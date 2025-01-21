// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import WebRTC
import BChatUIKit
import BChatMessagingKit
import BChatUtilitiesKit
import UIKit
import MediaPlayer
import AVFoundation

final class NewIncomingCallVC: BaseVC,VideoPreviewDelegate {
    
    
    let call: BChatCall
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
    var isVideoSwapped = false
    
    var audioSession: AVAudioSession!
    
    private var isSpeakerEnabled = false
    private var isBluetoothEnabled = false
    private var isBluetoothConnectedWithDevice = false
    
    // MARK: Lifecycle
    init(for call: BChatCall) {
        self.call = call
        super.init(nibName: nil, bundle: nil)
        setupStateChangeCallbacks()
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init(coder: NSCoder) { preconditionFailure("Use init(for:) instead.") }
    
    
    private lazy var localVideoView: LocalVideoView = {
        let result = LocalVideoView()
//        result.isHidden = !call.isVideoEnabled
        result.layer.cornerRadius = 10
        result.layer.masksToBounds = true
        result.set(.width, to: LocalVideoView.width)
        result.set(.height, to: LocalVideoView.height)
        result.makeViewDraggable()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(smallVideoViewTapped))
        result.addGestureRecognizer(tapGestureRecognizer)
        return result
    }()
    
    private lazy var remoteVideoView: RemoteVideoView = {
        let result = RemoteVideoView()
        result.alpha = 0
        result.backgroundColor = .black
        result.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleRemoteVieioViewTapped)))
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
        if call.hasStartedConnecting { result.text = "Connecting..." }
        return result
    }()
    
    private lazy var answerButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "call_answer")
        result.setImage(image, for: .normal)
        result.set(.width, to: 72)
        result.set(.height, to: 72)
        result.layer.cornerRadius = 36
        result.addTarget(self, action: #selector(answerCall), for: UIControl.Event.touchUpInside)
        return result
    }()
    
    private lazy var hangUpButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "call_decline")
        result.setImage(image, for: .normal)
        result.set(.width, to: 72)
        result.set(.height, to: 72)
        result.layer.cornerRadius = 36
        result.addTarget(self, action: #selector(endCall), for: UIControl.Event.touchUpInside)
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
        result.isHidden = call.hasConnected
        let image = UIImage(named: "NavBarBack")!.withTint(isLightMode ? .black : .white)
        result.setImage(image, for: .normal)
        result.set(.width, to: 60)
        result.set(.height, to: 60)
        result.addTarget(self, action: #selector(pop), for: UIControl.Event.touchUpInside)
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
        result.addTarget(self, action: #selector(videoButtonTapped), for: UIControl.Event.touchUpInside)
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
        result.addTarget(self, action: #selector(cameraButtonTapped), for: UIControl.Event.touchUpInside)
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
        result.addTarget(self, action: #selector(audioButtonTapped), for: UIControl.Event.touchUpInside)
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
        result.addTarget(self, action: #selector(speakerButtonTapped), for: UIControl.Event.touchUpInside)
        return result
    }()
    
    private lazy var hangUpButtonSecond: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "call_decline")
        result.setImage(image, for: .normal)
        result.set(.width, to: 72)
        result.set(.height, to: 72)
        result.layer.cornerRadius = 36
        result.addTarget(self, action: #selector(endCall), for: UIControl.Event.touchUpInside)
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
        result.addTarget(self, action: #selector(bluetoothButtonTapped), for: UIControl.Event.touchUpInside)
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
        result.addTarget(self, action: #selector(internalSpeakerButtonTapped), for: UIControl.Event.touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        view.addSubview(backgroundImageView)
        backgroundImageView.pin(to: view)
        
        // Remote video view
        call.attachRemoteVideoRenderer(remoteVideoView)
        view.addSubview(remoteVideoView)
        remoteVideoView.translatesAutoresizingMaskIntoConstraints = false
        remoteVideoView.pin(to: view)
        // Local video view
        call.attachLocalVideoRenderer(localVideoView)
        
        view.addSubViews(voiceCallLabel, backGroundViewForIconAndLabel, callerImageBackgroundView, callerNameLabel, incomingCallLabel, buttonStackView, bottomView, hangUpButtonSecond, callDurationLabel, speakerOptionStackView, muteCallLabel)
        backGroundViewForIconAndLabel.addSubViews(iconView, endToEndLabel)
        callerImageBackgroundView.addSubViews(callerImageView, verifiedImageView)
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
        callerImageView.image = getProfilePicture(of: 132, for: self.call.bchatID)
        
        let contact: Contact? = Storage.shared.getContact(with: self.call.bchatID)
        if let _ = contact, let isBnsUser = contact?.isBnsHolder {
            callerImageView.layer.borderWidth = isBnsUser ? Values.borderThickness : 0
            callerImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
            verifiedImageView.isHidden = isBnsUser ? false : true
        } else {
            verifiedImageView.isHidden = true
        }
        
        
        if shouldRestartCamera { cameraManager.prepare() }
        touch(call.videoCapturer)
        callerNameLabel.text = self.call.contactName
        AppEnvironment.shared.callManager.startCall(call) { error in
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
            print("Audio output set to Speaker")
            internalSpeakerButton.isSelected = true
            let image = UIImage(named: "speaker_enable")
            speakerButton.setImage(image, for: .normal)
        } catch {
            print("Failed to set audio output to speaker: \(error.localizedDescription)")
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
                    print("Audio routed to Bluetooth.")
                    bluetoothButton.isSelected = true
                    let image = UIImage(named: "speaker_bluetooth")
                    speakerButton.setImage(image, for: .normal)
                    bluetoothButton.isHidden = false
                    isBluetoothConnectedWithDevice = true
                } else {
                    disableSpeaker()
                    print("Audio routed to Loudspeaker.")
                }
            }
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            if !speakerOptionStackView.isHidden {
                speakerOptionStackView.isHidden = true
            }
        }
    }
    
    private func addLocalVideoView() {
        let safeAreaInsets = UIApplication.shared.keyWindow!.safeAreaInsets
        let window = CurrentAppContext().mainWindow!
        window.addSubview(localVideoView)
        localVideoView.autoPinEdge(toSuperviewEdge: .right, withInset: Values.smallSpacing)
        let topMargin = safeAreaInsets.top + Values.veryLargeSpacing
        localVideoView.autoPinEdge(toSuperviewEdge: .top, withInset: topMargin)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (call.isVideoEnabled && shouldRestartCamera) { cameraManager.start() }
        shouldRestartCamera = true
        addLocalVideoView()
        remoteVideoView.alpha = call.isRemoteVideoEnabled ? 1 : 0
        self.conversationVC?.inputAccessoryView?.isHidden = true
        self.conversationVC?.inputAccessoryView?.alpha = 0
        setupStateChangeCallbacks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.conversationVC?.inputAccessoryView?.isHidden = true
        self.conversationVC?.inputAccessoryView?.alpha = 0
        
        if call.hasConnected {
            self.incomingCallLabel.isHidden = true
            self.buttonStackView.isHidden = true
            self.hangUpButtonSecond.isHidden = false
            self.callDurationLabel.isHidden = false
            self.bottomView.isHidden = false
        }
        if call.hasStartedConnecting {
            self.incomingCallLabel.isHidden = true
            self.buttonStackView.isHidden = true
            self.hangUpButtonSecond.isHidden = false
            self.callDurationLabel.isHidden = false
            self.bottomView.isHidden = false
        }
        
        if call.hasConnected {
            updateTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (call.isVideoEnabled && shouldRestartCamera) { cameraManager.stop() }
//        localVideoView.removeFromSuperview()
    }
    
    @objc private func pop() {
        NotificationCenter.default.post(name: .callConnectingTapNotification, object: nil)
        self.conversationVC?.showInputAccessoryView()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Orientation

    private func setupOrientationMonitoring() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeDeviceOrientation), name: UIDevice.orientationDidChangeNotification, object: UIDevice.current)
    }
    
    func setupStateChangeCallbacks() {
        self.call.remoteVideoStateDidChange = { isEnabled in
            NotificationCenter.default.post(name: .callConnectingTapNotification, object: nil)
            DispatchQueue.main.async {
                if self.incomingCallLabel.alpha < 0.5 {
                    UIView.animate(withDuration: 0.25) {
                        self.callDurationLabel.text = "Connecting..."
                    }
                }
            }
        }
        self.call.hasStartedConnectingDidChange = {
            DispatchQueue.main.async {
                self.callDurationLabel.text = "Connecting..."
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
        self.call.hasConnectedDidChange = {
            DispatchQueue.main.async {
                CallRingTonePlayer.shared.stopPlayingRingTone()
                self.callDurationLabel.text = "Connected"
                self.updateTimer()
                self.incomingCallLabel.isHidden = true
                self.callDurationLabel.isHidden = false
                self.setAudioOutputToBluetoothOrSpeaker()
            }
        }
        self.call.hasEndedDidChange = {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .connectingCallHideViewNotification, object: nil)
                self.durationTimer?.invalidate()
                self.durationTimer = nil
                self.handleEndCallMessage()
            }
        }
        self.call.hasStartedReconnecting = {
            DispatchQueue.main.async {
                self.incomingCallLabel.isHidden = false
                self.callDurationLabel.isHidden = true
                self.callDurationLabel.text = "Reconnecting..."
            }
        }
        self.call.hasReconnected = {
            DispatchQueue.main.async {
                self.incomingCallLabel.isHidden = true
                self.callDurationLabel.isHidden = false
                NotificationCenter.default.post(name: .connectingCallShowViewNotification, object: nil)
            }
        }
    }
    
    @objc private func smallVideoViewTapped() {
        isVideoSwapped.toggle()
        if isVideoSwapped {
            call.removeRemoteVideoRenderer(remoteVideoView)
            call.removeLocalVideoRenderer(localVideoView)
            call.attachRemoteVideoRenderer(localVideoView)
            call.attachLocalVideoRenderer(remoteVideoView)
        } else {
            call.removeRemoteVideoRenderer(localVideoView)
            call.removeLocalVideoRenderer(remoteVideoView)
            call.attachRemoteVideoRenderer(remoteVideoView)
            call.attachLocalVideoRenderer(localVideoView)
        }
    }
    
    func updateTimer() {
        self.durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.callDurationLabel.text = self.call.duration.stringFromTimeInterval()
            NotificationCenter.default.post(name: .connectingCallShowViewNotification, object: nil)
            self.buttonStackView.isHidden = true
            self.hangUpButtonSecond.isHidden = false
            self.bottomView.isHidden = false
            self.backButton.isHidden = false
            self.callerImageView.isHidden = self.call.isRemoteVideoEnabled
            self.callerNameLabel.isHidden = self.call.isRemoteVideoEnabled
            self.remoteVideoView.alpha = self.call.isRemoteVideoEnabled ? 1 : 0
            self.voiceCallLabel.text = self.call.isVideoEnabled ? "Video Call" : "Voice Call"
            self.callerImageBackgroundView.isHidden = self.call.isVideoEnabled || self.call.isRemoteVideoEnabled
            
            if !self.isCallOutgoing() {
                if self.call.isMuted {
                    self.muteCallLabel.isHidden = true
                } else {
                    self.muteCallLabel.isHidden = false
                }
            }
            
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
        NotificationCenter.default.post(name: .connectingCallHideViewNotification, object: nil)
        SNLog("[Calls] Ending call.")
        self.incomingCallLabel.isHidden = true
        self.callDurationLabel.isHidden = true
        callDurationLabel.text = "Call Ended"
        self.alertOnCallEnding()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            self.conversationVC?.showInputAccessoryView()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func answerCall() {
        self.incomingCallLabel.isHidden = true
        self.buttonStackView.isHidden = true
        self.hangUpButtonSecond.isHidden = false
        self.callDurationLabel.isHidden = false
        self.bottomView.isHidden = false
        
        UIApplication.shared.isIdleTimerDisabled = true
        AppEnvironment.shared.callManager.answerCall(call) { error in
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
        AppEnvironment.shared.callManager.endCall(call) { error in
            if let _ = error {
                self.call.endBChatCall()
                AppEnvironment.shared.callManager.reportCurrentCallEnded(reason: nil)
            }
            DispatchQueue.main.async {
                self.conversationVC?.showInputAccessoryView()
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func alertOnCallEnding() {
        guard let url = Bundle.main.url(forResource: "webrtc_call_end", withExtension: "mp3") else {
            print("error");
            return;
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers);
            player = try AVAudioPlayer(contentsOf: url);
            guard let player = player else {
                print("error");
                return;
            }
            player.play();
        } catch let error {
            print(error.localizedDescription);
        }
    }
    
    
    func isCallOutgoing() -> Bool {
        guard let call = AppEnvironment.shared.callManager.currentCall else { return true }
        return call.isOutgoing
    }
    
    @objc private func videoButtonTapped(sender : UIButton) {
        sender.isSelected = !sender.isSelected
        if (call.isVideoEnabled) {
//            localVideoView.isHidden = true
            cameraManager.stop()
            call.isVideoEnabled = false
            cameraButton.isEnabled = false
            cameraButton.isSelected = false
            videoButton.tintColor = .white
            videoButton.backgroundColor = UIColor(hex: 0x1F1F1F)
        } else {
            guard requestCameraPermissionIfNeeded() else { return }
            let previewVC = VideoPreviewVC()
            previewVC.delegate = self
            present(previewVC, animated: true, completion: nil)
        }
    }
    
    func cameraDidConfirmTurningOn() {
        localVideoView.isHidden = false
        cameraManager.prepare()
        cameraManager.start()
        call.isVideoEnabled = true
        cameraButton.isEnabled = true
        cameraButton.isSelected = true
        videoButton.tintColor = UIColor(hex: 0x1F1F1F)
        videoButton.backgroundColor = .white
        setAudioOutputForVideoCall()
    }
    
    
    @objc private func cameraButtonTapped(sender : UIButton) {
        sender.isSelected = !sender.isSelected
        cameraManager.switchCamera()
    }
    
    @objc private func audioButtonTapped(sender : UIButton) {
        sender.isSelected = !sender.isSelected
        if call.isMuted {
            audioButton.backgroundColor = UIColor(hex: 0x1F1F1F)
            call.isMuted = false
        } else {
            audioButton.backgroundColor = Colors.destructive
            call.isMuted = true
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
            print("Error setting up audio session: \(error.localizedDescription)")
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
            print("Failed to set audio output to speaker: \(error.localizedDescription)")
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
            print("Failed to set audio session: \(error)")
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
            print("New audio device connected.")
        case .oldDeviceUnavailable:
            print("Audio device disconnected (e.g., Bluetooth).")
            disableSpeaker()
            bluetoothButton.isHidden = true
            isBluetoothConnectedWithDevice = false
        case .categoryChange:
            print("Audio session category changed.")
        case .override:
            print("Audio session override.")
        case .wakeFromSleep:
            print("Audio session woke from sleep.")
        @unknown default:
            print("Unknown audio route change.")
        }
    }
    
    @objc private func handleRemoteVieioViewTapped(gesture: UITapGestureRecognizer) {
        let isHidden = callDurationLabel.alpha < 0.5
    }

    func getProfilePicture(of size: CGFloat, for publicKey: String) -> UIImage? {
        guard !publicKey.isEmpty else { return nil }
        if let profilePicture = OWSProfileManager.shared().profileAvatar(forRecipientId: publicKey) {
            return profilePicture
        } else {
            // TODO: Pass in context?
            let displayName = Storage.shared.getContact(with: publicKey)?.name ?? publicKey
            return Identicon.generatePlaceholderIcon(seed: publicKey, text: displayName, size: size)
        }
    }
    
}
