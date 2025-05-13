import PromiseKit
import WebRTC
import BChatUIKit
import UIKit
import BChatMessagingKit

extension AppDelegate {

    // MARK: Call handling
    @objc func hasIncomingCallWaiting() -> Bool {
        guard let call = AppEnvironment.shared.callManager.currentCall else { return false }
        return !call.hasStartedConnecting
    }
    
    @objc func handleAppActivatedWithOngoingCallIfNeeded() {
        guard let call = AppEnvironment.shared.callManager.currentCall else { return }
        guard MiniCallView.current == nil else { return }
        if let callVC = CurrentAppContext().frontmostViewController() as? NewIncomingCallVC, callVC.bChatCall == call { return }
        guard let presentingVC = CurrentAppContext().frontmostViewController() else { preconditionFailure() } // FIXME: Handle more gracefully
        let callVC = NewIncomingCallVC(for: call)
        if let conversationVC = presentingVC as? ConversationVC, let contactThread = conversationVC.thread as? TSContactThread, contactThread.contactBChatID() == call.bchatID {
            callVC.conversationVC = conversationVC
            conversationVC.inputAccessoryView?.isHidden = true
            conversationVC.inputAccessoryView?.alpha = 0
        }
        presentingVC.present(callVC, animated: true, completion: nil)
    }
    
    private func dismissAllCallUI() {
        if let currentBanner = IncomingCallBanner.current { currentBanner.dismiss() }
        if let callVC = CurrentAppContext().frontmostViewController() as? NewIncomingCallVC { callVC.handleEndCallMessage() }
        if let miniCallView = MiniCallView.current { miniCallView.dismiss() }
    }
    
    private func showCallUIForCall(_ call: BChatCall) {
        DispatchQueue.main.async {
            call.reportIncomingCallIfNeeded{ error in
                if let error = error {
                    SNLog("[Calls] Failed to report incoming call to CallKit due to error: \(error)")
                } else {
                    if CurrentAppContext().isMainAppAndActive {
                        guard let presentingVC = CurrentAppContext().frontmostViewController() else { preconditionFailure() } // FIXME: Handle more gracefully
                        if let conversationVC = presentingVC as? ConversationVC, let contactThread = conversationVC.thread as? TSContactThread, contactThread.contactBChatID() == call.bchatID {
                            let callVC = NewIncomingCallVC(for: call)
                            callVC.conversationVC = conversationVC
                            conversationVC.inputAccessoryView?.isHidden = true
                            conversationVC.inputAccessoryView?.alpha = 0
                            presentingVC.present(callVC, animated: true, completion: nil)
                        } else if !SSKPreferences.isCallKitSupported {
                            let incomingCallBanner = IncomingCallBanner(for: call)
                            incomingCallBanner.show()
                        }
                    }
                }
            }
        }
    }
    
    private func insertCallInfoMessage(for message: CallMessage, using transaction: YapDatabaseReadWriteTransaction) -> TSInfoMessage? {
        guard let sender = message.sender, let uuid = message.uuid else { return nil }
        var receivedCalls = Storage.shared.getReceivedCalls(for: sender, using: transaction)
        guard !receivedCalls.contains(uuid) else { return nil }
        let thread = TSContactThread.getOrCreateThread(withContactBChatID: message.sender!, transaction: transaction)
        if thread.isArchived {
            thread.isArchived = false
        }
        let infoMessage = TSInfoMessage.from(message, associatedWith: thread)
        infoMessage.save(with: transaction)
        receivedCalls.insert(uuid)
        Storage.shared.setReceivedCalls(to: receivedCalls, for: sender, using: transaction)
        return infoMessage
    }
    
    private func showMissedCallTipsIfNeeded(caller: String) {
        let userDefaults = UserDefaults.standard
        guard !userDefaults[.hasSeenCallMissedTips] else { return }
        guard let presentingVC = CurrentAppContext().frontmostViewController() else { preconditionFailure() }
//        let callMissedTipsModal = CallMissedTipsModal(caller: caller)
//        presentingVC.present(callMissedTipsModal, animated: true, completion: nil)
        let vc = MissedCallPopUp(caller: caller)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        presentingVC.present(vc, animated: true, completion: nil)
        userDefaults[.hasSeenCallMissedTips] = true
    }
    
    @objc func setUpCallHandling() {
        // Pre offer messages
        MessageReceiver.handleNewCallOfferMessageIfNeeded = { (message, transaction) in
            guard CurrentAppContext().isMainApp else { return }
            guard let timestamp = message.sentTimestamp, TimestampUtils.isWithinOneMinute(timestamp: timestamp) else {
                // Add missed call message for call offer messages from more than one minute
                if let infoMessage = self.insertCallInfoMessage(for: message, using: transaction) {
                    infoMessage.updateCallInfoMessage(.missed, using: transaction)
                    let thread = TSContactThread.getOrCreateThread(withContactBChatID: message.sender!, transaction: transaction)
                    SSKEnvironment.shared.notificationsManager?.notifyUser(forIncomingCall: infoMessage, in: thread, transaction: transaction)
                }
                return
            }
            guard SSKPreferences.areCallsEnabled else {
                if let infoMessage = self.insertCallInfoMessage(for: message, using: transaction) {
                    infoMessage.updateCallInfoMessage(.permissionDenied, using: transaction)
                    let thread = TSContactThread.getOrCreateThread(withContactBChatID: message.sender!, transaction: transaction)
                    SSKEnvironment.shared.notificationsManager?.notifyUser(forIncomingCall: infoMessage, in: thread, transaction: transaction)
                    let contactName = Storage.shared.getContact(with: message.sender!, using: transaction)?.displayName(for: Contact.Context.regular) ?? message.sender!
                    DispatchQueue.main.async {
                        self.showMissedCallTipsIfNeeded(caller: contactName)
                    }
                }
                return
            }
            let callManager = AppEnvironment.shared.callManager
            // Ignore pre offer message after the same call instance has been generated
            if let currentCall = callManager.currentCall, currentCall.uuid == message.uuid! { return }
            guard callManager.currentCall == nil else {
                callManager.handleIncomingCallOfferInBusyState(offerMessage: message, using: transaction)
                return
            }
            let infoMessage = self.insertCallInfoMessage(for: message, using: transaction)
            // Handle UI
            if let caller = message.sender, let uuid = message.uuid {
                let call = BChatCall(for: caller, uuid: uuid, mode: .answer)
                call.callMessageID = infoMessage?.uniqueId
                self.showCallUIForCall(call)
            }
        }
        // Offer messages
        MessageReceiver.handleOfferCallMessage = { message in
            DispatchQueue.main.async {
                guard let call = AppEnvironment.shared.callManager.currentCall, message.uuid! == call.uuid else { return }
                let sdp = RTCSessionDescription(type: .offer, sdp: message.sdps![0])
                call.didReceiveRemoteSDP(sdp: sdp)
            }
        }
        // Answer messages
        MessageReceiver.handleAnswerCallMessage = { message in
            DispatchQueue.main.async {
                guard let call = AppEnvironment.shared.callManager.currentCall, message.uuid! == call.uuid else { return }
                if message.sender! == getUserHexEncodedPublicKey() {
                    guard !call.hasStartedConnecting else { return }
                    self.dismissAllCallUI()
                    AppEnvironment.shared.callManager.reportCurrentCallEnded(reason: .answeredElsewhere)
                } else {
                    call.hasStartedConnecting = true
                    let sdp = RTCSessionDescription(type: .answer, sdp: message.sdps![0])
                    call.didReceiveRemoteSDP(sdp: sdp)
                    guard let callVC = CurrentAppContext().frontmostViewController() as? NewIncomingCallVC else { return }
                    callVC.handleAnswerMessage(message)
                }
            }
        }
        // End call messages
        MessageReceiver.handleEndCallMessage = { message in
            DispatchQueue.main.async {
                guard let call = AppEnvironment.shared.callManager.currentCall, message.uuid! == call.uuid else { return }
                self.dismissAllCallUI()
                if message.sender! == getUserHexEncodedPublicKey() {
                    AppEnvironment.shared.callManager.reportCurrentCallEnded(reason: .declinedElsewhere)
                } else {
                    AppEnvironment.shared.callManager.reportCurrentCallEnded(reason: .remoteEnded)
                }
            }
        }
    }
    
    // MARK: Configuration message
    @objc(syncConfigurationIfNeeded)
    func syncConfigurationIfNeeded() {
        guard Storage.shared.getUser()?.name != nil else { return }
        let userDefaults = UserDefaults.standard
        let lastSync = userDefaults[.lastConfigurationSync] ?? .distantPast
        guard Date().timeIntervalSince(lastSync) > 7 * 24 * 60 * 60 else { return } // Sync every 2 days
        MessageSender.syncConfiguration(forceSyncNow: false)
            .done {
                // Only update the 'lastConfigurationSync' timestamp if we have done the first sync (Don't want
                // a new device config sync to override config syncs from other devices)
                if userDefaults[.hasSyncedInitialConfiguration] {
                    userDefaults[.lastConfigurationSync] = Date()
                }
            }
            .retainUntilComplete()
    }

    // MARK: Closed group poller
    @objc func startClosedGroupPoller() {
        guard OWSIdentityManager.shared().identityKeyPair() != nil else { return }
        ClosedGroupPoller.shared.start()
    }

    @objc func stopClosedGroupPoller() {
        ClosedGroupPoller.shared.stop()
    }

    @objc
    func verifyBnsName() {
        guard NetworkReachabilityStatus.isConnectedToNetworkSignal() else { return }
        guard let bnsName = UserDefaults.standard.string(forKey: Constants.bnsUserName) else { return }
        SnodeAPI.getBChatID(for: bnsName.lowercased()).done { bChatID in
            self.updateBnsUserContact(getUserHexEncodedPublicKey() == bChatID, bChatID: bChatID)
        }.catch { error in
            self.verifyBnsName()
        }
    }
    
    func updateBnsUserContact(_ isBnsUser: Bool, bChatID: String = "") {
        UserDefaults.standard.set(isBnsUser, forKey: Constants.isBnsVerifiedUser)
        NotificationCenter.default.post(name: Notification.Name(kNSNotificationName_LocalProfileDidChange), object: nil)
        Storage.read { transaction in
            TSContactThread.enumerateCollectionObjects(with: transaction) { object, _  in
                guard let contact = Storage.shared.getContact(with: bChatID) else { return }
                Storage.write { transaction in
                    contact.isBnsHolder = isBnsUser
                    Storage.shared.setContact(contact, using: transaction)
                }
            }
        }
    }
}
