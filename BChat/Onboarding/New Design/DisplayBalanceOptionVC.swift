// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class DisplayBalanceOptionVC: BaseVC {

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
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Display Balance As"
        return result
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_close"), for: .normal)
        return button
    }()
    lazy var fullBalanceButton: UIButton = {
        let button = UIButton()
        button.setTitle("Beldex Full Balance", for: .normal)
        button.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x1C1C26)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(fullBalanceButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var availableBalanceButton: UIButton = {
        let button = UIButton()
        button.setTitle("Beldex Available Balance", for: .normal)
        button.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x1C1C26)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(availableBalanceButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var hiddenBalanceButton: UIButton = {
        let button = UIButton()
        button.setTitle("Beldex Hidden", for: .normal)
        button.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x1C1C26)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(hiddenBalanceButtonTapped), for: .touchUpInside)
        return button
    }()
    var displayBalanceString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hexValue: 0x080812, a: 0.7)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, closeButton, fullBalanceButton, availableBalanceButton, hiddenBalanceButton)
        
        fullBalanceButtonUtilities()
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -18),
            closeButton.heightAnchor.constraint(equalToConstant: 22),
            closeButton.widthAnchor.constraint(equalToConstant: 22),
            fullBalanceButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            fullBalanceButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            fullBalanceButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            fullBalanceButton.heightAnchor.constraint(equalToConstant: 60),
            availableBalanceButton.topAnchor.constraint(equalTo: fullBalanceButton.bottomAnchor, constant: 11),
            availableBalanceButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            availableBalanceButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            availableBalanceButton.heightAnchor.constraint(equalToConstant: 60),
            hiddenBalanceButton.topAnchor.constraint(equalTo: availableBalanceButton.bottomAnchor, constant: 11),
            hiddenBalanceButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            hiddenBalanceButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            hiddenBalanceButton.heightAnchor.constraint(equalToConstant: 60),
            hiddenBalanceButton.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -34)
        ])
        
        if !SaveUserDefaultsData.SelectedBalance.isEmpty {
            if SaveUserDefaultsData.SelectedBalance.contains("Beldex Full Balance"){
                fullBalanceButtonUtilities()
            }else if SaveUserDefaultsData.SelectedBalance.contains("Beldex Available Balance"){
                availableBalanceButtonUtilities()
            }else{
                hiddenBalanceButtonUtilities()
            }
        }else{
            fullBalanceButton.setTitle("Beldex Full Balance", for: .normal)
        }
        
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        SaveUserDefaultsData.SelectedBalance = displayBalanceString
        NotificationCenter.default.post(name: Notification.Name("selectedDisplayNameKey"), object: SaveUserDefaultsData.SelectedBalance)
    }
    
    @objc private func fullBalanceButtonTapped(_ sender: UIButton) {
        fullBalanceButtonUtilities()
        displayBalanceString = "Beldex Full Balance"
    }
    
    @objc private func availableBalanceButtonTapped(_ sender: UIButton) {
        availableBalanceButtonUtilities()
        displayBalanceString = "Beldex Available Balance"
    }
    
    @objc private func hiddenBalanceButtonTapped(_ sender: UIButton) {
        hiddenBalanceButtonUtilities()
        displayBalanceString = "Beldex Hidden"
    }
    
    func fullBalanceButtonUtilities(){
        fullBalanceButton.layer.borderWidth = 2
        fullBalanceButton.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        fullBalanceButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        fullBalanceButton.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        
        availableBalanceButton.layer.borderWidth = 1
        availableBalanceButton.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        availableBalanceButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        availableBalanceButton.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
        
        hiddenBalanceButton.layer.borderWidth = 1
        hiddenBalanceButton.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        hiddenBalanceButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        hiddenBalanceButton.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
    }
    
    func availableBalanceButtonUtilities(){
        availableBalanceButton.layer.borderWidth = 2
        availableBalanceButton.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        availableBalanceButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        availableBalanceButton.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        
        fullBalanceButton.layer.borderWidth = 1
        fullBalanceButton.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        fullBalanceButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        fullBalanceButton.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
        
        hiddenBalanceButton.layer.borderWidth = 1
        hiddenBalanceButton.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        hiddenBalanceButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        hiddenBalanceButton.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
    }
    
    func hiddenBalanceButtonUtilities(){
        hiddenBalanceButton.layer.borderWidth = 2
        hiddenBalanceButton.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        hiddenBalanceButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        hiddenBalanceButton.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        
        availableBalanceButton.layer.borderWidth = 1
        availableBalanceButton.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        availableBalanceButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        availableBalanceButton.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
        
        fullBalanceButton.layer.borderWidth = 1
        fullBalanceButton.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        fullBalanceButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        fullBalanceButton.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
    }

}
