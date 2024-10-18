// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import PromiseKit
import BChatMessagingKit

class CreateSecretGroupScreenVC: BaseVC, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    private lazy var groupNameTextField: UITextField = {
        let result = UITextField()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor3
        result.layer.cornerRadius = Values.buttonRadius
        result.setLeftPaddingPoints(12)
        result.attributedPlaceholder = NSAttributedString(
            string: "Enter Group name",
            attributes: [NSAttributedString.Key.foregroundColor: Colors.textFieldPlaceHolderColor]
        )
        return result
    }()
    
    private lazy var separatorView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.borderColorNew
        return stackView
    }()
    
    private lazy var searchTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(
            string: "Search Contact",
            attributes: [NSAttributedString.Key.foregroundColor: Colors.textFieldPlaceHolderColor]
        )
        result.font = Fonts.OpenSans(ofSize: 14)
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
        searchIconImageView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
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
    lazy var searchImageView: UIImageView = {
       let result = UIImageView()
       result.image = UIImage(named: "ic_search")
        result.set(.width, to: 16)
        result.set(.height, to: 16)
       result.layer.masksToBounds = true
       result.contentMode = .center
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
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.unlockButtonBackgroundColor
        button.setTitleColor(UIColor(hex: 0x6E6E7C), for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let contacts = ContactUtilities.getAllContacts()
    private var selectedContacts: Set<String> = []

    var filteredContacts: [String] = []
    var searchText: String = ""
    var mainDict: [String: String] = [:]
    var filterDict: [String: String] = [:]
    var namesArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.viewBackgroundColorSocialGroup//Colors.mainBackGroundColor4
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Secret Group"
        
        view.addSubViews(groupNameTextField, separatorView, searchTextField, bottomButtonView, searchImageView)
        bottomButtonView.addSubview(createButton)
        view.addSubview(tableView)
        
        groupNameTextField.delegate = self
        searchTextField.delegate = self
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 12.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomButtonView.topAnchor, constant: 0).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(CreateSecretGroupTableViewCell.self, forCellReuseIdentifier: "CreateSecretGroupTableViewCell")
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        
        createButton.backgroundColor = Colors.bothGreenColor
        createButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        searchImageView.isHidden = true
        
        
        NSLayoutConstraint.activate([
            
            groupNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            groupNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            groupNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            groupNameTextField.heightAnchor.constraint(equalToConstant: 48),
            
            
            separatorView.topAnchor.constraint(equalTo: groupNameTextField.bottomAnchor, constant: 14),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            searchTextField.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 14),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchTextField.heightAnchor.constraint(equalToConstant: 48),
            
            searchImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            searchImageView.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            
            bottomButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            bottomButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            bottomButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            bottomButtonView.heightAnchor.constraint(equalToConstant: 88),
            
            createButton.centerYAnchor.constraint(equalTo: bottomButtonView.centerYAnchor),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            createButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
        filteredContacts = contacts
        
        if contacts.count > 0 {
            for i in 0...(contacts.count - 1) {
                namesArray.append(Storage.shared.getContact(with: contacts[i])?.displayName(for: .regular) ?? contacts[i])
            }
            
            mainDict = Dictionary(uniqueKeysWithValues: zip(contacts, namesArray))
            filterDict = mainDict
        }
        tableView.reloadData()
    }
    
    //Close Action
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
    
    func isFilterContacts() {
        let currentText = searchTextField.text ?? ""
        searchText = currentText
        if searchText.isEmpty {
            filteredContacts = contacts
            if contacts.count > 0 {
                namesArray = []
                for i in 0...(contacts.count - 1) {
                    namesArray.append(Storage.shared.getContact(with: contacts[i])?.displayName(for: .regular) ?? contacts[i])
                }
                mainDict = Dictionary(uniqueKeysWithValues: zip(contacts, namesArray))
                filterDict = mainDict
            }
        } else {
            let predicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", searchText)
            filterDict = mainDict.filter { predicate.evaluate(with: $0.value) }
        }
        tableView.reloadData()
    }
    
    //Text Enter Action
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
    
    func isFilterSearchContact(text:String) {
        let currentText = text
        searchText = currentText
        if searchText.isEmpty {
            filteredContacts = contacts
            if contacts.count > 0 {
                namesArray = []
                for i in 0...(contacts.count - 1) {
                    namesArray.append(Storage.shared.getContact(with: contacts[i])?.displayName(for: .regular) ?? contacts[i])
                }
                mainDict = Dictionary(uniqueKeysWithValues: zip(contacts, namesArray))
                filterDict = mainDict
            }
        } else {
            let predicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", searchText)
            filterDict = mainDict.filter { predicate.evaluate(with: $0.value) }
        }
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterDict.count//filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateSecretGroupTableViewCell") as! CreateSecretGroupTableViewCell
        let publicKey = Array(filterDict.keys)[indexPath.row]
        cell.publicKey = publicKey
        let isSelected = selectedContacts.contains(publicKey)
        cell.selectionButton.isSelected = isSelected
        cell.update()
        let contact: Contact? = Storage.shared.getContact(with: publicKey)
        if let _ = contact, let isBnsUser = contact?.isBnsHolder {
            cell.profileImageView.layer.borderWidth = isBnsUser ? 3 : 0
            cell.profileImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
            cell.verifiedImageView.isHidden = isBnsUser ? false : true
        } else {
            cell.verifiedImageView.isHidden = true
        }
        cell.selectionButtonCallback = {
            if self.filterDict.count > 0 {
                let publicKey = Array(self.filterDict.keys)[indexPath.row]
                if !self.selectedContacts.contains(publicKey) { self.selectedContacts.insert(publicKey) } else { self.selectedContacts.remove(publicKey) }
                guard let cell = tableView.cellForRow(at: indexPath) as? CreateSecretGroupTableViewCell else { return }
                let isSelected = self.selectedContacts.contains(publicKey)
                cell.selectionButton.isSelected = isSelected
                cell.update()
            }
        }
        return cell
    }
    
    fileprivate func tableViewWasTouched(_ tableView: UITableView) {
        if groupNameTextField.isFirstResponder {
            groupNameTextField.resignFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.filterDict.count > 0 {
            let publicKey = Array(filterDict.keys)[indexPath.row]
            if !selectedContacts.contains(publicKey) { selectedContacts.insert(publicKey) } else { selectedContacts.remove(publicKey) }
            guard let cell = tableView.cellForRow(at: indexPath) as? CreateSecretGroupTableViewCell else { return }
            let isSelected = selectedContacts.contains(publicKey)
            cell.selectionButton.isSelected = isSelected
            cell.update()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let str = groupNameTextField.text!
        if str.count == 0 {
            createButton.backgroundColor = Colors.bothGreenColor
            createButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
        } else {
            createButton.backgroundColor = Colors.bothGreenColor
            createButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the current text in the search field
        if textField == searchTextField {
            searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if searchText.isEmpty {
                // If the search text is empty, show all currencies without filtering
                filteredContacts = contacts
                if contacts.count > 0 {
                    namesArray = []
                    for i in 0...(contacts.count - 1) {
                        namesArray.append(Storage.shared.getContact(with: contacts[i])?.displayName(for: .regular) ?? contacts[i])
                    }
                    
                    mainDict = Dictionary(uniqueKeysWithValues: zip(contacts, namesArray))
                    filterDict = mainDict
                }
                
            } else {
                
                // Update the filteredCurrencyArray based on the search text
                let predicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", searchText)
                filterDict = mainDict.filter { predicate.evaluate(with: $0.value) }
                
            }
        }
        DispatchQueue.main.async {
            // Reload the table view with the filtered or unfiltered data
            self.tableView.reloadData()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: Button Actions :-
    @objc private func createButtonTapped() {
        func showError(title: String, message: String = "") {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
            presentAlert(alert)
        }
        guard let name = groupNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.count > 0 else {
            return showError(title: NSLocalizedString("vc_create_closed_group_group_name_missing_error", comment: ""))
        }
        guard name.count < 64 else {
            return showError(title: NSLocalizedString("vc_create_closed_group_group_name_too_long_error", comment: ""))
        }
        guard selectedContacts.count >= 1 else {
            return showError(title: "Please pick at least 1 group member")
        }
        guard selectedContacts.count < 100 else { // Minus one because we're going to include self later
            return showError(title: NSLocalizedString("vc_create_closed_group_too_many_group_members_error", comment: ""))
        }
        let selectedContacts = self.selectedContacts
        let message: String? = (selectedContacts.count > 20) ? "Please wait while the group is created..." : nil
        var promise: Promise<TSGroupThread>!
        ModalActivityIndicatorViewController.present(fromViewController: navigationController!, message: message) { [weak self] _ in
            Storage.write(with: { transaction in
                promise = MessageSender.createClosedGroup(name: name, members: selectedContacts, transaction: transaction)
            }, completion: {
                let _ = promise.done(on: DispatchQueue.main) { thread in
                    MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                    SignalApp.shared().presentConversation(for: thread, action: .compose, animated: false)
                }
                promise.catch(on: DispatchQueue.main) { error in
                    self?.dismiss(animated: true, completion: nil) // Dismiss the loader
                    if error.localizedDescription == "HTTP request failed with status code: 0." {
                        self?.navigationController?.popViewController(animated: true)
                        return
                    }
                    let title = "Couldn't Create Group"
                    let message = "Please check your internet connection and try again."
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
                    self?.presentAlert(alert)
                }
            })
        }
    }

}
