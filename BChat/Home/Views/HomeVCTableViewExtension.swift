// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        messageRequestCountLabel.text = "\(Int(unreadMessageRequestCount))"
        messageRequestCountLabel.isHidden = (Int(unreadMessageRequestCount) <= 0)
        messageRequestLabel.isHidden = (Int(unreadMessageRequestCount) <= 0)
        showOrHideMessageRequestCollectionViewButton.isHidden = (Int(unreadMessageRequestCount) <= 0)
        
        if !messageRequestLabel.isHidden {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0 + 38 + 16)
        } else {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0 + 16)
        }
        self.messageCollectionView.isHidden = true
        
        switch section {
            case 0:
                return 0
            case 1: return Int(threadCount)
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageRequestsCell.reuseIdentifier) as! MessageRequestsCell
            cell.update(with: Int(unreadMessageRequestCount))
            
            let logoName = isLightMode ? "arrowmsg1" : "arrowmsg2"
            let image = UIImage(named: logoName)!
            let checkmark = UIImageView(frame:CGRect(x:0, y:0, width:(image.size.width), height:(image.size.height)));
            checkmark.image = image
            cell.accessoryView = checkmark
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as! HomeTableViewCell
            cell.threadViewModel = threadViewModel(at: indexPath.row)
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !mainButtonPopUpView.isHidden && !self.isTapped {
            isTapped = false
            mainButtonPopUpView.isHidden = true
            mainButton.setImage(UIImage(named: "ic_HomeVCLogo"), for: .normal)
            return
        }
        if mainButtonPopUpView.isHidden && self.isTapped {
            isTapped = false
            return
        }
        isTapped = false
        switch indexPath.section {
            case 0:
                let viewController: MessageRequestsViewController = MessageRequestsViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
                return
            default:
                guard let thread = self.thread(at: indexPath.row) else { return }
                show(thread, with: ConversationViewAction.none, highlightedMessageID: nil, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
            case 0:
                let hide = UIContextualAction(style: .destructive, title: "Hide", handler: { (action, view, success) in
                    let alert = UIAlertController(title: "Hide Message request?", message: "Once they are hidden,you can access them from Settings > Message Requests.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "No", style: .default, handler: { action in
                    })
                    alert.addAction(ok)
                    let cancel = UIAlertAction(title: "Yes", style: .default, handler: { action in
                        CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] = true
                        // Animate the row removal
                        self.updateTableViewCell(indexPath)
                    })
                    cancel.setValue(UIColor.red, forKey: "titleTextColor")
                    alert.addAction(cancel)
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true)
                    })
                })
                hide.backgroundColor = Colors.destructive
                return UISwipeActionsConfiguration(actions: [hide])
            default:
                guard let thread = self.thread(at: indexPath.row) else { return UISwipeActionsConfiguration(actions: []) }
                let delete = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, success) in
                    var message = NSLocalizedString("This cannot be undone.", comment: "")
                    if let thread = thread as? TSGroupThread, thread.isClosedGroup, thread.groupModel.groupAdminIds.contains(getUserHexEncodedPublicKey()) {
                        message = NSLocalizedString("admin_group_leave_warning", comment: "")
                    }
                    let alert = UIAlertController(title: NSLocalizedString("Delete Conversation?", comment: ""), message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { [weak self] _ in
                        self?.delete(thread)
                    })
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { _ in })
                    self.presentAlert(alert)
                })
                delete.backgroundColor = Colors.mainBackGroundColor2
                delete.image = UIImage(named: "ic_delete_new")
                let isPinned = thread.isPinned
                let pin = UIContextualAction(style: .destructive, title: "Pin", handler: { (action, view, success) in
                    thread.isPinned = true
                    thread.save()
                    self.threadViewModelCache.removeValue(forKey: thread.uniqueId!)
                    tableView.reloadRows(at: [ indexPath ], with: UITableView.RowAnimation.fade)
                })
                pin.backgroundColor = Colors.mainBackGroundColor2
                pin.image = UIImage(named: "Pin_menu")
                //UnPin Option
                let unpin = UIContextualAction(style: .destructive, title: "Unpin", handler: { (action, view, success) in
                    thread.isPinned = false
                    thread.save()
                    self.threadViewModelCache.removeValue(forKey: thread.uniqueId!)
                    tableView.reloadRows(at: [ indexPath ], with: UITableView.RowAnimation.fade)
                })
                unpin.backgroundColor = Colors.mainBackGroundColor2
                unpin.image = UIImage(named: "ic_unpin")
                
                if let thread = thread as? TSContactThread, !thread.isNoteToSelf() {
                    let publicKey = thread.contactBChatID()
                    
                    let block = UIContextualAction(style: .destructive, title: "Block", handler: { (action, view, success) in
                        Storage.shared.write(
                            with: { transaction in
                                guard  let transaction = transaction as? YapDatabaseReadWriteTransaction, let contact: Contact = Storage.shared.getContact(with: publicKey, using: transaction) else {
                                    return
                                }
                                contact.isBlocked = true
                                Storage.shared.setContact(contact, using: transaction as Any)
                            },
                            completion: {
                                MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                                DispatchQueue.main.async {
                                    tableView.reloadRows(at: [ indexPath ], with: UITableView.RowAnimation.fade)
                                }
                            }
                        )
                    })
                    block.backgroundColor = Colors.mainBackGroundColor2
                    block.image = UIImage(named: "block")
                    
                    let unblock = UIContextualAction(style: .destructive, title: "Unblock", handler: { (action, view, success) in
                        
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
                                }
                            }
                        )
                    })
                    unblock.backgroundColor = Colors.mainBackGroundColor2
                    unblock.image = UIImage(named: "unblock_big")
                    
                    return UISwipeActionsConfiguration(actions: [ delete, (thread.isBlocked() ? unblock : block), (isPinned ? unpin : pin) ])
                }
                else {
                    return UISwipeActionsConfiguration(actions: [ delete, (isPinned ? unpin : pin) ])
                }
        }
    }
}