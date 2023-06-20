// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import BChatMessagingKit


class BlockedContactVC: BaseVC, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "BlockedXibCell", bundle: nil), forCellReuseIdentifier: "BlockedXibCell")
        }
    }
    
    var contacts = ContactUtilities.getAllContacts()
    var names = [String]()
    var publicKeys = [String]()
    var arrayNames = [String]()
    var arrayPublicKey = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Blocked Contacts"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.systemGray
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        
        for publicKey in contacts {
            let blockedflag = Storage.shared.getContact(with: publicKey)!.isBlocked
            if blockedflag == true {
                let Aname = Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
                names.append(Aname)
                let pukey = Storage.shared.getContact(with: publicKey)
                publicKeys.append(pukey!.bchatuser_ID)
            }
            tableView.reloadData()
        }
        let names = names.joined(separator: ",")
        var allNames = [String]()
        allNames = names.components(separatedBy: ",")
        let publicKeys = publicKeys.joined(separator: ",")
        var allpublicKeys = [String]()
        allpublicKeys = publicKeys.components(separatedBy: ",")
        arrayNames = allNames.filter({ $0 != ""})
        arrayPublicKey = allpublicKeys.filter({ $0 != ""})

    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedXibCell", for: indexPath) as! BlockedXibCell

        cell.lblname.text = arrayNames[indexPath.row]
        cell.lblname.font = .boldSystemFont(ofSize: Values.mediumFontSize)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           
           let publicKey = arrayPublicKey[indexPath.row]
           let pubname = arrayNames[indexPath.row]
           
           let unblock = UIContextualAction(style: .destructive, title: "Unblock", handler: {(action, view, success) in
               let alert = UIAlertController(title: "Unblock", message: "Are you sure you want to Unblock \(pubname)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                        
                    })
                    alert.addAction(ok)
                    let cancel = UIAlertAction(title: "Ok", style: .default, handler: { action in
                        
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
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        )
                    })
                    alert.addAction(cancel)
                    DispatchQueue.main.async(execute: {
                       self.present(alert, animated: true)
               })
           })
           unblock.backgroundColor = Colors.unimportant
           unblock.image = UIImage(named: "unblock_big")
           return UISwipeActionsConfiguration(actions: [ unblock ])
       }
       
}

