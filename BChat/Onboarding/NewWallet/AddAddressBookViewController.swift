// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import BChatMessagingKit

class AddAddressBookViewController: BaseVC {
    
    // MARK: - UIElements
    
    /// Background view
    private lazy var backgroundView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = Colors.viewBackgroundColorNew
        containerView.layer.cornerRadius = 20
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return containerView
    }()
    
    /// Name label
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = Colors.titleColor
        label.font = Fonts.boldOpenSans(ofSize: Values.smallFontSize)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Name text field
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = Fonts.OpenSans(ofSize: 16)
        textField.layer.borderColor = Colors.borderColor.cgColor
        textField.backgroundColor = Colors.cellGroundColor2
        textField.layer.cornerRadius = 16
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: textField.frame.size.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.placeholder = "Enter name"
        textField.textColor = Colors.titleColor
        return textField
    }()
    
    /// Name label
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.text = "Address"
        label.textColor = Colors.titleColor
        label.font = Fonts.boldOpenSans(ofSize: Values.smallFontSize)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Address container view
    private lazy var addressContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cellGroundColor2
        view.layer.cornerRadius = 16
        return view
    }()
    
    /// Name text field
    private lazy var addressTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = Fonts.OpenSans(ofSize: 16)
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 16
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: textField.frame.size.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.placeholder = "Enter the address"
        textField.textColor = Colors.titleColor
        return textField
    }()
    
    /// Add address button
    private lazy var qrCodeButton: UIButton = {
        let button = UIButton()
        let imageName = isDarkMode ? "ic_QR_white" : "ic_QR_dark"
        button.setImage(UIImage(named: imageName), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(qrCodeButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    /// Add address button
    private lazy var addAddressButton: UIButton = {
        let button = UIButton()
        button.isUserInteractionEnabled = false
        button.setTitle(NSLocalizedString("Add Address", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.backgroundViewColor
        button.setTitleColor(Colors.buttonTextColor, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(addAddressButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    /// Name text
    var nameText: String?
    
    /// Address text
    var addressText: String?
    
    // MARK: - UIViewController life cycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.setUpScreenBackgroundColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Add address"
        
        view.addSubview(backgroundView)
        backgroundView.addSubview(nameLabel)
        backgroundView.addSubview(nameTextField)
        backgroundView.addSubview(addressLabel)
        
        backgroundView.addSubview(addressContainerView)
        addressContainerView.addSubview(addressTextField)
        addressContainerView.addSubview(qrCodeButton)
        backgroundView.addSubview(addAddressButton)
        
        addAddressButton.backgroundColor = Colors.cellGroundColor2
        addAddressButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            nameLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 30),
            nameLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            nameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            nameTextField.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 60),
            
            addressLabel.topAnchor.constraint(equalTo: nameTextField.topAnchor, constant: 80),
            addressLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            addressLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            addressLabel.heightAnchor.constraint(equalToConstant: 20),
            
            addressContainerView.topAnchor.constraint(equalTo: addressLabel.topAnchor, constant: 30),
            addressContainerView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            addressContainerView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            addressContainerView.heightAnchor.constraint(equalToConstant: 60),
        
            addressTextField.leadingAnchor.constraint(equalTo: addressContainerView.leadingAnchor, constant: 0),
            addressTextField.trailingAnchor.constraint(equalTo: qrCodeButton.leadingAnchor, constant: -10),
            addressTextField.centerYAnchor.constraint(equalTo: addressContainerView.centerYAnchor),
            addressTextField.heightAnchor.constraint(equalToConstant: 50),
            
            qrCodeButton.trailingAnchor.constraint(equalTo: addressContainerView.trailingAnchor, constant: -10),
            qrCodeButton.centerYAnchor.constraint(equalTo: addressContainerView.centerYAnchor),
            qrCodeButton.widthAnchor.constraint(equalToConstant: 28),
            qrCodeButton.heightAnchor.constraint(equalToConstant: 28),
            
            addAddressButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addAddressButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            addAddressButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -35),
            addAddressButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    /// View will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// View did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// View will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /// View did disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - UIButton Actions
    
    /// Add address button  action
    @objc private func addAddressButtonAction(_ sender: UIButton) {
        var contact = Contact(bchatID: "")
        Storage.write { transaction in
            contact.name = "test iOS"
            contact.beldexAddress = "bxcnTBCVEXS62VyRNxoPui81JcQGSgiJQj8y8NFQvzyUZZDtWmSnuvA5zifEPwpAHLCFCRDi7qbM1VQ4gVuCKFLG1qApD6G9p"
            contact.didApproveMe = true
            Storage.shared.setContact(contact, using: transaction)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Qr code button action
    @objc private func qrCodeButtonAction(_ sender: UIButton) {
        let scanViewController = ScanNewVC()
        scanViewController.newChatScanflag = false
        navigationController!.pushViewController(scanViewController, animated: true)
    }
}

// MARK: - UITextFieldDelegate methods

extension AddAddressBookViewController: UITextFieldDelegate {
        
    /// TextField Should Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// TextField shouldChangeCharactersIn replacementString
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.textInputMode?.primaryLanguage == nil || textField.textInputMode?.primaryLanguage == "emoji" {
            return false
        }
        
        if let oldString = textField.text {
            // FIXME: need to check allow empty or not
            //donot allow empty spaces
//            if oldString.count == 0 && string.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
//                return false
//            }
            
            let newString = oldString.replacingCharacters(in: Range(range, in: oldString)!, with: string)
            if textField == nameTextField {
                nameText = newString
            } else {
                addressText = newString
            }
        }
        
        guard let nameString = nameText, let addressString = addressText else {
            return true
        }
        
        if nameString.isEmpty || addressString.isEmpty {
            addAddressButton.backgroundColor = Colors.backgroundViewColor
            addAddressButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
            addAddressButton.isUserInteractionEnabled = false
        } else {
            addAddressButton.backgroundColor = Colors.bothGreenColor
            addAddressButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
            addAddressButton.isUserInteractionEnabled = true
        }
        return true
    }
}
