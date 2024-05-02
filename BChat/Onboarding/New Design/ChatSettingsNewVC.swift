// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class ChatSettingsNewVC: BaseVC {
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.cellGroundColor2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    
    private lazy var profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 43
        imageView.image = UIImage(named: "ic_test")
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let result = UILabel()
        result.text = "Name"
        result.textColor = Colors.titleColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    private lazy var bChatLabel: UILabel = {
        let result = UILabel()
        result.text = "BChat ID"
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var bChatIdLabel: UILabel = {
        let result = PaddingLabel()
        result.text = "ajhsgd929a8syksdhsaskjhuweuibfabfaaskjdhaskdaskdhaskdhaafof"
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.paddingTop = 9
        result.paddingBottom = 9
        result.paddingLeft = 15
        result.paddingRight = 15
        result.backgroundColor = Colors.unlockButtonBackgroundColor
        result.layer.masksToBounds = true
        result.layer.cornerRadius = 8.86
        return result
    }()
    
    private lazy var copyBChatIdButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.bothGreenColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15.5
        button.setImage(UIImage(named: "ic_Newcopy"), for: .normal)
        button.addTarget(self, action: #selector(copyBChatIdButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var backGroundViewTwo: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.cellGroundColor2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var allMediaLabel: UILabel = {
        let result = UILabel()
        result.text = "All Media"
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var searchLabel: UILabel = {
        let result = UILabel()
        result.text = "Search Conversation"
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var disappearingMessagesLabel: UILabel = {
        let result = UILabel()
        result.text = "Disappearing Messages"
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var disappearingMessagesDiscriptionLabel: UILabel = {
        let result = UILabel()
        result.text = "When enabled, messages between you and person will disappear after they have been seen"
        result.textColor = Colors.bothGrayColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    private lazy var allMediaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_all_media")
        return imageView
    }()
    
    private lazy var searchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_search_setting")
        return imageView
    }()
        
    private lazy var disappearingMessagesImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_disappearing_message")
        return imageView
    }()
    
    lazy var disappearingMessagesSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.greenColor
        toggle.addTarget(self, action: #selector(self.disappearingMessagesSwitchValueChanged(_:)), for: .valueChanged)
        return toggle
    }()
    
    private lazy var backGroundViewThree: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.cellGroundColor2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var messageSoundLabel: UILabel = {
        let result = UILabel()
        result.text = "Message Sound"
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var messageSoundTypeLabel: UILabel = {
        let result = UILabel()
        result.text = "Default"
        result.textColor = Colors.bothGrayColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var messageSoundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_message_sound")
        return imageView
    }()
    
    private lazy var muteLabel: UILabel = {
        let result = UILabel()
        result.text = "Mute"
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var muteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_mute")
        return imageView
    }()
    
    lazy var muteSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.greenColor
        toggle.addTarget(self, action: #selector(self.muteSwitchValueChanged(_:)), for: .valueChanged)
        return toggle
    }()
    
    
    private lazy var backGroundViewFour: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.cellGroundColor2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var blockLabel: UILabel = {
        let result = UILabel()
        result.text = "Block User"
        result.textColor = Colors.bothRedColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var blockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "blocked_contacts")
        return imageView
    }()
    
    private lazy var reportLabel: UILabel = {
        let result = UILabel()
        result.text = "Report Person"
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var reportImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_report")
        return imageView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        self.title = "Settings"
        
        view.addSubViews(backGroundView, backGroundViewTwo, backGroundViewThree, backGroundViewFour)
        
        backGroundView.addSubViews(profilePictureImageView, userNameLabel, bChatLabel, bChatIdLabel, copyBChatIdButton)
        backGroundViewTwo.addSubViews(allMediaImageView, allMediaLabel, searchImageView, searchLabel, disappearingMessagesImageView, disappearingMessagesLabel, disappearingMessagesDiscriptionLabel, disappearingMessagesSwitch)
        backGroundViewThree.addSubViews(messageSoundImageView, messageSoundLabel, messageSoundTypeLabel, muteImageView, muteLabel, muteSwitch)
        backGroundViewFour.addSubViews(blockImageView, blockLabel, reportImageView, reportLabel)
        
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 68),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            profilePictureImageView.widthAnchor.constraint(equalToConstant: 86),
            profilePictureImageView.heightAnchor.constraint(equalToConstant: 86),
            profilePictureImageView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            profilePictureImageView.centerYAnchor.constraint(equalTo: backGroundView.topAnchor),
            userNameLabel.topAnchor.constraint(equalTo: profilePictureImageView.bottomAnchor, constant: 1),
            userNameLabel.centerXAnchor.constraint(equalTo: profilePictureImageView.centerXAnchor),
            bChatLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16.96),
            bChatLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 6.4),
            bChatIdLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 12),
            bChatIdLabel.topAnchor.constraint(equalTo: bChatLabel.bottomAnchor, constant: 6.6),
            bChatIdLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -14),
            copyBChatIdButton.widthAnchor.constraint(equalToConstant: 31),
            copyBChatIdButton.heightAnchor.constraint(equalToConstant: 31),
            copyBChatIdButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -10),
            copyBChatIdButton.centerYAnchor.constraint(equalTo: bChatIdLabel.centerYAnchor),
            bChatIdLabel.trailingAnchor.constraint(equalTo: copyBChatIdButton.leadingAnchor, constant: -8),
            
            
            backGroundViewTwo.topAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: 10),
            backGroundViewTwo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            backGroundViewTwo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            allMediaImageView.widthAnchor.constraint(equalToConstant: 22),
            allMediaImageView.heightAnchor.constraint(equalToConstant: 22),
            allMediaImageView.topAnchor.constraint(equalTo: backGroundViewTwo.topAnchor, constant: 21),
            allMediaImageView.leadingAnchor.constraint(equalTo: backGroundViewTwo.leadingAnchor, constant: 22),
            allMediaLabel.leadingAnchor.constraint(equalTo: allMediaImageView.trailingAnchor, constant: 20),
            allMediaLabel.centerYAnchor.constraint(equalTo: allMediaImageView.centerYAnchor),
            searchImageView.widthAnchor.constraint(equalToConstant: 20),
            searchImageView.heightAnchor.constraint(equalToConstant: 20),
            searchImageView.topAnchor.constraint(equalTo: allMediaImageView.bottomAnchor, constant: 21),
            searchImageView.leadingAnchor.constraint(equalTo: backGroundViewTwo.leadingAnchor, constant: 23),
            searchLabel.leadingAnchor.constraint(equalTo: searchImageView.trailingAnchor, constant: 21),
            searchLabel.centerYAnchor.constraint(equalTo: searchImageView.centerYAnchor),
            disappearingMessagesLabel.topAnchor.constraint(equalTo: searchLabel.bottomAnchor, constant: 20),
            disappearingMessagesDiscriptionLabel.topAnchor.constraint(equalTo: disappearingMessagesLabel.bottomAnchor, constant: 5.14),
            disappearingMessagesImageView.widthAnchor.constraint(equalToConstant: 18),
            disappearingMessagesImageView.heightAnchor.constraint(equalToConstant: 18.48),
            disappearingMessagesImageView.topAnchor.constraint(equalTo: disappearingMessagesLabel.topAnchor, constant: 20),
            disappearingMessagesImageView.leadingAnchor.constraint(equalTo: backGroundViewTwo.leadingAnchor, constant: 24),
            disappearingMessagesLabel.leadingAnchor.constraint(equalTo: disappearingMessagesImageView.trailingAnchor, constant: 22),
            disappearingMessagesDiscriptionLabel.leadingAnchor.constraint(equalTo: disappearingMessagesLabel.leadingAnchor),
            disappearingMessagesSwitch.topAnchor.constraint(equalTo: disappearingMessagesLabel.topAnchor, constant: 16.71),
            disappearingMessagesSwitch.trailingAnchor.constraint(equalTo: backGroundViewTwo.trailingAnchor, constant: -22.25),
            disappearingMessagesDiscriptionLabel.trailingAnchor.constraint(equalTo: disappearingMessagesSwitch.leadingAnchor, constant: -24.53),
            disappearingMessagesDiscriptionLabel.bottomAnchor.constraint(equalTo: backGroundViewTwo.bottomAnchor, constant: -22.86),
            
            
            backGroundViewThree.topAnchor.constraint(equalTo: backGroundViewTwo.bottomAnchor, constant: 10),
            backGroundViewThree.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            backGroundViewThree.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            messageSoundImageView.widthAnchor.constraint(equalToConstant: 17.78),
            messageSoundImageView.heightAnchor.constraint(equalToConstant: 16),
            messageSoundImageView.topAnchor.constraint(equalTo: backGroundViewThree.topAnchor, constant: 25),
            messageSoundImageView.leadingAnchor.constraint(equalTo: backGroundViewThree.leadingAnchor, constant: 27),
            messageSoundLabel.leadingAnchor.constraint(equalTo: messageSoundImageView.trailingAnchor, constant: 19.22),
            messageSoundLabel.centerYAnchor.constraint(equalTo: messageSoundImageView.centerYAnchor),
            messageSoundTypeLabel.trailingAnchor.constraint(equalTo: backGroundViewThree.trailingAnchor, constant: -24),
            messageSoundTypeLabel.centerYAnchor.constraint(equalTo: messageSoundImageView.centerYAnchor),
            muteImageView.widthAnchor.constraint(equalToConstant: 22),
            muteImageView.heightAnchor.constraint(equalToConstant: 22),
            muteImageView.topAnchor.constraint(equalTo: messageSoundImageView.bottomAnchor, constant: 25),
            muteImageView.leadingAnchor.constraint(equalTo: backGroundViewThree.leadingAnchor, constant: 25),
            muteLabel.leadingAnchor.constraint(equalTo: muteImageView.trailingAnchor, constant: 17),
            muteLabel.centerYAnchor.constraint(equalTo: muteImageView.centerYAnchor),
            muteSwitch.trailingAnchor.constraint(equalTo: backGroundViewThree.trailingAnchor, constant: -20),
            muteSwitch.centerYAnchor.constraint(equalTo: muteImageView.centerYAnchor),
            muteLabel.bottomAnchor.constraint(equalTo: backGroundViewThree.bottomAnchor, constant: -25),
            
            
            backGroundViewFour.topAnchor.constraint(equalTo: backGroundViewThree.bottomAnchor, constant: 10),
            backGroundViewFour.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            backGroundViewFour.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            blockImageView.widthAnchor.constraint(equalToConstant: 18.16),
            blockImageView.heightAnchor.constraint(equalToConstant: 18),
            blockImageView.topAnchor.constraint(equalTo: backGroundViewFour.topAnchor, constant: 28.44),
            blockImageView.leadingAnchor.constraint(equalTo: backGroundViewFour.leadingAnchor, constant: 28.31),
            blockLabel.leadingAnchor.constraint(equalTo: blockImageView.trailingAnchor, constant: 17.53),
            blockLabel.centerYAnchor.constraint(equalTo: blockImageView.centerYAnchor),
            reportImageView.widthAnchor.constraint(equalToConstant: 24),
            reportImageView.heightAnchor.constraint(equalToConstant: 24),
            reportImageView.topAnchor.constraint(equalTo: blockImageView.bottomAnchor, constant: 19.56),
            reportImageView.leadingAnchor.constraint(equalTo: backGroundViewFour.leadingAnchor, constant: 25),
            
            reportLabel.leadingAnchor.constraint(equalTo: reportImageView.trailingAnchor, constant: 15),
            reportLabel.centerYAnchor.constraint(equalTo: reportImageView.centerYAnchor),
            reportLabel.bottomAnchor.constraint(equalTo: backGroundViewFour.bottomAnchor, constant: -24)
        ])
        
    }
    
    
    
    
    
    @objc func copyBChatIdButtonTapped() {
        UIPasteboard.general.string = getUserHexEncodedPublicKey()
        self.showToastMsg(message: NSLocalizedString("BCHAT_ID_COPIED_NEW", comment: ""), seconds: 1.0)
    }
    
    @objc func disappearingMessagesSwitchValueChanged(_ x: UISwitch) {
        
    }
    
    @objc func muteSwitchValueChanged(_ x: UISwitch) {
        
    }
    

}
