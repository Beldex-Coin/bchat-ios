// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import PromiseKit
import BChatMessagingKit

class EditGroupViewController: BaseVC, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
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
    
    private lazy var nameTextField: UITextField = {
        let result = UITextField()
        let attributes = [
            NSAttributedString.Key.foregroundColor: Colors.titleColor,
            NSAttributedString.Key.font: Fonts.OpenSans(ofSize: 16)
        ]
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("Enter a group name", comment: ""), attributes: attributes)
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
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.layer.cornerRadius = 14
        return t
    }()
    
    private lazy var applyChangesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Apply Changes", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.unlockButtonBackgroundColor
        button.setTitleColor(UIColor(hex: 0x6E6E7C), for: .normal)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(applyChangesButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomButtonView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor3
        return stackView
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
    
    
    private let thread: TSGroupThread
    private var name = ""
    private var zombies: Set<String> = []
    private var membersAndZombies: [String] = [] { didSet { handleMembersChanged() } }
    
    private lazy var groupPublicKey: String = {
        let groupID = thread.groupModel.groupId
        return LKGroupUtilities.getDecodedGroupID(groupID)
    }()
    
    
    // MARK: Lifecycle
    @objc(initWithThreadID:)
    init(with threadID: String) {
        var thread: TSGroupThread!
        Storage.read { transaction in
            thread = TSGroupThread.fetch(uniqueId: threadID, transaction: transaction)!
        }
        self.thread = thread
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Use init(with:) instead.")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        self.title = "Edit Group"
        
        view.addSubViews(profilePictureImageView, displayNameLabel, tableView, nameTextField, editIconImage, bottomButtonView, doneButton)
        bottomButtonView.addSubview(applyChangesButton)
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.OpenSans(ofSize: 16),
            .foregroundColor: Colors.titleColor
        ]
        let attributedPlaceholder = NSAttributedString(string: "Enter a group name", attributes: placeholderAttributes)
        nameTextField.attributedPlaceholder = attributedPlaceholder
        nameTextField.font = Fonts.boldOpenSans(ofSize: 18)
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "ic_addMembers"), style: .plain, target: self, action: #selector(addMemberAction))
        let rightBarButtonItems = [rightBarItem]
        navigationItem.rightBarButtonItems = rightBarButtonItems
                
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        tableView.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 25.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomButtonView.topAnchor, constant: 0).isActive = true
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(NewBlockContactTableViewCell.self, forCellReuseIdentifier: "NewBlockContactTableViewCell")
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        
        let size = CGFloat(86)
        profilePictureImageView.set(.width, to: size)
        profilePictureImageView.set(.height, to: size)
        profilePictureImageView.size = size
        profilePictureImageView.layer.masksToBounds = true
        profilePictureImageView.layer.cornerRadius = 43
        profilePictureImageView.update(for: self.thread)
        
        displayNameLabel.text = (self.threadName()!.count > 0) ? self.threadName()! : "Anonymous"
        displayNameLabel.isHidden = true
        nameTextField.text = (self.threadName()!.count > 0) ? self.threadName()! : "Anonymous"
        nameTextField.delegate = self
        
        NSLayoutConstraint.activate([
            profilePictureImageView.widthAnchor.constraint(equalToConstant: 86),
            profilePictureImageView.heightAnchor.constraint(equalToConstant: 86),
            profilePictureImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            profilePictureImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            displayNameLabel.topAnchor.constraint(equalTo: profilePictureImageView.bottomAnchor, constant: 8),
            displayNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: profilePictureImageView.bottomAnchor, constant: 8),
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editIconImage.widthAnchor.constraint(equalToConstant: 14),
            editIconImage.heightAnchor.constraint(equalToConstant: 14),
            editIconImage.leadingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor, constant: 4),
            editIconImage.centerYAnchor.constraint(equalTo: displayNameLabel.centerYAnchor),
            
            bottomButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            bottomButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            bottomButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            bottomButtonView.heightAnchor.constraint(equalToConstant: 88),
            
            applyChangesButton.centerYAnchor.constraint(equalTo: bottomButtonView.centerYAnchor),
            applyChangesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            applyChangesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            applyChangesButton.heightAnchor.constraint(equalToConstant: 58),
            
            doneButton.widthAnchor.constraint(equalToConstant: 66.7),
            doneButton.heightAnchor.constraint(equalToConstant: 26),
            doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.3),
            
        ])
        
        applyChangesButton.backgroundColor = Colors.cancelButtonBackgroundColor
        applyChangesButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
        nameTextField.isUserInteractionEnabled = true
        editIconImage.isHidden = false
        nameTextField.addTarget(self, action: #selector(nameTextfieldTapped), for: UIControl.Event.touchDown)
        
        
        func getDisplayName(for publicKey: String) -> String {
            return Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
        }
        // Always show zombies at the bottom
        zombies = Storage.shared.getZombieMembers(for: groupPublicKey)
        membersAndZombies = GroupUtilities.getClosedGroupMembers(thread).sorted { getDisplayName(for: $0) < getDisplayName(for: $1) }
            + zombies.sorted { getDisplayName(for: $0) < getDisplayName(for: $1) }
        name = thread.groupModel.groupName!
        
        doneButton.isHidden = true
        
    }
    
    
    private func handleMembersChanged() {
        tableView.reloadData()
    }
    
    @objc private func applyChangesButtonTapped() {
        updateGroupName()
    }
    
    @objc private func doneButtonTapped(_ sender: UIButton) {
        updateGroupName()
    }

    private func updateGroupName() {
        let name = nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !name.isEmpty else {
            return showError(title: NSLocalizedString("vc_create_closed_group_group_name_missing_error", comment: ""))
        }
        guard name.count < 64 else {
            return showError(title: NSLocalizedString("vc_create_closed_group_group_name_too_long_error", comment: ""))
        }
        self.name = name
        displayNameLabel.text = name
        doneButton.isHidden = true
        commitChanges()
    }
    
    func threadName() -> String? {
        var threadName = self.thread.name()
        return threadName
    }
    

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength : Int
        if textField == nameTextField {
            maxLength = 26
        }
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= 26
    }
    
    @objc func nameTextfieldTapped(textField: UITextField) {
        editIconImage.isHidden = true
        doneButton.isHidden = false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let name = self.nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if name == thread.groupModel.groupName {
            applyChangesButton.backgroundColor = Colors.cancelButtonBackgroundColor
            applyChangesButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
        } else {
            applyChangesButton.backgroundColor = Colors.bothGreenColor
            applyChangesButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
        }
    }
    
    @objc func addMemberAction() {
        let title = "Add Members"
        let userSelectionVC = AddMembersViewController(with: title, excluding: Set(membersAndZombies)) { [weak self] selectedUsers in
            guard let self = self else { return }
            var members = self.membersAndZombies
            members.append(contentsOf: selectedUsers)
            func getDisplayName(for publicKey: String) -> String {
                return Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
            }
            self.membersAndZombies = members.sorted { getDisplayName(for: $0) < getDisplayName(for: $1) }
            self.applyChangesButton.backgroundColor = Colors.bothGreenColor
            self.applyChangesButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
        }
        navigationController!.pushViewController(userSelectionVC, animated: true, completion: nil)
    }
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return membersAndZombies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let userPublicKey = getUserHexEncodedPublicKey()
        return thread.groupModel.groupAdminIds.contains(userPublicKey)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewBlockContactTableViewCell") as! NewBlockContactTableViewCell
        
        cell.unblockButton.isHidden = true
        cell.selectionButton.isHidden = true
        
        let publicKey = membersAndZombies[indexPath.row]
        cell.nameLabel.text = Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
        cell.profileImageView.image = getProfilePicture(of: 30, for: publicKey)
        
        let contact: Contact? = Storage.shared.getContact(with: publicKey)
        if let _ = contact, let isBnsUser = contact?.isBnsHolder {
            cell.profileImageView.layer.borderWidth = isBnsUser ? Values.borderThickness : 0
            cell.profileImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
            cell.verifiedImageView.isHidden = isBnsUser ? false : true
        }  else {
            cell.verifiedImageView.isHidden = true
        }
        
        let userPublicKey = getUserHexEncodedPublicKey()
        let isCurrentUserAdmin = thread.groupModel.groupAdminIds.contains(userPublicKey)
        cell.removeButton.isHidden = !isCurrentUserAdmin ? true : false
        
        if publicKey == userPublicKey && isCurrentUserAdmin {
            cell.removeButton.isHidden = true
        }
        
        cell.removeCallback = {
            if let index = self.membersAndZombies.firstIndex(of: publicKey) {
                self.membersAndZombies.remove(at: index)
                self.applyChangesButton.backgroundColor = Colors.bothGreenColor
                self.applyChangesButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
            }
        }
        
        return cell
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
    
    private func commitChanges() {
        let popToConversationVC: (EditGroupViewController) -> Void = { editVC in
            if let conversationVC = editVC.navigationController!.viewControllers.first(where: { $0 is ConversationVC }) {
                editVC.navigationController!.popToViewController(conversationVC, animated: true)
            } else {
                editVC.navigationController!.popViewController(animated: true)
            }
        }
        let storage = SNMessagingKitConfiguration.shared.storage
        let members = Set(self.membersAndZombies)
        let name = self.nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let zombies = storage.getZombieMembers(for: groupPublicKey)
        guard members != Set(thread.groupModel.groupMemberIds + zombies) || name != thread.groupModel.groupName else { return }
        if !members.contains(getUserHexEncodedPublicKey()) {
            guard Set(thread.groupModel.groupMemberIds).subtracting([ getUserHexEncodedPublicKey() ]) == members else {
                return showError(title: "Couldn't Update Group", message: "Can't leave while adding or removing other members.")
            }
        }
        guard members.count <= 100 else {
            return showError(title: NSLocalizedString("vc_create_closed_group_too_many_group_members_error", comment: ""))
        }
        var promise: Promise<Void>!
        ModalActivityIndicatorViewController.present(fromViewController: navigationController!) { [groupPublicKey, weak self] _ in
            Storage.write(with: { transaction in
                if !members.contains(getUserHexEncodedPublicKey()) {
                    promise = MessageSender.leave(groupPublicKey, using: transaction)
                } else {
                    promise = MessageSender.update(groupPublicKey, with: members, name: name, transaction: transaction)
                }
            }, completion: {
                let _ = promise.done(on: DispatchQueue.main) {
                    guard let self = self else { return }
                    MentionsManager.populateUserPublicKeyCacheIfNeeded(for: self.thread.uniqueId!)
                    self.dismiss(animated: true, completion: nil) // Dismiss the loader
                    popToConversationVC(self)
                }
                promise.catch(on: DispatchQueue.main) { error in
                    self?.dismiss(animated: true, completion: nil) // Dismiss the loader
                    self?.showError(title: "Couldn't Update Group", message: error.localizedDescription)
                }
            })
        }
    }

    // MARK: Convenience
    private func showError(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
        presentAlert(alert)
    }
    

}
