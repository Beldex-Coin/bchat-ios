// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class WalletSendNewVC: UIViewController,UITextFieldDelegate {
    
    private lazy var topView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.cornerRadius = 16
        stackView.layer.borderColor = Colors.greenColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    private lazy var titleOfTotalBalanceLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("TOTAL_BALANCE", comment: "")
        result.textColor = UIColor.lightGray
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var beldexLogoImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_beldex", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    private lazy var beldexBalanceLabel: UILabel = {
        let result = UILabel()
        result.text = "3.333333"
        result.textColor = .white
        result.font = Fonts.boldOpenSans(ofSize: 24)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var middleView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    private lazy var bdxAmountTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("ENTER_BDX_AMOUNT", comment: "")
        result.textColor = UIColor.lightGray
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
        button.backgroundColor = Colors.blueColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(isFromMaxButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var bdxAmountTextField: UITextField = {
        let result = UITextField()
        result.delegate = self
        result.translatesAutoresizingMaskIntoConstraints = false
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("0.00000", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 16)
        result.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 10
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingView
        result.leftViewMode = .always
        result.layer.borderColor = UIColor.lightGray.cgColor
        result.layer.borderWidth = 0.5
        return result
    }()
    let isCurrencyNameTitleLabel = UILabel()
    private lazy var isCurrencyResultTitleLabel: UILabel = {
        let result = UILabel()
        result.text = "0.0000 USD"
        result.textColor = UIColor.lightGray
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
    private lazy var isFromScanOptionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: 0x282836)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.setImage(UIImage(named: "ic_QR_scan_send"), for: .normal)
        button.addTarget(self, action: #selector(isFromScanOptionButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var beldexAddressTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("BELDEX_ADDRESS", comment: "")
        result.textColor = .white
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var beldexAddressBgView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 12
        stackView.backgroundColor = Colors.backgroundViewColor2
        return stackView
    }()
    private lazy var beldexAddressIDLabel: UILabel = {
        let result = UILabel()
        result.text = "328632bdskhj839ehdnd92dddid83993ndasoaksjhpifyaoajscqitp98wkjhaiuahhashf9ahfsdfhasdf328632bdskhj839ehdnd92dddid83993ndasoaksjhpifyaoajscqitp98wkjhaiuahhashf9ahfsdfhasdf"
        result.textColor = Colors.greenColor
        result.font = Fonts.OpenSans(ofSize: 13)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    private lazy var transationPriorityTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("TRANSACTION_PRIORITY", comment: "")
        result.textColor = .white
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var flashPriorityButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("FLASH_BUTTON", comment: ""), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 12)
        button.backgroundColor = UIColor(hex: 0x282836)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }()
    private lazy var estimatedFeeBgView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = .clear
        stackView.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        stackView.layer.borderWidth = 0.5
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
        button.backgroundColor = UIColor(hex: 0x282836)
        button.setTitleColor(UIColor(hex: 0x6E6E7C), for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 18)
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Send"
        
        isCurrencyNameTitleLabel.text = "USD"
        isCurrencyNameTitleLabel.textColor = UIColor.white
        isCurrencyNameTitleLabel.font = Fonts.boldOpenSans(ofSize: 12)
        isCurrencyNameTitleLabel.textAlignment = .center
        isCurrencyNameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        isCurrencyNameTitleLabel.backgroundColor = UIColor(hex: 0x3A3A4B)
        isCurrencyNameTitleLabel.clipsToBounds = true
        
        view.addSubViews(topView)
        topView.addSubview(titleOfTotalBalanceLabel)
        topView.addSubview(beldexLogoImg)
        topView.addSubview(beldexBalanceLabel)
        view.addSubview(middleView)
        middleView.addSubview(bdxAmountTitleLabel)
        middleView.addSubview(isFromMaxButton)
        middleView.addSubview(bdxAmountTextField)
        middleView.addSubview(isCurrencyNameTitleLabel)
        middleView.addSubview(isCurrencyResultTitleLabel)
        middleView.addSubview(isFromAddressBookButton)
        middleView.addSubview(isFromScanOptionButton)
        middleView.addSubview(beldexAddressTitleLabel)
        middleView.addSubview(beldexAddressBgView)
        middleView.addSubview(beldexAddressIDLabel)
        middleView.addSubview(transationPriorityTitleLabel)
        middleView.addSubview(flashPriorityButton)
        middleView.addSubview(estimatedFeeBgView)
        middleView.addSubview(estimatedFeeIDLabel)
        view.addSubview(sendButton)
        
        flashPriorityButton.addRightIcon(image: UIImage(named: "ic_dropdownNew")!.withRenderingMode(.alwaysTemplate))
        flashPriorityButton.tintColor = .white
        
        let fullText = "Estimated Fee : 0.004596 BDX"  
        if let rangeBeldex = fullText.range(of: "Estimated Fee :"),
           let rangeAddress = fullText.range(of: "0.004596 BDX") {
            let attributedString = NSMutableAttributedString(string: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.lightGray, range: NSRange(rangeBeldex, in: fullText))
            attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(rangeAddress, in: fullText))
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
            bdxAmountTitleLabel.topAnchor.constraint(equalTo: middleView.topAnchor, constant: 32),
            bdxAmountTitleLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 26),
            bdxAmountTitleLabel.trailingAnchor.constraint(equalTo: middleView.trailingAnchor, constant: -20),
            isFromMaxButton.trailingAnchor.constraint(equalTo: middleView.trailingAnchor, constant: -20),
            isFromMaxButton.widthAnchor.constraint(equalToConstant: 68),
            isFromMaxButton.heightAnchor.constraint(equalToConstant: 53),
            isFromMaxButton.topAnchor.constraint(equalTo: bdxAmountTitleLabel.bottomAnchor, constant: 13),
            bdxAmountTextField.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 19),
            bdxAmountTextField.topAnchor.constraint(equalTo: bdxAmountTitleLabel.bottomAnchor, constant: 13),
            bdxAmountTextField.trailingAnchor.constraint(equalTo: isFromMaxButton.leadingAnchor, constant: -7),
            bdxAmountTextField.heightAnchor.constraint(equalToConstant: 53),
            isCurrencyNameTitleLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 19),
            isCurrencyNameTitleLabel.topAnchor.constraint(equalTo: bdxAmountTextField.bottomAnchor, constant: 15),
            isCurrencyNameTitleLabel.widthAnchor.constraint(equalToConstant: 53),
            isCurrencyNameTitleLabel.heightAnchor.constraint(equalToConstant: 25),
            isCurrencyResultTitleLabel.leadingAnchor.constraint(equalTo: isCurrencyNameTitleLabel.trailingAnchor, constant: 8),
            isCurrencyResultTitleLabel.centerYAnchor.constraint(equalTo: isCurrencyNameTitleLabel.centerYAnchor),
            isFromAddressBookButton.trailingAnchor.constraint(equalTo: middleView.trailingAnchor, constant: -20),
            isFromAddressBookButton.widthAnchor.constraint(equalToConstant: 32),
            isFromAddressBookButton.heightAnchor.constraint(equalToConstant: 32),
            isFromAddressBookButton.topAnchor.constraint(equalTo: isCurrencyResultTitleLabel.bottomAnchor, constant: 35),
            isFromScanOptionButton.trailingAnchor.constraint(equalTo: isFromAddressBookButton.leadingAnchor, constant: -7),
            isFromScanOptionButton.widthAnchor.constraint(equalToConstant: 32),
            isFromScanOptionButton.heightAnchor.constraint(equalToConstant: 32),
            isFromScanOptionButton.centerYAnchor.constraint(equalTo: isFromAddressBookButton.centerYAnchor),
            beldexAddressTitleLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 26),
            beldexAddressTitleLabel.centerYAnchor.constraint(equalTo: isFromScanOptionButton.centerYAnchor),
            beldexAddressTitleLabel.trailingAnchor.constraint(equalTo: isFromScanOptionButton.leadingAnchor, constant: -7),
            beldexAddressBgView.trailingAnchor.constraint(equalTo: middleView.trailingAnchor, constant: -20),
            beldexAddressBgView.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 19),
            beldexAddressBgView.topAnchor.constraint(equalTo: isFromAddressBookButton.bottomAnchor, constant: 13),
            beldexAddressIDLabel.topAnchor.constraint(equalTo: beldexAddressBgView.topAnchor, constant: 22),
            beldexAddressIDLabel.bottomAnchor.constraint(equalTo: beldexAddressBgView.bottomAnchor, constant: -22),
            beldexAddressIDLabel.leadingAnchor.constraint(equalTo: beldexAddressBgView.leadingAnchor, constant: 22),
            beldexAddressIDLabel.trailingAnchor.constraint(equalTo: beldexAddressBgView.trailingAnchor, constant: -22),
            transationPriorityTitleLabel.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 26),
            transationPriorityTitleLabel.topAnchor.constraint(equalTo: beldexAddressBgView.bottomAnchor, constant: 35),
            flashPriorityButton.leadingAnchor.constraint(equalTo: transationPriorityTitleLabel.trailingAnchor, constant: 10),
            flashPriorityButton.centerYAnchor.constraint(equalTo: transationPriorityTitleLabel.centerYAnchor),
            flashPriorityButton.heightAnchor.constraint(equalToConstant: 36),
            flashPriorityButton.widthAnchor.constraint(equalToConstant: 81),
            estimatedFeeBgView.trailingAnchor.constraint(equalTo: middleView.trailingAnchor, constant: -20),
            estimatedFeeBgView.leadingAnchor.constraint(equalTo: middleView.leadingAnchor, constant: 20),
            estimatedFeeBgView.topAnchor.constraint(equalTo: flashPriorityButton.bottomAnchor, constant: 35),
            estimatedFeeIDLabel.topAnchor.constraint(equalTo: estimatedFeeBgView.topAnchor, constant: 12),
            estimatedFeeIDLabel.bottomAnchor.constraint(equalTo: estimatedFeeBgView.bottomAnchor, constant: -12),
            estimatedFeeIDLabel.leadingAnchor.constraint(equalTo: estimatedFeeBgView.leadingAnchor, constant: 12),
            estimatedFeeIDLabel.trailingAnchor.constraint(equalTo: estimatedFeeBgView.trailingAnchor, constant: -12),
        ])
        NSLayoutConstraint.activate([
            sendButton.topAnchor.constraint(equalTo: middleView.bottomAnchor, constant: 44),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            sendButton.heightAnchor.constraint(equalToConstant: 58),
            sendButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
        ])
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        isCurrencyNameTitleLabel.layer.cornerRadius = isCurrencyNameTitleLabel.frame.height/2
    }
    
    // MARK: - Navigation
    @objc func isFromMaxButtonTapped(_ sender: UIButton){
        
    }
    
    @objc func isFromAddressBookButtonTapped(_ sender: UIButton){
        
    }
    
    @objc func isFromScanOptionButtonTapped(_ sender: UIButton){
        
    }
    
    @objc func sendButtonTapped(_ sender: UIButton){
        
    }
    
}
