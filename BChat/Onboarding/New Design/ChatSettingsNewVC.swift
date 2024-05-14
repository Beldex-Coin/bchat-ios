// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import ContactsUI
import PromiseKit
import Foundation


let kIconViewLength: CGFloat = 24


protocol OWSConversationSettingsViewDelegate: AnyObject {
    func groupWasUpdated(_ groupModel: TSGroupModel)
    func conversationSettingsDidRequestConversationSearch(_ conversationSettingsViewController: ChatSettingsNewVC)
    func popAllConversationSettingsViewsWithCompletion(_ completionBlock: (() -> Void)?)
}


class ChatSettingsNewVC: BaseVC, SheetViewControllerDelegate {
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.cellGroundColor2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var profilePictureImageView = ProfilePictureView()
    
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
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var allMediaButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(allMediaButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var messageSoundButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(messageSoundButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var blockButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
//    var thread: TSThread?
//    var uiDatabaseConnection: YapDatabaseConnection?
////    var editingDatabaseConnection: YapDatabaseConnection?
//    var disappearingMessagesDurations: [NSNumber]?
//    var disappearingMessagesConfiguration: OWSDisappearingMessagesConfiguration?
////    var mediaGallery: MediaGallery?
////    var avatarView: UIImageView
////    var disappearingMessagesDurationLabel: UILabel
////    var displayNameLabel: UILabel
////    var displayNameTextField: TextField
////    var displayNameContainer: UIView
//    var isEditingDisplayName: Bool?
    
    var thread: TSThread?
        var uiDatabaseConnection: YapDatabaseConnection?
//        private(set) var editingDatabaseConnection: YapDatabaseConnection?
        var disappearingMessagesDurations: [NSNumber]?
        var disappearingMessagesConfiguration: OWSDisappearingMessagesConfiguration?
        var mediaGallery: MediaGallery?
        private(set) var avatarView: UIImageView?
        private(set) var disappearingMessagesDurationLabel: UILabel?
        var displayNameLabel: UILabel?
    var displayNameTextField: TextField?
        var displayNameContainer: UIView?
        var isEditingDisplayName: Bool = false
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
          super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
          commonInit()
      }

      required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
          commonInit()
      }

      private func commonInit() {
          observeNotifications()
      }


    
    weak var conversationSettingsViewDelegate: OWSConversationSettingsViewDelegate?

        var showVerificationOnAppear: Bool = false

        func configureWithThread(thread: TSThread, uiDatabaseConnection: YapDatabaseConnection) {
            self.thread = thread
            self.uiDatabaseConnection = uiDatabaseConnection
        }

    
    func tsAccountManager() -> TSAccountManager? {
        return SSKEnvironment.shared.tsAccountManager
    }
    
    func profileManager() -> OWSProfileManager? {
        return OWSProfileManager.shared()
    }
    
    
    func observeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(identityStateDidChange(_:)), name: Notification.Name(rawValue: "kNSNotificationName_IdentityStateDidChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(otherUsersProfileDidChange(_:)), name: Notification.Name(rawValue: "kNSNotificationName_OtherUsersProfileDidChange"), object: nil)
    }

    
    func editingDatabaseConnection() -> YapDatabaseConnection? {
        return OWSPrimaryStorage.shared().dbReadWriteConnection
    }
    
//    func threadName() -> String? {
//        var threadName = self.thread.name
//        if self.thread is TSContactThread {
//            let thread = self.thread as? TSContactThread
//            return LKStorage.shared.getContactWithBChatID(thread?.contactBChatID).displayName(for: SNContactContextRegular) ?? "Anonymous"
//        } else if threadName.count == 0 && isGroupThread() {
//            threadName = MessageStrings.newGroupDefaultTitle
//        }
//        return threadName
//    }
    
    func isGroupThread() -> Bool {
        return thread is TSGroupThread
    }
    
    func isOpenGroup() -> Bool {
        if isGroupThread() {
            let thread = self.thread as? TSGroupThread
            return thread?.isOpenGroup ?? false
        }
        return false
    }
    
    func isClosedGroup() -> Bool {
        if isGroupThread() {
            let thread = self.thread as? TSGroupThread
            return thread?.groupModel.groupType == .closedGroup
        }
        return false
    }
    
    
    func configure(with thread: TSThread?, uiDatabaseConnection: YapDatabaseConnection?) {
        self.thread = thread
        self.uiDatabaseConnection = uiDatabaseConnection
    }

    func didFinishEditingContact() {
//        updateTableContents()
        dismiss(animated: false)
    }
    
//    func contactViewController(
//        _ viewController: CNContactViewController,
//        didCompleteWith contact: CNContact?
//    ) {
////        updateTableContents()
//
//        if contact {
//            dismiss(animated: false)
//        } else {
//            dismiss(animated: true)
//        }
//
//    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        self.title = "Settings"
        
        view.addSubViews(backGroundView, backGroundViewTwo, backGroundViewThree, backGroundViewFour)
        
        backGroundView.addSubViews(profilePictureImageView, userNameLabel, bChatLabel, bChatIdLabel, copyBChatIdButton)
        backGroundViewTwo.addSubViews(allMediaImageView, allMediaLabel, searchImageView, searchLabel, disappearingMessagesImageView, disappearingMessagesLabel, disappearingMessagesDiscriptionLabel, disappearingMessagesSwitch)
        backGroundViewThree.addSubViews(messageSoundImageView, messageSoundLabel, messageSoundTypeLabel, muteImageView, muteLabel, muteSwitch)
        backGroundViewFour.addSubViews(blockImageView, blockLabel, reportImageView, reportLabel)
        
        
        
        let profilePictureTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showProfilePicture(_:)))
        let size = CGFloat(86)
        profilePictureImageView.set(.width, to: size)
        profilePictureImageView.set(.height, to: size)
        profilePictureImageView.size = size
        profilePictureImageView.layer.masksToBounds = true
        profilePictureImageView.layer.cornerRadius = 43
        profilePictureImageView.addGestureRecognizer(profilePictureTapGestureRecognizer)
        
        profilePictureImageView.update(for: self.thread!)

        
        
        
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
    
    
    
    
    
//    func updateDisappearingMessagesDurationLabel() {
//        if disappearingMessagesConfiguration!.isEnabled {
//            let keepForFormat = "Disappear after %@"
//            disappearingMessagesDurationLabel.text = String(format: keepForFormat, disappearingMessagesConfiguration.durationString)
//        } else {
//            disappearingMessagesDurationLabel.text = NSLocalizedString("KEEP_MESSAGES_FOREVER", comment: "Slider label when disappearing messages is off")
//        }
//
//        disappearingMessagesDurationLabel.setNeedsLayout()
//        disappearingMessagesDurationLabel.superview.setNeedsLayout()
//    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if disappearingMessagesConfiguration!.isNewRecord && !disappearingMessagesConfiguration!.isEnabled {
            // don't save defaults, else we'll unintentionally save the configuration and notify the contact.
            return
        }
        
        
        if disappearingMessagesConfiguration!.dictionaryValueDidChange {
            Storage.write() { [self] transaction in
                disappearingMessagesConfiguration!.save(with: transaction as! YapDatabaseReadWriteTransaction)

                let infoMessage = OWSDisappearingConfigurationUpdateInfoMessage(
                    timestamp: NSDate.ows_millisecondTimeStamp(),
                    thread: thread!,
                    configuration: disappearingMessagesConfiguration!,
                    createdByRemoteName: nil,
                    createdInExistingGroup: false)
                infoMessage.save(with: transaction as! YapDatabaseReadWriteTransaction )
                
                let expirationTimerUpdate = ExpirationTimerUpdate()
                let isEnabled = disappearingMessagesConfiguration!.isEnabled
                expirationTimerUpdate.duration = isEnabled ? disappearingMessagesConfiguration!.durationSeconds : 0
                MessageSender.send(expirationTimerUpdate, in: thread!, using: transaction)

            }
        }
        
        
    }
    
    
    func copyBChatID() {
        UIPasteboard.general.string = (thread as! TSContactThread).contactBChatID()
        let toast = UIAlertController(title: nil, message: "Your BChat ID copied to clipboard", preferredStyle: .alert)
        present(toast, animated: true)
                                                                             
        let duration = Int(1.0)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Double(duration) * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            toast.dismiss(animated: true)
        })
    }
    
    
    func notify(forMentionsOnlySwitchValueDidChange sender: Any?) {
        let uiSwitch = sender as? UISwitch
        let isEnabled = uiSwitch?.isOn ?? false
        Storage.write() { [self] transaction in
            (thread as? TSGroupThread)?.setIsOnlyNotifyingForMentions(isEnabled, with: transaction)
        }
    }
    
    
    func editGroup() {
        let editSecretGroupVC = EditSecretGroupVC(with: thread!.uniqueId!)
        navigationController?.pushViewController(editSecretGroupVC, animated: true, completion: nil)
    }
    
    func hasLeftGroup() -> Bool {
        if isGroupThread() {
            let groupThread = thread as? TSGroupThread
            return !groupThread!.isCurrentUserMemberInGroup()
        }
        return false
    }
    
    func leaveGroup() {
        let gThread = thread as? TSGroupThread
        if gThread!.isClosedGroup {
            let groupPublicKey = LKGroupUtilities.getDecodedGroupID(gThread!.groupModel.groupId)
            Storage.writeSync() { transaction in
                MessageSender.objc_leave(groupPublicKey, using: transaction).retainUntilComplete()
            }
        }

        navigationController?.popViewController(animated: true)
    }
    
    
    func disappearingMessagesSwitchValueDidChange(_ sender: UISwitch?) {
        let disappearingMessagesSwitch = sender

//        toggleDisappearingMessages(disappearingMessagesSwitch?.isOn)

//        updateTableContents()
    }
    
    func handleMuteSwitchToggled(_ sender: Any?) {
        let uiSwitch = sender as? UISwitch
        if uiSwitch?.isOn ?? false {
            Storage.write() { [self] transaction in
                thread!.updateWithMuted(until: Date.distantFuture, transaction: transaction)
            }
        } else {
            Storage.write() { [self] transaction in
                thread!.updateWithMuted(until: nil, transaction: transaction)
            }
        }
    }
    
    func showMediaGallery() {
        print("")

        let mediaGallery = MediaGallery(thread: self.thread!, options: .sliderEnabled)
        self.mediaGallery = mediaGallery

        assert(self.navigationController is OWSNavigationController)
        mediaGallery.pushTileView(fromNavController: self.navigationController as! OWSNavigationController)
    }
    
    func tappedConversationSearch() {
        conversationSettingsViewDelegate?.conversationSettingsDidRequestConversationSearch(self)
    }
    
    
    @objc func showProfilePicture(_ tapGesture: UITapGestureRecognizer) {
        guard let profilePictureView = tapGesture.view as? ProfilePictureView,
              let image = profilePictureView.getProfilePicture() else {
            return
        }
        
//        let title = (threadName?.isEmpty == false) ? threadName : "Anonymous"
//        let profilePictureVC = ProfilePictureVC(image: image, title: title)
//        let navController = UINavigationController(rootViewController: profilePictureVC)
//        navController.modalPresentationStyle = .fullScreen
//        present(navController, animated: true, completion: nil)
    }

    func sheetViewControllerRequestedDismiss(_ sheetViewController: SheetViewController?) {
        dismiss(animated: true)
    }
    
    func hideEditNameUI() {
        isEditingDisplayName = false
    }

    func showEditNameUI() {
        isEditingDisplayName = true
    }
    
    
//    func setIsEditingDisplayName(_ isEditingDisplayName: Bool) {
//        self.isEditingDisplayName = isEditingDisplayName
//
//        UIView.animate(withDuration: 0.25, animations: { [self] in
//            displayNameLabel.alpha = self.isEditingDisplayName ? 0 : 1
//            displayNameTextField.alpha = self.isEditingDisplayName ? 1 : 0
//        })
//
//        if isEditingDisplayName {
//            displayNameTextField.becomeFirstResponder()
//        } else {
//            displayNameTextField.resignFirstResponder()
//        }
//
//    }
    
    
    
//    func saveName() {
//        if !(thread is TSContactThread) {
//            return
//        }
//        let bchatID = (thread as? TSContactThread)?.contactBChatID
//        var contact = Storage.shared.getContactWithBChatID(bchatID)
//        if contact == nil {
//            contact = SNContact(bchatID: bchatID)
//        }
//        let text = displayNameTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
//        contact.nickname = text.count > 0 ? text : nil
//        LKStorage.write() { transaction in
//            LKStorage.shared.setContact(contact, using: transaction)
//        }
//        displayNameLabel.text = text.count > 0 ? text : contact.name
//        hideEditNameUI()
//
//    }
    
    
    
    @objc func copyBChatIdButtonTapped() {
        self.copyBChatID()
    }
    
    @objc func disappearingMessagesSwitchValueChanged(_ x: UISwitch) {
        
    }
    
    @objc func muteSwitchValueChanged(_ x: UISwitch) {
        let uiSwitch = x
        if uiSwitch.isOn {
            Storage.write() { [self] transaction in
                self.thread!.updateWithMuted(until: Date.distantFuture, transaction: transaction)
            }
        } else {
            Storage.write() { [self] transaction in
                self.thread!.updateWithMuted(until: nil, transaction: transaction)
            }
        }
    }
    
    @objc private func searchButtonTapped(_ sender: UIButton) {
        self.tappedConversationSearch()
    }
    
    @objc private func allMediaButtonTapped(_ sender: UIButton) {
        self.showMediaGallery()
    }
    
    @objc private func messageSoundButtonTapped(_ sender: UIButton) {
        let vc = OWSSoundSettingsViewController()
        vc.thread = self.thread
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func blockButtonTapped(_ sender: UIButton) {
        
    }
    
    @objc private func reportButtonTapped(_ sender: UIButton) {
        
    }
    
    
    // MARK: - Notification Observers -
    
    @objc func identityStateDidChange(_ notification: Notification) {
//        updateTableContents()
    }
    
    @objc func otherUsersProfileDidChange(_ notification: Notification) {
        let recipientId = notification.userInfo![kNSNotificationKey_ProfileRecipientId] as? String
        if (recipientId?.count ?? 0) > 0 && (thread is TSContactThread) && ((thread as? TSContactThread)!.contactBChatID() == recipientId) {
//            updateTableContents()
        }
    }

}
