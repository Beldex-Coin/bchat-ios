// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class RescanNewVC: BaseVC {
    
    // MARK: - UIElements
    
    /// topBackgroundView
    private lazy var topBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.cellBackgroundColorForNodeList
        stackView.layer.borderColor = Colors.borderColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    /// Current Blockheight Title Label
    private lazy var currentBlockheightTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("CURRENT_BLOCK_HEIGHT_NEW", comment: "")
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Current Block height Id Title Label
    private lazy var currentBlockheightIdTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.greenColor
        result.font = Fonts.boldOpenSans(ofSize: 20)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Sub Title Wallet Label
    private lazy var subTitleWalletLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("WALLET_DATE_ENTER_LABEL_NEW", comment: "")
        result.textColor = Colors.cancelButtonTitleColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Restore Date Height TextField
    private lazy var restoreDateHeightTextField: UITextField = {
        let result = UITextField()
        result.delegate = self
        result.translatesAutoresizingMaskIntoConstraints = false
        result.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("RESTORE_DATE_TITLE_NEW", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 14)
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 16
        
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingViewLeft
        result.leftViewMode = .always
        
        let imageView = UIImageView(image: UIImage(named: "ic_date_New"))
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24) // Adjusted frame
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true // Enable user interaction
        
        // Ensure the tap gesture recognizer is properly configured
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 24)) // Adjusted width to ensure proper spacing
        paddingView.addSubview(imageView)
        result.rightView = paddingView
        result.rightViewMode = .always
        
        return result
    }()
    
    /// Restore From Block Height TextField
    private lazy var restoreFromBlockHeightTextField: UITextField = {
        let result = UITextField()
        result.delegate = self
        result.translatesAutoresizingMaskIntoConstraints = false
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("RESTORE_FROM_BLOCKHEIGHT", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 14)
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 16
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingView
        result.leftViewMode = .always
        return result
    }()
    
    /// Rescan Button
    private lazy var rescanButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("RESCAN_BUTTON_TITLE", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.greenColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 18)
        button.addTarget(self, action: #selector(rescanButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// I Know The BlockHeight Button
    private lazy var iKnowTheBlockHeightButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("I_KNOW_THE_BLOCKHEIGHT", comment: ""), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor3
        button.setTitleColor(Colors.aboutContentLabelColor, for: .normal)
        button.layer.borderColor = Colors.borderColor.cgColor
        button.layer.borderWidth = 1
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(iKnowTheBlockHeightButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let datePicker = DatePickerDialog()
    var daemonBlockChainHeight: UInt64 = 0
    var dateHeight = ""
    var lastEditedTextField: UITextField?
    
    // MARK: - UIViewController life cycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorNew
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Rescan"
        setUpTopCornerRadius()
        
        iKnowTheBlockHeightButton.addRightIconLongSpace(image: UIImage(named: "ic_right_arrow_New")!.withRenderingMode(.alwaysTemplate))
        iKnowTheBlockHeightButton.tintColor = Colors.greenColor
        restoreFromBlockHeightTextField.isHidden = true
        restoreDateHeightTextField.isHidden = false
        
        currentBlockheightIdTitleLabel.text = "\(daemonBlockChainHeight)"
        restoreFromBlockHeightTextField.addDoneButtonKeybord()
        restoreFromBlockHeightTextField.keyboardType = .numberPad
        
        view.addSubViews(topBackgroundView)
        topBackgroundView.addSubview(currentBlockheightTitleLabel)
        topBackgroundView.addSubview(currentBlockheightIdTitleLabel)
        view.addSubview(subTitleWalletLabel)
        view.addSubview(restoreDateHeightTextField)
        view.addSubview(restoreFromBlockHeightTextField)
        view.addSubview(rescanButton)
        view.addSubview(iKnowTheBlockHeightButton)
        
        NSLayoutConstraint.activate([
            topBackgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 41),
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            topBackgroundView.heightAnchor.constraint(equalToConstant: 52),
            currentBlockheightTitleLabel.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 20),
            currentBlockheightTitleLabel.centerYAnchor.constraint(equalTo: topBackgroundView.centerYAnchor),
            currentBlockheightIdTitleLabel.leadingAnchor.constraint(equalTo: currentBlockheightTitleLabel.trailingAnchor, constant: 10),
            currentBlockheightIdTitleLabel.centerYAnchor.constraint(equalTo: currentBlockheightTitleLabel.centerYAnchor),
            subTitleWalletLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            subTitleWalletLabel.topAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: 116),
            subTitleWalletLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            restoreDateHeightTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            restoreDateHeightTextField.topAnchor.constraint(equalTo: subTitleWalletLabel.bottomAnchor, constant: 20),
            restoreDateHeightTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            restoreDateHeightTextField.heightAnchor.constraint(equalToConstant: 60),
            restoreFromBlockHeightTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            restoreFromBlockHeightTextField.topAnchor.constraint(equalTo: subTitleWalletLabel.bottomAnchor, constant: 20),
            restoreFromBlockHeightTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            restoreFromBlockHeightTextField.heightAnchor.constraint(equalToConstant: 60),
            rescanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            rescanButton.topAnchor.constraint(equalTo: restoreDateHeightTextField.bottomAnchor, constant: 16),
            rescanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            rescanButton.heightAnchor.constraint(equalToConstant: 58),
            iKnowTheBlockHeightButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            iKnowTheBlockHeightButton.topAnchor.constraint(equalTo: rescanButton.bottomAnchor, constant: 168),
            iKnowTheBlockHeightButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            iKnowTheBlockHeightButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
    }
    
    /// View Did Layout Subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBackgroundView.layer.cornerRadius = topBackgroundView.frame.height/2
        iKnowTheBlockHeightButton.layer.cornerRadius = iKnowTheBlockHeightButton.frame.height/2
    }
    
    /// Date Picker
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
                let dateString = formatter.string(from: dt)
                print("selected date---------String Formate--------------------->: ",dateString)
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
    
    /// image View Tapped
    @objc func imageViewTapped() {
        print("Image View tapped")
        datePickerTapped()
    }
    
    /// Rescan Button Tapped
    @objc func rescanButtonTapped(_ sender: UIButton) {
        let heightString = restoreFromBlockHeightTextField.text
        let dateString = restoreDateHeightTextField.text
        
        if let lastEdited = lastEditedTextField {
            if lastEdited == restoreFromBlockHeightTextField, let heightString = heightString, !heightString.isEmpty {
                processBlockHeightInput(heightString)
            } else if lastEdited == restoreDateHeightTextField, let dateString = dateString, !dateString.isEmpty {
                processDateInput()
            }
        } else {
            if heightString == "" && dateString != ""{
                if !dateHeight.isEmpty {
                    SaveUserDefaultsData.WalletRestoreHeight = dateHeight
                }else {
                    SaveUserDefaultsData.WalletRestoreHeight = ""
                }
                navigateBack()
            }
            if heightString != "" && dateString == "" {
                let number: Int64? = Int64("\(heightString!)")
                if number! > daemonBlockChainHeight {
                    inValidHeightAlert()
                }else if number! == daemonBlockChainHeight {
                    inValidHeightAlert()
                }
                else {
                    SaveUserDefaultsData.WalletRestoreHeight = restoreFromBlockHeightTextField.text!
                    navigateBack()
                }
            }
            if restoreFromBlockHeightTextField.text != "" && restoreDateHeightTextField.text != "" {
                restoreHeightDateAlert()
            }
            if restoreFromBlockHeightTextField.text!.isEmpty && restoreDateHeightTextField.text!.isEmpty {
                restoreHeightDateAlert()
            }
        }
    }
    
    /// Process Block Height Input
    func processBlockHeightInput(_ heightString: String) {
        let number: Int64? = Int64(heightString)
        if let number = number, number >= 0 {
            if number > daemonBlockChainHeight || number == daemonBlockChainHeight {
                inValidHeightAlert()
            } else {
                SaveUserDefaultsData.WalletRestoreHeight = heightString
                navigateBack()
            }
        }
    }
    
    /// Process Date Input
    func processDateInput() {
        if !dateHeight.isEmpty {
            SaveUserDefaultsData.WalletRestoreHeight = dateHeight
            navigateBack()
        } else {
            SaveUserDefaultsData.WalletRestoreHeight = ""
            navigateBack()
        }
    }
    
    /// Navigate Back
    func navigateBack() {
        if let navigationController = navigationController {
            let count = navigationController.viewControllers.count
            if count > 1 {
                let VC = navigationController.viewControllers[count - 2] as! WalletHomeNewVC
                VC.backApiRescanVC = true
                WalletSync.isInsideWallet = false
            }
            navigationController.popViewController(animated: true)
        }
    }
    
    /// In Valid Height Alert
    func inValidHeightAlert() {
        let alert = UIAlertController(title: NSLocalizedString("WALLET_TITLE", comment: ""), message: NSLocalizedString("INVALID_HEIGHT", comment: ""), preferredStyle: .alert)
        let okayAction = UIAlertAction(title: NSLocalizedString("OKEY_BUTTON", comment: ""), style: .default, handler: { (_) in
        })
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Restore Height Date Alert
    func restoreHeightDateAlert() {
        let alert = UIAlertController(title: NSLocalizedString("WALLET_TITLE", comment: ""), message: NSLocalizedString("PLEASE_PICK_RESTOREHEIGHT", comment: ""), preferredStyle: .alert)
        let okayAction = UIAlertAction(title: NSLocalizedString("OKEY_BUTTON", comment: ""), style: .default, handler: { (_) in
        })
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func iKnowTheBlockHeightButtonTapped(_ sender: UIButton){
        iKnowTheBlockHeightButton.isSelected = !iKnowTheBlockHeightButton.isSelected
        if iKnowTheBlockHeightButton.isSelected {
            subTitleWalletLabel.text = NSLocalizedString("WALLET_DATE_ENTER_LABEL_NEW2", comment: "")
            iKnowTheBlockHeightButton.setTitle(NSLocalizedString("I_KNOW_THE_DATE", comment: ""), for: .normal)
            restoreFromBlockHeightTextField.isHidden = false
            restoreDateHeightTextField.isHidden = true
        } else {
            subTitleWalletLabel.text = NSLocalizedString("WALLET_DATE_ENTER_LABEL_NEW", comment: "")
            iKnowTheBlockHeightButton.setTitle(NSLocalizedString("I_KNOW_THE_BLOCKHEIGHT", comment: ""), for: .normal)
            restoreFromBlockHeightTextField.isHidden = true
            restoreDateHeightTextField.isHidden = false
        }
    }
    
}


// MARK: - UITextFieldDelegate methods

extension RescanNewVC: UITextFieldDelegate {
    /// UI Text View Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == restoreFromBlockHeightTextField){
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.restoreDateHeightTextField {
            datePickerTapped()
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lastEditedTextField = textField
    }
}
