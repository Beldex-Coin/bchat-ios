// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit
import BChatUIKit
import BChatMessagingKit
import BChatUtilitiesKit

final class ShareContactViewController: BaseVC, UITableViewDataSource, UITableViewDelegate, UISearchTextFieldDelegate {

    private var tableView = UITableView()
    private var searchTextField = UITextField()
    private var sendButton = UIButton()
    private var searchCloseImageView = UIImageView()
    private let noContactStackView = UIStackView()
    
    private let contacts = ContactUtilities.getAllContacts()
    private var selectedContacts: Set<String> = []

    var filteredContacts: [String] = []
    var searchText: String = ""
    var mainDict: [String: String] = [:]
    var filterDict: [String: String] = [:]
    var namesArray: [String] = []
    
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        
        setupNavigation()
        setupSearchTextFeild()
        setupTableView()
        setupSendButton()
        setupNoResultsView()
        
        filteredContacts = contacts
        if contacts.count > 0 {
            for i in 0...(contacts.count - 1) {
                namesArray.append(Storage.shared.getContact(with: contacts[i])?.displayName(for: .regular) ?? contacts[i])
            }
            mainDict = Dictionary(uniqueKeysWithValues: zip(contacts, namesArray))
            filterDict = mainDict
        }
        filterDict.count > 0 ? (noContactStackView.isHidden = true) : (noContactStackView.isHidden = false)
        filterDict.count > 0 ? (sendButton.isHidden = false) : (sendButton.isHidden = true)
        tableView.reloadData()
    }

    private func setupNavigation() {
        setUpNavBarStyle()
        navigationItem.title = "Send Contact"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                target: self,
                                                                action: #selector(CancelTapped))
    }

    private func setupSearchTextFeild() {
        
        view.addSubview(searchTextField)
        searchTextField.delegate = self
        
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search Contact",
            attributes: [NSAttributedString.Key.foregroundColor: Colors.textFieldPlaceHolderColor]
        )
        searchTextField.font = Fonts.regularOpenSans(ofSize: 14)
        searchTextField.layer.borderColor = Colors.borderColorNew.cgColor
        searchTextField.backgroundColor = Colors.unlockButtonBackgroundColor
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.layer.cornerRadius = 24
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = Colors.borderColor3.cgColor
        searchTextField.textColor = Colors.titleColor3
        searchTextField.textAlignment = .left
        
        // Add left padding
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 16))
        searchTextField.leftView = paddingViewLeft
        searchTextField.leftViewMode = .always
        
        // Add right padding
        let paddingViewRight = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 14))
        searchTextField.rightView = paddingViewRight
        searchTextField.rightViewMode = .always
        
        // Create an UIImageView and set its image for search icon
        searchCloseImageView = UIImageView(image: UIImage(named: "ic_Search_Vector_New"))
        searchCloseImageView.frame = CGRect(x: 16, y: 0, width: 16, height: 16)
        searchCloseImageView.contentMode = .scaleAspectFit
        paddingViewLeft.addSubview(searchCloseImageView)
        
        // Create an UIImageView for close icon initially hidden
        searchCloseImageView = UIImageView(image: UIImage(named: "ic_closeNew"))
        searchCloseImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 14)
        searchCloseImageView.contentMode = .scaleAspectFit
        searchCloseImageView.tag = 1 // Set a tag to distinguish it from the search icon
        searchCloseImageView.isHidden = true
        paddingViewRight.addSubview(searchCloseImageView)
        
        // Add tap gesture recognizer to closeIconImageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchCloseTapped))
        searchCloseImageView.isUserInteractionEnabled = true
        searchCloseImageView.addGestureRecognizer(tapGestureRecognizer)
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            searchTextField.heightAnchor.constraint(equalToConstant: 48),
        ])
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ShareContactTableViewCell.self, forCellReuseIdentifier: ShareContactTableViewCell.identifier)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }

    private func setupSendButton() {
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = Colors.bothGreenColor
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 12
        view.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sendButton.heightAnchor.constraint(equalToConstant: 58),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupNoResultsView() {
        // No Contact Image
        let noContactImageView = UIImageView()
        noContactImageView.image = UIImage(named: "no_contact")
        noContactImageView.contentMode = .scaleAspectFit
        
        // No Contact Label
        let noContactLabel = UILabel()
        noContactLabel.text = "No Contact Found!"
        noContactLabel.textColor = Colors.noDataLabelColor
        noContactLabel.font = Fonts.semiOpenSans(ofSize: 16)
        noContactLabel.textAlignment = .center
        
        // Stack View
        noContactStackView.axis = .vertical
        noContactStackView.alignment = .center
        noContactStackView.spacing = 12
        noContactStackView.translatesAutoresizingMaskIntoConstraints = false
        noContactStackView.addArrangedSubview(noContactImageView)
        noContactStackView.addArrangedSubview(noContactLabel)
        noContactStackView.isHidden = true
        view.addSubview(noContactStackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            noContactStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noContactStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noContactImageView.heightAnchor.constraint(equalToConstant: 80),
            noContactImageView.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Event Handlers
    
    @objc private func CancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func searchCloseTapped() {
        searchTextField.text = ""
        searchCloseImageView.isHidden = true
        filteredContactsBySearchText(text: searchTextField.text ?? "")
    }

    // MARK: - TableView Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterDict.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShareContactTableViewCell.identifier, for: indexPath) as? ShareContactTableViewCell else {
            return UITableViewCell()
        }
        
        let publicKey = Array(filterDict.keys)[indexPath.row]
        cell.publicKey = publicKey
        let isSelected = selectedContacts.contains(publicKey)
        cell.checkbox.isSelected = isSelected
        cell.update()
        let contact: Contact? = Storage.shared.getContact(with: publicKey)
        if let _ = contact, let isBnsUser = contact?.isBnsHolder {
            cell.profileImageView.layer.borderWidth = isBnsUser ? Values.borderThickness : 0
            cell.profileImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
            cell.verifiedImageView.isHidden = isBnsUser ? false : true
        } else {
            cell.verifiedImageView.isHidden = true
        }

        cell.toggleSelection = { [weak self] in
            guard let self = self else { return }
            if self.filterDict.count > 0 {
                let publicKey = Array(self.filterDict.keys)[indexPath.row]
                if !self.selectedContacts.contains(publicKey) {
                    self.selectedContacts.removeAll()
                    self.selectedContacts.insert(publicKey)
                } else {
                    self.selectedContacts.remove(publicKey)
                }
                self.tableView.reloadData()
            }
        }

        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.filterDict.count > 0 {
            let publicKey = Array(filterDict.keys)[indexPath.row]
            if !selectedContacts.contains(publicKey) {
                selectedContacts.removeAll()
                selectedContacts.insert(publicKey)
            } else {
                selectedContacts.remove(publicKey)
            }
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    // MARK: - UITextField
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text else { return }
        filteredContactsBySearchText(text:textField.text!)
        searchCloseImageView.isHidden = searchText.isEmpty
    }
    
    func filteredContactsBySearchText(text:String) {
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
    

}
