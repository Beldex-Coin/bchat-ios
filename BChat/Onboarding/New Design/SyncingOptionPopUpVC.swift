// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import SignalUtilitiesKit

class SyncingOptionPopUpVC: BaseVC {
    
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
        result.textColor = UIColor(hex: 0x00BD40)
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Syncing Option"
        return result
    }()
    private lazy var reconnectButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reconnect", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(reconnectButtonTapped), for: .touchUpInside)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        return button
    }()
    private lazy var reScaneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Rescan", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(reScaneButtonTapped), for: .touchUpInside)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        return button
    }()
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 8
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexValue: 0x080812, a: 0.7)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, buttonStackView)
        buttonStackView.addArrangedSubview(reconnectButton)
        buttonStackView.addArrangedSubview(reScaneButton)
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            buttonStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            buttonStackView.widthAnchor.constraint(equalToConstant: 178),
            reconnectButton.heightAnchor.constraint(equalToConstant: 52),
            reconnectButton.widthAnchor.constraint(equalToConstant: 178),
            reScaneButton.heightAnchor.constraint(equalToConstant: 52),
            reScaneButton.widthAnchor.constraint(equalToConstant: 178),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -22),
            buttonStackView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
        ])
        
    }
    
    @objc private func reconnectButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reconnectButtonAction"), object: nil)
    }
    
    @objc private func reScaneButtonTapped(_ sender: UIButton) {
        //        self.dismiss(animated: true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reScaneButtonAction"), object: nil)
    }
    
}
