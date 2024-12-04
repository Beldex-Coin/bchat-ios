// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class SyncInfoPopUpVC: BaseVC {

    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x111119)
        stackView.layer.cornerRadius = 20
         stackView.layer.borderWidth = 1
         stackView.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        return stackView
    }()
    
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Sync Info"
        return result
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "You have scanned from the block height 2250000. However we recommend to scan the blockchain from the block height at which you created the wallet, to get all the transactions and correct balance."
        result.numberOfLines = 0
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("OK", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fill
        result.spacing = 0
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hexValue: 0x080812, a: 0.7)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, discriptionLabel, buttonStackView)
        buttonStackView.addArrangedSubview(okButton)
        
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 22),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 11),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -19),
            
            
            buttonStackView.topAnchor.constraint(equalTo: discriptionLabel.bottomAnchor, constant: 18),
            buttonStackView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor, constant: 0),
            buttonStackView.widthAnchor.constraint(equalToConstant: 158),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -21),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            okButton.heightAnchor.constraint(equalToConstant: 52),
            okButton.widthAnchor.constraint(equalToConstant: 158),
        ])
    }
    
    
    @objc private func okButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

}
