import UIKit
import CoreServices
import Photos
import PhotosUI
import PromiseKit
import BChatUtilitiesKit
import SignalUtilitiesKit

extension ConversationVC : InputViewDelegate, MessageCellDelegate, ContextMenuActionDelegate, ScrollToBottomButtonDelegate,
    SendMediaNavDelegate, UIDocumentPickerDelegate, AttachmentApprovalViewControllerDelegate, GifPickerViewControllerDelegate,
    ConversationTitleViewDelegate {

    func handleTitleViewTapped() {
        // Don't take the user to settings for message requests
        guard
            let contactThread: TSContactThread = thread as? TSContactThread,
            let contact: Contact = Storage.shared.getContact(with: contactThread.contactBChatID()),
            contact.isApproved,
            contact.didApproveMe
        else {
            return
        }
        
        openSettings()
    }
    
    @objc func openSettings() {
        snInputView.resignFirstResponder()
        let settingsVC = ChatSettingsVC()
        settingsVC.configure(with: thread, viewItems: viewItems, uiDatabaseConnection: OWSPrimaryStorage.shared().uiDatabaseConnection)
        settingsVC.conversationSettingsViewDelegate = self
        navigationController!.pushViewController(settingsVC, animated: true, completion: nil)
    }

    func handleScrollToBottomButtonTapped() {
        // The table view's content size is calculated by the estimated height of cells,
        // so the result may be inaccurate before all the cells are loaded. Use this
        // to scroll to the last row instead.
        let indexPath = IndexPath(row: viewItems.count - 1, section: 0)
        unreadViewItems.removeAll()
        messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
    }
    
    // MARK: Call
    @objc func startCall(_ sender: Any?) {
        snInputView.resignFirstResponder()
        guard let thread = thread as? TSContactThread else { return }
        let publicKey = thread.contactBChatID()
        let contact: Contact = Storage.shared.getContact(with: publicKey)!
        if contact.isBlocked {
            guard !showBlockedModalIfNeeded() else { return }
        } else {
            guard BChatCall.isEnabled else { return }
            if SSKPreferences.areCallsEnabled {
                requestMicrophonePermissionIfNeeded { }
                guard AVAudioSession.sharedInstance().recordPermission == .granted else { return }
                guard let contactBChatID = (thread as? TSContactThread)?.contactBChatID() else { return }
                guard AppEnvironment.shared.callManager.currentCall == nil else { return }
                let call = BChatCall(for: contactBChatID, uuid: UUID().uuidString.lowercased(), mode: .offer, outgoing: true)
                let callVC = NewIncomingCallVC(for: call)
                callVC.conversationVC = self
                self.inputAccessoryView?.isHidden = true
                self.inputAccessoryView?.alpha = 0
                present(callVC, animated: true, completion: nil)
                //CallVC
                //NewIncomingCallVC
            } else {
                snInputView.isHidden = true
                let vc = CallPermissionRequestModalNewVC()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }
    }

    // MARK: Blocking
    @objc func unblock() {
        guard let thread = thread as? TSContactThread else { return }
        let publicKey = thread.contactBChatID()
        UIView.animate(withDuration: 0.25, animations: {
        }, completion: { _ in
            if let contact: Contact = Storage.shared.getContact(with: publicKey) {
                Storage.shared.write(
                    with: { transaction in
                        guard let transaction = transaction as? YapDatabaseReadWriteTransaction else { return }
                        
                        contact.isBlocked = false
                        Storage.shared.setContact(contact, using: transaction)
                    },
                    completion: {
                        self.snInputView.isHidden = false
                        if let clearChatButtonStackView = self.view.viewWithTag(111) {
                            clearChatButtonStackView.removeFromSuperview()
                        }
                        MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                    }
                )
            }
        })
    }

    func showBlockedModalIfNeeded() -> Bool {
        guard let thread = thread as? TSContactThread, thread.isBlocked() else { return false }
        let blockedModal = BlockedModal(publicKey: thread.contactBChatID())
        blockedModal.modalPresentationStyle = .overFullScreen
        blockedModal.modalTransitionStyle = .crossDissolve
        present(blockedModal, animated: true, completion: nil)
        return true
    }

    // MARK: Attachments
    func didPasteImageFromPasteboard(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        let dataSource = DataSourceValue.dataSource(with: imageData, utiType: kUTTypeJPEG as String)
        let attachment = SignalAttachment.attachment(dataSource: dataSource, dataUTI: kUTTypeJPEG as String, imageQuality: .medium)
        
        let approvalVC = AttachmentApprovalViewController.wrappedInNavController(attachments: [ attachment ], approvalDelegate: self)
        approvalVC.modalPresentationStyle = .fullScreen
        self.present(approvalVC, animated: true, completion: nil)
    }
    
    func sendMediaNavDidCancel(_ sendMediaNavigationController: SendMediaNavigationController) {
        dismiss(animated: true, completion: nil)
    }

    func sendMediaNav(_ sendMediaNavigationController: SendMediaNavigationController, didApproveAttachments attachments: [SignalAttachment], messageText: String?) {
        sendAttachments(attachments, with: messageText ?? "")
        resetMentions()
        self.snInputView.text = ""
        dismiss(animated: true) { }
    }

    func sendMediaNavInitialMessageText(_ sendMediaNavigationController: SendMediaNavigationController) -> String? {
        return snInputView.text
    }

    func sendMediaNav(_ sendMediaNavigationController: SendMediaNavigationController, didChangeMessageText newMessageText: String?) {
        snInputView.text = newMessageText ?? ""
    }

    func attachmentApproval(_ attachmentApproval: AttachmentApprovalViewController, didApproveAttachments attachments: [SignalAttachment], messageText: String?) {
        sendAttachments(attachments, with: messageText ?? "") { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        scrollToBottom(isAnimated: false)
        resetMentions()
        self.snInputView.text = ""
    }

    func attachmentApprovalDidCancel(_ attachmentApproval: AttachmentApprovalViewController) {
        dismiss(animated: true, completion: nil)
    }

    func attachmentApproval(_ attachmentApproval: AttachmentApprovalViewController, didChangeMessageText newMessageText: String?) {
        snInputView.text = newMessageText ?? ""
    }

    func handleCameraButtonTapped() {
        guard requestCameraPermissionIfNeeded() else { return }
        requestMicrophonePermissionIfNeeded { }
        if AVAudioSession.sharedInstance().recordPermission != .granted {
            SNLog("Proceeding without microphone access. Any recorded video will be silent.")
        }
        let sendMediaNavController = SendMediaNavigationController.showingCameraFirst()
        sendMediaNavController.sendMediaNavDelegate = self
        sendMediaNavController.modalPresentationStyle = .fullScreen
        present(sendMediaNavController, animated: true, completion: nil)
    }
    
    func handleLibraryButtonTapped() {
        requestLibraryPermissionIfNeeded { [weak self] in
            DispatchQueue.main.async {
                let sendMediaNavController = SendMediaNavigationController.showingMediaLibraryFirst()
                sendMediaNavController.sendMediaNavDelegate = self
                sendMediaNavController.modalPresentationStyle = .fullScreen
                self?.present(sendMediaNavController, animated: true, completion: nil)
            }
        }
    }
    
    func handleGIFButtonTapped() {
        let gifVC = GifPickerViewController(thread: thread)
        gifVC.delegate = self
        let navController = OWSNavigationController(rootViewController: gifVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true) { }
    }

    func gifPickerDidSelect(attachment: SignalAttachment) {
        showAttachmentApprovalDialog(for: [ attachment ])
    }
    
    func handleDocumentButtonTapped() {
        // UIDocumentPickerModeImport copies to a temp file within our container.
        // It uses more memory than "open" but lets us avoid working with security scoped URLs.
        let documentPickerVC = UIDocumentPickerViewController(documentTypes: [ kUTTypeItem as String ], in: UIDocumentPickerMode.import)
        documentPickerVC.delegate = self
        documentPickerVC.modalPresentationStyle = .fullScreen
        SNAppearance.switchToDocumentPickerAppearance()
        present(documentPickerVC, animated: true, completion: nil)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        SNAppearance.switchToBChatAppearance() // Switch back to the correct appearance
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        SNAppearance.switchToBChatAppearance()
        guard let url = urls.first else { return } // TODO: Handle multiple?
        let urlResourceValues: URLResourceValues
        do {
            urlResourceValues = try url.resourceValues(forKeys: [ .typeIdentifierKey, .isDirectoryKey, .nameKey ])
        } catch {
            let alert = UIAlertController(title: "BChat", message: "An error occurred.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            return presentAlert(alert)
        }
        let type = urlResourceValues.typeIdentifier ?? (kUTTypeData as String)
        guard urlResourceValues.isDirectory != true else {
            DispatchQueue.main.async {
                let title = NSLocalizedString("ATTACHMENT_PICKER_DOCUMENTS_PICKED_DIRECTORY_FAILED_ALERT_TITLE", comment: "")
                let message = NSLocalizedString("ATTACHMENT_PICKER_DOCUMENTS_PICKED_DIRECTORY_FAILED_ALERT_BODY", comment: "")
                OWSAlerts.showAlert(title: title, message: message)
            }
            return
        }
        let fileName = urlResourceValues.name ?? NSLocalizedString("ATTACHMENT_DEFAULT_FILENAME", comment: "")
        guard let dataSource = DataSourcePath.dataSource(with: url, shouldDeleteOnDeallocation: false) else {
            DispatchQueue.main.async {
                let title = NSLocalizedString("ATTACHMENT_PICKER_DOCUMENTS_FAILED_ALERT_TITLE", comment: "")
                OWSAlerts.showAlert(title: title)
            }
            return
        }
        dataSource.sourceFilename = fileName
        // Although we want to be able to send higher quality attachments through the document picker
        // it's more imporant that we ensure the sent format is one all clients can accept (e.g. *not* quicktime .mov)
        guard !SignalAttachment.isInvalidVideo(dataSource: dataSource, dataUTI: type) else {
            return showAttachmentApprovalDialogAfterProcessingVideo(at: url, with: fileName)
        }
        // "Document picker" attachments _SHOULD NOT_ be resized
        let attachment = SignalAttachment.attachment(dataSource: dataSource, dataUTI: type, imageQuality: .original)
        showAttachmentApprovalDialog(for: [ attachment ])
    }

    func showAttachmentApprovalDialog(for attachments: [SignalAttachment]) {
        let navController = AttachmentApprovalViewController.wrappedInNavController(attachments: attachments, approvalDelegate: self)
        present(navController, animated: true, completion: nil)
    }

    func showAttachmentApprovalDialogAfterProcessingVideo(at url: URL, with fileName: String) {
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: true, message: nil) { [weak self] modalActivityIndicator in
            let dataSource = DataSourcePath.dataSource(with: url, shouldDeleteOnDeallocation: false)!
            dataSource.sourceFilename = fileName
            let compressionResult: SignalAttachment.VideoCompressionResult = SignalAttachment.compressVideoAsMp4(dataSource: dataSource, dataUTI: kUTTypeMPEG4 as String)
            compressionResult.attachmentPromise.done { attachment in
                guard !modalActivityIndicator.wasCancelled, let attachment = attachment as? SignalAttachment else { return }
                modalActivityIndicator.dismiss {
                    if !attachment.hasError {
                        self?.showAttachmentApprovalDialog(for: [ attachment ])
                    } else {
                        self?.showErrorAlert(for: attachment, onDismiss: nil)
                    }
                }
            }.retainUntilComplete()
        }
    }

    // MARK: Message Sending
    func handleSendButtonTapped() {
        sendMessage()
    }
    
    func sendMessage(hasPermissionToSendSeed: Bool = false) {
        guard !showBlockedModalIfNeeded() else { return }
        let text = replaceMentions(in: snInputView.text.trimmingCharacters(in: .whitespacesAndNewlines))
        let thread = self.thread
        guard !text.isEmpty else { return }
        
        if text.contains(mnemonic) && !thread.isNoteToSelf() && !hasPermissionToSendSeed {
            // Warn the user if they're about to send their seed to someone
            inputAccessoryView?.isHidden = true
            inputAccessoryView?.alpha = 0
            let modal = OwnSeedWarningPopUp()
            modal.modalPresentationStyle = .overFullScreen
            modal.modalTransitionStyle = .crossDissolve
            modal.proceed = {
                self.showInputAccessoryView()
                self.sendMessage(hasPermissionToSendSeed: true)
            }
            modal.cancel = {
                self.showInputAccessoryView()
            }
            return present(modal, animated: true, completion: nil)
        }
        
        //john Developed.
        let spaceCount = text.reduce(0) { $1.isWhitespace && !$1.isNewline ? $0 + 1 : $0 }
        // I have develop word count 4096 perpose logic
        if spaceCount < 0 {
            
        }else{
            if text.count == 4096 || text.count > 4096 {
                self.showToast(message: "Text limit exceed: Maximum limit of messages is 4096 characters", seconds: 1.5)
            }else {
                let thread = self.thread
                
                let sentTimestamp: UInt64 = NSDate.millisecondTimestamp()
                let message: VisibleMessage = VisibleMessage()
                message.sentTimestamp = sentTimestamp
                message.text = text
                message.quote = VisibleMessage.Quote.from(snInputView.quoteDraftInfo?.model)
                
                // Note: 'shouldBeVisible' is set to true the first time a thread is saved so we can
                // use it to determine if the user is creating a new thread and update the 'isApproved'
                // flags appropriately
                let oldThreadShouldBeVisible: Bool = thread.shouldBeVisible
                let linkPreviewDraft = snInputView.linkPreviewInfo?.draft
                let tsMessage = TSOutgoingMessage.from(message, associatedWith: thread)
                
                let promise: Promise<Void> = self.approveMessageRequestIfNeeded(
                    for: self.thread,
                    isNewThread: !oldThreadShouldBeVisible,
                    timestamp: (sentTimestamp - 1)  // Set 1ms earlier as this is used for sorting
                )
                .map { [weak self] _ in
                    self?.viewModel.appendUnsavedOutgoingTextMessage(tsMessage)
            
                    Storage.write(with: { transaction in
                        message.linkPreview = VisibleMessage.LinkPreview.from(linkPreviewDraft, using: transaction)
                    }, completion: { [weak self] in
                        tsMessage.linkPreview = OWSLinkPreview.from(message.linkPreview)
                        
                        Storage.shared.write(
                            with: { transaction in
                                tsMessage.save(with: transaction as! YapDatabaseReadWriteTransaction)
                            },
                            completion: { [weak self] in
                                // At this point the TSOutgoingMessage should have its link preview set, so we can scroll to the bottom knowing
                                // the height of the new message cell
                                self?.scrollToBottom(isAnimated: false)
                            }
                            
                        )
                        
                        Storage.shared.write { transaction in
                            MessageSender.send(message, with: [], in: thread, using: transaction as! YapDatabaseReadWriteTransaction)
                        }
                        
                        self?.handleMessageSent()
                    })
                }
                
                // Show an error indicating that approving the thread failed
                promise.catch(on: DispatchQueue.main) { [weak self] _ in
                    let alert = UIAlertController(title: "BChat", message: "An error occurred when trying to accept this message request", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
                
                promise.retainUntilComplete()
            }
        }
    }

    func sendAttachments(_ attachments: [SignalAttachment], with text: String, onComplete: (() -> ())? = nil) {
        guard !showBlockedModalIfNeeded() else { return }
        
        for attachment in attachments {
            if attachment.hasError {
                return showErrorAlert(for: attachment, onDismiss: onComplete)
            }
        }
        
        let thread = self.thread
        let sentTimestamp: UInt64 = NSDate.millisecondTimestamp()
        let message = VisibleMessage()
        message.sentTimestamp = sentTimestamp
        message.text = replaceMentions(in: text)
        
        // Note: 'shouldBeVisible' is set to true the first time a thread is saved so we can
        // use it to determine if the user is creating a new thread and update the 'isApproved'
        // flags appropriately
        let oldThreadShouldBeVisible: Bool = thread.shouldBeVisible
        let tsMessage = TSOutgoingMessage.from(message, associatedWith: thread)
        
        let promise: Promise<Void> = self.approveMessageRequestIfNeeded(
            for: self.thread,
            isNewThread: !oldThreadShouldBeVisible,
            timestamp: (sentTimestamp - 1)  // Set 1ms earlier as this is used for sorting
        )
        .map { [weak self] _ in
            Storage.write(
                with: { transaction in
                    tsMessage.save(with: transaction)
                    // The new message cell is inserted at this point, but the TSOutgoingMessage doesn't have its attachment yet
                },
                completion: { [weak self] in
                    Storage.write(with: { transaction in
                        MessageSender.send(message, with: attachments, in: thread, using: transaction)
                    }, completion: { [weak self] in
                        // At this point the TSOutgoingMessage should have its attachments set, so we can scroll to the bottom knowing
                        // the height of the new message cell
                        self?.scrollToBottom(isAnimated: false)
                    })
                    self?.handleMessageSent()
            
                    // Attachment successfully sent - dismiss the screen
                    onComplete?()
                }
            )
        }
    
        // Show an error indicating that approving the thread failed
        promise.catch(on: DispatchQueue.main) { [weak self] _ in
            let alert = UIAlertController(title: "BChat", message: "An error occurred when trying to accept this message request", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
        
        promise.retainUntilComplete()
    }

    func handleMessageSent() {
        resetMentions()
        self.snInputView.text = ""
        self.snInputView.quoteDraftInfo = nil
        
        // Update the input state if this is a contact thread
        if let contactThread: TSContactThread = thread as? TSContactThread {
            let contact: Contact? = Storage.shared.getContact(with: contactThread.contactBChatID())
            
            // If the contact doesn't exist yet then it's a message request without the first message sent
            // so only allow text-based messages
            self.snInputView.setEnabledMessageTypes(
                (thread.isNoteToSelf() || contact?.didApproveMe == true || thread.isMessageRequest() ?
                    .all : .textOnly
                ),
                message: nil
            )
        }
        
        self.markAllAsRead()
        if Environment.shared.preferences.soundInForeground() {
            let soundID = OWSSounds.systemSoundID(for: .messageSent, quiet: true)
            AudioServicesPlaySystemSound(soundID)
        }
        SSKEnvironment.shared.typingIndicators.didSendOutgoingMessage(inThread: thread)
        Storage.write { transaction in
            self.thread.setDraft("", transaction: transaction)
        }
    }

    // MARK: Input View
    func inputTextViewDidChangeContent(_ inputTextView: InputTextView) {
        let newText = inputTextView.text ?? ""
        if !newText.isEmpty {
            SSKEnvironment.shared.typingIndicators.didStartTypingOutgoingInput(inThread: thread)
        }
        inputTextView.textColor = Colors.text
        if newText != "" && newText.isNumeric == true && newText.filter({ $0 == "." }).count <= 1 {
            if WalletSharedData.sharedInstance.wallet != nil {
                if SSKPreferences.areWalletEnabled {
                    let blockChainHeight = WalletSharedData.sharedInstance.wallet!.blockChainHeight
                    let daemonBlockChainHeight = WalletSharedData.sharedInstance.wallet!.daemonBlockChainHeight
                    if blockChainHeight == daemonBlockChainHeight {
                        if SSKPreferences.areWalletEnabled {
                            if let contactThread: TSContactThread = thread as? TSContactThread {
                                if let contact: Contact = Storage.shared.getContact(with: contactThread.contactBChatID()), contact.isApproved, contact.didApproveMe, !thread.isNoteToSelf(), !thread.isMessageRequest(), !contact.isBlocked {
                                    if contact.beldexAddress != nil {
                                        if SSKPreferences.arePayAsYouChatEnabled {
                                            if self.audioRecorder == nil && snInputView.quoteDraftInfo == nil {
                                                customizeSlideToOpen.isHidden = false
                                                inputTextView.textColor = Colors.accent
                                                CustomSlideView.isFromExpandAttachment = true
                                                NotificationCenter.default.post(name: .attachmentHiddenNotification, object: nil)
                                            } else {
                                                customizeSlideToOpen.isHidden = true
                                                CustomSlideView.isFromExpandAttachment = false
                                            }
                                        }
                                    }
                                } else {
                                    customizeSlideToOpen.isHidden = true
                                    CustomSlideView.isFromExpandAttachment = false
                                }
                            }
                        }
                    } else {
                        customizeSlideToOpen.isHidden = true
                        CustomSlideView.isFromExpandAttachment = false
                    }
                    print("Height-->",blockChainHeight,daemonBlockChainHeight)
                }
            }
        } else {
            customizeSlideToOpen.isHidden = true
            CustomSlideView.isFromExpandAttachment = false
        }
        updateMentions(for: newText)
    }

    func showLinkPreviewSuggestionModal() {
        let linkPreviewModel = LinkPreviewModal() { [weak self] in
            self?.snInputView.autoGenerateLinkPreview()
        }
        linkPreviewModel.modalPresentationStyle = .overFullScreen
        linkPreviewModel.modalTransitionStyle = .crossDissolve
        dismiss(animated: true)
    }

    // MARK: Mentions
    func updateMentions(for newText: String) {
        if newText.count < oldText.count {
            currentMentionStartIndex = nil
            snInputView.hideMentionsUI()
            mentions = mentions.filter { $0.isContained(in: newText) }
        }
        if !newText.isEmpty {
            let lastCharacterIndex = newText.index(before: newText.endIndex)
            let lastCharacter = newText[lastCharacterIndex]
            // Check if there is whitespace before the '@' or the '@' is the first character
            let isCharacterBeforeLastWhiteSpaceOrStartOfLine: Bool
            if newText.count == 1 {
                isCharacterBeforeLastWhiteSpaceOrStartOfLine = true // Start of line
            } else {
                let characterBeforeLast = newText[newText.index(before: lastCharacterIndex)]
                isCharacterBeforeLastWhiteSpaceOrStartOfLine = characterBeforeLast.isWhitespace
            }
            if lastCharacter == "@" && isCharacterBeforeLastWhiteSpaceOrStartOfLine {
                let candidates = MentionsManager.getMentionCandidates(for: "", in: thread.uniqueId!)
                currentMentionStartIndex = lastCharacterIndex
                snInputView.showMentionsUI(for: candidates, in: thread)
            } else if lastCharacter.isWhitespace || lastCharacter == "@" { // the lastCharacter == "@" is to check for @@
                currentMentionStartIndex = nil
                snInputView.hideMentionsUI()
            } else {
                if let currentMentionStartIndex = currentMentionStartIndex {
                    let query = String(newText[newText.index(after: currentMentionStartIndex)...]) // + 1 to get rid of the @
                    let candidates = MentionsManager.getMentionCandidates(for: query, in: thread.uniqueId!)
                    snInputView.showMentionsUI(for: candidates, in: thread)
                }
            }
        }
        oldText = newText
    }

    func resetMentions() {
        oldText = ""
        currentMentionStartIndex = nil
        mentions = []
    }

    func replaceMentions(in text: String) -> String {
        var result = text
        for mention in mentions {
            guard let range = result.range(of: "@\(mention.displayName)") else { continue }
            result = result.replacingCharacters(in: range, with: "@\(mention.publicKey)")
        }
        return result
    }

    func handleMentionSelected(_ mention: Mention, from view: MentionSelectionView) {
        guard let currentMentionStartIndex = currentMentionStartIndex else { return }
        mentions.append(mention)
        let oldText = snInputView.text
        let newText = oldText.replacingCharacters(in: currentMentionStartIndex..., with: "@\(mention.displayName) ")
        snInputView.text = newText
        self.currentMentionStartIndex = nil
        snInputView.hideMentionsUI()
        self.oldText = newText
    }
    
    func showInputAccessoryView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.inputAccessoryView?.isHidden = false
            self.inputAccessoryView?.alpha = 1
        })
    }

    // MARK: View Item Interaction
    func handleViewItemLongPressed(_ viewItem: ConversationViewItem) {
        // Show the context menu if applicable
        guard let index = viewItems.firstIndex(where: { $0 === viewItem }),
            let cell = messagesTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? VisibleMessageCell,
            let snapshot = cell.bubbleView.snapshotView(afterScreenUpdates: false), contextMenuWindow == nil,
            !ContextMenuVC.actions(for: viewItem, delegate: self).isEmpty else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        let frame = cell.convert(cell.bubbleView.frame, to: UIApplication.shared.keyWindow!)
        let window = ContextMenuWindow()
        let contextMenuVC = ContextMenuVC(snapshot: snapshot, viewItem: viewItem, frame: frame, delegate: self) { [weak self] in
            window.isHidden = true
            guard let self = self else { return }
            self.contextMenuVC = nil
            self.contextMenuWindow = nil
            self.scrollButton.alpha = 0
            UIView.animate(withDuration: 0.25) {
                self.scrollButton.alpha = self.getScrollButtonOpacity()
                self.unreadCountView.alpha = self.scrollButton.alpha
            }
        }
        self.contextMenuVC = contextMenuVC
        contextMenuWindow = window
        window.rootViewController = contextMenuVC
        window.makeKeyAndVisible()
        window.backgroundColor = .clear
    }
    
    func handleTapToCallback() {
        if SSKPreferences.areCallsEnabled {
            requestMicrophonePermissionIfNeeded { }
            guard AVAudioSession.sharedInstance().recordPermission == .granted else { return }
            guard let contactBChatID = (thread as? TSContactThread)?.contactBChatID() else { return }
            guard AppEnvironment.shared.callManager.currentCall == nil else { return }
            let call = BChatCall(for: contactBChatID, uuid: UUID().uuidString.lowercased(), mode: .offer, outgoing: true)
            let callVC = NewIncomingCallVC(for: call)
            callVC.conversationVC = self
            snInputView.isHidden = true
            present(callVC, animated: true, completion: nil)
            
        } else {
            snInputView.isHidden = true
            let vc = CallPermissionRequestModalNewVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func confirmDownload(_ viewItem: ConversationViewItem) {
        snInputView.isHidden = true
        let vc = DownloadAttachmentPopUpViewController(viewItem: viewItem)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }

    func handleViewItemTapped(_ viewItem: ConversationViewItem, gestureRecognizer: UITapGestureRecognizer) {
        
        if snInputView.attachmentsButton.isExpanded {
            snInputView.attachmentsButton.isExpanded = false
            return
        }
        
        if let message = viewItem.interaction as? TSInfoMessage, message.messageType == .call {
            let caller = (thread as! TSContactThread).name()
            let vc = MissedCallPopUp(caller: caller)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        } else if let message = viewItem.interaction as? TSOutgoingMessage, message.messageState == .failed {
            // Show the failed message sheet
            showFailedMessageSheet(for: message)
        } else {
            switch viewItem.messageCellType {
                case .audio:
                    if viewItem.interaction is TSIncomingMessage,
                        let thread = self.thread as? TSContactThread,
                        Storage.shared.getContact(with: thread.contactBChatID())?.isTrusted != true {
                        confirmDownload(viewItem)
                    } else {
                        guard let index = viewItems.firstIndex(where: { $0 === viewItem }),
                            let cell = messagesTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? VisibleMessageCell else { return }
                        let albumView = cell.subviews[6]
                        let albumCheck = gestureRecognizer.location(in: albumView)
                        if albumCheck.x < 0 || albumCheck.x > albumView.frame.maxX {
                            return
                        }
                        playOrPauseAudio(for: viewItem)
                    }
                case .mediaMessage:
                    guard let index = viewItems.firstIndex(where: { $0 === viewItem }),
                        let cell = messagesTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? VisibleMessageCell else { return }
                    if viewItem.interaction is TSIncomingMessage,
                        let thread = self.thread as? TSContactThread,
                        Storage.shared.getContact(with: thread.contactBChatID())?.isTrusted != true {
                        confirmDownload(viewItem)
                    } else {
                        guard let albumView = cell.albumView else { return }
                        let locationInCell = gestureRecognizer.location(in: cell)
                        // Figure out which of the media views was tapped
                        let albumCheck = gestureRecognizer.location(in: albumView)
                        if albumCheck.x < 0 || albumCheck.x > albumView.frame.maxX {
                            return
                        }
                        let locationInAlbumView = cell.convert(locationInCell, to: albumView)
                        guard let mediaView = albumView.mediaView(forLocation: locationInAlbumView) else { return }
                        if albumView.isMoreItemsView(mediaView: mediaView) && viewItem.mediaAlbumHasFailedAttachment() {
                            // TODO: Tapped a failed incoming attachment
                        }
                        let attachment = mediaView.attachment
                        if let pointer = attachment as? TSAttachmentPointer {
                            if pointer.state == .failed {
                                // TODO: Tapped a failed incoming attachment
                            }
                        }
                        guard let stream = attachment as? TSAttachmentStream else { return }
                        let gallery = MediaGallery(thread: thread, options: [ .sliderEnabled, .showAllMediaButton ]) //*************
                        gallery.presentDetailView(fromViewController: self, mediaAttachment: stream)
                    }
                case .genericAttachment:
                    if viewItem.interaction is TSIncomingMessage,
                        let thread = self.thread as? TSContactThread,
                        Storage.shared.getContact(with: thread.contactBChatID())?.isTrusted != true {
                        self.confirmDownload(viewItem)
                    }
                    else if (viewItem.attachmentStream?.isText == true ||
                        viewItem.attachmentStream?.isMicrosoftDoc == true ||
                        viewItem.attachmentStream?.contentType == OWSMimeTypeApplicationPdf), let filePathString: String = viewItem.attachmentStream?.originalFilePath {
                        let fileUrl: URL = URL(fileURLWithPath: filePathString)
                        let interactionController: UIDocumentInteractionController = UIDocumentInteractionController(url: fileUrl)
                        interactionController.delegate = self
                        interactionController.presentPreview(animated: true)
                    }
                    else {
                        // Open the document if possible
                        guard let url = viewItem.attachmentStream?.originalMediaURL else { return }
                        let shareVC = UIActivityViewController(activityItems: [ url ], applicationActivities: nil)
                        if UIDevice.current.isIPad {
                            shareVC.excludedActivityTypes = []
                            shareVC.popoverPresentationController?.permittedArrowDirections = []
                            shareVC.popoverPresentationController?.sourceView = self.view
                            shareVC.popoverPresentationController?.sourceRect = self.view.bounds
                        }
                        navigationController!.present(shareVC, animated: true, completion: nil)
                    }
                case .textOnlyMessage:
                    if let reply = viewItem.quotedReply {
                        // Scroll to the source of the reply
                        guard let indexPath = viewModel.ensureLoadWindowContainsQuotedReply(reply) else { return }
                        messagesTableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: true)
                    } else if let message = viewItem.interaction as? TSIncomingMessage, let name = message.openGroupInvitationName,
                        let url = message.openGroupInvitationURL {
                        joinOpenGroup(name: name, url: url)
                    } else if let payment = viewItem.interaction as? TSIncomingMessage, let id = payment.paymentTxnid, let amount = payment.paymentAmount {
                        joinBeldexExplorer(id: id, amount: amount)
                    } else if let payment = viewItem.interaction as? TSOutgoingMessage, let id = payment.paymentTxnid, let amount = payment.paymentAmount {
                        joinBeldexExplorer(id: id, amount: amount)
                    } else {
                        if isKeyboardPresented {
                            UIApplication.dismissKeyboard()
                        }
                    }
                default: break
            }
        }
    }
    
    func handleViewItemSwiped(_ viewItem: ConversationViewItem, state: SwipeState) {
        switch state {
            case .began:
                messagesTableView.isScrollEnabled = false
            case .ended, .cancelled:
                messagesTableView.isScrollEnabled = true
        }
    }

    func showFailedMessageSheet(for tsMessage: TSOutgoingMessage) {
        let thread = self.thread
        let error = tsMessage.mostRecentFailureText
        let sheet = UIAlertController(title: error, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            Storage.write { transaction in
                tsMessage.remove(with: transaction)
                Storage.shared.cancelPendingMessageSendJobIfNeeded(for: tsMessage.timestamp, using: transaction)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Resend", style: .default, handler: { _ in
            let message = VisibleMessage.from(tsMessage)
            Storage.write { transaction in
                var attachments: [TSAttachmentStream] = []
                tsMessage.attachmentIds.forEach { attachmentID in
                    guard let attachmentID = attachmentID as? String else { return }
                    let attachment = TSAttachment.fetch(uniqueId: attachmentID, transaction: transaction)
                    guard let stream = attachment as? TSAttachmentStream else { return }
                    attachments.append(stream)
                }
                MessageSender.prep(attachments, for: message, using: transaction)
                MessageSender.send(message, in: thread, using: transaction)
            }
        }))
        // HACK: Extracting this info from the error string is pretty dodgy
        let prefix = "HTTP request failed at destination (Master node "
        if error.hasPrefix(prefix) {
            let rest = error.substring(from: prefix.count)
            if let index = rest.firstIndex(of: ")") {
                let snodeAddress = String(rest[rest.startIndex..<index])
                sheet.addAction(UIAlertAction(title: "Copy Master Node Info", style: .default, handler: { _ in
                    UIPasteboard.general.string = snodeAddress
                }))
            }
        }
        presentAlert(sheet)
    }

    func handleViewItemDoubleTapped(_ viewItem: ConversationViewItem) {
        switch viewItem.messageCellType {
        case .audio: speedUpAudio(for: viewItem) // The user can double tap a voice message when it's playing to speed it up
        default: break
        }
    }
    
    func showFullText(_ viewItem: ConversationViewItem) {
        let longMessageVC = LongTextViewController(viewItem: viewItem)
        navigationController!.pushViewController(longMessageVC, animated: true)
    }
    
    func reply(_ viewItem: ConversationViewItem) {
        customizeSlideToOpen.isHidden = true
        CustomSlideView.isFromExpandAttachment = false
        var quoteDraftOrNil: OWSQuotedReplyModel?
        Storage.read { transaction in
            quoteDraftOrNil = OWSQuotedReplyModel.quotedReplyForSending(with: viewItem, threadId: viewItem.interaction.uniqueThreadId, transaction: transaction)
        }
        guard let quoteDraft = quoteDraftOrNil else { return }
        let isOutgoing = (viewItem.interaction.interactionType() == .outgoingMessage)
        snInputView.quoteDraftInfo = (model: quoteDraft, isOutgoing: isOutgoing)
        snInputView.becomeFirstResponder()
    }
    
    func copy(_ viewItem: ConversationViewItem) {
        if viewItem.canCopyMedia() {
            viewItem.copyMediaAction()
        } else if let payment = viewItem.interaction as? TSIncomingMessage, let id = payment.paymentTxnid, let amount = payment.paymentAmount {
            let fullDetails = "Amount:\(amount), txnid:\(id)"
            UIPasteboard.general.string = fullDetails
        } else if let payment = viewItem.interaction as? TSOutgoingMessage, let id = payment.paymentTxnid, let amount = payment.paymentAmount {
            let fullDetails = "Amount:\(amount), txnid:\(id)"
            UIPasteboard.general.string = fullDetails
        } else {
            viewItem.copyTextAction()
        }
        self.showToast(message: "Copied to clipboard", seconds: 1.0)
    }
    
    func copyBChatID(_ viewItem: ConversationViewItem) {
        // FIXME: Copying media
        guard let message = viewItem.interaction as? TSIncomingMessage else { return }
        UIPasteboard.general.string = message.authorId
    }
    
    func delete(_ viewItem: ConversationViewItem) {
        guard let message = viewItem.interaction as? TSMessage else { return self.deleteLocally(viewItem) }
        
        // Handle open group messages the old way
        if message.isOpenGroupMessage { return self.deleteForEveryone(viewItem) }
        
        // Handle 1-1 and closed group messages with unsend request
        if viewItem.interaction.interactionType() == .outgoingMessage, message.serverHash != nil  {
            let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteLocallyAction = UIAlertAction.init(title: NSLocalizedString("delete_message_for_me", comment: ""), style: .destructive) { _ in
                self.deleteLocally(viewItem)
                if !self.thread.isBlocked() {
                    self.showInputAccessoryView()
                }
            }
            alertVC.addAction(deleteLocallyAction)
            
            var title = NSLocalizedString("delete_message_for_everyone", comment: "")
            if !viewItem.isGroupThread {
                title = String(format: NSLocalizedString("delete_message_for_me_and_recipient", comment: ""), viewItem.interaction.thread.name())
            }
            let deleteRemotelyAction = UIAlertAction.init(title: title, style: .destructive) { _ in
                self.deleteForEveryone(viewItem)
                if !self.thread.isBlocked() {
                    self.showInputAccessoryView()
                }
            }
            alertVC.addAction(deleteRemotelyAction)
            
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("TXT_CANCEL_TITLE", comment: ""), style: .cancel) {_ in
                if !self.thread.isBlocked() {
                    self.showInputAccessoryView()
                }
            }
            alertVC.addAction(cancelAction)
            
            self.inputAccessoryView?.isHidden = true
            self.inputAccessoryView?.alpha = 0
            self.presentAlert(alertVC)
        } else {
            let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteLocallyAction = UIAlertAction.init(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
                self.deleteLocally(viewItem)
                if !self.thread.isBlocked() {
                    self.showInputAccessoryView()
                }
            }
            alertVC.addAction(deleteLocallyAction)
            var title = NSLocalizedString("Report & Delete", comment: "")
            if !viewItem.isGroupThread {
                title = String(format: NSLocalizedString("Report & Delete", comment: ""), viewItem.interaction.thread.name())
            }
            let deleteRemotelyAction = UIAlertAction.init(title: title, style: .destructive) { _ in
                let uiAlert = UIAlertController(title: "Report & Delete", message: "This message will be forwarded to the BChat Team & will be deleted.", preferredStyle: UIAlertController.Style.alert)
                self.present(uiAlert, animated: true, completion: nil)
                uiAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                }))
                uiAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                    self.deleteLocally(viewItem)
                    if !self.thread.isBlocked() {
                        self.showInputAccessoryView()
                    }
                }))
            }
            alertVC.addAction(deleteRemotelyAction)
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("TXT_CANCEL_TITLE", comment: ""), style: .cancel) {_ in
                if !self.thread.isBlocked() {
                    self.showInputAccessoryView()
                }
            }
            alertVC.addAction(cancelAction)
            self.inputAccessoryView?.isHidden = true
            self.inputAccessoryView?.alpha = 0
            self.presentAlert(alertVC)
        }
    }
    
    func report(_ viewItem: ConversationViewItem) {
        let uiAlert = UIAlertController(title: "Report", message: "This message will be Reported to the BChat Team.", preferredStyle: UIAlertController.Style.alert)
        self.present(uiAlert, animated: true, completion: nil)
        uiAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
        }))
        uiAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
        }))
    }
    
    private func buildUnsendRequest(_ viewItem: ConversationViewItem) -> UnsendRequest? {
        if let message = viewItem.interaction as? TSMessage,
           message.isOpenGroupMessage || message.serverHash == nil { return nil }
        let unsendRequest = UnsendRequest()
        switch viewItem.interaction.interactionType() {
        case .incomingMessage:
            if let incomingMessage = viewItem.interaction as? TSIncomingMessage {
                unsendRequest.author = incomingMessage.authorId
            }
        case .outgoingMessage: unsendRequest.author = getUserHexEncodedPublicKey()
        default: return nil // Should never occur
        }
        unsendRequest.timestamp = viewItem.interaction.timestamp
        return unsendRequest
    }
    
    func deleteLocally(_ viewItem: ConversationViewItem) {
        viewItem.deleteLocallyAction()
        if let unsendRequest = buildUnsendRequest(viewItem) {
            SNMessagingKitConfiguration.shared.storage.write { transaction in
                MessageSender.send(unsendRequest, to: .contact(publicKey: getUserHexEncodedPublicKey()), using: transaction).retainUntilComplete()
            }
        }
    }
    
    func deleteForEveryone(_ viewItem: ConversationViewItem) {
        viewItem.deleteLocallyAction()
        viewItem.deleteRemotelyAction()
        if let unsendRequest = buildUnsendRequest(viewItem) {
            SNMessagingKitConfiguration.shared.storage.write { transaction in
                MessageSender.send(unsendRequest, in: self.thread, using: transaction as! YapDatabaseReadWriteTransaction)
            }
        }
    }
    
    func save(_ viewItem: ConversationViewItem) {
        guard viewItem.canSaveMedia() else { return }
        viewItem.saveMediaAction()
        sendMediaSavedNotificationIfNeeded(for: viewItem)
    }
    
    func messageDetail(_ viewItem: ConversationViewItem) {
        let vc = MessageDetailsVC(with: viewItem, thread: self.thread)
        navigationController!.pushViewController(vc, animated: true)
    }
    
    func ban(_ viewItem: ConversationViewItem) {
        guard let message = viewItem.interaction as? TSIncomingMessage, message.isOpenGroupMessage else { return }
        let explanation = "This will ban the selected user from this room. It won't ban them from other rooms."
        let alert = UIAlertController(title: "BChat", message: explanation, preferredStyle: .alert)
        let threadID = thread.uniqueId!
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let publicKey = message.authorId
            guard let openGroupV2 = Storage.shared.getV2OpenGroup(for: threadID) else { return }
            OpenGroupAPIV2.ban(publicKey, from: openGroupV2.room, on: openGroupV2.server).retainUntilComplete()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        presentAlert(alert)
    }
    
    func banAndDeleteAllMessages(_ viewItem: ConversationViewItem) {
        guard let message = viewItem.interaction as? TSIncomingMessage, message.isOpenGroupMessage else { return }
        let explanation = "This will ban the selected user from this room and delete all messages sent by them. It won't ban them from other rooms or delete the messages they sent there."
        let alert = UIAlertController(title: "BChat", message: explanation, preferredStyle: .alert)
        let threadID = thread.uniqueId!
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            let publicKey = message.authorId
            guard let openGroupV2 = Storage.shared.getV2OpenGroup(for: threadID) else { return }
            OpenGroupAPIV2.banAndDeleteAllMessages(publicKey, from: openGroupV2.room, on: openGroupV2.server).retainUntilComplete()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        presentAlert(alert)
    }
    
    func contextMenuDismissed() {
        recoverInputView()
    }

    func handleQuoteViewCancelButtonTapped() {
        snInputView.quoteDraftInfo = nil
    }
    
    func hideAttachmentExpandedButtons() {
        if snInputView.attachmentsButton.isExpanded {
            snInputView.attachmentsButton.isExpanded = false
        }
    }
    
    // For open url
    func showOpenURLView(_ url: URL) {
        urlToOpen = url
        showOpenURLView()
    }
    
    func joinOpenGroup(name: String, url: String) {
        // Open groups can be unsafe, so always ask the user whether they want to join one
        let joinOpenGroupModal = JoinOpenGroupModal(name: name, url: url)
        joinOpenGroupModal.modalPresentationStyle = .overFullScreen
        joinOpenGroupModal.modalTransitionStyle = .crossDissolve
        present(joinOpenGroupModal, animated: true, completion: nil)
    }
    
    func joinBeldexExplorer(id: String, amount: String) {
        if let url = URL(string: "https://explorer.beldex.io/tx/\(id)") {
            UIApplication.shared.open(url)
        }
    }
    func handleReplyButtonTapped(for viewItem: ConversationViewItem) {
        reply(viewItem)
    }
    
    func showUserDetails(for bchatID: String) {
        let userDetailsSheet = UserDetailsSheet(for: bchatID)
        userDetailsSheet.modalPresentationStyle = .overFullScreen
        userDetailsSheet.modalTransitionStyle = .crossDissolve
        present(userDetailsSheet, animated: true, completion: nil)
    }

    // MARK: Voice Message Playback
    @objc func handleAudioDidFinishPlayingNotification(_ notification: Notification) {
        // Play the next voice message if there is one
        guard let audioPlayer = audioPlayer, let viewItem = audioPlayer.owner as? ConversationViewItem,
            let index = viewItems.firstIndex(where: { $0 === viewItem }), index < (viewItems.endIndex - 1) else { return }
        let nextViewItem = viewItems[index + 1]
        guard nextViewItem.messageCellType == .audio else { return }
        playOrPauseAudio(for: nextViewItem)
    }
    
    func playOrPauseAudio(for viewItem: ConversationViewItem) {
        guard let attachment = viewItem.attachmentStream else { return }
        let fileManager = FileManager.default
        guard let path = attachment.originalFilePath, fileManager.fileExists(atPath: path),
            let url = attachment.originalMediaURL else { return }
        if let audioPlayer = audioPlayer {
            if let owner = audioPlayer.owner as? ConversationViewItem, owner === viewItem {
                audioPlayer.playbackRate = 1
                audioPlayer.togglePlayState()
                return
            } else {
                audioPlayer.stop()
                self.audioPlayer = nil
            }
        }
        let audioPlayer = OWSAudioPlayer(mediaUrl: url, audioBehavior: .audioMessagePlayback, delegate: viewItem)
        self.audioPlayer = audioPlayer
        audioPlayer.owner = viewItem
        audioPlayer.play()
        audioPlayer.setCurrentTime(Double(viewItem.audioProgressSeconds))
    }

    func speedUpAudio(for viewItem: ConversationViewItem) {
        guard let audioPlayer = audioPlayer, let owner = audioPlayer.owner as? ConversationViewItem, owner === viewItem, audioPlayer.isPlaying else { return }
        audioPlayer.playbackRate = 1.5
        viewItem.lastAudioMessageView?.showSpeedUpLabel()
    }
    
    func payAsYouChatLongPress() {
        if !SSKPreferences.arePayAsYouChatEnabled {
            snInputView.isHidden = true
            let vc = PayAsYouChatPopUpVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }

    // MARK: Voice Message Recording
    func startVoiceMessageRecording() {
        // Request permission if needed
        self.customizeSlideToOpen.isHidden = true
        CustomSlideView.isFromExpandAttachment = false
        requestMicrophonePermissionIfNeeded() { [weak self] in
            self?.cancelVoiceMessageRecording()
        }
        // Keep screen on
        UIApplication.shared.isIdleTimerDisabled = false
        guard AVAudioSession.sharedInstance().recordPermission == .granted else { return }
        // Cancel any current audio playback
        audioPlayer?.stop()
        audioPlayer = nil
        // Create URL
        let directory = OWSTemporaryDirectory()
        let fileName = "\(NSDate.millisecondTimestamp()).m4a"
        let path = (directory as NSString).appendingPathComponent(fileName)
        let url = URL(fileURLWithPath: path)
        // Set up audio bchat
        let isConfigured = audioSession.startAudioActivity(recordVoiceMessageActivity)
        guard isConfigured else {
            return cancelVoiceMessageRecording()
        }
        // Set up audio recorder
        let settings: [String:NSNumber] = [
            AVFormatIDKey : NSNumber(value: kAudioFormatMPEG4AAC),
            AVSampleRateKey : NSNumber(value: 44100),
            AVNumberOfChannelsKey : NSNumber(value: 2),
            AVEncoderBitRateKey : NSNumber(value: 128 * 1024)
        ]
        let audioRecorder: AVAudioRecorder
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder.isMeteringEnabled = true
            self.audioRecorder = audioRecorder
        } catch {
            SNLog("Couldn't start audio recording due to error: \(error).")
            return cancelVoiceMessageRecording()
        }
        // Limit voice messages to a minute
        audioTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: false, block: { [weak self] _ in
            self?.snInputView.hideVoiceMessageUI()
            self?.endVoiceMessageRecording()
        })
        // Prepare audio recorder
        guard audioRecorder.prepareToRecord() else {
            SNLog("Couldn't prepare audio recorder.")
            return cancelVoiceMessageRecording()
        }
        // Start recording
        guard audioRecorder.record() else {
            SNLog("Couldn't record audio.")
            return cancelVoiceMessageRecording()
        }
        audioRecorder.pause()
        audioRecorder.record()
    }

    func endVoiceMessageRecording() {
        UIApplication.shared.isIdleTimerDisabled = true
        // Hide the UI
        snInputView.hideVoiceMessageUI()
        // Cancel the timer
        audioTimer?.invalidate()
        // Check preconditions
        guard let audioRecorder = audioRecorder else { return }
        // For LongPress stop audio
        let player = try? AVAudioPlayer(contentsOf: audioRecorder.url)
        // Get duration
        var duration = audioRecorder.currentTime
        // For LongPress stop audio
        if player?.duration ?? 0.0 > 1 {
            duration = player?.duration ?? 0.0
        }
        // Stop the recording
        stopVoiceMessageRecording()
        // Check for user misunderstanding
        guard duration > 1 else {
            isAudioRecording = false
            self.audioRecorder = nil
            let title = NSLocalizedString("VOICE_MESSAGE_TOO_SHORT_ALERT_TITLE", comment: "")
            let message = NSLocalizedString("VOICE_MESSAGE_TOO_SHORT_ALERT_MESSAGE", comment: "")
            return OWSAlerts.showAlert(title: title, message: message)
        }
        // Get data
        let dataSourceOrNil = DataSourcePath.dataSource(with: audioRecorder.url, shouldDeleteOnDeallocation: true)
        self.audioRecorder = nil
        guard let dataSource = dataSourceOrNil else { return SNLog("Couldn't load recorded data.") }
        // Create attachment
        let fileName = (NSLocalizedString("VOICE_MESSAGE_FILE_NAME", comment: "") as NSString).appendingPathExtension("m4a")
        dataSource.sourceFilename = fileName
        let attachment = SignalAttachment.voiceMessageAttachment(dataSource: dataSource, dataUTI: kUTTypeMPEG4Audio as String)
        guard !attachment.hasError else {
            return showErrorAlert(for: attachment, onDismiss: nil)
        }
        // Send attachment
        sendAttachments([ attachment ], with: "")
        audioPlayer = nil
        isAudioRecording = false
    }

    func cancelVoiceMessageRecording() {
        snInputView.hideVoiceMessageUI()
        audioTimer?.invalidate()
        stopVoiceMessageRecording()
        audioRecorder = nil
        audioPlayer = nil
        deleteAudioView.isHidden = true
        hideAttachmentExpandedButtons()
        isAudioRecording = false
    }
    
    func pauseRecording() {
        deleteAudioView.isHidden = false
        audioRecorder?.stop()
    }
    
    func showDeleteAudioView() {
        deleteAudioView.isHidden = false
    }
    
    func resumeAudioRecording() {
        // For Resume Audio Don't Delete
//        audioRecorder?.record()
    }
    
    func showAlertForAudioRecordingIsOn() {
        let alert = UIAlertController(title: Alert.Alert_BChat_title, message: Alert.Alert_Recording_On, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alert.Alert_BChat_Ok, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func playRecording() {
        let url = (audioRecorder?.url)!
        let owsAudioPlayer = OWSAudioPlayer(mediaUrl: url, audioBehavior: .audioMessagePlayback)
        owsAudioPlayer.isLooping = false
        if audioPlayer == nil {
            audioPlayer = owsAudioPlayer
        }
        if isAudioPlaying {
            audioPlayer!.pause()
        } else {
            audioPlayer!.play()
        }
        isAudioPlaying = !isAudioPlaying
    }

    func stopVoiceMessageRecording() {
        audioRecorder?.stop()
        audioSession.endAudioActivity(recordVoiceMessageActivity)
        deleteAudioView.isHidden = true
    }
    
    @objc func deleteAudioButtonTapped() {
        isAudioRecording = false
        deleteAudioView.isHidden = true
        cancelVoiceMessageRecording()
        NotificationCenter.default.post(name: .showPayAsYouChatNotification, object: nil)
    }
    
    // MARK: - Data Extraction Notifications
    @objc func sendScreenshotNotificationIfNeeded() {
        /*
        guard thread is TSContactThread else { return }
        let message = DataExtractionNotification()
        message.kind = .screenshot
        Storage.write { transaction in
            MessageSender.send(message, in: self.thread, using: transaction)
        }
         */
    }
    
    func sendMediaSavedNotificationIfNeeded(for viewItem: ConversationViewItem) {
        guard thread is TSContactThread, viewItem.interaction.interactionType() == .incomingMessage else { return }
        let message = DataExtractionNotification()
        message.kind = .mediaSaved(timestamp: viewItem.interaction.timestamp)
        Storage.write { transaction in
            MessageSender.send(message, in: self.thread, using: transaction)
        }
    }

    // MARK: - Convenience
    func showErrorAlert(for attachment: SignalAttachment, onDismiss: (() -> ())?) {
        let title = NSLocalizedString("ATTACHMENT_ERROR_ALERT_TITLE", comment: "")
        let message = attachment.localizedErrorDescription ?? SignalAttachment.missingDataErrorMessage
        
        OWSAlerts.showAlert(title: title, message: message, buttonTitle: nil) { _ in
            onDismiss?()
        }
    }
}

// MARK: - UIDocumentInteractionControllerDelegate

extension ConversationVC: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

// MARK: - Message Request Actions

extension ConversationVC {
    
    fileprivate func approveMessageRequestIfNeeded(for thread: TSThread?, isNewThread: Bool, timestamp: UInt64) -> Promise<Void> {
        guard let contactThread: TSContactThread = thread as? TSContactThread else { return Promise.value(()) }
        
        // If the contact doesn't exist then we should create it so we can store the 'isApproved' state
        // (it'll be updated with correct profile info if they accept the message request so this
        // shouldn't cause weird behaviours)
        let bchatId: String = contactThread.contactBChatID()
        let contact: Contact = (Storage.shared.getContact(with: bchatId) ?? Contact(bchatID: bchatId))
        
        guard !contact.isApproved else { return Promise.value(()) }
        
        return Promise.value(())
            .then { [weak self] _ -> Promise<Void> in
                guard !isNewThread else { return Promise.value(()) }
                guard let strongSelf = self else { return Promise(error: MessageSender.Error.noThread) }
                
                // If we aren't creating a new thread (ie. sending a message request) then send a
                // messageRequestResponse back to the sender (this allows the sender to know that
                // they have been approved and can now use this contact in closed groups)
                let (promise, seal) = Promise<Void>.pending()
                let messageRequestResponse: MessageRequestResponse = MessageRequestResponse(
                    isApproved: true
                )
                messageRequestResponse.sentTimestamp = timestamp
                
                // Show a loading indicator
                ModalActivityIndicatorViewController.present(fromViewController: strongSelf, canCancel: false) { _ in
                    seal.fulfill(())
                }
                
                return promise
                    .then { _ -> Promise<Void> in
                        let (promise, seal) = Promise<Void>.pending()
                        Storage.writeSync { transaction in
                            MessageSender.sendNonDurably(messageRequestResponse, in: contactThread, using: transaction)
                                .done { seal.fulfill(()) }
                                .catch { _ in seal.fulfill(()) } // Fulfill even if this failed; the configuration in the swarm should be at most 2 days old
                                .retainUntilComplete()
                        }
                        
                        return promise
                    }
                    .map { _ in
                        if self?.presentedViewController is ModalActivityIndicatorViewController {
                            self?.dismiss(animated: true, completion: nil) // Dismiss the loader
                        }
                    }
            }
            .map { _ in
                // Default 'didApproveMe' to true for the person approving the message request
                Storage.write { transaction in
                    contact.isApproved = true
                    contact.didApproveMe = (contact.didApproveMe || !isNewThread)
                    Storage.shared.setContact(contact, using: transaction)
                }
                
                // Send a sync message with the details of the contact
                MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                
                // Hide the 'messageRequestView' since the request has been approved and force a config
                // sync to propagate the contact approval state (both must run on the main thread)
                DispatchQueue.main.async { [weak self] in
                    let messageRequestViewWasVisible: Bool = (self?.messageRequestView.isHidden == false)
                    
                    UIView.animate(withDuration: 0.3) {
                        self?.messageRequestView.isHidden = true
                        self?.scrollButtonMessageRequestsBottomConstraint?.isActive = false
                        self?.scrollButtonBottomConstraint?.isActive = true
                        
                        // Update the table content inset and offset to account for the dissapearance of
                        // the messageRequestsView
                        if messageRequestViewWasVisible {
                            let messageRequestsOffset: CGFloat = ((self?.messageRequestView.bounds.height ?? 0) + 16)
                            let oldContentInset: UIEdgeInsets = (self?.messagesTableView.contentInset ?? UIEdgeInsets.zero)
                            self?.messagesTableView.contentInset = UIEdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: max(oldContentInset.bottom - messageRequestsOffset, 0),
                                trailing: 0
                            )
                        }
                    }
                    
                    // Update UI
                    self?.updateNavBarButtons()
                    if let viewControllers: [UIViewController] = self?.navigationController?.viewControllers,
                       let messageRequestsIndex = viewControllers.firstIndex(where: { $0 is MessageRequestsViewController }),
                       messageRequestsIndex > 0 {
                        var newViewControllers = viewControllers
                        newViewControllers.remove(at: messageRequestsIndex)
                        self?.navigationController?.setViewControllers(newViewControllers, animated: false)
                    }
                }
            }
    }

    @objc func acceptMessageRequest() {
        let alert = UIAlertController(title: "", message: "Are you sure you want to accept this request?", preferredStyle: .alert)
        let Cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
        })
        alert.addAction(Cancel)
        let Accept = UIAlertAction(title: "Accept", style: .default, handler: { action in
            
            let promise: Promise<Void> = self.approveMessageRequestIfNeeded (
                for: self.thread,
                isNewThread: false,
                timestamp: NSDate.millisecondTimestamp()
            )
            
            // Show an error indicating that approving the thread failed
            promise.catch(on: DispatchQueue.main) { [weak self] _ in
                let alert = UIAlertController(title: "BChat", message: NSLocalizedString("MESSAGE_REQUESTS_APPROVAL_ERROR_MESSAGE", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            promise.retainUntilComplete()
            
        })
        Cancel.setValue(UIColor.lightGray, forKey: "titleTextColor")
        Accept.setValue(Colors.bchatButtonColor, forKey: "titleTextColor")
        alert.addAction(Accept)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    @objc func deleteMessageRequest() {
        guard let uniqueId: String = thread.uniqueId else { return }
        let alert = UIAlertController(title: "", message: "Declining this request will permanently block this user, are you sure?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Cancel", style: .default, handler: { action in
        })
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "Decline", style: .default, handler: { action in
            // Delete the request
            Storage.write(
                with: { [weak self] transaction in
                    Storage.shared.cancelPendingMessageSendJobs(for: uniqueId, using: transaction)
                    
                    // Update the contact
                    if let contactThread: TSContactThread = self?.thread as? TSContactThread {
                        let bchatId: String = contactThread.contactBChatID()
                        
                        if let contact: Contact = Storage.shared.getContact(with: bchatId) {
                            // Stop observing the `BlockListDidChange` notification (we are about to pop the screen
                            // so showing the banner just looks buggy)
                            if let strongSelf = self {
                                NotificationCenter.default.removeObserver(strongSelf, name: .contactBlockedStateChanged, object: nil)
                            }
                            
                            contact.isApproved = false
                            contact.isBlocked = true
                            
                            // Note: We set this to true so the current user will be able to send a
                            // message to the person who originally sent them the message request in
                            // the future if they unblock them
                            contact.didApproveMe = true
                            
                            Storage.shared.setContact(contact, using: transaction)
                        }
                    }
                    
                    // Delete all thread content
                    self?.thread.removeAllThreadInteractions(with: transaction)
                },
                completion: { [weak self] in
                    // Force a config sync and pop to the previous screen
                    MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                    
                    // Remove the thread after the config message is sent.
                    // Otherwise the blocked user won't be included in the
                    // config message.
                    self?.thread.remove()
                    
                    DispatchQueue.main.async {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            )
        })
        ok.setValue(UIColor.lightGray, forKey: "titleTextColor")
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(cancel)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
}

struct CustomSlideView {
    static var isFromExpandAttachment = false
    static var isFromNormalAttachment = false
}

