// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit
import Alamofire
import BChatUIKit

class MyWalletHomeVC: UIViewController, ExpandedCellDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(WalletHomeXibCell.nib, forCellWithReuseIdentifier: WalletHomeXibCell.identifier)
        }
    }
    var rightBarButtonItems: [UIBarButtonItem] = []
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet weak var NotransationImg: UIImageView!
    @IBOutlet weak var imgBeldexlogo: UIImageView!
    @IBOutlet var notransationLabel: UILabel!
    @IBOutlet var notransationLabel2: UILabel!
    @IBOutlet var lblMainblns: UILabel!
    @IBOutlet var lblOtherCurrencyblns: UILabel!
    @IBOutlet weak var rightview: UIView!
    @IBOutlet weak var backgroundBottomView: UIView!
    @IBOutlet weak var backgroundBottomScanView: UIView!
    @IBOutlet weak var bottomview: UIView!
    @IBOutlet weak var viewSyncing: UIView!
    @IBOutlet weak var btnReconnect: UIButton!
    @IBOutlet weak var btnRescan: UIButton!
    @IBOutlet weak var btnHomeSend: UIButton!
    @IBOutlet weak var btnHomeScan: UIButton!
    @IBOutlet weak var btnHomeReceive: UIButton!
    @IBOutlet weak var incomingButton: UIButton!
    @IBOutlet weak var outgoingButton: UIButton!
    @IBOutlet weak var transactionByDateButton: UIButton!
    @IBOutlet weak var incomingImageView: UIImageView!
    @IBOutlet weak var outgoingImageView: UIImageView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var syncedIconView: UIView!
    @IBOutlet var lblsyncedRestoreHeight: UILabel!
    @IBOutlet weak var syncedIconRefbtn: UIButton!
    var iconClick = true
    var BackAPI = false
    var backAPIRescanVC = false
    var backAPISelectedCurrency = false
    var backAPISelectedDecimal = false
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var imgScanRef: UIImageView!
    @IBOutlet weak var btnBydateRef: UIButton!
    @IBOutlet weak var syncedIconRef: UIButton!
    var btnAllRef2 = false
    var btnSendRef2 = false
    var btnReceiveRef2 = false
    var btndateaction = false
    var isExpanded = [Bool]()
    var expandingArray = [TransactionItem]()
    var isCellExpanded : Bool = false
    weak var delegate:ExpandedCellDelegate?
    
    //MARK:- Wallet References
    //========================================================================================
    var nodeArray = ["explorer.beldex.io:19091","mainnet.beldex.io:29095","publicnode1.rpcnode.stream:29095","publicnode2.rpcnode.stream:29095","publicnode3.rpcnode.stream:29095","publicnode4.rpcnode.stream:29095","publicnode5.rpcnode.stream:29095"]
    var randomNodeValue = ""
    var filteredAllTransactionarray : [TransactionItem] = []
    var filteredOutgoingTransactionarray : [TransactionItem] = []
    var filteredIncomingTransactionarray : [TransactionItem] = []
    var transactionAllarray = [TransactionItem]()
    var transactionSendarray = [TransactionItem]()
    var transactionReceivearray = [TransactionItem]()
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
                RunLoop.main.add(timer, forMode: .common)
            } else {
                timer.invalidate()
            }
        }
    }
    private lazy var timer: Timer = {
        Timer.init(timeInterval: 0.5, repeats: true) { [weak self] (_) in
            guard let `self` = self else { return }
            self.updateSyncingProgress()
        }
    }()
    
    public lazy var loadingState = { Postable<Bool>() }()
    private var SelectedDecimal = ""
    private var SelectedBalance = ""
    private var currencyName = ""
    var mainbalance = ""
    private var CurrencyValue: Double!
    private var refreshDuration: TimeInterval = 60
    private var marketsDataRequest: DataRequest?
    @IBOutlet weak var viewdateRangeRef: UIView!
    @IBOutlet weak var viewFromdateRef: UIView!
    @IBOutlet weak var viewTodateRef: UIView!
    @IBOutlet weak var btndateCancel: UIButton!
    @IBOutlet weak var btndateOkey: UIButton!
    @IBOutlet weak var txtfromdate: UITextField!
    @IBOutlet weak var txttodate: UITextField!
    var fromDate : String = ""
    var toDate : String = ""
    var hashArray2 = [RecipientDomainSchema]()
    var isFilter = false
    var noTransaction = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "My Wallet"
        let tap = UITapGestureRecognizer(target: self, action: #selector (self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(MyWalletHomeVC.backHomeScreen(sender:)))
        newBackButton.image = UIImage(named: "NavBarBack")
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //depending upon direction of collection view
        self.collectionView?.setCollectionViewLayout(layout, animated: true)
        self.collectionView.showsVerticalScrollIndicator = false
        // Disable vertical scrolling
        scrollView.isScrollEnabled = false
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height)
        progressView.tintColor = Colors.bchat_button_clr
        btnHomeSend.setTitleColor(.lightGray, for: .normal)
        btnHomeScan.isUserInteractionEnabled = false
        btnHomeSend.isUserInteractionEnabled = false
        btnHomeSend.backgroundColor = Colors.bchat_storyboard_clr
        backgroundBottomScanView.backgroundColor = Colors.bchat_storyboard_clr
        
        let colorScanQR: UIColor = isDarkMode ? .lightGray : .lightGray
        imgScanRef.image = UIImage(named: "ic_Scan_QR")?.asTintedImage(color: colorScanQR)
        
        let logo_ic_no_transactions = isLightMode ? "ic_no_transactions_light" : "ic_no_transactions"
        NotransationImg.image = UIImage(named: logo_ic_no_transactions)!
        
        let colorimgBeldex: UIColor = isDarkMode ? .white : .black
        imgBeldexlogo.image = UIImage(named: "ic_beldex")?.asTintedImage(color: colorimgBeldex)
        
        let imageDatefilter = UIImage(named: "ic_Datefilter")?.asTintedImage(color: colorimgBeldex)
        btnBydateRef.setImage(imageDatefilter, for: .normal)
        
        let imageinfo = UIImage(named: "ic_info")?.asTintedImage(color: colorimgBeldex)
        syncedIconRef.setImage(imageinfo, for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(syncWalletData(_:)), name: Notification.Name(rawValue: "syncWallet"), object: nil)
        
        if BackAPI == true{
            self.SelectedBalance = SaveUserDefaultsData.SelectedBalance
            self.fetchMarketsData(false)
        }
        
        //MARK:- Wallet Ref
        init_syncing_wallet()
        
        // Selected Currency Code Implement
        if backAPISelectedCurrency == true {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            if mainbalance.isEmpty {
                let fullblnce = "0.00"
                lblOtherCurrencyblns.text = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
            }else {
                let fullblnce = Double(mainbalance)! * CurrencyValue
                lblOtherCurrencyblns.text = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
            }
        }else {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency.uppercased()
            if mainbalance.isEmpty {
                let fullblnce = "0.00"
                // Trim "-" Value in amount place "-0.00 USD"
                var str = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                let cs = CharacterSet.init(charactersIn: "-")
                str = str.trimmingCharacters(in: cs)
                lblOtherCurrencyblns.text = "\(str)"
            }else {
                if CurrencyValue != nil {
                    let fullblnce = Double(mainbalance)! * CurrencyValue
                    lblOtherCurrencyblns.text = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                }
            }
        }
        
        // randomElement node And Selected Node
        if !SaveUserDefaultsData.SelectedNode.isEmpty {
            randomNodeValue = SaveUserDefaultsData.SelectedNode
        }else {
            randomNodeValue = nodeArray.randomElement()!
        }
        SaveUserDefaultsData.FinalWallet_node = randomNodeValue
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "ic_WalletSettings")!, style: .plain, target: self, action: #selector(settingsoptn))
        rightBarButtonItems.append(settingsButton)
        
        let refreButton = UIBarButtonItem(image: UIImage(named: "ic_resync"), style: .plain, target: self, action: #selector(refreshoptn))
        refreButton.accessibilityLabel = "Settings button"
        refreButton.isAccessibilityElement = true
        rightBarButtonItems.append(refreButton)
        navigationItem.rightBarButtonItems = rightBarButtonItems
        
        //Save Receipent Address fun developed
        if UserDefaults.standard.domainSchemas.isEmpty { }else {
            hashArray2 = UserDefaults.standard.domainSchemas
        }
        
        isExpanded = Array(repeating: false, count: transactionAllarray.count)
        
        if self.transactionAllarray.count == 0 {
            self.showNoTransactionView()
        }else {
            self.hideNoTransactionView()
        }
        
        bottomview.clipsToBounds = true
        bottomview.layer.cornerRadius = 10
        bottomview.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        rightview.clipsToBounds = true
        rightview.layer.cornerRadius = 10
        rightview.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        backgroundBottomView.layer.cornerRadius = 6
        backgroundBottomScanView.layer.cornerRadius = 6
        txttodate.delegate = self
        txtfromdate.delegate = self
        
        //1st view popUp Recycle
        viewSyncing.layer.cornerRadius = 6
        btnReconnect.layer.cornerRadius = 6
        btnRescan.layer.cornerRadius = 6
        viewSyncing.isHidden = true
        
        btnHomeSend.layer.cornerRadius = 6
        btnHomeReceive.layer.cornerRadius = 6
        
        //2nd view popUp
        bottomview.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        btnAllRef2 = true
        btnSendRef2 = false
        btnReceiveRef2 = false
        self.incomingButton.isSelected = true
        self.outgoingButton.isSelected = true
        let checkBox = isLightMode ? "icCheck_box" : "ic_Check_box_white"
        incomingImageView.image = UIImage(named: checkBox)!
        outgoingImageView.image = UIImage(named: checkBox)!
        UserDefaults.standard.setValue(nil, forKey: "btnclicked")
        
        self.filterView.isHidden = true
        self.filterView.layer.cornerRadius = 6
        
        self.syncedIconView.isHidden = true
        self.syncedIconView.layer.cornerRadius = 6
        self.syncedIconRefbtn.layer.cornerRadius = 6
        
        // Date Range References
        viewdateRangeRef.isHidden = true
        bottomview.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        viewdateRangeRef.layer.cornerRadius = 8
        viewFromdateRef.layer.cornerRadius = 3
        viewTodateRef.layer.cornerRadius = 3
        viewFromdateRef.layer.borderWidth = 1
        viewTodateRef.layer.borderWidth = 1
        viewFromdateRef.layer.borderColor = Colors.bchat_button_clr.cgColor
        viewTodateRef.layer.borderColor = Colors.bchatmeassgeReq.cgColor
        
        txtfromdate.delegate = self
        txttodate.delegate = self
        txtfromdate.placeholder = "Select From Date"
        txttodate.placeholder = "Select To Date"
        
        self.txtfromdate.datePicker(target: self,
                                    doneAction: #selector(fromdoneAction),
                                    cancelAction: #selector(fromcancelAction),
                                    datePickerMode: .date)
        self.txttodate.datePicker(target: self,
                                  doneAction: #selector(todoneAction),
                                  cancelAction: #selector(tocancelAction),
                                  datePickerMode: .date)
        
        
        // UIPanGesture recognizer swiping only in one direction left side
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanForLeftswipe(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    //UIPanGesture recognizer swiping only in one direction left side
    @objc func handlePanForLeftswipe(_ gestureRecognizer: UIPanGestureRecognizer) {
        // Get the translation of the pan gesture
        let translation = gestureRecognizer.translation(in: view)
        // Calculate the progress of the swipe based on the translation
        let progress = translation.x / view.bounds.width
        switch gestureRecognizer.state {
        case .began:
            // Handle the pan gesture start, if needed
            break
        case .changed:
            // Handle the pan gesture changes, if needed
            // You can update the screen content or perform animations based on the progress.
            break
        case .ended, .cancelled:
            // Complete or cancel the interactive transition based on progress
            if progress > 0.5 {
                navigateToNextScreen()
            } else if progress < -0.5 {
                navigateToPreviousScreen()
            } else {
                // Reset the screen to its initial state as the swipe is not significant
                resetScreen()
            }
        default:
            // Handle other states, if needed
            break
        }
    }
    func navigateToNextScreen() {
        // Perform the navigation action to the next view controller
    }
    func navigateToPreviousScreen() {
        // Perform the navigation action to the previous view controller
    }
    func resetScreen() {
        // Reset the screen to its initial state
        // For example, you can cancel any ongoing animations or undo any changes made during the swipe.
        self.navigationController?.popToSpecificViewController(ofClass: HomeVC.self, animated: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            if hitView === self.filterView {
                print("touch is inside")
            } else {
                print("touch is outside")
                self.filterView.isHidden = true
                viewdateRangeRef.isUserInteractionEnabled = true
                bottomview.isUserInteractionEnabled = true
                scrollView.isUserInteractionEnabled = true
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
            }
        }
    }
    
    //Save Receipent Address fun developed
    func start(hashid:String,array:[RecipientDomainSchema])->(boolvalue:Bool,address:String){
        var boolvalue:Bool = false
        var address:String = ""
        for ar in array{
            let hasid = ar.localhash
            if hashid == hasid{
                boolvalue = true
                address = ar.localaddress
                return (boolvalue,address)
            }else{
                boolvalue = false
            }
        }
        return (boolvalue,address)
    }
    
    // from date implemenation
    @objc
    func fromcancelAction() {
        self.txtfromdate.resignFirstResponder()
    }
    @objc
    func fromdoneAction() {
        if let datePickerView = self.txtfromdate.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.txtfromdate.text = dateString
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "dd-MM-yyyy"
            let dateString2 = formatter2.string(from: datePickerView.date)
            fromDate = dateString2
            
            if let datePickerView = self.txttodate.inputView as? UIDatePicker {
                let dateFormatter3 = DateFormatter()
                dateFormatter3.dateFormat = "dd-MM-yyyy"
                let date = dateFormatter3.date(from:fromDate)!
                datePickerView.minimumDate = date
            }
            self.txtfromdate.resignFirstResponder()
        }
    }
    
    // To date implemenation
    @objc
    func tocancelAction() {
        self.txttodate.resignFirstResponder()
    }
    @objc
    func todoneAction() {
        if let datePickerView = self.txttodate.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.txttodate.text = dateString
            
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "dd-MM-yyyy"
            let dateString2 = formatter2.string(from: datePickerView.date)
            toDate = dateString2
            self.txttodate.resignFirstResponder()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.isUserInteractionEnabled = false
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isIdleTimerDisabled = true
        if BackAPI == true{
            init_syncing_wallet()
            self.SelectedBalance = SaveUserDefaultsData.SelectedBalance
            self.fetchMarketsData(false)
        }
        
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
        
        // Selected Currency Code Implement
        if backAPISelectedCurrency == true {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency.uppercased()
            if mainbalance.isEmpty {
                lblOtherCurrencyblns.text = "0.00 \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
            }else {
                let fullblnce = Double(mainbalance)! * CurrencyValue
                lblOtherCurrencyblns.text = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
            }
        }else {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency.uppercased()
            if mainbalance.isEmpty {
                let fullblnce = "0.00"
                // Trim "-" Value in amount place "-0.00 USD"
                var str = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                let cs = CharacterSet.init(charactersIn: "-")
                str = str.trimmingCharacters(in: cs)
                lblOtherCurrencyblns.text = "\(str)"
            }else {
                if CurrencyValue != nil {
                    let fullblnce = Double(mainbalance)! * CurrencyValue
                    lblOtherCurrencyblns.text = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                }
            }
        }
        
        // Rescan Height Update in userdefaults work
        if backAPIRescanVC == true {
            init_syncing_wallet()
        }
        filteredAllTransactionarray = []
        filteredOutgoingTransactionarray = []
        filteredIncomingTransactionarray = []
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if SaveUserDefaultsData.SwitchNode == true {
            SaveUserDefaultsData.SwitchNode = false
            self.closeWallet()
            init_syncing_wallet()
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "", message: "Switching Node", preferredStyle: .alert)
                let progressBar = UIProgressView(progressViewStyle: .default)
                progressBar.setProgress(0.0, animated: true)
                progressBar.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
                alert.view.addSubview(progressBar)
                self.present(alert, animated: true, completion: nil)
                var progress: Float = 0.0
                // Do the time critical stuff asynchronously
                DispatchQueue.global(qos: .background).async {
                    repeat {
                        progress += 0.1
                        Thread.sleep(forTimeInterval: 0.25)
                        print (progress)
                        DispatchQueue.main.async(flags: .barrier) {
                            progressBar.setProgress(progress, animated: true)
                        }
                    } while progress < 1.0
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true, completion: nil);
                    }
                }
            }
        }
    }
    
    //MARK:- Wallet func Connect Deamon
    func init_syncing_wallet() {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            lblMainblns.text = "0.00"
            lblOtherCurrencyblns.text = "0.00"
            self.syncedflag = false
            conncetingState.value = true
            syncedIconRef.isHidden = true
            self.progressLabel.textColor = Colors.bchat_button_clr
            progressLabel.text = "Loading Wallet ..."
            let username = SaveUserDefaultsData.NameForWallet
            WalletService.shared.openWallet(username, password: "") { [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let wallet):
                    strongSelf.wallet = wallet
                    strongSelf.connect(wallet: wallet)
                case .failure(_):
                    DispatchQueue.main.async {
                        strongSelf.refreshState.value = true
                        strongSelf.conncetingState.value = false
                        strongSelf.progressLabel.textColor = .red
                        strongSelf.progressLabel.text = "Failed to Connect"
                        self!.syncedflag = true
                        self!.syncedIconRef.isHidden = true
                    }
                }
            }
        } else {
            self.showToastMsg(message: "Please check your internet connection", seconds: 1.0)
        }
        
    }
    
    func connect(wallet: BDXWallet) {
        if !connecting {
            self.syncedflag = false
            self.conncetingState.value = true
            syncedIconRef.isHidden = true
            self.progressLabel.textColor = Colors.bchat_button_clr
            progressLabel.text = "Connecting ..."
        }
        wallet.connectToDaemon(address: SaveUserDefaultsData.FinalWallet_node, delegate: self) { [weak self] (isConnected) in
            guard let `self` = self else { return }
            if isConnected {
                if let wallet = self.wallet {
                    if SaveUserDefaultsData.WalletRestoreHeight == "" {
                        let defaultHeight = UInt64("1850630")!
                        wallet.restoreHeight = defaultHeight
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
                    self.syncedIconRef.isHidden = true
                    self.progressLabel.textColor = .red
                    self.progressLabel.text = "Failed to Connect"
                }
            }
        }
    }
    
    private func updateSyncingProgress() {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            if self.wallet?.synchronized == false {
                taskQueue.async {
                    let (current, total) = (self.currentBlockChainHeight, self.daemonBlockChainHeight)
                    guard total != current else { return }
                    let difference = total.subtractingReportingOverflow(current)
                    var progress = CGFloat(current) / CGFloat(total)
                    let leftBlocks: String
                    if difference.overflow || difference.partialValue <= 1 {
                        leftBlocks = "1"
                        progress = 1
                    } else {
                        leftBlocks = String(difference.partialValue)
                    }
                    let largeNumber = Int(leftBlocks)
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .decimal
                    numberFormatter.groupingSize = 3
                    numberFormatter.secondaryGroupingSize = 2
                    let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber ?? 1))
                    let statusText = "\(formattedNumber!)" + " Blocks Remaining"
                    DispatchQueue.main.async {
                        if self.conncetingState.value {
                            self.conncetingState.value = false
                        }
                        self.syncedflag = false
                        self.progressView.progress = Float(progress)
                        self.progressLabel.textColor = Colors.bchat_button_clr
                        self.progressLabel.text = statusText
                    }
                }
            }
        } else {
            self.progressLabel.textColor = .red
            self.progressLabel.text = "Check your internet"
        }
    }
    
    //syncWalletData
    @objc func syncWalletData(_ notification: Notification) {
        init_syncing_wallet()
    }
    
    private func synchronizedUI() {
        progressView.progress = 1
        syncedflag = true
        btnHomeScan.isUserInteractionEnabled = true
        btnHomeSend.isUserInteractionEnabled = true
        let logoName = isLightMode ? "ic_Scan_QR" : "ic_Scan_QR"
        imgScanRef.image = UIImage(named: logoName)!
        btnHomeSend.backgroundColor = Colors.sentMessageBackground
        btnHomeSend.setTitleColor(.white, for: .normal)
        self.progressLabel.textColor = Colors.bchat_button_clr
        self.progressLabel.text = "Synchronized"
        syncedIconRef.isHidden = false
        self.collectionView.reloadData()
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
    }
    
    // MARK: - BackScreen Func
    @objc func backHomeScreen(sender: UIBarButtonItem) {
        if syncedflag == false {
            let alert = UIAlertController(title: "Wallet is syncing...", message: "If you close the wallet, synchronization will be paused.Are you sure you want to exit the wallet?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                
            })
            alert.addAction(cancel)
            let exit = UIAlertAction(title: "Exit", style: .default, handler: { action in
                let homeVC = HomeVC()
                self.navigationController!.setViewControllers([ homeVC ], animated: true)
            })
            alert.addAction(exit)
            cancel.setValue(isLightMode ? UIColor.black : UIColor.white, forKey: "titleTextColor")
            exit.setValue(Colors.bchat_button_clr, forKey: "titleTextColor")
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }else {
            let alert = UIAlertController(title: "Are you sure you want to exit the wallet?", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                
            })
            alert.addAction(cancel)
            let exit = UIAlertAction(title: "Exit", style: .default, handler: { action in
                let homeVC = HomeVC()
                self.navigationController!.setViewControllers([ homeVC ], animated: true)
            })
            alert.addAction(exit)
            cancel.setValue(isLightMode ? UIColor.black : UIColor.white, forKey: "titleTextColor")
            exit.setValue(Colors.bchat_button_clr, forKey: "titleTextColor")
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }
    }
    
    // MARK: - Navigation
    
    func topButtonTouched(indexPath: IndexPath) {
        isExpanded[indexPath.row] = !isExpanded[indexPath.row]
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.collectionView.reloadItems(at: [indexPath])
        }, completion: { success in
            print("success")
        })
    }
    
    // MARK: Settings
    @objc func settingsoptn(_ sender: Any?) {
        self.filterView.isHidden = true
        viewdateRangeRef.isUserInteractionEnabled = true
        bottomview.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.syncedIconView.isHidden = true
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletSettingsVC") as! MyWalletSettingsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // MARK: Refresh
    @objc func refreshoptn(_ sender: Any?) {
        if(iconClick == true) {
            viewSyncing.isHidden = false
            bottomview.isUserInteractionEnabled = false
            scrollView.isUserInteractionEnabled = false
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            self.filterView.isHidden = true
            viewdateRangeRef.isUserInteractionEnabled = true
            bottomview.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.syncedIconView.isHidden = true
        } else {
            viewSyncing.isHidden = true
            bottomview.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
        }
        iconClick = !iconClick
    }
    @objc func dismissKeyboard() {
        if(iconClick == false) {
            viewSyncing.isHidden = true
            bottomview.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            iconClick = !iconClick
        }
    }
    
    // MARK: - Button Action
    @IBAction func sendAction(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletSendVC") as! MyWalletSendVC
        vc.wallet = self.wallet
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func receiveAction(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletReceiveVC") as! MyWalletReceiveVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func scanAction(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletScannerVC") as! MyWalletScannerVC
        vc.wallet = self.wallet
        vc.isFromWallet = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func syncedforRestoreHeightAction(_ sender: UIButton) {
        self.filterView.isHidden = true
        viewdateRangeRef.isUserInteractionEnabled = true
        bottomview.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.syncedIconView.isHidden = false
        lblsyncedRestoreHeight.text = "\(SaveUserDefaultsData.WalletRestoreHeight)."
    }
    @IBAction func syncedforRestoreHeightCloseAction(_ sender: UIButton) {
        self.syncedIconView.isHidden = true
        self.filterView.isHidden = true
        viewdateRangeRef.isUserInteractionEnabled = true
        bottomview.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    // Date Range References
    @IBAction func filterAction(_ sender: UIButton) {
        self.noTransaction = false
        self.isFilter = false
        fromDate = ""
        toDate = ""
        if let datePickerView = self.txttodate.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
        self.filterView.isHidden = false
        bottomview.isUserInteractionEnabled = false
        scrollView.isUserInteractionEnabled = false
    }
    
    @IBAction func incomingButtonTapped(_ sender: UIButton) {
        self.incomingButton.isSelected = !self.incomingButton.isSelected
        self.filterTransaction()
    }
    
    @IBAction func outgoingButtonTapped(_ sender: UIButton) {
        self.outgoingButton.isSelected = !self.outgoingButton.isSelected
        self.filterTransaction()
    }
    
    @IBAction func transactionByDateButtonTapped(_ sender: UIButton) {
        self.filterView.isHidden = true
        fromDate = ""
        toDate = ""
        viewdateRangeRef.isHidden = false
        bottomview.isUserInteractionEnabled = false
        scrollView.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    func filterTransaction() {
        if self.incomingButton.isSelected {
            let checkBox = isLightMode ? "icCheck_box" : "ic_Check_box_white"
            incomingImageView.image = UIImage(named: checkBox)!
        } else {
            let checkBox = isLightMode ? "ic_Uncheck-box" : "ic_Uncheck_box_white"
            incomingImageView.image = UIImage(named: checkBox)!
        }
        
        if self.outgoingButton.isSelected {
            let checkBox = isLightMode ? "icCheck_box" : "ic_Check_box_white"
            outgoingImageView.image = UIImage(named: checkBox)!
        } else {
            let checkBox = isLightMode ? "ic_Uncheck-box" : "ic_Uncheck_box_white"
            outgoingImageView.image = UIImage(named: checkBox)!
        }
        
        self.noTransaction = false
        self.isFilter = false
        fromDate = ""
        toDate = ""
        if let datePickerView = self.txttodate.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
        filteredAllTransactionarray = []
        filteredOutgoingTransactionarray = []
        filteredIncomingTransactionarray = []
        
        //All
        if self.incomingButton.isSelected && self.outgoingButton.isSelected {
            btnAllRef2 = true
            btnSendRef2 = false
            btnReceiveRef2 = false
            self.hideNoTransactionView()
            UserDefaults.standard.setValue(nil, forKey: "btnclicked")
        }
        
        //outgoing
        if !self.incomingButton.isSelected && self.outgoingButton.isSelected {
            btnAllRef2 = false
            btnSendRef2 = true
            btnReceiveRef2 = false
            self.hideNoTransactionView()
            UserDefaults.standard.setValue("outgoing", forKey: "btnclicked")
        }
        
        //incoming
        if self.incomingButton.isSelected && !self.outgoingButton.isSelected {
            btnAllRef2 = false
            btnSendRef2 = false
            btnReceiveRef2 = true
            self.hideNoTransactionView()
            UserDefaults.standard.setValue("incoming", forKey: "btnclicked")
        }
        
        //no
        if !self.incomingButton.isSelected && !self.outgoingButton.isSelected {
            self.noTransaction = true
            self.showNoTransactionView()
        }
        self.collectionView.reloadData()
    }
    
    func hideNoTransactionView() {
        self.NotransationImg.isHidden = true
        self.notransationLabel.isHidden = true
        self.notransationLabel2.isHidden = true
    }
    
    func showNoTransactionView() {
        self.NotransationImg.isHidden = false
        self.notransationLabel.isHidden = false
        self.notransationLabel2.isHidden = false
    }
    
    // Date Range References
    @IBAction func cancelDateAction(_ sender: UIButton) {
        self.fromcancelAction()
        self.tocancelAction()
        viewdateRangeRef.isHidden = true
        bottomview.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        txtfromdate.placeholder = "Select From Date"
        txttodate.placeholder = "Select To Date"
        txtfromdate.text = ""
        txttodate.text = ""
        filteredAllTransactionarray = []
        filteredOutgoingTransactionarray = []
        filteredIncomingTransactionarray = []
        self.isFilter = false
        fromDate = ""
        toDate = ""
        if let datePickerView = self.txttodate.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
        collectionView.reloadData()
    }
    @IBAction func okeyDateAction(_ sender: UIButton) {
        viewdateRangeRef.isHidden = true
        bottomview.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        filteredAllTransactionarray = []
        filteredOutgoingTransactionarray = []
        filteredIncomingTransactionarray = []
        if fromDate == "" || toDate == "" {
            self.isFilter = false
            let alert = UIAlertController(title: "", message: "please select both From and To dates", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.isFilter = true
            if UserDefaults.standard.value(forKey: "btnclicked") != nil {
                if UserDefaults.standard.value(forKey: "btnclicked")as! String == "outgoing" { // outgoing filter
                    for element in transactionSendarray {
                        let timeInterval = element.timestamp
                        let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy"
                        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                        let listDate = dateFormatter.string(from: date as Date)
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd-MM-yyyy"
                        let fromDateArray = fromDate.components(separatedBy: "-")
                        let FromDate = fromDateArray[0]
                        let FromMonth = fromDateArray[1]
                        let FromYear = fromDateArray[2]
                        let ToDateArray = toDate.components(separatedBy: "-")
                        let ToDate = ToDateArray[0]
                        let ToMonth = ToDateArray[1]
                        let ToYear = ToDateArray[2]
                        let ListArray = listDate.components(separatedBy: "-")
                        let ListDate = ListArray[0]
                        let ListMonth = ListArray[1]
                        let ListYear = ListArray[2]
                        if ListYear >= FromYear && ListYear <= ToYear {
                            if ListMonth >= FromMonth && ListMonth <= ToMonth {
                                if ListDate >= FromDate && ListDate <= ToDate{ //
                                    filteredOutgoingTransactionarray.append(element)
                                }
                            }
                        }
                    }
                    self.collectionView.reloadData()
                    let fromDateArray = fromDate.components(separatedBy: "-")
                    let FromDate = fromDateArray[0]
                    let FromMonth = fromDateArray[1]
                    let FromYear = fromDateArray[2]
                    let ToDateArray = toDate.components(separatedBy: "-")
                    let ToDate = ToDateArray[0]
                    let ToMonth = ToDateArray[1]
                    let ToYear = ToDateArray[2]
                    if ToYear <= FromYear {
                        if ToMonth <= FromMonth {
                            if ToDate < FromDate {
                                let alert = UIAlertController(title: "", message: "Invalid Date Range", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } else  if UserDefaults.standard.value(forKey: "btnclicked")as! String == "incoming" { // income filetr
                    for element in transactionReceivearray {
                        let timeInterval = element.timestamp
                        let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy"
                        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                        let listDate = dateFormatter.string(from: date as Date)
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd-MM-yyyy"
                        let fromDateArray = fromDate.components(separatedBy: "-")
                        let FromDate = fromDateArray[0]
                        let FromMonth = fromDateArray[1]
                        let FromYear = fromDateArray[2]
                        let ToDateArray = toDate.components(separatedBy: "-")
                        let ToDate = ToDateArray[0]
                        let ToMonth = ToDateArray[1]
                        let ToYear = ToDateArray[2]
                        let ListArray = listDate.components(separatedBy: "-")
                        let ListDate = ListArray[0]
                        let ListMonth = ListArray[1]
                        let ListYear = ListArray[2]
                        if ListYear >= FromYear && ListYear <= ToYear {
                            if ListMonth >= FromMonth && ListMonth <= ToMonth {
                                if ListDate >= FromDate && ListDate <= ToDate{ //
                                    filteredIncomingTransactionarray.append(element)
                                }
                            }
                        }
                    }
                    self.collectionView.reloadData()
                    let fromDateArray = fromDate.components(separatedBy: "-")
                    let FromDate = fromDateArray[0]
                    let FromMonth = fromDateArray[1]
                    let FromYear = fromDateArray[2]
                    let ToDateArray = toDate.components(separatedBy: "-")
                    let ToDate = ToDateArray[0]
                    let ToMonth = ToDateArray[1]
                    let ToYear = ToDateArray[2]
                    if ToYear <= FromYear {
                        if ToMonth <= FromMonth {
                            if ToDate < FromDate {
                                let alert = UIAlertController(title: "", message: "Invalid Date Range", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    
                }
            } else { // all filter
                for element in transactionAllarray {
                    let timeInterval = element.timestamp
                    let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy"
                    dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                    let listDate = dateFormatter.string(from: date as Date)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                    let fromDateArray = fromDate.components(separatedBy: "-")
                    let FromDate = fromDateArray[0]
                    let FromMonth = fromDateArray[1]
                    let FromYear = fromDateArray[2]
                    let ToDateArray = toDate.components(separatedBy: "-")
                    let ToDate = ToDateArray[0]
                    let ToMonth = ToDateArray[1]
                    let ToYear = ToDateArray[2]
                    let ListArray = listDate.components(separatedBy: "-")
                    let ListDate = ListArray[0]
                    let ListMonth = ListArray[1]
                    let ListYear = ListArray[2]
                    if ListYear >= FromYear && ListYear <= ToYear {
                        if ListMonth >= FromMonth && ListMonth <= ToMonth {
                            if ListDate >= FromDate && ListDate <= ToDate{ //
                                filteredAllTransactionarray.append(element)
                            }
                        }
                    }
                }
                self.collectionView.reloadData()
                let fromDateArray = fromDate.components(separatedBy: "-")
                let FromDate = fromDateArray[0]
                let FromMonth = fromDateArray[1]
                let FromYear = fromDateArray[2]
                let ToDateArray = toDate.components(separatedBy: "-")
                let ToDate = ToDateArray[0]
                let ToMonth = ToDateArray[1]
                let ToYear = ToDateArray[2]
                if ToYear <= FromYear {
                    if ToMonth <= FromMonth {
                        if ToDate < FromDate {
                            let alert = UIAlertController(title: "", message: "Invalid Date Range", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            txtfromdate.placeholder = "Select From Date"
            txttodate.placeholder = "Select To Date"
            txtfromdate.text = ""
            txttodate.text = ""
        }
        fromDate = ""
        toDate = ""
        if let datePickerView = self.txttodate.inputView as? UIDatePicker {
            datePickerView.minimumDate = nil
        }
    }
    
    // Recycle perpose code
    @IBAction func reconnectAction(_ sender: UIButton) {
        viewSyncing.isHidden = true
        bottomview.isUserInteractionEnabled = false
        scrollView.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        init_syncing_wallet()
    }
    @IBAction func rescanAction(_ sender: UIButton) {
        if syncedflag == true {
            viewSyncing.isHidden = true
            bottomview.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletRescanVC") as! MyWalletRescanVC
            vc.daemonBlockChainHeight = daemonBlockChainHeight
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            self.showToastMsg(message: "Can't rescan while wallet is syncing", seconds: 1.0)
        }
    }
}

extension MyWalletHomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.noTransaction {
            self.showNoTransactionView()
            return 0
        }
        if btnAllRef2 == true {
            if self.isFilter {
                if filteredAllTransactionarray.count == 0 {
                    self.showNoTransactionView()
                }
                return filteredAllTransactionarray.count
            } else {
                if transactionAllarray.count == 0 {
                    self.showNoTransactionView()
                }
                return transactionAllarray.count
            }
        }else if btnSendRef2 == true {
            if self.isFilter {
                if filteredOutgoingTransactionarray.count == 0 {
                    self.showNoTransactionView()
                }
                return filteredOutgoingTransactionarray.count
            } else {
                if transactionSendarray.count == 0 {
                    self.showNoTransactionView()
                }
                return transactionSendarray.count
            }
        }else {
            if self.isFilter {
                if filteredIncomingTransactionarray.count == 0 {
                    self.showNoTransactionView()
                }
                return filteredIncomingTransactionarray.count
            } else {
                if transactionReceivearray.count == 0 {
                    self.showNoTransactionView()
                }
                return transactionReceivearray.count
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalletHomeXibCell.identifier, for: indexPath) as! WalletHomeXibCell
        //drop down code
        if isExpanded[indexPath.row] == true{
            let logoName = isLightMode ? "ic_dropdown_dark" : "ic_dropdown_white"
            cell.img.image = UIImage(named: logoName)!
        }else{
            let logoName = isLightMode ? "ic_dropdown_darkDown" : "ic_dropdown_whiteDown"
            cell.img.image = UIImage(named: logoName)!
        }
        //Transation action browser
        let tap = UITapGestureRecognizer(target: self, action: #selector(MyWalletHomeVC.btntransation_action))
        cell.lbltraID.isUserInteractionEnabled = true
        cell.lbltraID.tag = indexPath.row
        cell.lbltraID.addGestureRecognizer(tap)
        cell.indexPath = indexPath
        cell.delegate = self
        
        if btnAllRef2 == true {
            //TimeStamp
            if filteredAllTransactionarray.count > 0 {
                let responceData = filteredAllTransactionarray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
                let dateString = dateFormatter.string(from: date as Date)
                cell.lbldate.text = dateString
                cell.lbltraID.text = responceData.hash
                cell.lbldateandtime.text = dateString
                cell.lblheight.text = "\(responceData.blockHeight)"
                cell.lblfee.text = "- Fee \(responceData.networkFee)"
                cell.lbltraID.text = responceData.hash
                //Save Receipent Address fun developed
                let serverhash = responceData.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray2)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    cell.lblReceipentAddress.text = "\(address)"
                }else {
                    cell.lblReceipentAddress.text = "---"
                }
                if responceData.direction != BChat_Messenger.TransactionDirection.received {
                    cell.lblSendandReceive.text = "Send"
                    cell.imgpic.image = UIImage(named: "ic_send_icon")
                    cell.lblamount.textColor = UIColor.red
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "- \(bdxamount)"
                    cell.lblfee.isHidden = false
                    cell.lblfeeTitle.isHidden = false
                    cell.lblReceipentAddress.isHidden = false
                    cell.lblReceipentAddressTitle.isHidden = false
                }else {
                    cell.lblSendandReceive.text = "Received"
                    cell.imgpic.image = UIImage(named: "ic_receive")
                    cell.lblamount.textColor = Colors.bchat_button_clr
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "+ \(bdxamount)"
                    cell.lblfee.isHidden = true
                    cell.lblfeeTitle.isHidden = true
                    cell.lblReceipentAddress.isHidden = true
                    cell.lblReceipentAddressTitle.isHidden = true
                }
            } else {
                let responceData = transactionAllarray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
                let dateString = dateFormatter.string(from: date as Date)
                cell.lbldate.text = dateString
                cell.lbldateandtime.text = dateString
                cell.lblheight.text = "\(responceData.blockHeight)"
                cell.lblfee.text = "- Fee \(responceData.networkFee)"
                cell.lbltraID.text = responceData.hash
                //Save Receipent Address fun developed
                let serverhash = responceData.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray2)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    cell.lblReceipentAddress.text = "\(address)"
                }else {
                    cell.lblReceipentAddress.text = "---"
                }
                if responceData.direction != BChat_Messenger.TransactionDirection.received {
                    cell.lblSendandReceive.text = "Send"
                    cell.imgpic.image = UIImage(named: "ic_send_icon")
                    cell.lblamount.textColor = UIColor.red
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "- \(bdxamount)"
                    cell.lblfee.isHidden = false
                    cell.lblfeeTitle.isHidden = false
                    cell.lblReceipentAddress.isHidden = false
                    cell.lblReceipentAddressTitle.isHidden = false
                }else {
                    cell.lblSendandReceive.text = "Received"
                    cell.imgpic.image = UIImage(named: "ic_receive")
                    cell.lblamount.textColor = Colors.bchat_button_clr
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "+ \(bdxamount)"
                    cell.lblfee.isHidden = true
                    cell.lblfeeTitle.isHidden = true
                    cell.lblReceipentAddress.isHidden = true
                    cell.lblReceipentAddressTitle.isHidden = true
                }
            }
        }else if btnSendRef2 == true {
            if filteredOutgoingTransactionarray.count > 0 {
                let responceData = filteredOutgoingTransactionarray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
                let dateString = dateFormatter.string(from: date as Date)
                cell.lbldate.text = dateString
                cell.lbldateandtime.text = dateString
                cell.lblheight.text = "\(responceData.blockHeight)"
                cell.lblfee.text = "- Fee \(responceData.networkFee)"
                cell.lbltraID.text = responceData.hash
                //Save Receipent Address fun developed
                let serverhash = responceData.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray2)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    cell.lblReceipentAddress.text = "\(address)"
                }else {
                    cell.lblReceipentAddress.text = "---"
                }
                if responceData.direction != BChat_Messenger.TransactionDirection.sent {
                    cell.lblSendandReceive.text = "Send"
                    cell.imgpic.image = UIImage(named: "ic_send_icon")
                    cell.lblamount.textColor = UIColor.red
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "- \(bdxamount)"
                    cell.lblfee.isHidden = false
                    cell.lblfeeTitle.isHidden = false
                    cell.lblReceipentAddress.isHidden = false
                    cell.lblReceipentAddressTitle.isHidden = false
                }else {
                    cell.lblSendandReceive.text = "Send"
                    cell.imgpic.image = UIImage(named: "ic_send_icon")
                    cell.lblamount.textColor = UIColor.red
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "- \(bdxamount)"
                    cell.lblfee.isHidden = false
                    cell.lblfeeTitle.isHidden = false
                    cell.lblReceipentAddress.isHidden = false
                    cell.lblReceipentAddressTitle.isHidden = false
                }
            } else {
                let responceData = transactionSendarray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
                let dateString = dateFormatter.string(from: date as Date)
                cell.lbldate.text = dateString
                cell.lbldateandtime.text = dateString
                cell.lblheight.text = "\(responceData.blockHeight)"
                cell.lblfee.text = "- Fee \(responceData.networkFee)"
                cell.lbltraID.text = responceData.hash
                //Save Receipent Address fun developed
                let serverhash = responceData.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray2)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    cell.lblReceipentAddress.text = "\(address)"
                }else {
                    cell.lblReceipentAddress.text = "---"
                }
                if responceData.direction != BChat_Messenger.TransactionDirection.sent {
                    cell.lblSendandReceive.text = "Send"
                    cell.imgpic.image = UIImage(named: "ic_send_icon")
                    cell.lblamount.textColor = UIColor.red
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "- \(bdxamount)"
                    cell.lblfee.isHidden = false
                    cell.lblfeeTitle.isHidden = false
                    cell.lblReceipentAddress.isHidden = false
                    cell.lblReceipentAddressTitle.isHidden = false
                }else {
                    cell.lblSendandReceive.text = "Send"
                    cell.imgpic.image = UIImage(named: "ic_send_icon")
                    cell.lblamount.textColor = UIColor.red
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "- \(bdxamount)"
                    cell.lblfee.isHidden = false
                    cell.lblfeeTitle.isHidden = false
                    cell.lblReceipentAddress.isHidden = false
                    cell.lblReceipentAddressTitle.isHidden = false
                }
            }
        }else {
            if filteredIncomingTransactionarray.count > 0 {
                //TimeStamp
                let responceData = filteredIncomingTransactionarray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
                let dateString = dateFormatter.string(from: date as Date)
                cell.lbldate.text = dateString
                cell.lbldateandtime.text = dateString
                cell.lblheight.text = "\(responceData.blockHeight)"
                cell.lblfee.text = "- Fee \(responceData.networkFee)"
                cell.lbltraID.text = responceData.hash
                //Save Receipent Address fun developed
                let serverhash = responceData.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray2)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    cell.lblReceipentAddress.text = "\(address)"
                }else {
                    cell.lblReceipentAddress.text = "---"
                }
                if responceData.direction != BChat_Messenger.TransactionDirection.received {
                    cell.lblSendandReceive.text = "Received"
                    cell.imgpic.image = UIImage(named: "ic_receive")
                    cell.lblamount.textColor = Colors.bchat_button_clr
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "+ \(bdxamount)"
                    cell.lblfee.isHidden = true
                    cell.lblfeeTitle.isHidden = true
                    cell.lblReceipentAddress.isHidden = true
                    cell.lblReceipentAddressTitle.isHidden = true
                }else {
                    cell.lblSendandReceive.text = "Received"
                    cell.imgpic.image = UIImage(named: "ic_receive")
                    cell.lblamount.textColor = Colors.bchat_button_clr
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "+ \(bdxamount)"
                    cell.lblfee.isHidden = true
                    cell.lblfeeTitle.isHidden = true
                    cell.lblReceipentAddress.isHidden = true
                    cell.lblReceipentAddressTitle.isHidden = true
                }
            } else {
                //TimeStamp
                let responceData = transactionReceivearray[indexPath.row]
                let timeInterval  = responceData.timestamp
                let date = NSDate(timeIntervalSince1970: TimeInterval(timeInterval))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
                let dateString = dateFormatter.string(from: date as Date)
                cell.lbldate.text = dateString
                cell.lbldateandtime.text = dateString
                cell.lblheight.text = "\(responceData.blockHeight)"
                cell.lblfee.text = "- Fee \(responceData.networkFee)"
                cell.lbltraID.text = responceData.hash
                //Save Receipent Address fun developed
                let serverhash = responceData.hash
                let hashionfo = self.start(hashid: serverhash, array: hashArray2)
                let hashbool = hashionfo.boolvalue
                let address = hashionfo.address
                if hashbool == true {
                    cell.lblReceipentAddress.text = "\(address)"
                }else {
                    cell.lblReceipentAddress.text = "---"
                }
                if responceData.direction != BChat_Messenger.TransactionDirection.received {
                    cell.lblSendandReceive.text = "Received"
                    cell.imgpic.image = UIImage(named: "ic_receive")
                    cell.lblamount.textColor = Colors.bchat_button_clr
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "+ \(bdxamount)"
                    cell.lblfee.isHidden = true
                    cell.lblfeeTitle.isHidden = true
                    cell.lblReceipentAddress.isHidden = true
                    cell.lblReceipentAddressTitle.isHidden = true
                }else {
                    cell.lblSendandReceive.text = "Received"
                    cell.imgpic.image = UIImage(named: "ic_receive")
                    cell.lblamount.textColor = Colors.bchat_button_clr
                    let bdxamount = Double(responceData.amount)!.removeZerosFromEnd()
                    cell.lblamount.text = "+ \(bdxamount)"
                    cell.lblfee.isHidden = true
                    cell.lblfeeTitle.isHidden = true
                    cell.lblReceipentAddress.isHidden = true
                    cell.lblReceipentAddressTitle.isHidden = true
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isExpanded[indexPath.row] == true{
            if self.noTransaction {
                return CGSize(width: collectionView.frame.size.width, height: 345)
            }
            if btnAllRef2 == true {
                if self.isFilter {
                    if filteredAllTransactionarray.count == 0 {
                        self.showNoTransactionView()
                    }
                    let responceData = filteredAllTransactionarray[indexPath.row]
                    if responceData.direction == BChat_Messenger.TransactionDirection.received {
                        return CGSize(width: collectionView.frame.size.width, height: 250)
                    } else {
                        return CGSize(width: collectionView.frame.size.width, height: 345)
                    }
                    
                } else {
                    if transactionAllarray.count == 0 {
                        self.showNoTransactionView()
                    }
                    let responceData = transactionAllarray[indexPath.row]
                    if responceData.direction == BChat_Messenger.TransactionDirection.received {
                        return CGSize(width: collectionView.frame.size.width, height: 250)
                    } else {
                        return CGSize(width: collectionView.frame.size.width, height: 345)
                    }
                }
            }else if btnSendRef2 == true {
                if self.isFilter {
                    if filteredOutgoingTransactionarray.count == 0 {
                        self.showNoTransactionView()
                    }
                    let responceData = filteredOutgoingTransactionarray[indexPath.row]
                    if responceData.direction == BChat_Messenger.TransactionDirection.received {
                        return CGSize(width: collectionView.frame.size.width, height: 250)
                    } else {
                        return CGSize(width: collectionView.frame.size.width, height: 345)
                    }
                } else {
                    if transactionSendarray.count == 0 {
                        self.showNoTransactionView()
                    }
                    let responceData = transactionSendarray[indexPath.row]
                    if responceData.direction == BChat_Messenger.TransactionDirection.received {
                        return CGSize(width: collectionView.frame.size.width, height: 250)
                    } else {
                        return CGSize(width: collectionView.frame.size.width, height: 345)
                    }
                }
            }else {
                if self.isFilter {
                    if filteredIncomingTransactionarray.count == 0 {
                        self.showNoTransactionView()
                    }
                    let responceData = filteredIncomingTransactionarray[indexPath.row]
                    if responceData.direction == BChat_Messenger.TransactionDirection.received {
                        return CGSize(width: collectionView.frame.size.width, height: 250)
                    } else {
                        return CGSize(width: collectionView.frame.size.width, height: 345)
                    }
                } else {
                    if transactionReceivearray.count == 0 {
                        self.showNoTransactionView()
                    }
                    let responceData = transactionReceivearray[indexPath.row]
                    if responceData.direction == BChat_Messenger.TransactionDirection.received {
                        return CGSize(width: collectionView.frame.size.width, height: 250)
                    } else {
                        return CGSize(width: collectionView.frame.size.width, height: 345)
                    }
                }
            }
        }else{
            return CGSize(width: collectionView.frame.size.width, height: 75)
        }
    }
    
    @objc func btntransation_action(sender:UITapGestureRecognizer) {
        if btnAllRef2 == true {
            let indexPath = IndexPath(item: sender.view!.tag, section: 0);
            if collectionView.cellForItem(at: indexPath) is WalletHomeXibCell {
                let trID = transactionAllarray[indexPath.row].hash
                if let url = URL(string: "https://explorer.beldex.io/tx/\(trID)") {
                    UIApplication.shared.open(url)
                }
            }
        }else if btnSendRef2 == true {
            let indexPath = IndexPath(item: sender.view!.tag, section: 0);
            if collectionView.cellForItem(at: indexPath) is WalletHomeXibCell {
                let trID = transactionSendarray[indexPath.row].hash
                if let url = URL(string: "https://explorer.beldex.io/tx/\(trID)") {
                    UIApplication.shared.open(url)
                }
            }
        }else {
            let indexPath = IndexPath(item: sender.view!.tag, section: 0);
            if collectionView.cellForItem(at: indexPath) is WalletHomeXibCell {
                let trID = transactionReceivearray[indexPath.row].hash
                if let url = URL(string: "https://explorer.beldex.io/tx/\(trID)") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    //MARK:- Balance currency conversion
    private func reloadData(_ json: [String: [String: Any]]) {
        let xmrAmount = json["beldex"]?[currencyName] as? Double
        if xmrAmount != nil {
            CurrencyValue = xmrAmount
            //MARK:- Balance currency conversion
            if mainbalance.isEmpty {
                self.lblMainblns.text = "0.00"
            }else {
                if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
                    SelectedDecimal = SaveUserDefaultsData.SelectedDecimal
                    if SelectedDecimal == "4 - Decimal" {
                        self.lblMainblns.text = String(format:"%.4f", Double(mainbalance)!)
                    }else if SelectedDecimal == "3 - Decimal" {
                        self.lblMainblns.text = String(format:"%.3f", Double(mainbalance)!)
                    }else if SelectedDecimal == "2 - Decimal" {
                        self.lblMainblns.text = String(format:"%.2f", Double(mainbalance)!)
                    }else if SelectedDecimal == "0 - Decimal" {
                        self.lblMainblns.text = String(format:"%.0f", Double(mainbalance)!)
                    }
                    self.currencyName = SaveUserDefaultsData.SelectedCurrency
                    self.fetchMarketsData(false)
                    self.reloadData([:])
                    
                    if mainbalance.isEmpty {
                        let fullblnce = "0.00"
                        lblOtherCurrencyblns.text = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                    }else {
                        if CurrencyValue != nil {
                            let fullblnce = Double(mainbalance)! * CurrencyValue
                            lblOtherCurrencyblns.text = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                        }
                    }
                }else {
                    let fullblnce = Double(mainbalance)! * CurrencyValue
                    lblOtherCurrencyblns.text = "\(String(format:"%.2f", fullblnce)) \(SaveUserDefaultsData.SelectedCurrency.uppercased())"
                }
            }
        }
    }
    
    private func fetchMarketsData(_ showHUD: Bool = false) {
        if let req = marketsDataRequest {
            req.cancel()
        }
        if showHUD { loadingState.newState(true) }
        let startTime = CFAbsoluteTimeGetCurrent()
        let Url = "https://api.coingecko.com/api/v3/simple/price?ids=beldex&vs_currencies=\(currencyName)"
        let request = Session.default.request("\(Url)")
        request.responseJSON(queue: .main, options: .mutableLeaves) { [weak self] (resp) in
            guard let SELF = self else { return }
            SELF.marketsDataRequest = nil
            if showHUD { SELF.loadingState.newState(false) }
            switch resp.result {
            case .failure(_): break
                //   HUD.showError(error.localizedDescription)
            case .success(let value):
                SELF.reloadData(value as? [String: [String: Any]] ?? [:])
            }
            let endTime = CFAbsoluteTimeGetCurrent()
            let requestDuration = endTime - startTime
            if requestDuration >= SELF.refreshDuration {
                SELF.fetchMarketsData()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + SELF.refreshDuration - requestDuration) {
                    guard let SELF = self else { return }
                    SELF.fetchMarketsData()
                }
            }
        }
        marketsDataRequest = request
    }
    
}
extension MyWalletHomeVC: BeldexWalletDelegate {
    func beldexWalletRefreshed(_ wallet: BChatWalletWrapper) {
        print("Refreshed---------->blockChainHeight-->\(wallet.blockChainHeight) ---------->daemonBlockChainHeight-->, \(wallet.daemonBlockChainHeight)")
        self.daemonBlockChainHeight = wallet.daemonBlockChainHeight
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            if self.wallet?.synchronized == true {
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
            self.synchronizedUI()
        }
    }
    func beldexWalletNewBlock(_ wallet: BChatWalletWrapper, currentHeight: UInt64) {
//        print("11111------------------------------------------currentHeight ----> \(currentHeight)---DaemonBlockHeight---->\(wallet.daemonBlockChainHeight)")
        self.currentBlockChainHeight = currentHeight
        self.daemonBlockChainHeight = wallet.daemonBlockChainHeight
        self.needSynchronized = true
        self.isSyncingUI = true
    }
    
    private func postData(balance: String, history: TransactionHistory) {
        let balance_modify = Helper.displayDigitsAmount(balance)
        transactionAllarray = history.all
        expandingArray = transactionAllarray
        let count = expandingArray.count
        isExpanded = Array(repeating: false, count: count)
        transactionSendarray = history.send
        transactionReceivearray = history.receive
        self.mainbalance = balance_modify
        DispatchQueue.main.async { [self] in
            self.transactionAllarray = history.all
            self.transactionSendarray = history.send
            self.transactionReceivearray = history.receive
            
            if SaveUserDefaultsData.WalletRestoreHeight == "" {
                let restoreHeightempty = UInt64("1850630")!
                self.transactionAllarray = self.transactionAllarray.filter{$0.blockHeight >= restoreHeightempty}
                self.transactionSendarray = self.transactionSendarray.filter{$0.blockHeight >= restoreHeightempty}
                self.transactionReceivearray = self.transactionReceivearray.filter{$0.blockHeight >= restoreHeightempty}
            } else {
                self.transactionAllarray = self.transactionAllarray.filter{$0.blockHeight >= UInt64(SaveUserDefaultsData.WalletRestoreHeight)!}
                self.transactionSendarray = self.transactionSendarray.filter{$0.blockHeight >= UInt64(SaveUserDefaultsData.WalletRestoreHeight)!}
                self.transactionReceivearray = self.transactionReceivearray.filter{$0.blockHeight >= UInt64(SaveUserDefaultsData.WalletRestoreHeight)!}
            }
            
            if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
                SelectedDecimal = SaveUserDefaultsData.SelectedDecimal
                if SelectedDecimal == "4 - Decimal" {
                    self.lblMainblns.text = String(format:"%.4f", Double(mainbalance)!)
                }else if SelectedDecimal == "3 - Decimal" {
                    self.lblMainblns.text = String(format:"%.3f", Double(mainbalance)!)
                }else if SelectedDecimal == "2 - Decimal" {
                    self.lblMainblns.text = String(format:"%.2f", Double(mainbalance)!)
                }else if SelectedDecimal == "0 - Decimal" {
                    self.lblMainblns.text = String(format:"%.0f", Double(mainbalance)!)
                }
            }else {
                self.lblMainblns.text = String(format:"%.4f", Double(balance_modify)!)
            }
            
            if SaveUserDefaultsData.SelectedBalance == "Beldex Full Balance" || SaveUserDefaultsData.SelectedBalance == "Beldex Available Balance"{
                if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
                    SelectedDecimal = SaveUserDefaultsData.SelectedDecimal
                    if SelectedDecimal == "4 - Decimal" {
                        self.lblMainblns.text = String(format:"%.4f", Double(mainbalance)!)
                    }else if SelectedDecimal == "3 - Decimal" {
                        self.lblMainblns.text = String(format:"%.3f", Double(mainbalance)!)
                    }else if SelectedDecimal == "2 - Decimal" {
                        self.lblMainblns.text = String(format:"%.2f", Double(mainbalance)!)
                    }else if SelectedDecimal == "0 - Decimal" {
                        self.lblMainblns.text = String(format:"%.0f", Double(mainbalance)!)
                    }
                }else {
                    self.lblMainblns.text = String(format:"%.4f", Double(balance_modify)!)
                }
            }
            if SaveUserDefaultsData.SelectedBalance == "Beldex Hidden" {
                self.lblMainblns.text = "---"
                self.lblOtherCurrencyblns.text = "---"
            }
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            self.fetchMarketsData(false)
            self.reloadData([:])
            
            self.collectionView.reloadData()
            if self.transactionAllarray.count == 0 {
                self.showNoTransactionView()
            }else {
                self.hideNoTransactionView()
            }
        }
    }
}

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
}
