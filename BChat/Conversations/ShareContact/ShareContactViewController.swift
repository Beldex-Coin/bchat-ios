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
    
    private var threads: YapDatabaseViewMappings!
    private var threadViewModelCache: [String: ThreadViewModel] = [:]
    private var selectedThread: TSThread?
    
    private var threadCount: UInt {
        threads.numberOfItems(inGroup: TSInboxGroup)
    }
    
    private lazy var dbConnection: YapDatabaseConnection = {
        let result = OWSPrimaryStorage.shared().newDatabaseConnection()
        result.objectCacheLimit = 500
        return result
    }()
    
    private var dbReadConnection: YapDatabaseConnection {
        return OWSPrimaryStorage.shared().dbReadConnection
    }
    
    private let contacts = ContactUtilities.getAllContacts()
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        
        setupDB()
        setupNavigation()
        setupSearchTextFeild()
        setupTableView()
        setupSendButton()
        setupNoResultsView()
    }
    
    private func setupDB() {
        dbConnection.beginLongLivedReadTransaction()
        
        // Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleYapDatabaseModifiedNotification(_:)), name: .YapDatabaseModified, object: OWSPrimaryStorage.shared().dbNotificationObject)
        
        threads = YapDatabaseViewMappings(groups: [ TSMessageRequestGroup, TSInboxGroup ], view: TSThreadDatabaseViewExtensionName)
        threads.setIsReversed(true, forGroup: TSInboxGroup)
        dbConnection.read { transaction in
            self.threads.update(with: transaction)
        }
        
        
        
        
        noContactStackView.isHidden = !threads.isEmpty()
        sendButton.isHidden = threads.isEmpty()
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
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor),
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
        tableView.reloadData()
    }

    // MARK: - TableView Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(threadCount)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShareContactTableViewCell.identifier, for: indexPath) as? ShareContactTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: contacts)

        //cell.threadViewModel = threadViewModel(at: indexPath.row)
//        cell.toggleSelection = { [weak self] in
//            guard let self = self else { return }
//            contact.isSelected.toggle()
//            if let index = self.contacts.firstIndex(where: { $0.name == contact.name && $0.address == contact.address }) {
//                self.contacts[index] = contact
//                self.filteredContacts = self.contacts
//            }
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//        }

        return cell
    }
    
    // MARK: - UITextField
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text else { return }
        if searchText.isEmpty {
            //filteredContacts = contacts
        } else {
            //filteredContacts = contacts.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        searchCloseImageView.isHidden = searchText.isEmpty
        tableView.reloadData()
    }
    
    private func reload() {
        AssertIsOnMainThread()
//        guard !isReloading else { return }
//        isReloading = true
        dbConnection.beginLongLivedReadTransaction()
        dbConnection.read { transaction in
            self.threads.update(with: transaction)
        }
        threadViewModelCache.removeAll()
        tableView.reloadData()
//        isReloading = false
    }
    
    @objc private func handleYapDatabaseModifiedNotification(_ yapDatabase: YapDatabase) {
        AssertIsOnMainThread()
        reload()
    }
    
    // MARK: - Thread
    
    private func thread(at index: Int) -> TSThread? {
        var thread: TSThread? = nil
        dbConnection.read { transaction in
            let ext = transaction.ext(TSThreadDatabaseViewExtensionName) as! YapDatabaseViewTransaction
            thread = ext.object(atRow: UInt(index), inSection: 1, with: self.threads) as? TSThread
        }
        return thread
    }
    
    private func threadViewModel(at index: Int) -> ThreadViewModel? {
        guard let thread = thread(at: index) else { return nil }
        
        if let cachedThreadViewModel = threadViewModelCache[thread.uniqueId!] {
            return cachedThreadViewModel
        } else {
            var threadViewModel: ThreadViewModel? = nil
            dbConnection.read { transaction in
                threadViewModel = ThreadViewModel(thread: thread, transaction: transaction)
            }
            threadViewModelCache[thread.uniqueId!] = threadViewModel
            return threadViewModel
        }
    }
}
