// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class ArchiveChatsVC: BaseVC {
    
    private lazy var infoLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.textFieldPlaceHolderColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = Colors.mainBackGroundColor2
        result.separatorStyle = .none
        result.register(HomeTableViewCell.self, forCellReuseIdentifier: "HomeTableViewCell")
        result.showsVerticalScrollIndicator = false
        return result
    }()
    
    var syncedflag = false
    private var threads: YapDatabaseViewMappings!
    internal var threadViewModelCache: [String:ThreadViewModel] = [:]
    internal var threadCount: UInt {
        threads.numberOfItems(inGroup: TSArchiveGroup)
    }
    
    private lazy var dbConnection: YapDatabaseConnection = {
        let result = OWSPrimaryStorage.shared().newDatabaseConnection()
        result.objectCacheLimit = 500
        return result
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        self.title = "Archived Chats"
        setUpTopCornerRadius()
        view.addSubview(infoLabel)
        infoLabel.text = "Chats will automatically Unarchived when new messages are received."
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 19),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -19),
        ])
        
        // Table view
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.pin(.leading, to: .leading, of: view)
        tableView.pin(.top, to: .bottom, of: infoLabel, withInset: 26)
        tableView.pin(.trailing, to: .trailing, of: view)
        tableView.pin(.bottom, to: .bottom, of: view)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleYapDatabaseModifiedNotification(_:)), name: .YapDatabaseModified, object: OWSPrimaryStorage.shared().dbNotificationObject)
        
        dbConnection.beginLongLivedReadTransaction()
        
        threads = YapDatabaseViewMappings(groups: [ TSArchiveGroup ], view: TSThreadDatabaseViewExtensionName) // The extension should be registered at this point
        threads.setIsReversed(true, forGroup: TSArchiveGroup)
        dbConnection.read { transaction in
            self.threads.update(with: transaction) // Perform the initial update
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
    }
    
    func thread(at index: Int) -> TSThread? {
        var thread: TSThread? = nil
        dbConnection.read { transaction in
            // Note: Section needs to be '1' as we now have 'TSMessageRequests' as the 0th section
            let ext = transaction.ext(TSThreadDatabaseViewExtensionName) as! YapDatabaseViewTransaction
            thread = ext.object(atRow: UInt(index), inSection: 0, with: self.threads) as? TSThread
        }
        return thread
    }
    
    func threadViewModel(at index: Int) -> ThreadViewModel? {
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
    
    private var isReloading = false
    private func reload() {
        AssertIsOnMainThread()
        guard !isReloading else { return }
        isReloading = true
        dbConnection.beginLongLivedReadTransaction() // Jump to the latest commit
        dbConnection.read { transaction in
            self.threads.update(with: transaction)
        }
        threadViewModelCache.removeAll()
        tableView.reloadData()
        isReloading = false
    }
    
    @objc func show(_ thread: TSThread, with action: ConversationViewAction, highlightedMessageID: String?, animated: Bool) {
        DispatchMainThreadSafe {
            if let presentedVC = self.presentedViewController {
                presentedVC.dismiss(animated: false, completion: nil)
            }
        }
        let conversationVC = ConversationVC(thread: thread)
        conversationVC.isSyncingStatus = syncedflag
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    @objc private func handleYapDatabaseModifiedNotification(_ yapDatabase: YapDatabase) {
        AssertIsOnMainThread()
        reload()
    }
    
}


extension ArchiveChatsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(threadCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as! HomeTableViewCell
        cell.threadViewModel = threadViewModel(at: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let thread = self.thread(at: indexPath.row) else { return UISwipeActionsConfiguration(actions: []) }
        
        // UnArchive
        let isArchived = thread.isArchived
        let unarchive = UIContextualAction(style: .destructive, title: "UnArchive", handler: { (action, view, success) in
            thread.isArchived = false
            thread.save()
            self.threadViewModelCache.removeValue(forKey: thread.uniqueId!)
            tableView.reloadRows(at: [indexPath], with: .fade)
            self.reload()
        })
        unarchive.backgroundColor = Colors.mainBackGroundColor2
        unarchive.image = UIImage(named: "ic_unarchive")
        
        
        return UISwipeActionsConfiguration(actions: [(isArchived ? unarchive : unarchive)])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let thread = self.thread(at: indexPath.row) else { return }
        show(thread, with: ConversationViewAction.none, highlightedMessageID: nil, animated: true)
    }
    
}
