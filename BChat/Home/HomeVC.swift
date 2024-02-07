
import UIKit
import SideMenu
import SVGKit
import BChatUIKit
import Alamofire

final class HomeVC : BaseVC, UITableViewDataSource, UITableViewDelegate, NewConversationButtonSetDelegate {
    private var threads: YapDatabaseViewMappings!
    private var threadViewModelCache: [String:ThreadViewModel] = [:] // Thread ID to ThreadViewModel
    private var tableViewTopConstraint: NSLayoutConstraint!
    private var unreadMessageRequestCount: UInt {
        var count: UInt = 0
        dbConnection.read { transaction in
            let ext = transaction.ext(TSThreadDatabaseViewExtensionName) as! YapDatabaseViewTransaction
            ext.enumerateRows(inGroup: TSMessageRequestGroup) { _, _, object, _, _, _ in
                if ((object as? TSThread)?.unreadMessageCount(transaction: transaction) ?? 0) > 0 {
                    count += 1
                }
            }
        }
        return count
    }
    
    private var threadCount: UInt {
        threads.numberOfItems(inGroup: TSInboxGroup)
    }
    
    private lazy var dbConnection: YapDatabaseConnection = {
        let result = OWSPrimaryStorage.shared().newDatabaseConnection()
        result.objectCacheLimit = 500
        return result
    }()
    
    private var isReloading = false
    
    // MARK: UI Components
    
    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = .clear
        result.separatorStyle = .singleLine
        result.register(MessageRequestsCell.self, forCellReuseIdentifier: MessageRequestsCell.reuseIdentifier)
        result.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseIdentifier)
        let bottomInset = Values.newConversationButtonBottomOffset + NewConversationButtonSet.expandedButtonSize + Values.largeSpacing + NewConversationButtonSet.collapsedButtonSize
        result.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        result.showsVerticalScrollIndicator = false
        return result
    }()
    
    private lazy var newConversationButtonSet: NewConversationButtonSet = {
        let result = NewConversationButtonSet()
        result.delegate = self
        return result
    }()
    
    private lazy var fadeView: UIView = {
        let result = UIView()
        let gradient = Gradients.homeVCFade
        result.setGradient(gradient)
        result.isUserInteractionEnabled = false
        return result
    }()
    
    private lazy var emptyStateView: UIView = {
        let explanationLabel = UILabel()
        explanationLabel.textColor = Colors.bchatPlaceholderColor
        explanationLabel.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        explanationLabel.numberOfLines = 0
        explanationLabel.lineBreakMode = .byWordWrapping
        explanationLabel.textAlignment = .center
        explanationLabel.text = NSLocalizedString("Much empty.Such wow.", comment: "")
        
        let explanationLabel2 = UILabel()
        explanationLabel2.textColor = Colors.bchatPlaceholderColor
        explanationLabel2.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        explanationLabel2.numberOfLines = 0
        explanationLabel2.lineBreakMode = .byWordWrapping
        explanationLabel2.textAlignment = .center
        explanationLabel2.text = NSLocalizedString("Go get some friends to BChat!", comment: "")
        
        let createNewPrivateChatButton = Button(style: .prominentFilled2, size: .large)
        createNewPrivateChatButton.setTitle(NSLocalizedString("Start a Chat", comment: ""), for: UIControl.State.normal)
        createNewPrivateChatButton.addTarget(self, action: #selector(createNewDM), for: UIControl.Event.touchUpInside)
        createNewPrivateChatButton.set(.width, to: 196)
        let result = UIStackView(arrangedSubviews: [ explanationLabel ,explanationLabel2])
        result.axis = .vertical
        result.spacing = Values.verySmallSpacing
        result.alignment = .center
        result.isHidden = true
        return result
    }()
    
    var someImageView: UIImageView = {
        let theImageView = UIImageView()
        theImageView.layer.masksToBounds = true
        let logoName = isLightMode ? "svg_light" : "svg_dark"
        let namSvgImgVar: SVGKImage = SVGKImage(named: logoName)!
        theImageView.image = namSvgImgVar.uiImage
        return theImageView
    }()
    
    //MARK:- Wallet References
    //========================================================================================
//    ,"publicnode5.rpcnode.stream:29095"
    //MAINNET
    var nodeArray = ["explorer.beldex.io:19091","mainnet.beldex.io:29095","publicnode1.rpcnode.stream:29095","publicnode2.rpcnode.stream:29095","publicnode3.rpcnode.stream:29095","publicnode4.rpcnode.stream:29095","publicnode5.rpcnode.stream:29095"]
    //TESTNET
//    var nodeArray = ["149.102.156.174:19095"]
    var randomNodeValue = ""
    lazy var statusTextState = { return Observable<String>("") }()
    lazy var conncetingState = { return Observable<Bool>(false) }()
    lazy var refreshState = { return Observable<Bool>(false) }()
    var syncedflag = false
    private var connecting: Bool { return conncetingState.value}
    private var currentBlockChainHeight: UInt64 = 0
    private var daemonBlockChainHeight: UInt64 = 0
    private var needSynchronized = false {
        didSet {
            guard needSynchronized, !oldValue,
                  let wallet = self.wallet else { return }
            wallet.saveOnTerminate()
        }
    }
    private lazy var taskQueue = DispatchQueue(label: "beldex.wallet.task")
    lazy var progressState = { return Observable<CGFloat>(0) }()
    // MARK: - Properties (Private)
    private var wallet: BDXWallet?
    private var listening = false
    private var isSyncingUI = false {
        didSet {
            guard oldValue != isSyncingUI else { return }
            if isSyncingUI {
//                RunLoop.main.add(timer, forMode: .common)
            } else {
//                timer.invalidate()
            }
        }
    }
    public lazy var loadingState = { Postable<Bool>() }()
    private var SelectedDecimal = ""
    private var SelectedBalance = ""
    var mainbalance = ""
    private var CurrencyValue: Double!
    private var refreshDuration: TimeInterval = 60
    private var marketsDataRequest: DataRequest?
    var hashArray2 = [RecipientDomainSchema]()
    var syncingIsFromDelegateMethod = true
    var isdaemonHeight : Int64 = 0
    var backApiRescanVC = false
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Note: This is a hack to ensure `isRTL` is initially gets run on the main thread so the value is cached (it gets
        // called on background threads and if it hasn't cached the value then it can cause odd performance issues since
        // it accesses UIKit)
        _ = CurrentAppContext().isRTL
        
        // Threads (part 1)
        dbConnection.beginLongLivedReadTransaction() // Freeze the connection for use on the main thread (this gives us a stable data source that doesn't change until we tell it to)
        // Preparation
        SignalApp.shared().homeViewController = self
        // Gradient & nav bar
        setUpGradientBackground()
        if navigationController?.navigationBar != nil {
            setUpNavBarStyle()
        }
        updateNavBarButtons()
        setUpNavBarSessionHeading()
        // Table view
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.pin(.leading, to: .leading, of: view)
        tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0)
        tableView.pin(.trailing, to: .trailing, of: view)
        tableView.pin(.bottom, to: .bottom, of: view)
        view.addSubview(someImageView)
        someImageView.pin(to: view)
        // Empty state view
        view.addSubview(emptyStateView)
        emptyStateView.center(.horizontal, in: view)
        let verticalCenteringConstraint = emptyStateView.center(.vertical, in: view)
        verticalCenteringConstraint.constant = -16 // Makes things appear centered visually
        // New conversation button set
        view.addSubview(newConversationButtonSet)
        // newConversationButtonSet.center(.horizontal, in: view)
        newConversationButtonSet.pin(.trailing, to: .trailing, of: view, withInset: -Values.newConversationButtonBottomOffset + 120)
        newConversationButtonSet.pin(.bottom, to: .bottom, of: view, withInset: -Values.newConversationButtonBottomOffset) // Negative due to how the constraint is set up
        // Notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleYapDatabaseModifiedNotification(_:)), name: .YapDatabaseModified, object: OWSPrimaryStorage.shared().dbNotificationObject)
        notificationCenter.addObserver(self, selector: #selector(handleProfileDidChangeNotification(_:)), name: NSNotification.Name(rawValue: kNSNotificationName_OtherUsersProfileDidChange), object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleLocalProfileDidChangeNotification(_:)), name: Notification.Name(kNSNotificationName_LocalProfileDidChange), object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleSeedViewedNotification(_:)), name: .seedViewed, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleBlockedContactsUpdatedNotification(_:)), name: .blockedContactsUpdated, object: nil)
        // Threads (part 2)
        threads = YapDatabaseViewMappings(groups: [ TSMessageRequestGroup, TSInboxGroup ], view: TSThreadDatabaseViewExtensionName) // The extension should be registered at this point
        threads.setIsReversed(true, forGroup: TSInboxGroup)
        dbConnection.read { transaction in
            self.threads.update(with: transaction) // Perform the initial update
        }
        // Start polling if needed (i.e. if the user just created or restored their BChat ID)
        if OWSIdentityManager.shared().identityKeyPair() != nil {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.startPollerIfNeeded()
            appDelegate.startClosedGroupPoller()
            appDelegate.startOpenGroupPollersIfNeeded()
            // Do this only if we created a new BChat ID, or if we already received the initial configuration message
            if UserDefaults.standard[.hasSyncedInitialConfiguration] {
                appDelegate.syncConfigurationIfNeeded()
            }
        }
        // Re-populate snode pool if needed
        SnodeAPI.getSnodePool().retainUntilComplete()
        // Onion request path countries cache
        DispatchQueue.global(qos: .utility).sync {
            let _ = IP2Country.shared.populateCacheIfNeeded()
        }
        // Get default open group rooms if needed
        OpenGroupAPIV2.getDefaultRoomsIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .myNotificationKey_doodlechange, object: nil)
    }
    
    @objc func notificationReceived(_ notification: Notification) {
        guard let text = notification.userInfo?["text"] as? String else { return }
        someImageView.layer.masksToBounds = true
        let logoName = isLightMode ? "svg_light" : "svg_dark"
        let namSvgImgVar: SVGKImage = SVGKImage(named: logoName)!
        someImageView.image = namSvgImgVar.uiImage
    }
    @objc func tappedMe() {
        let searchController = GlobalSearchViewController()
        self.navigationController?.setViewControllers([ self, searchController ], animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(_:)), name: .myNotificationKey_doodlechange, object: nil)
        reload()

        if SSKPreferences.areWalletEnabled{
            if UserDefaults.standard.domainSchemas.isEmpty {}else {
                hashArray2 = UserDefaults.standard.domainSchemas
            }
            // randomElement node And Selected Node
            if !SaveUserDefaultsData.SelectedNode.isEmpty {
                randomNodeValue = SaveUserDefaultsData.SelectedNode
            }else {
                randomNodeValue = nodeArray.randomElement()!
            }
            SaveUserDefaultsData.FinalWallet_node = randomNodeValue
            
            if WalletSharedData.sharedInstance.wallet != nil {
                if self.wallet == nil {
                    isSyncingUI = true
                    syncingIsFromDelegateMethod = false
                }
            }else {
                init_syncing_wallet()
            }
            // Rescan Height Update in userdefaults work
//            if backApiRescanVC == true {
//                self.closeWallet()
//                init_syncing_wallet()
//            }
        }else {
            WalletSharedData.sharedInstance.wallet = nil
            closeWallet()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        newConversationButtonSet.collapse(withAnimation: true)
//        self.backApiRescanVC = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }
    
    override func appDidBecomeActive(_ notification: Notification) {
        reload()
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
    
    //MARK:- Wallet func Connect Deamon
    func init_syncing_wallet() {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            conncetingState.value = true
            let username = SaveUserDefaultsData.NameForWallet
            let pwd = SaveUserDefaultsData.israndomUUIDPassword
            WalletService.shared.openWallet(username, password: pwd) { [weak self] (result) in
                WalletSharedData.sharedInstance.wallet = nil
                guard let strongSelf = self else { return }
                switch result {
                case .success(let wallet):
                    strongSelf.wallet = wallet
                    WalletSharedData.sharedInstance.wallet = wallet
                    strongSelf.connect(wallet: wallet)
                    strongSelf.syncedflag = true
                case .failure(_):
                    DispatchQueue.main.async {
                        strongSelf.refreshState.value = true
                        strongSelf.conncetingState.value = false
                        strongSelf.syncedflag = false
                    }
                }
            }
        }
    }
    
    func connect(wallet: BDXWallet) {
        if !connecting {
            self.syncedflag = false
            self.conncetingState.value = true
        }
        wallet.connectToDaemon(address: SaveUserDefaultsData.FinalWallet_node, delegate: self) { [weak self] (isConnected) in
            guard let `self` = self else { return }
            if isConnected {
                if let wallet = self.wallet {
                    if SaveUserDefaultsData.WalletRestoreHeight == "" {
                        let lastElementHeight = DateHeight.getBlockHeight.last
                        let height = lastElementHeight!.components(separatedBy: ":")
                        SaveUserDefaultsData.WalletRestoreHeight = "\(height[1])"
                        wallet.restoreHeight = UInt64(SaveUserDefaultsData.WalletRestoreHeight)!
                    }else {
                        wallet.restoreHeight = UInt64(SaveUserDefaultsData.WalletRestoreHeight)!
                    }
//                    if self.backApiRescanVC == true {
//                        wallet.rescanBlockchainAsync()
//                    }
                    wallet.start()
                }
                self.listening = true
            } else {
                DispatchQueue.main.async {
                    self.refreshState.value = true
                    self.conncetingState.value = false
                    self.listening = false
                }
            }
        }
    }
    
    private func synchronizedUI() {
        syncedflag = true
//        WalletSharedData.sharedInstance.wallet = nil
    }
    
    // MARK: - Refresh Func
    func refresh() {
        refreshState.value = false
        if let wallet = self.wallet {
            if listening {
                wallet.pasue()
                wallet.start()
            } else {
                connect(wallet: wallet)
            }
        } else {
            init_syncing_wallet()
        }
    }
    
    // MARK: - Close Wallet Func
    private func closeWallet() {
        guard let wallet = self.wallet else {
            return
        }
        self.wallet = nil
        if listening {
            listening = false
            wallet.pasue()
        }
        wallet.close()
    }
    deinit {
        isSyncingUI = false
        closeWallet()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if unreadMessageRequestCount > 0 && !CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] {
                return 1
            }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reuseIdentifier) as! ConversationCell
            cell.threadViewModel = threadViewModel(at: indexPath.row)
            return cell
        }
    }
    
    // MARK: Updating
    
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
        emptyStateView.isHidden = (threadCount != 0)
        someImageView.isHidden = (threadCount != 0)
        isReloading = false
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
        let hasChanges = (
            ext.hasChanges(forGroup: TSMessageRequestGroup, in: notifications) ||
            ext.hasChanges(forGroup: TSInboxGroup, in: notifications)
        )
        
        guard hasChanges else { return }
        
        if let firstChangeSet = notifications[0].userInfo {
            let firstSnapshot = firstChangeSet[YapDatabaseSnapshotKey] as! UInt64
            
            // The 'getSectionChanges' code below will crash if we try to process multiple commits at once
            // so just force a full reload
            if threads.snapshotOfLastUpdate != firstSnapshot - 1 {
                // Check if we inserted a new message request (if so then unhide the message request banner)
                if
                    let extensions: [String: Any] = firstChangeSet[YapDatabaseExtensionsKey] as? [String: Any],
                    let viewExtensions: [String: Any] = extensions[TSThreadDatabaseViewExtensionName] as? [String: Any]
                {
                    // Note: We do a 'flatMap' here rather than explicitly grab the desired key because
                    // the key we need is 'changeset_key_changes' in 'YapDatabaseViewPrivate.h' so could
                    // change due to an update and silently break this - this approach is a bit safer
                    let allChanges: [Any] = Array(viewExtensions.values).compactMap { $0 as? [Any] }.flatMap { $0 }
                    let messageRequestInserts = allChanges
                        .compactMap { $0 as? YapDatabaseViewRowChange }
                        .filter { $0.finalGroup == TSMessageRequestGroup && $0.type == .insert }
                    
                    if !messageRequestInserts.isEmpty && CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] {
                        CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] = false
                    }
                }
                
                // If there are no unread message requests then hide the message request banner
                if unreadMessageRequestCount == 0 {
                    CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] = true
                }
                
                return reload()
            }
        }
        
        var sectionChanges = NSArray()
        var rowChanges = NSArray()
        ext.getSectionChanges(&sectionChanges, rowChanges: &rowChanges, for: notifications, with: threads)
        
        // Separate out the changes for new message requests and the inbox (so we can avoid updating for
        // new messages within an existing message request)
        let messageRequestChanges = rowChanges
            .compactMap { $0 as? YapDatabaseViewRowChange }
            .filter { $0.originalGroup == TSMessageRequestGroup || $0.finalGroup == TSMessageRequestGroup }
        let inboxRowChanges = rowChanges
            .compactMap { $0 as? YapDatabaseViewRowChange }
            .filter { $0.originalGroup == TSInboxGroup || $0.finalGroup == TSInboxGroup }
        
        guard sectionChanges.count > 0 || inboxRowChanges.count > 0 || messageRequestChanges.count > 0 else { return }
        
        //        tableView.beginUpdates()
        self.tableView.performBatchUpdates({
            // If we need to unhide the message request row and then re-insert it
            if !messageRequestChanges.isEmpty {
                
                // If there are no unread message requests then hide the message request banner
                if unreadMessageRequestCount == 0 && tableView.numberOfRows(inSection: 0) == 1 {
                    CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] = true
                    tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
                else {
                    if tableView.numberOfRows(inSection: 0) == 1 && Int(unreadMessageRequestCount) <= 0 {
                        tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    }
                    else if tableView.numberOfRows(inSection: 0) == 0 && Int(unreadMessageRequestCount) > 0 && !CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] {
                        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    }
                }
            }
            
            inboxRowChanges.forEach { rowChange in
                let key = rowChange.collectionKey.key
                threadViewModelCache[key] = nil
                
                switch rowChange.type {
                case .delete:
                    tableView.deleteRows(at: [ rowChange.indexPath! ], with: .automatic)
                    
                case .insert:
                    tableView.insertRows(at: [ rowChange.newIndexPath! ], with: .automatic)
                    
                case .update:
                    tableView.reloadRows(at: [ rowChange.indexPath! ], with: .automatic)
                    
                case .move:
                    // Note: We need to handle the move from the message requests section to the inbox (since
                    // we are only showing a single row for message requests we need to custom handle this as
                    // an insert as the change won't be defined correctly)
                    if rowChange.originalGroup == TSMessageRequestGroup && rowChange.finalGroup == TSInboxGroup {
                        tableView.insertRows(at: [ rowChange.newIndexPath! ], with: .automatic)
                    }
                    else if rowChange.originalGroup == TSInboxGroup && rowChange.finalGroup == TSMessageRequestGroup {
                        tableView.deleteRows(at: [ rowChange.indexPath! ], with: .automatic)
                    }
                    
                default: break
                }
            }
            //        tableView.endUpdates()
        }, completion: nil)
        // HACK: Moves can have conflicts with the other 3 types of change.
        // Just batch perform all the moves separately to prevent crashing.
        // Since all the changes are from the original state to the final state,
        // it will still be correct if we pick the moves out.
//        tableView.beginUpdates()
        self.tableView.performBatchUpdates({
        rowChanges.forEach { rowChange in
            let rowChange = rowChange as! YapDatabaseViewRowChange
            let key = rowChange.collectionKey.key
            threadViewModelCache[key] = nil
            
            switch rowChange.type {
            case .move:
                // Since we are custom handling this specific movement in the above 'updates' call we need
                // to avoid trying to handle it here
                if rowChange.originalGroup == TSMessageRequestGroup || rowChange.finalGroup == TSMessageRequestGroup {
                    return
                }
                
                tableView.moveRow(at: rowChange.indexPath!, to: rowChange.newIndexPath!)
                
            default: break
            }
        }
        //        tableView.endUpdates()
    }, completion: nil)
        emptyStateView.isHidden = (threadCount != 0)
        someImageView.isHidden = (threadCount != 0)
    }
    
    @objc private func handleProfileDidChangeNotification(_ notification: Notification) {
        tableView.reloadData() // TODO: Just reload the affected cell
    }
    
    @objc private func handleLocalProfileDidChangeNotification(_ notification: Notification) {
        updateNavBarButtons()
    }
    
    @objc private func handleSeedViewedNotification(_ notification: Notification) {
        tableViewTopConstraint.isActive = false
        tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: Values.smallSpacing)
    }
    
    @objc private func handleBlockedContactsUpdatedNotification(_ notification: Notification) {
        self.tableView.reloadData() // TODO: Just reload the affected cell
    }
    
    private func updateNavBarButtons() {
        let backButton = UIBarButtonItem(image: UIImage(named: "Group 630"), style: .plain, target: self, action: #selector(openSettings))
        backButton.tintColor = UIColor(red: 0.18, green: 0.63, blue: 0.13, alpha: 1.00)
        backButton.isAccessibilityElement = true
        self.navigationItem.leftBarButtonItem = backButton
        
        // Right bar button item - search button
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchUI))
        rightBarButtonItem.accessibilityLabel = "Search button"
        rightBarButtonItem.isAccessibilityElement  = true
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc override internal func handleAppModeChangedNotification(_ notification: Notification) {
        super.handleAppModeChangedNotification(notification)
        //        let gradient = Gradients.homeVCFade
        //        fadeView.setGradient(gradient) // Re-do the gradient
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
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
                // guard let self = self else { return }
                self.presentAlert(alert)
            })
            delete.backgroundColor = Colors.destructive
            delete.image = UIImage(named: "delete-1")
            let isPinned = thread.isPinned
            let pin = UIContextualAction(style: .destructive, title: "Pin", handler: { (action, view, success) in
                thread.isPinned = true
                thread.save()
                self.threadViewModelCache.removeValue(forKey: thread.uniqueId!)
                tableView.reloadRows(at: [ indexPath ], with: UITableView.RowAnimation.fade)
            })
            pin.backgroundColor = Colors.pathsBuilding
            pin.image = UIImage(named: "pin_big")
            //UnPin Option
            let unpin = UIContextualAction(style: .destructive, title: "Unpin", handler: { (action, view, success) in
                thread.isPinned = false
                thread.save()
                self.threadViewModelCache.removeValue(forKey: thread.uniqueId!)
                tableView.reloadRows(at: [ indexPath ], with: UITableView.RowAnimation.fade)
            })
            unpin.backgroundColor = Colors.pathsBuilding
            unpin.image = UIImage(named: "unpin")
            
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
                block.backgroundColor = Colors.unimportant
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
                unblock.backgroundColor = Colors.unimportant
                unblock.image = UIImage(named: "unblock_big")
                
                return UISwipeActionsConfiguration(actions: [ delete, (thread.isBlocked() ? unblock : block), (isPinned ? unpin : pin) ])
            }
            else {
                return UISwipeActionsConfiguration(actions: [ delete, (isPinned ? unpin : pin) ])
            }
        }
    }
    
    // MARK: - Interaction
    
    @objc func show(_ thread: TSThread, with action: ConversationViewAction, highlightedMessageID: String?, animated: Bool) {
        DispatchMainThreadSafe {
            if let presentedVC = self.presentedViewController {
                presentedVC.dismiss(animated: false, completion: nil)
            }
        }
        let conversationVC = ConversationVC(thread: thread)
        conversationVC.isSyncingStatus = syncedflag
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.setViewControllers([ self, conversationVC ], animated: true)
        
    }
    
    private func delete(_ thread: TSThread) {
        let openGroupV2 = Storage.shared.getV2OpenGroup(for: thread.uniqueId!)
        Storage.write { transaction in
            Storage.shared.cancelPendingMessageSendJobs(for: thread.uniqueId!, using: transaction)
            if let openGroupV2 = openGroupV2 {
                OpenGroupManagerV2.shared.delete(openGroupV2, associatedWith: thread, using: transaction)
            } else if let thread = thread as? TSGroupThread, thread.isClosedGroup == true {
                let groupID = thread.groupModel.groupId
                let groupPublicKey = LKGroupUtilities.getDecodedGroupID(groupID)
                MessageSender.leave(groupPublicKey, using: transaction).retainUntilComplete()
                thread.removeAllThreadInteractions(with: transaction)
                thread.remove(with: transaction)
            } else {
                thread.removeAllThreadInteractions(with: transaction)
                thread.remove(with: transaction)
            }
        }
    }
    
    //1.New Chat one to one chat
    @objc func joinOpenGroup() {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewChatVC") as! NewChatVC
        if UIDevice.current.isIPad {
            vc.modalPresentationStyle = .fullScreen
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //2.Social group
    @objc func createNewDM() {
        let newSecretGroupVC = NewSecretGroupVC()
        let navigationController = OWSNavigationController(rootViewController: newSecretGroupVC)
        if UIDevice.current.isIPad {
            navigationController.modalPresentationStyle = .fullScreen
        }
        present(navigationController, animated: true, completion: nil)
    }
    
    //3.Group Chat
    @objc func createClosedGroup() {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SocialGroupVC") as! SocialGroupVC
        if UIDevice.current.isIPad {
            vc.modalPresentationStyle = .fullScreen
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openSettings() {
        newConversationButtonSet.collapse(withAnimation: true)
        let RightVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! SideMenuNavigationController
        SideMenuManager.default.leftMenuNavigationController = RightVC
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @objc private func showSearchUI() {
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: false, completion: nil)
        }
        let searchController = GlobalSearchViewController()
        self.navigationController?.setViewControllers([ self, searchController ], animated: true)
    }
    
    @objc(createNewDMFromDeepLink:)
    func createNewDMFromDeepLink(bchatID: String) {
        let newDMVC = NewDMVC(bchatID: bchatID)
        let navigationController = OWSNavigationController(rootViewController: newDMVC)
        if UIDevice.current.isIPad {
            navigationController.modalPresentationStyle = .fullScreen
        }
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: Convenience
    private func thread(at index: Int) -> TSThread? {
        var thread: TSThread? = nil
        dbConnection.read { transaction in
            // Note: Section needs to be '1' as we now have 'TSMessageRequests' as the 0th section
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

extension HomeVC: BeldexWalletDelegate {
    func beldexWalletRefreshed(_ wallet: BChatWalletWrapper) {
        print("Refreshed--->blockChainHeight-->\(wallet.blockChainHeight)---->daemonBlockChainHeight-->, \(wallet.daemonBlockChainHeight)")
        self.daemonBlockChainHeight = wallet.daemonBlockChainHeight
        isdaemonHeight = Int64(wallet.blockChainHeight)
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            if wallet.isSynchronized == true {
                self.isSyncingUI = false
            }
        }
        if self.needSynchronized {
            self.needSynchronized = !wallet.save()
        }
        taskQueue.async {
            guard let wallet = self.wallet else { return }
            let (balance, history) = (wallet.balance, wallet.history)
            self.postData(balance: balance, history: history)
        }
        if daemonBlockChainHeight != 0 {
            let difference = wallet.daemonBlockChainHeight.subtractingReportingOverflow(daemonBlockChainHeight)
            guard !difference.overflow else { return }
        }
        DispatchQueue.main.async {
            if self.conncetingState.value {
                self.conncetingState.value = false
            }
            if wallet.isSynchronized {
                self.synchronizedUI()
            }
        }
    }
    func beldexWalletNewBlock(_ wallet: BChatWalletWrapper, currentHeight: UInt64) {
        print("NewBlock--currentHeight ----> \(currentHeight)---DaemonBlockHeight---->\(wallet.daemonBlockChainHeight)")
        self.currentBlockChainHeight = currentHeight
        self.daemonBlockChainHeight = wallet.daemonBlockChainHeight
        isdaemonHeight = Int64(wallet.daemonBlockChainHeight)
        self.needSynchronized = true
        self.isSyncingUI = true
    }
    private func postData(balance: String, history: TransactionHistory) {
        let balance_modify = Helper.displayDigitsAmount(balance)
        self.mainbalance = balance_modify
        DispatchQueue.main.async { [self] in
            self.tableView.reloadData()
        }
    }
}
