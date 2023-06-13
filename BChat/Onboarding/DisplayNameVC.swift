// Copyright © 2022 Beldex. All rights reserved.

import UIKit
import BChatUIKit
import Sodium

class DisplayNameVC: BaseVC,UITextFieldDelegate {
    private var seed: Data! { didSet { updateKeyPair() } }
    private var ed25519KeyPair: Sign.KeyPair!
    private var x25519KeyPair: ECKeyPair! { didSet { updatePublicKeyLabel() } }
    
    @IBOutlet weak var backgroungView:UIView!
    @IBOutlet weak var userNametxt:UITextField!
    @IBOutlet weak var nextRef:UIButton!
    private var data = NewWallet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Display Name"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backgroungView!.layer.cornerRadius = 10
        backgroungView!.layer.masksToBounds = true
        nextRef.layer.cornerRadius = 6
        userNametxt.attributedPlaceholder = NSAttributedString(string:"Enter a display name", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        userNametxt.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userNametxt.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: General
    @objc private func dismissKeyboard() {
        userNametxt.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  //if desired
        performAction()
        return true
    }

    func performAction() {
        func showError(title: String, message: String = "") {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
            presentAlert(alert)
        }
        if userNametxt.text!.isEmpty {
            let displayName = userNametxt.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !displayName.isEmpty else {
                return showError(title: NSLocalizedString("vc_display_name_display_name_missing_error", comment: ""))
            }
        }
        if userNametxt.text!.count >= 26 {
            let displayName = userNametxt.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !OWSProfileManager.shared().isProfileNameTooLong(displayName) else {
                return showError(title: NSLocalizedString("vc_display_name_display_name_too_long_error", comment: ""))
            }
        }
        else {
            // MARK:- Beldex Wallet
            data.name = userNametxt.text!
            // data.pwd = pwd.text!
            WalletService.shared.createWallet(with: .new(data: data)) { (result) in
                switch result {
                case .success(let wallet):
                    let seed = wallet.seed
                case .failure(_):
                    print("in case failyre")
                }
            }
            let WalletpublicAddress = UserDefaultsData.WalletpublicAddress
            let WalletSeed = UserDefaultsData.WalletSeed
            let mnemonic = WalletSeed
            do {
                let hexEncodedSeed = try Mnemonic.decode(mnemonic: mnemonic)
                let seed = Data(hex: hexEncodedSeed)
                updateSeed(seedvalue: seed)
            } catch let error {
                print("failsur")
            }
            // Bchat Work
            Onboarding.Flow.register.preregister(with: seed, ed25519KeyPair: ed25519KeyPair, x25519KeyPair: x25519KeyPair)
            func showError(title: String, message: String = "") {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
                presentAlert(alert)
            }
            let displayName = userNametxt.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !displayName.isEmpty else {
                return showError(title: NSLocalizedString("vc_display_name_display_name_missing_error", comment: ""))
            }
            guard !OWSProfileManager.shared().isProfileNameTooLong(displayName) else {
                return showError(title: NSLocalizedString("vc_display_name_display_name_too_long_error", comment: ""))
            }
            OWSProfileManager.shared().updateLocalProfileName(displayName, avatarImage: nil, success: {
            }, failure: { _ in }, requiresSync: false) // Try to save the user name but ignore the result

            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DisplayBChatIDsVC") as! DisplayBChatIDsVC
            vc.userNameString = displayName
            vc.bchatIDString = x25519KeyPair.hexEncodedPublicKey
            vc.beldexAddressIDString = WalletpublicAddress
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func NextAction(sender:UIButton){
        performAction()
    }
    
    
}
