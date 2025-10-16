// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit
import BChatUIKit
import BChatMessagingKit
import BChatUtilitiesKit

enum SharedContactState: Int, CaseIterable {
    case fromAttachment
    case fromChat
}

@objc
protocol ShareContactDelegate: AnyObject {
    func sendSharedContact(with address: [String], name: [String])
}

final class ShareContactViewController: BaseVC, UITableViewDataSource, UITableViewDelegate, UISearchTextFieldDelegate {
    
    // MARK: - UI Elements

    private var tableView = UITableView()
    private var searchTextField = UITextField()
    private var sendButton = UIButton()
    private var searchCloseImageView = UIImageView()
    private let noContactStackView = UIStackView()
    
    // MARK: - Properties
    
    private var contacts: [String] = []
    private var selectedContacts: Set<String> = []

    var filteredContacts: [String] = []
    var searchText: String = ""
    var mainDict: [String: String] = [:]
    var filterDict: [String: String] = [:]
    var namesArray: [String] = []
    var state: SharedContactState?
    
    @objc
    public weak var delegate: ShareContactDelegate?
    
    // MARK: - Initialize
    
    init(state: SharedContactState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(thread:) instead.")
    }
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        self.contacts = getAllContactsWithArchiveContacts()
        setupNavigation()
        setupSearchTextFeild()
        setupTableView()
        setupSendButton()
        setupNoResultsView()
        if state == .fromAttachment {
            loadContacts()
        } else {
            sendButton.isHidden = true
        }
        
    }
    
    // MARK: - Setup UI

    private func setupNavigation() {
        setUpNavBarStyle()
        navigationItem.title = state == .fromAttachment ? "Send Contact" : "View Contacts"
        if state == .fromAttachment {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                    target: self,
                                                                    action: #selector(cancelTapped))
        }
    }

    private func setupSearchTextFeild() {
        view.addSubview(searchTextField)
        searchTextField.delegate = self
        searchTextField.isHidden = state == .fromChat
        
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
        var searchImageView = UIImageView()
        searchImageView = UIImageView(image: UIImage(named: "ic_Search_Vector_New"))
        searchImageView.frame = CGRect(x: 16, y: 0, width: 16, height: 16)
        searchImageView.contentMode = .scaleAspectFit
        paddingViewLeft.addSubview(searchImageView)
        
        // Create an UIImageView for close icon initially hidden
        searchCloseImageView = UIImageView(image: UIImage(named: "ic_closeNew"))
        searchCloseImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 14)
        searchCloseImageView.contentMode = .scaleAspectFit
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
        tableView.keyboardDismissMode = .onDrag
        tableView.register(ShareContactTableViewCell.self, forCellReuseIdentifier: ShareContactTableViewCell.identifier)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let topAnchor: NSLayoutYAxisAnchor = state == .fromChat ? view.topAnchor : searchTextField.bottomAnchor

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
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
        sendButton.isEnabled = false
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        view.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sendButton.heightAnchor.constraint(equalToConstant: 58),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
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
    
    private func loadContacts() {
        filteredContacts = contacts
        if !contacts.isEmpty {
            for i in 0...(contacts.count - 1) {
                namesArray.append(Storage.shared.getContact(with: contacts[i])?.displayName(for: .regular) ?? contacts[i])
            }
            mainDict = Dictionary(uniqueKeysWithValues: zip(contacts, namesArray))
            filterDict = mainDict
        }
        
        noContactStackView.isHidden = !filterDict.isEmpty
        sendButton.isHidden = filterDict.isEmpty || state == .fromChat
//        filterDict.count > 0 ? (noContactStackView.isHidden = true) : (noContactStackView.isHidden = false)
//        filterDict.count > 0 ? (sendButton.isHidden = false) : (sendButton.isHidden = true)
        tableView.reloadData()
    }
    
    // MARK: - Event Handlers
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func searchCloseTapped() {
        searchTextField.text = ""
        searchCloseImageView.isHidden = true
        filteredContactsBySearchText(text: searchTextField.text ?? "")
    }
    
    @objc private func sendButtonTapped() {
        guard !selectedContacts.isEmpty else { return }
        let publicKey = selectedContacts
        var publicKeyArray: [String] = Array(publicKey)
        var nameArray: [String] = []
        for i in 0...(publicKey.count - 1) {
            nameArray.append(Storage.shared.getContact(with: publicKeyArray[i])?.displayName(for: .regular) ?? publicKeyArray[i])
        }
        delegate?.sendSharedContact(with: Array(publicKey), name: nameArray)
        cancelTapped()
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
        cell.checkboxButton.isSelected = selectedContacts.contains(publicKey)
        cell.state = state
        cell.name = Array(filterDict.values)[indexPath.row]
        cell.chatButton.tag = indexPath.row
        cell.removeContactButton.tag = indexPath.row
        cell.update()
        
        if state == .fromChat {
            cell.nameLabel.text = Array(filterDict.values)[indexPath.row].firstCharacterUpperCase()
        }

        cell.checkboxToggleSelection = { [weak self] in
            guard let self = self else { return }
            updateSelectedContacts(with: indexPath)
        }
        
        cell.chatToggle = { [weak self] in
            guard let self = self else { return }
            self.chatSelectedContact(cell.chatButton.tag)
        }
        
        cell.removeContactToggle = { [weak self] in
            guard let self = self else { return }
        }

        return cell
    }
    
    // MARK: - TableView Delegate
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if state == .fromAttachment {
            updateSelectedContacts(with: indexPath)
        } else {
            chatSelectedContact(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        68
    }
    
    // MARK: -
    
    private func chatSelectedContact(_ index: Int) {
        let thread = TSContactThread.getOrCreateThread(contactBChatID: Array(filterDict.keys)[index])
        
        // show confirmation modal
        let confirmationModal: ConfirmationModal = ConfirmationModal(
            info: ConfirmationModal.Info(
                modalType: .shareContact,
                title: (Array(filterDict.values)[index].capitalized),
                body: .text("Do you want to chat with this contact now?"),
                showCondition: .disabled,
                confirmTitle: "Message",
                onConfirm: { _ in
                    CATransaction.begin()
                    CATransaction.setCompletionBlock {
                        let conversationVC = ConversationVC(thread: thread)
                        var viewControllers = self.navigationController?.viewControllers
                        if let index = viewControllers?.firstIndex(of: self) { viewControllers?.remove(at: index) }
                        viewControllers?.append(conversationVC)
                        self.navigationController?.setViewControllers(viewControllers!, animated: true)
                    }
                    CATransaction.commit()
                }, dismissHandler: {
                }
            )
        )
        present(confirmationModal, animated: true, completion:  {
        })
    }
    
    // MARK: - UITextField
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text else { return }
        filteredContactsBySearchText(text: searchText)
        searchCloseImageView.isHidden = searchText.isEmpty
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: -
    
    private func filteredContactsBySearchText(text: String) {
        searchText = text
        if searchText.isEmpty {
            namesArray = []
            loadContacts()
        } else {
            let predicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", searchText)
            filterDict = mainDict.filter { predicate.evaluate(with: $0.value) }
            noContactStackView.isHidden = !filterDict.isEmpty
        }
        tableView.reloadData()
    }
    
    private func updateSelectedContacts(with indexPath: IndexPath) {
        guard !filterDict.isEmpty else { return }
        let publicKey = Array(filterDict.keys)[indexPath.row]
        if !selectedContacts.contains(publicKey) {
            selectedContacts.insert(publicKey)
        } else {
            selectedContacts.remove(publicKey)
        }
        tableView.reloadData()
        sendButton.isEnabled = !selectedContacts.isEmpty
    }
    
    func getAllContactsWithArchiveContacts() -> [String] {
        var result: [String] = []
        Storage.read { transaction in
            TSContactThread.enumerateCollectionObjects(with: transaction) { object, _ in
                guard
                    let thread: TSContactThread = object as? TSContactThread,
                    thread.shouldBeVisible,
                    Storage.shared.getContact(
                        with: thread.contactBChatID(),
                        using: transaction
                    )?.didApproveMe == true
                else {
                    return
                }
                
                result.append(thread.contactBChatID())
            }
        }
        
        func getDisplayName(for publicKey: String) -> String {
            return Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
        }
        
        // Remove the current user
        if let index = result.firstIndex(of: getUserHexEncodedPublicKey()) {
            result.remove(at: index)
        }
        
        // Sort alphabetically
        return result.sorted { getDisplayName(for: $0) < getDisplayName(for: $1) }
    }
    
}
