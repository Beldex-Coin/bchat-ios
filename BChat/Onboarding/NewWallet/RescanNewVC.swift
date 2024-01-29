// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class RescanNewVC: UIViewController,UITextFieldDelegate {
    
    private lazy var topView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        stackView.layer.borderWidth = 0.5
        return stackView
    }()
    private lazy var currentBlockheightTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("CURRENT_BLOCK_HEIGHT_NEW", comment: "")
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var currentBlockheightIDTitleLabel: UILabel = {
        let result = UILabel()
        result.text = "9872364"
        result.textColor = Colors.greenColor
        result.font = Fonts.boldOpenSans(ofSize: 20)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var subTitleWalletLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("WALLET_DATE_ENTER_LABEL_NEW", comment: "")
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var restoreDateHeightTextField: UITextField = {
        let result = UITextField()
        result.delegate = self
        result.translatesAutoresizingMaskIntoConstraints = false
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("RESTORE_DATE_TITLE_NEW", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 14)
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 16
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingViewLeft
        result.leftViewMode = .always
        let imageView = UIImageView(image: UIImage(named: "ic_date_New"))
        imageView.frame = CGRect(x: -10, y: 0, width: 24, height: 24) // Adjust the frame as needed
        imageView.contentMode = .scaleAspectFit // Set the content mode as needed
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        result.rightView = paddingView
        result.rightViewMode = .always
        result.rightView?.addSubview(imageView)
        return result
    }()
    private lazy var restoreFromBlockHeightTextField: UITextField = {
        let result = UITextField()
        result.delegate = self
        result.translatesAutoresizingMaskIntoConstraints = false
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("RESTORE_FROM_BLOCKHEIGHT", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 14)
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 16
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingView
        result.leftViewMode = .always
        return result
    }()
    private lazy var isFromRescanButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("RESCAN_BUTTON_TITLE", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.greenColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 18)
        button.addTarget(self, action: #selector(isFromRescanButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var isFromIKnowTheHeightButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("I_KNOW_THE_BLOCKHEIGHT", comment: ""), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        button.layer.borderWidth = 1
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(isFromIKnowTheHeightButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let datePicker = DatePickerDialog()
    var daemonBlockChainHeight: UInt64 = 0
    var dateHeight = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Rescan"
        
        isFromIKnowTheHeightButton.addRightIconLongSpace(image: UIImage(named: "ic_right_arrow_New")!.withRenderingMode(.alwaysTemplate))
        isFromIKnowTheHeightButton.tintColor = Colors.greenColor
        restoreFromBlockHeightTextField.isHidden = true
        restoreDateHeightTextField.isHidden = false
        
        currentBlockheightIDTitleLabel.text = "\(daemonBlockChainHeight)"
        
        view.addSubViews(topView)
        topView.addSubview(currentBlockheightTitleLabel)
        topView.addSubview(currentBlockheightIDTitleLabel)
        view.addSubview(subTitleWalletLabel)
        view.addSubview(restoreDateHeightTextField)
        view.addSubview(restoreFromBlockHeightTextField)
        view.addSubview(isFromRescanButton)
        view.addSubview(isFromIKnowTheHeightButton)
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor, constant: 41),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            topView.heightAnchor.constraint(equalToConstant: 52),
            currentBlockheightTitleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            currentBlockheightTitleLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            currentBlockheightIDTitleLabel.leadingAnchor.constraint(equalTo: currentBlockheightTitleLabel.trailingAnchor, constant: 10),
            currentBlockheightIDTitleLabel.centerYAnchor.constraint(equalTo: currentBlockheightTitleLabel.centerYAnchor),
            subTitleWalletLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            subTitleWalletLabel.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 116),
            subTitleWalletLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            restoreDateHeightTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            restoreDateHeightTextField.topAnchor.constraint(equalTo: subTitleWalletLabel.bottomAnchor, constant: 20),
            restoreDateHeightTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            restoreDateHeightTextField.heightAnchor.constraint(equalToConstant: 60),
            restoreFromBlockHeightTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            restoreFromBlockHeightTextField.topAnchor.constraint(equalTo: subTitleWalletLabel.bottomAnchor, constant: 20),
            restoreFromBlockHeightTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            restoreFromBlockHeightTextField.heightAnchor.constraint(equalToConstant: 60),
            isFromRescanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            isFromRescanButton.topAnchor.constraint(equalTo: restoreDateHeightTextField.bottomAnchor, constant: 16),
            isFromRescanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            isFromRescanButton.heightAnchor.constraint(equalToConstant: 58),
            isFromIKnowTheHeightButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            isFromIKnowTheHeightButton.topAnchor.constraint(equalTo: isFromRescanButton.bottomAnchor, constant: 168),
            isFromIKnowTheHeightButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            isFromIKnowTheHeightButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topView.layer.cornerRadius = topView.frame.height/2
        isFromIKnowTheHeightButton.layer.cornerRadius = isFromIKnowTheHeightButton.frame.height/2
    }
    
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
    
    
    // MARK: - Navigation
    @objc func imageViewTapped() {
        // Handle the tap on the imageView here
        datePickerTapped()
    }
    
    @objc func isFromRescanButtonTapped(_ sender: UIButton){
        let heightString = restoreFromBlockHeightTextField.text
        let dateString = restoreDateHeightTextField.text
        if heightString == "" && dateString != ""{
            if !dateHeight.isEmpty {
                SaveUserDefaultsData.WalletRestoreHeight = dateHeight
            }else {
                SaveUserDefaultsData.WalletRestoreHeight = ""
            }
            if self.navigationController != nil{
                let count = self.navigationController!.viewControllers.count
                if count > 1
                {
                    let VC = self.navigationController!.viewControllers[count-2] as! MyWalletHomeVC
                    VC.backApiRescanVC = true
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
        if heightString != "" && dateString == "" {
            let number: Int64? = Int64("\(heightString!)")
            if number! > daemonBlockChainHeight {
                isFromInvalidHeightAlert()
            }else if number! == daemonBlockChainHeight {
                isFromInvalidHeightAlert()
            }
            else {
                SaveUserDefaultsData.WalletRestoreHeight = restoreFromBlockHeightTextField.text!
                if self.navigationController != nil{
                    let count = self.navigationController!.viewControllers.count
                    if count > 1
                    {
                        let VC = self.navigationController!.viewControllers[count-2] as! MyWalletHomeVC
                        VC.backApiRescanVC = true
                    }
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        if restoreFromBlockHeightTextField.text != "" && restoreDateHeightTextField.text != "" {
            isFromRestoreHeightDateAlert()
        }
        if restoreFromBlockHeightTextField.text!.isEmpty && restoreDateHeightTextField.text!.isEmpty {
            isFromRestoreHeightDateAlert()
        }
    }
    func isFromInvalidHeightAlert(){
        let alert = UIAlertController(title: NSLocalizedString("WALLET_TITLE", comment: ""), message: NSLocalizedString("INVALID_HEIGHT", comment: ""), preferredStyle: .alert)
        let okayAction = UIAlertAction(title: NSLocalizedString("OKEY_BUTTON", comment: ""), style: .default, handler: { (_) in
        })
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    func isFromRestoreHeightDateAlert(){
        let alert = UIAlertController(title: NSLocalizedString("WALLET_TITLE", comment: ""), message: NSLocalizedString("PLEASE_PICK_RESTOREHEIGHT", comment: ""), preferredStyle: .alert)
        let okayAction = UIAlertAction(title: NSLocalizedString("OKEY_BUTTON", comment: ""), style: .default, handler: { (_) in
        })
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func isFromIKnowTheHeightButtonTapped(_ sender: UIButton){
        isFromIKnowTheHeightButton.isSelected = !isFromIKnowTheHeightButton.isSelected
        if isFromIKnowTheHeightButton.isSelected {
            subTitleWalletLabel.text = NSLocalizedString("WALLET_DATE_ENTER_LABEL_NEW2", comment: "")
            isFromIKnowTheHeightButton.setTitle(NSLocalizedString("I_KNOW_THE_DATE", comment: ""), for: .normal)
            restoreFromBlockHeightTextField.isHidden = false
            restoreDateHeightTextField.isHidden = true
        }else {
            subTitleWalletLabel.text = NSLocalizedString("WALLET_DATE_ENTER_LABEL_NEW", comment: "")
            isFromIKnowTheHeightButton.setTitle(NSLocalizedString("I_KNOW_THE_BLOCKHEIGHT", comment: ""), for: .normal)
            restoreFromBlockHeightTextField.isHidden = true
            restoreDateHeightTextField.isHidden = false
        }
    }
    
}
