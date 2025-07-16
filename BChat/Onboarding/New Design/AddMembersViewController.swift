// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class AddMembersViewController: BaseVC, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private lazy var searchTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(
            string: "Search Contact",
            attributes: [NSAttributedString.Key.foregroundColor: Colors.textFieldPlaceHolderColor]
        )
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.layer.borderColor = Colors.borderColorNew.cgColor
        result.backgroundColor = Colors.unlockButtonBackgroundColor
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 24
        result.layer.borderWidth = 1
        result.textColor = Colors.titleColor3
        result.textAlignment = .left
        
        // Add left padding
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: result.frame.size.height))
        result.leftView = paddingViewLeft
        result.leftViewMode = .always
        
        // Add right padding
        let paddingViewRight = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 12))
        result.rightView = paddingViewRight
        result.rightViewMode = .always
        
        // Create an UIImageView and set its image for search icon
        let searchIconImageView = UIImageView(image: UIImage(named: "ic_Search_Vector_New"))
        searchIconImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 12)
        searchIconImageView.contentMode = .scaleAspectFit
        paddingViewRight.addSubview(searchIconImageView)
        
        // Create an UIImageView for close icon initially hidden
        let closeIconImageView = UIImageView(image: UIImage(named: "ic_closeNew"))
        closeIconImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 12)
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
        return t
    }()
    
    private lazy var bottomButtonView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor3
        return stackView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.unlockButtonBackgroundColor
        button.setTitleColor(UIColor(hex: 0x6E6E7C), for: .normal)
        button.titleLabel!.font = Fonts.regularOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    
    private let usersToExclude: Set<String>
    private let completion: (Set<String>) -> Void
    private var selectedUsers: Set<String> = []

    private lazy var users: [String] = {
        var result = ContactUtilities.getAllContacts()
        result.removeAll { usersToExclude.contains($0) }
        return result
    }()
    
    var filteredUsers: [String] = []
    var searchText: String = ""
    var mainDict: [String: String] = [:]
    var filterDict: [String: String] = [:]
    var namesArray: [String] = []
    
    
    @objc(initWithTitle:excluding:completion:)
    init(with title: String, excluding usersToExclude: Set<String>, completion: @escaping (Set<String>) -> Void) {
        self.usersToExclude = usersToExclude
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { preconditionFailure("Use AddMembersViewController.init(excluding:) instead.") }
    override init(nibName: String?, bundle: Bundle?) { preconditionFailure("Use AddMembersViewController.init(excluding:) instead.") }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.viewBackgroundColorSocialGroup
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Add members"
        
        view.addSubViews(searchTextField, bottomButtonView)
        bottomButtonView.addSubview(addButton)
        view.addSubview(tableView)
        
        searchTextField.delegate = self
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 14.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomButtonView.topAnchor, constant: 0).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(CreateSecretGroupTableViewCell.self, forCellReuseIdentifier: "CreateSecretGroupTableViewCell")
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        
        addButton.backgroundColor = Colors.bothGreenColor
        addButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            searchTextField.heightAnchor.constraint(equalToConstant: 48),
            
            bottomButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            bottomButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            bottomButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            bottomButtonView.heightAnchor.constraint(equalToConstant: 88),
            
            addButton.centerYAnchor.constraint(equalTo: bottomButtonView.centerYAnchor),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            addButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
        if users.count > 0 {
            for i in 0...(users.count - 1) {
                namesArray.append(Storage.shared.getContact(with: users[i])?.displayName(for: .regular) ?? users[i])
            }
            
            mainDict = Dictionary(uniqueKeysWithValues: zip(users, namesArray))
            filterDict = mainDict
        }
        tableView.reloadData()
        
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
                    isFilterContacts()
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
                    isFilterContacts()
                }
            }
        }
    }
    
    
    func isFilterContacts(){
        let currentText = searchTextField.text ?? ""
        searchText = currentText
        if searchText.isEmpty {
            filteredUsers = users
            if users.count > 0 {
                namesArray = []
                for i in 0...(users.count - 1) {
                    namesArray.append(Storage.shared.getContact(with: users[i])?.displayName(for: .regular) ?? users[i])
                }
                mainDict = Dictionary(uniqueKeysWithValues: zip(users, namesArray))
                filterDict = mainDict
            }
        } else {
            let predicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", searchText)
            filterDict = mainDict.filter { predicate.evaluate(with: $0.value) }
        }
        tableView.reloadData()
    }
    
    func isFilterSearchContact(text:String){
        let currentText = text
        searchText = currentText
        if searchText.isEmpty {
            filteredUsers = users
            if users.count > 0 {
                namesArray = []
                for i in 0...(users.count - 1) {
                    namesArray.append(Storage.shared.getContact(with: users[i])?.displayName(for: .regular) ?? users[i])
                }
                mainDict = Dictionary(uniqueKeysWithValues: zip(users, namesArray))
                filterDict = mainDict
            }
        } else {
            let predicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", searchText)
            filterDict = mainDict.filter { predicate.evaluate(with: $0.value) }
        }
        tableView.reloadData()
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Show/hide search and close icons based on text
        if let rightView = textField.rightView {
            if let searchIconImageView = rightView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                searchIconImageView.isHidden = !textField.text!.isEmpty
                isFilterSearchContact(text:textField.text!)
            }
            if let closeIconImageView = rightView.subviews.first(where: { $0 is UIImageView && $0.tag == 1 }) as? UIImageView {
                closeIconImageView.isHidden = textField.text!.isEmpty
                isFilterSearchContact(text:textField.text!)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func addButtonTapped() {
        completion(selectedUsers)
        navigationController!.popViewController(animated: true)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterDict.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateSecretGroupTableViewCell") as! CreateSecretGroupTableViewCell
        
        let publicKey = Array(filterDict.keys)[indexPath.row]
        cell.publicKey = publicKey
        let isSelected = selectedUsers.contains(publicKey)
        cell.selectionButton.isSelected = isSelected
        cell.update()
        cell.selectionButtonCallback = {
            let publicKey = Array(self.filterDict.keys)[indexPath.row]
            if !self.selectedUsers.contains(publicKey) { self.selectedUsers.insert(publicKey) } else { self.selectedUsers.remove(publicKey) }
            guard let cell = tableView.cellForRow(at: indexPath) as? CreateSecretGroupTableViewCell else { return }
            let isSelected = self.selectedUsers.contains(publicKey)
            cell.selectionButton.isSelected = isSelected
            cell.update()
        }
        
        let contact: Contact? = Storage.shared.getContact(with: publicKey)
        if let _ = contact, let isBnsUser = contact?.isBnsHolder {
            cell.profileImageView.layer.borderWidth = isBnsUser ? Values.borderThickness : 0
            cell.profileImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
            cell.verifiedImageView.isHidden = isBnsUser ? false : true
        } else {
            cell.verifiedImageView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let publicKey = Array(filterDict.keys)[indexPath.row]
        if !selectedUsers.contains(publicKey) { selectedUsers.insert(publicKey) } else { selectedUsers.remove(publicKey) }
        guard let cell = tableView.cellForRow(at: indexPath) as? CreateSecretGroupTableViewCell else { return }
        let isSelected = selectedUsers.contains(publicKey)
        cell.selectionButton.isSelected = isSelected
        cell.update()
    }
  

}
