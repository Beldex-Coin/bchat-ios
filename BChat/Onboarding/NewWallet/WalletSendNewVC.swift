// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import Alamofire
import BChatUIKit

class WalletSendNewVC: BaseVC, UITextFieldDelegate, UITextViewDelegate, MyDataSendingDelegateProtocol {
    
    /// Top Background View
    private lazy var topBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.layer.cornerRadius = 16
        stackView.layer.borderColor = Colors.greenColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    /// Total Balance Title Label
    private lazy var totalBalanceTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("TOTAL_BALANCE", comment: "")
        result.textColor = Colors.cancelButtonTitleColor
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Beldex Logo Img
    lazy var beldexLogoImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_beldex_blackimg" : "ic_beldex"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Beldex Balance Label
    private lazy var beldexBalanceLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 24)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Payment ID Title Label
    private lazy var paymentIDTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.greenColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.text = "Payment ID integrated"
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Payment Id Image
    lazy var paymentIdImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_payment_ID_Image" : "ic_payment_ID_Image"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Middle Background View
    private lazy var middleBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    /// Beldex Amount Title Label
    private lazy var beldexAmountTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("ENTER_BDX_AMOUNT", comment: "")
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Max Button
    private lazy var maxButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("MAX_BUTTON", comment: ""), for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothBlueColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(maxButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Beldex Amount TextField
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
    
    /// Currency Result Title Label
    private lazy var currencyResultTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.noDataLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Address Book Button
    private lazy var addressBookButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.greenColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.setImage(UIImage(named: "ic_addressBook_New"), for: .normal)
        button.addTarget(self, action: #selector(addressBookButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Scan Option Background View
    private lazy var scanOptionBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = Colors.scanButtonBackgroundColor
        return stackView
    }()
    
    /// Scan Button
    private lazy var scanButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        let logoImage = isLightMode ? "ic_scan_blackimage" : "ic_QR_scan_send"
        button.setImage(UIImage(named: logoImage), for: .normal)
        button.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Beldex Address TitleLabel
    private lazy var beldexAddressTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("BELDEX_ADDRESS", comment: "")
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Beldex Address Background View
    private lazy var beldexAddressBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 12
        stackView.backgroundColor = Colors.cellGroundColor2
        return stackView
    }()
    
    /// Beldex Address Textview
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
    
    /// Transation Priority Title Label
    private lazy var transationPriorityTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("TRANSACTION_PRIORITY", comment: "")
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Flash Priority Button
    private lazy var flashPriorityButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("FLASH_BUTTON", comment: ""), for: .normal)
        button.setTitleColor(Colors.aboutContentLabelColor, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 12)
        button.backgroundColor = Colors.cellGroundColor2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
        let image = UIImage(named: "ic_dropdown_sendScreen")?.scaled(to: CGSize(width: 7.53, height: 4.5))
        button.setImage(image, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 24, bottom: 0, right: 0)
        return button
    }()
    
    
    lazy var feePriorityButtonsStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 0
        result.isLayoutMarginsRelativeArrangement = true
        result.layer.borderColor = Colors.borderColor.cgColor
        result.layer.borderWidth = 1
        result.layer.cornerRadius = 6
        return result
    }()
    
    private lazy var flashPriorityButtonInSideStackView: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("FLASH_BUTTON", comment: ""), for: .normal)
        button.setTitleColor(Colors.aboutContentLabelColor, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 12)
        button.backgroundColor = Colors.cellGroundColor2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(flashButtonInsideStackViewTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var slowPriorityButtonInSideStackView: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("SLOW_BUTTON", comment: ""), for: .normal)
        button.setTitleColor(Colors.aboutContentLabelColor, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 12)
        button.backgroundColor = Colors.cellGroundColor2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(slowButtonInsideStackViewTapped), for: .touchUpInside)
        return button
    }()
    
    /// Estimated Fee Background View
    private lazy var estimatedFeeBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = .clear
        stackView.layer.borderColor = Colors.borderColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    /// Estimated Fee ID Label
    private lazy var estimatedFeeIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor.white
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    /// Send Button
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
        
        let newBackButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(WalletSendNewVC.backHomeScreen(sender:)))
        newBackButton.image = UIImage(named: "NavBarBack")
        self.navigationItem.leftBarButtonItem = newBackButton
        
        view.addSubViews(topBackgroundView)
        topBackgroundView.addSubview(totalBalanceTitleLabel)
        topBackgroundView.addSubview(beldexLogoImg)
        topBackgroundView.addSubview(beldexBalanceLabel)
        view.addSubview(middleBackgroundView)
        middleBackgroundView.addSubview(beldexAmountTitleLabel)
        // don't delete below lines
        //middleBackgroundView.addSubview(maxButton)
        middleBackgroundView.addSubview(beldexAmountTextField)
        middleBackgroundView.addSubview(currencyResultTitleLabel)
        middleBackgroundView.addSubview(addressBookButton)
        middleBackgroundView.addSubview(scanOptionBackgroundView)
        scanOptionBackgroundView.addSubview(scanButton)
        middleBackgroundView.addSubview(beldexAddressTitleLabel)
        middleBackgroundView.addSubview(beldexAddressBackgroundView)
        beldexAddressBackgroundView.addSubview(beldexAddressTextview)
        middleBackgroundView.addSubview(paymentIdImage)
        middleBackgroundView.addSubview(paymentIDTitleLabel)
        middleBackgroundView.addSubview(transationPriorityTitleLabel)
        middleBackgroundView.addSubview(flashPriorityButton)
        middleBackgroundView.addSubview(estimatedFeeBackgroundView)
        estimatedFeeBackgroundView.addSubview(estimatedFeeIDLabel)
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            topBackgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            totalBalanceTitleLabel.topAnchor.constraint(equalTo: topBackgroundView.topAnchor, constant: 20),
            totalBalanceTitleLabel.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 18),
            beldexLogoImg.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 18),
            beldexLogoImg.widthAnchor.constraint(equalToConstant: 18),
            beldexLogoImg.heightAnchor.constraint(equalToConstant: 18),
            beldexLogoImg.topAnchor.constraint(equalTo: totalBalanceTitleLabel.bottomAnchor, constant: 10),
            beldexBalanceLabel.leadingAnchor.constraint(equalTo: beldexLogoImg.trailingAnchor, constant: 10),
            beldexBalanceLabel.centerYAnchor.constraint(equalTo: beldexLogoImg.centerYAnchor),
            beldexBalanceLabel.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -14),
            beldexBalanceLabel.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: -18),
        ])
        
        NSLayoutConstraint.activate([
            middleBackgroundView.topAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: 18),
            middleBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            middleBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            beldexAmountTitleLabel.topAnchor.constraint(equalTo: middleBackgroundView.topAnchor, constant: 20),
            beldexAmountTitleLabel.leadingAnchor.constraint(equalTo: middleBackgroundView.leadingAnchor, constant: 19),
            beldexAmountTitleLabel.trailingAnchor.constraint(equalTo: middleBackgroundView.trailingAnchor, constant: -19),
            // don't delete below lines
//            maxButton.trailingAnchor.constraint(equalTo: middleBackgroundView.trailingAnchor, constant: -19),
//            maxButton.widthAnchor.constraint(equalToConstant: 68),
//            maxButton.heightAnchor.constraint(equalToConstant: 53),
//            maxButton.topAnchor.constraint(equalTo: beldexAmountTitleLabel.bottomAnchor, constant: 13),
            beldexAmountTextField.leadingAnchor.constraint(equalTo: middleBackgroundView.leadingAnchor, constant: 19),
            beldexAmountTextField.topAnchor.constraint(equalTo: beldexAmountTitleLabel.bottomAnchor, constant: 13),
            beldexAmountTextField.trailingAnchor.constraint(equalTo: middleBackgroundView.trailingAnchor, constant: -19),
            beldexAmountTextField.heightAnchor.constraint(equalToConstant: 53),
            currencyResultTitleLabel.leadingAnchor.constraint(equalTo: middleBackgroundView.leadingAnchor, constant: 19),
            currencyResultTitleLabel.topAnchor.constraint(equalTo: beldexAmountTextField.bottomAnchor, constant: 15),
            currencyResultTitleLabel.heightAnchor.constraint(equalToConstant: 25),
            addressBookButton.trailingAnchor.constraint(equalTo: middleBackgroundView.trailingAnchor, constant: -19),
            addressBookButton.widthAnchor.constraint(equalToConstant: 32),
            addressBookButton.heightAnchor.constraint(equalToConstant: 32),
            addressBookButton.topAnchor.constraint(equalTo: currencyResultTitleLabel.bottomAnchor, constant: 25),
            scanOptionBackgroundView.trailingAnchor.constraint(equalTo: addressBookButton.leadingAnchor, constant: -7),
            scanOptionBackgroundView.widthAnchor.constraint(equalToConstant: 32),
            scanOptionBackgroundView.heightAnchor.constraint(equalToConstant: 32),
            scanOptionBackgroundView.centerYAnchor.constraint(equalTo: addressBookButton.centerYAnchor),
            beldexAddressTitleLabel.leadingAnchor.constraint(equalTo: middleBackgroundView.leadingAnchor, constant: 19),
            beldexAddressTitleLabel.centerYAnchor.constraint(equalTo: scanOptionBackgroundView.centerYAnchor),
            beldexAddressTitleLabel.trailingAnchor.constraint(equalTo: scanOptionBackgroundView.leadingAnchor, constant: -7),
            scanButton.heightAnchor.constraint(equalToConstant: 32),
            scanButton.widthAnchor.constraint(equalToConstant: 32),
            scanButton.centerYAnchor.constraint(equalTo: scanOptionBackgroundView.centerYAnchor),
            scanButton.centerXAnchor.constraint(equalTo: scanOptionBackgroundView.centerXAnchor),
            beldexAddressBackgroundView.trailingAnchor.constraint(equalTo: middleBackgroundView.trailingAnchor, constant: -19),
            beldexAddressBackgroundView.leadingAnchor.constraint(equalTo: middleBackgroundView.leadingAnchor, constant: 19),
            beldexAddressBackgroundView.topAnchor.constraint(equalTo: addressBookButton.bottomAnchor, constant: 13),
            beldexAddressBackgroundView.heightAnchor.constraint(equalToConstant: 105),
            beldexAddressTextview.topAnchor.constraint(equalTo: beldexAddressBackgroundView.topAnchor, constant: 18),
            beldexAddressTextview.bottomAnchor.constraint(equalTo: beldexAddressBackgroundView.bottomAnchor, constant: -18),
            beldexAddressTextview.leadingAnchor.constraint(equalTo: beldexAddressBackgroundView.leadingAnchor, constant: 19),
            beldexAddressTextview.trailingAnchor.constraint(equalTo: beldexAddressBackgroundView.trailingAnchor, constant: -22),
            paymentIdImage.heightAnchor.constraint(equalToConstant: 15),
            paymentIdImage.widthAnchor.constraint(equalToConstant: 15),
            paymentIdImage.leadingAnchor.constraint(equalTo: middleBackgroundView.leadingAnchor, constant: 19),
            paymentIdImage.topAnchor.constraint(equalTo: beldexAddressBackgroundView.bottomAnchor, constant: 5),
            paymentIDTitleLabel.leadingAnchor.constraint(equalTo: paymentIdImage.trailingAnchor, constant: 5),
            paymentIDTitleLabel.centerYAnchor.constraint(equalTo: paymentIdImage.centerYAnchor),
            transationPriorityTitleLabel.leadingAnchor.constraint(equalTo: middleBackgroundView.leadingAnchor, constant: 19),
            transationPriorityTitleLabel.topAnchor.constraint(equalTo: paymentIdImage.bottomAnchor, constant: 25),
            flashPriorityButton.leadingAnchor.constraint(equalTo: transationPriorityTitleLabel.trailingAnchor, constant: 10),
            flashPriorityButton.centerYAnchor.constraint(equalTo: transationPriorityTitleLabel.centerYAnchor),
            flashPriorityButton.heightAnchor.constraint(equalToConstant: 36),
            flashPriorityButton.widthAnchor.constraint(equalToConstant: 81),
            estimatedFeeBackgroundView.trailingAnchor.constraint(equalTo: middleBackgroundView.trailingAnchor, constant: -19),
            estimatedFeeBackgroundView.leadingAnchor.constraint(equalTo: middleBackgroundView.leadingAnchor, constant: 19),
            estimatedFeeBackgroundView.topAnchor.constraint(equalTo: flashPriorityButton.bottomAnchor, constant: 25),
            estimatedFeeBackgroundView.bottomAnchor.constraint(equalTo: middleBackgroundView.bottomAnchor, constant: -25),
            estimatedFeeBackgroundView.heightAnchor.constraint(equalToConstant: 44),
            estimatedFeeIDLabel.leadingAnchor.constraint(equalTo: estimatedFeeBackgroundView.leadingAnchor, constant: 12),
            estimatedFeeIDLabel.trailingAnchor.constraint(equalTo: estimatedFeeBackgroundView.trailingAnchor, constant: -12),
            estimatedFeeIDLabel.centerYAnchor.constraint(equalTo: estimatedFeeBackgroundView.centerYAnchor),
            estimatedFeeIDLabel.centerXAnchor.constraint(equalTo: estimatedFeeBackgroundView.centerXAnchor),
        ])
        
        view.addSubview(feePriorityButtonsStackView)
        feePriorityButtonsStackView.addArrangedSubview(flashPriorityButtonInSideStackView)
        feePriorityButtonsStackView.addArrangedSubview(slowPriorityButtonInSideStackView)
        
        
        NSLayoutConstraint.activate([
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            sendButton.heightAnchor.constraint(equalToConstant: 58),
            sendButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
            
            flashPriorityButtonInSideStackView.heightAnchor.constraint(equalToConstant: 36),
            flashPriorityButtonInSideStackView.widthAnchor.constraint(equalToConstant: 81),
            slowPriorityButtonInSideStackView.heightAnchor.constraint(equalToConstant: 36),
            slowPriorityButtonInSideStackView.widthAnchor.constraint(equalToConstant: 81),
            
            feePriorityButtonsStackView.bottomAnchor.constraint(equalTo: flashPriorityButton.topAnchor, constant: -6),
            feePriorityButtonsStackView.centerXAnchor.constraint(equalTo: flashPriorityButton.centerXAnchor)
            
        ])
        
        feePriorityButtonsStackView.isHidden = true
        
        if !mainBalance.isEmpty {
            beldexBalanceLabel.text = mainBalance
        } else {
            beldexBalanceLabel.text = "-.----"
        }
        
        // transation FeePriority values
        if !SaveUserDefaultsData.FeePriority.isEmpty {
            let val = SaveUserDefaultsData.FeePriority
            flashPriorityButton.setTitle(val, for: .normal)
            if val == "Flash" {
                flashPriorityValue()
            } else {
                slowPriorityValue()
            }
        } else {
            flashPriorityButton.setTitle("Flash", for: .normal)
            flashPriorityValue()
        }
        
        updateSendButtonStates()
        
        beldexAmountTextField.keyboardType = .decimalPad
        beldexAddressTextview.returnKeyType = .done
        beldexAmountTextField.tintColor = Colors.bchatButtonColor
        beldexAddressTextview.tintColor = Colors.bchatButtonColor
        beldexAddressTextview.delegate = self
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
        
        paymentIdImage.isHidden = true
        paymentIDTitleLabel.isHidden = true
        
        //Save Receipent Address fun developed In Local
        self.saveReceipeinetAddressOnAndOff()
        if !SaveUserDefaultsData.SelectedCurrency.isEmpty {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            currencyResultTitleLabel.text = "0.00 \(self.currencyName.uppercased())"
        } else {
            currencyResultTitleLabel.text = "0.00 USD"
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
    
    /// View did appear
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
    
    /// View will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.saveReceipeinetAddressOnAndOff()
        if backAPI == true {
            self.beldexAmountTextField.text = ""
            self.beldexAddressTextview.text = ""
            placeholderLabel?.isHidden = !beldexAddressTextview.text.isEmpty
            if !SaveUserDefaultsData.SelectedCurrency.isEmpty {
                self.currencyName = SaveUserDefaultsData.SelectedCurrency
                currencyResultTitleLabel.text = "0.00 \(self.currencyName.uppercased())"
            } else {
                currencyResultTitleLabel.text = "0.00 USD"
            }
            paymentIdImage.isHidden = true
            paymentIDTitleLabel.isHidden = true
        }
    }
    
    /// View will disappear
    override func viewWillDisappear(_ animated: Bool) {
        self.backAPI = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != self.feePriorityButtonsStackView && !feePriorityButtonsStackView.isHidden {
            feePriorityButtonsStackView.isHidden = true
        }
    }
    
    
    // transation FeePriority values
    func flashPriorityValue(){
        let fullText = "Estimated Fee : 0.040596 BDX"
        if let rangeBeldex = fullText.range(of: "Estimated Fee :"),
           let rangeAddress = fullText.range(of: "0.040596 BDX") {
            let attributedString = NSMutableAttributedString(string: fullText)
            attributedString.addAttribute(.foregroundColor, value: Colors.cancelButtonTitleColor, range: NSRange(rangeBeldex, in: fullText))
            attributedString.addAttribute(.foregroundColor, value: Colors.aboutContentLabelColor, range: NSRange(rangeAddress, in: fullText))
            estimatedFeeIDLabel.attributedText = attributedString
        }
    }
    
    func slowPriorityValue(){
        let fullText = "Estimated Fee : 0.013532 BDX"
        if let rangeBeldex = fullText.range(of: "Estimated Fee :"),
           let rangeAddress = fullText.range(of: "0.013532 BDX") {
            let attributedString = NSMutableAttributedString(string: fullText)
            attributedString.addAttribute(.foregroundColor, value: Colors.cancelButtonTitleColor, range: NSRange(rangeBeldex, in: fullText))
            attributedString.addAttribute(.foregroundColor, value: Colors.aboutContentLabelColor, range: NSRange(rangeAddress, in: fullText))
            estimatedFeeIDLabel.attributedText = attributedString
        }
    }
    
    @objc func backHomeScreen(sender: UIBarButtonItem) {
        self.navigationController?.popToSpecificViewController(ofClass: WalletHomeNewVC.self, animated: true)
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
        sendButton.isUserInteractionEnabled = sendButton.isEnabled
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
                paymentIdImage.isHidden = false
                paymentIDTitleLabel.isHidden = false
            } else {
                paymentIdImage.isHidden = true
                paymentIDTitleLabel.isHidden = true
            }
        } else {
            paymentIdImage.isHidden = true
            paymentIDTitleLabel.isHidden = true
        }
        updateSendButtonStates()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel?.isHidden = !textView.text.isEmpty
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
    
    func saveReceipeinetAddressOnAndOff() {
        if SaveUserDefaultsData.SaveReceipeinetSwitch == true {
            recipientAddressON = true
        } else {
            recipientAddressON = false
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if beldexAmountTextField.text!.count == 0 {
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            currencyResultTitleLabel.text = "0.00 \(self.currencyName.uppercased())"
            self.bdxCurrencyValue = beldexAmountTextField.text!
            self.currencyName = SaveUserDefaultsData.SelectedCurrency
            fetchMarketsData(false)
            reloadData([:])
        } else if beldexAmountTextField.text == "." {
            // print("---dot value entry----")
        } else {
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
            currencyResultTitleLabel.text = "0.00 \(self.currencyName.uppercased())"
        } else if beldexAmountTextField.text == "." {
            // print("---dot value entry----")
        } else {
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
            currencyResultTitleLabel.text = "\(String(format:"%.4f",tax)) \(self.currencyName.uppercased())"
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
        } else {
            self.dismiss(animated: true)
            DispatchQueue.main.async {
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
    
    // MARK: - Navigation
    @objc func maxButtonTapped(_ sender: UIButton) {
        beldexAmountTextField.text! = mainBalance
    }
    
    @objc func addressBookButtonTapped(_ sender: UIButton) {
        let vc = WalletAddressBookNewVC()
        vc.isGoingToSendScreen = true
        vc.delegate = self
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func scanButtonTapped(_ sender: UIButton) {
        let vc = ScanNewVC()
        vc.isFromWallet = true
        vc.wallet = self.wallet
        vc.mainBalanceForScan = beldexBalanceLabel.text!
        navigationController!.pushViewController(vc, animated: true)
    }
    
    //send Transation Button Tapped 11
    @objc func sendButtonTapped(_ sender: UIButton) {
        if beldexAddressTextview.text!.isEmpty || beldexAmountTextField.text!.isEmpty {
            let alert = UIAlertController(title: "My Wallet", message: "fill the all fileds", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if ((beldexAddressTextview.text.count > 106 || beldexAddressTextview.text.count < 95) && beldexAddressTextview.text.suffix(4).lowercased() != ".bdx") {
            let alert = UIAlertController(title: "My Wallet", message: "Invalid destination address", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OKEY_BUTTON", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let indexOfString = beldexAmountTextField.text!
            let lastString = beldexAmountTextField.text!.index(before: beldexAmountTextField.text!.endIndex)
            if beldexAmountTextField.text?.count == 0 {
                let alert = UIAlertController(title: NSLocalizedString("MY_WALLET_TITLE", comment: ""), message: NSLocalizedString("PLEASE_ENTER_AMOUNT_TEXT", comment: ""), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if beldexAmountTextField.text! == "." || Int(beldexAmountTextField.text!) == 0 || indexOfString.count > 16 || beldexAmountTextField.text![lastString] == "." {
                let alert = UIAlertController(title: NSLocalizedString("MY_WALLET_TITLE", comment: ""), message: NSLocalizedString("PLEASE_ENTER_PROPER_AMOUNT_TEXT", comment: ""), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OKEY_BUTTON", comment: ""), style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
                    self.finalWalletAddress = self.beldexAddressTextview.text!
                    self.finalWalletAmount = self.beldexAmountTextField.text!
                    let vc = NewPasswordVC()
                    vc.isGoingSendBDX = true
                    vc.isVerifyWalletPassword = true
                    vc.wallet = self.wallet
                    vc.finalWalletAddress = self.finalWalletAddress
                    vc.finalWalletAmount = self.finalWalletAmount
                    navigationController!.pushViewController(vc, animated: true)
                } else {
                    self.showToast(message: "Please check your internet connection", seconds: 1.0)
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
                    } else {
                        hashArray.append(.init(localhash: txid, localaddress: finalWalletAddress))
                        UserDefaults.standard.domainSchemas = hashArray
                    }
                }
                WalletSync.isInsideWallet = false
                // Here dismiss with Confirm Sending PopUp
                self.dismiss(animated: true)
                // Here display Transaction Success PopUp
                let vc = WalletTransactionSuccessVC()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            self.showToast(message: "Please check your internet connection", seconds: 1.0)
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
        paymentIdImage.isHidden = true
        paymentIDTitleLabel.isHidden = true
    }
    
    // Delegate Method get the beldex address
    func sendBeldexAddressToMyWalletSendVC(myData: String) {
        placeholderLabel?.isHidden = true
        self.beldexAddressTextview.text = myData
        updateSendButtonStates()
    }
    
    @objc func flashButtonTapped(_ sender: UIButton) {
        feePriorityButtonsStackView.isHidden = false
    }
    
    @objc func flashButtonInsideStackViewTapped(_ sender: UIButton) {
        flashPriorityButton.setTitle(NSLocalizedString("FLASH_BUTTON", comment: ""), for: .normal)
        flashPriorityValue()
        feePriorityButtonsStackView.isHidden = true
        SaveUserDefaultsData.FeePriority = "Flash"
    }
    
    @objc func slowButtonInsideStackViewTapped(_ sender: UIButton) {
        flashPriorityButton.setTitle(NSLocalizedString("SLOW_BUTTON", comment: ""), for: .normal)
        slowPriorityValue()
        feePriorityButtonsStackView.isHidden = true
        SaveUserDefaultsData.FeePriority = "Slow"
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
