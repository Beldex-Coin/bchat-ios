// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import ContactsUI
import PromiseKit
import Foundation
import BChatUtilitiesKit
import BChatMessagingKit


enum DocumentContentType : String {
    case mswordDocument = "application/msword"
    case pdfDocument = "application/pdf"
    case textDocument = "text/plain"
}


let kIconViewLength: CGFloat = 24


protocol OWSConversationSettingsViewDelegate: AnyObject {
    func groupWasUpdated(_ groupModel: TSGroupModel)
    func conversationSettingsDidRequestConversationSearch(_ conversationSettingsViewController: ChatSettingsVC)
    func popAllConversationSettingsViewsWithCompletion(_ completionBlock: (() -> Void)?)
}


class ChatSettingsVC: BaseVC, SheetViewControllerDelegate {
    
    
    private lazy var profilePictureImageView = ProfilePictureView()
    
    lazy var secretGroupImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 25)
        result.set(.height, to: 25)
        result.contentMode = .scaleAspectFill
        result.image = UIImage(named: "ic_secretGroupSmall")
        return result
    }()
    
    private lazy var bnsApprovalIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "ic_Bns_Approval_icon", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    private lazy var displayNameLabel: UILabel = {
        let result = UILabel()
        result.text = ""
        result.textColor = Colors.titleColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 1
        return result
    }()
    
    private lazy var nameTextField: UITextField = {
        let result = UITextField()
        let attributes = [
            NSAttributedString.Key.foregroundColor: Colors.titleColor,
            NSAttributedString.Key.font: Fonts.OpenSans(ofSize: 18)
        ]
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("Display name", comment: ""), attributes: attributes)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.backgroundColor = .clear
        result.textAlignment = .center
        
        return result
    }()
    
    private lazy var editIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "chatSetting_edit")
        return imageView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.layer.cornerRadius = 14
        return t
    }()
    
    
    var socialGroupTitleArray = ["All Media", "Add Members", "Search Conversation", "Message Sound", "Notify for Mentions Only", "Mute"]
    var socialGroupLeftImageArray = ["ic_allmedia", "chatSettings_addmember", "ic_search_settingnew", "ic_message_sound", "chatSetting_notify", "chatSetting_mute"]
    
    var noteToSelfTitleArray = ["", "All Media", "Search Conversation"]
    var noteToSelfImageArray = ["bchat_chat_setting", "ic_allmedia", "ic_search_settingnew", "ic_disappearing_setting"]
    
    var contactTitleArray = ["", "All Media", "Search Conversation", "Disappearing Messgaess", "Message Sound", "Mute", "Block This User", "Report Name"]
    var contactImageArray = ["bchat_chat_setting", "ic_allmedia", "ic_search_settingnew", "ic_disappearing_setting", "ic_message_sound", "chatSetting_mute", "chatSetting_block", "chatSetting_report"]
    
    var closeGroupTitleArray = ["All Media", "Search Conversation", "Disappearing Messgaess", "Edit Group", "Message Sound", "Notify for Mentions Only", "Mute", "Leave Group"]
    var closeGroupImageArray = ["ic_allmedia", "ic_search_settingnew", "ic_disappearing_setting", "chatSetting_editGroup", "ic_message_sound", "chatSetting_notify", "chatSetting_mute", "chatSetting_leaveGroup"]
    
    
    
    var thread: TSThread?
    var viewItems: [ConversationViewItem]?
    var uiDatabaseConnection: YapDatabaseConnection?
    var disappearingMessagesDurations: [NSNumber]?
    var disappearingMessagesConfiguration: OWSDisappearingMessagesConfiguration?
    var mediaGallery: MediaGallery?
    private(set) var avatarView: UIImageView?
    var displayNameTextField: TextField?
    var displayNameContainer: UIView?
    var isEditingDisplayName: Bool = false
    
    var sliderDurationText = ""
    
    weak var conversationSettingsViewDelegate: OWSConversationSettingsViewDelegate?
    
    var showVerificationOnAppear: Bool = false
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        self.title = ""
        
        if self.thread!.isKind(of: TSContactThread.self) {
            self.title = "Contact Info"
        } else {
            self.title = "Group Info"
        }
        if self.thread?.isNoteToSelf() == true {
            self.title = "Note to self"
        }
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.OpenSans(ofSize: 16),
            .foregroundColor: Colors.titleColor
        ]
        let attributedPlaceholder = NSAttributedString(string: "Display name", attributes: placeholderAttributes)
        nameTextField.attributedPlaceholder = attributedPlaceholder
        nameTextField.font = Fonts.boldOpenSans(ofSize: 18)
        setUpTopCornerRadius()
        view.addSubViews(profilePictureImageView, secretGroupImageView, displayNameLabel, tableView, doneButton, nameTextField, editIconImage, bnsApprovalIconImage)
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        tableView.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 25.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(CustomChatSettingsTableViewCell.self, forCellReuseIdentifier: "CustomChatSettingsTableViewCell")
        tableView.register(NotifyChatSettingsTableViewCell.self, forCellReuseIdentifier: "NotifyChatSettingsTableViewCell")
        tableView.register(DisappearingChatSettingsTableViewCell.self, forCellReuseIdentifier: "DisappearingChatSettingsTableViewCell")
        tableView.backgroundColor = Colors.cellGroundColor
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        
        let profilePictureTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showProfilePicture(_:)))
        let size = CGFloat(86)
        profilePictureImageView.set(.width, to: size)
        profilePictureImageView.set(.height, to: size)
        profilePictureImageView.size = size
        profilePictureImageView.layer.masksToBounds = true
        profilePictureImageView.layer.cornerRadius = 43
        profilePictureImageView.addGestureRecognizer(profilePictureTapGestureRecognizer)
        
        profilePictureImageView.update(for: self.thread!)
        
        self.displayNameLabel.text = (self.threadName()!.count > 0) ? self.threadName()! : "Anonymous"
        self.displayNameLabel.isHidden = true
        self.nameTextField.text = (self.threadName()!.count > 0) ? self.threadName()! : "Anonymous"
        
        
        NSLayoutConstraint.activate([
            profilePictureImageView.widthAnchor.constraint(equalToConstant: 86),
            profilePictureImageView.heightAnchor.constraint(equalToConstant: 86),
            profilePictureImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            profilePictureImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            secretGroupImageView.trailingAnchor.constraint(equalTo: profilePictureImageView.trailingAnchor, constant: 2),
            secretGroupImageView.bottomAnchor.constraint(equalTo: profilePictureImageView.bottomAnchor, constant: 2),
            
            bnsApprovalIconImage.trailingAnchor.constraint(equalTo: profilePictureImageView.trailingAnchor, constant: -1),
            bnsApprovalIconImage.bottomAnchor.constraint(equalTo: profilePictureImageView.bottomAnchor, constant: 9),
            bnsApprovalIconImage.widthAnchor.constraint(equalToConstant: 34),
            bnsApprovalIconImage.heightAnchor.constraint(equalToConstant: 34),
            
            displayNameLabel.topAnchor.constraint(equalTo: profilePictureImageView.bottomAnchor, constant: 8),
            displayNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            displayNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 12),
            displayNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -12),
            nameTextField.topAnchor.constraint(equalTo: profilePictureImageView.bottomAnchor, constant: 8),
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 12),
            nameTextField.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -12),
            
            editIconImage.widthAnchor.constraint(equalToConstant: 14),
            editIconImage.heightAnchor.constraint(equalToConstant: 14),
            editIconImage.leadingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor, constant: 4),
            editIconImage.centerYAnchor.constraint(equalTo: displayNameLabel.centerYAnchor),
            
            doneButton.widthAnchor.constraint(equalToConstant: 66.7),
            doneButton.heightAnchor.constraint(equalToConstant: 26),
            doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.3),
        ])
        
        self.disappearingMessagesDurations = OWSDisappearingMessagesConfiguration.validDurationsSeconds()
        self.disappearingMessagesConfiguration = OWSDisappearingMessagesConfiguration.fetch(uniqueId: self.thread!.uniqueId!)
        if self.disappearingMessagesConfiguration == nil {
            self.disappearingMessagesConfiguration = OWSDisappearingMessagesConfiguration(uniqueId: self.thread!.uniqueId)
        }
        
        self.doneButton.isHidden = true
        if self.thread!.isKind(of: TSContactThread.self) {
            self.nameTextField.isUserInteractionEnabled = true
            self.editIconImage.isHidden = false
        } else {
            self.nameTextField.isUserInteractionEnabled = false
            self.editIconImage.isHidden = true
        }
        if self.thread?.isNoteToSelf() == true {
            self.nameTextField.isUserInteractionEnabled = false
            self.editIconImage.isHidden = true
        }
        
        nameTextField.addTarget(self, action: #selector(nameTextfieldTapped), for: UIControl.Event.touchDown)
        
        if let groupThread = self.thread as? TSGroupThread {
            if !groupThread.isCurrentUserMemberInGroup() {
                closeGroupTitleArray.removeLast()
            }
        }
        bnsApprovalIconImage.isHidden = true
        if let contactThread = self.thread as? TSContactThread {
            let publicKey = contactThread.contactBChatID()
            let contact: Contact? = Storage.shared.getContact(with: publicKey)
            if let _ = contact, let isBnsUser = contact?.isBnsHolder {
                profilePictureImageView.layer.borderWidth = isBnsUser ? Values.borderThickness : 0
                profilePictureImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
                bnsApprovalIconImage.isHidden = isBnsUser ? false : true
            }
        }
        
        secretGroupImageView.isHidden = true
        if self.isClosedGroup() {
            secretGroupImageView.isHidden = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(leaveGroupTapped), name: .LeaveGroupNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllDcouments()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if (disappearingMessagesConfiguration!.isNewRecord && !disappearingMessagesConfiguration!.isEnabled) {
            // don't save defaults, else we'll unintentionally save the configuration and notify the contact.
            return
        }
        
        // Initial default is 0 second for disappearslider
        if self.disappearingMessagesConfiguration!.durationString == "0 seconds" {
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
    
    private func commonInit() {
        observeNotifications()
    }
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(userBlockContactTapped), name: .blockContactNotification, object: nil)
    }
    
    func editingDatabaseConnection() -> YapDatabaseConnection? {
        return OWSPrimaryStorage.shared().dbReadWriteConnection
    }
    
    func threadName() -> String? {
        var threadName = self.thread?.name()
        if self.thread is TSContactThread {
            let thread = self.thread as? TSContactThread
            return Storage.shared.getContact(with: thread!.contactBChatID())?.displayName(for: Contact.Context.regular) ?? "Anonymous"
        } else if threadName!.count == 0 && isGroupThread() {
            threadName = MessageStrings.newGroupDefaultTitle
        }
        return threadName
    }
    
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
    
    
    func configure(with thread: TSThread?, viewItems: [ConversationViewItem]?, uiDatabaseConnection: YapDatabaseConnection?) {
        self.thread = thread
        self.viewItems = viewItems
        self.uiDatabaseConnection = uiDatabaseConnection
        
        getAllDcouments()
    }
    
    func didFinishEditingContact() {
        self.tableView.reloadData()
        dismiss(animated: false)
    }
    
    func contactViewController(
        _ viewController: CNContactViewController,
        didCompleteWith contact: CNContact?
    ) {
        self.tableView.reloadData()
        if (contact != nil) {
            dismiss(animated: false)
        } else {
            dismiss(animated: true)
        }
        
    }
    
    func adjustTableViewHeight() {
        tableView.layoutIfNeeded()
        var totalHeight: CGFloat = 0
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if let cell = tableView.cellForRow(at: indexPath) {
                    totalHeight += cell.frame.height
                }
            }
        }
        tableView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
    }
    
    func inviteUsersToOpenGroup() {
        guard let threadID = self.thread?.uniqueId else {
            return
        }
        
        guard let openGroup = Storage.shared.getV2OpenGroup(for: threadID) else {
            return
        }
        
        let url = "\(openGroup.server)/\(openGroup.room)?public_key=\(openGroup.publicKey)"
        
        let userSelectionVC = UserSelectionVC(with: NSLocalizedString("vc_conversation_settings_invite_button_title", comment: ""),
                                              excluding: Set<String>(),
                                              completion: { selectedUsers in
            for user in selectedUsers {
                let message = VisibleMessage()
                message.sentTimestamp = NSDate.millisecondTimestamp()
                //                message.openGroupInvitation = OpenGroupInvitation(name: openGroup.name, url: url)
                let invitation = VisibleMessage.OpenGroupInvitation(name: openGroup.name, url: url)
                message.openGroupInvitation = invitation
                
                let thread = TSContactThread.getOrCreateThread(contactBChatID: user)
                let tsMessage = TSOutgoingMessage.from(message, associatedWith: thread)
                Storage.write { transaction in
                    tsMessage.save(with: transaction)
                }
                Storage.write { transaction in
                    MessageSender.send(message, in: thread, using: transaction)
                }
            }
        })
        
        navigationController?.pushViewController(userSelectionVC, animated: true)
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
    
    @objc func nameTextfieldTapped(textField: UITextField) {
        self.doneButton.isHidden = false
        self.editIconImage.isHidden = true
        // While edit name for clear text
//        self.nameTextField.text = ""
    }
    
    @objc func notifyforMentionsOnlySwitchValueDidChange(_ sender: UISwitch) {
        let uiSwitch = sender
        let isEnabled = uiSwitch.isOn
        Storage.write() { [self] transaction in
            (thread as? TSGroupThread)?.setIsOnlyNotifyingForMentions(isEnabled, with: transaction)
        }
        self.tableView.reloadData()
    }
    
    @objc func disAppearSwitchValueDidChange(_ sender: UISwitch) {
        let disappearingMessagesSwitch = sender
        self.toggleDisappearingMessages(disappearingMessagesSwitch.isOn)
        self.tableView.reloadData()
    }
    
    func toggleDisappearingMessages(_ flag: Bool) {
        self.disappearingMessagesConfiguration?.isEnabled = flag
        self.tableView.reloadData()
    }
    
    
    @objc func handleMuteSwitchToggled(_ sender: UISwitch) {
        let uiSwitch = sender
        if uiSwitch.isOn {
            Storage.write() { [self] transaction in
                thread!.updateWithMuted(until: Date.distantFuture, transaction: transaction)
            }
        } else {
            Storage.write() { [self] transaction in
                thread!.updateWithMuted(until: nil, transaction: transaction)
            }
        }
        self.tableView.reloadData()
    }
    
    
    
    func editGroup() {
        let editSecretGroupVC = EditGroupViewController(with: thread!.uniqueId!)
        navigationController?.pushViewController(editSecretGroupVC, animated: true, completion: nil)
    }
    
    
    func didTapLeaveGroup() {
        guard let groupThread = self.thread as? TSGroupThread else {
            return
        }
        
        let userPublicKey = GeneralUtilities.getUserPublicKey()
        var message: String
        
        if groupThread.groupModel.groupAdminIds.contains(userPublicKey) {
            message = NSLocalizedString("Because you are the creator of this group it will be deleted for everyone. This cannot be undone.", comment: "")
        } else {
            message = NSLocalizedString("CONFIRM_LEAVE_GROUP_DESCRIPTION", comment: "Alert body")
        }
        
        let vc = LeaveGroupPopUp()
        vc.message = message
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
        
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
    
    
    @objc func durationSliderDidChange(_ slider: UISlider) {
        let index = Int(slider.value + 0.5)
        slider.setValue(Float(index), animated: true)
        
        let numberOfSeconds = self.disappearingMessagesDurations![index]
        self.disappearingMessagesConfiguration!.durationSeconds = UInt32(numberOfSeconds.uintValue)
        
        if self.disappearingMessagesConfiguration!.isEnabled {
            let keepForFormat = NSLocalizedString("Disappear after %@", comment: "Format for disappearing messages duration label")
            self.sliderDurationText = String(format: keepForFormat, self.disappearingMessagesConfiguration!.durationString)
        } else {
            self.sliderDurationText = NSLocalizedString("KEEP_MESSAGES_FOREVER", comment: "Slider label when disappearing messages is off")
        }
        self.tableView.reloadData()
    }
    
    func disappearingMessagesSwitchValueDidChange(_ sender: UISwitch?) {
        let disappearingMessagesSwitch = sender
        self.tableView.reloadData()
        
    }
    
    func showMediaGallery() {
        let mediaGallery = MediaGallery(thread: self.thread!, options: .sliderEnabled, isFromChatSettings: true, viewItems: self.viewItems ?? [])
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
        
        let title = ((threadName()!.isEmpty == false) ? threadName() : "Anonymous")!
        let profilePictureVC = ProfilePictureVC(image: image, title: title)
        let navController = UINavigationController(rootViewController: profilePictureVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
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
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        self.saveName()
    }
    
    func saveName() {
        guard let thread = self.thread as? TSContactThread else { return }
        
        let bchatID = thread.contactBChatID
        var contact = Storage.shared.getContact(with: bchatID())
        
        if contact == nil {
            contact = Contact(bchatID: bchatID())
        }
        
        let text = self.nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else {
            return showError(title: NSLocalizedString("vc_settings_display_name_missing_error", comment: ""))
        }
        guard !OWSProfileManager.shared().isProfileNameTooLong(text) else {
            return showError(title: NSLocalizedString("vc_settings_display_name_too_long_error", comment: ""))
        }
        contact?.nickname = text.isEmpty ? nil : text
        Storage.write { transaction in
            if let contact = contact {
                Storage.shared.setContact(contact, using: transaction)
            }
        }
        self.displayNameLabel.text = text.isEmpty ? contact?.name : text
        self.nameTextField.text = text.isEmpty ? contact?.name : text
        self.doneButton.isHidden = true
        self.editIconImage.isHidden = false
    }
    
    @objc func leaveGroupTapped() {
        leaveGroup()
    }
    
    
    // MARK: - Notification Observers -
    
    @objc func identityStateDidChange(_ notification: Notification) {
        self.tableView.reloadData()
    }
    
    @objc func otherUsersProfileDidChange(_ notification: Notification) {
        let recipientId = notification.userInfo![kNSNotificationKey_ProfileRecipientId] as? String
        if (recipientId?.count ?? 0) > 0 && (thread is TSContactThread) && ((thread as? TSContactThread)!.contactBChatID() == recipientId) {
            self.tableView.reloadData()
        }
    }
    
    func showError(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
        presentAlert(alert)
    }
    
    // Block and UnBlock the Contact
    @objc func userBlockContactTapped(_ notification: Notification) {
        if let contactThread = self.thread as? TSContactThread {
            let isCurrentlyBlocked = contactThread.isBlocked()
            if !isCurrentlyBlocked {
                guard let thread = thread as? TSContactThread else { return }
                let publicKey = thread.contactBChatID()
                if let contact: Contact = Storage.shared.getContact(with: publicKey) {
                    Storage.shared.write(
                        with: { transaction in
                            guard let transaction = transaction as? YapDatabaseReadWriteTransaction else { return }
                            
                            contact.isBlocked = true
                            Storage.shared.setContact(contact, using: transaction)
                        },
                        completion: {
                            MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                        }
                    )
                    self.tableView.reloadData()
                }
            } else {
                guard let thread = thread as? TSContactThread else { return }
                let publicKey = thread.contactBChatID()
                if let contact: Contact = Storage.shared.getContact(with: publicKey) {
                    Storage.shared.write(
                        with: { transaction in
                            guard let transaction = transaction as? YapDatabaseReadWriteTransaction else { return }
                            
                            contact.isBlocked = false
                            Storage.shared.setContact(contact, using: transaction)
                        },
                        completion: {
                            MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                        }
                    )
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func getAllDcouments() {
        UserDefaults.standard.removeObject(forKey: Constants.attachedDocuments)
        
        var deletedDocuments: [Document] = []
        if let objects = UserDefaults.standard.value(forKey: Constants.deleteAttachedDocuments) as? Data {
            let decoder = JSONDecoder()
            if let documentsDecoded = try? decoder.decode([Document].self, from: objects) as [Document] {
                deletedDocuments = documentsDecoded
            }
            deletedDocuments.forEach { document in
                debugPrint("document contentType **** \(document.contentType) timestamp **** \(document.createdTimeStamp)")
            }
        }
        
        var allAttachments: [TSAttachmentStream] = []
        var documents: [Document] = []
        guard let theViewItems = viewItems else { return }
        theViewItems.forEach { viewItem in
            if let message = viewItem.interaction as? TSMessage {
                Storage.read { transaction in
                    message.attachmentIds.forEach { attachmentID in
                        guard let attachmentID = attachmentID as? String else { return }
                        let attachment = TSAttachment.fetch(uniqueId: attachmentID, transaction: transaction)
                        guard let stream = attachment as? TSAttachmentStream else { return }
                        allAttachments.append(stream) //appending all attachments
                        
                        if stream.contentType == DocumentContentType.mswordDocument.rawValue || stream.contentType == DocumentContentType.pdfDocument.rawValue || stream.contentType == DocumentContentType.textDocument.rawValue {
                            
                            if !deletedDocuments.isEmpty {
                                for document in deletedDocuments {
                                    if document.documentId == attachmentID {
                                        self.deleteLocally(viewItem)
                                    }
                                }
                            }
                            
                            guard let filePath = stream.originalFilePath, let mediaUrl = stream.originalMediaURL else { return }
                            let theDocument = Document(contentType: stream.contentType,
                                                       originalFilePath: filePath,
                                                       originalMediaURL: mediaUrl,
                                                       createdTimeStamp: stream.creationTimestamp,
                                                       documentId: attachmentID)
                            documents.append(theDocument) //appending only documents
                        }
                    }
                }
            }
        }
        if !documents.isEmpty {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(documents) {
                UserDefaults.standard.set(encoded, forKey: Constants.attachedDocuments)
            }
        }
    }
    
    func deleteLocally(_ viewItem: ConversationViewItem) {
        viewItem.deleteLocallyAction()
        if let unsendRequest = buildUnsendRequest(viewItem) {
            SNMessagingKitConfiguration.shared.storage.write { transaction in
                MessageSender.send(unsendRequest, to: .contact(publicKey: getUserHexEncodedPublicKey()), using: transaction).retainUntilComplete()
            }
        }
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
    
    
}


extension ChatSettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isOpenGroup() {
            return self.socialGroupTitleArray.count
        } else if self.thread!.isNoteToSelf() {
            return self.noteToSelfTitleArray.count
        } else if self.thread!.isKind(of: TSContactThread.self) {
            return self.contactTitleArray.count
        } else if self.isClosedGroup() {
            return self.closeGroupTitleArray.count
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.isOpenGroup() {
            if indexPath.row == 4 {
                return 84
            }
        }
        
        if self.thread!.isNoteToSelf() {
            if indexPath.row == 0 {
                return 65
            }
            if indexPath.row == 3 {
                if self.disappearingMessagesConfiguration?.isEnabled ?? false {
                    return 98 + 21 + 26 + 26
                } else {
                    return 98
                }
            }
        }
        
        if self.thread!.isKind(of: TSContactThread.self) {
            if indexPath.row == 0 {
                return 65
            }
            if indexPath.row == 3 {
                if self.disappearingMessagesConfiguration?.isEnabled ?? false {
                    return 98 + 21 + 26 + 26
                } else {
                    return 98
                }
            }
        }
        
        if self.isClosedGroup() {
            if indexPath.row == 2 {
                if self.disappearingMessagesConfiguration?.isEnabled ?? false {
                    return 98 + 21 + 26 + 26
                } else {
                    return 98
                }
            }
            if indexPath.row == 5 {
                return 84
            }
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomChatSettingsTableViewCell") as! CustomChatSettingsTableViewCell
        
        if self.isOpenGroup() {  // Social Group
            cell.titleLabel.text = self.socialGroupTitleArray[indexPath.row]
            cell.leftIconImageView.image = UIImage(named: self.socialGroupLeftImageArray[indexPath.row])
            
            if cell.titleLabel.text == "All Media" {
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
            }
            if cell.titleLabel.text == "Add Members" {
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
            }
            if cell.titleLabel.text == "Search Conversation" {
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
            }
            if cell.titleLabel.text == "Message Sound" {
                cell.rightTitleLabel.isHidden = false
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.isHidden = true
            }
            if cell.titleLabel.text == "Notify for Mentions Only" {
                cell.rightSwitch.isHidden = false
                cell.rightIconImageView.isHidden = true
                cell.rightTitleLabel.isHidden = true
            }
            if cell.titleLabel.text == "Mute" {
                cell.rightSwitch.isHidden = false
                cell.rightIconImageView.isHidden = true
                cell.rightTitleLabel.isHidden = true
            }
            
            if indexPath.row == 3 {
                let sound = OWSSounds.notificationSound(for: self.thread!)
                let displayName = OWSSounds.displayName(for: sound)
                cell.rightTitleLabel.text = displayName
            }
            
            if indexPath.row == 5 {
                if let mutedUntilDate = self.thread?.mutedUntilDate {
                    let now = Date()
                    cell.rightSwitch.isOn = mutedUntilDate.timeIntervalSince(now) > 0
                } else {
                    cell.rightSwitch.isOn = false
                }
                if cell.rightSwitch.isOn {
                    cell.rightSwitch.thumbTintColor = Colors.bothGreenColor
                } else {
                    cell.rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
                }
                cell.rightSwitch.addTarget(self, action: #selector(handleMuteSwitchToggled(_:)), for: .valueChanged)
            }
            
            if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotifyChatSettingsTableViewCell") as! NotifyChatSettingsTableViewCell
                cell.leftIconImageView.image = UIImage(named: "chatSetting_notify")
                cell.titleLabel.text = "Notify for Mentions Only"
                cell.discriptionLabel.text = "When enabled,you’ll only be notified for messages mentioning you."
                let groupThread = self.thread as? TSGroupThread
                let isOnlyNotifyingForMentions = groupThread?.isOnlyNotifyingForMentions ?? false
                cell.rightSwitch.isOn = isOnlyNotifyingForMentions
                
                if cell.rightSwitch.isOn {
                    cell.rightSwitch.thumbTintColor = Colors.bothGreenColor
                } else {
                    cell.rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
                }
                cell.rightSwitch.addTarget(self, action: #selector(notifyforMentionsOnlySwitchValueDidChange(_:)), for: .valueChanged)
                
                return cell
                
            }
            
        }
        
        
        // Note to self
        if self.thread!.isNoteToSelf() {
            cell.titleLabel.text = self.noteToSelfTitleArray[indexPath.row]
            cell.leftIconImageView.image = UIImage(named: self.noteToSelfImageArray[indexPath.row])
            
            if indexPath.row == 0 {
                cell.titleLabel.text = (thread as! TSContactThread).contactBChatID()
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.image = UIImage(named: "chat_setting_copy")
                cell.titleLabel.font = Fonts.OpenSans(ofSize: 12)
            } else {
                cell.titleLabel.font = Fonts.OpenSans(ofSize: 16)
            }
            if cell.titleLabel.text == "All Media" {
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.image = UIImage(named: "chatSetting_rightArrow")
            }
            if cell.titleLabel.text == "Search Conversation" {
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.image = UIImage(named: "chatSetting_rightArrow")
            }
            
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DisappearingChatSettingsTableViewCell") as! DisappearingChatSettingsTableViewCell
                cell.leftIconImageView.image = UIImage(named: "ic_disappearing_setting")
                cell.titleLabel.text = "Disappearing Messgaess"
                cell.discriptionLabel.text = "When enabled, messages between you and the group will disappear after they have been seen."
                
                //                cell.rightSwitch.isOn = self.isDisAppearMessageSwitchOn
                cell.rightSwitch.isOn = self.disappearingMessagesConfiguration?.isEnabled ?? false
                
                if cell.rightSwitch.isOn {
                    cell.rightSwitch.thumbTintColor = Colors.bothGreenColor
                    cell.bottomView.isHidden = false
                    
                    if self.disappearingMessagesConfiguration!.isEnabled {
                        let keepForFormat = NSLocalizedString("Disappear after %@", comment: "Format for disappearing messages duration label")
                        self.sliderDurationText = String(format: keepForFormat, self.disappearingMessagesConfiguration!.durationString)
                        if self.disappearingMessagesConfiguration!.durationString == "0 seconds" {
                            let numberOfSeconds = self.disappearingMessagesDurations![10]
                            self.disappearingMessagesConfiguration!.durationSeconds = UInt32(numberOfSeconds.uintValue)
                            let keepForFormat = NSLocalizedString("Disappear after %@", comment: "Format for disappearing messages duration label")
                            self.sliderDurationText = String(format: keepForFormat, self.disappearingMessagesConfiguration!.durationString)
                        }
                    } else {
                        self.sliderDurationText = NSLocalizedString("KEEP_MESSAGES_FOREVER", comment: "Slider label when disappearing messages is off")
                    }
                    
                    cell.rightTitleLabelForSlider.text = self.sliderDurationText
                    
                    if let sliderView = view.viewWithTag(111) {
                        sliderView.removeFromSuperview()
                    }
                    let slider = UISlider()
                    slider.maximumValue = Float(disappearingMessagesDurations!.count - 1)
                    slider.minimumValue = 0
                    slider.tintColor = Colors.bothGreenColor
                    slider.isContinuous = false
                    slider.tag = 111
                    slider.setThumbImage(UIImage(named: "chatSetting_slider"), for: .normal)
                    slider.value = Float(disappearingMessagesConfiguration!.durationIndex)
                    slider.addTarget(self, action: #selector(durationSliderDidChange(_:)), for: .valueChanged)
                    cell.bottomView.addSubview(slider)
                    slider.autoPinEdge(.leading, to: .leading, of: cell.titleLabelForSlider)
                    slider.autoPinEdge(.trailing, to: .trailing, of: cell.rightTitleLabelForSlider)
                    slider.autoPinEdge(.top, to: .bottom, of: cell.titleLabelForSlider, withOffset: 10)
                    
                    
                    
                    
                } else {
                    cell.rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
                    cell.bottomView.isHidden = true
                }
                cell.rightSwitch.addTarget(self, action: #selector(disAppearSwitchValueDidChange(_:)), for: .valueChanged)
                
                return cell
            }
            
        }
        
        
        // One To One Chat
        if self.thread!.isKind(of: TSContactThread.self) {
            cell.titleLabel.text = self.contactTitleArray[indexPath.row]
            cell.leftIconImageView.image = UIImage(named: self.contactImageArray[indexPath.row])
            
            if indexPath.row == 0 {
                cell.titleLabel.text = (thread as! TSContactThread).contactBChatID()
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.image = UIImage(named: "chat_setting_copy")
                cell.titleLabel.font = Fonts.OpenSans(ofSize: 12)
            } else {
                cell.titleLabel.font = Fonts.OpenSans(ofSize: 16)
            }
            if cell.titleLabel.text == "All Media" {
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.image = UIImage(named: "chatSetting_rightArrow")
            }
            if cell.titleLabel.text == "Search Conversation" {
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.image = UIImage(named: "chatSetting_rightArrow")
            }
            if cell.titleLabel.text == "Message Sound" {
                cell.rightTitleLabel.isHidden = false
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.isHidden = true
            }
            if cell.titleLabel.text == "Mute" {
                cell.rightSwitch.isHidden = false
                cell.rightIconImageView.isHidden = true
                cell.rightTitleLabel.isHidden = true
            }
            
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DisappearingChatSettingsTableViewCell") as! DisappearingChatSettingsTableViewCell
                cell.leftIconImageView.image = UIImage(named: "ic_disappearing_setting")
                cell.titleLabel.text = "Disappearing Messgaess"
                cell.discriptionLabel.text = "When enabled, messages between you and the group will disappear after they have been seen."
                
                cell.rightSwitch.isOn = self.disappearingMessagesConfiguration?.isEnabled ?? false
                if cell.rightSwitch.isOn {
                    cell.rightSwitch.thumbTintColor = Colors.bothGreenColor
                    cell.bottomView.isHidden = false
                    
                    if self.disappearingMessagesConfiguration!.isEnabled {
                        let keepForFormat = NSLocalizedString("Disappear after %@", comment: "Format for disappearing messages duration label")
                        self.sliderDurationText = String(format: keepForFormat, self.disappearingMessagesConfiguration!.durationString)
                        if self.disappearingMessagesConfiguration!.durationString == "0 seconds" {
                            let numberOfSeconds = self.disappearingMessagesDurations![10]
                            self.disappearingMessagesConfiguration!.durationSeconds = UInt32(numberOfSeconds.uintValue)
                            let keepForFormat = NSLocalizedString("Disappear after %@", comment: "Format for disappearing messages duration label")
                            self.sliderDurationText = String(format: keepForFormat, self.disappearingMessagesConfiguration!.durationString)
                        }
                    } else {
                        self.sliderDurationText = NSLocalizedString("KEEP_MESSAGES_FOREVER", comment: "Slider label when disappearing messages is off")
                    }
                    
                    cell.rightTitleLabelForSlider.text = self.sliderDurationText
                    
                    if let sliderView = view.viewWithTag(111) {
                        sliderView.removeFromSuperview()
                    }
                    let slider = UISlider()
                    slider.maximumValue = Float(disappearingMessagesDurations!.count - 1)
                    slider.minimumValue = 0
                    slider.tintColor = Colors.bothGreenColor
                    slider.isContinuous = false
                    slider.tag = 111
                    slider.setThumbImage(UIImage(named: "chatSetting_slider"), for: .normal)
                    slider.value = Float(disappearingMessagesConfiguration!.durationIndex)
                    slider.addTarget(self, action: #selector(durationSliderDidChange(_:)), for: .valueChanged)
                    cell.bottomView.addSubview(slider)
                    slider.autoPinEdge(.leading, to: .leading, of: cell.titleLabelForSlider)
                    slider.autoPinEdge(.trailing, to: .trailing, of: cell.rightTitleLabelForSlider)
                    slider.autoPinEdge(.top, to: .bottom, of: cell.titleLabelForSlider, withOffset: 10)
                    
                    
                } else {
                    cell.rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
                    cell.bottomView.isHidden = true
                }
                
                
                
                cell.rightSwitch.addTarget(self, action: #selector(disAppearSwitchValueDidChange(_:)), for: .valueChanged)
                
                return cell
                
            }
            
            
            if indexPath.row == 4 {
                let sound = OWSSounds.notificationSound(for: self.thread!)
                let displayName = OWSSounds.displayName(for: sound)
                cell.rightTitleLabel.text = displayName
            }
            
            if indexPath.row == 5 {
                if let mutedUntilDate = self.thread?.mutedUntilDate {
                    let now = Date()
                    cell.rightSwitch.isOn = mutedUntilDate.timeIntervalSince(now) > 0
                } else {
                    cell.rightSwitch.isOn = false
                }
                if cell.rightSwitch.isOn {
                    cell.rightSwitch.thumbTintColor = Colors.bothGreenColor
                } else {
                    cell.rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
                }
                cell.rightSwitch.addTarget(self, action: #selector(handleMuteSwitchToggled(_:)), for: .valueChanged)
            }
            
            
            if indexPath.row == 6 {
                cell.titleLabel.textColor = Colors.bothRedColor
                let thread = self.thread as? TSContactThread
                if thread!.isBlocked() {
                    cell.titleLabel.text = "UnBlock This User"
                } else {
                    cell.titleLabel.text = "Block This User"
                }
            } else {
                cell.titleLabel.textColor = Colors.titleColor
            }
            
            if indexPath.row == 7 {
                let thread = self.thread as? TSContactThread
                cell.titleLabel.text = "Report \(Storage.shared.getContact(with: thread!.contactBChatID())?.displayName(for: Contact.Context.regular) ?? "Anonymous")"
            }
            
            
            
        }
        
        
        
        // Close Group
        if self.isClosedGroup() {
            cell.titleLabel.text = self.closeGroupTitleArray[indexPath.row]
            cell.leftIconImageView.image = UIImage(named: self.closeGroupImageArray[indexPath.row])
            
            
            if cell.titleLabel.text == "All Media" {
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.image = UIImage(named: "chatSetting_rightArrow")
            }
            if cell.titleLabel.text == "Search Conversation" {
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.image = UIImage(named: "chatSetting_rightArrow")
            }
            if cell.titleLabel.text == "Message Sound" {
                cell.rightTitleLabel.isHidden = false
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.isHidden = true
            }
            if cell.titleLabel.text == "Mute" {
                cell.rightSwitch.isHidden = false
                cell.rightIconImageView.isHidden = true
                cell.rightTitleLabel.isHidden = true
            }
            if cell.titleLabel.text == "Edit Group" {
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
                cell.rightIconImageView.image = UIImage(named: "chatSetting_rightArrow")
            }
            if cell.titleLabel.text == "Leave Group" {
                cell.rightIconImageView.isHidden = true
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
                cell.titleLabel.textColor = Colors.bothRedColor
            } else {
                cell.titleLabel.textColor = Colors.titleColor
            }
            
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DisappearingChatSettingsTableViewCell") as! DisappearingChatSettingsTableViewCell
                cell.leftIconImageView.image = UIImage(named: "ic_disappearing_setting")
                cell.titleLabel.text = "Disappearing Messgaess"
                cell.discriptionLabel.text = "When enabled, messages between you and the group will disappear after they have been seen."
                
                let groupThread = self.thread as? TSGroupThread
                if !groupThread!.isCurrentUserMemberInGroup() {
                    cell.rightSwitch.isEnabled = false
                }
                cell.rightSwitch.isOn = self.disappearingMessagesConfiguration?.isEnabled ?? false
                if cell.rightSwitch.isOn {
                    cell.rightSwitch.thumbTintColor = Colors.bothGreenColor
                    cell.bottomView.isHidden = false
                    
                    if self.disappearingMessagesConfiguration!.isEnabled {
                        let keepForFormat = NSLocalizedString("Disappear after %@", comment: "Format for disappearing messages duration label")
                        self.sliderDurationText = String(format: keepForFormat, self.disappearingMessagesConfiguration!.durationString)
                        if self.disappearingMessagesConfiguration!.durationString == "0 seconds" {
                            let numberOfSeconds = self.disappearingMessagesDurations![10]
                            self.disappearingMessagesConfiguration!.durationSeconds = UInt32(numberOfSeconds.uintValue)
                            let keepForFormat = NSLocalizedString("Disappear after %@", comment: "Format for disappearing messages duration label")
                            self.sliderDurationText = String(format: keepForFormat, self.disappearingMessagesConfiguration!.durationString)
                        }
                    } else {
                        self.sliderDurationText = NSLocalizedString("KEEP_MESSAGES_FOREVER", comment: "Slider label when disappearing messages is off")
                    }
                    
                    cell.rightTitleLabelForSlider.text = self.sliderDurationText
                    
                    if let sliderView = view.viewWithTag(111) {
                        sliderView.removeFromSuperview()
                    }
                    let slider = UISlider()
                    slider.maximumValue = Float(disappearingMessagesDurations!.count - 1)
                    slider.minimumValue = 0
                    slider.tintColor = Colors.bothGreenColor
                    slider.isContinuous = false
                    slider.tag = 111
                    slider.setThumbImage(UIImage(named: "chatSetting_slider"), for: .normal)
                    slider.value = Float(disappearingMessagesConfiguration!.durationIndex)
                    slider.addTarget(self, action: #selector(durationSliderDidChange(_:)), for: .valueChanged)
                    cell.bottomView.addSubview(slider)
                    slider.autoPinEdge(.leading, to: .leading, of: cell.titleLabelForSlider)
                    slider.autoPinEdge(.trailing, to: .trailing, of: cell.rightTitleLabelForSlider)
                    slider.autoPinEdge(.top, to: .bottom, of: cell.titleLabelForSlider, withOffset: 10)
                    
                    
                } else {
                    cell.rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
                    cell.bottomView.isHidden = true
                }
                
                cell.rightSwitch.addTarget(self, action: #selector(disAppearSwitchValueDidChange(_:)), for: .valueChanged)
                
                return cell
                
            }
            
            
            if indexPath.row == 4 {
                let sound = OWSSounds.notificationSound(for: self.thread!)
                let displayName = OWSSounds.displayName(for: sound)
                cell.rightTitleLabel.text = displayName
            }
            
            if indexPath.row == 6 {
                let groupThread = self.thread as? TSGroupThread
                if !groupThread!.isCurrentUserMemberInGroup() {
                    cell.rightSwitch.isEnabled = false
                }
                if let mutedUntilDate = self.thread?.mutedUntilDate {
                    let now = Date()
                    cell.rightSwitch.isOn = mutedUntilDate.timeIntervalSince(now) > 0
                } else {
                    cell.rightSwitch.isOn = false
                }
                if cell.rightSwitch.isOn {
                    cell.rightSwitch.thumbTintColor = Colors.bothGreenColor
                } else {
                    cell.rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
                }
                cell.rightSwitch.addTarget(self, action: #selector(handleMuteSwitchToggled(_:)), for: .valueChanged)
            }
            
            if indexPath.row == 5 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotifyChatSettingsTableViewCell") as! NotifyChatSettingsTableViewCell
                cell.leftIconImageView.image = UIImage(named: "chatSetting_notify")
                cell.titleLabel.text = "Notify for Mentions Only"
                cell.discriptionLabel.text = "When enabled,you’ll only be notified for messages mentioning you."
                let groupThread = self.thread as? TSGroupThread
                let isOnlyNotifyingForMentions = groupThread?.isOnlyNotifyingForMentions ?? false
                if !groupThread!.isCurrentUserMemberInGroup() {
                    cell.rightSwitch.isEnabled = false
                }
                cell.rightSwitch.isOn = isOnlyNotifyingForMentions
                
                if cell.rightSwitch.isOn {
                    cell.rightSwitch.thumbTintColor = Colors.bothGreenColor
                } else {
                    cell.rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
                }
                cell.rightSwitch.addTarget(self, action: #selector(notifyforMentionsOnlySwitchValueDidChange(_:)), for: .valueChanged)
                return cell
            }
            
            let groupThread = self.thread as? TSGroupThread
            if !groupThread!.isCurrentUserMemberInGroup() {
                if indexPath.row == 3 {
                    cell.titleLabel.alpha = 0.6
                    cell.rightIconImageView.alpha = 0.6
                    cell.leftIconImageView.alpha = 0.6
                }
            }
            
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isOpenGroup() { // Social Group
            if indexPath.row == 0 {
                self.showMediaGallery()
            }
            if indexPath.row == 1 {
                self.inviteUsersToOpenGroup()
            }
            if indexPath.row == 2 {
                self.tappedConversationSearch()
            }
            if indexPath.row == 3 {
                let vc = OWSSoundSettingsViewController()
                vc.thread = self.thread!
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        // Note to self
        if self.thread!.isNoteToSelf() {
            if indexPath.row == 0 {
                self.copyBChatID()
            }
            if indexPath.row == 1 {
                self.showMediaGallery()
                return
            }
            if indexPath.row == 2 {
                self.tappedConversationSearch()
            }
            
        }
        
        // One To One Chat
        if self.thread!.isKind(of: TSContactThread.self) {
            if indexPath.row == 0 {
                self.copyBChatID()
            }
            if indexPath.row == 1 {
                self.showMediaGallery()
            }
            if indexPath.row == 2 {
                self.tappedConversationSearch()
            }
            if indexPath.row == 3 {
                
            }
            if indexPath.row == 4 {
                let vc = OWSSoundSettingsViewController()
                vc.thread = self.thread!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 5 {
                
            }
            if indexPath.row == 6 { // Block and UnBlock Contact Index Cell
                if let contactThread = self.thread as? TSContactThread {
                    let isCurrentlyBlocked = contactThread.isBlocked()
                    if !isCurrentlyBlocked {
                        let vc = BlockContactPopUpVC()
                        vc.modalPresentationStyle = .overFullScreen
                        vc.modalTransitionStyle = .crossDissolve
                        self.present(vc, animated: true, completion: nil)
                    } else {
                        let vc = BlockContactPopUpVC()
                        vc.isBlocked = true
                        vc.modalPresentationStyle = .overFullScreen
                        vc.modalTransitionStyle = .crossDissolve
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
            
            if indexPath.row == 7 {
                if let thread = self.thread as? TSContactThread {
                    if let contact = Storage.shared.getContact(with: thread.contactBChatID()) {
                        let displayName = contact.displayName(for: Contact.Context.regular)
                        let fullDisplayName = String(format: NSLocalizedString("Report %@ ", comment: ""), displayName!)
                        
                        let alert = UIAlertController(title: fullDisplayName, message: NSLocalizedString("This user will be reported to BChat Team.", comment: ""), preferredStyle: .alert)
                        
                        // Add Buttons
                        let yesButton = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default) { _ in
                            // Handle your 'Ok' button action here
                        }
                        let noButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { _ in
                            // Handle 'Cancel' button action here
                        }
                        
                        // Add buttons to alert controller
                        alert.addAction(yesButton)
                        alert.addAction(noButton)
                        
                        // Present alert
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        
        
        // Close Group
        if self.isClosedGroup() {
            if indexPath.row == 0 {
                self.showMediaGallery()
            }
            if indexPath.row == 1 {
                self.tappedConversationSearch()
            }
            if indexPath.row == 3 {
                let groupThread = self.thread as? TSGroupThread
                if groupThread!.isCurrentUserMemberInGroup() {
                    self.editGroup()
                }
            }
            if indexPath.row == 4 {
                let vc = OWSSoundSettingsViewController()
                vc.thread = self.thread!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 7 {
                self.didTapLeaveGroup()
            }
        }
    }
    
}
