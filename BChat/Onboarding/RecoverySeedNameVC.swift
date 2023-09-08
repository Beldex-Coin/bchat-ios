
// Copyright © 2022 Beldex. All rights reserved.

import UIKit

class RecoverySeedNameVC: BaseVC,UITextFieldDelegate {
    
    @IBOutlet weak var backgroundNameView: UIView!
    @IBOutlet weak var backgroundHeightView: UIView!
    @IBOutlet weak var backgroundDateView: UIView!
    @IBOutlet weak var userNametxt:UITextField!
    @IBOutlet weak var heighttxt:UITextField!
    @IBOutlet weak var datetxt:UITextField!
    @IBOutlet weak var nextRef:UIButton!
    let datePicker = DatePickerDialog()
    var seedPassing:String!
    private var data = NewWallet()
    private var recovery_seed = RecoverWallet(from: .seed)
    var dateHeight = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        self.title = "Restore from seed"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //Keyboard Done Option
        heighttxt.addDoneButtonKeybord()
        
        backgroundNameView.layer.cornerRadius = 10
        backgroundHeightView.layer.cornerRadius = 10
        backgroundDateView.layer.cornerRadius = 10
        nextRef.layer.cornerRadius = 6
        
        recovery_seed.seed = seedPassing
        userNametxt.attributedPlaceholder = NSAttributedString(string:"Display Name", attributes:[NSAttributedString.Key.foregroundColor: isLightMode ? UIColor.darkGray : UIColor.lightGray])
        heighttxt.attributedPlaceholder = NSAttributedString(string:"Restore from Blockheight", attributes:[NSAttributedString.Key.foregroundColor: isLightMode ? UIColor.darkGray : UIColor.lightGray])
        datetxt.attributedPlaceholder = NSAttributedString(string:"Restore from Date", attributes:[NSAttributedString.Key.foregroundColor: isLightMode ? UIColor.darkGray : UIColor.lightGray])
        userNametxt.delegate = self
        heighttxt.delegate = self
        datetxt.delegate = self
        heighttxt.keyboardType = .numberPad
        userNametxt.returnKeyType = .done
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        // Listen to keyboard notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillChangeFrameNotification(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    func datePickerTapped() {
        datePicker.show("Select Date",
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        maximumDate: Date(),
                        datePickerMode: .date) { [self] (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.datetxt.text = formatter.string(from: dt)
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "yyyy-MM"
                let finalDate = formatter2.string(from: dt)
                for element in DateHeight.getBlockHeight {
                    let fullNameArr = element.components(separatedBy: ":")
                    let dateString  = fullNameArr[0]
                    let heightString = fullNameArr[1]
                    if dateString == finalDate {
                        dateHeight = heightString
                    }
                }
            }
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.datetxt {
            datePickerTapped()
            return false
        }
        return true
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
        heighttxt.resignFirstResponder()
    }
    
    // MARK: Updating
    @objc private func handleKeyboardWillChangeFrameNotification(_ notification: Notification) {
        guard let newHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else { return }
    }
    
    @objc private func handleKeyboardWillHideNotification(_ notification: Notification) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == heighttxt){
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return (string == numberFiltered) && textLimit(existingText: textField.text,
                                                           newText: string,
                                                           limit: 9)
        }
        return true
    }
    func textLimit(existingText: String?,
                   newText: String,
                   limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    
    @IBAction func NextAction(sender:UIButton){
        func showError(title: String, message: String = "") {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
            presentAlert(alert)
        }
        let dateText = datetxt.text!
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
        if heighttxt.text!.isEmpty && datetxt.text!.isEmpty { //
            let displayName = heighttxt.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !displayName.isEmpty else {
                return showError(title: NSLocalizedString("restore height or date is missing", comment: ""))
            }
        }
        if heighttxt.text!.count >= 9 {
            let displayName = heighttxt.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !OWSProfileManager.shared().isProfileNameTooLong(displayName) else {
                return showError(title: NSLocalizedString("restore height is too long", comment: ""))
            }
        }
        if heighttxt.text!.isEmpty && datetxt.text != nil{
            if !dateHeight.isEmpty {
                SaveUserDefaultsData.WalletRestoreHeight = dateHeight
            }else {
                SaveUserDefaultsData.WalletRestoreHeight = ""
            }
            self.mnemonicSeedconnect()
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EnterPinVC") as! EnterPinVC
            navigationflowTag = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if userNametxt.text != "" && heighttxt.text != "" && datetxt.text != "" {
            showError(title: NSLocalizedString("enter either Restore height or Date", comment: ""))
        }
        if userNametxt.text != "" && heighttxt.text != nil && dateText == ""{ //
            SaveUserDefaultsData.WalletRestoreHeight = heighttxt.text!
            SaveUserDefaultsData.NameForWallet = userNametxt.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.mnemonicSeedconnect()
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EnterPinVC") as! EnterPinVC
            navigationflowTag = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            // Wallet Seed
            self.mnemonicSeedconnect()
            SaveUserDefaultsData.NameForWallet = userNametxt.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    func mnemonicSeedconnect() {
        self.alertWarningIfNeed(recovery_seed)
        let mnemonic = seedPassing!
        do {
            let hexEncodedSeed = try Mnemonic.decode(mnemonic: mnemonic)
            let seed = Data(hex: hexEncodedSeed)
            let (ed25519KeyPair, x25519KeyPair) = KeyPairUtilities.generate(from: seed)
            Onboarding.Flow.recover.preregister(with: seed, ed25519KeyPair: ed25519KeyPair, x25519KeyPair: x25519KeyPair)
            Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
            }
        } catch let error {
            let error = error as? Mnemonic.DecodingError ?? Mnemonic.DecodingError.generic
            showError(title: error.errorDescription!)
        }
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
        OWSProfileManager.shared().updateLocalProfileName(displayName, avatarImage: nil, success: { }, failure: { _ in }, requiresSync: false) // Try to save the user name but ignore the result
    }
    
    private func alertWarningIfNeed(_ recover: RecoverWallet) {
        guard recover.date == nil &&
                recover.block == nil
        else {
            self.createWallet(recover)
            return
        }
        self.createWallet(recover)
    }
    
    private func createWallet(_ recover: RecoverWallet) {
        SaveUserDefaultsData.WalletRecoverSeed = seedPassing!
        data.name = userNametxt.text!
        WalletService.shared.createWallet(with: .recovery(data: data, recover: recover)) { (result) in
            switch result {
            case .success(let wallet):
                wallet.close()
                print("sucecs in import")
            case .failure(_):
                print("faile in import")
            }
        }
    }
}
