// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import UIKit

class SearchGroupMemberVC: BaseVC, UITextFieldDelegate {
    
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.semiOpenSans(ofSize: 20)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.text = "Search members"
        return result
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        let image = UIImage(named: "ic_closeSearchMember")
        button.setImage(image, for: UIControl.State.normal)
        button.set(.width, to: 28)
        button.set(.height, to: 28)
        return button
    }()
    
    private lazy var searchTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(
            string: "Search people",
            attributes: [NSAttributedString.Key.foregroundColor: Colors.textFieldPlaceHolderColor]
        )
        result.font = Fonts.OpenSans(ofSize: 14)
        result.layer.borderColor = Colors.borderColorNew.cgColor
        result.backgroundColor = Colors.unlockButtonBackgroundColor
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 24
        result.layer.borderWidth = 0
        result.textColor = Colors.titleColor3
        result.textAlignment = .left
        
        // Add left padding
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 17 + 16 + 10, height: 16))
        result.leftView = paddingViewLeft
        result.leftViewMode = .always
        
        // Add right padding
        let paddingViewRight = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 12))
        result.rightView = paddingViewRight
        result.rightViewMode = .always
        
        // Create an UIImageView and set its image for search icon
        let searchIconImageView = UIImageView(image: UIImage(named: "ic_Search_Vector_New"))
        searchIconImageView.frame = CGRect(x: 17, y: 0, width: 16, height: 16)
        searchIconImageView.contentMode = .scaleAspectFit
        paddingViewLeft.addSubview(searchIconImageView)
        
        // Create an UIImageView for close icon initially hidden
        let closeIconImageView = UIImageView(image: UIImage(named: "ic_closeNew"))
        closeIconImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 14)
        closeIconImageView.contentMode = .scaleAspectFit
        closeIconImageView.tag = 1 // Set a tag to distinguish it from the search icon
        closeIconImageView.isHidden = true
        paddingViewRight.addSubview(closeIconImageView)
        
        // Add tap gesture recognizer to closeIconImageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeIconTapped))
        closeIconImageView.isUserInteractionEnabled = true
        closeIconImageView.addGestureRecognizer(tapGestureRecognizer)
        result.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return result
    }()
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.separatorStyle = .none
        return t
    }()
    
    
    
    var filteredUsers: [String] = []
    var searchText: String = ""
    var mainDict: [String: String] = [:]
    var filterDict: [String: String] = [:]
    var namesArray: [String] = []
    var isSearchEnable = false
    private var zombies: Set<String> = []
    private var membersAndZombies: [String] = [] { didSet { handleMembersChanged() } }
    private lazy var groupPublicKey: String = {
            let groupThread = self.thread as? TSGroupThread
            let groupID = groupThread?.groupModel.groupId
            return LKGroupUtilities.getDecodedGroupID(groupID!)
    }()
    var thread: TSThread?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        view.addSubViews(titleLabel, closeButton, searchTextField, tableView)
        
        searchTextField.delegate = self
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 21),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 17),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            searchTextField.heightAnchor.constraint(equalToConstant: 48),
            
        ])
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 8).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(ChatSettingsTableViewCell.self, forCellReuseIdentifier: "ChatSettingsTableViewCell")
        tableView.backgroundColor = Colors.mainBackGroundColor2
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        
        
        zombies = Storage.shared.getZombieMembers(for: groupPublicKey)
        guard let groupThread = self.thread as? TSGroupThread else { return }
        membersAndZombies = GroupUtilities.getClosedGroupMembers(groupThread).sorted { getDisplayName(for: $0) < getDisplayName(for: $1) }
            + zombies.sorted { getDisplayName(for: $0) < getDisplayName(for: $1) }
        
        filteredUsers = membersAndZombies
        if membersAndZombies.count > 0 {
            namesArray = []
            for i in 0...(membersAndZombies.count - 1) {
                namesArray.append(Storage.shared.getContact(with: membersAndZombies[i])?.displayName(for: .regular) ?? membersAndZombies[i])
            }
            mainDict = Dictionary(uniqueKeysWithValues: zip(membersAndZombies, namesArray))
            filterDict = mainDict
        }
        
        let adminId = groupThread.groupModel.groupAdminIds[0]
        if let value = filterDict[adminId] {
            filterDict.removeValue(forKey: adminId)
            var orderedDictionary: [String: String] = [adminId: value]
            for (key, value) in filterDict {
                orderedDictionary[key] = value
            }
            filterDict = orderedDictionary
        }
        if let index = filteredUsers.firstIndex(of: adminId) {
            filteredUsers.remove(at: index)
            filteredUsers.insert(adminId, at: 0)
        }
        
    }
    
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    private func handleMembersChanged() {
        tableView.reloadData()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let rightView = searchTextField.rightView {
            if let searchIconImageView = rightView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                searchIconImageView.isHidden = !searchTextField.text!.isEmpty
                self.isFilterSearchContact()
            }
            if let closeIconImageView = rightView.subviews.first(where: { $0 is UIImageView && $0.tag == 1 }) as? UIImageView {
                closeIconImageView.isHidden = searchTextField.text!.isEmpty
                self.isFilterSearchContact()
            }
        }
        
    }
    
    @objc func closeIconTapped() {
        searchTextField.text = ""
        tableView.reloadData()
        // Get the right view of the search text field
        if let rightView = searchTextField.rightView {
            // Iterate through subviews of the right view to find the close icon image view
            for subview in rightView.subviews {
                if let closeIconImageView = subview as? UIImageView, closeIconImageView.tag == 1 {
                    // Hide the close icon image view
                    closeIconImageView.isHidden = true
                    isFilterSearchContact()
                }
            }
        }
        // Get the right view of the search text field
        if let rightView = searchTextField.rightView {
            // Iterate through subviews of the right view to find the search icon image view
            for subview in rightView.subviews {
                if let searchIconImageView = subview as? UIImageView, searchIconImageView.tag != 1 {
                    // Show the search icon image view
                    searchIconImageView.isHidden = false
                    isFilterSearchContact()
                }
            }
        }
    }
    
    func isFilterSearchContact() {
        let currentText = searchTextField.text ?? ""
        searchText = currentText
        if searchText.isEmpty {
            filteredUsers = membersAndZombies
            if membersAndZombies.count > 0 {
                namesArray = []
                for i in 0...(membersAndZombies.count - 1) {
                    namesArray.append(Storage.shared.getContact(with: membersAndZombies[i])?.displayName(for: .regular) ?? membersAndZombies[i])
                }
                mainDict = Dictionary(uniqueKeysWithValues: zip(membersAndZombies, namesArray))
                filterDict = mainDict
            }
        } else {
            let predicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", searchText)
            filterDict = mainDict.filter { predicate.evaluate(with: $0.value) }
            filteredUsers = Array(filterDict.keys)
        }
        guard let groupThread = self.thread as? TSGroupThread else { return }
        let adminId = groupThread.groupModel.groupAdminIds[0]
        if let value = filterDict[adminId] {
            filterDict.removeValue(forKey: adminId)
            var orderedDictionary: [String: String] = [adminId: value]
            for (key, value) in filterDict {
                orderedDictionary[key] = value
            }
            filterDict = orderedDictionary
        }
        if let index = filteredUsers.firstIndex(of: adminId) {
            filteredUsers.remove(at: index)
            filteredUsers.insert(adminId, at: 0)
        }
        tableView.reloadData()
    }
    
    func getDisplayName(for publicKey: String) -> String {
        return Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
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

extension SearchGroupMemberVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSettingsTableViewCell") as! ChatSettingsTableViewCell
        
        cell.backGroundView.backgroundColor = .clear
        let publicKey = filteredUsers[indexPath.row]
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
                    
        let groupThread = self.thread as? TSGroupThread
        let isCurrentUserAdmin = groupThread?.groupModel.groupAdminIds.contains(publicKey)
        cell.adminButton.isHidden = (isCurrentUserAdmin ?? false) ? false : true
        return cell
    }
}
