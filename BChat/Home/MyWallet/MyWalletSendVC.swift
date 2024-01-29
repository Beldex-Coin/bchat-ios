// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit
import Alamofire
import NVActivityIndicatorView
import BChatUIKit

class MyWalletSendVC: BaseVC,UITextFieldDelegate,MyDataSendingDelegateProtocol,UITextViewDelegate {
    
    @IBOutlet weak var backgroundAddressView: UIView!
    @IBOutlet weak var backgroundAmountView: UIView!
    @IBOutlet weak var btnsend: UIButton!
    @IBOutlet weak var txtaddress: UITextView!
    @IBOutlet weak var txtamount: UITextField!
    @IBOutlet weak var lblusd: UILabel!
    @IBOutlet weak var scanRefbtn: UIButton!
    @IBOutlet weak var addressRefbtn: UIButton!
    @IBOutlet weak var lbladdressAftersending: UILabel!
    @IBOutlet weak var lblAmountAftersending: UILabel!
    @IBOutlet weak var lblFeeAftersending: UILabel!
    @IBOutlet weak var confirmSendingPopView: UIView!
    @IBOutlet weak var btncancel: UIButton!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var successPopView: UIView!
    @IBOutlet weak var btnfinalOK: UIButton!
    @IBOutlet weak var imgtick: UIImageView!
    public lazy var loadingState = { Postable<Bool>() }()
    private var currencyName = ""
    private var bdxCurrencyValue = ""
    private var currencyValue: Double!
    private var refreshDuration: TimeInterval = 60
    private var marketsDataRequest: DataRequest?
    var walletAddress: String!
    var walletAmount: String!
    var wallet: BDXWallet?
    private lazy var taskQueue = DispatchQueue(label: "beldex.wallet.task")
    private var currentBlockChainHeight: UInt64 = 0
    private var daemonBlockChainHeight: UInt64 = 0
    lazy var conncetingState = { return Observable<Bool>(false) }()
    private var needSynchronized = false {
        didSet {
            guard needSynchronized, !oldValue,
                  let wallet = self.wallet else { return }
            wallet.saveOnTerminate()
        }
    }
    private let loading = NVActivityIndicatorView(frame: .zero, type: .ballSpinFadeLoader, color: isLightMode ? .black : .white , padding: 0)
    private func configureLoading() {
        loading.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loading)
        NSLayoutConstraint.activate([
            loading.widthAnchor.constraint(equalToConstant: 40),
            loading.heightAnchor.constraint(equalToConstant: 40),
            loading.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loading.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    var backAPI = false
    var hashArray = [RecipientDomainSchema]()
    var recipientAddressON = false
    var placeholderLabel : UILabel!
    var finalWalletAddress = ""
    var finalWalletAmount = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        configureLoading()
        
        //Keyboard Done Option
        txtamount.addDoneButtonKeybord()
        
        self.title = "Send"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let newBackButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(MyWalletSendVC.backHomeScreen(sender:)))
        newBackButton.image = UIImage(named: "NavBarBack")
        self.navigationItem.leftBarButtonItem = newBackButton
        //TextView Placholder
        txtaddress.delegate = self
        txtaddress.isUserInteractionEnabled = true
        scanRefbtn.isUserInteractionEnabled = true
        addressRefbtn.isUserInteractionEnabled = true
        placeholderLabel = UILabel()
        placeholderLabel.text = "Beldex address"
        placeholderLabel.font = Fonts.OpenSans(ofSize: (txtaddress.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        txtaddress.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtaddress.font?.pointSize)! / 2)
        placeholderLabel.textColor = Colors.bchatPlaceholderColor
        placeholderLabel.isHidden = !txtaddress.text.isEmpty
        
        //Save Receipent Address fun developed In Local
        self.saveReceipeinetAddressOnAndOff()
        
        btnsend.layer.cornerRadius = 6
        backgroundAddressView.layer.cornerRadius = 6
        backgroundAmountView.layer.cornerRadius = 6
        btncancel.layer.cornerRadius = 6
        btnOK.layer.cornerRadius = 6
        successPopView.layer.cornerRadius = 6
        confirmSendingPopView.layer.cornerRadius = 6
        btnfinalOK.layer.cornerRadius = 6
        lblusd.layer.cornerRadius = 6
        lblusd.clipsToBounds = true
        txtamount.delegate = self
        txtamount.keyboardType = .decimalPad
        txtaddress.delegate = self
        txtamount.delegate = self
        txtaddress.returnKeyType = .done
        txtamount.tintColor = Colors.bchatButtonColor
        txtaddress.tintColor = Colors.bchatButtonColor
        let logoScanImg = isLightMode ? "scan_QR_dark" : "scan_QR"
        scanRefbtn.setImage(UIImage(named: logoScanImg), for: .normal)
        let logoAddressImg = isLightMode ? "user_light" : "user_dark"
        addressRefbtn.setImage(UIImage(named: logoAddressImg), for: .normal)
        
        if backAPI == true{
            self.confirmSendingPopView.isHidden = false
            self.successPopView.isHidden = true
            self.lbladdressAftersending.text = self.txtaddress.text!
            self.lblAmountAftersending.text = self.txtamount.text!
            self.lblFeeAftersending.text = "---"
            txtaddress.isUserInteractionEnabled = false
            scanRefbtn.isUserInteractionEnabled = false
            addressRefbtn.isUserInteractionEnabled = false
        }else {
            confirmSendingPopView.isHidden = true
            successPopView.isHidden = true
            txtaddress.isUserInteractionEnabled = true
            scanRefbtn.isUserInteractionEnabled = true
            addressRefbtn.isUserInteractionEnabled = true
        }
        
        imgtick.layer.cornerRadius = imgtick.layer.frame.height/2
        imgtick.clipsToBounds = true
        
        if walletAddress != nil {
            placeholderLabel?.isHidden = true
            self.txtaddress.text = "\(walletAddress!)"
        }
        if walletAmount != nil {
            self.txtamount.text = "\(walletAmount!)"
            self.bdxCurrencyValue = txtamount.text!
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            fetchMarketsData(false)
            reloadData([:])
        }
        if !SaveUserDefaultsData.SelectedCurrency.isEmpty {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            lblusd.text = "  \(self.currencyName.uppercased()) 0.00  "
        }else {
            self.currencyName = "usd"
            lblusd.text = "  \(self.currencyName.uppercased()) 0.00  "
        }
        
        let dismiss: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismiss)
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.saveReceipeinetAddressOnAndOff()
        if backAPI == true{
            self.btnOK.backgroundColor = UIColor(red: 0.47, green: 0.47, blue: 0.55, alpha: 1.00)
            self.confirmSendingPopView.isHidden = false
            self.successPopView.isHidden = true
            self.lbladdressAftersending.text = self.txtaddress.text!
            self.lblAmountAftersending.text = self.txtamount.text!
            self.lblFeeAftersending.text = "---"
            self.txtamount.text = ""
            self.txtaddress.text = ""
            txtaddress.isUserInteractionEnabled = false
            scanRefbtn.isUserInteractionEnabled = false
            addressRefbtn.isUserInteractionEnabled = false
            loading.startAnimating()
            placeholderLabel?.isHidden = !txtaddress.text.isEmpty
            if !SaveUserDefaultsData.SelectedCurrency.isEmpty {
                self.currencyName = SaveUserDefaultsData.SelectedCurrency
                lblusd.text = "  \(self.currencyName.uppercased()) 0.00  "
            }else {
                self.currencyName = "usd"
                lblusd.text = "  \(self.currencyName.uppercased()) 0.00  "
            }
        }else {
            confirmSendingPopView.isHidden = true
            successPopView.isHidden = true
            txtaddress.isUserInteractionEnabled = true
            scanRefbtn.isUserInteractionEnabled = true
            addressRefbtn.isUserInteractionEnabled = true
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if backAPI == true{
            self.btnOK.backgroundColor = UIColor(red: 0.47, green: 0.47, blue: 0.55, alpha: 1.00)
            self.txtamount.text = ""
            self.txtaddress.text = ""
            connect(wallet: self.wallet!)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.backAPI = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    //TextView Placholder delegates
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
//        placeholderLabel?.isHidden = true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        if textView == txtaddress{
            let currentString: NSString = txtaddress.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString
            return newString.length <= 97
        }
        return true
    }
    
    // txtamout only sigle . enter and txtaddress lenth fixed
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtaddress{
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= 97
        }else{
            // Get the current text in the text field
            guard let currentText = txtamount.text else {
                return true
            }
            // Calculate the future text if the user's input is accepted
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            // Use regular expression to validate the new text format
            let amountPattern = "^(\\d{0,9})(\\.\\d{0,5})?$"
            let amountTest = NSPredicate(format: "SELF MATCHES %@", amountPattern)
            return amountTest.evaluate(with: newText)
        }
    }
    
    // Textfiled Paste option hide
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:))
        {
            return true
        } else if action == Selector(("_lookup:")) || action == Selector(("_share:")) || action == Selector(("_define:")) || action == #selector(delete(_:)) || action == #selector(copy(_:)) || action == #selector(cut(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    func saveReceipeinetAddressOnAndOff(){
        if SaveUserDefaultsData.SaveReceipeinetSwitch == true {
            recipientAddressON = true
        } else {
            recipientAddressON = false
        }
    }
    
    // Delegate Method
    func sendDataToMyWalletSendVC(myData: String) {
        btnsend.isUserInteractionEnabled = true
        placeholderLabel?.isHidden = true
        self.txtaddress.text = myData
    }
    
    @objc func backHomeScreen(sender: UIBarButtonItem) {
        self.navigationController?.popToSpecificViewController(ofClass: MyWalletHomeVC.self, animated: true)
    }
    
    // cancel Button Tapped
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        confirmSendingPopView.isHidden = true
        successPopView.isHidden = true
        txtaddress.isUserInteractionEnabled = true
        scanRefbtn.isUserInteractionEnabled = true
        addressRefbtn.isUserInteractionEnabled = true
        loading.stopAnimating()
    }
    
    //confirm sending Button Tapped 22
    @IBAction func confirmsendingButtonTapped(_ sender: UIButton) {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            loading.startAnimating()
            let txid = self.wallet!.txid()
            let commitPendingTransaction = self.wallet!.commitPendingTransaction()
            if commitPendingTransaction == true {
                //Save Receipent Address fun developed In Local
                if recipientAddressON == true {
                    if !UserDefaults.standard.domainSchemas.isEmpty {
                        hashArray = UserDefaults.standard.domainSchemas
                        hashArray.append(.init(localhash: txid, localaddress: lbladdressAftersending.text!))
                        UserDefaults.standard.domainSchemas = hashArray
                    }else {
                        hashArray.append(.init(localhash: txid, localaddress: lbladdressAftersending.text!))
                        UserDefaults.standard.domainSchemas = hashArray
                    }
                }
                loading.stopAnimating()
                confirmSendingPopView.isHidden = true
                successPopView.isHidden = false
            }
        } else {
            self.showToastMsg(message: "Please check your internet connection", seconds: 1.0)
        }
    }

    //success Button Tapped 33
    @IBAction func successButtonTapped(_ sender: UIButton) {
        self.navigationController?.popToSpecificViewController(ofClass: MyWalletHomeVC.self, animated: true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "syncWallet"), object: nil)
    }
    //address Book Button Tapped
    @IBAction func addressBookButtonTapped(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletAddressBookVC") as! MyWalletAddressBookVC
        vc.delegate = self
        vc.flagSendAddress = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //send Transation Button Tapped 11
    @IBAction func sendTransationButtonTapped(_ sender: UIButton) {
        if confirmSendingPopView.isHidden == false {
            btnsend.isUserInteractionEnabled = false
        }else {
            btnsend.isUserInteractionEnabled = true
            
            if txtaddress.text!.isEmpty || txtamount.text!.isEmpty {
                let alert = UIAlertController(title: "My Wallet", message: "fill the all fileds", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                let indexOfString = txtamount.text!
                let lastString = txtamount.text!.index(before: txtamount.text!.endIndex)
                guard BChatWalletWrapper.validAddress(txtaddress.text!) else {
                    let alert = UIAlertController(title: "My Wallet", message: "Not a valid address", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                if txtamount.text?.count == 0 {
                    let alert = UIAlertController(title: "My Wallet", message: "Pls Enter amount", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else if txtamount.text! == "." || Int(txtamount.text!) == 0 || indexOfString.count > 16 || txtamount.text![lastString] == "." {
                    let alert = UIAlertController(title: "My Wallet", message: "Pls Enter Proper amount", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }else {
                    if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
                        self.finalWalletAddress = self.txtaddress.text!
                        self.finalWalletAmount = self.txtamount.text!
                        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletPasscodeVC") as! MyWalletPasscodeVC
                        vc.isSendWalletVC = true
                        vc.wallet = self.wallet
                        vc.finalWalletAddress = self.finalWalletAddress
                        vc.finalWalletAmount = self.finalWalletAmount
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        self.showToastMsg(message: "Please check your internet connection", seconds: 1.0)
                    }
                }
            }
        }
    }
    //scan Transation Button Tapped
    @IBAction func scanTransationButtonTapped(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletScannerVC") as! MyWalletScannerVC
        vc.isFromWallet = true
        vc.wallet = self.wallet
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if txtamount.text!.count == 0 {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            lblusd.text = "  \(self.currencyName.uppercased()) 0.00  "
            self.bdxCurrencyValue = txtamount.text!
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            fetchMarketsData(false)
            reloadData([:])
        }else if txtamount.text == "." {
            // print("---dot value entry----")
        }else {
            self.bdxCurrencyValue = txtamount.text!
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            fetchMarketsData(false)
            reloadData([:])
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if txtamount.text!.count == 0 {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            lblusd.text = "  \(self.currencyName.uppercased()) 0.00  "
        }else if txtamount.text == "." {
            // print("---dot value entry----")
        }else {
            self.bdxCurrencyValue = txtamount.text!
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            fetchMarketsData(false)
            reloadData([:])
        }
    }
    
    private func reloadData(_ json: [String: [String: Any]]) {
        let xmrAmount = json["beldex"]?[currencyName] as? Double
        if xmrAmount != nil {
            currencyValue = xmrAmount
        }
        if currencyValue != nil && bdxCurrencyValue != "" {
            let tax = Double(bdxCurrencyValue)! * currencyValue
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            lblusd.text = "  \(self.currencyName.uppercased()) \(String(format:"%.4f",tax))  "
        }
    }
    
    private func fetchMarketsData(_ showHUD: Bool = false) {
        if let req = marketsDataRequest {
            req.cancel()
        }
        if showHUD { loadingState.newState(true) }
        let startTime = CFAbsoluteTimeGetCurrent()
        let Url = "https://api.coingecko.com/api/v3/simple/price?ids=beldex&vs_currencies=\(currencyName.lowercased())"
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
    
    // Wallet Send Func
    func connect(wallet: BDXWallet) {
        wallet.connectToDaemon(address: SaveUserDefaultsData.FinalWallet_node, delegate: self) { [weak self] (isConnected) in
            guard let `self` = self else { return }
            if isConnected {
                if let wallet = self.wallet {
                    if SaveUserDefaultsData.WalletRestoreHeight == "" {
                        let lastElementHeight = DateHeight.getBlockHeight.last
                        let height = lastElementHeight!.components(separatedBy: ":")
                        SaveUserDefaultsData.WalletRestoreHeight = "\(height[1])"
                        wallet.restoreHeight = UInt64("\(height[1])")!
                    }else {
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
            self.lblFeeAftersending.text = feeValue
            loading.stopAnimating()
            self.btnOK.backgroundColor = Colors.bchatButtonColor
        }else {
            loading.stopAnimating()
            self.btnOK.backgroundColor = UIColor(red: 0.47, green: 0.47, blue: 0.55, alpha: 1.00)
            confirmSendingPopView.isHidden = true
            successPopView.isHidden = true
            let errMsg = wallet.commitPendingTransactionError()
            let alert = UIAlertController(title: "Create Transaction Error", message: errMsg, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
extension MyWalletSendVC: BeldexWalletDelegate {
    func beldexWalletRefreshed(_ wallet: BChatWalletWrapper) {
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
        }
    }
    func beldexWalletNewBlock(_ wallet: BChatWalletWrapper, currentHeight: UInt64) {
        self.currentBlockChainHeight = currentHeight
        self.daemonBlockChainHeight = wallet.daemonBlockChainHeight
    }
    private func postData(balance: String, history: TransactionHistory) {
//        let balance_modify = Helper.displayDigitsAmount(balance)
        DispatchQueue.main.async {
        }
    }
}

