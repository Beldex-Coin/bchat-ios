// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import UIKit

class DisplayNameNewVC: BaseVC {
    
    
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.boldOpenSans(ofSize: 22)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
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
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 18)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameTextField: UITextField = {
        let result = UITextField()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.placeholder = "Enter name"
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 16
        result.setLeftPaddingPoints(20)
        return result
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: 0x11111A)

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
        
        
    }

    
    // MARK: Button Actions :-
    @objc private func continueButtonTapped() {
        self.performAction()
        let vc = RegisterVC()
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    func performAction() {
//        func showError(title: String, message: String = "") {
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
//            presentAlert(alert)
//        }
//        if userNametxt.text!.isEmpty {
//            let displayName = userNametxt.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//            guard !displayName.isEmpty else {
//                return showError(title: NSLocalizedString("vc_display_name_display_name_missing_error", comment: ""))
//            }
//        }
//        if userNametxt.text!.count >= 26 {
//            let displayName = userNametxt.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//            guard !OWSProfileManager.shared().isProfileNameTooLong(displayName) else {
//                return showError(title: NSLocalizedString("vc_display_name_display_name_too_long_error", comment: ""))
//            }
//        }
//        else {
//            // MARK:- Beldex Wallet
//            let uuid = UUID()
//            data.name = userNametxt.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//            data.pwd = uuid.uuidString
//            SaveUserDefaultsData.israndomUUIDPassword = uuid.uuidString
//            WalletService.shared.createWallet(with: .new(data: data)) { (result) in
//                switch result {
//                case .success(let wallet):
//                    wallet.close()
//                case .failure(_):
//                    print("in case failyre")
//                }
//            }
//            let WalletpublicAddress = SaveUserDefaultsData.WalletpublicAddress
//            let WalletSeed = SaveUserDefaultsData.WalletSeed
//            SaveUserDefaultsData.NameForWallet = data.name
//            let mnemonic = WalletSeed
//            do {
//                let hexEncodedSeed = try Mnemonic.decode(mnemonic: mnemonic)
//                let seed = Data(hex: hexEncodedSeed)
//                updateSeed(seedvalue: seed)
//            } catch let error {
//                print("Failure: \(error)")
//                return
//            }
//            // Bchat Work
//            Onboarding.Flow.register.preregister(with: seed, ed25519KeyPair: ed25519KeyPair, x25519KeyPair: x25519KeyPair)
//            func showError(title: String, message: String = "") {
//                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
//                presentAlert(alert)
//            }
//            let displayName = userNametxt.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//            guard !displayName.isEmpty else {
//                return showError(title: NSLocalizedString("vc_display_name_display_name_missing_error", comment: ""))
//            }
//            guard !OWSProfileManager.shared().isProfileNameTooLong(displayName) else {
//                return showError(title: NSLocalizedString("vc_display_name_display_name_too_long_error", comment: ""))
//            }
//            OWSProfileManager.shared().updateLocalProfileName(displayName, avatarImage: nil, success: {
//            }, failure: { _ in }, requiresSync: false) // Try to save the user name but ignore the result
//
//            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DisplayBChatIDsVC") as! DisplayBChatIDsVC
//            vc.userNameString = displayName
//            vc.bchatIDString = x25519KeyPair.hexEncodedPublicKey
//            vc.beldexAddressIDString = WalletpublicAddress
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }

   
}




extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
