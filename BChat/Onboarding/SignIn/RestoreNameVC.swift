// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class RestoreNameVC: BaseVC,UITextFieldDelegate {
    private var spacer1HeightConstraint: NSLayoutConstraint!
    private var spacer2HeightConstraint: NSLayoutConstraint!
    private var spacer3HeightConstraint: NSLayoutConstraint!
    private var spacer4HeightConstraint: NSLayoutConstraint!
    private var spacer5HeightConstraint: NSLayoutConstraint!
    private var spacer6HeightConstraint: NSLayoutConstraint!
    private var spacer7HeightConstraint: NSLayoutConstraint!
    private var spacer8HeightConstraint: NSLayoutConstraint!
    private var restoreButtonBottomOffsetConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    var isSelectedDate = false
    var seedPassing:String!
    var topStackView = UIStackView()
    var spacer1 = UIView()
    var spacer2 = UIView()
    var spacer3 = UIView()
    var spacer4 = UIView()
    var spacer5 = UIView()
    var spacer6 = UIView()
    var spacer7 = UIView()
    var spacer8 = UIView()
    
    let datePicker = DatePickerDialog()
    private var data = NewWallet()
    private var recovery_seed = RecoverWallet(from: .seed)
    var dateHeight = ""
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.text = NSLocalizedString("DISPLAY_NAME_NEW", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    private lazy var displayNameTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("ENTER_NAME_TITLE_NEW", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.layer.borderColor = Colors.text.cgColor
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.set(.height, to: 60)
        result.layer.cornerRadius = Values.buttonRadius
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingView
        result.leftViewMode = .always
        return result
    }()
    
    private lazy var restoreButton: UIButton = {
        let result = UIButton(type: .custom)
        result.setTitle(NSLocalizedString("RESTORE_NEW", comment: ""), for: .normal)
        result.titleLabel!.font = Fonts.regularOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(restoreButtonAction), for: .touchUpInside)
        result.layer.cornerRadius = Values.buttonRadius
        result.set(.height, to: 58)
        result.backgroundColor = Colors.cellGroundColor2
        result.setTitleColor(Colors.buttonDisableColor, for: .normal)
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Restore from seed"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setUpTopCornerRadius()
        view.backgroundColor = UIColor(hex: 0x11111A)
        recovery_seed.seed = seedPassing
        displayNameTextField.returnKeyType = .done
        displayNameTextField.delegate = self
        disableRestoreButton()
        
        // Set up spacers
        let topSpacer = UIView.vStretchingSpacer()
        spacer1HeightConstraint = spacer1.set(.height, to: isIPhone5OrSmaller ? Values.smallSpacing : Values.smallSpacing)
        spacer2HeightConstraint = spacer2.set(.height, to: isIPhone5OrSmaller ? Values.smallSpacing : Values.smallSpacing)
        spacer3HeightConstraint = spacer3.set(.height, to: isIPhone5OrSmaller ? Values.smallSpacing : Values.smallSpacing)
        spacer4HeightConstraint = spacer4.set(.height, to: isIPhone5OrSmaller ? Values.smallSpacing : Values.smallSpacing)
        spacer5HeightConstraint = spacer5.set(.height, to: isIPhone5OrSmaller ? Values.smallSpacing : Values.smallSpacing)
        spacer6HeightConstraint = spacer6.set(.height, to: isIPhone5OrSmaller ? Values.smallSpacing : Values.smallSpacing)
        spacer7HeightConstraint = spacer7.set(.height, to: isIPhone5OrSmaller ? Values.smallSpacing : Values.smallSpacing)
        spacer8HeightConstraint = spacer8.set(.height, to: isIPhone5OrSmaller ? Values.smallSpacing : Values.smallSpacing)
        let bottomSpacer = UIView.vStretchingSpacer()
        let registerButtonBottomOffsetSpacer = UIView()
        restoreButtonBottomOffsetConstraint = registerButtonBottomOffsetSpacer.set(.height, to: 33)
        
        // Set up register button container
        let restoreButtonContainer = UIView()
        restoreButtonContainer.addSubview(restoreButton)
        if UIDevice.current.isIPad {
            restoreButton.set(.width, to: Values.iPadButtonWidth)
            restoreButton.center(in: restoreButtonContainer)
        } else {
            restoreButton.pin(.leading, to: .leading, of: restoreButtonContainer, withInset: 21)
            restoreButtonContainer.pin(.trailing, to: .trailing, of: restoreButton, withInset: 21)
        }
        restoreButton.pin(.top, to: .top, of: restoreButtonContainer)
        restoreButtonContainer.pin(.bottom, to: .bottom, of: restoreButton)
        
        // Set up top stack view
        topStackView = UIStackView(arrangedSubviews: [ titleLabel, spacer1, displayNameTextField, spacer5, spacer6, spacer7, spacer2, spacer3, spacer4, spacer8 ])
        topStackView.axis = .vertical
        topStackView.alignment = .fill
        // Set up top stack view container
        let topStackViewContainer = UIView()
        topStackViewContainer.addSubview(topStackView)
        topStackView.pin(.leading, to: .leading, of: topStackViewContainer, withInset: 21)
        topStackView.pin(.top, to: .top, of: topStackViewContainer)
        topStackViewContainer.pin(.trailing, to: .trailing, of: topStackView, withInset: 21)
        topStackViewContainer.pin(.bottom, to: .bottom, of: topStackView)
        // Set up main stack view
        let mainStackView = UIStackView(arrangedSubviews: [ topSpacer, topStackViewContainer, bottomSpacer, restoreButtonContainer, registerButtonBottomOffsetSpacer ])
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        view.addSubview(mainStackView)
        mainStackView.pin(.leading, to: .leading, of: view)
        mainStackView.pin(.top, to: .top, of: view)
        mainStackView.pin(.trailing, to: .trailing, of: view)
        bottomConstraint = mainStackView.pin(.bottom, to: .bottom, of: view)
        topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor, multiplier: 0.1).isActive = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deleteAllWalletFiles()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func disableRestoreButton() {
        restoreButton.backgroundColor = Colors.cellGroundColor2
        restoreButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
        restoreButton.isUserInteractionEnabled = false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: General
    @objc private func dismissKeyboard() {
        displayNameTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkMandatoryFields()
    }
    
    func deleteAllWalletFiles() {
        let username = displayNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if username == "" {
            return
        }
        let documentDirectory = allPaths[0]
        let documentPath = documentDirectory + "/"
        let pathWithFileName = documentPath + username
        let pathWithFileKeys = documentPath + "\(username).keys"
        let pathWithFileAddress = documentPath + "\(username).address.txt"
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponentForFileName = url.appendingPathComponent("\(username)") {
            let filePath = pathComponentForFileName.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                try? FileManager.default.removeItem(atPath: "\(pathWithFileName)")
            }
        }
        if let pathComponentForFileKeys = url.appendingPathComponent("\(username).keys") {
            let filePath = pathComponentForFileKeys.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                try? FileManager.default.removeItem(atPath: "\(pathWithFileKeys)")
            }
        }
        if let pathComponentForFileAddress = url.appendingPathComponent("\(username).address.txt") {
            let filePath = pathComponentForFileAddress.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                try? FileManager.default.removeItem(atPath: "\(pathWithFileAddress)")
            }
        }
    }
    
    func checkMandatoryFields() {
        let displayNameText = displayNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if displayNameText.isEmpty {
            disableRestoreButton()
        } else {
            // All fields have valid values, proceed with your logic here
            restoreButton.isUserInteractionEnabled = true
            restoreButton.backgroundColor = Colors.bothGreenColor
            restoreButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textLimit(existingText: String?,
                   newText: String,
                   limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    
    func mnemonicSeedconnect() {
        self.alertWarningIfNeed(recovery_seed)
        let mnemonic = seedPassing!
        do {
            let hexEncodedSeed = try Mnemonic.decode(mnemonic: mnemonic)
            let seed = Data(hex: hexEncodedSeed)
            let (ed25519KeyPair, x25519KeyPair) = KeyPairUtilities.generate(from: seed)
            Onboarding.Flow.recover.preregister(with: seed, ed25519KeyPair: ed25519KeyPair, x25519KeyPair: x25519KeyPair)
        } catch let error {
            let error = error as? Mnemonic.DecodingError ?? Mnemonic.DecodingError.generic
            showError(title: error.errorDescription!)
        }
        func showError(title: String, message: String = "") {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
            presentAlert(alert)
        }
        let displayName = displayNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
        let uuid = UUID()
        data.name = displayNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        data.pwd = uuid.uuidString
        SaveUserDefaultsData.israndomUUIDPassword = uuid.uuidString
        WalletService.shared.createWallet(with: .recovery(data: data, recover: recover)) { (result) in
            switch result {
            case .success(let wallet):
                wallet.close()
            case .failure(_):
                print("in case failyre")
            }
        }
    }
    
    // MARK: - Navigation
    
    @objc private func restoreButtonAction() {
        func showError(title: String, message: String = "") {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
            presentAlert(alert)
        }
        if displayNameTextField.text!.isEmpty {
            let displayName = displayNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !displayName.isEmpty else {
                return showError(title: NSLocalizedString("vc_display_name_display_name_missing_error", comment: ""))
            }
        }
        if displayNameTextField.text!.count >= 26 {
            let displayName = displayNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !OWSProfileManager.shared().isProfileNameTooLong(displayName) else {
                return showError(title: NSLocalizedString("vc_display_name_display_name_too_long_error", comment: ""))
            }
        }
        if displayNameTextField.text != "" {
            SaveUserDefaultsData.WalletRestoreHeight = "0"
            SaveUserDefaultsData.NameForWallet = displayNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.mnemonicSeedconnect()
            let vc = NewPasswordVC()
            vc.isGoingHome = true
            vc.isCreatePassword = true
            navigationController!.pushViewController(vc, animated: true)
        }
    }
    
}

