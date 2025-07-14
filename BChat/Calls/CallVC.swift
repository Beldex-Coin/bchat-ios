// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import WebRTC
import BChatUIKit
import BChatMessagingKit
import BChatUtilitiesKit
import UIKit
import MediaPlayer
import AVFoundation

final class CallVC: BaseVC, VideoPreviewDelegate, RTCVideoViewDelegate {
    
    private static let floatingVideoViewWidth: CGFloat = (UIDevice.current.isIPad ? 312 : 116)
    private static let floatingVideoViewHeight: CGFloat = (UIDevice.current.isIPad ? 270: 135)
    
    let bChatCall: BChatCall
    var latestKnownAudioOutputDeviceName: String?
    var durationTimer: Timer?
    var duration: Int = 0
    var shouldRestartCamera = true
    weak var conversationVC: ConversationVC? = nil
    var player: AVAudioPlayer?;
    lazy var cameraManager: CameraManager = {
        let result = CameraManager()
        result.delegate = self
        return result
    }()
    
    var audioSession: AVAudioSession!
    
    private var isSpeakerEnabled = false
    private var isBluetoothEnabled = false
    private var isBluetoothConnectedWithDevice = false
    
    // MARK: Lifecycle
    init(for call: BChatCall) {
        self.bChatCall = call
        super.init(nibName: nil, bundle: nil)
        setupStateChangeCallbacks()
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init(coder: NSCoder) { preconditionFailure("Use init(for:) instead.") }
    
    // Floating local video view
    private lazy var floatingLocalVideoView: LocalVideoView = {
        let result = LocalVideoView()
        result.alpha = 0
        result.backgroundColor = .clear
        result.set(.width, to: Self.floatingVideoViewWidth)
        result.set(.height, to: Self.floatingVideoViewHeight)
        
        return result
    }()
    
    // Floating remote video view
    private lazy var floatingRemoteVideoView: RemoteVideoView = {
        let result = RemoteVideoView()
        result.alpha = 0
        result.backgroundColor = .clear
        result.set(.width, to: Self.floatingVideoViewWidth)
        result.set(.height, to: Self.floatingVideoViewHeight)
        
        return result
    }()
    
    // Fullscreen local video view
    private lazy var fullScreenLocalVideoView: LocalVideoView = {
        let result = LocalVideoView()
        result.alpha = 0
        result.backgroundColor = .clear
        result.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFullScreenVideoViewTapped)))
        return result
    }()
    
    // Fullscreen remote video view
    private lazy var fullScreenRemoteVideoView: RemoteVideoView = {
        let result = RemoteVideoView()
        result.alpha = 0
        result.backgroundColor = .clear
        result.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleFullScreenVideoViewTapped)))
        return result
    }()
    
    private lazy var floatingViewContainer: UIView = {
        let result = UIView()
        result.isHidden = true
        result.clipsToBounds = true
        result.layer.cornerRadius = UIDevice.current.isIPad ? 20 : 10
        result.layer.masksToBounds = true
        result.backgroundColor = Colors.backgroundViewColor
        result.makeViewDraggable()
        
        let userIcon: UIImageView = UIImageView()
        userIcon.image = getProfilePicture(of: 65, for: self.bChatCall.bchatID)
        userIcon.set(.width, to: 65)
        userIcon.set(.height, to: 65)
        userIcon.layer.masksToBounds = true
        userIcon.contentMode = .scaleAspectFit
        userIcon.layer.cornerRadius = 32.5
        result.addSubview(userIcon)
        userIcon.center(in: result)
        
        result.addSubview(floatingLocalVideoView)
        floatingLocalVideoView.pin(to: result)
        
        result.addSubview(floatingRemoteVideoView)
        floatingRemoteVideoView.pin(to: result)
        
        let swappingVideoIcon: UIImageView = UIImageView(
            image: UIImage(systemName: "arrow.2.squarepath")?
                .withRenderingMode(.alwaysTemplate)
        )
//        swappingVideoIcon.tintColor = Colors.textColor
//        swappingVideoIcon.set(.width, to: 16)
//        swappingVideoIcon.set(.height, to: 12)
//        result.addSubview(swappingVideoIcon)
//        swappingVideoIcon.pin(.top, to: .top, of: result, withInset: Values.smallSpacing)
//        swappingVideoIcon.pin(.trailing, to: .trailing, of: result, withInset: -Values.smallSpacing)
        
        result.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchVideo)))
        
        return result
    }()
    
    var backgroundImageView: UIImageView = {
        let theImageView = UIImageView()
        theImageView.layer.masksToBounds = true
        theImageView.image = UIImage(named: "Background_call")
        theImageView.contentMode = .scaleToFill
        return theImageView
    }()
    
    private lazy var voiceCallLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 24)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Voice Call"
        return result
    }()
    
    private lazy var backGroundViewForIconAndLabel: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private lazy var iconView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "Lock_encrypted")
        result.set(.width, to: 12)
        result.set(.height, to: 12)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var endToEndLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "End to End Encrypted"
        return result
    }()
    
    private lazy var incomingCallLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        if bChatCall.hasStartedConnecting { result.text = "Connecting..." }
        return result
    }()
    
    private lazy var answerButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "call_answer")
        result.setImage(image, for: .normal)
        result.set(.width, to: 72)
        result.set(.height, to: 72)
        result.layer.cornerRadius = 36
        result.addTarget(self, action: #selector(answerCall), for: .touchUpInside)
        return result
    }()
    
    private lazy var hangUpButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "call_decline")
        result.setImage(image, for: .normal)
        result.set(.width, to: 72)
        result.set(.height, to: 72)
        result.layer.cornerRadius = 36
        result.addTarget(self, action: #selector(endCall), for: .touchUpInside)
        return result
    }()
    
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 60
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    private lazy var callerImageBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.set(.width, to: 194)
        stackView.set(.height, to: 194)
        stackView.backgroundColor = Colors.mainBackgroundColorWithAlpha
        stackView.layer.cornerRadius = 97
        stackView.layer.borderWidth = 1.19
        stackView.layer.borderColor = Colors.callScreenBorderColor.cgColor
        return stackView
    }()
    
    private lazy var callerImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "")
        result.set(.width, to: 132)
        result.set(.height, to: 132)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        result.layer.cornerRadius = 66
        return result
    }()
    
    lazy var verifiedImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 54)
        result.set(.height, to: 54)
        result.contentMode = .scaleAspectFit
        result.image = UIImage(named: "ic_verified_image")
        return result
    }()
    
    private lazy var backButton: UIButton = {
        let result = UIButton(type: .custom)
        result.isHidden = bChatCall.hasConnected
        let image = UIImage(named: "NavBarBack")!.withTint(isLightMode ? .black : .white)
        result.setImage(image, for: .normal)
        result.set(.width, to: 60)
        result.set(.height, to: 60)
        result.addTarget(self, action: #selector(pop), for: .touchUpInside)
        return result
    }()
    
    private lazy var callerNameLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.semiOpenSans(ofSize: 30)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Person"
        return result
    }()
    
    private lazy var bottomView: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.set(.height, to: 86 + 34)
        View.backgroundColor = Colors.callScreenBottomViewBackgroundColor
        return View
    }()
    
    lazy var stackViewForBottomView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .equalSpacing
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    private lazy var videoButton: UIButton = { // videoButton
        let result = UIButton(type: .custom)
        let image = UIImage(named: "video_enable")
        result.setImage(image, for: .normal)
        let imageSelected = UIImage(named: "video_disable")
        result.setImage(imageSelected, for: .selected)
        result.set(.width, to: 52)
        result.set(.height, to: 52)
        result.layer.cornerRadius = 26
        result.addTarget(self, action: #selector(videoButtonTapped), for: .touchUpInside)
        return result
    }()
    
    private lazy var cameraButton: UIButton = { //switchCameraButton
        let result = UIButton(type: .custom)
        let image = UIImage(named: "cameraRotate_enable")
        result.setImage(image, for: .normal)
        let imageSelected = UIImage(named: "cameraRotate_enable")
        result.setImage(imageSelected, for: .selected)
        result.set(.width, to: 52)
        result.set(.height, to: 52)
        result.layer.cornerRadius = 26
        result.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        result.isEnabled = false
        result.isSelected = false
        return result
    }()
    
    private lazy var emptyButton: UIButton = {
        let result = UIButton(type: .custom)
        result.set(.width, to: 52)
        result.set(.height, to: 52)
        result.layer.cornerRadius = 26
        result.backgroundColor = .clear
        return result
    }()
    
    private lazy var audioButton: UIButton = { //switchAudioButton
        let result = UIButton(type: .custom)
        let image = UIImage(named: "audio_enable")
        result.setImage(image, for: .normal)
        let imageSelected = UIImage(named: "audio_disable")
        result.setImage(imageSelected, for: .selected)
        result.set(.width, to: 52)
        result.set(.height, to: 52)
        result.layer.cornerRadius = 26
        result.addTarget(self, action: #selector(audioButtonTapped), for: .touchUpInside)
        return result
    }()
    
    private lazy var speakerButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "speaker_disable")
        result.setImage(image, for: .normal)
        let imageSelected = UIImage(named: "speaker_disable")
        result.setImage(imageSelected, for: .selected)
        result.set(.width, to: 52)
        result.set(.height, to: 52)
        result.layer.cornerRadius = 26
        result.addTarget(self, action: #selector(speakerButtonTapped), for: .touchUpInside)
        return result
    }()
    
    private lazy var hangUpButtonSecond: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "call_decline")
        result.setImage(image, for: .normal)
        result.set(.width, to: 72)
        result.set(.height, to: 72)
        result.layer.cornerRadius = 36
        result.addTarget(self, action: #selector(endCall), for: .touchUpInside)
        return result
    }()
    
    private lazy var callDurationLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var speakerOptionStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .fill
        result.distribution = .fillEqually
        result.isLayoutMarginsRelativeArrangement = true
        result.set(.height, to: 110)
        result.set(.width, to: 52)
        result.layer.cornerRadius = 26
        result.backgroundColor = Colors.callScreenSpeakerOptionBackgroundColor
        result.spacing = 0
        return result
    }()
    
    private lazy var bluetoothButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "callScreen_bluetooth_white")
        result.setImage(image, for: .normal)
        let imageSelected = UIImage(named: "callScreen_bluetooth_green")
        result.setImage(imageSelected, for: .selected)
        result.set(.width, to: 26)
        result.set(.height, to: 26)
        result.addTarget(self, action: #selector(bluetoothButtonTapped), for: .touchUpInside)
        return result
    }()
    
    private lazy var internalSpeakerButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "callScreen_speaker_white")
        result.setImage(image, for: .normal)
        let imageSelected = UIImage(named: "callScreen_speaker_green")
        result.setImage(imageSelected, for: .selected)
        result.set(.width, to: 26)
        result.set(.height, to: 26)
        result.addTarget(self, action: #selector(internalSpeakerButtonTapped), for: .touchUpInside)
        return result
    }()
    
    private lazy var muteCallLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Mute"
        result.isHidden = true
        return result
    }()
    
    private lazy var smallCallerImageViewForFloatingView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "")
        result.set(.width, to: 65)
        result.set(.height, to: 65)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        result.layer.cornerRadius = 32.5
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if shouldRestartCamera { cameraManager.prepare() }
        
        callerImageBackgroundView.addSubViews(callerImageView, verifiedImageView)
        backGroundViewForIconAndLabel.addSubViews(iconView, endToEndLabel)
        
        view.addSubview(voiceCallLabel)
        view.addSubview(callerNameLabel)
        view.addSubview(callerImageBackgroundView)
        view.addSubview(backGroundViewForIconAndLabel)
        
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        view.addSubview(backgroundImageView)
        backgroundImageView.pin(to: view)
        
        // Remote video view
        bChatCall.attachRemoteVideoRenderer(fullScreenRemoteVideoView)
        view.addSubview(fullScreenRemoteVideoView)
        fullScreenRemoteVideoView.translatesAutoresizingMaskIntoConstraints = false
        fullScreenRemoteVideoView.pin(to: view)
        
        // Local video view
        bChatCall.attachLocalVideoRenderer(floatingLocalVideoView)
        view.addSubview(fullScreenLocalVideoView)
        fullScreenLocalVideoView.translatesAutoresizingMaskIntoConstraints = false
        fullScreenLocalVideoView.pin(to: view)
        
        view.addSubViews(incomingCallLabel, buttonStackView, bottomView, hangUpButtonSecond, callDurationLabel, speakerOptionStackView, muteCallLabel)
        
        buttonStackView.addArrangedSubview(answerButton)
        buttonStackView.addArrangedSubview(hangUpButton)
        bottomView.addSubViews(stackViewForBottomView)
        stackViewForBottomView.addArrangedSubview(videoButton)
        stackViewForBottomView.addArrangedSubview(cameraButton)
        stackViewForBottomView.addArrangedSubview(emptyButton)
        stackViewForBottomView.addArrangedSubview(audioButton)
        stackViewForBottomView.addArrangedSubview(speakerButton)
        speakerOptionStackView.addArrangedSubview(bluetoothButton)
        speakerOptionStackView.addArrangedSubview(internalSpeakerButton)
        self.internalSpeakerButton.isSelected = true
        
        self.bottomView.isHidden = true
        self.hangUpButtonSecond.isHidden = true
        self.callDurationLabel.isHidden = true
        speakerOptionStackView.isHidden = true
        
        self.incomingCallLabel.isHidden = true
        self.buttonStackView.isHidden = true
        self.hangUpButtonSecond.isHidden = false
        self.callDurationLabel.isHidden = false
        self.bottomView.isHidden = false
        
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.pin(.left, to: .left, of: view)
        backButton.pin(.top, to: .top, of: view, withInset: 55)
        
        NSLayoutConstraint.activate([
            voiceCallLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 55),
            voiceCallLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backGroundViewForIconAndLabel.topAnchor.constraint(equalTo: voiceCallLabel.bottomAnchor, constant: 6),
            backGroundViewForIconAndLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callerImageBackgroundView.topAnchor.constraint(equalTo: backGroundViewForIconAndLabel.bottomAnchor, constant: 30),
            callerImageBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callerImageView.centerXAnchor.constraint(equalTo: callerImageBackgroundView.centerXAnchor),
            callerImageView.centerYAnchor.constraint(equalTo: callerImageBackgroundView.centerYAnchor),
            callerNameLabel.topAnchor.constraint(equalTo: callerImageBackgroundView.bottomAnchor, constant: 18),
            callerNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callerNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 12),
            callerNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -12),
            iconView.topAnchor.constraint(equalTo: backGroundViewForIconAndLabel.topAnchor),
            iconView.leadingAnchor.constraint(equalTo: backGroundViewForIconAndLabel.leadingAnchor),
            iconView.bottomAnchor.constraint(equalTo: backGroundViewForIconAndLabel.bottomAnchor),
            endToEndLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 5),
            endToEndLabel.trailingAnchor.constraint(equalTo: backGroundViewForIconAndLabel.trailingAnchor),
            endToEndLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -52),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            incomingCallLabel.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -30),
            incomingCallLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackViewForBottomView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 24),
            stackViewForBottomView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -24),
            stackViewForBottomView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -14),
            hangUpButtonSecond.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hangUpButtonSecond.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: -33),
            callDurationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callDurationLabel.bottomAnchor.constraint(equalTo: hangUpButtonSecond.topAnchor, constant: -36),
            
            muteCallLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            muteCallLabel.bottomAnchor.constraint(equalTo: callDurationLabel.topAnchor, constant: -16),

            speakerOptionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            speakerOptionStackView.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -9),
        ])
        
        verifiedImageView.pin(.trailing, to: .trailing, of: callerImageView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: callerImageView, withInset: 3)
        callerImageView.image = getProfilePicture(of: 132, for: self.bChatCall.bchatID)
        
        let contact: Contact? = Storage.shared.getContact(with: self.bChatCall.bchatID)
        if let _ = contact, let isBnsUser = contact?.isBnsHolder {
            callerImageView.layer.borderWidth = isBnsUser ? Values.borderThickness : 0
            callerImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
            verifiedImageView.isHidden = isBnsUser ? false : true
        } else {
            verifiedImageView.isHidden = true
        }
        
        touch(bChatCall.videoCapturer)
        callerNameLabel.text = self.bChatCall.contactName
        AppEnvironment.shared.callManager.startCall(bChatCall) { error in
            DispatchQueue.main.async {
                if let _ = error {
                    self.incomingCallLabel.text = "Can't start a call."
                    self.endCall()
                } else {
                    self.callDurationLabel.text = "Calling..."
                }
            }
        }
        setupOrientationMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteDidChange), name: AVAudioSession.routeChangeNotification, object: nil)
        self.conversationVC?.inputAccessoryView?.isHidden = true
        self.conversationVC?.inputAccessoryView?.alpha = 0
     
        // For Incoming Call
        if !isCallOutgoing() {
            self.incomingCallLabel.text = "Incoming Call.."
            self.incomingCallLabel.isHidden = false
            self.buttonStackView.isHidden = false
            self.hangUpButtonSecond.isHidden = true
            self.callDurationLabel.isHidden = true
            self.bottomView.isHidden = true
        }
        audioSession = AVAudioSession.sharedInstance()
    }
       
    func setAudioOutputToSpeaker() {
        do {
            // Set the audio session to route audio to the speaker
            try audioSession.overrideOutputAudioPort(.speaker)
            debugPrint("Audio output set to Speaker")
            internalSpeakerButton.isSelected = true
            let image = UIImage(named: "speaker_enable")
            speakerButton.setImage(image, for: .normal)
        } catch {
            debugPrint("Failed to set audio output to speaker: \(error.localizedDescription)")
        }
    }
    
    func setAudioOutputToBluetoothOrSpeaker() {
        do {
            // Set the category to allow both playback and recording
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
            
            // Activate the audio session
            try audioSession.setActive(true)
            
            // Check for Bluetooth availability
            if let availableInputs = audioSession.availableInputs {
                // Try to find a Bluetooth HFP (Hands-Free Profile) input
                if let bluetoothInput = availableInputs.first(where: { $0.portType == .bluetoothHFP || $0.portType == .bluetoothA2DP || $0.portType == .bluetoothLE}) {
                    // If Bluetooth is available, use it
                    try audioSession.setPreferredInput(bluetoothInput)
                    debugPrint("Audio routed to Bluetooth.")
                    bluetoothButton.isSelected = true
                    let image = UIImage(named: "speaker_bluetooth")
                    speakerButton.setImage(image, for: .normal)
                    bluetoothButton.isHidden = false
                    isBluetoothConnectedWithDevice = true
                } else {
                    isSpeakerEnabled ? setAudioOutputToSpeaker() : disableSpeaker()
                    debugPrint("Audio routed to default.")
                }
            }
        } catch {
            debugPrint("Failed to set audio session: \(error)")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let _ = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            if !speakerOptionStackView.isHidden {
                speakerOptionStackView.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (bChatCall.isVideoEnabled && shouldRestartCamera) {
            cameraButton.isEnabled = true
            cameraButton.isSelected = true
            cameraManager.prepare()
            cameraManager.start()
        }
        shouldRestartCamera = true
        addFloatingVideoView()
        self.conversationVC?.inputAccessoryView?.isHidden = true
        self.conversationVC?.inputAccessoryView?.alpha = 0
        setupStateChangeCallbacks()
        
        if bChatCall.hasConnected {
            self.incomingCallLabel.isHidden = true
            self.buttonStackView.isHidden = true
            self.hangUpButtonSecond.isHidden = false
            self.callDurationLabel.isHidden = false
            self.bottomView.isHidden = false
            updateTimer()
        }
        if bChatCall.hasStartedConnecting {
            self.incomingCallLabel.isHidden = true
            self.buttonStackView.isHidden = true
            self.hangUpButtonSecond.isHidden = false
            self.callDurationLabel.isHidden = false
            self.bottomView.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.conversationVC?.inputAccessoryView?.isHidden = true
        self.conversationVC?.inputAccessoryView?.alpha = 0
        
        if (bChatCall.isVideoEnabled && shouldRestartCamera) { cameraManager.start() }
        
        addFloatingVideoView()
        let remoteVideoView: RemoteVideoView = bChatCall.floatingViewVideoSource == .remote ? floatingRemoteVideoView : fullScreenRemoteVideoView
        remoteVideoView.alpha = bChatCall.isRemoteVideoEnabled ? 1 : 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        floatingViewContainer.removeFromSuperview()
        let currentCallDuration = AppEnvironment.shared.callManager.currentCall?.duration
        if currentCallDuration == nil {
            durationTimer?.invalidate()
            durationTimer = nil
        }
    }
    
    @objc private func pop() {
        //Don't delete the below lines
//        NotificationCenter.default.post(name: .callConnectingTapNotification, object: nil)
//        self.conversationVC?.showInputAccessoryView()
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        
        self.shouldRestartCamera = false
        self.conversationVC?.showInputAccessoryView()
        
        let miniCallView = MiniCallView(from: self)
        miniCallView.show()
        
        presentingViewController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: .showInputViewNotification, object: nil)
        }
    }
    
    private func addFloatingVideoView() {
        guard let window: UIWindow = CurrentAppContext().mainWindow else { return }
        
        window.addSubview(floatingViewContainer)
        floatingViewContainer.pin(.bottom, to: .bottom, of: window, withInset: window.safeAreaInsets.bottom - 160)
        floatingViewContainer.pin(.right, to: .right, of: window, withInset: -Values.smallSpacing)
    }
    
    // MARK: - Orientation

    private func setupOrientationMonitoring() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeDeviceOrientation), name: UIDevice.orientationDidChangeNotification, object: UIDevice.current)
    }
    
    func setupStateChangeCallbacks() {
        self.bChatCall.remoteAudioMuted = { isMuted in
            DispatchQueue.main.async {
                self.muteCallLabel.isHidden = !isMuted
                self.muteCallLabel.text = isMuted ? "Muted" : ""
            }
        }
        
        self.bChatCall.remoteVideoStateDidChange = { isEnabled in
            NotificationCenter.default.post(name: .callConnectingTapNotification, object: nil)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    let remoteVideoView: RemoteVideoView = self.bChatCall.floatingViewVideoSource == .remote ? self.floatingRemoteVideoView : self.fullScreenRemoteVideoView
                    remoteVideoView.alpha = isEnabled ? 1 : 0
                }
                    
                if self.incomingCallLabel.alpha < 0.5 {
                    UIView.animate(withDuration: 0.25) {
                        self.callDurationLabel.text = "Connecting..."
                    }
                }
            }
        }
        self.bChatCall.hasStartedConnectingDidChange = {
            DispatchQueue.main.async {
                self.callDurationLabel.text = "Connecting..."
                self.setAudioOutputToBluetoothOrSpeaker()
                NotificationCenter.default.post(name: .callConnectingTapNotification, object: nil)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                }, completion: nil)
                self.incomingCallLabel.isHidden = true
                self.callDurationLabel.isHidden = false
                self.buttonStackView.isHidden = true
                self.hangUpButtonSecond.isHidden = false
                self.bottomView.isHidden = false
            }
        }
        self.bChatCall.hasConnectedDidChange = {
            DispatchQueue.main.async {
                CallRingTonePlayer.shared.stopPlayingRingTone()
                self.callDurationLabel.text = "Connected"
                self.updateTimer()
                self.incomingCallLabel.isHidden = true
                self.callDurationLabel.isHidden = false
                self.setAudioOutputToBluetoothOrSpeaker()
            }
        }
        self.bChatCall.hasEndedDidChange = {
            DispatchQueue.main.async {
                if (self.bChatCall.isVideoEnabled && self.shouldRestartCamera) { self.cameraManager.stop() }
                self.durationTimer?.invalidate()
                self.durationTimer = nil
                self.handleEndCallMessage()
                NotificationCenter.default.post(name: .connectingCallHideViewNotification, object: nil)
            }
        }
        self.bChatCall.hasStartedReconnecting = {
            DispatchQueue.main.async {
                self.incomingCallLabel.isHidden = false
                self.callDurationLabel.isHidden = true
                self.callDurationLabel.text = "Reconnecting..."
            }
        }
        self.bChatCall.hasReconnected = {
            DispatchQueue.main.async {
                self.incomingCallLabel.isHidden = true
                self.callDurationLabel.isHidden = false
                NotificationCenter.default.post(name: .connectingCallShowViewNotification, object: nil)
            }
        }
    }
    
    @objc private func switchVideo() {
        if self.bChatCall.floatingViewVideoSource == .remote {
            bChatCall.removeRemoteVideoRenderer(floatingRemoteVideoView)
            bChatCall.removeLocalVideoRenderer(fullScreenLocalVideoView)
            
            floatingRemoteVideoView.alpha = 0
            floatingLocalVideoView.alpha = bChatCall.isVideoEnabled ? 1 : 0
            fullScreenRemoteVideoView.alpha = bChatCall.isRemoteVideoEnabled ? 1 : 0
            fullScreenLocalVideoView.alpha = 0
            
            bChatCall.floatingViewVideoSource = .local
            bChatCall.attachRemoteVideoRenderer(fullScreenRemoteVideoView)
            bChatCall.attachLocalVideoRenderer(floatingLocalVideoView)
        } else {
            bChatCall.removeRemoteVideoRenderer(fullScreenRemoteVideoView)
            bChatCall.removeLocalVideoRenderer(floatingLocalVideoView)
            
            floatingRemoteVideoView.alpha = bChatCall.isRemoteVideoEnabled ? 1 : 0
            floatingLocalVideoView.alpha = 0
            fullScreenRemoteVideoView.alpha = 0
            fullScreenLocalVideoView.alpha = bChatCall.isVideoEnabled ? 1 : 0
            
            bChatCall.floatingViewVideoSource = .remote
            bChatCall.attachRemoteVideoRenderer(floatingRemoteVideoView)
            bChatCall.attachLocalVideoRenderer(fullScreenLocalVideoView)
        }
    }
    
    func updateTimer() {
        self.durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.callDurationLabel.text = self.bChatCall.duration.stringFromTimeInterval()
            self.buttonStackView.isHidden = true
            self.hangUpButtonSecond.isHidden = false
            self.bottomView.isHidden = false
            self.backButton.isHidden = false
            self.voiceCallLabel.text = self.bChatCall.isVideoEnabled ? "Video Call" : "Voice Call"
                
            NotificationCenter.default.post(name: .connectingCallShowViewNotification, object: nil)
        }
    }
    
    @objc func didChangeDeviceOrientation(notification: Notification) {
        func rotateAllButtons(rotationAngle: CGFloat) {
            let transform = CGAffineTransform(rotationAngle: rotationAngle)
            UIView.animate(withDuration: 0.2) {
                self.answerButton.transform = transform
                self.hangUpButton.transform = transform
                self.audioButton.transform = transform
                self.cameraButton.transform = transform
                self.videoButton.transform = transform
                self.internalSpeakerButton.transform = transform
                self.bluetoothButton.transform = transform
            }
        }
        
        switch UIDevice.current.orientation {
            case .portrait:
                rotateAllButtons(rotationAngle: 0)
            case .portraitUpsideDown:
                rotateAllButtons(rotationAngle: .pi)
            case .landscapeLeft:
                rotateAllButtons(rotationAngle: .halfPi)
            case .landscapeRight:
                rotateAllButtons(rotationAngle: .pi + .halfPi)
            default:
                break
        }
    }
    
    // MARK: Call signalling
    func handleAnswerMessage(_ message: CallMessage) {
        callDurationLabel.text = "Connecting..."
    }
    
    func handleEndCallMessage() {
        //END CALL NOTIFICATION
        SNLog("[Calls] Ending call.")
        self.incomingCallLabel.isHidden = true
        self.callDurationLabel.isHidden = true
        callDurationLabel.text = "Call Ended"
        self.alertOnCallEnding()
        durationTimer?.invalidate()
        durationTimer = nil
        if (bChatCall.isVideoEnabled && shouldRestartCamera) { cameraManager.stop() }
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            self.conversationVC?.showInputAccessoryView()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        UIView.animate(withDuration: 0.25) {
            let remoteVideoView: RemoteVideoView = self.bChatCall.floatingViewVideoSource == .remote ? self.floatingRemoteVideoView : self.fullScreenRemoteVideoView
            remoteVideoView.alpha = 0
        }
        
        NotificationCenter.default.post(name: .connectingCallHideViewNotification, object: nil)
    }
    
    @objc private func answerCall() {
        self.incomingCallLabel.isHidden = true
        self.buttonStackView.isHidden = true
        self.hangUpButtonSecond.isHidden = false
        self.callDurationLabel.isHidden = false
        self.bottomView.isHidden = false
        
        UIApplication.shared.isIdleTimerDisabled = true
        AppEnvironment.shared.callManager.answerCall(bChatCall) { error in
            DispatchQueue.main.async {
                if let _ = error {
                    self.callDurationLabel.text = "Can't answer the call."
                    self.endCall()
                }
            }
        }
    }
    
    @objc private func endCall() {
        UIApplication.shared.isIdleTimerDisabled = false
        NotificationCenter.default.post(name: .connectingCallHideViewNotification, object: nil)
        AppEnvironment.shared.callManager.endCall(bChatCall) { error in
            if let _ = error {
                self.bChatCall.endBChatCall()
                AppEnvironment.shared.callManager.reportCurrentCallEnded(reason: nil)
            }
            DispatchQueue.main.async {
                self.floatingLocalVideoView.isHidden = true
                self.conversationVC?.showInputAccessoryView()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func alertOnCallEnding() {
        guard let url = Bundle.main.url(forResource: "webrtc_call_end", withExtension: "mp3") else {
            debugPrint("error");
            return;
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers);
            player = try AVAudioPlayer(contentsOf: url);
            guard let player = player else {
                debugPrint("error");
                return;
            }
            player.play();
        } catch let error {
            debugPrint(error.localizedDescription);
        }
    }
    
    func isCallOutgoing() -> Bool {
        guard let call = AppEnvironment.shared.callManager.currentCall else { return true }
        return call.isOutgoing
    }
    
    @objc private func videoButtonTapped(sender : UIButton) {
        sender.isSelected = !sender.isSelected
        if (bChatCall.isVideoEnabled) {
            floatingViewContainer.isHidden = bChatCall.floatingViewVideoSource == .local || !bChatCall.isRemoteVideoEnabled
            cameraManager.stop()
            bChatCall.isVideoEnabled = false
            cameraButton.isEnabled = false
            cameraButton.isSelected = false
            videoButton.tintColor = .white
            videoButton.backgroundColor = UIColor(hex: 0x1F1F1F)
            
            //bChatCall.removeLocalVideoRenderer(fullScreenLocalVideoView)
            fullScreenLocalVideoView.alpha = 0
        } else {
            guard requestCameraPermissionIfNeeded() else { return }
            let previewVC = VideoPreviewVC()
            previewVC.delegate = self
            present(previewVC, animated: true)
        }
    }
    
    func cameraDidConfirmTurningOn() {
        floatingViewContainer.isHidden = false
        let localVideoView: LocalVideoView = bChatCall.floatingViewVideoSource == .local ? floatingLocalVideoView : fullScreenLocalVideoView
        localVideoView.alpha = 1
        
        cameraManager.prepare()
        cameraManager.start()
        bChatCall.isVideoEnabled = true
        cameraButton.isEnabled = true
        cameraButton.isSelected = true
        videoButton.tintColor = UIColor(hex: 0x1F1F1F)
        videoButton.backgroundColor = .white
        setAudioOutputForVideoCall()
    }
    
    
    @objc private func cameraButtonTapped(sender : UIButton) {
        if bChatCall.isVideoEnabled {
            sender.isSelected = !sender.isSelected
            cameraManager.switchCamera()
        } else {
            debugPrint("Enable video call first")
        }
    }
    
    @objc private func audioButtonTapped(sender : UIButton) {
        sender.isSelected = !sender.isSelected
        if bChatCall.isMuted {
            audioButton.backgroundColor = UIColor(hex: 0x1F1F1F)
            bChatCall.isMuted = false
        } else {
            audioButton.backgroundColor = Colors.destructive
            bChatCall.isMuted = true
        }
    }
    
    @objc private func speakerButtonTapped(sender : UIButton) {
        speakerOptionStackView.isHidden = !speakerOptionStackView.isHidden
        if !isBluetoothConnectedWithDevice {
            speakerOptionStackView.isHidden = true
            isSpeakerEnabled.toggle()
            if isSpeakerEnabled {
                setAudioOutputToSpeaker()
            } else {
                disableSpeaker()
            }
        } else {
            bluetoothButton.isHidden = false
        }
    }
    
    @objc private func bluetoothButtonTapped(sender : UIButton) {
        speakerOptionStackView.isHidden = true
        enableBluetooth()
        sender.isSelected = true
        internalSpeakerButton.isSelected = false
    }
    
    func enableBluetooth() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: .allowBluetooth)
            try audioSession.setActive(true)
            bluetoothButton.isSelected = true
            let image = UIImage(named: "speaker_bluetooth")
            speakerButton.setImage(image, for: .normal)
        } catch {
            debugPrint("Error setting up audio session: \(error.localizedDescription)")
        }
    }
    
    func disableSpeaker() {
        do {
            // Set the audio session to route audio to the speaker
            try audioSession.overrideOutputAudioPort(.none)
            bluetoothButton.isSelected = false
            internalSpeakerButton.isSelected = false
            let image = UIImage(named: "speaker_disable")
            speakerButton.setImage(image, for: .normal)
        } catch {
            debugPrint("Failed to set audio output to speaker: \(error.localizedDescription)")
        }
    }
    
    @objc private func internalSpeakerButtonTapped(sender : UIButton) {
        speakerOptionStackView.isHidden = true
        setAudioOutputToSpeaker()
        sender.isSelected = true
        bluetoothButton.isSelected = false
    }
    
    func setAudioOutputForVideoCall() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            if let availableInputs = audioSession.availableInputs {
                if let bluetoothInput = availableInputs.first(where: { $0.portType == .bluetoothHFP || $0.portType == .bluetoothA2DP || $0.portType == .bluetoothLE}) {
                    try audioSession.setPreferredInput(bluetoothInput)
                    bluetoothButton.isSelected = true
                    let image = UIImage(named: "speaker_bluetooth")
                    speakerButton.setImage(image, for: .normal)
                    bluetoothButton.isHidden = false
                    isBluetoothConnectedWithDevice = true
                } else {
                    setAudioOutputToSpeaker()
                    bluetoothButton.isHidden = true
                    isBluetoothConnectedWithDevice = false
                }
            }
        } catch {
            debugPrint("Failed to set audio session: \(error)")
        }
    }
    
    @objc private func audioRouteDidChange(_ notification: Notification) {
        let currentSession = AVAudioSession.sharedInstance()
        let currentRoute = currentSession.currentRoute
        if let currentOutput = currentRoute.outputs.first {
            if let latestKnownAudioOutputDeviceName = latestKnownAudioOutputDeviceName, currentOutput.portName == latestKnownAudioOutputDeviceName { return }
            latestKnownAudioOutputDeviceName = currentOutput.portName
            
            switch currentOutput.portType {
                case .builtInSpeaker:
                    let image = UIImage(named: "speaker_enable")
                    speakerButton.setImage(image, for: .normal)
                    internalSpeakerButton.isSelected = true
                case .headphones:
                    let image = UIImage(named: "speaker_enable")
                    speakerButton.setImage(image, for: .normal)
                    internalSpeakerButton.isSelected = true
                case .bluetoothLE: fallthrough
                case .bluetoothA2DP:
                    bluetoothButton.isHidden = false
                    internalSpeakerButton.isSelected = false
                    bluetoothButton.isSelected = true
                    let image = UIImage(named: "speaker_bluetooth")
                    speakerButton.setImage(image, for: .normal)
                case .bluetoothHFP:
                    bluetoothButton.isHidden = false
                    internalSpeakerButton.isSelected = false
                    bluetoothButton.isSelected = true
                    let image = UIImage(named: "speaker_bluetooth")
                    speakerButton.setImage(image, for: .normal)
                case .builtInReceiver: fallthrough
                default:
                    let image = UIImage(named: "speaker_disable")
                    speakerButton.setImage(image, for: .normal)
            }

        }
        
        guard let info = notification.userInfo,
              let reasonValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
            case .newDeviceAvailable:
                debugPrint("New audio device connected.")
            case .oldDeviceUnavailable:
                debugPrint("Audio device disconnected (e.g., Bluetooth).")
                disableSpeaker()
                bluetoothButton.isHidden = true
                isBluetoothConnectedWithDevice = false
            case .categoryChange:
                debugPrint("Audio session category changed.")
            case .override:
                debugPrint("Audio session override.")
            case .wakeFromSleep:
                debugPrint("Audio session woke from sleep.")
            @unknown default:
                debugPrint("Unknown audio route change.")
        }
    }
    
    @objc private func handleFullScreenVideoViewTapped() {
        let isHidden = callDurationLabel.alpha < 0.5
        
        UIView.animate(withDuration: 0.5) {
            self.hangUpButtonSecond.alpha = isHidden ? 1 : 0
            self.bottomView.alpha = isHidden ? 1 : 0
            self.callDurationLabel.alpha = isHidden ? 1 : 0
            self.backButton.alpha = isHidden ? 1 : 0
            self.muteCallLabel.alpha  = isHidden ? 1 : 0
            self.voiceCallLabel.alpha  = isHidden ? 1 : 0
            self.endToEndLabel.alpha  = isHidden ? 1 : 0
            self.iconView.alpha = isHidden ? 1 : 0
        }
    }
    
    
    // MARK: RTCVideoViewDelegate
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        videoView.setSize(floatingLocalVideoView.size)
    }
}
