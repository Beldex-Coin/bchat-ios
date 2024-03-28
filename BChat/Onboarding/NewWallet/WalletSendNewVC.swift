// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import Alamofire
import BChatUIKit

class WalletSendNewVC: BaseVC,UITextFieldDelegate,UITextViewDelegate {
    
    private lazy var topView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.layer.cornerRadius = 16
        stackView.layer.borderColor = Colors.greenColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    private lazy var titleOfTotalBalanceLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("TOTAL_BALANCE", comment: "")
        result.textColor = Colors.cancelButtonTitleColor
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var beldexLogoImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_beldex_blackimg" : "ic_beldex"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    private lazy var beldexBalanceLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 24)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var paymentIDTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.greenColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.text = "Payment ID integrated"
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var paymentIDImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_payment_ID_Image" : "ic_payment_ID_Image"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    private lazy var middleView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    private lazy var beldexAmountTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("ENTER_BDX_AMOUNT", comment: "")
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var isFromMaxButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("MAX_BUTTON", comment: ""), for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothBlueColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(isFromMaxButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var beldexAmountTextField: UITextField = {
        let result = UITextField()
        result.delegate = self
        result.translatesAutoresizingMaskIntoConstraints = false
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("0.00000", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 16)
        result.layer.borderColor = Colors.borderColor.cgColor
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 10
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingView
        result.leftViewMode = .always
        result.layer.borderWidth = 1
        return result
    }()
    private lazy var isCurrencyResultTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.noDataLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var isFromAddressBookButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.greenColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.setImage(UIImage(named: "ic_addressBook_New"), for: .normal)
        button.addTarget(self, action: #selector(isFromAddressBookButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var isFromScanOptionButtonView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = Colors.scanButtonBackgroundColor
        return stackView
    }()
    private lazy var isFromScanOptionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        let logoImage = isLightMode ? "ic_scan_blackimage" : "ic_QR_scan_send"
        button.setImage(UIImage(named: logoImage), for: .normal)
        button.addTarget(self, action: #selector(isFromScanOptionButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var beldexAddressTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("BELDEX_ADDRESS", comment: "")
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var beldexAddressBgView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 12
        stackView.backgroundColor = Colors.cellGroundColor2
        return stackView
    }()
    private lazy var beldexAddressTextview: UITextView = {
        let result = UITextView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.textAlignment = .left
        result.textColor = Colors.greenColor
        result.font = Fonts.OpenSans(ofSize: 13)
        result.delegate = self
        result.backgroundColor = .clear
        return result
    }()
    private lazy var transationPriorityTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("TRANSACTION_PRIORITY", comment: "")
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var flashPriorityButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("FLASH_BUTTON", comment: ""), for: .normal)
        button.setTitleColor(Colors.aboutContentLabelColor, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 12)
        button.backgroundColor = Colors.cellGroundColor2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }()
    private lazy var estimatedFeeBgView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = .clear
        stackView.layer.borderColor = Colors.borderColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    private lazy var estimatedFeeIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor.white
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("ATTACHMENT_APPROVAL_SEND_BUTTON", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.backgroundViewColor
        button.setTitleColor(Colors.buttonTextColor, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 18)
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()
    
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
    var backAPI = false
    var hashArray = [RecipientDomainSchema]()
    var recipientAddressON = false
    var placeholderLabel : UILabel!
    var finalWalletAddress = ""
    var finalWalletAmount = ""
    var mainBalance = ""
    var feeValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorSocialGroup
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Send"
        
        view.addSubViews(topView)
        topView.addSubview(titleOfTotalBalanceLabel)
        topView.addSubview(beldexLogoImg)
        topView.addSubview(beldexBalanceLabel)
        view.addSubview(middleView)
        middleView.addSubview(beldexAmountTitleLabel)
        middleView.addSubview(isFromMaxButton)
        middleView.addSubview(beldexAmountTextField)
        middleView.addSubview(isCurrencyResultTitleLabel)
        middleView.addSubview(isFromAddressBookButton)
        middleView.addSubview(isFromScanOptionButtonView)
        isFromScanOptionButtonView.addSubview(isFromScanOptionButton)
        middleView.addSubview(beldexAddressTitleLabel)
        middleView.addSubview(beldexAddressBgView)
        beldexAddressBgView.addSubview(beldexAddressTextview)
        middleView.addSubview(paymentIDImg)
        middleView.addSubview(paymentIDTitleLabel)
        
        middleView.addSubview(transationPriorityTitleLabel)
        
        middleView.addSubview(flashPriorityButton)
        middleView.addSubview(estimatedFeeBgView)
        estimatedFeeBgView.addSubview(estimatedFeeIDLabel)
        view.addSubview(sendButton)
        
        flashPriorityButton.addRightIcon(image: UIImage(named: "ic_dropdownNew")!.withRenderingMode(.alwaysTemplate))
        flashPriorityButton.tintColor = isLightMode ? UIColor.lightGray : UIColor.white
        
        let fullText = "Estimated Fee : 0.004596 BDX"
        if let rangeBeldex = fullText.range(of: "Estimated Fee :"),
           let rangeAddress = fullText.range(of: "0.004596 BDX") {
            let attributedString = NSMutableAttributedString(string: fullText)
            attributedString.addAttribute(.foregroundColor, value: Colors.cancelButtonTitleColor, range: NSRange(rangeBeldex, in: fullText))
            attributedString.addAttribute(.foregroundColor, value: Colors.aboutContentLabelColor, range: NSRange(rangeAddress, in: fullText))
            estimatedFeeIDLabel.attributedText = attributedString
        }
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            titleOfTotalBalanceLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20),
            titleOfTotalBalanceLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
            beldexLogoImg.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
            beldexLogoImg.widthAnchor.constraint(equalToConstant: 18),
            beldexLogoImg.heightAnchor.constraint(equalToConstant: 18),
            beldexLogoImg.topAnchor.constraint(equalTo: titleOfTotalBalanceLabel.bottomAnchor, constant: 10),
            beldexBalanceLabel.leadingAnchor.constraint(equalTo: beldexLogoImg.trailingAnchor, constant: 10),
            beldexBalanceLabel.centerYAnchor.constraint(equalTo: beldexLogoImg.centerYAnchor),
            beldexBalanceLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -14),
            beldexBalanceLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -18),
        ])
        NSLayoutConstraint.activate([
            middleView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 18),
            middleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            middleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            beldexAmountTitleLabel.topAnchor.constraint(equalTo: middleView.topAnchor, constant: 32),
            beldexAmountTitleLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 26),
            beldexAmountTitleLabel.trailingAnchor.constraint(equalTo: middleView.trailingAnchor, constant: -20),
            isFromMaxButton.trailingAnchor.constraint(equalTo: middleView.trailingAnchor, constant: -20),
            isFromMaxButton.widthAnchor.constraint(equalToConstant: 68),
            isFromMaxButton.heightAnchor.constraint(equalToConstant: 53),
            isFromMaxButton.topAnchor.constraint(equalTo: beldexAmountTitleLabel.bottomAnchor, constant: 13),
            beldexAmountTextField.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 19),
            beldexAmountTextField.topAnchor.constraint(equalTo: beldexAmountTitleLabel.bottomAnchor, constant: 13),
            beldexAmountTextField.trailingAnchor.constraint(equalTo: isFromMaxButton.leadingAnchor, constant: -7),
            beldexAmountTextField.heightAnchor.constraint(equalToConstant: 53),
            isCurrencyResultTitleLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 19),
            isCurrencyResultTitleLabel.topAnchor.constraint(equalTo: beldexAmountTextField.bottomAnchor, constant: 15),
            isCurrencyResultTitleLabel.heightAnchor.constraint(equalToConstant: 25),
            isFromAddressBookButton.trailingAnchor.constraint(equalTo: middleView.trailingAnchor, constant: -20),
            isFromAddressBookButton.widthAnchor.constraint(equalToConstant: 32),
            isFromAddressBookButton.heightAnchor.constraint(equalToConstant: 32),
            isFromAddressBookButton.topAnchor.constraint(equalTo: isCurrencyResultTitleLabel.bottomAnchor, constant: 35),
            isFromScanOptionButtonView.trailingAnchor.constraint(equalTo: isFromAddressBookButton.leadingAnchor, constant: -7),
            isFromScanOptionButtonView.widthAnchor.constraint(equalToConstant: 32),
            isFromScanOptionButtonView.heightAnchor.constraint(equalToConstant: 32),
            isFromScanOptionButtonView.centerYAnchor.constraint(equalTo: isFromAddressBookButton.centerYAnchor),
            beldexAddressTitleLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 26),
            beldexAddressTitleLabel.centerYAnchor.constraint(equalTo: isFromScanOptionButtonView.centerYAnchor),
            beldexAddressTitleLabel.trailingAnchor.constraint(equalTo: isFromScanOptionButtonView.leadingAnchor, constant: -7),
            isFromScanOptionButton.heightAnchor.constraint(equalToConstant: 14),
            isFromScanOptionButton.widthAnchor.constraint(equalToConstant: 14),
            isFromScanOptionButton.centerYAnchor.constraint(equalTo: isFromScanOptionButtonView.centerYAnchor),
            isFromScanOptionButton.centerXAnchor.constraint(equalTo: isFromScanOptionButtonView.centerXAnchor),
            beldexAddressBgView.trailingAnchor.constraint(equalTo: middleView.trailingAnchor, constant: -20),
            beldexAddressBgView.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 19),
            beldexAddressBgView.topAnchor.constraint(equalTo: isFromAddressBookButton.bottomAnchor, constant: 13),
            beldexAddressBgView.heightAnchor.constraint(equalToConstant: 105),
            beldexAddressTextview.topAnchor.constraint(equalTo: beldexAddressBgView.topAnchor, constant: 18),
            beldexAddressTextview.bottomAnchor.constraint(equalTo: beldexAddressBgView.bottomAnchor, constant: -18),
            beldexAddressTextview.leadingAnchor.constraint(equalTo: beldexAddressBgView.leadingAnchor, constant: 22),
            beldexAddressTextview.trailingAnchor.constraint(equalTo: beldexAddressBgView.trailingAnchor, constant: -22),
          
            paymentIDImg.heightAnchor.constraint(equalToConstant: 15),
            paymentIDImg.widthAnchor.constraint(equalToConstant: 15),
            paymentIDImg.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 26),
            paymentIDImg.topAnchor.constraint(equalTo: beldexAddressBgView.bottomAnchor, constant: 5),
            
            paymentIDTitleLabel.leadingAnchor.constraint(equalTo: paymentIDImg.trailingAnchor, constant: 5),
            paymentIDTitleLabel.centerYAnchor.constraint(equalTo: paymentIDImg.centerYAnchor),
            
            transationPriorityTitleLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 26),
            transationPriorityTitleLabel.topAnchor.constraint(equalTo: beldexAddressBgView.bottomAnchor, constant: 35),
            flashPriorityButton.leadingAnchor.constraint(equalTo: transationPriorityTitleLabel.trailingAnchor, constant: 10),
            flashPriorityButton.centerYAnchor.constraint(equalTo: transationPriorityTitleLabel.centerYAnchor),
            flashPriorityButton.heightAnchor.constraint(equalToConstant: 36),
            flashPriorityButton.widthAnchor.constraint(equalToConstant: 81),
            estimatedFeeBgView.trailingAnchor.constraint(equalTo: middleView.trailingAnchor, constant: -20),
            estimatedFeeBgView.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 20),
            estimatedFeeBgView.topAnchor.constraint(equalTo: flashPriorityButton.bottomAnchor, constant: 35),
            estimatedFeeBgView.bottomAnchor.constraint(equalTo: middleView.bottomAnchor, constant: -35),
            estimatedFeeBgView.heightAnchor.constraint(equalToConstant: 44),
            estimatedFeeIDLabel.leadingAnchor.constraint(equalTo: estimatedFeeBgView.leadingAnchor, constant: 12),
            estimatedFeeIDLabel.trailingAnchor.constraint(equalTo: estimatedFeeBgView.trailingAnchor, constant: -12),
            estimatedFeeIDLabel.centerYAnchor.constraint(equalTo: estimatedFeeBgView.centerYAnchor),
            estimatedFeeIDLabel.centerXAnchor.constraint(equalTo: estimatedFeeBgView.centerXAnchor),
        ])
        NSLayoutConstraint.activate([
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            sendButton.heightAnchor.constraint(equalToConstant: 58),
            sendButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
        ])
        if !mainBalance.isEmpty{
            beldexBalanceLabel.text = mainBalance
        }else {
            beldexBalanceLabel.text = "-.----"
        }
        
        sendButton.backgroundColor = Colors.backgroundViewColor
        sendButton.setTitleColor(Colors.buttonTextColor, for: .normal)
        
        beldexAmountTextField.keyboardType = .decimalPad
        beldexAddressTextview.returnKeyType = .done
        beldexAmountTextField.tintColor = Colors.bchatButtonColor
        beldexAddressTextview.tintColor = Colors.bchatButtonColor
        //Keyboard Done Option
        beldexAmountTextField.addDoneButtonKeybord()
        self.placeHolderSeedLabel()
        
        if walletAddress != nil {
            placeholderLabel?.isHidden = true
            self.beldexAddressTextview.text = "\(walletAddress!)"
            updateSendButtonStates()
        }
        if walletAmount != nil {
            self.beldexAmountTextField.text = "\(walletAmount!)"
            self.bdxCurrencyValue = beldexAmountTextField.text!
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            fetchMarketsData(false)
            reloadData([:])
            updateSendButtonStates()
        }
        
        paymentIDImg.isHidden = true
        paymentIDTitleLabel.isHidden = true
        
        //Save Receipent Address fun developed In Local
        self.saveReceipeinetAddressOnAndOff()
        if !SaveUserDefaultsData.SelectedCurrency.isEmpty {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            isCurrencyResultTitleLabel.text = "0.00 \(self.currencyName.uppercased())"
        }else {
            isCurrencyResultTitleLabel.text = "0.00 USD"
        }
        
        // Dismiss keyboard on tap
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        // Notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleAddressSharingToSendScreen), name: Notification.Name("selectedAddressSharingToSendScreen"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleConfirmsendingOkeyButtonTapped), name: Notification.Name("confirmsendingButtonTapped"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleTransactionSuccessfulButtonTapped), name: Notification.Name("transactionSuccessfulButtonTapped"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleInitiatingTransactionTapped), name: Notification.Name("initiatingTransactionForWalletConnect"), object: nil)
        
    }
    
    @objc private func dismissKeyboard() {
        beldexAddressTextview.resignFirstResponder()
    }
    func placeHolderSeedLabel(){
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter Address or BNS name"
        placeholderLabel.font = Fonts.OpenSans(ofSize: 13)
        placeholderLabel.sizeToFit()
        beldexAddressTextview.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (beldexAddressTextview.font?.pointSize)! / 2)
        placeholderLabel.textColor = Colors.bchatPlaceholderColor
        placeholderLabel.isHidden = !beldexAddressTextview.text.isEmpty
    }
    override func viewDidAppear(_ animated: Bool) {
        if backAPI == true{
            let vc = InitiatingTransactionVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
            self.beldexAmountTextField.text = ""
            self.beldexAddressTextview.text = ""
        }
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.saveReceipeinetAddressOnAndOff()
        if backAPI == true{
            self.beldexAmountTextField.text = ""
            self.beldexAddressTextview.text = ""
            placeholderLabel?.isHidden = !beldexAddressTextview.text.isEmpty
            if !SaveUserDefaultsData.SelectedCurrency.isEmpty {
                self.currencyName = SaveUserDefaultsData.SelectedCurrency
                isCurrencyResultTitleLabel.text = "0.00 \(self.currencyName.uppercased())"
            }else {
                isCurrencyResultTitleLabel.text = "0.00 USD"
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.backAPI = false
    }
    
    //Here Address display
    @objc func handleAddressSharingToSendScreen(notification: NSNotification) {
        if let stringValue = notification.object as? NSObject {
            if let address = stringValue as? String{
                beldexAddressTextview.text! = address
                //Send Button userInteraction
                updateSendButtonStates()
            }
        }
    }
    private func updateSendButtonStates() {
        let isAddressValid = isValidAddress(beldexAddressTextview.text)
        let isAmountValid = isValidAmount(beldexAmountTextField.text)
        sendButton.isEnabled = isAddressValid && isAmountValid
        sendButton.backgroundColor = sendButton.isEnabled ? Colors.greenColor : Colors.backgroundViewColor
        sendButton.setTitleColor(sendButton.isEnabled ? UIColor.white : UIColor(hex: 0x6E6E7C), for: .normal)
    }
    private func isValidAddress(_ address: String?) -> Bool {
        // Add your validation logic for the address here
        // Example: Check if the address is not empty
        return !(address ?? "").isEmpty
    }
    private func isValidAmount(_ amount: String?) -> Bool {
        // Add your validation logic for the amount here
        // Example: Check if the amount is a valid decimal number
        guard let amountString = amount else {
            return false
        }
        return NSDecimalNumber(string: amountString).doubleValue > 0
    }
    
    //TextView Placholder delegates
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
        let currentAddress: NSString = beldexAddressTextview.text! as NSString
        if BChatWalletWrapper.validAddress(beldexAddressTextview.text!) {
            if currentAddress.length == 106 {
                paymentIDImg.isHidden = false
                paymentIDTitleLabel.isHidden = false
            }else{
                paymentIDImg.isHidden = true
                paymentIDTitleLabel.isHidden = true
            }
        }else{
            paymentIDImg.isHidden = true
            paymentIDTitleLabel.isHidden = true
        }
        updateSendButtonStates()
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
        return true
    }
    // txtamout only sigle . enter and txtaddress lenth fixed
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSendButtonStates()
        // Get the current text in the text field
        guard let currentText = beldexAmountTextField.text else {
            return true
        }
        // Calculate the future text if the user's input is accepted
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        // Use regular expression to validate the new text format
        let amountPattern = "^(\\d{0,9})(\\.\\d{0,5})?$"
        let amountTest = NSPredicate(format: "SELF MATCHES %@", amountPattern)
        return amountTest.evaluate(with: newText)
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
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if beldexAmountTextField.text!.count == 0 {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            isCurrencyResultTitleLabel.text = "0.00 \(self.currencyName.uppercased())"
            self.bdxCurrencyValue = beldexAmountTextField.text!
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            fetchMarketsData(false)
            reloadData([:])
        }else if beldexAmountTextField.text == "." {
            // print("---dot value entry----")
        }else {
            self.bdxCurrencyValue = beldexAmountTextField.text!
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            fetchMarketsData(false)
            reloadData([:])
        }
        //Send Button userInteraction
        updateSendButtonStates()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if beldexAmountTextField.text!.count == 0 {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            isCurrencyResultTitleLabel.text = "0.00 \(self.currencyName.uppercased())"
        }else if beldexAmountTextField.text == "." {
            // print("---dot value entry----")
        }else {
            self.bdxCurrencyValue = beldexAmountTextField.text!
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
            isCurrencyResultTitleLabel.text = "\(String(format:"%.4f",tax)) \(self.currencyName.uppercased())"
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
            let isFromfeeValue = BChatWalletWrapper.displayAmount(fee)
            feeValue = isFromfeeValue
            // Here dismiss with Initiating Transaction PopUp
            self.dismiss(animated: true)
            // Here display Confirm Sending PopUp
            DispatchQueue.main.async {
                let vc = ConfirmSendingVC()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.finalWalletAddress = self.finalWalletAddress
                vc.finalWalletAmount = self.finalWalletAmount
                vc.feeValue = self.feeValue
                self.present(vc, animated: true, completion: nil)
            }
        }else {
            let errMsg = wallet.commitPendingTransactionError()
            let alert = UIAlertController(title: "Create Transaction Error", message: errMsg, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    @objc func isFromMaxButtonTapped(_ sender: UIButton){
        beldexAmountTextField.text! = mainBalance
    }
    @objc func isFromAddressBookButtonTapped(_ sender: UIButton){
        let vc = WalletAddressBookNewVC()
        navigationController!.pushViewController(vc, animated: true)
    }
    @objc func isFromScanOptionButtonTapped(_ sender: UIButton){
        let vc = ScanNewVC()
        vc.isFromWallet = true
        vc.wallet = self.wallet
        navigationController!.pushViewController(vc, animated: true)
    }
    //send Transation Button Tapped 11
    @objc func sendButtonTapped(_ sender: UIButton){
        if beldexAddressTextview.text!.isEmpty || beldexAmountTextField.text!.isEmpty {
            let alert = UIAlertController(title: "My Wallet", message: "fill the all fileds", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if ((beldexAddressTextview.text.count > 106 || beldexAddressTextview.text.count < 95) && beldexAddressTextview.text.suffix(4).lowercased() != ".bdx") {
            let alert = UIAlertController(title: "My Wallet", message: "Invalid destination address", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
            let indexOfString = beldexAmountTextField.text!
            let lastString = beldexAmountTextField.text!.index(before: beldexAmountTextField.text!.endIndex)
            if beldexAmountTextField.text?.count == 0 {
                let alert = UIAlertController(title: "My Wallet", message: "Pls Enter amount", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else if beldexAmountTextField.text! == "." || Int(beldexAmountTextField.text!) == 0 || indexOfString.count > 16 || beldexAmountTextField.text![lastString] == "." {
                let alert = UIAlertController(title: "My Wallet", message: "Pls Enter Proper amount", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
                    self.finalWalletAddress = self.beldexAddressTextview.text!
                    self.finalWalletAmount = self.beldexAmountTextField.text!
                    let vc = NewPasswordVC()
                    vc.isGoingSendBDX = true
                    vc.isVerifyPassword = true
                    vc.wallet = self.wallet
                    vc.finalWalletAddress = self.finalWalletAddress
                    vc.finalWalletAmount = self.finalWalletAmount
                    navigationController!.pushViewController(vc, animated: true)
                } else {
                    self.showToastMsg(message: "Please check your internet connection", seconds: 1.0)
                }
            }
        }
    }
    
    //confirm sending Button Tapped 22
    @objc func handleConfirmsendingOkeyButtonTapped(notification: NSNotification) {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            let txid = self.wallet!.txid()
            let commitPendingTransaction = self.wallet!.commitPendingTransaction()
            if commitPendingTransaction == true {
                //Save Receipent Address fun developed In Local
                if recipientAddressON == true {
                    if !UserDefaults.standard.domainSchemas.isEmpty {
                        hashArray = UserDefaults.standard.domainSchemas
                        hashArray.append(.init(localhash: txid, localaddress: finalWalletAddress))
                        UserDefaults.standard.domainSchemas = hashArray
                    }else {
                        hashArray.append(.init(localhash: txid, localaddress: finalWalletAddress))
                        UserDefaults.standard.domainSchemas = hashArray
                    }
                }
                // Here dismiss with Confirm Sending PopUp
                self.dismiss(animated: true)
                // Here display Transaction Success PopUp
                let vc = WalletTransactionSuccessVC()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            self.showToastMsg(message: "Please check your internet connection", seconds: 1.0)
        }
    }
    
    //success Button Tapped 33
    @objc func handleTransactionSuccessfulButtonTapped(notification: NSNotification) {
        self.navigationController?.popToSpecificViewController(ofClass: WalletHomeNewVC.self, animated: true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "syncWallet"), object: nil)
    }
    
    @objc func handleInitiatingTransactionTapped(notification: NSNotification) {
        self.beldexAmountTextField.text = ""
        self.beldexAddressTextview.text = ""
        connect(wallet: self.wallet!)
    }
}

extension WalletSendNewVC: BeldexWalletDelegate {
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
        let balance_modify = Helper.displayDigitsAmount(balance)
        self.mainBalance = balance_modify
    }
}
