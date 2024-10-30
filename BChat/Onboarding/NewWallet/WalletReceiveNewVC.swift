// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class WalletReceiveNewVC: BaseVC,UITextFieldDelegate {
    
    /// Share Button
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("SHARE_OPTION_NEW", comment: ""), for: .normal)
        let logoImage = isLightMode ? "ic_share_new" : "ic_share_new"
        let image = UIImage(named: logoImage)?.scaled(to: CGSize(width: 16, height: 16))
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 18)
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Top Background View
    private lazy var topBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    /// Beldex Address Background View
    private lazy var beldexAddressBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = Values.buttonRadius
        stackView.backgroundColor = Colors.cellGroundColor2
        return stackView
    }()
    
    /// Beldex Address Id Label
    private lazy var beldexAddressIdLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.OpenSans(ofSize: 13)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    /// Copy Button
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.bothGreenColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.setImage(UIImage(named: "ic_copy_white2"), for: .normal)
        button.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Beldex Address Title Label
    private lazy var beldexAddressTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("BELDEX_ADDRESS", comment: "")
        result.textColor = Colors.cancelButtonTitleColor1
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Beldex Amount TextField
    private lazy var beldexAmountTextField: UITextField = {
        let result = UITextField()
        result.delegate = self
        result.translatesAutoresizingMaskIntoConstraints = false
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("0.00000", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: Colors.noDataLabelColor])
        result.font = Fonts.OpenSans(ofSize: 16)
        result.layer.borderColor = Colors.borderColor.cgColor
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = Values.buttonRadius
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingView
        result.leftViewMode = .always
        result.layer.borderColor = Colors.borderColorNew.cgColor
        result.layer.borderWidth = 1
        return result
    }()
    
    /// Bdx Amount Title Label
    private lazy var bdxAmountTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("ENTER_BDX_AMOUNT", comment: "")
        result.textColor = Colors.cancelButtonTitleColor1
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Qr Code Background View
    private lazy var qrCodebackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = Values.buttonRadius
        stackView.backgroundColor = Colors.qrCodeBackgroundColor
        return stackView
    }()
    
    /// Qr Code Image
    private lazy var qrCodeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorSocialGroup
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Receive"
        
        view.addSubview(topBackgroundView)
        topBackgroundView.addSubview(beldexAddressBackgroundView)
        beldexAddressBackgroundView.addSubview(beldexAddressIdLabel)
        topBackgroundView.addSubview(copyButton)
        topBackgroundView.addSubview(beldexAddressTitleLabel)
        topBackgroundView.addSubview(beldexAmountTextField)
        topBackgroundView.addSubview(bdxAmountTitleLabel)
        topBackgroundView.addSubview(qrCodebackgroundView)
        qrCodebackgroundView.addSubview(qrCodeImage)
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            topBackgroundView.bottomAnchor.constraint(equalTo: shareButton.topAnchor, constant: -25),
            beldexAddressBackgroundView.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: -40),
            beldexAddressBackgroundView.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 19),
            beldexAddressBackgroundView.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -19),
            beldexAddressIdLabel.topAnchor.constraint(equalTo: beldexAddressBackgroundView.topAnchor, constant: 22),
            beldexAddressIdLabel.bottomAnchor.constraint(equalTo: beldexAddressBackgroundView.bottomAnchor, constant: -22),
            beldexAddressIdLabel.leadingAnchor.constraint(equalTo: beldexAddressBackgroundView.leadingAnchor, constant: 22),
            beldexAddressIdLabel.trailingAnchor.constraint(equalTo: beldexAddressBackgroundView.trailingAnchor, constant: -22),
            copyButton.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -20),
            copyButton.widthAnchor.constraint(equalToConstant: 32),
            copyButton.heightAnchor.constraint(equalToConstant: 32),
            copyButton.bottomAnchor.constraint(equalTo: beldexAddressBackgroundView.topAnchor, constant: -15),
            beldexAddressTitleLabel.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 26),
            beldexAddressTitleLabel.centerYAnchor.constraint(equalTo: copyButton.centerYAnchor),
            beldexAddressTitleLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -7),
            beldexAmountTextField.bottomAnchor.constraint(equalTo: copyButton.topAnchor, constant: -20),
            beldexAmountTextField.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 19),
            beldexAmountTextField.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -19),
            beldexAmountTextField.heightAnchor.constraint(equalToConstant: 53),
            bdxAmountTitleLabel.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 26),
            bdxAmountTitleLabel.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -7),
            bdxAmountTitleLabel.bottomAnchor.constraint(equalTo: beldexAmountTextField.topAnchor, constant: -10),
            qrCodebackgroundView.widthAnchor.constraint(equalToConstant: 190),
            qrCodebackgroundView.heightAnchor.constraint(equalToConstant: 190),
            qrCodebackgroundView.centerXAnchor.constraint(equalTo: topBackgroundView.centerXAnchor),
            qrCodebackgroundView.bottomAnchor.constraint(equalTo: bdxAmountTitleLabel.topAnchor, constant: -35),
            qrCodebackgroundView.centerYAnchor.constraint(equalTo: topBackgroundView.firstBaselineAnchor, constant: 25),
            qrCodeImage.topAnchor.constraint(equalTo: qrCodebackgroundView.topAnchor, constant: 20),
            qrCodeImage.bottomAnchor.constraint(equalTo: qrCodebackgroundView.bottomAnchor, constant: -20),
            qrCodeImage.leadingAnchor.constraint(equalTo: qrCodebackgroundView.leadingAnchor, constant: 20),
            qrCodeImage.trailingAnchor.constraint(equalTo: qrCodebackgroundView.trailingAnchor, constant: -20),
        ])
        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90),
            shareButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        beldexAmountTextField.addTarget(self, action: #selector(onAmountChange), for: .editingChanged)
        beldexAmountTextField.delegate = self
        beldexAmountTextField.keyboardType = .decimalPad
        beldexAmountTextField.tintColor = Colors.bothGreenColor
        //Keyboard Done Option
        beldexAmountTextField.addDoneButtonKeybord()
        if !SaveUserDefaultsData.WalletpublicAddress.isEmpty {
            beldexAddressIdLabel.text = SaveUserDefaultsData.WalletpublicAddress
        }
        qrCodeImage.image = UIImage.generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)" + "?amount=\(beldexAmountTextField.text!)")
        qrCodeImage.contentMode = .scaleAspectFit
        
        let dismiss: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismiss)
    }
    
    // MARK: - Navigation
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    // txtamout only sigle . enter
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
    
    @objc private func onAmountChange(_ textField: UITextField) {
        updateQRCode()
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateQRCode()
    }
    
    func updateQRCode(){
        if beldexAmountTextField.text!.count == 0 {
            shareButton.isUserInteractionEnabled = false
            shareButton.backgroundColor = Colors.backgroundViewColor
            shareButton.setTitleColor(.white, for: .normal)
            qrCodeImage.image = UIImage.generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)" + "?amount=\(beldexAmountTextField.text!)")
            qrCodeImage.contentMode = .scaleAspectFit
        } else {
            shareButton.isUserInteractionEnabled = true
            shareButton.backgroundColor = Colors.bothGreenColor
            shareButton.setTitleColor(.white, for: .normal)
            if let mystring = beldexAmountTextField.text {
                qrCodeImage.image = UIImage.generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)" + "?amount=\(mystring)")
            } else {
                qrCodeImage.image = UIImage.generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)")
            }
        }
    }
    
    @objc func shareButtonTapped(_ sender: UIButton) {
        
        guard let amount =  beldexAmountTextField.text else { return }
        let amountText = amount.isEmpty ? "" : "?amount=\(beldexAmountTextField.text!)"
        let qrCode = UIImage.generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)" + amountText)
        let shareVC = UIActivityViewController(activityItems: [ qrCode! ], applicationActivities: nil)
        self.navigationController!.present(shareVC, animated: true, completion: nil)
        
        // don't delete the below lines
//        if beldexAmountTextField.text!.isEmpty {
//            amountValidationAlert()
//        }else {
//            let indexOfString = beldexAmountTextField.text!
//            let lastString = beldexAmountTextField.text!.index(before: beldexAmountTextField.text!.endIndex)
//            if beldexAmountTextField.text?.count == 0 {
//                amountValidationAlert()
//            }
//            else if beldexAmountTextField.text! == "." || Int(beldexAmountTextField.text!) == 0 || indexOfString.count
//                        > 16 || beldexAmountTextField.text![lastString] == "." {
//                properAmountValidationAlert()
//            }else {
//                let qrCode = UIImage.generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)" + "?amount=\(beldexAmountTextField.text!)")
//                let shareVC = UIActivityViewController(activityItems: [ qrCode! ], applicationActivities: nil)
//                self.navigationController!.present(shareVC, animated: true, completion: nil)
//            }
//        }
    }
    
    func amountValidationAlert(){
        let alert = UIAlertController(title: NSLocalizedString("MY_WALLET_TITLE", comment: ""), message: NSLocalizedString("PLEASE_ENTER_AMOUNT_TEXT", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OKEY_BUTTON", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func properAmountValidationAlert(){
        let alert = UIAlertController(title: NSLocalizedString("MY_WALLET_TITLE", comment: ""), message: NSLocalizedString("PLEASE_ENTER_PROPER_AMOUNT_TEXT", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OKEY_BUTTON", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func copyButtonTapped(_ sender: UIButton){
        UIPasteboard.general.string = "\(SaveUserDefaultsData.WalletpublicAddress)"
        self.showToast(message: NSLocalizedString("BELDEX_ADDRESS_COPIED_NEW", comment: ""), seconds: 1.0)
    }
    
}
