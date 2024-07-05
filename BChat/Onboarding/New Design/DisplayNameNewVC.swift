// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import Sodium


class DisplayNameNewVC: BaseVC, UITextFieldDelegate {
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.boldOpenSans(ofSize: 22)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor5
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor3
        button.setTitleColor(Colors.buttonDisableColor, for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameTextField: UITextField = {
        let result = UITextField()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.placeholder = "Enter name"
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 16
        result.setLeftPaddingPoints(20)
        return result
    }()
    
    private var seed: Data! { didSet { updateKeyPair() } }
    private var ed25519KeyPair: Sign.KeyPair!
    private var x25519KeyPair: ECKeyPair! { didSet { updatePublicKeyLabel() } }
    private var data = NewWallet()
    var continueButtonYPosition = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        self.title = "Display Name"
        self.titleLabel.text = "Set your Display Name"
        self.subTitleLabel.text = "You can change it anytime :)"
        
        view.addSubViews(titleLabel)
        view.addSubViews(subTitleLabel)
        view.addSubViews(continueButton)
        view.addSubViews(nameTextField)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 39),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 21),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 23),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -23),
            nameTextField.heightAnchor.constraint(equalToConstant: 60),
            subTitleLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 11),
            subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
            continueButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        
        continueButton.backgroundColor = Colors.cellGroundColor3
        continueButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
        continueButton.isUserInteractionEnabled = false
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillChangeFrameNotification(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        continueButtonYPosition = UIScreen.main.bounds.height / 1.3
        continueButton.frame.origin.y = continueButtonYPosition
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Button Actions :-
    @objc private func continueButtonTapped() {
        self.performAction()
    }
    
    // MARK: Updating
    private func updateSeed(seedvalue: Data) {
        seed = seedvalue
    }
    
    private func updateKeyPair() {
        (ed25519KeyPair, x25519KeyPair) = KeyPairUtilities.generate(from: seed)
    }
    
    private func updatePublicKeyLabel() {
        let hexEncodedPublicKey = x25519KeyPair.hexEncodedPublicKey
        let characterCount = hexEncodedPublicKey.count
        var count = 0
        let limit = 32
        func animate() {
            let numberOfIndexesToShuffle = 32 - count
            let indexesToShuffle = (0..<characterCount).shuffled()[0..<numberOfIndexesToShuffle]
            var mangledHexEncodedPublicKey = hexEncodedPublicKey
            for index in indexesToShuffle {
                let startIndex = mangledHexEncodedPublicKey.index(mangledHexEncodedPublicKey.startIndex, offsetBy: index)
                let endIndex = mangledHexEncodedPublicKey.index(after: startIndex)
                mangledHexEncodedPublicKey.replaceSubrange(startIndex..<endIndex, with: "0123456789abcdef__".shuffled()[0..<1])
            }
            count += 1
            if count < limit {
                animate()
            } else {
                
            }
        }
        animate()
    }
    
    
    @objc func handleKeyboardWillChangeFrameNotification(_ notification: Notification) {
        let userInfo: [AnyHashable: Any] = (notification.userInfo ?? [:])
        let duration = ((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0)
        let curveValue: Int = ((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? Int(UIView.AnimationOptions.curveEaseInOut.rawValue))
        let options: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(curveValue << 16))
        let keyboardRect: CGRect = ((userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? CGRect.zero)
        let keyboardTop = (UIScreen.main.bounds.height - keyboardRect.minY)
        if keyboardTop <= 100 {
            continueButtonYPosition = UIScreen.main.bounds.height / 1.3
            continueButton.frame.origin.y = continueButtonYPosition
        } else {
            continueButtonYPosition = UIScreen.main.bounds.height / 2.9
            continueButton.frame.origin.y = continueButtonYPosition
        }
        
    }
    
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        let userInfo: [AnyHashable: Any] = (notification.userInfo ?? [:])
        let duration = ((userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0)
        let curveValue: Int = ((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? Int(UIView.AnimationOptions.curveEaseInOut.rawValue))
        let options: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: UInt(curveValue << 16))
        let keyboardRect: CGRect = ((userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? CGRect.zero)
        let keyboardTop = (UIScreen.main.bounds.height - keyboardRect.minY)
        
        continueButtonYPosition = UIScreen.main.bounds.height / 1.3
        continueButton.frame.origin.y = continueButtonYPosition
    }
    
    
    // MARK: General
    @objc private func dismissKeyboard() {
        nameTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  //if desired
        performAction()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let str = textField.text!
        if str.count == 0 {
            continueButton.backgroundColor = Colors.cellGroundColor3
            continueButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
            continueButton.isUserInteractionEnabled = false
        } else {
            continueButton.backgroundColor = Colors.bothGreenColor
            continueButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
            continueButton.isUserInteractionEnabled = true
        }
    }
    
    func performAction() {
        func showError(title: String, message: String = "") {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
            presentAlert(alert)
        }
        if nameTextField.text!.isEmpty {
            let displayName = nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !displayName.isEmpty else {
                return showError(title: NSLocalizedString("vc_display_name_display_name_missing_error", comment: ""))
            }
        }
        if nameTextField.text!.count >= 26 {
            let displayName = nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !OWSProfileManager.shared().isProfileNameTooLong(displayName) else {
                return showError(title: NSLocalizedString("vc_display_name_display_name_too_long_error", comment: ""))
            }
        }
        else {
            // MARK:- Beldex Wallet
            let uuid = UUID()
            data.name = nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            data.pwd = uuid.uuidString
            SaveUserDefaultsData.israndomUUIDPassword = uuid.uuidString
            WalletService.shared.createWallet(with: .new(data: data)) { (result) in
                switch result {
                case .success(let wallet):
                    wallet.close()
                case .failure(_):
                    print("in case failyre")
                }
            }
            let WalletpublicAddress = SaveUserDefaultsData.WalletpublicAddress
            let WalletSeed = SaveUserDefaultsData.WalletSeed
            SaveUserDefaultsData.NameForWallet = data.name
            let mnemonic = WalletSeed
            do {
                let hexEncodedSeed = try Mnemonic.decode(mnemonic: mnemonic)
                let seed = Data(hex: hexEncodedSeed)
                updateSeed(seedvalue: seed)
            } catch let error {
                print("Failure: \(error)")
                return
            }
            // Bchat Work
            Onboarding.Flow.register.preregister(with: seed, ed25519KeyPair: ed25519KeyPair, x25519KeyPair: x25519KeyPair)
            func showError(title: String, message: String = "") {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
                presentAlert(alert)
            }
            let displayName = nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !displayName.isEmpty else {
                return showError(title: NSLocalizedString("vc_display_name_display_name_missing_error", comment: ""))
            }
            guard !OWSProfileManager.shared().isProfileNameTooLong(displayName) else {
                return showError(title: NSLocalizedString("vc_display_name_display_name_too_long_error", comment: ""))
            }
            OWSProfileManager.shared().updateLocalProfileName(displayName, avatarImage: nil, success: {
            }, failure: { _ in }, requiresSync: false) // Try to save the user name but ignore the result
            
            let vc = RegisterVC()
            vc.userNameString = displayName
            vc.bchatIDString = x25519KeyPair.hexEncodedPublicKey
            vc.beldexAddressIDString = WalletpublicAddress
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}



