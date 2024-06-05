// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import BChatMessagingKit

class NewBlockedContactVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    private lazy var bottomButtonView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private lazy var unblockButton: UIButton = {
        let button = UIButton()
        button.setTitle("Unblock selected", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.unlockButtonBackgroundColor//UIColor(hex: 0x282836)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.bothGreenColor, for: .normal)
        button.addTarget(self, action: #selector(unblockButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var noContactsTitleLabel: UILabel = {
        let result = UILabel()
        result.text = "No blocked contact found"
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.isHidden = true
        return result
    }()
    
    
    var isSelectionEnable = false
    var contacts = ContactUtilities.getAllContacts()
    var arrayNames = [String]()
    var arrayPublicKey = [String]()
    var selectedarrayPublicKey: Set<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2//UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Blocked contacts"
        
        view.addSubview(tableView)
        view.addSubview(bottomButtonView)
        bottomButtonView.addSubview(unblockButton)
        view.addSubview(noContactsTitleLabel)
            
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomButtonView.topAnchor, constant: 0).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(NewBlockContactTableViewCell.self, forCellReuseIdentifier: "NewBlockContactTableViewCell")
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        NSLayoutConstraint.activate([
        bottomButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        bottomButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
        bottomButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        bottomButtonView.heightAnchor.constraint(equalToConstant: 88),
        
        unblockButton.centerYAnchor.constraint(equalTo: bottomButtonView.centerYAnchor),
        unblockButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
        unblockButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
        unblockButton.heightAnchor.constraint(equalToConstant: 58),
        
        noContactsTitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        noContactsTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        self.getBlockedContacts()
        
        self.updateRighBarButton(isSelectionEnable: self.isSelectionEnable)
        
    }
    

    func updateRighBarButton(isSelectionEnable : Bool) {
        var rightBarButtonItems: [UIBarButtonItem] = []
        if isSelectionEnable {
            let selectionButton = UIBarButtonItem(image: UIImage(named: "ic_check_all_enable")!, style: .plain, target: self, action: #selector(selectionButtonTapped))
            rightBarButtonItems.append(selectionButton)
        } else {
            let selectionButton = UIBarButtonItem(image: UIImage(named: "ic_check_all")!, style: .plain, target: self, action: #selector(selectionButtonTapped))
            rightBarButtonItems.append(selectionButton)
        }
        self.bottomButtonView.isHidden = !isSelectionEnable
        if arrayNames.count != 0 {
            navigationItem.rightBarButtonItems = rightBarButtonItems
            self.noContactsTitleLabel.isHidden = true
        } else {
            navigationItem.rightBarButtonItems = []
            self.noContactsTitleLabel.isHidden = false
        }
    }
    
    
    func getBlockedContacts() {
        var names = [String]()
        var publicKeys = [String]()
        for publicKey in self.contacts {
            let blockedflag = Storage.shared.getContact(with: publicKey)!.isBlocked
            if blockedflag == true {
                let userName = Storage.shared.getContact(with: publicKey)?.name
                names.append(userName!)
                let pukey = Storage.shared.getContact(with: publicKey)
                publicKeys.append(pukey!.bchatID)
            }
            self.tableView.reloadData()
        }
        let userNames = names.joined(separator: ",")
        let allNames = userNames.components(separatedBy: ",")
        let userPublicKeys = publicKeys.joined(separator: ",")
        let allpublicKeys = userPublicKeys.components(separatedBy: ",")
        self.arrayNames = allNames.filter({ $0 != ""})
        self.arrayPublicKey = allpublicKeys.filter({ $0 != ""})
        self.tableView.reloadData()
    }
    
    
    // MARK: Button Actions :-
    @objc private func unblockButtonTapped() {
        if self.selectedarrayPublicKey.count > 0 {
            for i in 0...(selectedarrayPublicKey.count - 1) {
                let publicKey = Array(selectedarrayPublicKey)[i]//selectedarrayPublicKey[i]
                Storage.shared.write(
                    with: { transaction in
                        guard  let transaction = transaction as? YapDatabaseReadWriteTransaction, let contact: Contact = Storage.shared.getContact(with: publicKey, using: transaction) else {
                            return
                        }
                        contact.isBlocked = false
                        Storage.shared.setContact(contact, using: transaction as Any)
                    },
                    completion: {
                        MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                        DispatchQueue.main.async {
                            self.getBlockedContacts()
                            self.updateRighBarButton(isSelectionEnable: false)
                        }
                    }
                )
            }
            self.getBlockedContacts()
            self.updateRighBarButton(isSelectionEnable: false)
            selectedarrayPublicKey = []
        }
    }
    
    @objc func selectionButtonTapped() {
        self.isSelectionEnable = !self.isSelectionEnable
        self.updateRighBarButton(isSelectionEnable: self.isSelectionEnable)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewBlockContactTableViewCell") as! NewBlockContactTableViewCell
        
        if self.isSelectionEnable {
            cell.selectionButton.isHidden = false
            cell.unblockButton.isHidden = true
        } else {
            cell.selectionButton.isSelected = false
            cell.selectionButton.isHidden = true
            cell.unblockButton.isHidden = false
        }
        
        
        let publicKey = arrayPublicKey[indexPath.row]
        let isSelected = selectedarrayPublicKey.contains(publicKey)
        cell.selectionButton.isSelected = isSelected
        cell.profileImageView.image = Identicon.generatePlaceholderIcon(seed: publicKey, text: arrayNames[indexPath.row], size: 30)
        
        cell.nameLabel.text = arrayNames[indexPath.row]
        cell.unblockCallback = {
            let publicKey = self.arrayPublicKey[indexPath.row]
            Storage.shared.write(
                with: { transaction in
                    guard  let transaction = transaction as? YapDatabaseReadWriteTransaction, let contact: Contact = Storage.shared.getContact(with: publicKey, using: transaction) else {
                        return
                    }
                    contact.isBlocked = false
                    Storage.shared.setContact(contact, using: transaction as Any)
                },
                completion: {
                    MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [ indexPath ], with: UITableView.RowAnimation.fade)
                        self.getBlockedContacts()
                        self.updateRighBarButton(isSelectionEnable: false)
                    }
                }
            )
            self.getBlockedContacts()
            self.updateRighBarButton(isSelectionEnable: false)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let publicKey = arrayPublicKey[indexPath.row]
        if !selectedarrayPublicKey.contains(publicKey) { selectedarrayPublicKey.insert(publicKey) } else { selectedarrayPublicKey.remove(publicKey) }
        guard let cell = tableView.cellForRow(at: indexPath) as? NewBlockContactTableViewCell else { return }
        let isSelected = selectedarrayPublicKey.contains(publicKey)
        cell.selectionButton.isSelected = isSelected
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
