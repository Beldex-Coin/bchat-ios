import BChatUIKit
import AVFAudio
import BChatMessagingKit
import UIKit
import SVGKit
import PromiseKit
import BChatUtilitiesKit
import NVActivityIndicatorView
// TODO:
// • Slight paging glitch when scrolling up and loading more content
// • Photo rounding (the small corners don't have the correct rounding)
// • Remaining search glitchiness

// Required globle variable for audio is playing or not.
var isAudioPlaying = false
var isAudioRecording = false

final class ConversationVC : BaseVC, ConversationViewModelDelegate, OWSConversationSettingsViewDelegate, ConversationSearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, MTSlideToOpenDelegate {
    func conversationSettingsDidRequestConversationSearch(_ conversationSettingsViewController: ChatSettingsVC) {
        showSearchUI()
        popAllConversationSettingsViews {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Without this delay the search bar doesn't show
                self.searchController.uiSearchController.searchBar.becomeFirstResponder()
                self.searchController.uiSearchController.searchBar.showsCancelButton = true
            }
        }
    }
    
    func popAllConversationSettingsViewsWithCompletion(_ completionBlock: (() -> Void)?) {
        print("")
    }
    
    let thread: TSThread
    let threadStartedAsMessageRequest: Bool
    let focusedMessageID: String? // This is used for global search
    var focusedMessageIndexPath: IndexPath?
    var initialUnreadCount: UInt = 0
    var unreadViewItems: [ConversationViewItem] = []
    var scrollButtonBottomConstraint: NSLayoutConstraint?
    var scrollButtonMessageRequestsBottomConstraint: NSLayoutConstraint?
    var messageRequestsViewBotomConstraint: NSLayoutConstraint?
    // Search
    var isShowingSearchUI = false
    var lastSearchedText: String?
    // Audio playback & recording
    var audioPlayer: OWSAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var audioTimer: Timer?
    // Context menu
    var contextMenuWindow: ContextMenuWindow?
    var contextMenuVC: ContextMenuVC?
    // Mentions
    var oldText = ""
    var currentMentionStartIndex: String.Index?
    var mentions: [Mention] = []
    // Scrolling & paging
    var isUserScrolling = false
    var didFinishInitialLayout = false
    var isLoadingMore = false
    var scrollDistanceToBottomBeforeUpdate: CGFloat?
    var baselineKeyboardHeight: CGFloat = 0
    var isSyncingStatus = false
    
    var audioSession: OWSAudioSession { Environment.shared.audioSession }
    var dbConnection: YapDatabaseConnection { OWSPrimaryStorage.shared().uiDatabaseConnection }
    var viewItems: [ConversationViewItem] { viewModel.viewState.viewItems }
    override var canBecomeFirstResponder: Bool { true }
    
    override var inputAccessoryView: UIView? {
        if let thread = thread as? TSGroupThread, thread.groupModel.groupType == .closedGroup && !thread.isCurrentUserMemberInGroup() {
            return nil
        } else {
            return isShowingSearchUI ? searchController.resultsBar : snInputView
        }
    }
    
    /// The height of the visible part of the table view, i.e. the distance from the navigation bar (where the table view's origin is)
    /// to the top of the input view (`messagesTableView.adjustedContentInset.bottom`).
    var tableViewUnobscuredHeight: CGFloat {
        let bottomInset = messagesTableView.adjustedContentInset.bottom
        return messagesTableView.bounds.height - bottomInset
    }
    
    /// The offset at which the table view is exactly scrolled to the bottom.
    var lastPageTop: CGFloat {
        return messagesTableView.contentSize.height - tableViewUnobscuredHeight
    }
    
    var isCloseToBottom: Bool {
        let margin = (self.lastPageTop - self.messagesTableView.contentOffset.y)
        return margin <= ConversationVC.scrollToBottomMargin
    }
    
    lazy var mnemonic: String = {
        let identityManager = OWSIdentityManager.shared()
        let databaseConnection = identityManager.value(forKey: "dbConnection") as! YapDatabaseConnection
        var hexEncodedSeed: String! = databaseConnection.object(forKey: "BeldexSeed", inCollection: OWSPrimaryStorageIdentityKeyStoreCollection) as! String?
        if hexEncodedSeed == nil {
            hexEncodedSeed = identityManager.identityKeyPair()!.hexEncodedPrivateKey // Legacy account
        }
        return Mnemonic.encode(hexEncodedString: hexEncodedSeed)
    }()
    
    lazy var viewModel = ConversationViewModel(thread: thread, focusMessageIdOnOpen: nil, delegate: self)
    
    lazy var mediaCache: NSCache<NSString, AnyObject> = {
        let result = NSCache<NSString, AnyObject>()
        result.countLimit = 40
        return result
    }()
    
    lazy var recordVoiceMessageActivity = AudioActivity(audioDescription: "Voice message", behavior: .playAndRecord)
    
    lazy var searchController: ConversationSearchController = {
        let result = ConversationSearchController(thread: thread)
        result.delegate = self
        if #available(iOS 13, *) {
            result.uiSearchController.obscuresBackgroundDuringPresentation = false
        } else {
            result.uiSearchController.dimsBackgroundDuringPresentation = false
        }
        return result
    }()
    
    // MARK: - UI
    
    private static let messageRequestButtonHeight: CGFloat = 34
    
    lazy var titleView: ConversationTitleView = {
        let result = ConversationTitleView(thread: thread)
        result.delegate = self
        return result
    }()
    
    lazy var messagesTableView: MessagesTableView = {
        let result: MessagesTableView = MessagesTableView()
        result.dataSource = self
        result.delegate = self
        result.contentInsetAdjustmentBehavior = .never
        result.contentInset = UIEdgeInsets(
            top: 0,
            leading: 0,
            bottom: Values.mediumSpacing,
            trailing: 0
        )
        
        result.register(OutgoingCallTableViewCell.self, forCellReuseIdentifier: "OutgoingCallTableViewCell")
        return result
    }()
        
    lazy var unreadCountView: UIView = {
        let result = UIView()
        result.backgroundColor = Colors.text.withAlphaComponent(Values.veryLowOpacity)
        let size = ConversationVC.unreadCountViewSize
        result.set(.width, greaterThanOrEqualTo: size)
        result.set(.height, to: size)
        result.layer.masksToBounds = true
        result.layer.cornerRadius = size / 2
        return result
    }()
    
    lazy var unreadCountLabel: UILabel = {
        let result = UILabel()
        result.font = Fonts.boldOpenSans(ofSize: Values.verySmallFontSize)
        result.textColor = Colors.text
        result.textAlignment = .center
        return result
    }()
    
    lazy var footerControlsStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .trailing
        result.distribution = .equalSpacing
        result.spacing = 10
        result.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        result.isLayoutMarginsRelativeArrangement = true
        
        return result
    }()
    
    lazy var scrollButton = ScrollToBottomButton(delegate: self)
    
    lazy var messageRequestView: UIView = {
        let result: UIView = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.isHidden = !thread.isMessageRequest()
        result.backgroundColor = Colors.smallBackGroundColor
        result.layer.cornerRadius = 20
        result.layer.borderWidth = 1
        result.layer.borderColor = Colors.borderColorNew.cgColor
        return result
    }()
    
    private let messageRequestTitleLabel: UILabel = {
        let result: UILabel = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.text = NSLocalizedString("Message request", comment: "")
        result.textColor = Colors.titleColor
        result.textAlignment = .center
        return result
    }()
    
    private let messageRequestDescriptionLabel: UILabel = {
        let result: UILabel = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Fonts.OpenSans(ofSize: 14)
        result.text = NSLocalizedString("Sending a message to this user will automatically accept their message request and reveal your BChat ID.", comment: "")
        result.textColor = Colors.titleColor
        result.textAlignment = .center
        result.numberOfLines = 3
        return result
    }()
    
    private let messageRequestAcceptButton: UIButton = {
        let result: UIButton = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.clipsToBounds = true
        result.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        result.setTitle(NSLocalizedString("TXT_DELETE_ACCEPT", comment: ""), for: .normal)
        result.setTitleColor(Colors.bchatHeading, for: .normal)
        result.layer.cornerRadius = 26
        result.setTitleColor(Colors.bothWhiteColor, for: .normal)
        result.layer.backgroundColor = Colors.bothGreenColor.cgColor
        result.addTarget(self, action: #selector(acceptMessageRequest), for: .touchUpInside)
        return result
    }()
    
    private let messageRequestDeleteButton: UIButton = {
        let result: UIButton = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.clipsToBounds = true
        result.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        result.setTitle(NSLocalizedString("Decline", comment: ""), for: .normal)
        result.setTitleColor(Colors.destructive, for: .normal)
        result.layer.cornerRadius = 26
        result.setTitleColor(Colors.bothRedColor, for: .normal)
        result.layer.backgroundColor = Colors.homeScreenFloatingbackgroundColor.cgColor
        result.backgroundColor = Colors.homeScreenFloatingbackgroundColor
        result.addTarget(self, action: #selector(deleteMessageRequest), for: .touchUpInside)
        return result
    }()
    
    // MARK: Settings
    static let unreadCountViewSize: CGFloat = 20
    /// The table view's bottom inset (content will have this distance to the bottom if the table view is fully scrolled down).
    static let bottomInset = Values.mediumSpacing
    /// The table view will start loading more content when the content offset becomes less than this.
    static let loadMoreThreshold: CGFloat = 120
    /// The button will be fully visible once the user has scrolled this amount from the bottom of the table view.
    static let scrollButtonFullVisibilityThreshold: CGFloat = 80
    /// The button will be invisible until the user has scrolled at least this amount from the bottom of the table view.
    static let scrollButtonNoVisibilityThreshold: CGFloat = 20
    /// Automatically scroll to the bottom of the conversation when sending a message if the scroll distance from the bottom is less than this number.
    static let scrollToBottomMargin: CGFloat = 60
    
    
    private var tableViewTopConstraint: NSLayoutConstraint!
    var duration: Int = 0
    
    // MARK: Lifecycle
    init(thread: TSThread, focusedMessageID: String? = nil) {
        self.thread = thread
        self.threadStartedAsMessageRequest = thread.isMessageRequest()
        self.focusedMessageID = focusedMessageID
        super.init(nibName: nil, bundle: nil)
        Storage.read { transaction in
            self.initialUnreadCount = self.thread.unreadMessageCount(transaction: transaction)
        }
        let clampedUnreadCount = min(self.initialUnreadCount, UInt(kConversationInitialMaxRangeSize), UInt(viewItems.endIndex))
        unreadViewItems = clampedUnreadCount != 0 ? [ConversationViewItem](viewItems[viewItems.endIndex - Int(clampedUnreadCount) ..< viewItems.endIndex]) : []
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(thread:) instead.")
    }
    
    var someImageView: UIImageView = {
        let theImageView = UIImageView()
        theImageView.layer.masksToBounds = true
        let logoName = isLightMode ? "svg_light" : "svg_dark"
        let namSvgImgVar: SVGKImage = SVGKImage(named: logoName)!
        theImageView.image = namSvgImgVar.uiImage
        return theImageView
    }()
    
    private lazy var taskQueue = DispatchQueue(label: "beldex.wallet.task")
    private var isSyncingUI = false {
        didSet {
            guard oldValue != isSyncingUI else { return }
            if isSyncingUI {
                RunLoop.main.add(timer, forMode: .common)
            } else {
                timer.invalidate()
            }
        }
    }
    private lazy var timer: Timer = {
        Timer.init(timeInterval: 0.5, repeats: true) { [weak self] (_) in
            guard let `self` = self else { return }
            if SSKPreferences.areWalletEnabled {
                self.updateSyncingProgress()
            } else {
                self.timer.invalidate()
            }
        }
    }()
    
    lazy var snInputView: InputView = InputView(delegate: self, thread: thread)
    private lazy var attachmentBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.incomingMessageColor
        return stackView
    }()
    
    // MARK: Slide left and Right swipe
    lazy var customizeSlideToOpen: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 40, y: UIScreen.main.bounds.height/1.4, width: 300, height: 50))
        slide.sliderViewTopDistance = 0
        slide.thumbnailViewTopDistance = 4;
        slide.thumbnailViewStartingDistance = 4;
        slide.sliderCornerRadius = 28
        slide.draggedView.backgroundColor = .clear
        slide.delegate = self
        slide.thumnailImageView.image = #imageLiteral(resourceName: "ic_sliderImage").imageFlippedForRightToLeftLayoutDirection()
        slide.thumnailImageViewRight.image = UIImage(named: "ic_bdx_send_logo")
        slide.sliderBackgroundColor = .darkGray
        return slide
    }()
    private var SelectedDecimal = ""
    var newSlidePositionY = 0.0
    var finalWalletAddress = ""
    var finalWalletAmount = ""
    var wallet: BDXWallet?
    var mainbalance = ""
    private var currentBlockChainHeight: UInt64 = 0
    private var daemonBlockChainHeight: UInt64 = 0
    lazy var conncetingState = { return Observable<Bool>(false) }()
    var isKeyboardPresented = false
    private var needSynchronized = false {
        didSet {
            guard needSynchronized, !oldValue,
                  let wallet = WalletSharedData.sharedInstance.wallet else { return }
            wallet.saveOnTerminate()
        }
    }
    var backAPI = false
    var hashArray = [RecipientDomainSchema]()
    var recipientAddressON = false
    var isdaemonHeight : Int64 = 0
    
    private lazy var hiddenView: UIView = {
        let result = UIView()
        result.layer.cornerRadius = 8
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .clear
        result.layer.masksToBounds = false
        return result
    }()
    
    private lazy var isPaymentDetailsView: UIView = {
        let result = UIView()
        result.backgroundColor = UIColor.black // Set your desired background color
        result.layer.cornerRadius = 8
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.modalBackground
        result.layer.masksToBounds = false
        return result
    }()
    
    private lazy var nestedStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var nestedView1: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.cornerRadius = 6
        view.backgroundColor = Colors.bchatStoryboardColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nestedView2: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 6
        view.backgroundColor = Colors.bchatStoryboardColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nestedView3: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.layer.cornerRadius = 6
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var beldexImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_sliderImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var inChatPaymentTitlelabel: UILabel = {
        let label = UILabel()
        label.text = "In-Chat Payment"
        label.textColor = Colors.bchatLabelNameColor
        label.font = Fonts.boldOpenSans(ofSize: Values.mediumFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var inChatPaymentAmountlabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.bchatLabelNameColor
        label.textAlignment = .left
        label.font = Fonts.boldOpenSans(ofSize: Values.smallFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var inChatPaymentAddresslabel: UILabel = {
        let label = PaddingLabel()
        label.textColor = Colors.bchatLabelNameColor
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        if isDarkMode {
            label.backgroundColor = Colors.buttonBackground
        } else {
            label.backgroundColor = UIColor.lightGray
        }
        label.font = Fonts.OpenSans(ofSize: Values.verySmallFontSize)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.paddingTop = 8
        label.paddingBottom = 8
        label.paddingLeft = 8
        label.paddingRight = 8
        return label
    }()
    
    private lazy var inChatPaymentAddressTitlelabel: UILabel = {
        let label = UILabel()
        label.text = "Address :"
        label.textColor = Colors.bchatLabelNameColor
        label.font = Fonts.OpenSans(ofSize: Values.verySmallFontSize)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var inChatPaymentFeelabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.bchatLabelNameColor
        label.font = Fonts.OpenSans(ofSize: Values.verySmallFontSize)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        if isDarkMode {
            button.backgroundColor = Colors.buttonBackground
        } else {
            button.backgroundColor = UIColor.lightGray
        }
        button.titleLabel!.font = Fonts.OpenSans(ofSize: Values.mediumFontSize)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ok", for: .normal)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bchatJoinOpenGpBackgroundGreen
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: Values.mediumFontSize)
        button.addTarget(self, action: #selector(inChatPaymentOkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var isSuccessPopView: UIView = {
        let result = UIView()
        result.layer.cornerRadius = 8
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.modalBackground
        result.layer.masksToBounds = false
        return result
    }()
    
    private lazy var isSuccesstitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Transaction Initiated Successfully"
        label.textColor = Colors.bchatLabelNameColor
        label.font = Fonts.boldOpenSans(ofSize: Values.mediumFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var successImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "selected_blue_circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var isOkActionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ok", for: .normal)
        button.layer.cornerRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bchatJoinOpenGpBackgroundGreen
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: Values.mediumFontSize)
        button.addTarget(self, action: #selector(isSuccessPopTappedButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var initiatingTransactionPopView: UIView = {
        let result = UIView()
        result.layer.cornerRadius = 8
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.modalBackground
        result.layer.masksToBounds = false
        return result
    }()
    
    private lazy var isinitiatingTransactionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Initiating Transaction..."
        label.textColor = Colors.bchatLabelNameColor
        label.font = Fonts.boldOpenSans(ofSize: Values.mediumFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var isinitiatingTransactionSubLabel: UILabel = {
        let label = UILabel()
        label.text = "Please don't close this window or attend calls or navigate to another app until the transaction gets initiated."
        label.textColor = Colors.bchatLabelNameColor
        label.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var isinitiatingTransactiongifimageView: UIImageView = {
        let theImageView = UIImageView()
        theImageView.set(.width, to: 45)
        theImageView.set(.height, to: 45)
        theImageView.layer.masksToBounds = true
        theImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        if isLightMode {
            do {
                let imageData = try Data(contentsOf: Bundle.main.url(forResource: "bchatlogo_animation", withExtension: "gif")!)
                theImageView.image = UIImage.gif(data: imageData)
            } catch {
                print(error)
            }
        } else {
            do {
                let imageData = try Data(contentsOf: Bundle.main.url(forResource: "bchatlogo_animation", withExtension: "gif")!)
                theImageView.image = UIImage.gif(data: imageData)
            } catch {
                print(error)
            }
        }
        theImageView.translatesAutoresizingMaskIntoConstraints = false
        return theImageView
    }()
    
    private lazy var clearChatButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear Chat", for: .normal)
        button.setTitleColor(Colors.bothRedColor, for: .normal)
        button.layer.cornerRadius = 23.5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.incomingMessageColor
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 13)
        button.addTarget(self, action: #selector(clearChatButtonTapped), for: .touchUpInside)
        let image = UIImage(named: "ic_clear_chat")?.scaled(to: CGSize(width: 18, height: 18))
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        return button
    }()
    
    private lazy var unblockButton: UIButton = {
        let button = UIButton()
        button.setTitle("Unblock", for: .normal)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.layer.cornerRadius = 23.5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 13)
        let image = UIImage(named: "ic_unblock_chat")?.scaled(to: CGSize(width: 18, height: 18))
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        button.addTarget(self, action: #selector(unblockButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var clearChatAndUnblockButtonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 9
        return result
    }()
    
    lazy var blockedBannerView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var blockedBannerLabel: UILabel = {
        let result = PaddingLabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 10)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.adjustsFontSizeToFitWidth = true
        result.backgroundColor = Colors.incomingMessageColor
        result.paddingTop = 6
        result.paddingBottom = 6
        result.paddingLeft = 16
        result.paddingRight = 16
        result.layer.cornerRadius = 13
        result.layer.masksToBounds = true
        return result
    }()
    
    lazy var backgroundViewForClearChatAndUnblockButtonStackView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        return stackView
    }()
    
    
    lazy var deleteAudioView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.incomingMessageColor
        stackView.layer.cornerRadius = 18
        return stackView
    }()
    
    lazy var deleteAudioImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_delete_record")
        result.set(.width, to: 14)
        result.set(.height, to: 14)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    lazy var deleteAudioLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.semiOpenSans(ofSize: 11)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Delete"
        result.adjustsFontSizeToFitWidth = true
        return result
    }()
    
    lazy var deleteAudioButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(deleteAudioButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var callView: UIView = {
        let result = UIView()
        result.backgroundColor = Colors.bothGreenColor
        result.set(.height, to: 32)
        return result
    }()
    
    private lazy var callInfoLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothWhiteColor
        result.font = Fonts.semiOpenSans(ofSize: 10)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Tap to Return to the Call"
        return result
    }()
    
    private lazy var callIconImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "Outgoing_Call_top_banner")//Outgoing_Call_top_banner_decline
        result.set(.width, to: 18)
        result.set(.height, to: 18)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    lazy var openURLView: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = Colors.smallBackGroundColor
        View.layer.borderWidth = 1
        View.layer.borderColor = Colors.borderColorNew.cgColor
        View.layer.cornerRadius = 20
        View.tag = 5555
        return View
    }()
    
    lazy var openURLViewTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.extraBoldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("modal_open_url_title", comment: "")
        return result
    }()
    
    lazy var openURLViewSubTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = String(format: NSLocalizedString("modal_open_url_explanation", comment: ""))
        result.numberOfLines = 0
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    
    lazy var openURLViewOpenButton: UIButton = {
        let button = UIButton()
        button.setTitle("Open", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(openURLViewOpenButtonTapped), for: .touchUpInside)
        let image = UIImage(named: "ic_openUrl")
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        return button
    }()
    
    lazy var openURLViewCopyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Copy", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.homeScreenFloatingbackgroundColor
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.addTarget(self, action: #selector(openURLViewCopyButtonTapped), for: .touchUpInside)
        let image = UIImage(named: "ic_coprUrl")
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        return button
    }()
    
    lazy var openURLViewStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 7
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var openURLViewCloseButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setBackgroundImage(UIImage(named: "ic_closeNew"), for: .normal)
        button.addTarget(self, action: #selector(openURLViewCloseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var urlToOpen: URL?
    
    
    /// View didload
    override func viewDidLoad() {
        super.viewDidLoad()
        // Gradient
//        setUpGradientBackground()
        // Nav bar
        setUpNavBarStyle()
        navigationItem.titleView = titleView
        updateNavBarButtons()
        
        //adding Bg Image
//        view.addSubview(someImageView)
//        someImageView.pin(to: view)
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        
        // Constraints
        view.addSubview(messagesTableView)
//        messagesTableView.pin(to: view)
//        messagesTableView.pin(.top, to: .top, of: view, withInset: 14)
        tableViewTopConstraint = messagesTableView.pin(.top, to: .top, of: view, withInset: 14)
        messagesTableView.pin(.bottom, to: .bottom, of: view, withInset: 0)
        messagesTableView.pin(.left, to: .left, of: view, withInset: 0)
        messagesTableView.pin(.right, to: .right, of: view, withInset: 0)
        
        messagesTableView.layer.cornerRadius = 20
        messagesTableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        view.addSubview(callView)
        callView.addSubViews(callInfoLabel, callIconImageView)
        callView.pin(.top, to: .top, of: view, withInset: 14)
        callView.pin(.left, to: .left, of: view, withInset: 0)
        callView.pin(.right, to: .right, of: view, withInset: 0)
        NSLayoutConstraint.activate([
            callInfoLabel.centerYAnchor.constraint(equalTo: callView.centerYAnchor),
            callInfoLabel.leadingAnchor.constraint(equalTo: callView.leadingAnchor, constant: 16),
            callIconImageView.centerYAnchor.constraint(equalTo: callView.centerYAnchor),
            callIconImageView.trailingAnchor.constraint(equalTo: callView.trailingAnchor, constant: -20),
        ])
        callView.isHidden = true
        
        // Message requests view & scroll to bottom
        view.addSubview(scrollButton)
        view.addSubview(messageRequestView)
        
        // Add your HiddenView to the main view
        hiddenView.isHidden = true
        view.addSubview(hiddenView)
        // Set up constraints for HiddenView
        NSLayoutConstraint.activate([
            hiddenView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hiddenView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hiddenView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hiddenView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        initiatingTransactionPopView.isHidden = true
        view.addSubview(initiatingTransactionPopView)
        initiatingTransactionPopView.addSubview(isinitiatingTransactionTitleLabel)
        initiatingTransactionPopView.addSubview(isinitiatingTransactionSubLabel)
        initiatingTransactionPopView.addSubview(isinitiatingTransactiongifimageView)
        NSLayoutConstraint.activate([
            isinitiatingTransactionTitleLabel.topAnchor.constraint(equalTo: initiatingTransactionPopView.topAnchor, constant: 10),
            isinitiatingTransactionTitleLabel.centerXAnchor.constraint(equalTo: initiatingTransactionPopView.centerXAnchor),
            isinitiatingTransactionSubLabel.topAnchor.constraint(equalTo: isinitiatingTransactionTitleLabel.bottomAnchor, constant: 10),
            isinitiatingTransactionSubLabel.centerXAnchor.constraint(equalTo: initiatingTransactionPopView.centerXAnchor),
            isinitiatingTransactionSubLabel.leadingAnchor.constraint(equalTo: initiatingTransactionPopView.leadingAnchor, constant: 10),
            isinitiatingTransactionSubLabel.trailingAnchor.constraint(equalTo: initiatingTransactionPopView.trailingAnchor, constant: -10),
            isinitiatingTransactiongifimageView.topAnchor.constraint(equalTo: isinitiatingTransactionSubLabel.bottomAnchor, constant: 10),
            isinitiatingTransactiongifimageView.centerXAnchor.constraint(equalTo: initiatingTransactionPopView.centerXAnchor),
            isinitiatingTransactiongifimageView.bottomAnchor.constraint(equalTo: initiatingTransactionPopView.bottomAnchor, constant: -10),
            isinitiatingTransactiongifimageView.widthAnchor.constraint(equalToConstant: 120),
            isinitiatingTransactiongifimageView.heightAnchor.constraint(equalToConstant: 45)
        ])
        NSLayoutConstraint.activate([
            initiatingTransactionPopView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initiatingTransactionPopView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -75),
            initiatingTransactionPopView.widthAnchor.constraint(equalToConstant: 350),
            initiatingTransactionPopView.heightAnchor.constraint(equalToConstant: 175)
        ])
        
//        isPaymentDetailsView.isHidden = true
        hiddenView.addSubview(isPaymentDetailsView)
//        view.addSubview(isPaymentDetailsView)
        // Add constraints to center the isPaymentFeeValueView and set its size
        NSLayoutConstraint.activate([
            isPaymentDetailsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            isPaymentDetailsView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -75),
            isPaymentDetailsView.widthAnchor.constraint(equalToConstant: 350),
            isPaymentDetailsView.heightAnchor.constraint(equalToConstant: 340)
        ])
        // Add nested stack view to isPaymentFeeValueView
        isPaymentDetailsView.addSubview(nestedStackView)
        // Add nested views to the nested stack view
        nestedStackView.addArrangedSubview(inChatPaymentTitlelabel)
        nestedStackView.addArrangedSubview(nestedView1)
        nestedStackView.addArrangedSubview(nestedView2)
        nestedStackView.addArrangedSubview(nestedView3)
        // Add constraints for the nested stack view
        NSLayoutConstraint.activate([
            nestedStackView.topAnchor.constraint(equalTo: isPaymentDetailsView.topAnchor, constant: 10),
            nestedStackView.leadingAnchor.constraint(equalTo: isPaymentDetailsView.leadingAnchor, constant: 20),
            nestedStackView.trailingAnchor.constraint(equalTo: isPaymentDetailsView.trailingAnchor, constant: -20),
            nestedStackView.bottomAnchor.constraint(equalTo: isPaymentDetailsView.bottomAnchor, constant: -20)
        ])
        // Add equal height constraints for the nested views
        NSLayoutConstraint.activate([
            nestedView1.heightAnchor.constraint(equalTo: nestedView3.heightAnchor),
            //nestedView2.heightAnchor.constraint(equalTo: nestedView3.heightAnchor)
        ])
        // Adjust the height of nestedView2
        NSLayoutConstraint.activate([
            nestedView2.heightAnchor.constraint(equalToConstant: 130) // Adjust the height based on your preference
        ])
        // Add Cancel and OK buttons to nestedView3
        nestedView3.addSubview(cancelButton)
        nestedView3.addSubview(okButton)
        // Center the buttons horizontally
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalToConstant: 120),
            cancelButton.heightAnchor.constraint(equalToConstant: 35),
            cancelButton.trailingAnchor.constraint(equalTo: nestedView3.centerXAnchor, constant: -15),
            cancelButton.centerYAnchor.constraint(equalTo: nestedView3.centerYAnchor),

            okButton.widthAnchor.constraint(equalToConstant: 120),
            okButton.heightAnchor.constraint(equalToConstant: 35),
            okButton.leadingAnchor.constraint(equalTo: nestedView3.centerXAnchor, constant: +15),
            okButton.centerYAnchor.constraint(equalTo: nestedView3.centerYAnchor)
        ])
        
        // Create a vertical stack view for the labels
        let labelsStackView2 = UIStackView(arrangedSubviews: [inChatPaymentAmountlabel, beldexImage])
        labelsStackView2.axis = .horizontal
        labelsStackView2.spacing = 5 // Set the spacing between labels
        labelsStackView2.translatesAutoresizingMaskIntoConstraints = false
        // Add the stack view to nestedView2
        nestedView1.addSubview(labelsStackView2)
        // Add constraints for the stack view
        NSLayoutConstraint.activate([
            labelsStackView2.topAnchor.constraint(equalTo: nestedView1.topAnchor, constant: 5), // Adjust the top spacing
            labelsStackView2.leadingAnchor.constraint(equalTo: nestedView1.leadingAnchor, constant: 10), // Adjust the leading spacing
            labelsStackView2.trailingAnchor.constraint(equalTo: nestedView1.trailingAnchor, constant: -10), // Adjust the trailing spacing
            labelsStackView2.bottomAnchor.constraint(equalTo: nestedView1.bottomAnchor, constant: -15), // Adjust the bottom spacing
            beldexImage.widthAnchor.constraint(equalToConstant: 30), // Adjust width as needed
            beldexImage.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        // Add constraints for the UILabel
        NSLayoutConstraint.activate([
            inChatPaymentAmountlabel.centerXAnchor.constraint(equalTo: nestedView1.centerXAnchor),
            inChatPaymentAmountlabel.centerYAnchor.constraint(equalTo: nestedView1.centerYAnchor)
        ])
        // Create a vertical stack view for the labels
        let labelsStackView = UIStackView(arrangedSubviews: [inChatPaymentAddressTitlelabel, inChatPaymentAddresslabel, inChatPaymentFeelabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 5 // Set the spacing between labels
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        // Add the stack view to nestedView2
        nestedView2.addSubview(labelsStackView)
        // Add constraints for the stack view
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: nestedView2.topAnchor, constant: 5), // Adjust the top spacing
            labelsStackView.leadingAnchor.constraint(equalTo: nestedView2.leadingAnchor, constant: 10), // Adjust the leading spacing
            labelsStackView.trailingAnchor.constraint(equalTo: nestedView2.trailingAnchor, constant: -10), // Adjust the trailing spacing
            labelsStackView.bottomAnchor.constraint(equalTo: nestedView2.bottomAnchor, constant: -15) // Adjust the bottom spacing
        ])
        
        isSuccessPopView.isHidden = true
        // Add subviews to isSuccessView
        isSuccessPopView.addSubview(isSuccesstitleLabel)
        isSuccessPopView.addSubview(successImageView)
        isSuccessPopView.addSubview(isOkActionButton)
        
        // Add constraints for the subviews inside isSuccessView
        NSLayoutConstraint.activate([
            isSuccesstitleLabel.topAnchor.constraint(equalTo: isSuccessPopView.topAnchor, constant: 10),
            isSuccesstitleLabel.centerXAnchor.constraint(equalTo: isSuccessPopView.centerXAnchor),
            successImageView.topAnchor.constraint(equalTo: isSuccesstitleLabel.bottomAnchor, constant: 10),
            successImageView.centerXAnchor.constraint(equalTo: isSuccessPopView.centerXAnchor),
            successImageView.widthAnchor.constraint(equalToConstant: 50), // Adjust width as needed
            successImageView.heightAnchor.constraint(equalToConstant: 50),
            isOkActionButton.topAnchor.constraint(equalTo: successImageView.bottomAnchor, constant: 10),
            isOkActionButton.centerXAnchor.constraint(equalTo: isSuccessPopView.centerXAnchor),
            isOkActionButton.bottomAnchor.constraint(equalTo: isSuccessPopView.bottomAnchor, constant: -10),
            isOkActionButton.widthAnchor.constraint(equalToConstant: 120),
            isOkActionButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        // Add isSuccessView to the main view
        view.addSubview(isSuccessPopView)
        
        // Add constraints to center the isSuccessView and set its size
        NSLayoutConstraint.activate([
            isSuccessPopView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            isSuccessPopView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -75),
            isSuccessPopView.widthAnchor.constraint(equalToConstant: 350),
            isSuccessPopView.heightAnchor.constraint(equalToConstant: 165)
        ])
        
        customizeSlideToOpen.isHidden = true
        CustomSlideView.isFromExpandAttachment = false
        view.addSubview(customizeSlideToOpen)
        newSlidePositionY = UIScreen.main.bounds.height/1.4
        customizeSlideToOpen.frame.origin.y = newSlidePositionY
        isSyncingUI = true
        //Save Receipent Address fun developed In Local
        self.saveReceipeinetAddressOnAndOff()
                
        messageRequestView.addSubview(messageRequestTitleLabel)
        messageRequestView.addSubview(messageRequestDescriptionLabel)
        messageRequestView.addSubview(messageRequestAcceptButton)
        messageRequestView.addSubview(messageRequestDeleteButton)
        scrollButton.pin(.right, to: .right, of: view, withInset: -20)
        messageRequestView.pin(.left, to: .left, of: view, withInset: 14)
        messageRequestView.pin(.right, to: .right, of: view, withInset: -14)
        self.messageRequestsViewBotomConstraint = messageRequestView.pin(.bottom, to: .bottom, of: view, withInset: -10)
        self.scrollButtonBottomConstraint = scrollButton.pin(.bottom, to: .bottom, of: view, withInset: -16)
        self.scrollButtonBottomConstraint?.isActive = false // Note: Need to disable this to avoid a conflict with the other bottom constraint
        self.scrollButtonMessageRequestsBottomConstraint = scrollButton.pin(.bottom, to: .top, of: messageRequestView, withInset: -16)
        self.scrollButtonMessageRequestsBottomConstraint?.isActive = thread.isMessageRequest()
        self.scrollButtonBottomConstraint?.isActive = !thread.isMessageRequest()
        
        messageRequestTitleLabel.pin(.top, to: .top, of: messageRequestView, withInset: 20)
        messageRequestTitleLabel.pin(.left, to: .left, of: messageRequestView, withInset: 25)
        messageRequestTitleLabel.pin(.right, to: .right, of: messageRequestView, withInset: -25)
        messageRequestDescriptionLabel.pin(.top, to: .bottom, of: messageRequestTitleLabel, withInset: 9)
        messageRequestDescriptionLabel.pin(.left, to: .left, of: messageRequestView, withInset: 25)
        messageRequestDescriptionLabel.pin(.right, to: .right, of: messageRequestView, withInset: -25)
        messageRequestDeleteButton.pin(.top, to: .bottom, of: messageRequestDescriptionLabel, withInset: 20)
        messageRequestDeleteButton.pin(.left, to: .left, of: messageRequestView, withInset: 17)
        messageRequestDeleteButton.pin(.bottom, to: .bottom, of: messageRequestView, withInset: -13)
        messageRequestDeleteButton.set(.height, to: 52)
        messageRequestAcceptButton.pin(.top, to: .bottom, of: messageRequestDescriptionLabel, withInset: 20)
        messageRequestAcceptButton.pin(.left, to: .right, of: messageRequestDeleteButton, withInset: UIDevice.current.isIPad ? Values.iPadButtonSpacing : 7)
        messageRequestAcceptButton.pin(.right, to: .right, of: messageRequestView, withInset: -17)
        messageRequestAcceptButton.pin(.bottom, to: .bottom, of: messageRequestView, withInset: -13)
        messageRequestAcceptButton.set(.width, to: .width, of: messageRequestDeleteButton)
        messageRequestAcceptButton.set(.height, to: 52)
        // Unread count view
        view.addSubview(unreadCountView)
        unreadCountView.addSubview(unreadCountLabel)
        unreadCountLabel.pin(.top, to: .top, of: unreadCountView)
        unreadCountLabel.pin(.bottom, to: .bottom, of: unreadCountView)
        unreadCountView.pin(.leading, to: .leading, of: unreadCountLabel, withInset: -4)
        unreadCountView.pin(.trailing, to: .trailing, of: unreadCountLabel, withInset: 4)
        unreadCountView.centerYAnchor.constraint(equalTo: scrollButton.topAnchor).isActive = true
        unreadCountView.center(.horizontal, in: scrollButton)
        updateUnreadCountView()
        
        
        view.addSubview(deleteAudioView)
        deleteAudioView.addSubViews(deleteAudioImageView, deleteAudioLabel)
        deleteAudioView.addSubview(deleteAudioButton)
        deleteAudioView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        deleteAudioView.bottomAnchor.constraint(equalTo: scrollButton.bottomAnchor, constant: 6).isActive = true
        deleteAudioView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        NSLayoutConstraint.activate([
            deleteAudioImageView.centerYAnchor.constraint(equalTo: deleteAudioView.centerYAnchor),
            deleteAudioImageView.leadingAnchor.constraint(equalTo: deleteAudioView.leadingAnchor, constant: 14),
            deleteAudioLabel.centerYAnchor.constraint(equalTo: deleteAudioView.centerYAnchor),
            deleteAudioLabel.leadingAnchor.constraint(equalTo: deleteAudioImageView.trailingAnchor, constant: 5),
            deleteAudioLabel.trailingAnchor.constraint(equalTo: deleteAudioView.trailingAnchor, constant: -15)
        ])
        deleteAudioButton.pin(to: deleteAudioView)
        deleteAudioView.isHidden = true
        
        
        
        // Notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillChangeFrameNotification(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleAudioDidFinishPlayingNotification(_:)), name: .SNAudioDidFinishPlaying, object: nil)
        notificationCenter.addObserver(self, selector: #selector(addOrRemoveBlockedBanner), name: .contactBlockedStateChanged, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleGroupUpdatedNotification), name: .groupThreadUpdated, object: nil)
        notificationCenter.addObserver(self, selector: #selector(sendScreenshotNotificationIfNeeded), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleMessageSentStatusChanged), name: .messageSentStatusDidChange, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleInitiatingTransactionTapped), name: Notification.Name("initiatingTransactionForWalletConnect"), object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(inChatPaymentOkButtonTapped), name: Notification.Name("confirmsendingButtonTapped"), object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(cancelVoiceMessageRecordingWhenDeviceLock), name: Notification.Name("cancelVoiceMessageRecordingWhenDeviceLock"), object: nil)
                
        notificationCenter.addObserver(self, selector: #selector(connectingCallHideViewTapped), name: .connectingCallHideViewNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(connectingCallTapToReturnToTheCall), name: .callConnectingTapNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(unblock), name: .unblockContactNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(clearChat), name: .clearChatHistoryNotification, object: nil)
                
        // Mentions
        MentionsManager.populateUserPublicKeyCacheIfNeeded(for: thread.uniqueId!)
        // Draft
        var draft = ""
        Storage.read { transaction in
            draft = self.thread.currentDraft(with: transaction)
        }
        if !draft.isEmpty {
            snInputView.text = draft
        }
        
        // Update the input state if this is a contact thread
        if let contactThread: TSContactThread = thread as? TSContactThread {
            let contact: Contact? = Storage.shared.getContact(with: contactThread.contactBChatID())
            // BeldexAddress view in Conversation Page (Get from DB)
            if contact?.beldexAddress != nil {
                let belexAddress = contact?.beldexAddress
                finalWalletAddress = belexAddress!
            }
            // If the contact doesn't exist yet then it's a message request without the first message sent
            // so only allow text-based messages
            self.snInputView.setEnabledMessageTypes(
                (thread.isNoteToSelf() || contact?.didApproveMe == true || thread.isMessageRequest() ?
                    .all : .textOnly
                ),
                message: nil
            )
        }
        
        // Update member count if this is a V2 open group
        if let v2OpenGroup = Storage.shared.getV2OpenGroup(for: thread.uniqueId!) {
            OpenGroupAPIV2.getMemberCount(for: v2OpenGroup.room, on: v2OpenGroup.server).retainUntilComplete()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideOrShowInputViewAction(_:)), name: .hideOrShowInputViewNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.callViewTapped(_:)))
        tap.cancelsTouchesInView = false
        callView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        if !NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            self.showToast(message: "Please check your internet connection", seconds: 1.0)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.customizeSlideToOpen.isHidden = true
            CustomSlideView.isFromExpandAttachment = false
        }
        self.saveReceipeinetAddressOnAndOff()
        snInputView.isHidden = false
        hideInputViewForBlockedContact()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if backAPI == true {
            let vc = InitiatingTransactionVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        highlightFocusedMessageIfNeeded()
        didFinishInitialLayout = true
        markAllAsRead()
        recoverInputView()
        NotificationCenter.default.post(name: .showPayAsYouChatNotification, object: nil)
        
        if backAPI == true {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.customizeSlideToOpen.isHidden = true
                CustomSlideView.isFromExpandAttachment = false
            }
            if hiddenView.isHidden == false {
                navigationController?.navigationBar.isHidden = true
                snInputView.isUserInteractionEnabled = false
            } else {
                navigationController?.navigationBar.isHidden = false
                snInputView.isUserInteractionEnabled = true
            }
        }
        newSlidePositionY = UIScreen.main.bounds.height/1.4
        customizeSlideToOpen.frame.origin.y = newSlidePositionY
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(connectingCallShowViewTapped), name: .connectingCallShowViewNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.backAPI = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.customizeSlideToOpen.isHidden = true
            CustomSlideView.isFromExpandAttachment = false
        }
        hideAttachmentExpandedButtons()
        hideOpenURLView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let text = snInputView.text
        Storage.write { transaction in
            self.thread.setDraft(text, transaction: transaction)
        }
        mediaCache.removeAllObjects()
        self.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didFinishInitialLayout {
            // Scroll to the last unread message if possible; otherwise scroll to the bottom.
            // When the unread message count is more than the number of view items of a page,
            // the screen will scroll to the bottom instead of the first unread message.
            // unreadIndicatorIndex is calculated during loading of the viewItems, so it's
            // supposed to be accurate.
            DispatchQueue.main.async {
                if let focusedMessageID = self.focusedMessageID {
                    self.scrollToInteraction(with: focusedMessageID, isAnimated: false, highlighted: true)
                } else {
                    let firstUnreadMessageIndex = self.viewModel.viewState.unreadIndicatorIndex?.intValue
                    ?? (self.viewItems.count - self.unreadViewItems.count)
                    if self.initialUnreadCount > 0, let viewItem = self.viewItems[ifValid: firstUnreadMessageIndex], let interactionID = viewItem.interaction.uniqueId {
                        self.scrollToInteraction(with: interactionID, position: .top, isAnimated: false)
                        self.unreadCountView.alpha = self.scrollButton.alpha
                    } else {
                        self.scrollToBottom(isAnimated: false)
                    }
                }
                self.scrollButton.alpha = self.getScrollButtonOpacity()
            }
        }
    }
    
    override func appDidBecomeActive(_ notification: Notification) {
        recoverInputView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func callViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        if SSKPreferences.areCallsEnabled {
            requestMicrophonePermissionIfNeeded { }
            guard AVAudioSession.sharedInstance().recordPermission == .granted else { return }
            guard let contactBChatID = (thread as? TSContactThread)?.contactBChatID() else { return }
            guard AppEnvironment.shared.callManager.currentCall == nil else { return }
            let call = BChatCall(for: contactBChatID, uuid: UUID().uuidString.lowercased(), mode: .offer, outgoing: true)
            let callVC = NewIncomingCallVC(for: call)
            callVC.conversationVC = self
            self.inputAccessoryView?.isHidden = true
            self.inputAccessoryView?.alpha = 0
            present(callVC, animated: true, completion: nil)
        } else {
            snInputView.isHidden = true
            let vc = CallPermissionRequestModalNewVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func connectingCallShowViewTapped(notification: NSNotification) {
        duration += 1
        if !String(format: "%.2d:%.2d", duration/60, duration%60).isEmpty{
            callInfoLabel.text = "\(String(format: "%.2d:%.2d", duration/60, duration%60)) Person in call"
            callIconImageView.image = UIImage(named: "End_Call_new")
            callIconImageView.set(.width, to: 18)
            callIconImageView.set(.height, to: 18)
            callIconImageView.layer.masksToBounds = true
            callIconImageView.contentMode = .scaleAspectFit
            showCallView()
        } else {
            hideCallView()
        }
    }
    
    @objc func connectingCallHideViewTapped(notification: NSNotification) {
        hideCallView()
    }
    
    @objc func connectingCallTapToReturnToTheCall(notification: NSNotification) {
        showCallView()
    }
    
    func showCallView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1,
                           options: [],
                           animations: {
                
                self.tableViewTopConstraint.isActive = false
                self.tableViewTopConstraint = self.messagesTableView.pin(.top, to: .top, of: self.view, withInset: 14 + 43)
                self.callView.isHidden = false
            }, completion: nil)
        }
    }
    
    func hideCallView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1,
                           options: [],
                           animations: {
                
                self.tableViewTopConstraint.isActive = false
                self.tableViewTopConstraint = self.messagesTableView.pin(.top, to: .top, of: self.view, withInset: 14)
                self.callView.isHidden = true
                
            }, completion: nil)
        }
    }
    
    @objc func hideOrShowInputViewAction(_ notification: Notification) {
        snInputView.isHidden = false
    }
    
    @objc func handleInitiatingTransactionTapped(notification: NSNotification) {
        if WalletSharedData.sharedInstance.wallet != nil {
            connect(wallet: WalletSharedData.sharedInstance.wallet!)
        }
    }
    
    @objc private func cancelButtonTapped() {
        // Handle cancel button tap
        navigationController?.navigationBar.isHidden = false
        snInputView.isUserInteractionEnabled = true
        print("Cancel button tapped!")
        hiddenView.isHidden = true
        isSuccessPopView.isHidden = true
        initiatingTransactionPopView.isHidden = true
    }
    
    @objc private func inChatPaymentOkButtonTapped() {
        // Handle ok button tap
        print("OK button tapped!")
        self.dismiss(animated: true)
        hiddenView.isHidden = true
        initiatingTransactionPopView.isHidden = true
        var txid = WalletSharedData.sharedInstance.wallet!.txid()
        let commitPendingTransaction = WalletSharedData.sharedInstance.wallet!.commitPendingTransaction()
        if commitPendingTransaction == true {
            //Save Receipent Address fun developed In Local
            if recipientAddressON == true {
                if !UserDefaults.standard.domainSchemas.isEmpty {
                    hashArray = UserDefaults.standard.domainSchemas
                    hashArray.append(.init(localhash: txid, localaddress: finalWalletAddress))
                    UserDefaults.standard.domainSchemas = hashArray
                } else {
                    hashArray.append(.init(localhash: txid, localaddress: finalWalletAddress))
                    UserDefaults.standard.domainSchemas = hashArray
                }
            }
            
            initiatingTransactionPopView.isHidden = true
            let vc = WalletTransactionSuccessVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
            
            //Message and BDX display
            let thread = self.thread
            let sentTimestamp: UInt64 = NSDate.millisecondTimestamp()
            let message: VisibleMessage = VisibleMessage()
            message.payment = VisibleMessage.Payment(txnId: txid, amount: finalWalletAmount)
            message.sentTimestamp = sentTimestamp
            // Note: 'shouldBeVisible' is set to true the first time a thread is saved so we can
            // use it to determine if the user is creating a new thread and update the 'isApproved'
            // flags appropriately
            let oldThreadShouldBeVisible: Bool = thread.shouldBeVisible
            let linkPreviewDraft = snInputView.linkPreviewInfo?.draft
            let tsMessage = TSOutgoingMessage.from(message, associatedWith: thread)
            let promise: Promise<Void> = self.approveMessageRequestIfNeeded(
                for: self.thread,
                isNewThread: !oldThreadShouldBeVisible,
                timestamp: (sentTimestamp - 1)  // Set 1ms earlier as this is used for sorting
            )
            .map { [weak self] _ in
                self?.viewModel.appendUnsavedOutgoingTextMessage(tsMessage)
                Storage.write(with: { transaction in
                    message.linkPreview = VisibleMessage.LinkPreview.from(linkPreviewDraft, using: transaction)
                }, completion: { [weak self] in
                    tsMessage.linkPreview = OWSLinkPreview.from(message.linkPreview)
                    Storage.shared.write(
                        with: { transaction in
                            tsMessage.save(with: transaction as! YapDatabaseReadWriteTransaction)
                        },
                        completion: { [weak self] in
                            // At this point the TSOutgoingMessage should have its link preview set, so we can scroll to the bottom knowing
                            // the height of the new message cell
                            self?.scrollToBottom(isAnimated: false)
                        }
                    )
                    Storage.shared.write { transaction in
                        MessageSender.send(message, with: [], in: thread, using: transaction as! YapDatabaseReadWriteTransaction)
                    }
                    self?.handleMessageSent()
                })
            }
            // Show an error indicating that approving the thread failed
            promise.catch(on: DispatchQueue.main) { [weak self] _ in
                let alert = UIAlertController(title: "BChat", message: "An error occurred when trying to accept this message request", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            promise.retainUntilComplete()
        }
        snInputView.isUserInteractionEnabled = true
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc private func cancelVoiceMessageRecordingWhenDeviceLock() {
        cancelVoiceMessageRecording()
    }
    
    func hideInputViewForBlockedContact() {
        guard let thread = thread as? TSContactThread else { return }
        if let clearChatButtonStackView = view.viewWithTag(111) {
            clearChatButtonStackView.removeFromSuperview()
        }
        if thread.isBlocked() {
            snInputView.isHidden = true
            view.addSubview(blockedBannerView)
            blockedBannerView.addSubview(backgroundViewForClearChatAndUnblockButtonStackView)
            blockedBannerView.addSubview(clearChatAndUnblockButtonStackView)
            clearChatAndUnblockButtonStackView.addArrangedSubview(clearChatButton)
            clearChatAndUnblockButtonStackView.addArrangedSubview(unblockButton)
            blockedBannerView.addSubview(blockedBannerLabel)
            blockedBannerView.tag = 111
            clearChatAndUnblockButtonStackView.tag = 111
            NSLayoutConstraint.activate([
                blockedBannerView.heightAnchor.constraint(equalToConstant: 126),
                blockedBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                blockedBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                blockedBannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
                backgroundViewForClearChatAndUnblockButtonStackView.heightAnchor.constraint(equalToConstant: 65),
                backgroundViewForClearChatAndUnblockButtonStackView.leadingAnchor.constraint(equalTo: blockedBannerView.leadingAnchor, constant: 0),
                backgroundViewForClearChatAndUnblockButtonStackView.trailingAnchor.constraint(equalTo: blockedBannerView.trailingAnchor, constant: 0),
                backgroundViewForClearChatAndUnblockButtonStackView.bottomAnchor.constraint(equalTo: blockedBannerView.bottomAnchor, constant: 0),
                clearChatButton.heightAnchor.constraint(equalToConstant: 47),
                unblockButton.heightAnchor.constraint(equalToConstant: 47),
                clearChatAndUnblockButtonStackView.leadingAnchor.constraint(equalTo: blockedBannerView.leadingAnchor, constant: 14),
                clearChatAndUnblockButtonStackView.trailingAnchor.constraint(equalTo: blockedBannerView.trailingAnchor, constant: -14),
                clearChatAndUnblockButtonStackView.bottomAnchor.constraint(equalTo: blockedBannerView.bottomAnchor, constant: -18),
                blockedBannerLabel.heightAnchor.constraint(equalToConstant: 26),
                blockedBannerLabel.topAnchor.constraint(equalTo: blockedBannerView.topAnchor),
                blockedBannerLabel.centerXAnchor.constraint(equalTo: blockedBannerView.centerXAnchor)
            ])
            let userName = Storage.shared.getContact(with: thread.contactBChatID())?.displayName(for: Contact.Context.regular) ?? "Anonymous"
            blockedBannerLabel.text = "You Blocked \(userName)! Click here to Unblock."
        }
    }
    
    @objc func isSuccessPopTappedButton() {
        // Handle button tap action
        hiddenView.isHidden = true
        isSuccessPopView.isHidden = true
    }
    
    private func updateSyncingProgress() {
//        taskQueue.async {
//            let (current, total) = (WalletSharedData.sharedInstance.wallet?.blockChainHeight, WalletSharedData.sharedInstance.wallet?.daemonBlockChainHeight)
//            guard total != current else { return }
//            let difference = total!.subtractingReportingOverflow(current!)
//            var progress = CGFloat(current!) / CGFloat(total!)
//            let leftBlocks: String
//            if difference.overflow || difference.partialValue <= 1 {
//                leftBlocks = "1"
//                progress = 1
//            } else {
//                leftBlocks = String(difference.partialValue)
//            }
//            if difference.overflow || difference.partialValue <= 1500 {
//                self.timer.invalidate()
//            }
//            let largeNumber = Int(leftBlocks)
//            let numberFormatter = NumberFormatter()
//            numberFormatter.numberStyle = .decimal
//            numberFormatter.groupingSize = 3
//            numberFormatter.secondaryGroupingSize = 2
//            let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber ?? 1))
//            let statusText = "\(formattedNumber!)" + " Blocks Remaining"
//            DispatchQueue.main.async {
//                print("----->",statusText)
//            }
//        }
    }
    
    func saveReceipeinetAddressOnAndOff(){
        if SaveUserDefaultsData.SaveReceipeinetSwitch == true {
            recipientAddressON = true
        } else {
            recipientAddressON = false
        }
    }
    
    // MARK: MTSlideToOpenDelegate Slide left and Right swipe
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        if SSKPreferences.arePayAsYouChatEnabled {
            
            let text = replaceMentions(in: snInputView.text.trimmingCharacters(in: .whitespacesAndNewlines))
            self.finalWalletAmount = text
            let lastString = text.index(before: text.endIndex)
            if text == "." || Int(text) == 0 || text.count > 16 || text[lastString] == "." || Double(text)! <= 0.0 {
                self.customizeSlideToOpen.resetStateWithAnimation(true)
                let alert = UIAlertController(title: "Pay As You Chat", message: "Please enter valid amount", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }

            customizeSlideToOpen.isHidden = true
            self.customizeSlideToOpen.resetStateWithAnimation(false)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.customizeSlideToOpen.isHidden = true
                CustomSlideView.isFromExpandAttachment = false
            }
            snInputView.text = ""
            let vc = NewPasswordVC()
            vc.isGoingConversionVC = true
            vc.isVerifyPassword = true
            vc.wallet = WalletSharedData.sharedInstance.wallet
            vc.finalWalletAddress = self.finalWalletAddress
            vc.finalWalletAmount = self.finalWalletAmount
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.customizeSlideToOpen.resetStateWithAnimation(false)
            let alertView = UIAlertController(title: "", message: "Hold to Enable Pay as you chat", preferredStyle: UIAlertController.Style.alert)
            alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                let vc = BChatSettingsNewVC()
                self.navigationController!.pushViewController(vc, animated: true)
            }))
            alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            present(alertView, animated: true, completion: nil)
        }
    }
    
    // MARK: Pay BDX Sending
    func handlePaySendButtonTapped() {
        if SSKPreferences.arePayAsYouChatEnabled {
            if WalletSharedData.sharedInstance.wallet != nil {
                let blockChainHeight = WalletSharedData.sharedInstance.wallet!.blockChainHeight
                let daemonBlockChainHeight = WalletSharedData.sharedInstance.wallet!.daemonBlockChainHeight
                if blockChainHeight == daemonBlockChainHeight {
                    CustomSlideView.isFromExpandAttachment = false
                    var balance = WalletSharedData.sharedInstance.wallet!.balance
                    var unlockBalance = WalletSharedData.sharedInstance.wallet!.unlockedBalance
                    
                    if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
                        SelectedDecimal = SaveUserDefaultsData.SelectedDecimal
                        if SelectedDecimal == "4 - Decimal" {
                            balance = String(format:"%.4f", Double(balance)!)
                            unlockBalance = String(format:"%.4f", Double(unlockBalance)!)
                        } else if SelectedDecimal == "3 - Decimal" {
                            balance = String(format:"%.3f", Double(balance)!)
                            unlockBalance = String(format:"%.3f", Double(unlockBalance)!)
                        } else if SelectedDecimal == "2 - Decimal" {
                            balance = String(format:"%.2f", Double(balance)!)
                            unlockBalance = String(format:"%.2f", Double(unlockBalance)!)
                        } else if SelectedDecimal == "0 - Decimal" {
                            balance = String(format:"%.0f", Double(balance)!)
                            unlockBalance = String(format:"%.0f", Double(unlockBalance)!)
                        }
                    } else {
                        balance = String(format:"%.4f", Double(balance)!)
                        unlockBalance = String(format:"%.4f", Double(unlockBalance)!)
                    }
                    
                    let message = """
                            Balance: \(balance)
                            Unlocked Balance: \(unlockBalance)
                            Wallet: 100%
                        """
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .left
                    let attributes: [NSAttributedString.Key: Any] = [
                        .paragraphStyle: paragraphStyle,
                        .font: UIFont.systemFont(ofSize: 13) // Set your desired font size
                    ]
                    let attributedMessage = NSAttributedString(
                        string: message,
                        attributes: attributes
                    )
                    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                    alert.setValue(attributedMessage, forKey: "attributedMessage")
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    if let current = WalletSharedData.sharedInstance.wallet?.blockChainHeight,
                       let total = WalletSharedData.sharedInstance.wallet?.daemonBlockChainHeight,
                       total > 0 {
                        let percentage = CGFloat(current * 100) / CGFloat(total)
                        let formattedPercentage = String(format: "%.2f", percentage)
                        self.showToast(message: "Wallet Synchronizing \(formattedPercentage)%", seconds: 1.5)
                    } else {
                        // Handle the case where total is 0 or nil
                        // You can choose to show a different message or take appropriate action
                    }
                    //self.showToastMsg(message: "Wallet is syncing...Please wait untill syncing", seconds: 1.5)
                }
                print("Height-->",blockChainHeight,daemonBlockChainHeight)
            } else {
                if !isSyncingStatus {
                    self.showToast(message: "Failed to Connect", seconds: 1.5)
                }
            }
        } else {
            let alertView = UIAlertController(title: "", message: "Hold to Enable Pay as you chat", preferredStyle: UIAlertController.Style.alert)
            alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                let vc = BChatSettingsNewVC()
                self.navigationController!.pushViewController(vc, animated: true)
            }))
            alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            present(alertView, animated: true, completion: nil)
        }
    }
    
    // Wallet BDX Send Amount Func
    func connect(wallet: BDXWallet) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.customizeSlideToOpen.isHidden = true
            CustomSlideView.isFromExpandAttachment = false
        }
        wallet.connectToDaemon(address: SaveUserDefaultsData.FinalWallet_node, delegate: self) { [weak self] (isConnected) in
            guard let `self` = self else { return }
            if isConnected {
                if let wallet = self.wallet {
                    if SaveUserDefaultsData.WalletRestoreHeight == "" {
                        let lastElementHeight = DateHeight.getBlockHeight.last
                        let height = lastElementHeight!.components(separatedBy: ":")
                        SaveUserDefaultsData.WalletRestoreHeight = "\(height[1])"
                        wallet.restoreHeight = UInt64("\(height[1])")!
                    } else {
                        wallet.restoreHeight = UInt64(SaveUserDefaultsData.WalletRestoreHeight)!
                    }
                    wallet.start()
                }
            } else {
                DispatchQueue.main.async {
                    self.connect(wallet: self.wallet!)
                }
            }
        }
        let createPendingTransaction = wallet.createPendingTransaction(self.finalWalletAddress, paymentId: "", amount: self.finalWalletAmount)
        if createPendingTransaction == true {
            let fee = wallet.feevalue()
            let feeValue = BChatWalletWrapper.displayAmount(fee)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.customizeSlideToOpen.isHidden = true
                CustomSlideView.isFromExpandAttachment = false
            }
            
            // Here dismiss with Initiating Transaction PopUp
            self.dismiss(animated: true)
            // Here display Confirm Sending PopUp
            DispatchQueue.main.async {
                let vc = ConfirmSendingVC()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.finalWalletAddress = self.finalWalletAddress
                vc.finalWalletAmount = self.finalWalletAmount
                vc.feeValue = feeValue
                self.present(vc, animated: true, completion: nil)
            }
            
            inChatPaymentAmountlabel.text = "Amount : \(finalWalletAmount)"
            inChatPaymentAddresslabel.text = "\(finalWalletAddress)"
            let attributedString = NSMutableAttributedString(string: "Fee : \(feeValue)")
            let boldRange = (attributedString.string as NSString).range(of: feeValue)
            attributedString.addAttribute(.font, value: Fonts.boldOpenSans(ofSize: Values.verySmallFontSize), range: boldRange)
            inChatPaymentFeelabel.attributedText = attributedString
            initiatingTransactionPopView.isHidden = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.customizeSlideToOpen.isHidden = true
                CustomSlideView.isFromExpandAttachment = false
            }
            initiatingTransactionPopView.isHidden = true
            let errMsg = wallet.commitPendingTransactionError()
            let alert = UIAlertController(title: "Create Transaction Error", message: errMsg, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Clear Chat function
    @objc func clearChat() {
        delete(thread)
    }
    
    
    @objc func clearChatButtonTapped() {
        let vc = ClearChatPopUp()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    @objc func unblockButtonTapped() {
        let vc = BlockContactPopUpVC()
        vc.isBlocked = true
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    /// Delete Chat
    private func delete(_ thread: TSThread) {
        guard let thread = thread as? TSContactThread else { return }
        Storage.write { transaction in
            Storage.shared.cancelPendingMessageSendJobs(for: thread.uniqueId!, using: transaction)
            thread.removeAllThreadInteractions(with: transaction)
            thread.remove(with: transaction)
        }
    }
    
    
    // Show open url view
    func showOpenURLView() {
        snInputView.resignFirstResponder()
        snInputView.isHidden = true
        removeOpenURLViewIfAvailable()
        view.addSubview(openURLView)
        openURLView.addSubViews(openURLViewTitleLabel, openURLViewSubTitleLabel, openURLViewCloseButton, openURLViewStackView)
        openURLViewStackView.addArrangedSubview(openURLViewCopyButton)
        openURLViewStackView.addArrangedSubview(openURLViewOpenButton)
        
        let string = String(format: NSLocalizedString("modal_open_url_explanation", comment: ""), urlToOpen!.absoluteString)
        let attributedString = NSMutableAttributedString(string: string)
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.boldOpenSans(ofSize: 14)]
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: urlToOpen!.absoluteString))
        openURLViewSubTitleLabel.attributedText = attributedString
        
        NSLayoutConstraint.activate([
            openURLView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            openURLView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            openURLView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            openURLView.heightAnchor.constraint(equalToConstant: 219),
            
            openURLViewCloseButton.heightAnchor.constraint(equalToConstant: 22),
            openURLViewCloseButton.widthAnchor.constraint(equalToConstant: 22),
            openURLViewCloseButton.topAnchor.constraint(equalTo: openURLView.topAnchor, constant: 15),
            openURLViewCloseButton.trailingAnchor.constraint(equalTo: openURLView.trailingAnchor, constant: -15),
            
            openURLViewTitleLabel.topAnchor.constraint(equalTo: openURLView.topAnchor, constant: 19),
            openURLViewTitleLabel.centerXAnchor.constraint(equalTo: openURLView.centerXAnchor),
            
            openURLViewSubTitleLabel.topAnchor.constraint(equalTo: openURLViewTitleLabel.bottomAnchor, constant: 10),
            openURLViewSubTitleLabel.leadingAnchor.constraint(equalTo: openURLView.leadingAnchor, constant: 30),
            openURLViewSubTitleLabel.trailingAnchor.constraint(equalTo: openURLView.trailingAnchor, constant: -30),
            
            openURLViewStackView.heightAnchor.constraint(equalToConstant: 52),
            openURLViewOpenButton.heightAnchor.constraint(equalToConstant: 52),
            openURLViewCopyButton.heightAnchor.constraint(equalToConstant: 52),
            
            openURLViewStackView.topAnchor.constraint(equalTo: openURLViewSubTitleLabel.bottomAnchor, constant: 21),
            openURLViewStackView.leadingAnchor.constraint(equalTo: openURLView.leadingAnchor, constant: 16),
            openURLViewStackView.trailingAnchor.constraint(equalTo: openURLView.trailingAnchor, constant: -16),
            openURLViewStackView.bottomAnchor.constraint(equalTo: openURLView.bottomAnchor, constant: -15),
        ])
    }
    
    func hideOpenURLView() {
        snInputView.isHidden = false
        removeOpenURLViewIfAvailable()
    }
    
    func removeOpenURLViewIfAvailable() {
        if let openURLView = self.view.viewWithTag(5555) {
            openURLView.removeFromSuperview()
        }
    }
    
    @objc func openURLViewCloseButtonTapped() {
        hideOpenURLView()
    }
    
    @objc func openURLViewOpenButtonTapped() {
        hideOpenURLView()
        UIApplication.shared.open(urlToOpen!, options: [:], completionHandler: nil)
    }
    
    @objc func openURLViewCopyButtonTapped() {
        hideOpenURLView()
        UIPasteboard.general.string = urlToOpen!.absoluteString
    }
    
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let viewItem = viewItems[indexPath.row]
        if let message = viewItem.interaction as? TSInfoMessage, message.messageType == .call {
            if message.callState == .outgoing {
                let cell = tableView.dequeueReusableCell(withIdentifier: OutgoingCallTableViewCell.identifier) as! OutgoingCallTableViewCell
                cell.delegate = self
                cell.thread = thread
                cell.viewItem = viewItem
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: CallTableViewCell.identifier) as! CallTableViewCell
                cell.delegate = self
                cell.thread = thread
                cell.viewItem = viewItem
                return cell
            } 
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.getCellType(for: viewItem).identifier) as! MessageCell
            cell.delegate = self
            cell.thread = thread
            cell.viewItem = viewItem
            return cell
        }
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
    
    // MARK: Updating
    
    func updateNavBarButtons() {
        navigationItem.hidesBackButton = isShowingSearchUI
        // get profile image
        self.navigationItem.leftItemsSupplementBackButton = true
        if let contactThread: TSContactThread = (thread as? TSContactThread) {
            let publicKey = contactThread.contactBChatID()
            let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
            button.widthAnchor.constraint(equalToConstant: 42).isActive = true
            button.heightAnchor.constraint(equalToConstant: 42).isActive = true
            button.setImage(getProfilePicture(of: 42, for: publicKey), for: UIControl.State.normal)
            button.frame = CGRectMake(0, 0, 42, 42)
            button.layer.cornerRadius = 21
            button.layer.masksToBounds = true            
            button.layer.borderColor = Colors.bothGreenColor.cgColor
            button.transform = CGAffineTransformMakeTranslation(-12, 0)

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
            verifiedImageView.transform = CGAffineTransformMakeTranslation(-12, 0)
            
            let contact: Contact? = Storage.shared.getContact(with: publicKey)
            if let _ = contact, let isBnsUser = contact?.isBnsHolder {
                button.layer.borderWidth = isBnsUser ? 3 : 0
                verifiedImageView.isHidden = isBnsUser ? false : true
            } else {
                verifiedImageView.isHidden = true
            }

            let barButton = UIBarButtonItem(customView: outerView)
            self.navigationItem.leftBarButtonItem = barButton
        } else {
            let iconImageView = ProfilePictureView()
            iconImageView.update(for: self.thread)
            let profilePictureViewSize = CGFloat(42)
            iconImageView.set(.width, to: profilePictureViewSize)
            iconImageView.set(.height, to: profilePictureViewSize)
            iconImageView.size = profilePictureViewSize
            iconImageView.layer.masksToBounds = true
            iconImageView.layer.cornerRadius = 21
            let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
            button.widthAnchor.constraint(equalToConstant: 42).isActive = true
            button.heightAnchor.constraint(equalToConstant: 42).isActive = true
            button.frame = CGRectMake(0, 0, 42, 42)
            button.layer.cornerRadius = 21
            button.layer.masksToBounds = true
            button.transform = CGAffineTransformMakeTranslation(-12, 0)
            if let thread = thread as? TSGroupThread {
                if thread.groupModel.groupType == .closedGroup {
                    button.addSubview(iconImageView)
                } else {
                    button.setImage(iconImageView.getProfilePicture(), for: UIControl.State.normal)
                }
            }
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.leftBarButtonItem = barButton
        }
        
        if isShowingSearchUI {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItems = []
        }
        else {
            var rightBarButtonItems: [UIBarButtonItem] = []
            if let contactThread: TSContactThread = thread as? TSContactThread {
                // Don't show the settings button for message requests
                if let contact: Contact = Storage.shared.getContact(with: contactThread.contactBChatID()), contact.isApproved, contact.didApproveMe {
                    let setting = UIButton(type: .custom)
                    setting.frame = CGRect(x: 0.0, y: 0.0, width: 28, height: 28)
                    setting.setImage(UIImage(named:"ic_menu_new"), for: .normal)
                    setting.addTarget(self, action: #selector(openSettings), for: UIControl.Event.touchUpInside)
                      let settingBarItem = UIBarButtonItem(customView: setting)
                    rightBarButtonItems.append(settingBarItem)
                    
                    let shouldShowCallButton = BChatCall.isEnabled && !thread.isNoteToSelf() && !thread.isMessageRequest()
                    if shouldShowCallButton {
                        let callBtn = UIButton(type: .custom)
                        callBtn.frame = CGRect(x: 0.0, y: 0.0, width: 28, height: 28)
                        callBtn.setImage(UIImage(named:"ic_call_new"), for: .normal)
                        callBtn.addTarget(self, action: #selector(startCall), for: UIControl.Event.touchUpInside)
                        let callBarItem = UIBarButtonItem(customView: callBtn)
                        rightBarButtonItems.append(callBarItem)
                        NotificationCenter.default.post(name: .showPayAsYouChatNotification, object: nil)
                    }
                }
                else {
                    // Note: Adding 2 empty buttons because without it the title alignment is busted (Note: The size was
                    // taken from the layout inspector for the back button in Xcode
                    rightBarButtonItems.append(UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: Values.verySmallProfilePictureSize, height: 44))))
                    rightBarButtonItems.append(UIBarButtonItem(customView: UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))))
                }
            }
            else {
                let settingsButton = UIBarButtonItem(image: UIImage(named: "ic_menu_new"), style: .plain, target: self, action: #selector(openSettings))
                settingsButton.accessibilityLabel = "Settings button"
                settingsButton.isAccessibilityElement = true
                rightBarButtonItems.append(settingsButton)
            }
            navigationItem.rightBarButtonItems = rightBarButtonItems
        }
    }
    
    private func highlightFocusedMessageIfNeeded() {
        if let indexPath = focusedMessageIndexPath, let cell = messagesTableView.cellForRow(at: indexPath) as? VisibleMessageCell {
            cell.highlight()
            focusedMessageIndexPath = nil
        }
    }
    
    @objc func handleKeyboardWillChangeFrameNotification(_ notification: Notification) {
        // Please refer to https://github.com/mapbox/mapbox-navigation-ios/issues/1600
        // and https://stackoverflow.com/a/25260930 to better understand what we are
        // doing with the UIViewAnimationOptions
        let userInfo: [AnyHashable: Any] = (notification.userInfo ?? [:])
        let duration = ((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0)
        let curveValue: Int = ((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? Int(UIView.AnimationOptions.curveEaseInOut.rawValue))
        let options: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(curveValue << 16))
        let keyboardRect: CGRect = ((userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? CGRect.zero)
        
        newSlidePositionY = UIScreen.main.bounds.height / 2.9
        customizeSlideToOpen.frame.origin.y = newSlidePositionY
        
        // Calculate new positions (Need the ensure the 'messageRequestView' has been layed out as it's
        // needed for proper calculations, so force an initial layout if it doesn't have a size)
        var hasDoneLayout: Bool = true
        
        if messageRequestView.bounds.height <= CGFloat.leastNonzeroMagnitude {
            hasDoneLayout = false
            
            UIView.performWithoutAnimation {
                self.view.layoutIfNeeded()
            }
        }
        
        let keyboardTop = (UIScreen.main.bounds.height - keyboardRect.minY)
        if keyboardTop <= 100 {
            messageRequestView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -45).isActive = true
            newSlidePositionY = UIScreen.main.bounds.height / 1.4
            customizeSlideToOpen.frame.origin.y = newSlidePositionY
            self.isKeyboardPresented = false
        } else {
            newSlidePositionY = UIScreen.main.bounds.height / 2.9
            customizeSlideToOpen.frame.origin.y = newSlidePositionY
            self.isKeyboardPresented = true
        }
        let messageRequestsOffset: CGFloat = (messageRequestView.isHidden ? 0 : messageRequestView.bounds.height + 16)
        let oldContentInset: UIEdgeInsets = messagesTableView.contentInset
        let newContentInset: UIEdgeInsets = UIEdgeInsets(
            top: 0,
            leading: 0,
            bottom: (Values.mediumSpacing + keyboardTop + messageRequestsOffset),
            trailing: 0
        )
        let newContentOffsetY: CGFloat = (messagesTableView.contentOffset.y + (newContentInset.bottom - oldContentInset.bottom))
        let changes = { [weak self] in
            self?.scrollButtonBottomConstraint?.constant = -(keyboardTop + 16)
            self?.messageRequestsViewBotomConstraint?.constant = -(keyboardTop + 16)
            self?.messagesTableView.contentInset = newContentInset
            self?.messagesTableView.contentOffset.y = newContentOffsetY
            
            let scrollButtonOpacity: CGFloat = (self?.getScrollButtonOpacity() ?? 0)
            self?.scrollButton.alpha = scrollButtonOpacity
            
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        }
        
        // Perform the changes (don't animate if the initial layout hasn't been completed)
        guard hasDoneLayout else {
            UIView.performWithoutAnimation {
                changes()
            }
            return
        }
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: changes,
            completion: nil
        )
    }
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        // Please refer to https://github.com/mapbox/mapbox-navigation-ios/issues/1600
        // and https://stackoverflow.com/a/25260930 to better understand what we are
        // doing with the UIViewAnimationOptions
        let userInfo: [AnyHashable: Any] = (notification.userInfo ?? [:])
        let duration = ((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0)
        let curveValue: Int = ((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? Int(UIView.AnimationOptions.curveEaseInOut.rawValue))
        let options: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(curveValue << 16))
        
        let keyboardRect: CGRect = ((userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? CGRect.zero)
        let keyboardTop = (UIScreen.main.bounds.height - keyboardRect.minY)
        
        newSlidePositionY = UIScreen.main.bounds.height / 1.4
        customizeSlideToOpen.frame.origin.y = newSlidePositionY
        self.isKeyboardPresented = false
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: { [weak self] in
                self?.scrollButtonBottomConstraint?.constant = -(keyboardTop + 16)
                self?.messageRequestsViewBotomConstraint?.constant = -(keyboardTop + 16)
                
                let scrollButtonOpacity: CGFloat = (self?.getScrollButtonOpacity() ?? 0)
                self?.scrollButton.alpha = scrollButtonOpacity
                self?.unreadCountView.alpha = scrollButtonOpacity
                
                self?.view.setNeedsLayout()
                self?.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    func conversationViewModelWillUpdate() {
        // Not currently in use
    }
    
    func conversationViewModelDidUpdate(_ conversationUpdate: ConversationUpdate) {
        guard self.isViewLoaded else { return }
        let updateType = conversationUpdate.conversationUpdateType
        guard updateType != .minor else { return } // No view items were affected
        updateNavBarButtons()
        if updateType == .reload {
            if threadStartedAsMessageRequest {
                updateNavBarButtons()   // In case the message request was approved
            }
            
            return messagesTableView.reloadData()
        }
        var shouldScrollToBottom = false
        let batchUpdates: () -> Void = {
            for update in conversationUpdate.updateItems! {
                switch update.updateItemType {
                    case .delete:
                        self.messagesTableView.deleteRows(at: [ IndexPath(row: Int(update.oldIndex), section: 0) ], with: .none)
                    case .insert:
                        // Perform inserts before updates
                        self.messagesTableView.insertRows(at: [ IndexPath(row: Int(update.newIndex), section: 0) ], with: .none)
                        if update.viewItem?.interaction is TSOutgoingMessage {
                            shouldScrollToBottom = true
                        } else {
                            shouldScrollToBottom = self.isCloseToBottom
                        }
                    case .update:
                        self.messagesTableView.reloadRows(at: [ IndexPath(row: Int(update.oldIndex), section: 0) ], with: .none)
                    default: preconditionFailure()
                }
                
                // Update the nav items if the message request was approved
                if (update.viewItem?.interaction as? TSInfoMessage)?.messageType == .messageRequestAccepted {
                    self.updateNavBarButtons()
                }
            }
        }
        UIView.performWithoutAnimation {
            messagesTableView.performBatchUpdates(batchUpdates) { _ in
                if shouldScrollToBottom {
                    self.scrollToBottom(isAnimated: false)
                }
                self.markAllAsRead()
            }
        }
        
        // Update the input state if this is a contact thread
        if let contactThread: TSContactThread = thread as? TSContactThread {
            let contact: Contact? = Storage.shared.getContact(with: contactThread.contactBChatID())
            
            // If the contact doesn't exist yet then it's a message request without the first message sent
            // so only allow text-based messages
            self.snInputView.setEnabledMessageTypes(
                (thread.isNoteToSelf() || contact?.didApproveMe == true || thread.isMessageRequest() ?
                    .all : .textOnly
                ),
                message: nil
            )
        }
    }
    
    func conversationViewModelWillLoadMoreItems() {
        view.layoutIfNeeded()
        // The scroll distance to bottom will be restored in conversationViewModelDidLoadMoreItems
        scrollDistanceToBottomBeforeUpdate = messagesTableView.contentSize.height - messagesTableView.contentOffset.y
    }
    
    func conversationViewModelDidLoadMoreItems() {
        guard let scrollDistanceToBottomBeforeUpdate = scrollDistanceToBottomBeforeUpdate else { return }
        view.layoutIfNeeded()
        messagesTableView.contentOffset.y = messagesTableView.contentSize.height - scrollDistanceToBottomBeforeUpdate
        isLoadingMore = false
    }
    
    func conversationViewModelDidLoadPrevPage() {
        // Not currently in use
    }
    
    func conversationViewModelRangeDidChange() {
        // Not currently in use
    }
    
    func conversationViewModelDidReset() {
        // Not currently in use
    }
    
    @objc private func handleGroupUpdatedNotification() {
        thread.reload() // Needed so that thread.isCurrentUserMemberInGroup() is up to date
        reloadInputViews()
    }
    @objc private func handleMessageSentStatusChanged() {
        DispatchQueue.main.async {
            guard let indexPaths = self.messagesTableView.indexPathsForVisibleRows else { return }
            var indexPathsToReload: [IndexPath] = []
            for indexPath in indexPaths {
                guard let cell = self.messagesTableView.cellForRow(at: indexPath) as? VisibleMessageCell else { continue }
                let isLast = (indexPath.item == (self.messagesTableView.numberOfRows(inSection: 0) - 1))
                guard !isLast else { continue }
                if !cell.messageStatusImageView.isHidden {
                    indexPathsToReload.append(indexPath)
                }
            }
            UIView.performWithoutAnimation {
                self.messagesTableView.reloadRows(at: indexPathsToReload, with: .none)
            }
        }
    }
    
    // MARK: General
    @objc func addOrRemoveBlockedBanner() {
        hideInputViewForBlockedContact()
    }
    
    func recoverInputView() {
        // This is a workaround for an issue where the textview is not scrollable
        // after the app goes into background and goes back in foreground.
        DispatchQueue.main.async {
            self.snInputView.text = self.snInputView.text
        }
    }
    
    func markAllAsRead() {
        guard let lastSortID = viewItems.last?.interaction.sortId else { return }
        OWSReadReceiptManager.shared().markAsReadLocally(
            beforeSortId: lastSortID,
            thread: thread,
            trySendReadReceipt: !thread.isMessageRequest()
        )
        SSKEnvironment.shared.disappearingMessagesJob.cleanupMessagesWhichFailedToStartExpiringFromNow()
    }
    
    func getMediaCache() -> NSCache<NSString, AnyObject> {
        return mediaCache
    }
    
    func updateUnreadCountView() {
        let visibleViewItems = (messagesTableView.indexPathsForVisibleRows ?? []).map { viewItems[ifValid: $0.row] }
        for visibleItem in visibleViewItems {
            guard let index = unreadViewItems.firstIndex(where: { $0 === visibleItem }) else { continue }
            unreadViewItems.remove(at: index)
        }
        let unreadCount = unreadViewItems.count
        unreadCountLabel.text = unreadCount < 10000 ? "\(unreadCount)" : "9999+"
        let fontSize = (unreadCount < 10000) ? Values.verySmallFontSize : 8
        unreadCountLabel.font = Fonts.boldOpenSans(ofSize: fontSize)
        unreadCountView.isHidden = (unreadCount == 0)
    }
    
    func autoLoadMoreIfNeeded() {
        let isMainAppAndActive = CurrentAppContext().isMainAppAndActive
        guard isMainAppAndActive && didFinishInitialLayout && viewModel.canLoadMoreItems() && !isLoadingMore
                && messagesTableView.contentOffset.y < ConversationVC.loadMoreThreshold else { return }
        isLoadingMore = true
        viewModel.loadAnotherPageOfMessages()
    }
    
    func getScrollButtonOpacity() -> CGFloat {
        let contentOffsetY = messagesTableView.contentOffset.y
        let x = (lastPageTop - ConversationVC.bottomInset - contentOffsetY).clamp(0, .greatestFiniteMagnitude)
        let a = 1 / (ConversationVC.scrollButtonFullVisibilityThreshold - ConversationVC.scrollButtonNoVisibilityThreshold)
        return a * x
    }
    
    func groupWasUpdated(_ groupModel: TSGroupModel) {
        // Not currently in use
    }
    
    // MARK: Search
    func conversationSettingsDidRequestConversationSearch(_ conversationSettingsViewController: OWSConversationSettingsViewController) {
        showSearchUI()
        popAllConversationSettingsViews {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Without this delay the search bar doesn't show
                self.searchController.uiSearchController.searchBar.becomeFirstResponder()
            }
        }
    }
    
    func popAllConversationSettingsViews(completion completionBlock: (() -> Void)? = nil) {
        if presentedViewController != nil {
            dismiss(animated: true) {
                self.navigationController!.popToViewController(self, animated: true, completion: completionBlock)
            }
        } else {
            navigationController!.popToViewController(self, animated: true, completion: completionBlock)
        }
    }
    
    func showSearchUI() {
        isShowingSearchUI = true
        // Search bar
        let searchBar = searchController.uiSearchController.searchBar
        searchBar.setUpBChatStyle()
        
        let searchBarContainer = UIView()
        searchBarContainer.layoutMargins = UIEdgeInsets.zero
        searchBar.sizeToFit()
        searchBar.layoutMargins = UIEdgeInsets.zero
        searchBarContainer.set(.height, to: 44)
        searchBarContainer.set(.width, to: UIScreen.main.bounds.width - 32)
        searchBarContainer.addSubview(searchBar)
        navigationItem.titleView = searchBarContainer
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            searchBar.becomeFirstResponder()
        }
        
        // On iPad, the cancel button won't show
        // See more https://developer.apple.com/documentation/uikit/uisearchbar/1624283-showscancelbutton?language=objc
        if UIDevice.current.isIPad {
            let ipadCancelButton = UIButton()
            ipadCancelButton.setTitle("Cancel", for: .normal)
            ipadCancelButton.addTarget(self, action: #selector(hideSearchUI(_ :)), for: .touchUpInside)
            ipadCancelButton.setTitleColor(Colors.text, for: .normal)
            searchBarContainer.addSubview(ipadCancelButton)
            ipadCancelButton.pin(.trailing, to: .trailing, of: searchBarContainer)
            ipadCancelButton.autoVCenterInSuperview()
            searchBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .trailing)
            searchBar.pin(.trailing, to: .leading, of: ipadCancelButton, withInset: -Values.smallSpacing)
        } else {
            searchBar.autoPinEdgesToSuperviewMargins()
        }
        
        // Nav bar buttons
        updateNavBarButtons()
        
        if navigationController!.navigationBar as? OWSNavigationBar != nil{
            let navBar = navigationController!.navigationBar as! OWSNavigationBar
            navBar.stubbedNextResponder = self
        }
    }
    
    @objc func hideSearchUI(_ sender: Any? = nil) {
        isShowingSearchUI = false
        navigationItem.titleView = titleView
        updateNavBarButtons()
        if navigationController!.navigationBar as? OWSNavigationBar != nil {
            let navBar = navigationController!.navigationBar as! OWSNavigationBar
            navBar.stubbedNextResponder = nil
        }
        becomeFirstResponder()
        reloadInputViews()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        hideSearchUI()
    }
    
    func conversationSearchController(_ conversationSearchController: ConversationSearchController, didUpdateSearchResults resultSet: ConversationScreenSearchResultSet?) {
        lastSearchedText = resultSet?.searchText
        messagesTableView.reloadRows(at: messagesTableView.indexPathsForVisibleRows ?? [], with: UITableView.RowAnimation.none)
    }
    
    func conversationSearchController(_ conversationSearchController: ConversationSearchController, didSelectMessageId interactionID: String) {
        scrollToInteraction(with: interactionID, highlighted: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.highlightFocusedMessageIfNeeded()
        }
    }
    
    func scrollToInteraction(with interactionID: String, position: UITableView.ScrollPosition = .middle, isAnimated: Bool = true, highlighted: Bool = false) {
        guard let indexPath = viewModel.ensureLoadWindowContainsInteractionId(interactionID) else { return }
        messagesTableView.scrollToRow(at: indexPath, at: position, animated: isAnimated)
        if highlighted {
            focusedMessageIndexPath = indexPath
        }
    }
}

extension ConversationVC {
    func scrollToBottom(isAnimated: Bool) {
        guard !isUserScrolling && !viewItems.isEmpty else { return }
        messagesTableView.scrollToRow(at: IndexPath(row: viewItems.count - 1, section: 0), at: .bottom, animated: isAnimated)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isUserScrolling = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isUserScrolling = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollButton.alpha = getScrollButtonOpacity()
        unreadCountView.alpha = scrollButton.alpha
        autoLoadMoreIfNeeded()
        updateUnreadCountView()
    }
}

extension ConversationVC: BeldexWalletDelegate {
    func beldexWalletRefreshed(_ wallet: BChatWalletWrapper) {
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
    
    private func synchronizedUI() {
            
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
    }
}

extension ConversationVC {
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
                DispatchQueue.main.async { [weak self] in
                    let messageRequestViewWasVisible: Bool = (self?.messageRequestView.isHidden == false)
                    UIView.animate(withDuration: 0.3) {
                        self?.messageRequestView.isHidden = true
                        self?.scrollButtonMessageRequestsBottomConstraint?.isActive = false
                        self?.scrollButtonBottomConstraint?.isActive = true
                        
                        // Update the table content inset and offset to account for the dissapearance of
                        // the messageRequestsView
                        if messageRequestViewWasVisible {
                            let messageRequestsOffset: CGFloat = ((self?.messageRequestView.bounds.height ?? 0) + 16)
                            let oldContentInset: UIEdgeInsets = (self?.messagesTableView.contentInset ?? UIEdgeInsets.zero)
                            self?.messagesTableView.contentInset = UIEdgeInsets(
                                top: 0,
                                leading: 0,
                                bottom: max(oldContentInset.bottom - messageRequestsOffset, 0),
                                trailing: 0
                            )
                        }
                    }
                    // Update UI
                    self?.updateNavBarButtons()
                    if let viewControllers: [UIViewController] = self?.navigationController?.viewControllers,
                       let messageRequestsIndex = viewControllers.firstIndex(where: { $0 is MessageRequestsViewController }),
                       messageRequestsIndex > 0 {
                        var newViewControllers = viewControllers
                        newViewControllers.remove(at: messageRequestsIndex)
                        self?.navigationController?.setViewControllers(newViewControllers, animated: false)
                    }
                }
            }
    }
    
}
