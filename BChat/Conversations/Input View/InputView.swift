import UIKit
import BChatUIKit

final class InputView : UIView, InputViewButtonDelegate, InputTextViewDelegate, QuoteViewDelegate, LinkPreviewViewDelegate, MentionSelectionViewDelegate {
    enum MessageTypes {
        case all
        case textOnly
        case none
    }
    let thread: TSThread
    private weak var delegate: InputViewDelegate?
    var quoteDraftInfo: (model: OWSQuotedReplyModel, isOutgoing: Bool)? { didSet { handleQuoteDraftChanged() } }
    var linkPreviewInfo: (url: String, draft: OWSLinkPreviewDraft?)?
    private var voiceMessageRecordingView: VoiceMessageRecordingView?
    private lazy var mentionsViewHeightConstraint = mentionsView.set(.height, to: 0)

    private lazy var linkPreviewView: LinkPreviewView = {
        let maxWidth = self.additionalContentContainer.bounds.width - InputView.linkPreviewViewInset
        return LinkPreviewView(for: nil, maxWidth: maxWidth, delegate: self)
    }()

    var text: String {
        get { inputTextView.text }
        set { inputTextView.text = newValue }
    }
    
    var enabledMessageTypes: MessageTypes = .all {
        didSet {
            setEnabledMessageTypes(enabledMessageTypes, message: nil)
        }
    }
    
    override var intrinsicContentSize: CGSize { CGSize.zero }
    var lastSearchedText: String? { nil }
    
    // MARK: UI Components
    
    private var bottomStackView: UIStackView?
    private var finalBottomStack: UIStackView?
    private lazy var attachmentsButton = ExpandingAttachmentsButton(delegate: delegate)
    
    private lazy var voiceMessageButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "ic_audioNew"), delegate: self)
        result.accessibilityLabel = NSLocalizedString("VOICE_MESSAGE_TOO_SHORT_ALERT_TITLE", comment: "")
        result.accessibilityHint = NSLocalizedString("VOICE_MESSAGE_TOO_SHORT_ALERT_MESSAGE", comment: "")
        return result
    }()
    
    private lazy var payAsChatButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "beldeximg"), delegate: self, isPayButton: true)
        result.accessibilityLabel = NSLocalizedString("", comment: "")
        result.accessibilityHint = NSLocalizedString("", comment: "")
        // Create and add the circular progress view
        let progressView = CircularProgressView(frame: CGRect(x: 7.5, y: 7.5, width: InputViewButton.circularSize, height: InputViewButton.circularSize))
        result.addSubview(progressView)
        return result
    }()
    
    private lazy var payAsChatButtonFinal: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "beldeximg"), delegate: self, isPayButton: true)
        result.accessibilityLabel = NSLocalizedString("", comment: "")
        result.accessibilityHint = NSLocalizedString("", comment: "")
        // Create and add the circular progress view
        let progressView = CircularProgressView(frame: CGRect(x: 7.5, y: 7.5, width: InputViewButton.circularSize, height: InputViewButton.circularSize))
        result.addSubview(progressView)
        return result
    }()
    
    private var progressView: CircularProgressView? {
        return payAsChatButton.subviews.compactMap { $0 as? CircularProgressView }.first
    }
    
    private lazy var sendButton: InputViewButton = {
        let result = InputViewButton(icon: #imageLiteral(resourceName: "ic_sendMessage_new"), isSendButton: true, delegate: self)
        result.isHidden = true
        result.accessibilityLabel = NSLocalizedString("ATTACHMENT_APPROVAL_SEND_BUTTON", comment: "")
        return result
    }()
    private lazy var voiceMessageButtonContainer = container(for: voiceMessageButton)

    private lazy var mentionsView: MentionSelectionView = {
        let result = MentionSelectionView()
        result.delegate = self
        return result
    }()

    private lazy var mentionsViewContainer: UIView = {
        let result = UIView()
        let backgroundView = UIView()
        backgroundView.backgroundColor = isLightMode ? .white : .black
        backgroundView.alpha = Values.lowOpacity
        result.addSubview(backgroundView)
        backgroundView.pin(to: result)
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        result.addSubview(blurView)
        blurView.pin(to: result)
        result.alpha = 0
        return result
    }()
    
    private lazy var inputTextView: InputTextView = {
        // HACK: When restoring a draft the input text view won't have a frame yet, and therefore it won't
        // be able to calculate what size it should be to accommodate the draft text. As a workaround, we
        // just calculate the max width that the input text view is allowed to be and pass it in. See
        // setUpViewHierarchy() for why these values are the way they are.
        let adjustment = (InputViewButton.expandedSize - InputViewButton.size) / 2
        let maxWidth = UIScreen.main.bounds.width - 2 * InputViewButton.expandedSize - 2 * Values.smallSpacing - 2 * (Values.mediumSpacing - adjustment)
        return InputTextView(delegate: self, maxWidth: maxWidth)
    }()
    
    private lazy var disabledInputLabel: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        label.textColor = Colors.text.withAlphaComponent(Values.mediumOpacity)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    private lazy var additionalContentContainer = UIView()
    private lazy var additionalContentContainerOuterView = UIView()

    // MARK: Settings
    private static let linkPreviewViewInset: CGFloat = 6
    
    // MARK: Lifecycle
    init(delegate: InputViewDelegate,thread: TSThread) {
        self.delegate = delegate
        self.thread = thread
        super.init(frame: CGRect.zero)
//        sendButton.isHidden = false
        setUpViewHierarchy()
    }
    
    // MARK: Lifecycle
//    init(thread: TSThread, focusedMessageID: String? = nil) {
//        self.thread = thread
//    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(delegate:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(delegate:) instead.")
    }
    
    private func setUpViewHierarchy() {
        autoresizingMask = .flexibleHeight
        // Background & blur
        let backgroundView = UIView()
        backgroundView.backgroundColor = Colors.mainBackGroundColor2//isLightMode ? .white : .black
//        backgroundView.alpha = Values.lowOpacity
        addSubview(backgroundView)
        backgroundView.pin(to: self)
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        addSubview(blurView)
        blurView.pin(to: self)
        // Separator
        let separator = UIView()
        separator.backgroundColor = .clear//Colors.text.withAlphaComponent(0.2)
        separator.set(.height, to: 1 / UIScreen.main.scale)
        addSubview(separator)
        separator.pin([ UIView.HorizontalEdge.leading, UIView.VerticalEdge.top, UIView.HorizontalEdge.trailing ], to: self)
        // Bottom stack view
        let bottomStackView = UIStackView(arrangedSubviews: [ attachmentsButton, inputTextView, container(for: payAsChatButton)])
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = Values.smallSpacing
        bottomStackView.backgroundColor = Colors.incomingMessageColor//Colors.textViewColor
        bottomStackView.layer.cornerRadius = 24
        bottomStackView.alignment = .center
        self.bottomStackView = bottomStackView
        
        let bottomStackView2 = UIStackView(arrangedSubviews: [ bottomStackView, container(for: sendButton) ])
        bottomStackView2.axis = .horizontal
        bottomStackView2.spacing = 4
        bottomStackView2.backgroundColor = .clear//Colors.textViewColor
        bottomStackView2.layer.cornerRadius = 24
        bottomStackView2.alignment = .center
        self.finalBottomStack = bottomStackView2
        
        // Main stack view
        let mainStackView = UIStackView(arrangedSubviews: [ additionalContentContainer, bottomStackView2 ])
        mainStackView.axis = .vertical
        mainStackView.backgroundColor = Colors.mainBackGroundColor2//Colors.bchatViewBackgroundColor
        mainStackView.isLayoutMarginsRelativeArrangement = true
        let adjustment = (InputViewButton.expandedSize - InputViewButton.size) / 2
        mainStackView.layoutMargins = UIEdgeInsets(top: 2, leading: Values.mediumSpacing - adjustment, bottom: 2, trailing: Values.mediumSpacing - adjustment)
        addSubview(mainStackView)
        mainStackView.pin(.top, to: .bottom, of: separator)
        mainStackView.pin([ UIView.HorizontalEdge.leading, UIView.HorizontalEdge.trailing ], to: self)
        mainStackView.pin(.bottom, to: .bottom, of: self)
        
        addSubview(disabledInputLabel)
        
        disabledInputLabel.pin(.top, to: .top, of: mainStackView)
        disabledInputLabel.pin(.left, to: .left, of: mainStackView)
        disabledInputLabel.pin(.right, to: .right, of: mainStackView)
        disabledInputLabel.set(.height, to: InputViewButton.expandedSize)
        
        // Mentions
        insertSubview(mentionsViewContainer, belowSubview: mainStackView)
        mentionsViewContainer.pin([ UIView.HorizontalEdge.left, UIView.HorizontalEdge.right ], to: self)
        mentionsViewContainer.pin(.bottom, to: .top, of: self)
        mentionsViewContainer.addSubview(mentionsView)
        mentionsView.pin(to: mentionsViewContainer)
        mentionsViewHeightConstraint.isActive = true
        // Voice message button
        addSubview(voiceMessageButtonContainer)
        voiceMessageButtonContainer.center(in: sendButton)
        voiceMessageButtonContainer.backgroundColor = Colors.bothGreenColor
        voiceMessageButtonContainer.layer.cornerRadius = 24
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPayAsYouChatButton(_:)), name: Notification.Name(rawValue: "showPayAsYouChatButton"), object: nil)
        self.hideOrShowPayAsYouChatButton()
    }
    
    
    func hideOrShowPayAsYouChatButton() {
        if SSKPreferences.areWalletEnabled {
            if let contactThread: TSContactThread = thread as? TSContactThread {
                if let contact: Contact = Storage.shared.getContact(with: contactThread.contactBChatID()), contact.isApproved, contact.didApproveMe, !thread.isNoteToSelf(), !thread.isMessageRequest(), !contact.isBlocked {
                    if contact.beldexAddress != nil {
                        print("isApproved message BeldexAddress-> ",contact.beldexAddress!)
                        if SSKPreferences.arePayAsYouChatEnabled {
                            payAsChatButton.isHidden = false
                            progressView?.isHidden = false
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                                let (current, total) = (WalletSharedData.sharedInstance.wallet?.blockChainHeight, WalletSharedData.sharedInstance.wallet?.daemonBlockChainHeight)
                                guard let current = current, let total = total else { return }
                                // Calculate the percentage completion
                                let percentage = CGFloat(current * 100) / CGFloat(total)
                                // Set the progress bar
                                let progress = (percentage / 100)
                                let progress8 = progress * 0.8
                                self.progressView?.setProgress(min(progress8, 1.0))
                                if progress >= 1.0 {
                                    timer.invalidate()
                                    self.progressView?.isHidden = false
                                }
                            }
                        } else {
                            payAsChatButton.isHidden = false
                            progressView?.isHidden = true
                        }
                    } else {
                        payAsChatButton.isHidden = true
                        progressView?.isHidden = true
                    }
                } else{
                    payAsChatButton.isHidden = true
                    progressView?.isHidden = true
                }
            } else {
                payAsChatButton.isHidden = true
                progressView?.isHidden = true
            }
        } else {
            payAsChatButton.isHidden = true
            progressView?.isHidden = true
        }
    }
    
    
    
    @objc func showPayAsYouChatButton(_ notification: Notification) {
        self.hideOrShowPayAsYouChatButton()
    }

    
    // MARK: Updating
    func inputTextViewDidChangeSize(_ inputTextView: InputTextView) {
        invalidateIntrinsicContentSize()
    }

    func inputTextViewDidChangeContent(_ inputTextView: InputTextView) {
        let hasText = !text.isEmpty
//        sendButton.isHidden = false
//        voiceMessageButtonContainer.isHidden = false
        sendButton.isHidden = !hasText
        voiceMessageButtonContainer.isHidden = hasText
        autoGenerateLinkPreviewIfPossible()
        delegate?.inputTextViewDidChangeContent(inputTextView)
    }
    
    func didPasteImageFromPasteboard(_ inputTextView: InputTextView, image: UIImage) {
        delegate?.didPasteImageFromPasteboard(image)
    }

    // We want to show either a link preview or a quote draft, but never both at the same time. When trying to
    // generate a link preview, wait until we're sure that we'll be able to build a link preview from the given
    // URL before removing the quote draft.
    
    private func handleQuoteDraftChanged() {
//        additionalContentContainer.subviews.forEach { $0.removeFromSuperview() }
//        linkPreviewInfo = nil
//        guard let quoteDraftInfo = quoteDraftInfo else { return }
//        let direction: QuoteView.Direction = quoteDraftInfo.isOutgoing ? .outgoing : .incoming
//        let hInset: CGFloat = 4 // Slight visual adjustment
//        let maxWidth = additionalContentContainer.bounds.width
//        let quoteView = QuoteView(for: quoteDraftInfo.model, direction: direction, hInset: hInset, maxWidth: maxWidth, delegate: self)
//        additionalContentContainer.addSubview(quoteView)
//        quoteView.layer.cornerRadius = 16
//        quoteView.backgroundColor = Colors.incomingMessageColor
//        
//        quoteView.pin(.left, to: .left, of: additionalContentContainer, withInset: hInset)
//        quoteView.pin(.top, to: .top, of: additionalContentContainer, withInset: 12)
//        quoteView.pin(.right, to: .right, of: additionalContentContainer, withInset: -54)
//        quoteView.pin(.bottom, to: .bottom, of: additionalContentContainer, withInset: -1)
        
        
        additionalContentContainer.subviews.forEach { $0.removeFromSuperview() }
        linkPreviewInfo = nil
        guard let quoteDraftInfo = quoteDraftInfo else { return }
        let direction: QuoteView.Direction = quoteDraftInfo.isOutgoing ? .outgoing : .incoming
        let hInset: CGFloat = 4 // Slight visual adjustment
        let maxWidth = additionalContentContainer.bounds.width
        let quoteView = QuoteView(for: quoteDraftInfo.model, direction: direction, hInset: hInset, maxWidth: maxWidth, delegate: self)
        additionalContentContainerOuterView.addSubview(quoteView)
        additionalContentContainer.addSubview(additionalContentContainerOuterView)
        quoteView.backgroundColor = Colors.mainBackGroundColor2
        quoteView.layer.cornerRadius = 16
        
        additionalContentContainerOuterView.backgroundColor = Colors.incomingMessageColor
        additionalContentContainerOuterView.layer.cornerRadius = 16
        additionalContentContainerOuterView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        quoteView.pin(.left, to: .left, of: additionalContentContainerOuterView, withInset: 10)
        quoteView.pin(.top, to: .top, of: additionalContentContainerOuterView, withInset: 12)
        quoteView.pin(.right, to: .right, of: additionalContentContainerOuterView, withInset: -10)
        quoteView.pin(.bottom, to: .bottom, of: additionalContentContainerOuterView, withInset: -20)
        
        additionalContentContainerOuterView.pin(.left, to: .left, of: additionalContentContainer, withInset: 0)
        additionalContentContainerOuterView.pin(.top, to: .top, of: additionalContentContainer, withInset: 12)
        additionalContentContainerOuterView.pin(.right, to: .right, of: additionalContentContainer, withInset: -51)
        additionalContentContainerOuterView.pin(.bottom, to: .bottom, of: additionalContentContainer, withInset: 20)
    }

    private func autoGenerateLinkPreviewIfPossible() {
        // Don't allow link previews on 'none' or 'textOnly' input
        guard enabledMessageTypes == .all else { return }
            
        // Suggest that the user enable link previews if they haven't already and we haven't
        // told them about link previews yet
        let text = inputTextView.text!
        let userDefaults = UserDefaults.standard
        if !OWSLinkPreview.allPreviewUrls(forMessageBodyText: text).isEmpty && !SSKPreferences.areLinkPreviewsEnabled
            && !userDefaults[.hasSeenLinkPreviewSuggestion] {
            delegate?.showLinkPreviewSuggestionModal()
            userDefaults[.hasSeenLinkPreviewSuggestion] = true
            return
        }
        // Check that link previews are enabled
        guard SSKPreferences.areLinkPreviewsEnabled else { return }
        // Proceed
        autoGenerateLinkPreview()
    }

    func autoGenerateLinkPreview() {
        // Check that a valid URL is present
        guard let linkPreviewURL = OWSLinkPreview.previewUrl(forRawBodyText: text, selectedRange: inputTextView.selectedRange) else {
            return
        }
        // Guard against obsolete updates
        guard linkPreviewURL != self.linkPreviewInfo?.url else { return }
        // Clear content container
        additionalContentContainer.subviews.forEach { $0.removeFromSuperview() }
        quoteDraftInfo = nil
        // Set the state to loading
        linkPreviewInfo = (url: linkPreviewURL, draft: nil)
        linkPreviewView.linkPreviewState = LinkPreviewLoading()
        // Add the link preview view
        additionalContentContainer.addSubview(linkPreviewView)
        linkPreviewView.pin(.left, to: .left, of: additionalContentContainer, withInset: InputView.linkPreviewViewInset)
        linkPreviewView.pin(.top, to: .top, of: additionalContentContainer, withInset: 10)
        linkPreviewView.pin(.right, to: .right, of: additionalContentContainer)
        linkPreviewView.pin(.bottom, to: .bottom, of: additionalContentContainer, withInset: -4)
        // Build the link preview
        OWSLinkPreview.tryToBuildPreviewInfo(previewUrl: linkPreviewURL).done { [weak self] draft in
            guard let self = self else { return }
            guard self.linkPreviewInfo?.url == linkPreviewURL else { return } // Obsolete
            self.linkPreviewInfo = (url: linkPreviewURL, draft: draft)
            self.linkPreviewView.linkPreviewState = LinkPreviewDraft(linkPreviewDraft: draft)
        }.catch { _ in
            guard self.linkPreviewInfo?.url == linkPreviewURL else { return } // Obsolete
            self.linkPreviewInfo = nil
            self.additionalContentContainer.subviews.forEach { $0.removeFromSuperview() }
        }.retainUntilComplete()
    }
    
    func setEnabledMessageTypes(_ messageTypes: MessageTypes, message: String?) {
        guard enabledMessageTypes != messageTypes else { return }
        
        enabledMessageTypes = messageTypes
        disabledInputLabel.text = (message ?? "")
        
        attachmentsButton.isUserInteractionEnabled = (messageTypes == .all)
        voiceMessageButton.isUserInteractionEnabled = (messageTypes == .all)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.bottomStackView?.alpha = (messageTypes != .none ? 1 : 0)
            self?.attachmentsButton.alpha = (messageTypes == .all ?
                1 :
                (messageTypes == .textOnly ? 0.4 : 0)
            )
            self?.voiceMessageButton.alpha = (messageTypes == .all ?
                1 :
                (messageTypes == .textOnly ? 0.4 : 0)
            )
            self?.disabledInputLabel.alpha = (messageTypes != .none ? 0 : 1)
        }
    }
    
    // MARK: Interaction
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Needed so that the user can tap the buttons when the expanding attachments button is expanded
        let buttonContainers = [ attachmentsButton.mainButton, attachmentsButton.cameraButton,
            attachmentsButton.libraryButton, attachmentsButton.documentButton ]
        let buttonContainer = buttonContainers.first { $0.superview!.convert($0.frame, to: self).contains(point) }
        if let buttonContainer = buttonContainer {
            return buttonContainer
        } else {
            return super.hitTest(point, with: event)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let buttonContainers = [ attachmentsButton.documentButtonContainer,
            attachmentsButton.libraryButtonContainer, attachmentsButton.cameraButtonContainer, attachmentsButton.mainButtonContainer ]
        let isPointInsideAttachmentsButton = buttonContainers.contains { $0.superview!.convert($0.frame, to: self).contains(point) }
        if isPointInsideAttachmentsButton {
            // Needed so that the user can tap the buttons when the expanding attachments button is expanded
            return true
        } else if mentionsViewContainer.frame.contains(point) {
            // Needed so that the user can tap mentions
            return true
        } else {
            return super.point(inside: point, with: event)
        }
    }
    
    func handleInputViewButtonTapped(_ inputViewButton: InputViewButton) {
        if inputViewButton == sendButton {
            delegate?.handleSendButtonTapped()
        }else if inputViewButton == payAsChatButton {
            delegate?.handlePaySendButtonTapped()
        }
    }

    func handleInputViewButtonLongPressBegan(_ inputViewButton: InputViewButton) {
        if inputViewButton == payAsChatButton {
            delegate?.payAsYouChatLongPress()
        }
        guard inputViewButton == voiceMessageButton else { return }
        delegate?.startVoiceMessageRecording()
        showVoiceMessageUI()
    }

    func handleInputViewButtonLongPressMoved(_ inputViewButton: InputViewButton, with touch: UITouch) {
        guard let voiceMessageRecordingView = voiceMessageRecordingView, inputViewButton == voiceMessageButton else { return }
        let location = touch.location(in: voiceMessageRecordingView)
        voiceMessageRecordingView.handleLongPressMoved(to: location)
    }

    func handleInputViewButtonLongPressEnded(_ inputViewButton: InputViewButton, with touch: UITouch) {
        guard let voiceMessageRecordingView = voiceMessageRecordingView, inputViewButton == voiceMessageButton else { return }
        let location = touch.location(in: voiceMessageRecordingView)
        voiceMessageRecordingView.handleLongPressEnded(at: location)
    }

    func handleQuoteViewCancelButtonTapped() {
        delegate?.handleQuoteViewCancelButtonTapped()
    }

    override func resignFirstResponder() -> Bool {
        inputTextView.resignFirstResponder()
    }

    func handleLongPress() {
        // Not relevant in this case
    }

    func handleLinkPreviewCanceled() {
        linkPreviewInfo = nil
        additionalContentContainer.subviews.forEach { $0.removeFromSuperview() }
    }

    @objc private func showVoiceMessageUI() {
        voiceMessageRecordingView?.removeFromSuperview()
        let voiceMessageButtonFrame = voiceMessageButton.superview!.convert(voiceMessageButton.frame, to: self)
        let voiceMessageRecordingView = VoiceMessageRecordingView(voiceMessageButtonFrame: voiceMessageButtonFrame, delegate: delegate)
        voiceMessageRecordingView.alpha = 0
        addSubview(voiceMessageRecordingView)
        voiceMessageRecordingView.pin(to: self)
        self.voiceMessageRecordingView = voiceMessageRecordingView
        voiceMessageRecordingView.animate()
        let allOtherViews = [ attachmentsButton, sendButton, inputTextView, additionalContentContainer ]
        UIView.animate(withDuration: 0.25) {
            allOtherViews.forEach { $0.alpha = 0 }
        }
    }

    func hideVoiceMessageUI() {
        let allOtherViews = [ attachmentsButton, sendButton, inputTextView, additionalContentContainer ]
        UIView.animate(withDuration: 0.25, animations: {
            allOtherViews.forEach { $0.alpha = 1 }
            self.voiceMessageRecordingView?.alpha = 0
        }, completion: { _ in
            self.voiceMessageRecordingView?.removeFromSuperview()
            self.voiceMessageRecordingView = nil
        })
    }

    func hideMentionsUI() {
        UIView.animate(withDuration: 0.25, animations: {
            self.mentionsViewContainer.alpha = 0
        }, completion: { _ in
            self.mentionsViewHeightConstraint.constant = 0
            self.mentionsView.tableView.contentOffset = CGPoint.zero
        })
    }

    func showMentionsUI(for candidates: [Mention], in thread: TSThread) {
        if let openGroupV2 = Storage.shared.getV2OpenGroup(for: thread.uniqueId!) {
            mentionsView.openGroupServer = openGroupV2.server
            mentionsView.openGroupRoom = openGroupV2.room
        }
        mentionsView.candidates = candidates
        let mentionCellHeight = Values.smallProfilePictureSize + 2 * Values.smallSpacing
        mentionsViewHeightConstraint.constant = CGFloat(min(3, candidates.count)) * mentionCellHeight
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            self.mentionsViewContainer.alpha = 1
        }
    }

    func handleMentionSelected(_ mention: Mention, from view: MentionSelectionView) {
        delegate?.handleMentionSelected(mention, from: view)
    }

    // MARK: Convenience
    private func container(for button: InputViewButton) -> UIView {
        let result = UIView()
        result.addSubview(button)
        result.set(.width, to: InputViewButton.expandedSize)
        result.set(.height, to: InputViewButton.expandedSize)
        button.center(in: result)
        return result
    }
}

// MARK: Delegate
protocol InputViewDelegate : AnyObject, ExpandingAttachmentsButtonDelegate, VoiceMessageRecordingViewDelegate {

    func showLinkPreviewSuggestionModal()
    func handleSendButtonTapped()
    func handlePaySendButtonTapped()
    func handleQuoteViewCancelButtonTapped()
    func inputTextViewDidChangeContent(_ inputTextView: InputTextView)
    func handleMentionSelected(_ mention: Mention, from view: MentionSelectionView)
    func didPasteImageFromPasteboard(_ image: UIImage)
}
extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        // Regular expression pattern for the specified format
        let pattern = "^[0-9]{0,9}(\\.[0-9]{0,5})?$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: self)
    }
}


class CircularProgressView: UIView {
    private var progressLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let circularPath = UIBezierPath(arcCenter: center, radius: bounds.width / 2, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        // Background layer
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = Colors.bchatPlaceholderColor.cgColor
        backgroundLayer.lineWidth = 2.2
        backgroundLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(backgroundLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = Colors.accent.cgColor
        progressLayer.lineWidth = 2.2
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }

    func setProgress(_ progress: CGFloat) {
        progressLayer.strokeEnd = progress
    }
}
