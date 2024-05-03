
import UIKit
import SideMenu
import SVGKit
import BChatUIKit
import Alamofire

final class HomeVC : BaseVC, UITableViewDataSource, UITableViewDelegate {
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
    
    
    
    private var threadsForMessageRequest: YapDatabaseViewMappings! =  {
        let result = YapDatabaseViewMappings(groups: [ TSMessageRequestGroup ], view: TSThreadDatabaseViewExtensionName)
        result.setIsReversed(true, forGroup: TSMessageRequestGroup)
        return result
    }()
    private var threadViewModelCacheForMessageRequest: [String: ThreadViewModel] = [:] // Thread ID to ThreadViewModel
    
    private var messageRequestCountForMessageRequest: UInt {
        threadsForMessageRequest.numberOfItems(inGroup: TSMessageRequestGroup)
    }
    
    
    
    
    // MARK: UI Components
    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = Colors.mainBackGroundColor2//.clear
        result.separatorStyle = .none//.singleLine
        result.register(MessageRequestsCell.self, forCellReuseIdentifier: MessageRequestsCell.reuseIdentifier)
//        result.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseIdentifier)
        result.register(HomeTableViewCell.self, forCellReuseIdentifier: "HomeTableViewCell")
        result.showsVerticalScrollIndicator = false
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
    var nodeArray = ["publicnode1.rpcnode.stream:29095","publicnode2.rpcnode.stream:29095","publicnode3.rpcnode.stream:29095","publicnode4.rpcnode.stream:29095","publicnode5.rpcnode.stream:29095"]
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
    var isTapped = false
    
    // NewConversation Button Set PopUpView
    private lazy var mainButtonPopUpView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.homeScreenFloatingbackgroundColor
        stackView.layer.cornerRadius = 16
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var mainButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.setImage(UIImage(named: "ic_HomeVCLogo"), for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .clear
        return button
    }()
    
    private lazy var newChatLabel: UILabel = {
        let result: UILabel = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.text = NSLocalizedString("NEW_CHAT_PLUS", comment: "").uppercased()
        result.textColor = Colors.greenColor
        result.textAlignment = .right
        return result
    }()
    
    private lazy var secretGroupLabel: UILabel = {
        let result: UILabel = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.text = NSLocalizedString("SECRET_GROUP_TITLE", comment: "").uppercased()
        result.textColor = Colors.greenColor
        result.textAlignment = .right
        return result
    }()
    
    private lazy var socialGroupLabel: UILabel = {
        let result: UILabel = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.text = NSLocalizedString("SOCIAL_GROUP_TITLE", comment: "").uppercased()
        result.textColor = Colors.greenColor
        result.textAlignment = .right
        return result
    }()
    
    private lazy var isFromNewChatImgBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.textViewColor
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "ic_logoBubbleNew")?.scaled(to: CGSize(width: 22, height: 22))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var isFromSecretGroupImgBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.textViewColor
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "ic_GroupNew1")?.scaled(to: CGSize(width: 22, height: 22))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var isFromSocialGroupImgBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.textViewColor
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "ic_GroupMsgNew")?.scaled(to: CGSize(width: 22, height: 22))
        button.setImage(image, for: .normal)
        return button
    }()
    
    private lazy var imagesStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ isFromNewChatImgBtn, isFromSecretGroupImgBtn, isFromSocialGroupImgBtn ])
        result.axis = .vertical
        result.spacing = 10
        result.distribution = .fillEqually
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var newChatButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(newChatButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var secretGroupButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(secretGroupButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var socialGroupButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(socialGroupButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackViewButtons: UIStackView = {
        let result = UIStackView(arrangedSubviews: [newChatButton, secretGroupButton, socialGroupButton])
        result.axis = .vertical
        result.spacing = 10
        result.distribution = .fillEqually
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var messageRequestLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.titleColor3
       result.font = Fonts.boldOpenSans(ofSize: 16)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Message Request"
       return result
   }()
    
    lazy var messageRequestCountLabel: UILabel = {
       let result = PaddingLabel()
        result.textColor = Colors.darkThemeTextBoxColor
       result.font = Fonts.boldOpenSans(ofSize: 12)
       result.textAlignment = .center
       result.translatesAutoresizingMaskIntoConstraints = false
        result.paddingTop = 3
        result.paddingBottom = 3
        result.paddingLeft = 5
        result.paddingRight = 5
        result.layer.masksToBounds = true
        result.layer.cornerRadius = 11
        result.backgroundColor = Colors.messageRequestBackgroundColor
       return result
   }()
    
    lazy var showOrHideMessageRequestCollectionViewButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(showOrHideMessageRequestCollectionViewButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_downArrow"), for: .normal)
        button.setBackgroundImage(UIImage(named: "ic_upArrow"), for: .selected)
        return button
    }()
    
    var messageCollectionView: UICollectionView!
    let myGroup = DispatchGroup()
    var nodeArrayDynamic : [String]?
    
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
//        setUpGradientBackground()
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        if navigationController?.navigationBar != nil {
            setUpNavBarStyle()
        }
        updateNavBarButtons()
        setUpNavBarSessionHeading()
               
        view.addSubview(messageRequestLabel)
        view.addSubview(messageRequestCountLabel)
        view.addSubview(showOrHideMessageRequestCollectionViewButton)
        showOrHideMessageRequestCollectionViewButton.isSelected = true
        
        NSLayoutConstraint.activate([
            messageRequestLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 19),
            messageRequestLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            
            messageRequestCountLabel.leadingAnchor.constraint(equalTo: messageRequestLabel.trailingAnchor, constant: 6),
            messageRequestCountLabel.centerYAnchor.constraint(equalTo: messageRequestLabel.centerYAnchor),
            messageRequestCountLabel.heightAnchor.constraint(equalToConstant: 22),
            messageRequestCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 22),
            
            showOrHideMessageRequestCollectionViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            showOrHideMessageRequestCollectionViewButton.centerYAnchor.constraint(equalTo: messageRequestLabel.centerYAnchor),
            showOrHideMessageRequestCollectionViewButton.heightAnchor.constraint(equalToConstant: 24),
            showOrHideMessageRequestCollectionViewButton.widthAnchor.constraint(equalToConstant: 24),
        ])
                
        // CollectionView
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        messageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        messageCollectionView.dataSource = self
        messageCollectionView.delegate = self
        messageCollectionView.register(MessageRequestCollectionViewCell.self, forCellWithReuseIdentifier: "MessageRequestCollectionViewCell")
        messageCollectionView.showsHorizontalScrollIndicator = false
        messageCollectionView.backgroundColor = .clear
        messageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageCollectionView)
        // Add constraints for collectionView
        NSLayoutConstraint.activate([
            messageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            messageCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0 + 38 + 8),
            messageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            messageCollectionView.heightAnchor.constraint(equalToConstant: 80),
        ])
        self.messageCollectionView.isHidden = true
        messageCollectionView.reloadData()
        
        
        // Table view
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.pin(.leading, to: .leading, of: view)
        tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0 + 16)
        tableView.pin(.trailing, to: .trailing, of: view)
        tableView.pin(.bottom, to: .bottom, of: view)
        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        tableView.layer.cornerRadius = 22
        tableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
//        view.addSubview(someImageView)
//        someImageView.pin(to: view)
        self.messageCollectionView.isHidden = true
        // Empty state view
        view.addSubview(emptyStateView)
        emptyStateView.center(.horizontal, in: view)
        let verticalCenteringConstraint = emptyStateView.center(.vertical, in: view)
        verticalCenteringConstraint.constant = -16 // Makes things appear centered visually
        // New conversation button set
        view.addSubview(mainButton)
        mainButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        mainButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35).isActive = true
        mainButton.heightAnchor.constraint(equalToConstant: 58).isActive = true
        mainButton.widthAnchor.constraint(equalToConstant: 58).isActive = true
        view.addSubview(mainButtonPopUpView)
        mainButtonPopUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        mainButtonPopUpView.bottomAnchor.constraint(equalTo: mainButton.topAnchor, constant: -10).isActive = true
        mainButtonPopUpView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        mainButtonPopUpView.widthAnchor.constraint(equalToConstant: 170).isActive = true
        mainButtonPopUpView.addSubview(imagesStackView)
        imagesStackView.trailingAnchor.constraint(equalTo: mainButtonPopUpView.trailingAnchor, constant: -13).isActive = true
        imagesStackView.bottomAnchor.constraint(equalTo: mainButtonPopUpView.bottomAnchor, constant: -14).isActive = true
        imagesStackView.topAnchor.constraint(equalTo: mainButtonPopUpView.topAnchor, constant: 14).isActive = true
        imagesStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        imagesStackView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        mainButtonPopUpView.addSubview(newChatLabel)
        mainButtonPopUpView.addSubview(secretGroupLabel)
        mainButtonPopUpView.addSubview(socialGroupLabel)
        newChatLabel.leadingAnchor.constraint(equalTo: mainButtonPopUpView.leadingAnchor, constant: 8).isActive = true
        newChatLabel.trailingAnchor.constraint(equalTo: isFromNewChatImgBtn.leadingAnchor, constant: -8).isActive = true
        newChatLabel.centerYAnchor.constraint(equalTo: isFromNewChatImgBtn.centerYAnchor).isActive = true
        secretGroupLabel.leadingAnchor.constraint(equalTo: mainButtonPopUpView.leadingAnchor, constant: 8).isActive = true
        secretGroupLabel.trailingAnchor.constraint(equalTo: isFromSecretGroupImgBtn.leadingAnchor, constant: -8).isActive = true
        secretGroupLabel.centerYAnchor.constraint(equalTo: isFromSecretGroupImgBtn.centerYAnchor).isActive = true
        socialGroupLabel.leadingAnchor.constraint(equalTo: mainButtonPopUpView.leadingAnchor, constant: 8).isActive = true
        socialGroupLabel.trailingAnchor.constraint(equalTo: isFromSocialGroupImgBtn.leadingAnchor, constant: -8).isActive = true
        socialGroupLabel.centerYAnchor.constraint(equalTo: isFromSocialGroupImgBtn.centerYAnchor).isActive = true
        mainButtonPopUpView.addSubview(stackViewButtons)
        stackViewButtons.leadingAnchor.constraint(equalTo: mainButtonPopUpView.leadingAnchor, constant: 8).isActive = true
        stackViewButtons.trailingAnchor.constraint(equalTo: mainButtonPopUpView.trailingAnchor, constant: -8).isActive = true
        stackViewButtons.bottomAnchor.constraint(equalTo: mainButtonPopUpView.bottomAnchor, constant: -14).isActive = true
        stackViewButtons.topAnchor.constraint(equalTo: mainButtonPopUpView.topAnchor, constant: 14).isActive = true
        stackViewButtons.heightAnchor.constraint(equalToConstant: 40).isActive = true
        // main Button Tapped
        let mainButtonTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMainButtonTapped))
        mainButton.addGestureRecognizer(mainButtonTapGestureRecognizer)
        
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if !mainButtonPopUpView.isHidden {
            self.isTapped = true
            mainButtonPopUpView.isHidden = true
            mainButton.setImage(UIImage(named: "ic_HomeVCLogo"), for: .normal)
        } else {
            self.isTapped = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        isFromNewChatImgBtn.layer.cornerRadius = isFromNewChatImgBtn.frame.height/2
        isFromSecretGroupImgBtn.layer.cornerRadius = isFromSecretGroupImgBtn.frame.height/2
        isFromSocialGroupImgBtn.layer.cornerRadius = isFromSocialGroupImgBtn.frame.height/2
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .myNotificationKey_doodlechange, object: nil)
    }
    
    @objc func notificationReceived(_ notification: Notification) {
        guard let text = notification.userInfo?["text"] as? String else { return }
//        someImageView.layer.masksToBounds = true
//        let logoName = isLightMode ? "svg_light" : "svg_dark"
//        let namSvgImgVar: SVGKImage = SVGKImage(named: logoName)!
//        someImageView.image = namSvgImgVar.uiImage
    }
    @objc func tappedMe() {
        let searchController = GlobalSearchViewController()
        self.navigationController?.setViewControllers([ self, searchController ], animated: true)
    }
    
    private func reloadForMessageRequest() {
        AssertIsOnMainThread()
        dbConnection.beginLongLivedReadTransaction() // Jump to the latest commit
        dbConnection.read { transaction in
            self.threadsForMessageRequest.update(with: transaction)
        }
        threadViewModelCacheForMessageRequest.removeAll()
        messageCollectionView.reloadData()
    }
    
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
    
    private func deleteForMessageRequest(_ thread: TSThread) {
        guard let uniqueId: String = thread.uniqueId else { return }
        
        let alertVC: UIAlertController = UIAlertController(title: NSLocalizedString("MESSAGE_REQUESTS_DELETE_CONFIRMATION_ACTON", comment: ""), message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: NSLocalizedString("TXT_DELETE_TITLE", comment: ""), style: .destructive) { _ in
            Storage.write(
                with: { [weak self] transaction in
                    Storage.shared.cancelPendingMessageSendJobs(for: uniqueId, using: transaction)
//                    self?.updateContactAndThread(thread: thread, with: transaction)
                    
                    // Block the contact
                    if
                        let bchatId: String = (thread as? TSContactThread)?.contactBChatID(),
                        !thread.isBlocked(),
                        let contact: Contact = Storage.shared.getContact(with: bchatId, using: transaction)
                    {
                        contact.isBlocked = true
                        Storage.shared.setContact(contact, using: transaction)
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                            self?.messageCollectionView.reloadData()
                        }
                        
                    }
                },
                completion: {
                    // Force a config sync
                    MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                }
            )
        })
        alertVC.addAction(UIAlertAction(title: NSLocalizedString("TXT_CANCEL_TITLE", comment: ""), style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    private func threadForMessageRequest(at index: Int) -> TSThread? {
        var thread: TSThread? = nil
        
        dbConnection.read { transaction in
            let ext: YapDatabaseViewTransaction? = transaction.ext(TSThreadDatabaseViewExtensionName) as? YapDatabaseViewTransaction
            thread = ext?.object(atRow: UInt(index), inSection: 0, with: self.threads) as? TSThread
        }
        
        return thread
    }
    
    private func threadViewModelForMessageRequest(at index: Int) -> ThreadViewModel? {
        guard let thread = threadForMessageRequest(at: index), let uniqueId: String = thread.uniqueId else { return nil }
        
        if let cachedThreadViewModel = threadViewModelCacheForMessageRequest[uniqueId] {
            return cachedThreadViewModel
        }
        else {
            var threadViewModel: ThreadViewModel? = nil
            dbConnection.read { transaction in
                threadViewModel = ThreadViewModel(thread: thread, transaction: transaction)
            }
            threadViewModelCacheForMessageRequest[uniqueId] = threadViewModel
            
            return threadViewModel
        }
    }
        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isTapped = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(_:)), name: .myNotificationKey_doodlechange, object: nil)
        reload()
        updateNavBarButtons()
        if SSKPreferences.areWalletEnabled{
            //Dynamic node array
            self.getDynamicNodesFromAPI()
            
            if UserDefaults.standard.domainSchemas.isEmpty {}else {
                hashArray2 = UserDefaults.standard.domainSchemas
            }
            myGroup.notify(queue: .main) {
                print("Finished all requests.")
                if !SaveUserDefaultsData.SelectedNode.isEmpty {
                    if self.nodeArrayDynamic!.contains(SaveUserDefaultsData.SelectedNode) {
                        self.randomNodeValue = SaveUserDefaultsData.SelectedNode
                    } else {
                        self.randomNodeValue = self.nodeArrayDynamic!.randomElement()!
                        SaveUserDefaultsData.SelectedNode = self.randomNodeValue
                    }
                }else {
                    self.randomNodeValue = self.nodeArrayDynamic!.randomElement()!
                    SaveUserDefaultsData.SelectedNode = self.randomNodeValue
                }
                SaveUserDefaultsData.FinalWallet_node = self.randomNodeValue
                if WalletSharedData.sharedInstance.wallet != nil {
                    if self.wallet == nil {
                        self.isSyncingUI = true
                        self.syncingIsFromDelegateMethod = false
                    }
                }else {
                    self.init_syncing_wallet()
                }
            }
        }else {
            WalletSharedData.sharedInstance.wallet = nil
            closeWallet()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.isTapped = false
        mainButtonPopUpView.isHidden = true
        mainButton.setImage(UIImage(named: "ic_HomeVCLogo"), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }
    
    override func appDidBecomeActive(_ notification: Notification) {
        reload()
    }
    
    func getDynamicNodesFromAPI() {
        let url = globalDynamicNodeUrl
        // Create a custom URLRequest with cache policy
        var request = URLRequest(url: URL(string: url)!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        myGroup.enter()
        AF.request(request).responseDecodable(of: [NodeResponceModel].self) { response in
            switch response.result {
            case .success(let nodes):
                let uriArray = nodes.map { $0.uri }
                // Use the 'uriArray' here
                print(uriArray)
                self.nodeArrayDynamic = uriArray
                globalDynamicNodeArray = uriArray
                self.myGroup.leave()
            case .failure(let error):
                print("Error fetching data: \(error)")
                self.nodeArrayDynamic = self.nodeArray
                globalDynamicNodeArray = self.nodeArray
                self.myGroup.leave()
            }
        }
    }
    
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
        
        messageRequestCountLabel.text = "\(Int(unreadMessageRequestCount))"
        messageRequestCountLabel.isHidden = (Int(unreadMessageRequestCount) <= 0)
        messageRequestLabel.isHidden = (Int(unreadMessageRequestCount) <= 0)
        showOrHideMessageRequestCollectionViewButton.isHidden = (Int(unreadMessageRequestCount) <= 0)
        
        if !messageRequestLabel.isHidden {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0 + 38 + 16/*Values.smallSpacing*/)
        } else {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0 + 16/*Values.smallSpacing*/)
        }
        self.messageCollectionView.isHidden = true
        
        switch section {
        case 0:
//            if unreadMessageRequestCount > 0 && !CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] {
//                return 1
//            }
            return 0
        case 1: return Int(threadCount)//5
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
//            let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reuseIdentifier) as! ConversationCell
//            cell.threadViewModel = threadViewModel(at: indexPath.row)
//            return cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as! HomeTableViewCell
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
        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        tableView.reloadData()
        emptyStateView.isHidden = (threadCount != 0)
//        someImageView.isHidden = (threadCount != 0)
        isReloading = false
    }
    
    @objc private func handleYapDatabaseModifiedNotification(_ yapDatabase: YapDatabase) {
        // NOTE: This code is very finicky and crashes easily. Modify with care.
        AssertIsOnMainThread()
        reloadForMessageRequest()
        reload()
        // If we don't capture `threads` here, a race condition can occur where the
        // `thread.snapshotOfLastUpdate != firstSnapshot - 1` check below evaluates to
        // `false`, but `threads` then changes between that check and the
        // `ext.getSectionChanges(&sectionChanges, rowChanges: &rowChanges, for: notifications, with: threads)`
        // line. This causes `tableView.endUpdates()` to crash with an `NSInternalInconsistencyException`.
//        let threads = threads!
//        // Create a stable state for the connection and jump to the latest commit
//        let notifications = dbConnection.beginLongLivedReadTransaction()
//        guard !notifications.isEmpty else { return }
//        let ext = dbConnection.ext(TSThreadDatabaseViewExtensionName) as! YapDatabaseViewConnection
//        let hasChanges = (
//            ext.hasChanges(forGroup: TSMessageRequestGroup, in: notifications) ||
//            ext.hasChanges(forGroup: TSInboxGroup, in: notifications)
//        )
//
//        guard hasChanges else { return }
//
//        if let firstChangeSet = notifications[0].userInfo {
//            let firstSnapshot = firstChangeSet[YapDatabaseSnapshotKey] as! UInt64
//
//            // The 'getSectionChanges' code below will crash if we try to process multiple commits at once
//            // so just force a full reload
//            if threads.snapshotOfLastUpdate != firstSnapshot - 1 {
//                // Check if we inserted a new message request (if so then unhide the message request banner)
//                if
//                    let extensions: [String: Any] = firstChangeSet[YapDatabaseExtensionsKey] as? [String: Any],
//                    let viewExtensions: [String: Any] = extensions[TSThreadDatabaseViewExtensionName] as? [String: Any]
//                {
//                    // Note: We do a 'flatMap' here rather than explicitly grab the desired key because
//                    // the key we need is 'changeset_key_changes' in 'YapDatabaseViewPrivate.h' so could
//                    // change due to an update and silently break this - this approach is a bit safer
//                    let allChanges: [Any] = Array(viewExtensions.values).compactMap { $0 as? [Any] }.flatMap { $0 }
//                    let messageRequestInserts = allChanges
//                        .compactMap { $0 as? YapDatabaseViewRowChange }
//                        .filter { $0.finalGroup == TSMessageRequestGroup && $0.type == .insert }
//
//                    if !messageRequestInserts.isEmpty && CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] {
//                        CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] = false
//                    }
//                }
//
//                // If there are no unread message requests then hide the message request banner
//                if unreadMessageRequestCount == 0 {
//                    CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] = true
//                }
//
//                return reload()
//            }
//        }
//
//        var sectionChanges = NSArray()
//        var rowChanges = NSArray()
//        ext.getSectionChanges(&sectionChanges, rowChanges: &rowChanges, for: notifications, with: threads)
//
//        // Separate out the changes for new message requests and the inbox (so we can avoid updating for
//        // new messages within an existing message request)
//        let messageRequestChanges = rowChanges
//            .compactMap { $0 as? YapDatabaseViewRowChange }
//            .filter { $0.originalGroup == TSMessageRequestGroup || $0.finalGroup == TSMessageRequestGroup }
//        let inboxRowChanges = rowChanges
//            .compactMap { $0 as? YapDatabaseViewRowChange }
//            .filter { $0.originalGroup == TSInboxGroup || $0.finalGroup == TSInboxGroup }
//
//        guard sectionChanges.count > 0 || inboxRowChanges.count > 0 || messageRequestChanges.count > 0 else { return }
//
//                tableView.beginUpdates()
//        self.tableView.performBatchUpdates({
//            // If we need to unhide the message request row and then re-insert it
//            if !messageRequestChanges.isEmpty {
//
//                // If there are no unread message requests then hide the message request banner
//                if unreadMessageRequestCount == 0 && tableView.numberOfRows(inSection: 0) == 1 {
//                    CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] = true
//                    tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//                }
//                else {
//                    if tableView.numberOfRows(inSection: 0) == 1 && Int(unreadMessageRequestCount) <= 0 {
//                        tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//                    }
//                    else if tableView.numberOfRows(inSection: 0) == 0 && Int(unreadMessageRequestCount) > 0 && !CurrentAppContext().appUserDefaults()[.hasHiddenMessageRequests] {
//                        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//                    }
//                }
//            }
//
//            inboxRowChanges.forEach { rowChange in
//                let key = rowChange.collectionKey.key
//                threadViewModelCache[key] = nil
//
//                switch rowChange.type {
//                case .delete:
//                    tableView.deleteRows(at: [ rowChange.indexPath! ], with: .automatic)
//
//                case .insert:
//                    tableView.insertRows(at: [ rowChange.newIndexPath! ], with: .automatic)
//
//                case .update:
//                    tableView.reloadRows(at: [ rowChange.indexPath! ], with: .automatic)
//
//                case .move:
//                    // Note: We need to handle the move from the message requests section to the inbox (since
//                    // we are only showing a single row for message requests we need to custom handle this as
//                    // an insert as the change won't be defined correctly)
//                    if rowChange.originalGroup == TSMessageRequestGroup && rowChange.finalGroup == TSInboxGroup {
//                        tableView.insertRows(at: [ rowChange.newIndexPath! ], with: .automatic)
//                    }
//                    else if rowChange.originalGroup == TSInboxGroup && rowChange.finalGroup == TSMessageRequestGroup {
//                        tableView.deleteRows(at: [ rowChange.indexPath! ], with: .automatic)
//                    }
//
//                default: break
//                }
//            }
//                    tableView.endUpdates()
//        }, completion: nil)
//        // HACK: Moves can have conflicts with the other 3 types of change.
//        // Just batch perform all the moves separately to prevent crashing.
//        // Since all the changes are from the original state to the final state,
//        // it will still be correct if we pick the moves out.
//        //        tableView.beginUpdates()
//        self.tableView.performBatchUpdates({
//            rowChanges.forEach { rowChange in
//                let rowChange = rowChange as! YapDatabaseViewRowChange
//                let key = rowChange.collectionKey.key
//                threadViewModelCache[key] = nil
//
//                switch rowChange.type {
//                case .move:
//                    // Since we are custom handling this specific movement in the above 'updates' call we need
//                    // to avoid trying to handle it here
//                    if rowChange.originalGroup == TSMessageRequestGroup || rowChange.finalGroup == TSMessageRequestGroup {
//                        return
//                    }
//
//                    tableView.moveRow(at: rowChange.indexPath!, to: rowChange.newIndexPath!)
//
//                default: break
//                }
//            }
//            //        tableView.endUpdates()
//        }, completion: nil)
//        emptyStateView.isHidden = (threadCount != 0)
//        someImageView.isHidden = (threadCount != 0)
        self.tableView.reloadData()
        self.messageCollectionView.reloadData()
    }
    
    @objc private func handleProfileDidChangeNotification(_ notification: Notification) {
        tableView.reloadData() // TODO: Just reload the affected cell
    }
    
    @objc private func handleLocalProfileDidChangeNotification(_ notification: Notification) {
        updateNavBarButtons()
    }
    
    @objc private func handleSeedViewedNotification(_ notification: Notification) {
//        tableViewTopConstraint.isActive = false
//        tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0 + 16/*Values.smallSpacing*/)
//        self.messageCollectionView.isHidden = false
    }
    
    @objc private func handleBlockedContactsUpdatedNotification(_ notification: Notification) {
        self.tableView.reloadData() // TODO: Just reload the affected cell
    }
    
    @objc private func showOrHideMessageRequestCollectionViewButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isOpen = !isOpen
//        reloadForMessageRequest()
        if !isOpen {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 80 + 38 + 16/*Values.smallSpacing*/)
            self.messageCollectionView.isHidden = false
        } else {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0 + 38 + 16/*Values.smallSpacing*/)
            self.messageCollectionView.isHidden = true
        }
    }
    
    private func updateNavBarButtons() {
//        let backButton = UIBarButtonItem(image: UIImage(named: "Group 630"), style: .plain, target: self, action: #selector(openSettings))
//        backButton.tintColor = UIColor(red: 0.18, green: 0.63, blue: 0.13, alpha: 1.00)
//        backButton.isAccessibilityElement = true
//        self.navigationItem.leftBarButtonItem = backButton
                
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        
        let publicKey = getUserHexEncodedPublicKey()
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
                //set image for button
        button.widthAnchor.constraint(equalToConstant: 42).isActive = true
        button.heightAnchor.constraint(equalToConstant: 42).isActive = true

        button.setImage(getProfilePicture(of: 42, for: publicKey), for: UIControl.State.normal)
                //add function for button
        button.addTarget(self, action: #selector(openSettings), for: UIControl.Event.touchUpInside)
                //set frame
                button.frame = CGRectMake(0, 0, 42, 42)
        button.layer.cornerRadius = 21
        button.layer.masksToBounds = true
        
        
        lazy var outerView: UIView = {
            let View = UIView()
            View.translatesAutoresizingMaskIntoConstraints = false
            View.backgroundColor = .clear
            View.widthAnchor.constraint(equalToConstant: 42).isActive = true
            View.heightAnchor.constraint(equalToConstant: 42).isActive = true
            return View
        }()
        outerView.addSubview(button)
        
        if let statusView = view.viewWithTag(333222) {
            statusView.removeFromSuperview()
        }
        // Path status indicator
            let pathStatusView = PathStatusView()
            pathStatusView.tag = 333222
            pathStatusView.accessibilityLabel = "Current onion routing path indicator"
            pathStatusView.set(.width, to: PathStatusView.size)
            pathStatusView.set(.height, to: PathStatusView.size)
            outerView.addSubview(pathStatusView)
            pathStatusView.layer.borderWidth = 2
        pathStatusView.layer.borderColor = UIColor(hex: 0x1C1C26).cgColor
            pathStatusView.pin(.trailing, to: .trailing, of: outerView)
            pathStatusView.pin(.top, to: .top, of: outerView)
        
        

        let barButton = UIBarButtonItem(customView: outerView)
        self.navigationItem.leftBarButtonItem = barButton
        
        
        var rightBarButtonItems: [UIBarButtonItem] = []
        
        // Right bar button item - search button
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchUI))
        rightBarButtonItem.accessibilityLabel = "Search button"
        rightBarButtonItem.isAccessibilityElement  = true
        rightBarButtonItems.append(rightBarButtonItem)
        
//        let rightBarButtonItemWallet =  UIBarButtonItem(image: UIImage(named: "ic_walletHomeNew"), style: .plain, target: self, action: #selector(showWallet))
        let wallet = UIButton(type: .custom)
        wallet.frame = CGRect(x: 0.0, y: 0.0, width: 28, height: 28)
        wallet.widthAnchor.constraint(equalToConstant: 28).isActive = true
        wallet.heightAnchor.constraint(equalToConstant: 28).isActive = true
        wallet.setImage(UIImage(named:"ic_walletHomeNew"), for: .normal)
        wallet.addTarget(self, action: #selector(showWallet), for: UIControl.Event.touchUpInside)
          let walletBarItem = UIBarButtonItem(customView: wallet)
        
        rightBarButtonItems.append(walletBarItem)
        
        navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
    func getProfilePicture(of size: CGFloat, for publicKey: String) -> UIImage? {
        guard !publicKey.isEmpty else { return nil }
        if let profilePicture = OWSProfileManager.shared().profileAvatar(forRecipientId: publicKey) {
            return profilePicture
        } else {
            // TODO: Pass in context?
            let displayName = Storage.shared.getContact(with: publicKey)?.name ?? publicKey
            return Identicon.generatePlaceholderIcon(seed: publicKey, text: displayName, size: size)
        }
    }
    
    
    @objc override internal func handleAppModeChangedNotification(_ notification: Notification) {
        super.handleAppModeChangedNotification(notification)
        //        let gradient = Gradients.homeVCFade
        //        fadeView.setGradient(gradient) // Re-do the gradient
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        tableView.reloadData()
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
            delete.backgroundColor = Colors.mainBackGroundColor2//Colors.destructive
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
    
    //Main NewConversationButtonSet PopUpView
    @objc private func handleMainButtonTapped() {
        mainButtonPopUpView.isHidden = !mainButtonPopUpView.isHidden
        if mainButtonPopUpView.isHidden == true {
            mainButton.setImage(UIImage(named: "ic_HomeVCLogo"), for: .normal)
        } else {
            mainButton.setImage(UIImage(named: "ic_HomeVcLogo_close"), for: .normal)
        }
    }
    // New Chat
    @objc private func newChatButtonTapped(_ sender: UIButton) {
        mainButtonPopUpView.isHidden = true
        let vc = ChatNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    // Secret Group
    @objc private func secretGroupButtonTapped(_ sender: UIButton) {
        mainButtonPopUpView.isHidden = true
        let vc = CreateSecretGroupScreenVC()
        self.navigationController?.pushViewController(vc, animated: true)
//        let newSecretGroupVC = NewSecretGroupVC()
//        let navigationController = OWSNavigationController(rootViewController: newSecretGroupVC)
//        if UIDevice.current.isIPad {
//            navigationController.modalPresentationStyle = .fullScreen
//        }
//        present(navigationController, animated: true, completion: nil)
    }
    // Social Group
    @objc private func socialGroupButtonTapped(_ sender: UIButton) {
        mainButtonPopUpView.isHidden = true
        let vc = SocialGroupNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    
    // New Chat
    @objc func createNewDM() {
        
    }
    
    @objc private func openSettings() {
        mainButtonPopUpView.isHidden = true
        let menu = SideMenuNavigationController(rootViewController: SideMenuVC())
        SideMenuManager.default.leftMenuNavigationController = menu
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    var isOpen = false
    @objc private func showSearchUI() {
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: false, completion: nil)
        }
        let searchController = GlobalSearchViewController()
        self.navigationController?.setViewControllers([ self, searchController ], animated: true)
    }
    
    @objc private func showWallet() {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            // MARK: - Old flow (without wallet)
            if SaveUserDefaultsData.israndomUUIDPassword == "" {
                let vc = EnableWalletVC()
                navigationController!.pushViewController(vc, animated: true)
                return
            }
            // MARK: - New flow (with wallet)
            if SSKPreferences.areWalletEnabled {
                if SaveUserDefaultsData.WalletPassword.isEmpty {
                    let vc = NewPasswordVC()
                    vc.isGoingWallet = true
                    vc.isVerifyPassword = true
                    navigationController!.pushViewController(vc, animated: true)
                } else {
                    let vc = NewPasswordVC()
                    vc.isGoingWallet = true
                    vc.isVerifyPassword = true
                    navigationController!.pushViewController(vc, animated: true)
                }
            } else {
                let vc = EnableWalletVC()
                navigationController!.pushViewController(vc, animated: true)
            }
        } else {
            self.showToastMsg(message: "Please check your internet connection", seconds: 1.0)
        }

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




extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if messageRequestCountForMessageRequest == 0 {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0 + 16/*Values.smallSpacing*/)
            self.messageCollectionView.isHidden = true
            self.showOrHideMessageRequestCollectionViewButton.isSelected = false
            self.isOpen = false
        } else {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 80 + 38 + 16/*Values.smallSpacing*/)
            self.messageCollectionView.isHidden = false
            self.showOrHideMessageRequestCollectionViewButton.isSelected = true
            self.isOpen = true
        }
        
        
        messageRequestCountLabel.text = "\(Int(messageRequestCountForMessageRequest))"
        messageRequestCountLabel.isHidden = (Int(messageRequestCountForMessageRequest) <= 0)
        messageRequestLabel.isHidden = (Int(messageRequestCountForMessageRequest) <= 0)
        showOrHideMessageRequestCollectionViewButton.isHidden = (Int(messageRequestCountForMessageRequest) <= 0)
//        if !messageRequestLabel.isHidden {
//            tableViewTopConstraint.isActive = false
//            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0 + 38 + 16/*Values.smallSpacing*/)
//        } else {
//            tableViewTopConstraint.isActive = false
//            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0 + 16/*Values.smallSpacing*/)
//        }
        
        
        if messageRequestCountForMessageRequest == 0 {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 0 + 16/*Values.smallSpacing*/)
            self.messageCollectionView.isHidden = true
            self.showOrHideMessageRequestCollectionViewButton.isSelected = false
            self.isOpen = false
            messageRequestCountLabel.isHidden = true
            messageRequestLabel.isHidden = true
            showOrHideMessageRequestCollectionViewButton.isHidden = true
        } else {
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = tableView.pin(.top, to: .top, of: view, withInset: 80 + 38 + 16/*Values.smallSpacing*/)
            self.messageCollectionView.isHidden = false
            self.showOrHideMessageRequestCollectionViewButton.isSelected = false
            self.isOpen = false
            messageRequestCountLabel.isHidden = false
            messageRequestLabel.isHidden = false
            showOrHideMessageRequestCollectionViewButton.isHidden = false
        }
        
        

        return Int(messageRequestCountForMessageRequest)//10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = messageCollectionView.dequeueReusableCell(withReuseIdentifier: "MessageRequestCollectionViewCell", for: indexPath) as! MessageRequestCollectionViewCell
//        cell.backgroundColor = .red
        cell.profileImageView.update(for: threadViewModelForMessageRequest(at: indexPath.row)!.threadRecord)
        
        if threadViewModelForMessageRequest(at: indexPath.row)!.isGroupThread {
            if threadViewModelForMessageRequest(at: indexPath.row)!.name.isEmpty {
                cell.nameLabel.text =  "Unknown Group"
            }
            else {
                cell.nameLabel.text = threadViewModelForMessageRequest(at: indexPath.row)?.name
            }
        }
        else {
            if threadViewModelForMessageRequest(at: indexPath.row)!.threadRecord.isNoteToSelf() {
                cell.nameLabel.text = NSLocalizedString("NOTE_TO_SELF", comment: "")
            }
            else {
                let hexEncodedPublicKey: String = threadViewModelForMessageRequest(at: indexPath.row)!.contactBChatID!
                let displayName: String = (Storage.shared.getContact(with: hexEncodedPublicKey)?.displayName(for: .regular) ?? hexEncodedPublicKey)
                let middleTruncatedHexKey: String = "\(hexEncodedPublicKey.prefix(4))...\(hexEncodedPublicKey.suffix(4))"
                cell.nameLabel.text = (displayName == hexEncodedPublicKey ? middleTruncatedHexKey : displayName)
            }
        }
        
        cell.removeCallback = {
            guard let thread = self.threadForMessageRequest(at: indexPath.row) else { return }
            self.deleteForMessageRequest(thread)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 6  //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: 65, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = NewMessageRequestVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    
}


class CollectionViewCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct NodeResponceModel: Codable {
    let uri: String
    let isDefault: Bool
    enum CodingKeys: String, CodingKey {
        case uri
        case isDefault = "is_default"
    }
}
