import Foundation
import WebRTC
import BChatMessagingKit
import PromiseKit
import CallKit

enum FloatingViewVideoSource {
    case local
    case remote
}

public final class BChatCall: NSObject, WebRTCBChatDelegate {
    
    @objc static let isEnabled = true
    
    // MARK: Metadata Properties
    let uuid: String
    let callID: UUID // This is for CallKit
    let bchatID: String
    let mode: Mode
    var audioMode: AudioMode
    let webRTCBChat: WebRTCBChat
    let isOutgoing: Bool
    var remoteSDP: RTCSessionDescription? = nil
    var callMessageID: String?
    var answerCallAction: CXAnswerCallAction? = nil
    var contactName: String {
        let contact = Storage.shared.getContact(with: self.bchatID)
        return contact?.displayName(for: Contact.Context.regular) ?? "\(self.bchatID.prefix(4))...\(self.bchatID.suffix(4))"
    }
    var profilePicture: UIImage {
        if let result = OWSProfileManager.shared().profileAvatar(forRecipientId: bchatID) {
            return result
        } else {
            return Identicon.generatePlaceholderIcon(seed: bchatID, text: contactName, size: 300)
        }
    }
    
    // MARK: Control
    lazy public var videoCapturer: RTCVideoCapturer = {
        return RTCCameraVideoCapturer(delegate: webRTCBChat.localVideoSource)
    }()
    
    var isRemoteVideoEnabled = false {
        didSet {
            remoteVideoStateDidChange?(isRemoteVideoEnabled)
        }
    }
    
    var isRemoteAudioMuted = false {
        didSet {
            remoteAudioMuted?(isRemoteAudioMuted)
        }
    }
    
    var isMuted = false {
        willSet {
            if newValue {
                webRTCBChat.mute()
            } else {
                webRTCBChat.unmute()
            }
        }
    }
    var isVideoEnabled = false {
        willSet {
            if newValue {
                webRTCBChat.turnOnVideo()
            } else {
                webRTCBChat.turnOffVideo()
            }
        }
    }
    
    // MARK: Mode
    enum Mode {
        case offer
        case answer
    }
    
    // MARK: End call mode
    enum EndCallMode {
        case local
        case remote
        case unanswered
        case answeredElsewhere
    }
    
    // MARK: Audio I/O mode
    enum AudioMode {
        case earpiece
        case speaker
        case headphone
        case bluetooth
    }
    
    // MARK: Call State Properties
    var connectingDate: Date? {
        didSet {
            stateDidChange?()
            hasStartedConnectingDidChange?()
        }
    }

    var connectedDate: Date? {
        didSet {
            stateDidChange?()
            hasConnectedDidChange?()
        }
    }

    var endDate: Date? {
        didSet {
            stateDidChange?()
            hasEndedDidChange?()
        }
    }

    // Not yet implemented
    var isOnHold = false {
        didSet {
            stateDidChange?()
        }
    }

    // MARK: State Change Callbacks
    var stateDidChange: (() -> Void)?
    var hasStartedConnectingDidChange: (() -> Void)?
    var hasConnectedDidChange: (() -> Void)?
    var hasEndedDidChange: (() -> Void)?
    var remoteVideoStateDidChange: ((Bool) -> Void)?
    var hasStartedReconnecting: (() -> Void)?
    var hasReconnected: (() -> Void)?
    var remoteAudioMuted: ((Bool) -> Void)?
    
    // MARK: Derived Properties
    var hasStartedConnecting: Bool {
        get { return connectingDate != nil }
        set { connectingDate = newValue ? Date() : nil }
    }

    var hasConnected: Bool {
        get { return connectedDate != nil }
        set { connectedDate = newValue ? Date() : nil }
    }

    var hasEnded: Bool {
        get { return endDate != nil }
        set { endDate = newValue ? Date() : nil }
    }
    
    var timeOutTimer: Timer? = nil
    var didTimeout = false

    var duration: TimeInterval {
        guard let connectedDate = connectedDate else {
            return 0
        }
        if let endDate = endDate {
            return endDate.timeIntervalSince(connectedDate)
        }

        return Date().timeIntervalSince(connectedDate)
    }
    
    var reconnectTimer: Timer? = nil
    var isVideoSwapped = false
    
    var floatingViewVideoSource: FloatingViewVideoSource = .local
    
    // MARK: Initialization
    init(for bchatID: String, uuid: String, mode: Mode, outgoing: Bool = false) {
        self.bchatID = bchatID
        self.uuid = uuid
        self.callID = UUID()
        self.mode = mode
        self.audioMode = .earpiece
        self.webRTCBChat = WebRTCBChat.current ?? WebRTCBChat(for: bchatID, with: uuid)
        self.isOutgoing = outgoing
        WebRTCBChat.current = self.webRTCBChat
        super.init()
        self.webRTCBChat.delegate = self
        if AppEnvironment.shared.callManager.currentCall == nil {
            AppEnvironment.shared.callManager.currentCall = self
        } else {
            SNLog("[Calls] A call is ongoing.")
        }
    }
    
    func reportIncomingCallIfNeeded(completion: @escaping (Error?) -> Void) {
        guard case .answer = mode else { return }
        setupTimeoutTimer()
        AppEnvironment.shared.callManager.reportIncomingCall(self, callerName: contactName) { error in
            completion(error)
        }
    }
    
    func didReceiveRemoteSDP(sdp: RTCSessionDescription) {
        SNLog("[Calls] Did receive remote sdp.")
        remoteSDP = sdp
        if hasStartedConnecting {
            webRTCBChat.handleRemoteSDP(sdp, from: bchatID) // This sends an answer message internally
        }
    }
    
    // MARK: Actions
    func startBChatCall() {
        guard case .offer = mode else { return }
        guard let thread = TSContactThread.fetch(uniqueId: TSContactThread.threadID(fromContactBChatID: bchatID)) else { return }
        
        let message = CallMessage()
        message.sender = getUserHexEncodedPublicKey()
        message.sentTimestamp = NSDate.millisecondTimestamp()
        message.uuid = self.uuid
        message.kind = .preOffer
        let infoMessage = TSInfoMessage.from(message, associatedWith: thread)
        infoMessage.save()
        self.callMessageID = infoMessage.uniqueId
        
        var promise: Promise<Void>!
        Storage.write(with: { transaction in
            promise = self.webRTCBChat.sendPreOffer(message, in: thread, using: transaction)
        }, completion: { [weak self] in
            let _ = promise.done {
                Storage.shared.write { transaction in
                    self?.webRTCBChat.sendOffer(to: self!.bchatID, using: transaction as! YapDatabaseReadWriteTransaction).retainUntilComplete()
                }
                self?.setupTimeoutTimer()
            }
        })
    }
    
    func answerBChatCall() {
        guard case .answer = mode else { return }
        hasStartedConnecting = true
        if let sdp = remoteSDP {
            webRTCBChat.handleRemoteSDP(sdp, from: bchatID) // This sends an answer message internally
        }
    }
    
    func answerBChatCallInBackground(action: CXAnswerCallAction) {
        answerCallAction = action
        self.answerBChatCall()
    }
    
    @objc
    func endBChatCall() {
        guard !hasEnded else { return }
        webRTCBChat.hangUp()
        Storage.write { transaction in
            self.webRTCBChat.endCall(with: self.bchatID, using: transaction)
        }
        hasEnded = true
        NotificationCenter.default.post(name: .connectingCallHideViewNotification, object: nil)
    }
    
    // MARK: Update call message
    func updateCallMessage(mode: EndCallMode) {
        guard let callMessageID = callMessageID else { return }
        Storage.write { transaction in
            let infoMessage = TSInfoMessage.fetch(uniqueId: callMessageID, transaction: transaction)
            if let messageToUpdate = infoMessage {
                var shouldMarkAsRead = false
                if self.duration > 0 {
                    shouldMarkAsRead = true
                } else if self.hasStartedConnecting {
                    shouldMarkAsRead = true
                } else {
                    switch mode {
                        case .local:
                            shouldMarkAsRead = true
                            fallthrough
                        case .remote:
                            fallthrough
                        case .unanswered:
                            if messageToUpdate.callState == .incoming {
                                messageToUpdate.updateCallInfoMessage(.missed, using: transaction)
                            }
                        case .answeredElsewhere:
                            shouldMarkAsRead = true
                    }
                }
                if shouldMarkAsRead {
                    messageToUpdate.markAsRead(atTimestamp: NSDate.ows_millisecondTimeStamp(), trySendReadReceipt: false, transaction: transaction)
                }
            }
        }
    }
    
    // MARK: Renderer
    func attachRemoteVideoRenderer(_ renderer: RTCVideoRenderer) {
        webRTCBChat.attachRemoteRenderer(renderer)
    }
    
    func removeRemoteVideoRenderer(_ renderer: RTCVideoRenderer) {
        webRTCBChat.removeRemoteRenderer(renderer)
    }
    
    func attachLocalVideoRenderer(_ renderer: RTCVideoRenderer) {
        webRTCBChat.attachLocalRenderer(renderer)
    }
    
    func removeLocalVideoRenderer(_ renderer: RTCVideoRenderer) {
        webRTCBChat.removeLocalRenderer(renderer)
    }
    
    // MARK: Delegate
    public func webRTCIsConnected() {
        self.invalidateTimeoutTimer()
        self.reconnectTimer?.invalidate()
        guard !self.hasConnected else {
            hasReconnected?()
            return
        }
        self.hasConnected = true
        self.answerCallAction?.fulfill()
    }
    
    public func isRemoteVideoDidChange(isEnabled: Bool) {
        isRemoteVideoEnabled = isEnabled
    }
    
    public func isAudioMuted(isAudioMuted: Bool) {
        isRemoteAudioMuted = isAudioMuted
    }
    
    public func didReceiveHangUpSignal() {
        self.hasEnded = true
        DispatchQueue.main.async {
            if let currentBanner = IncomingCallBanner.current { currentBanner.dismiss() }
            if let callVC = CurrentAppContext().frontmostViewController() as? NewIncomingCallVC { callVC.handleEndCallMessage() }
            if let miniCallView = MiniCallView.current { miniCallView.dismiss() }
            AppEnvironment.shared.callManager.reportCurrentCallEnded(reason: .remoteEnded)
        }
    }
    
    public func dataChannelDidOpen() {
        // Send initial video status
        if (isVideoEnabled) {
            webRTCBChat.turnOnVideo()
        } else {
            webRTCBChat.turnOffVideo()
        }
    }
    
    public func reconnectIfNeeded() {
        setupTimeoutTimer()
        hasStartedReconnecting?()
        guard isOutgoing else { return }
        tryToReconnect()
    }
    
    private func tryToReconnect() {
        reconnectTimer?.invalidate()
        if SSKEnvironment.shared.reachabilityManager.isReachable {
            Storage.write { transaction in
                self.webRTCBChat.sendOffer(to: self.bchatID, using: transaction, isRestartingICEConnection: true).retainUntilComplete()
            }
        } else {
            reconnectTimer = Timer.scheduledTimerOnMainThread(withTimeInterval: 5, repeats: false) { _ in
                self.tryToReconnect()
            }
        }
    }
    
    // MARK: Timeout
    public func setupTimeoutTimer() {
        invalidateTimeoutTimer()
        let timeInterval: TimeInterval = hasConnected ? 60 : 30
        timeOutTimer = Timer.scheduledTimerOnMainThread(withTimeInterval: timeInterval, repeats: false) { _ in
            self.didTimeout = true
            AppEnvironment.shared.callManager.endCall(self) { error in
                self.timeOutTimer = nil
            }
        }
    }
    
    public func invalidateTimeoutTimer() {
        timeOutTimer?.invalidate()
        timeOutTimer = nil
    }
}
