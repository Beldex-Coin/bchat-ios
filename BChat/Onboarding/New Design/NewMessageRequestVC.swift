// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import BChatMessagingKit
import PromiseKit

class NewMessageRequestVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    
    
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
     
    lazy var iconImageView: UIImageView = {
       let result = UIImageView()
       result.image = UIImage(named: "no_messgae_rqst")
        result.set(.width, to: 80)
        result.set(.height, to: 80)
       result.layer.masksToBounds = true
       result.contentMode = .scaleToFill
       return result
   }()
    
    private lazy var messageLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "No Pending message Requests!"
        result.adjustsFontSizeToFitWidth = true
        return result
    }()

    
    
    
    private var threads: YapDatabaseViewMappings! =  {
        let result = YapDatabaseViewMappings(groups: [ TSMessageRequestGroup ], view: TSThreadDatabaseViewExtensionName)
        result.setIsReversed(true, forGroup: TSMessageRequestGroup)
        return result
    }()
    private var threadViewModelCache: [String: ThreadViewModel] = [:] // Thread ID to ThreadViewModel
    private var tableViewTopConstraint: NSLayoutConstraint!
    
    private var messageRequestCount: UInt {
        threads.numberOfItems(inGroup: TSMessageRequestGroup)
    }
    
    private lazy var dbConnection: YapDatabaseConnection = {
        let result = OWSPrimaryStorage.shared().newDatabaseConnection()
        result.objectCacheLimit = 500
        
        return result
    }()
    
    
    var tappedIndex = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0x111119)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Message Request", style: .plain, target: nil, action: nil)
        
        
        view.addSubview(tableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteMessageRequestTapped(_:)), name: Notification.Name(rawValue: "deleteMessageRequestTapped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(acceptMessageRequestTapped(_:)), name: Notification.Name(rawValue: "acceptMessageRequestTapped"), object: nil)
        
            
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 22.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(NewMessageRequestTableViewCell.self, forCellReuseIdentifier: "NewMessageRequestTableViewCell")
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        view.addSubview(backGroundView)
        backGroundView.addSubViews(iconImageView, messageLabel)
        self.backGroundView.isHidden = true
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            iconImageView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 0),
            iconImageView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 22),
            messageLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: 0),
            
            ])
        
//        if array.count == 0 {
//            self.tableView.isHidden = true
//            self.backGroundView.isHidden = false
//        }
        
        // Notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleYapDatabaseModifiedNotification(_:)),
            name: .YapDatabaseModified,
            object: OWSPrimaryStorage.shared().dbNotificationObject
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileDidChangeNotification(_:)),
            name: NSNotification.Name(rawValue: kNSNotificationName_OtherUsersProfileDidChange),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBlockedContactsUpdatedNotification(_:)),
            name: .blockedContactsUpdated,
            object: nil
        )
        
        reload()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(messageRequestCount)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewMessageRequestTableViewCell") as! NewMessageRequestTableViewCell
        
        cell.threadViewModel = threadViewModel(at: indexPath.row)
        
        cell.acceptCallback = {
            self.tappedIndex = indexPath.row
            let vc = AcceptMessageRequestPopUp()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        
        cell.deleteCallback = {
            self.tappedIndex = indexPath.row
            let vc = DeleteMessageRequestPopUp()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        
        cell.blockCallback = {
            self.tappedIndex = indexPath.row
            let vc = BlockMessageRequestPopUp()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        
        return cell
    }
    
    
    @objc func acceptMessageRequestTapped(_ notification: Notification) {
        guard let thread = self.thread(at: self.tappedIndex) else { return }
        let promise: Promise<Void> = self.approveMessageRequestIfNeeded(
            for: thread,
            isNewThread: false,
            timestamp: NSDate.millisecondTimestamp()
        )
        
        // Show an error indicating that approving the thread failed
        promise.catch(on: DispatchQueue.main) { [weak self] _ in
            let alert = UIAlertController(title: "BChat", message: NSLocalizedString("MESSAGE_REQUESTS_APPROVAL_ERROR_MESSAGE", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
        promise.retainUntilComplete()
        self.tableView.reloadData()
    }
    
    @objc func deleteMessageRequestTapped(_ notification: Notification) {
        guard let thread = self.thread(at: self.tappedIndex) else { return }
        self.delete(thread)
        self.tableView.reloadData()
    }
    
    
    
    // MARK: - Updating
    
    private func reload() {
        AssertIsOnMainThread()
        dbConnection.beginLongLivedReadTransaction() // Jump to the latest commit
        dbConnection.read { transaction in
            self.threads.update(with: transaction)
        }
        threadViewModelCache.removeAll()
        tableView.reloadData()
        backGroundView.isHidden = (messageRequestCount != 0)
    }
    
    @objc private func handleYapDatabaseModifiedNotification(_ yapDatabase: YapDatabase) {
        // NOTE: This code is very finicky and crashes easily. Modify with care.
        AssertIsOnMainThread()
        
        // If we don't capture `threads` here, a race condition can occur where the
        // `thread.snapshotOfLastUpdate != firstSnapshot - 1` check below evaluates to
        // `false`, but `threads` then changes between that check and the
        // `ext.getSectionChanges(&sectionChanges, rowChanges: &rowChanges, for: notifications, with: threads)`
        // line. This causes `tableView.endUpdates()` to crash with an `NSInternalInconsistencyException`.
        let threads = threads!
        
        // Create a stable state for the connection and jump to the latest commit
        let notifications = dbConnection.beginLongLivedReadTransaction()
        
        guard !notifications.isEmpty else { return }
        
        let ext = dbConnection.ext(TSThreadDatabaseViewExtensionName) as! YapDatabaseViewConnection
        let hasChanges = ext.hasChanges(forGroup: TSMessageRequestGroup, in: notifications)
        
        guard hasChanges else { return }
        
        if let firstChangeSet = notifications[0].userInfo {
            let firstSnapshot = firstChangeSet[YapDatabaseSnapshotKey] as! UInt64
            
            if threads.snapshotOfLastUpdate != firstSnapshot - 1 {
                return reload() // The code below will crash if we try to process multiple commits at once
            }
        }
        
        var sectionChanges = NSArray()
        var rowChanges = NSArray()
        ext.getSectionChanges(&sectionChanges, rowChanges: &rowChanges, for: notifications, with: threads)
        
        guard sectionChanges.count > 0 || rowChanges.count > 0 else { return }
        
        tableView.beginUpdates()
        
        rowChanges.forEach { rowChange in
            let rowChange = rowChange as! YapDatabaseViewRowChange
            let key = rowChange.collectionKey.key
            threadViewModelCache[key] = nil
            switch rowChange.type {
                case .delete: tableView.deleteRows(at: [ rowChange.indexPath! ], with: UITableView.RowAnimation.automatic)
                case .insert: tableView.insertRows(at: [ rowChange.newIndexPath! ], with: UITableView.RowAnimation.automatic)
                case .update: tableView.reloadRows(at: [ rowChange.indexPath! ], with: UITableView.RowAnimation.automatic)
                default: break
            }
        }
        tableView.endUpdates()
        
        // HACK: Moves can have conflicts with the other 3 types of change.
        // Just batch perform all the moves separately to prevent crashing.
        // Since all the changes are from the original state to the final state,
        // it will still be correct if we pick the moves out.
        
        tableView.beginUpdates()
        
        rowChanges.forEach { rowChange in
            let rowChange = rowChange as! YapDatabaseViewRowChange
            let key = rowChange.collectionKey.key
            threadViewModelCache[key] = nil
            
            switch rowChange.type {
                case .move: tableView.moveRow(at: rowChange.indexPath!, to: rowChange.newIndexPath!)
                default: break
            }
        }
        
        tableView.endUpdates()
        backGroundView.isHidden = (messageRequestCount != 0)
    }
    
    @objc private func handleProfileDidChangeNotification(_ notification: Notification) {
        tableView.reloadData() // TODO: Just reload the affected cell
    }
    
    @objc private func handleBlockedContactsUpdatedNotification(_ notification: Notification) {
        tableView.reloadData() // TODO: Just reload the affected cell
    }

    @objc override internal func handleAppModeChangedNotification(_ notification: Notification) {
        super.handleAppModeChangedNotification(notification)
        
       
        tableView.reloadData()
    }
    
    // MARK: - Interaction
    
    private func updateContactAndThread(thread: TSThread, with transaction: YapDatabaseReadWriteTransaction, onComplete: ((Bool) -> ())? = nil) {
        guard let contactThread: TSContactThread = thread as? TSContactThread else {
            onComplete?(false)
            return
        }
        
        var needsSync: Bool = false
        
        // Update the contact
        let bchatId: String = contactThread.contactBChatID()
        
        if let contact: Contact = Storage.shared.getContact(with: bchatId), (contact.isApproved || !contact.isBlocked) {
            contact.isApproved = false
            contact.isBlocked = true
            
            Storage.shared.setContact(contact, using: transaction)
            needsSync = true
        }
        
        // Delete all thread content
        thread.removeAllThreadInteractions(with: transaction)
        thread.remove(with: transaction)
        
        onComplete?(needsSync)
    }
    
    @objc private func clearAllTapped() {
        let threadCount: Int = Int(messageRequestCount)
        let threads: [TSThread] = (0..<threadCount).compactMap { self.thread(at: $0) }
        var needsSync: Bool = false
        
        let alertVC: UIAlertController = UIAlertController(title: NSLocalizedString("MESSAGE_REQUESTS_CLEAR_ALL_CONFIRMATION_TITLE", comment: ""), message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: NSLocalizedString("MESSAGE_REQUESTS_CLEAR_ALL_CONFIRMATION_ACTON", comment: ""), style: .destructive) { _ in
            // Clear the requests
            Storage.write(
                with: { [weak self] transaction in
                    threads.forEach { thread in
                        if let uniqueId: String = thread.uniqueId {
                            Storage.shared.cancelPendingMessageSendJobs(for: uniqueId, using: transaction)
                        }
                        self?.updateContactAndThread(thread: thread, with: transaction) { threadNeedsSync in
                            if threadNeedsSync {
                                needsSync = true
                            }
                        }
                        // Block the contact
                        if
                            let bchatId: String = (thread as? TSContactThread)?.contactBChatID(),
                            !thread.isBlocked(),
                            let contact: Contact = Storage.shared.getContact(with: bchatId, using: transaction)
                        {
                            contact.isBlocked = true
                            Storage.shared.setContact(contact, using: transaction)
                            needsSync = true
                        }
                    }
                },
                completion: {
                    // Force a config sync
                    if needsSync {
                        MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                    }
                }
            )
        })
        alertVC.addAction(UIAlertAction(title: NSLocalizedString("TXT_CANCEL_TITLE", comment: ""), style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func delete(_ thread: TSThread) {
        guard let uniqueId: String = thread.uniqueId else { return }
        
        Storage.write(
            with: { [weak self] transaction in
                Storage.shared.cancelPendingMessageSendJobs(for: uniqueId, using: transaction)
                self?.updateContactAndThread(thread: thread, with: transaction)
                
                // Block the contact
                if
                    let bchatId: String = (thread as? TSContactThread)?.contactBChatID(),
                    !thread.isBlocked(),
                    let contact: Contact = Storage.shared.getContact(with: bchatId, using: transaction)
                {
                    contact.isBlocked = true
                    Storage.shared.setContact(contact, using: transaction)
                }
            },
            completion: {
                // Force a config sync
                MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
            }
        )
    }
    
    // MARK: - Convenience

    private func thread(at index: Int) -> TSThread? {
        var thread: TSThread? = nil
        
        dbConnection.read { transaction in
            let ext: YapDatabaseViewTransaction? = transaction.ext(TSThreadDatabaseViewExtensionName) as? YapDatabaseViewTransaction
            thread = ext?.object(atRow: UInt(index), inSection: 0, with: self.threads) as? TSThread
        }
        
        return thread
    }
    
    private func threadViewModel(at index: Int) -> ThreadViewModel? {
        guard let thread = thread(at: index), let uniqueId: String = thread.uniqueId else { return nil }
        
        if let cachedThreadViewModel = threadViewModelCache[uniqueId] {
            return cachedThreadViewModel
        }
        else {
            var threadViewModel: ThreadViewModel? = nil
            dbConnection.read { transaction in
                threadViewModel = ThreadViewModel(thread: thread, transaction: transaction)
            }
            threadViewModelCache[uniqueId] = threadViewModel
            
            return threadViewModel
        }
    }
 

}




extension NewMessageRequestVC {
    
    fileprivate func approveMessageRequestIfNeeded(for thread: TSThread?, isNewThread: Bool, timestamp: UInt64) -> Promise<Void> {
        guard let contactThread: TSContactThread = thread as? TSContactThread else { return Promise.value(()) }
        
        // If the contact doesn't exist then we should create it so we can store the 'isApproved' state
        // (it'll be updated with correct profile info if they accept the message request so this
        // shouldn't cause weird behaviours)
        let bchatId: String = contactThread.contactBChatID()
        let contact: Contact = (Storage.shared.getContact(with: bchatId) ?? Contact(bchatID: bchatId))
        
        guard !contact.isApproved else { return Promise.value(()) }
        
        return Promise.value(())
            .then { [weak self] _ -> Promise<Void> in
                guard !isNewThread else { return Promise.value(()) }
                guard let strongSelf = self else { return Promise(error: MessageSender.Error.noThread) }
                
                // If we aren't creating a new thread (ie. sending a message request) then send a
                // messageRequestResponse back to the sender (this allows the sender to know that
                // they have been approved and can now use this contact in closed groups)
                let (promise, seal) = Promise<Void>.pending()
                let messageRequestResponse: MessageRequestResponse = MessageRequestResponse(
                    isApproved: true
                )
                messageRequestResponse.sentTimestamp = timestamp
                
                // Show a loading indicator
                ModalActivityIndicatorViewController.present(fromViewController: strongSelf, canCancel: false) { _ in
                    seal.fulfill(())
                }
                
                return promise
                    .then { _ -> Promise<Void> in
                        let (promise, seal) = Promise<Void>.pending()
                        Storage.writeSync { transaction in
                            MessageSender.sendNonDurably(messageRequestResponse, in: contactThread, using: transaction)
                                .done { seal.fulfill(()) }
                                .catch { _ in seal.fulfill(()) } // Fulfill even if this failed; the configuration in the swarm should be at most 2 days old
                                .retainUntilComplete()
                        }
                        
                        return promise
                    }
                    .map { _ in
                        if self?.presentedViewController is ModalActivityIndicatorViewController {
                            self?.dismiss(animated: true, completion: nil) // Dismiss the loader
                        }
                    }
            }
            .map { _ in
                // Default 'didApproveMe' to true for the person approving the message request
                Storage.write { transaction in
                    contact.isApproved = true
                    contact.didApproveMe = (contact.didApproveMe || !isNewThread)
                    Storage.shared.setContact(contact, using: transaction)
                }
                
                // Send a sync message with the details of the contact
                MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                
                // Hide the 'messageRequestView' since the request has been approved and force a config
                // sync to propagate the contact approval state (both must run on the main thread)
//                DispatchQueue.main.async { [weak self] in
//                    let messageRequestViewWasVisible: Bool = (self?.messageRequestView.isHidden == false)
//
////                    UIView.animate(withDuration: 0.3) {
////                        self?.messageRequestView.isHidden = true
////                        self?.scrollButtonMessageRequestsBottomConstraint?.isActive = false
////                        self?.scrollButtonBottomConstraint?.isActive = true
////
////                        // Update the table content inset and offset to account for the dissapearance of
////                        // the messageRequestsView
////                        if messageRequestViewWasVisible {
////                            let messageRequestsOffset: CGFloat = ((self?.messageRequestView.bounds.height ?? 0) + 16)
////                            let oldContentInset: UIEdgeInsets = (self?.messagesTableView.contentInset ?? UIEdgeInsets.zero)
////                            self?.messagesTableView.contentInset = UIEdgeInsets(
////                                top: 0,
////                                leading: 0,
////                                bottom: max(oldContentInset.bottom - messageRequestsOffset, 0),
////                                trailing: 0
////                            )
////                        }
////                    }
//
//                    // Update UI
//                    self?.updateNavBarButtons()
//                    if let viewControllers: [UIViewController] = self?.navigationController?.viewControllers,
//                       let messageRequestsIndex = viewControllers.firstIndex(where: { $0 is MessageRequestsViewController }),
//                       messageRequestsIndex > 0 {
//                        var newViewControllers = viewControllers
//                        newViewControllers.remove(at: messageRequestsIndex)
//                        self?.navigationController?.setViewControllers(newViewControllers, animated: false)
//                    }
//                }
            }
    }

//    @objc func acceptMessageRequest() {
//        let alert = UIAlertController(title: "", message: "Are you sure you want to accept this request?", preferredStyle: .alert)
//        let Cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
//        })
//        alert.addAction(Cancel)
//        let Accept = UIAlertAction(title: "Accept", style: .default, handler: { action in
//
//            let promise: Promise<Void> = self.approveMessageRequestIfNeeded(
//                for: self.thread,
//                isNewThread: false,
//                timestamp: NSDate.millisecondTimestamp()
//            )
//
//            // Show an error indicating that approving the thread failed
//            promise.catch(on: DispatchQueue.main) { [weak self] _ in
//                let alert = UIAlertController(title: "BChat", message: NSLocalizedString("MESSAGE_REQUESTS_APPROVAL_ERROR_MESSAGE", comment: ""), preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
//                self?.present(alert, animated: true, completion: nil)
//            }
//            promise.retainUntilComplete()
//
//        })
//        Cancel.setValue(UIColor.lightGray, forKey: "titleTextColor")
//        Accept.setValue(Colors.bchatButtonColor, forKey: "titleTextColor")
//        alert.addAction(Accept)
//        DispatchQueue.main.async(execute: {
//            self.present(alert, animated: true)
//        })
//    }
    
//    @objc func deleteMessageRequest() {
//        guard let uniqueId: String = thread.uniqueId else { return }
//        let alert = UIAlertController(title: "", message: "Declining this request will permanently block this user, are you sure?", preferredStyle: .alert)
//        let ok = UIAlertAction(title: "Cancel", style: .default, handler: { action in
//        })
//        alert.addAction(ok)
//        let cancel = UIAlertAction(title: "Decline", style: .default, handler: { action in
//            // Delete the request
//            Storage.write(
//                with: { [weak self] transaction in
//                    Storage.shared.cancelPendingMessageSendJobs(for: uniqueId, using: transaction)
//                    
//                    // Update the contact
//                    if let contactThread: TSContactThread = self?.thread as? TSContactThread {
//                        let bchatId: String = contactThread.contactBChatID()
//                        
//                        if let contact: Contact = Storage.shared.getContact(with: bchatId) {
//                            // Stop observing the `BlockListDidChange` notification (we are about to pop the screen
//                            // so showing the banner just looks buggy)
//                            if let strongSelf = self {
//                                NotificationCenter.default.removeObserver(strongSelf, name: .contactBlockedStateChanged, object: nil)
//                            }
//                            
//                            contact.isApproved = false
//                            contact.isBlocked = true
//                            
//                            // Note: We set this to true so the current user will be able to send a
//                            // message to the person who originally sent them the message request in
//                            // the future if they unblock them
//                            contact.didApproveMe = true
//                            
//                            Storage.shared.setContact(contact, using: transaction)
//                        }
//                    }
//                    
//                    // Delete all thread content
//                    self?.thread.removeAllThreadInteractions(with: transaction)
//                },
//                completion: { [weak self] in
//                    // Force a config sync and pop to the previous screen
//                    MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
//                    
//                    // Remove the thread after the config message is sent.
//                    // Otherwise the blocked user won't be included in the
//                    // config message.
//                    self?.thread.remove()
//                    
//                    DispatchQueue.main.async {
//                        self?.navigationController?.popViewController(animated: true)
//                    }
//                }
//            )
//        })
//        ok.setValue(UIColor.lightGray, forKey: "titleTextColor")
//        cancel.setValue(UIColor.red, forKey: "titleTextColor")
//        alert.addAction(cancel)
//        DispatchQueue.main.async(execute: {
//            self.present(alert, animated: true)
//        })
//    }
    
}
