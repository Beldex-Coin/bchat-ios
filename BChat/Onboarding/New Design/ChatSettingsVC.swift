// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import ContactsUI
import PromiseKit
import Foundation





let kIconViewLength: CGFloat = 24


protocol OWSConversationSettingsViewDelegate: AnyObject {
    func groupWasUpdated(_ groupModel: TSGroupModel)
    func conversationSettingsDidRequestConversationSearch(_ conversationSettingsViewController: ChatSettingsVC)
    func popAllConversationSettingsViewsWithCompletion(_ completionBlock: (() -> Void)?)
}


class ChatSettingsVC: BaseVC, SheetViewControllerDelegate {
    
    
    private lazy var profilePictureImageView = ProfilePictureView()
    
    private lazy var displayNameLabel: UILabel = {
        let result = UILabel()
        result.text = ""
        result.textColor = Colors.titleColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 1
        return result
    }()
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.layer.cornerRadius = 14
        return t
    }()
    
    
    var socialGroupTitleArray = ["All Media", "Add Members", "Search Conversation", "Message Sound", "Notify for Mentions Only", "Mute"]
    var socialGroupLeftImageArray = ["ic_allmedia", "chatSettings_addmember", "ic_search_settingnew", "ic_message_sound", "chatSetting_notify", "chatSetting_mute"]
    
    var noteToSelfTitleArray = ["", "All Media", "Search Conversation", "Disappearing Messgaess"]
    var noteToSelfImageArray = ["bchat_chat_setting", "ic_allmedia", "ic_search_settingnew", "ic_disappearing_setting"]
    
    
    
    
    var thread: TSThread?
    var uiDatabaseConnection: YapDatabaseConnection?
//            private(set) var editingDatabaseConnection: YapDatabaseConnection?
    var disappearingMessagesDurations: [NSNumber]?
    var disappearingMessagesConfiguration: OWSDisappearingMessagesConfiguration?
    var mediaGallery: MediaGallery?
    private(set) var avatarView: UIImageView?
    private(set) var disappearingMessagesDurationLabel: UILabel?
//    var displayNameLabel: UILabel?
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
    
    
    func configure(with thread: TSThread?, uiDatabaseConnection: YapDatabaseConnection?) {
        self.thread = thread
        self.uiDatabaseConnection = uiDatabaseConnection
    }

    func didFinishEditingContact() {
//        updateTableContents()
        self.tableView.reloadData()
        dismiss(animated: false)
    }
    
    func contactViewController(
        _ viewController: CNContactViewController,
        didCompleteWith contact: CNContact?
    ) {
//        updateTableContents()
        self.tableView.reloadData()
        if (contact != nil) {
            dismiss(animated: false)
        } else {
            dismiss(animated: true)
        }

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
        
        view.addSubViews(profilePictureImageView, displayNameLabel, tableView)
        
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
        
        
        
        NSLayoutConstraint.activate([
            profilePictureImageView.widthAnchor.constraint(equalToConstant: 86),
            profilePictureImageView.heightAnchor.constraint(equalToConstant: 86),
            profilePictureImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            profilePictureImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            displayNameLabel.topAnchor.constraint(equalTo: profilePictureImageView.bottomAnchor, constant: 8),
            displayNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
        ])
        
//        adjustTableViewHeight()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
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
            
    //        if disappearingMessagesConfiguration!.isNewRecord && !disappearingMessagesConfiguration!.isEnabled {
    //            // don't save defaults, else we'll unintentionally save the configuration and notify the contact.
    //            return
    //        }
    //
    //
    //        if disappearingMessagesConfiguration!.dictionaryValueDidChange {
    //            Storage.write() { [self] transaction in
    //                disappearingMessagesConfiguration!.save(with: transaction as! YapDatabaseReadWriteTransaction)
    //
    //                let infoMessage = OWSDisappearingConfigurationUpdateInfoMessage(
    //                    timestamp: NSDate.ows_millisecondTimeStamp(),
    //                    thread: thread!,
    //                    configuration: disappearingMessagesConfiguration!,
    //                    createdByRemoteName: nil,
    //                    createdInExistingGroup: false)
    //                infoMessage.save(with: transaction as! YapDatabaseReadWriteTransaction )
    //
    //                let expirationTimerUpdate = ExpirationTimerUpdate()
    //                let isEnabled = disappearingMessagesConfiguration!.isEnabled
    //                expirationTimerUpdate.duration = isEnabled ? disappearingMessagesConfiguration!.durationSeconds : 0
    //                MessageSender.send(expirationTimerUpdate, in: thread!, using: transaction)
    //
    //            }
    //        }
            
            
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
        
    
    @objc func notifyforMentionsOnlySwitchValueDidChange(_ sender: UISwitch) {
        let uiSwitch = sender
        let isEnabled = uiSwitch.isOn ?? false
        Storage.write() { [self] transaction in
            (thread as? TSGroupThread)?.setIsOnlyNotifyingForMentions(isEnabled, with: transaction)
        }
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
            self.tableView.reloadData()
            
        }
        
//        func handleMuteSwitchToggled(_ sender: Any?) {
//            let uiSwitch = sender as? UISwitch
//            if uiSwitch?.isOn ?? false {
//                Storage.write() { [self] transaction in
//                    thread!.updateWithMuted(until: Date.distantFuture, transaction: transaction)
//                }
//            } else {
//                Storage.write() { [self] transaction in
//                    thread!.updateWithMuted(until: nil, transaction: transaction)
//                }
//            }
//        }
        
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
            self.tableView.reloadData()
        }
        
        @objc func otherUsersProfileDidChange(_ notification: Notification) {
            let recipientId = notification.userInfo![kNSNotificationKey_ProfileRecipientId] as? String
            if (recipientId?.count ?? 0) > 0 && (thread is TSContactThread) && ((thread as? TSContactThread)!.contactBChatID() == recipientId) {
    //            updateTableContents()
                self.tableView.reloadData()
            }
        }
    
    

   

}


extension ChatSettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isOpenGroup() {
            return self.socialGroupTitleArray.count
        } else if self.thread!.isNoteToSelf() {
            return self.noteToSelfTitleArray.count
        }
        else {
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
                return 98
            }
        }
        
        return 45//UITableView.automaticDimension
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
                var groupThread = self.thread as? TSGroupThread
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
            }
            if cell.titleLabel.text == "Search Conversation" {
                cell.rightIconImageView.isHidden = false
                cell.rightTitleLabel.isHidden = true
                cell.rightSwitch.isHidden = true
            }
            
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotifyChatSettingsTableViewCell") as! NotifyChatSettingsTableViewCell
                cell.leftIconImageView.image = UIImage(named: "ic_disappearing_setting")
                cell.titleLabel.text = "Disappearing Messgaess"
                cell.discriptionLabel.text = "When enabled, messages between you and the group will disappear after they have been seen."
                var groupThread = self.thread as? TSGroupThread
                let isOnlyNotifyingForMentions = groupThread?.isOnlyNotifyingForMentions ?? false
                cell.rightSwitch.isOn = isOnlyNotifyingForMentions
                
                if cell.rightSwitch.isOn {
                    cell.rightSwitch.thumbTintColor = Colors.bothGreenColor
                } else {
                    cell.rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
                }
//                cell.rightSwitch.addTarget(self, action: #selector(notifyforMentionsOnlySwitchValueDidChange(_:)), for: .valueChanged)
                
                return cell
                
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
            }
            if indexPath.row == 2 {
                self.tappedConversationSearch()
            }
            
        }
        
        
    }
    
    
    
    
}
