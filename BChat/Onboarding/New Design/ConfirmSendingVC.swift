// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class ConfirmSendingVC: BaseVC {
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.viewBackgroundColorNew2
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColor.cgColor
        return stackView
    }()
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Confirm Sending"
        return result
    }()
    private lazy var amountView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.confirmSendingViewBackgroundColor
        stackView.layer.cornerRadius = Values.buttonRadius
        return stackView
    }()
    private lazy var amountLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Amount"
        return result
    }()
    private lazy var seperatorView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.borderColor
        return stackView
    }()
    private lazy var finalAmountLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 22)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.adjustsFontSizeToFitWidth = true
        return result
    }()
    private lazy var iconView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_confirmSending")
        result.set(.width, to: 27.42)
        result.set(.height, to: 26.48)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    private lazy var addressView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.confirmSendingViewBackgroundColor
        stackView.layer.cornerRadius = Values.buttonRadius
        return stackView
    }()
    private lazy var addressLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Address :"
        return result
    }()
    private lazy var beldexAddressLabel: UILabel = {
        let result = PaddingLabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 11)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor3
        result.paddingTop = 15
        result.paddingLeft = 15
        result.paddingRight = 15
        result.paddingBottom = 12
        result.numberOfLines = 0
        result.layer.cornerRadius = 16
        result.layer.masksToBounds = true
        return result
    }()
    private lazy var feeLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("OK", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 0.5
        button.layer.borderColor = Colors.bothGreenColor.cgColor
        button.backgroundColor = Colors.bothGreenWithAlpha10
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.setTitleColor(Colors.cancelButtonTitleColor1, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 8
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    var finalWalletAddress = ""
    var finalWalletAmount = ""
    var feeValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexValue: 0x080812, a: 0.7)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, buttonStackView, amountView, addressView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(okButton)
        amountView.addSubViews(amountLabel, seperatorView, iconView, finalAmountLabel)
        addressView.addSubViews(addressLabel, beldexAddressLabel, feeLabel)
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            amountView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 22),
            amountView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -22),
            amountView.heightAnchor.constraint(equalToConstant: 55),
            amountView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            amountLabel.topAnchor.constraint(equalTo: amountView.topAnchor, constant: 19),
            amountLabel.leadingAnchor.constraint(equalTo: amountView.leadingAnchor, constant: 27),
            amountLabel.widthAnchor.constraint(equalToConstant: 60),
            seperatorView.topAnchor.constraint(equalTo: amountView.topAnchor),
            seperatorView.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 16),
            seperatorView.bottomAnchor.constraint(equalTo: amountView.bottomAnchor),
            seperatorView.widthAnchor.constraint(equalToConstant: 1),
            finalAmountLabel.topAnchor.constraint(equalTo: amountView.topAnchor, constant: 13),
            finalAmountLabel.leadingAnchor.constraint(equalTo: seperatorView.trailingAnchor, constant: 15),
            finalAmountLabel.bottomAnchor.constraint(equalTo: amountView.bottomAnchor, constant: -9),
            finalAmountLabel.trailingAnchor.constraint(equalTo: amountView.trailingAnchor, constant: -52),
            iconView.topAnchor.constraint(equalTo: amountView.topAnchor, constant: 16),
            iconView.trailingAnchor.constraint(equalTo: amountView.trailingAnchor, constant: -16.03),
            iconView.bottomAnchor.constraint(equalTo: amountView.bottomAnchor, constant: -12.52),
            addressView.topAnchor.constraint(equalTo: amountView.bottomAnchor, constant: 14),
            addressView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 22),
            addressView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -22),
            addressLabel.topAnchor.constraint(equalTo: addressView.topAnchor, constant: 13.53),
            addressLabel.leadingAnchor.constraint(equalTo: addressView.leadingAnchor, constant: 22.57),
            beldexAddressLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 5.81),
            beldexAddressLabel.leadingAnchor.constraint(equalTo: addressView.leadingAnchor, constant: 15),
            beldexAddressLabel.trailingAnchor.constraint(equalTo: addressView.trailingAnchor, constant: -14),
            feeLabel.topAnchor.constraint(equalTo: beldexAddressLabel.bottomAnchor, constant: 13),
            feeLabel.leadingAnchor.constraint(equalTo: addressView.leadingAnchor, constant: 22.57),
            feeLabel.bottomAnchor.constraint(equalTo: addressView.bottomAnchor, constant: -15.33),
            buttonStackView.topAnchor.constraint(equalTo: addressView.bottomAnchor, constant: 17),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 22),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -22),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -27),
            buttonStackView.heightAnchor.constraint(equalToConstant: 46),
            okButton.heightAnchor.constraint(equalToConstant: 46),
            cancelButton.heightAnchor.constraint(equalToConstant: 46),
        ])
        
        beldexAddressLabel.text = finalWalletAddress
        finalAmountLabel.text = finalWalletAmount
        feeLabel.text = "Fee : \(feeValue)"
        
    }
    
    @objc private func okButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("confirmsendingButtonTapped"), object: nil)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
