
import UIKit
import SideMenu
import SVGKit
import BChatUIKit
import Alamofire

final class HomeVC : BaseVC {
    private var threads: YapDatabaseViewMappings!
    internal var threadViewModelCache: [String:ThreadViewModel] = [:] // Thread ID to ThreadViewModel
    internal  var tableViewTopConstraint: NSLayoutConstraint!
    internal  var messageRequestLabelTopConstraint: NSLayoutConstraint!
    internal  var collectionViewTopConstraint: NSLayoutConstraint!
    internal var unreadMessageRequestCount: UInt {
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
    internal var threadCount: UInt {
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
    
    internal var messageRequestCountForMessageRequest: UInt {
        threadsForMessageRequest.numberOfItems(inGroup: TSMessageRequestGroup)
    }
    
    // MARK: UI Components
    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = Colors.mainBackGroundColor2
        result.separatorStyle = .none
        result.register(MessageRequestsCell.self, forCellReuseIdentifier: MessageRequestsCell.reuseIdentifier)
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
    
    var type = HostManager.shared.hostType.hostValue
    var nodeArray = HostManager.shared.hostNet
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
    lazy var mainButtonPopUpView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.homeScreenFloatingbackgroundColor
        stackView.layer.cornerRadius = 16
        stackView.isHidden = true
        return stackView
    }()
    
    lazy var mainButton: UIButton = {
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
        result.text = NSLocalizedString("NEW_CHAT_PLUS", comment: "")
        result.textColor = Colors.greenColor
        result.textAlignment = .right
        return result
    }()
    
    private lazy var secretGroupLabel: UILabel = {
        let result: UILabel = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.text = NSLocalizedString("SECRET_GROUP_TITLE", comment: "")
        result.textColor = Colors.greenColor
        result.textAlignment = .right
        return result
    }()
    
    private lazy var socialGroupLabel: UILabel = {
        let result: UILabel = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.text = NSLocalizedString("SOCIAL_GROUP_TITLE", comment: "")
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
    
    lazy var noInternetView: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = .clear
        View.layer.cornerRadius = 12
        View.layer.borderColor = Colors.borderColorNew.cgColor
        View.layer.borderWidth = 1
        View.isHidden = true
        return View
    }()
    
    lazy var noInternetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_noInternet")
        return imageView
    }()
    
    private lazy var noInternetLabel: UILabel = {
        let result: UILabel = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Fonts.OpenSans(ofSize: 10)
        result.text = "You are not connected to the Hop. Check your internet connection or Restart the app!"
        result.textColor = Colors.noInternetTitleColor
        result.textAlignment = .left
        result.numberOfLines = 0
        return result
    }()
    
    
    var messageCollectionView: UICollectionView!
    let myGroup = DispatchGroup()
    var nodeArrayDynamic : [String]?
    var isManualyCloseMessageRequest = false
    
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
        
        view.addSubview(noInternetView)
        noInternetView.addSubViews(noInternetImageView, noInternetLabel)
        noInternetView.isHidden = true
        
        NSLayoutConstraint.activate([
            noInternetView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            noInternetView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            noInternetView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            noInternetView.heightAnchor.constraint(equalToConstant: 57),
            
            noInternetImageView.leadingAnchor.constraint(equalTo: noInternetView.leadingAnchor, constant: 18),
            noInternetImageView.centerYAnchor.constraint(equalTo: noInternetView.centerYAnchor),
            noInternetImageView.heightAnchor.constraint(equalToConstant: 20),
            noInternetImageView.widthAnchor.constraint(equalToConstant: 20),
            
            noInternetLabel.leadingAnchor.constraint(equalTo: noInternetImageView.trailingAnchor, constant: 13),
            noInternetLabel.trailingAnchor.constraint(equalTo: noInternetView.trailingAnchor, constant: -18),
            noInternetLabel.centerYAnchor.constraint(equalTo: noInternetView.centerYAnchor),
            
        ])
               
        view.addSubview(messageRequestLabel)
        view.addSubview(messageRequestCountLabel)
        view.addSubview(showOrHideMessageRequestCollectionViewButton)
        showOrHideMessageRequestCollectionViewButton.isSelected = false
        
        NSLayoutConstraint.activate([
            messageRequestLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 19),
            
            messageRequestCountLabel.leadingAnchor.constraint(equalTo: messageRequestLabel.trailingAnchor, constant: 6),
            messageRequestCountLabel.centerYAnchor.constraint(equalTo: messageRequestLabel.centerYAnchor),
            messageRequestCountLabel.heightAnchor.constraint(equalToConstant: 22),
            messageRequestCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 22),
            
            showOrHideMessageRequestCollectionViewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            showOrHideMessageRequestCollectionViewButton.centerYAnchor.constraint(equalTo: messageRequestLabel.centerYAnchor),
            showOrHideMessageRequestCollectionViewButton.heightAnchor.constraint(equalToConstant: 24),
            showOrHideMessageRequestCollectionViewButton.widthAnchor.constraint(equalToConstant: 24),
        ])
        messageRequestLabelTopConstraint = messageRequestLabel.pin(.top, to: .top, of: view, withInset: 16)
                
        // CollectionView
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        messageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        messageCollectionView.dataSource = self
        messageCollectionView.delegate = self
        messageCollectionView.register(MessageRequestCollectionViewCell.self, forCellWithReuseIdentifier: MessageRequestCollectionViewCell.reuseidentifier)
        messageCollectionView.showsHorizontalScrollIndicator = false
        messageCollectionView.backgroundColor = .clear
        messageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageCollectionView)
        // Add constraints for collectionView
        NSLayoutConstraint.activate([
            messageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            messageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            messageCollectionView.heightAnchor.constraint(equalToConstant: 80),
        ])
        
        collectionViewTopConstraint = messageCollectionView.pin(.top, to: .top, of: view, withInset: 38 + 8)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpNavBarSessionHeading()
        messageRequestLabelTopConstraint.isActive = false
        collectionViewTopConstraint.isActive = false
        if !NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            self.noInternetView.isHidden = false
            messageRequestLabelTopConstraint = messageRequestLabel.pin(.top, to: .top, of: view, withInset: 16 + 69)
            collectionViewTopConstraint = messageCollectionView.pin(.top, to: .top, of: view, withInset: 38 + 8 + 69)
        } else {
            self.noInternetView.isHidden = true
            messageRequestLabelTopConstraint = messageRequestLabel.pin(.top, to: .top, of: view, withInset: 16)
            collectionViewTopConstraint = messageCollectionView.pin(.top, to: .top, of: view, withInset: 38 + 8)
        }
        WalletSync.isInsideWallet = false
        self.isManualyCloseMessageRequest = false
        self.isTapped = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceived(_:)), name: .doodleChangeNotification, object: nil)
        reload()
        updateNavBarButtons()
        if SSKPreferences.areWalletEnabled {
            //Dynamic node array
            self.getDynamicNodesFromAPI()
            
            if UserDefaults.standard.domainSchemas.isEmpty {} else {
                hashArray2 = UserDefaults.standard.domainSchemas
            }
            myGroup.notify(queue: .main) {
                if !SaveUserDefaultsData.SelectedNode.isEmpty {
                    if self.nodeArrayDynamic!.contains(SaveUserDefaultsData.SelectedNode) {
                        self.randomNodeValue = SaveUserDefaultsData.SelectedNode
                    } else {
                        self.randomNodeValue = self.nodeArrayDynamic!.randomElement()!
                        SaveUserDefaultsData.SelectedNode = self.randomNodeValue
                    }
                } else {
                    self.randomNodeValue = self.nodeArrayDynamic!.randomElement()!
                    SaveUserDefaultsData.SelectedNode = self.randomNodeValue
                }
                SaveUserDefaultsData.FinalWallet_node = self.randomNodeValue
                if WalletSharedData.sharedInstance.wallet != nil {
                    if self.wallet == nil {
                        self.isSyncingUI = true
                        self.syncingIsFromDelegateMethod = false
                    }
                } else {
                    self.init_syncing_wallet()
                }
            }
        } else {
            WalletSharedData.sharedInstance.wallet = nil
            closeWallet()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.showOrHideMessageRequestCollectionViewButton.isSelected = false
        self.isManualyCloseMessageRequest = false
        self.isTapped = false
        mainButtonPopUpView.isHidden = true
        mainButton.setImage(UIImage(named: "ic_HomeVCLogo"), for: .normal)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .doodleChangeNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        isFromNewChatImgBtn.layer.cornerRadius = isFromNewChatImgBtn.frame.height/2
        isFromSecretGroupImgBtn.layer.cornerRadius = isFromSecretGroupImgBtn.frame.height/2
        isFromSocialGroupImgBtn.layer.cornerRadius = isFromSocialGroupImgBtn.frame.height/2
    }
    
    override func appDidBecomeActive(_ notification: Notification) {
        reload()
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
    
    @objc func notificationReceived(_ notification: Notification) {
        guard let text = notification.userInfo?["text"] as? String else { return }
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
    
    func deleteForMessageRequest(_ thread: TSThread) {
        guard let uniqueId: String = thread.uniqueId else { return }
        let alertVC: UIAlertController = UIAlertController(title: NSLocalizedString("MESSAGE_REQUESTS_DELETE_CONFIRMATION_ACTON", comment: ""), message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: NSLocalizedString("TXT_DELETE_TITLE", comment: ""), style: .destructive) { _ in
            Storage.write(
                with: { [weak self] transaction in
                    guard let strongSelf = self else { return }
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
                        DispatchQueue.main.async {
                            strongSelf.tableView.reloadData()
                            strongSelf.messageCollectionView.reloadData()
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
    
    func threadForMessageRequest(at index: Int) -> TSThread? {
        var thread: TSThread? = nil
        
        dbConnection.read { transaction in
            let ext: YapDatabaseViewTransaction? = transaction.ext(TSThreadDatabaseViewExtensionName) as? YapDatabaseViewTransaction
            thread = ext?.object(atRow: UInt(index), inSection: 0, with: self.threads) as? TSThread
        }
        
        return thread
    }
    
    func threadViewModelForMessageRequest(at index: Int) -> ThreadViewModel? {
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
                guard let strongSelf = self else { return }
                switch result {
                    case .success(let wallet):
                        strongSelf.wallet = wallet
                        WalletSharedData.sharedInstance.wallet = wallet
                        strongSelf.connect(wallet: wallet)
                        strongSelf.syncedflag = true
                    case .failure(_):
                    WalletSharedData.sharedInstance.wallet = nil
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
                    } else {
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
        isReloading = false
    }
    
    @objc private func handleYapDatabaseModifiedNotification(_ yapDatabase: YapDatabase) {
        // NOTE: This code is very finicky and crashes easily. Modify with care.
        AssertIsOnMainThread()
        reloadForMessageRequest()
        reload()
    }
    
    @objc private func handleProfileDidChangeNotification(_ notification: Notification) {
        tableView.reloadData() // TODO: Just reload the affected cell
    }
    
    @objc private func handleLocalProfileDidChangeNotification(_ notification: Notification) {
        updateNavBarButtons()
        reload()
    }
    
    @objc private func handleSeedViewedNotification(_ notification: Notification) {

    }
    
    @objc private func handleBlockedContactsUpdatedNotification(_ notification: Notification) {
        self.tableView.reloadData() // TODO: Just reload the affected cell
    }
    
    @objc private func showOrHideMessageRequestCollectionViewButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.isManualyCloseMessageRequest = false
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = NetworkReachabilityStatus.isConnectedToNetworkSignal() ? tableView.pin(.top, to: .top, of: view, withInset: 80 + 38 + 16) : tableView.pin(.top, to: .top, of: view, withInset: 80 + 38 + 16 + 69)
            self.messageCollectionView.isHidden = false
        } else {
            self.isManualyCloseMessageRequest = true
            tableViewTopConstraint.isActive = false
            tableViewTopConstraint = NetworkReachabilityStatus.isConnectedToNetworkSignal() ? tableView.pin(.top, to: .top, of: view, withInset: 0 + 38 + 16) : tableView.pin(.top, to: .top, of: view, withInset: 0 + 38 + 16 + 69)
            self.messageCollectionView.isHidden = true
        }
        noInternetView.isHidden = NetworkReachabilityStatus.isConnectedToNetworkSignal()
        messageRequestLabelTopConstraint.isActive = false
        messageRequestLabelTopConstraint = NetworkReachabilityStatus.isConnectedToNetworkSignal() ? messageRequestLabel.pin(.top, to: .top, of: view, withInset: 16) : messageRequestLabel.pin(.top, to: .top, of: view, withInset: 16 + 69)
        collectionViewTopConstraint.isActive = false
        collectionViewTopConstraint = NetworkReachabilityStatus.isConnectedToNetworkSignal() ? messageCollectionView.pin(.top, to: .top, of: view, withInset: 38 + 8) : messageCollectionView.pin(.top, to: .top, of: view, withInset: 38 + 8 + 69)
        setUpNavBarSessionHeading()
    }
    
    private func updateNavBarButtons() {
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
        
        // For BNS Verified User
        button.layer.borderColor = Colors.bothGreenColor.cgColor

        lazy var verifiedImageView: UIImageView = {
            let result = UIImageView()
            result.set(.width, to: 18)
            result.set(.height, to: 18)
            result.contentMode = .center
            result.image = UIImage(named: "ic_verified_image")
            return result
        }()
        
        lazy var outerView: UIView = {
            let View = UIView()
            View.translatesAutoresizingMaskIntoConstraints = false
            View.backgroundColor = .clear
            View.widthAnchor.constraint(equalToConstant: 42).isActive = true
            View.heightAnchor.constraint(equalToConstant: 42).isActive = true
            return View
        }()
        outerView.addSubViews(button, verifiedImageView)
        // For BNS Verified User
        verifiedImageView.pin(.trailing, to: .trailing, of: outerView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: outerView, withInset: 1)
        
        let isBnsUser = UserDefaults.standard.bool(forKey: Constants.isBnsVerifiedUser)
        button.layer.borderWidth = isBnsUser ? 3 : 0
        verifiedImageView.isHidden = isBnsUser ? false : true

        let barButton = UIBarButtonItem(customView: outerView)
        self.navigationItem.leftBarButtonItem = barButton
        
        var rightBarButtonItems: [UIBarButtonItem] = []
        
        // Right bar button item - search button
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchUI))
        rightBarButtonItem.accessibilityLabel = "Search button"
        rightBarButtonItem.isAccessibilityElement  = true
        rightBarButtonItems.append(rightBarButtonItem)
        
        let wallet = UIButton(type: .custom)
        wallet.frame = CGRect(x: 0.0, y: 0.0, width: 28, height: 28)
        wallet.widthAnchor.constraint(equalToConstant: 28).isActive = true
        wallet.heightAnchor.constraint(equalToConstant: 28).isActive = true
        wallet.setImage(UIImage(named:"ic_walletHomeNew"), for: .normal)
        wallet.addTarget(self, action: #selector(showWallet), for: UIControl.Event.touchUpInside)
          let walletBarItem = UIBarButtonItem(customView: wallet)
        
        rightBarButtonItems.append(walletBarItem)
        
        navigationItem.rightBarButtonItems = rightBarButtonItems
        setUpNavBarSessionHeading()
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
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        tableView.reloadData()
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
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.setViewControllers([ self, conversationVC ], animated: true)
    }
    
    func deleteThread(_ thread: TSThread) {
        guard let uniqueId = thread.uniqueId else { return }
        let openGroupV2 = Storage.shared.getV2OpenGroup(for: uniqueId)
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
        if isLightMode {
            mainButtonPopUpView.setShadow(radius: 30, opacity: 0.1, offset: .zero, color: UIColor.black.cgColor)
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
        let menu = SideMenuNavigationController(rootViewController: SideMenuViewController())
        let appScreenRect = UIApplication.shared.keyWindow?.bounds ?? UIWindow().bounds
        let minimumSize = min(appScreenRect.width, appScreenRect.height)
        menu.menuWidth = round(minimumSize * 0.80)
        SideMenuManager.default.leftMenuNavigationController = menu
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
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
            self.showToast(message: "Please check your internet connection", seconds: 1.0)
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
    func thread(at index: Int) -> TSThread? {
        var thread: TSThread? = nil
        dbConnection.read { transaction in
            // Note: Section needs to be '1' as we now have 'TSMessageRequests' as the 0th section
            let ext = transaction.ext(TSThreadDatabaseViewExtensionName) as! YapDatabaseViewTransaction
            thread = ext.object(atRow: UInt(index), inSection: 1, with: self.threads) as? TSThread
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
    
    func updateTableViewCell(_ indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func setTableViewTopConstraint(_ inset: CGFloat = 0) {
        noInternetView.isHidden = NetworkReachabilityStatus.isConnectedToNetworkSignal()
        messageRequestLabelTopConstraint.isActive = false
        messageRequestLabelTopConstraint = NetworkReachabilityStatus.isConnectedToNetworkSignal() ? messageRequestLabel.pin(.top, to: .top, of: view, withInset: 16) : messageRequestLabel.pin(.top, to: .top, of: view, withInset: 16 + 69)
        collectionViewTopConstraint.isActive = false
        collectionViewTopConstraint = NetworkReachabilityStatus.isConnectedToNetworkSignal() ? messageCollectionView.pin(.top, to: .top, of: view, withInset: 38 + 8) : messageCollectionView.pin(.top, to: .top, of: view, withInset: 38 + 8 + 69)
        tableViewTopConstraint = NetworkReachabilityStatus.isConnectedToNetworkSignal() ? tableView.pin(.top, to: .top, of: view, withInset: inset) : tableView.pin(.top, to: .top, of: view, withInset: inset + 69)
        setUpNavBarSessionHeading()
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
