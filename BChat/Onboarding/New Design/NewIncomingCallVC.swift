// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewIncomingCallVC: BaseVC {
    
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
        result.text = "Incoming Call.."
        return result
    }()
    
    private lazy var answerButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "call_answer")
        result.setImage(image, for: UIControl.State.normal)
        result.set(.width, to: 72)
        result.set(.height, to: 72)
        result.layer.cornerRadius = 36
        result.addTarget(self, action: #selector(answerCall), for: UIControl.Event.touchUpInside)
        return result
    }()
    
    private lazy var hangUpButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "call_decline")
        result.setImage(image, for: UIControl.State.normal)
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
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.cornerRadius = 97
        stackView.layer.borderWidth = 1.19
        stackView.layer.borderColor = UIColor(hex: 0x363645).cgColor
        return stackView
    }()
    
    private lazy var callerImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_test")
        result.set(.width, to: 132)
        result.set(.height, to: 132)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        result.layer.cornerRadius = 66
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
        View.backgroundColor = UIColor(hex: 0x11111A)
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
    
    private lazy var videoButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "video_enable")
        result.setImage(image, for: UIControl.State.normal)
        let imageSelected = UIImage(named: "video_disable")
        result.setImage(imageSelected, for: UIControl.State.selected)
        result.set(.width, to: 52)
        result.set(.height, to: 52)
        result.layer.cornerRadius = 26
        result.addTarget(self, action: #selector(videoButtonTapped), for: UIControl.Event.touchUpInside)
        return result
    }()
        
    private lazy var cameraButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "cameraRotate_disable")
        result.setImage(image, for: UIControl.State.normal)
        let imageSelected = UIImage(named: "cameraRotate_enable")
        result.setImage(imageSelected, for: UIControl.State.selected)
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
    
    private lazy var audioButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "audio_enable")
        result.setImage(image, for: UIControl.State.normal)
        let imageSelected = UIImage(named: "audio_disable")
        result.setImage(imageSelected, for: UIControl.State.selected)
        result.set(.width, to: 52)
        result.set(.height, to: 52)
        result.layer.cornerRadius = 26
        result.addTarget(self, action: #selector(audioButtonTapped), for: UIControl.Event.touchUpInside)
        return result
    }()
    
    private lazy var speakerButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "speaker_disable")
        result.setImage(image, for: UIControl.State.normal)
        let imageSelected = UIImage(named: "speaker_disable")
        result.setImage(imageSelected, for: UIControl.State.selected)
        result.set(.width, to: 52)
        result.set(.height, to: 52)
        result.layer.cornerRadius = 26
        result.addTarget(self, action: #selector(speakerButtonTapped), for: UIControl.Event.touchUpInside)
        return result
    }()
    
    private lazy var hangUpButtonSecond: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "call_decline")
        result.setImage(image, for: UIControl.State.normal)
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
        result.text = "0:00"
        return result
    }()
    
    
    private lazy var speakerOptionView: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.set(.height, to: 110)
        View.set(.width, to: 52)
        View.layer.cornerRadius = 26
        View.backgroundColor = UIColor(hex: 0x11111A)
        return View
    }()
    
    private lazy var bluetoothButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "callScreen_bluetooth_white")
        result.setImage(image, for: UIControl.State.normal)
        let imageSelected = UIImage(named: "callScreen_bluetooth_green")
        result.setImage(imageSelected, for: UIControl.State.selected)
        result.set(.width, to: 26)
        result.set(.height, to: 26)
        result.addTarget(self, action: #selector(bluetoothButtonTapped), for: UIControl.Event.touchUpInside)
        return result
    }()
    
    private lazy var internalSpeakerButton: UIButton = {
        let result = UIButton(type: .custom)
        let image = UIImage(named: "callScreen_speaker_white")
        result.setImage(image, for: UIControl.State.normal)
        let imageSelected = UIImage(named: "callScreen_speaker_green")
        result.setImage(imageSelected, for: UIControl.State.selected)
        result.set(.width, to: 26)
        result.set(.height, to: 26)
        result.addTarget(self, action: #selector(internalSpeakerButtonTapped), for: UIControl.Event.touchUpInside)
        return result
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        view.addSubview(backgroundImageView)
        backgroundImageView.pin(to: view)
        
        view.addSubViews(voiceCallLabel, backGroundViewForIconAndLabel, callerImageBackgroundView, callerNameLabel, incomingCallLabel, buttonStackView, bottomView, hangUpButtonSecond, callDurationLabel, speakerOptionView)
        backGroundViewForIconAndLabel.addSubViews(iconView, endToEndLabel)
        callerImageBackgroundView.addSubview(callerImageView)
        buttonStackView.addArrangedSubview(answerButton)
        buttonStackView.addArrangedSubview(hangUpButton)
        bottomView.addSubViews(stackViewForBottomView)
        stackViewForBottomView.addArrangedSubview(videoButton)
        stackViewForBottomView.addArrangedSubview(cameraButton)
        stackViewForBottomView.addArrangedSubview(emptyButton)
        stackViewForBottomView.addArrangedSubview(audioButton)
        stackViewForBottomView.addArrangedSubview(speakerButton)
        speakerOptionView.addSubViews(bluetoothButton, internalSpeakerButton)
        self.internalSpeakerButton.isSelected = true
        
        self.bottomView.isHidden = true
        self.hangUpButtonSecond.isHidden = true
        self.callDurationLabel.isHidden = true
        self.speakerOptionView.isHidden = true
        
        
        NSLayoutConstraint.activate([
            voiceCallLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 31),
            voiceCallLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backGroundViewForIconAndLabel.topAnchor.constraint(equalTo: voiceCallLabel.bottomAnchor, constant: 6),
            backGroundViewForIconAndLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callerImageBackgroundView.topAnchor.constraint(equalTo: backGroundViewForIconAndLabel.bottomAnchor, constant: 30),
            callerImageBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callerImageView.centerXAnchor.constraint(equalTo: callerImageBackgroundView.centerXAnchor),
            callerImageView.centerYAnchor.constraint(equalTo: callerImageBackgroundView.centerYAnchor),
            callerNameLabel.topAnchor.constraint(equalTo: callerImageBackgroundView.bottomAnchor, constant: 18),
            callerNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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
            speakerOptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            speakerOptionView.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -9),
            bluetoothButton.topAnchor.constraint(equalTo: speakerOptionView.topAnchor, constant: 22),
            bluetoothButton.centerXAnchor.constraint(equalTo: speakerOptionView.centerXAnchor),
            internalSpeakerButton.topAnchor.constraint(equalTo: bluetoothButton.bottomAnchor, constant: 19),
            internalSpeakerButton.centerXAnchor.constraint(equalTo: speakerOptionView.centerXAnchor),
        ])
     
        
    }
    
    
    
    
    
    
    @objc private func answerCall() {
        self.incomingCallLabel.isHidden = true
        self.buttonStackView.isHidden = true
        self.hangUpButtonSecond.isHidden = false
        self.callDurationLabel.isHidden = false
        self.bottomView.isHidden = false
    }
    
    @objc private func endCall() {
        
    }
    
    
    @objc private func videoButtonTapped(sender : UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func cameraButtonTapped(sender : UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func audioButtonTapped(sender : UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func speakerButtonTapped(sender : UIButton) {
        sender.isSelected = !sender.isSelected
        self.speakerOptionView.isHidden = false
    }
    
    @objc private func bluetoothButtonTapped(sender : UIButton) {
        sender.isSelected = !sender.isSelected
        self.speakerOptionView.isHidden = true
        self.internalSpeakerButton.isSelected = !self.bluetoothButton.isSelected
    }
    
    @objc private func internalSpeakerButtonTapped(sender : UIButton) {
        sender.isSelected = !sender.isSelected
        self.speakerOptionView.isHidden = true
        self.bluetoothButton.isSelected = !self.internalSpeakerButton.isSelected
    }
    
}
