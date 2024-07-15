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
        result.font = Fonts.OpenSans(ofSize: 14)
        result.text = NSLocalizedString("DISPLAY_NAME_NEW", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    private lazy var restoreTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = Fonts.OpenSans(ofSize: 14)
        result.text = NSLocalizedString("RESTORE_HEIGHT_TITLE_NEW", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    private lazy var dateTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = Fonts.OpenSans(ofSize: 14)
        result.text = NSLocalizedString("RESTORE_DATE_TITLE_NEW", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    private lazy var displayNameTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("ENTER_NAME_TITLE_NEW", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 12)
        result.layer.borderColor = Colors.text.cgColor
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.set(.height, to: 60)
        result.layer.cornerRadius = 16
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingView
        result.leftViewMode = .always
        return result
    }()
    private lazy var restoreHeightTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("RESTORE_BLOCK_HEIGHT_NEW", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 12)
        result.layer.borderColor = Colors.text.cgColor
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.set(.height, to: 60)
        result.layer.cornerRadius = 16
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingView
        result.leftViewMode = .always
        return result
    }()
    private lazy var restoreDateHeightTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("ENTER_DATE_NEW", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 12)
        result.layer.borderColor = Colors.text.cgColor
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.set(.height, to: 60)
        result.layer.cornerRadius = 16
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingViewLeft
        result.leftViewMode = .always
        // Create an UIImageView and set its image
        let imageView = UIImageView(image: UIImage(named: "ic_calenderNew"))
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // Adjust the frame as needed
        imageView.contentMode = .scaleAspectFit // Set the content mode as needed
        // Add tap gesture recognizer to the imageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        // Add some padding between the image and the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        result.rightView = paddingView
        result.rightViewMode = .always
        // Set the rightView of the TextField to the created UIImageView
        result.rightView?.addSubview(imageView)
        return result
    }()
    private lazy var isRestoreFromDateButton: UIButton = {
        let result = UIButton(type: .custom)
        result.setTitle(NSLocalizedString("RESTORE_DATE_TITLE_SPACE_NEW", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.OpenSans(ofSize: isIPhone5OrSmaller ? 12 : 12)
        result.addTarget(self, action: #selector(isRestoreFromDateButtonAction), for: UIControl.Event.touchUpInside)
        // Set the image
        let image = UIImage(named: "ic_calendar")?.withRenderingMode(.alwaysTemplate)
        result.setImage(image, for: .normal)
        result.tintColor = .white
        result.backgroundColor = Colors.bchatmeassgeReq
        result.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 9)
        result.layer.cornerRadius = result.frame.height/2
        result.set(.height, to: 39)
        result.set(.width, to: 189)
        return result
    }()
    private lazy var isRestoreFromDateViewContainer: UIStackView = {
        let result = UIStackView()
        result.axis = .horizontal
        result.spacing = -35
        result.distribution = .fillEqually
        if (UIDevice.current.isIPad) {
            result.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            result.isLayoutMarginsRelativeArrangement = true
        }
        return result
    }()
    private lazy var restoreButton: UIButton = {
        let result = UIButton(type: .custom)
        result.setTitle(NSLocalizedString("RESTORE_NEW", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: isIPhone5OrSmaller ? 18 : 18)
        result.addTarget(self, action: #selector(restoreButtonAction), for: UIControl.Event.touchUpInside)
        result.layer.cornerRadius = 16
        result.set(.height, to: 58)
        result.backgroundColor = Colors.cellGroundColor3
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
        restoreHeightTextField.delegate = self
        restoreDateHeightTextField.delegate = self
        restoreHeightTextField.keyboardType = .numberPad
        disableRestoreButton()
        
        isRestoreFromDateButton.addRightIcon(image: UIImage(named: "ic-Newarrow")!.withRenderingMode(.alwaysTemplate))
        isRestoreFromDateButton.tintColor = .white
        
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
        
        let emptyViewContainer = UIView()
        isRestoreFromDateViewContainer.addArrangedSubview(emptyViewContainer)
        isRestoreFromDateViewContainer.addArrangedSubview(isRestoreFromDateButton)
        
        // Set up top stack view
        topStackView = UIStackView(arrangedSubviews: [ titleLabel, spacer1, displayNameTextField, spacer5, spacer6, spacer7, spacer2, restoreTitleLabel, spacer3, restoreHeightTextField, spacer4, spacer8, isRestoreFromDateViewContainer ])
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
        isRestoreFromDateButton.layer.cornerRadius = isRestoreFromDateButton.bounds.height / 2
    }
    
    func disableRestoreButton() {
        restoreButton.backgroundColor = Colors.cellGroundColor3
        restoreButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
        restoreButton.isUserInteractionEnabled = false
    }
    
    func datePickerTapped() {
        datePicker.show(NSLocalizedString("SELECT_DATE__TITLE_NEW", comment: ""),
                        doneButtonTitle: NSLocalizedString("DONE_BUTTON_NEW", comment: ""),
                        cancelButtonTitle: NSLocalizedString("CANECEL_BUTTON_NEW", comment: ""),
                        maximumDate: Date(),
                        datePickerMode: .date) { [self] (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone(identifier: "UTC")
                self.restoreDateHeightTextField.text = formatter.string(from: dt)
                checkMandatoryFields()
                let dateString = formatter.string(from: dt)
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
        if textField == self.restoreDateHeightTextField {
            datePickerTapped()
            return false
        }
        return true
    }
    
    @objc func imageViewTapped() {
        // Handle the tap on the imageView here
        datePickerTapped()
    }
    
    // MARK: General
    @objc private func dismissKeyboard() {
        displayNameTextField.resignFirstResponder()
        restoreHeightTextField.resignFirstResponder()
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
        let restoreHeightText = restoreHeightTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let restoreDateHeightText = restoreDateHeightTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if displayNameText.isEmpty {
            disableRestoreButton()
        } else if restoreHeightText.isEmpty && restoreDateHeightText.isEmpty {
            disableRestoreButton()
        } else {
            // All fields have valid values, proceed with your logic here
            restoreButton.isUserInteractionEnabled = true
            restoreButton.backgroundColor = Colors.bothGreenColor
            restoreButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == restoreHeightTextField){
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

    @objc private func isRestoreFromDateButtonAction() {
        isRestoreFromDateButton.isSelected = !isRestoreFromDateButton.isSelected
        if isRestoreFromDateButton.isSelected {
            isRestoreFromDateButton.setTitle(NSLocalizedString("RESTORE_FROM_HEIGHT_SPACE_NEW", comment: ""), for: UIControl.State.normal)
            let image = UIImage(named: "ic_restoreHeight")?.withRenderingMode(.alwaysTemplate)
            isRestoreFromDateButton.setImage(image, for: .normal)
            restoreTitleLabel.text = "Pick a Date"
            restoreTitleLabel.isHidden = true
            restoreHeightTextField.isHidden = true
            dateTitleLabel.isHidden = false
            restoreDateHeightTextField.isHidden = false
            topStackView.addArrangedSubview(titleLabel)
            topStackView.addArrangedSubview(spacer1)
            topStackView.addArrangedSubview(displayNameTextField)
            topStackView.addArrangedSubview(spacer2)
            topStackView.addArrangedSubview(spacer5)
            topStackView.addArrangedSubview(spacer6)
            topStackView.addArrangedSubview(spacer7)
            topStackView.addArrangedSubview(dateTitleLabel)
            topStackView.addArrangedSubview(spacer3)
            topStackView.addArrangedSubview(restoreDateHeightTextField)
            topStackView.addArrangedSubview(spacer4)
            topStackView.addArrangedSubview(spacer8)
            topStackView.addArrangedSubview(isRestoreFromDateViewContainer)
        } else {
            isRestoreFromDateButton.setTitle(NSLocalizedString("RESTORE_DATE_TITLE_SPACE_NEW", comment: ""), for: UIControl.State.normal)
            let image = UIImage(named: "ic_calendar")?.withRenderingMode(.alwaysTemplate)
            isRestoreFromDateButton.setImage(image, for: .normal)
            restoreTitleLabel.text = NSLocalizedString("RESTORE_HEIGHT_TITLE_NEW", comment: "")
            restoreDateHeightTextField.resignFirstResponder()
            dateTitleLabel.isHidden = true
            restoreDateHeightTextField.isHidden = true
            restoreTitleLabel.isHidden = false
            restoreHeightTextField.isHidden = false
            topStackView.addArrangedSubview(titleLabel)
            topStackView.addArrangedSubview(spacer1)
            topStackView.addArrangedSubview(displayNameTextField)
            topStackView.addArrangedSubview(spacer2)
            topStackView.addArrangedSubview(spacer5)
            topStackView.addArrangedSubview(spacer6)
            topStackView.addArrangedSubview(spacer7)
            topStackView.addArrangedSubview(restoreTitleLabel)
            topStackView.addArrangedSubview(spacer3)
            topStackView.addArrangedSubview(restoreHeightTextField)
            topStackView.addArrangedSubview(spacer4)
            topStackView.addArrangedSubview(spacer8)
            topStackView.addArrangedSubview(isRestoreFromDateViewContainer)
        }
    }
    
    @objc private func restoreButtonAction() {
        func showError(title: String, message: String = "") {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
            presentAlert(alert)
        }
        let dateText = restoreDateHeightTextField.text!
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
        if restoreHeightTextField.text!.isEmpty && restoreDateHeightTextField.text!.isEmpty {
            let displayName = restoreHeightTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !displayName.isEmpty else {
                return showError(title: NSLocalizedString("RESTORE_HEIGHT_DATE_IS_MISSING_NEW", comment: ""))
            }
        }
        if restoreHeightTextField.text!.count >= 9 {
            let displayName = restoreHeightTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !OWSProfileManager.shared().isProfileNameTooLong(displayName) else {
                return showError(title: NSLocalizedString("RESTORE_HEIGHT_IS_LONG_MSG_NEW", comment: ""))
            }
        }
        
        // For greater blockheight
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        if Int64(restoreHeightTextField.text!) ?? 0 > RestoreHeight.getInstance().getHeight(dateString) {
            showError(title: "Enter blockheight less than current blockheight.")
            return
        }
        
        if restoreHeightTextField.text!.isEmpty && restoreDateHeightTextField.text != nil {
            if !dateHeight.isEmpty {
                SaveUserDefaultsData.WalletRestoreHeight = dateHeight
            } else {
                SaveUserDefaultsData.WalletRestoreHeight = ""
            }
            SaveUserDefaultsData.NameForWallet = displayNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.mnemonicSeedconnect()
            let vc = NewPasswordVC()
            vc.isGoingHome = true
            vc.isCreatePassword = true
            navigationController!.pushViewController(vc, animated: true)
            return
        }
        if displayNameTextField.text != "" && restoreHeightTextField.text != "" && restoreDateHeightTextField.text != "" {
            showError(title: NSLocalizedString(NSLocalizedString("ENTER_DATE_OR_HEIGHT_TXT_NEW", comment: ""), comment: ""))
        }
        if displayNameTextField.text != "" && restoreHeightTextField.text != nil && dateText == "" {
            SaveUserDefaultsData.WalletRestoreHeight = restoreHeightTextField.text!
            SaveUserDefaultsData.NameForWallet = displayNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.mnemonicSeedconnect()
            let vc = NewPasswordVC()
            vc.isGoingHome = true
            vc.isCreatePassword = true
            navigationController!.pushViewController(vc, animated: true)
        }
    }
    
}

