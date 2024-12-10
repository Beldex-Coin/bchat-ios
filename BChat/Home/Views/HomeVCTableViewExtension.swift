// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        messageRequestCountLabel.text = "\(Int(messageRequestCountForMessageRequest))"
        messageRequestCountLabel.isHidden = (Int(messageRequestCountForMessageRequest) <= 0)
        messageRequestLabel.isHidden = (Int(messageRequestCountForMessageRequest) <= 0)
        showOrHideMessageRequestCollectionViewButton.isHidden = (Int(messageRequestCountForMessageRequest) <= 0)
        
        setUpNavBarSessionHeading()
        noInternetView.isHidden = NetworkReachabilityStatus.isConnectedToNetworkSignal()
        messageRequestLabelTopConstraint.isActive = false
        messageRequestLabelTopConstraint = NetworkReachabilityStatus.isConnectedToNetworkSignal() ? messageRequestLabel.pin(.top, to: .top, of: view, withInset: 16) : messageRequestLabel.pin(.top, to: .top, of: view, withInset: 16 + 69)
        collectionViewTopConstraint.isActive = false
        collectionViewTopConstraint = NetworkReachabilityStatus.isConnectedToNetworkSignal() ? messageCollectionView.pin(.top, to: .top, of: view, withInset: 38 + 8) : messageCollectionView.pin(.top, to: .top, of: view, withInset: 38 + 8 + 69)
        
        if !messageRequestLabel.isHidden {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = NetworkReachabilityStatus.isConnectedToNetworkSignal() ?  tableView.pin(.top, to: .top, of: view, withInset: 0 + 38 + 16) : tableView.pin(.top, to: .top, of: view, withInset: 0 + 38 + 16 + 69)
        } else {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = NetworkReachabilityStatus.isConnectedToNetworkSignal() ? tableView.pin(.top, to: .top, of: view, withInset: 0 + 16) : tableView.pin(.top, to: .top, of: view, withInset: 0 + 16 + 69)
        }
        self.messageCollectionView.isHidden = true
        
        switch section {
            case 0:
            if threadCountForArchivedChats > 0 {
                return 1
            } else {
                return 0
            }
            case 1: return Int(threadCount)
            default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArchiveViewCell") as! ArchiveViewCell
            cell.archivedMessageCountLabel.text = "\(threadCountForArchivedChats)"
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
        switch indexPath.section {
            case 0:
            archivedButtonTapped()
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
                return UISwipeActionsConfiguration(actions: [])
            default:
                guard let thread = self.thread(at: indexPath.row) else { return UISwipeActionsConfiguration(actions: []) }
                let delete = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, success) in
                    var message = NSLocalizedString("This cannot be undone.", comment: "")
                    if let thread = thread as? TSGroupThread, thread.isClosedGroup, thread.groupModel.groupAdminIds.contains(getUserHexEncodedPublicKey()) {
                        message = NSLocalizedString("admin_group_leave_warning", comment: "")
                    }
                    let alert = UIAlertController(title: NSLocalizedString("Delete Conversation?", comment: ""), message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.deleteThread(thread)
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
                    tableView.reloadRows(at: [indexPath], with: .fade)
                })
                pin.backgroundColor = Colors.mainBackGroundColor2
                pin.image = UIImage(named: "ic_pinNew_Home")
                //UnPin Option
                let unpin = UIContextualAction(style: .destructive, title: "Unpin", handler: { (action, view, success) in
                    thread.isPinned = false
                    thread.save()
                    self.threadViewModelCache.removeValue(forKey: thread.uniqueId!)
                    tableView.reloadRows(at: [indexPath], with: .fade)
                })
                unpin.backgroundColor = Colors.mainBackGroundColor2
                unpin.image = UIImage(named: "ic_unPinNew_Home")
                
            // Archive
            let isArchived = thread.isArchived
            let archive = UIContextualAction(style: .destructive, title: "Archive", handler: { (action, view, success) in
                thread.isArchived = true
                thread.save()
                self.threadViewModelCache.removeValue(forKey: thread.uniqueId!)
                tableView.reloadRows(at: [indexPath], with: .fade)
            })
            archive.backgroundColor = Colors.mainBackGroundColor2
            archive.image = UIImage(named: "ic_archive")
            
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
                                    tableView.reloadRows(at: [indexPath], with: .fade)
                                }
                            }
                        )
                    })
                    block.backgroundColor = Colors.mainBackGroundColor2
                    block.image = UIImage(named: "ic_blockNew_Home")
                    
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
                    unblock.image = UIImage(named: "ic_unBlockNew_Home")
                    
                    return UISwipeActionsConfiguration(actions: [ delete, (thread.isBlocked() ? unblock : block), (isArchived ? archive : archive), (isPinned ? unpin : pin) ])
                }
                else {
                    return UISwipeActionsConfiguration(actions: [ delete, (isArchived ? archive : archive), (isPinned ? unpin : pin) ])
                }
        }
    }
}
