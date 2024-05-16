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
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        view.addSubview(backgroundImageView)
        backgroundImageView.pin(to: view)
        
        view.addSubViews(voiceCallLabel, backGroundViewForIconAndLabel, callerImageBackgroundView, callerNameLabel, incomingCallLabel, buttonStackView)
        backGroundViewForIconAndLabel.addSubViews(iconView, endToEndLabel)
        callerImageBackgroundView.addSubview(callerImageView)
        buttonStackView.addArrangedSubview(answerButton)
        buttonStackView.addArrangedSubview(hangUpButton)

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
            
        ])
        
        
        
        
    }
    

    
    
    
    
    @objc private func answerCall() {
        
    }
    
    @objc private func endCall() {
        
    }
    

}
