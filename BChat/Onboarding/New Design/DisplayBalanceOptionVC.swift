// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class DisplayBalanceOptionVC: BaseVC {

    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.smallBackGroundColor
        stackView.layer.cornerRadius = 20
         stackView.layer.borderWidth = 1
         stackView.layer.borderColor = Colors.borderColorNew.cgColor
        return stackView
    }()
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 16)
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
        button.setBackgroundImage(UIImage(named: "ic_closeNew"), for: .normal)
        return button
    }()
    lazy var fullBalanceButton: UIButton = {
        let button = UIButton()
        button.setTitle("Beldex Full Balance", for: .normal)
        button.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.layer.cornerRadius = Values.buttonRadius
        button.addTarget(self, action: #selector(fullBalanceButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var availableBalanceButton: UIButton = {
        let button = UIButton()
        button.setTitle("Beldex Available Balance", for: .normal)
        button.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.layer.cornerRadius = Values.buttonRadius
        button.addTarget(self, action: #selector(availableBalanceButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var hiddenBalanceButton: UIButton = {
        let button = UIButton()
        button.setTitle("Beldex Hidden", for: .normal)
        button.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.layer.cornerRadius = Values.buttonRadius
        button.addTarget(self, action: #selector(hiddenBalanceButtonTapped), for: .touchUpInside)
        return button
    }()
    var displayBalanceString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
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
            if SaveUserDefaultsData.SelectedBalance.contains("Beldex Full Balance") {
                fullBalanceButtonUtilities()
            } else if SaveUserDefaultsData.SelectedBalance.contains("Beldex Available Balance") {
                availableBalanceButtonUtilities()
            } else {
                hiddenBalanceButtonUtilities()
            }
        } else {
            fullBalanceButton.setTitle("Beldex Full Balance", for: .normal)
            fullBalanceButtonUtilities()
        }
        
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        SaveUserDefaultsData.SelectedBalance = displayBalanceString
        NotificationCenter.default.post(name: .selectedDisplayNameKeyNotification, object: SaveUserDefaultsData.SelectedBalance)
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
    
    func fullBalanceButtonUtilities() {
        fullBalanceButton.layer.borderWidth = 1
        fullBalanceButton.layer.borderColor = Colors.bothGreenColor.cgColor
        fullBalanceButton.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        fullBalanceButton.setTitleColor(Colors.titleColor3, for: .normal)
        
        availableBalanceButton.layer.borderWidth = 1
        availableBalanceButton.layer.borderColor = Colors.borderColorNew.cgColor
        availableBalanceButton.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        availableBalanceButton.setTitleColor(Colors.bothGrayColor, for: .normal)
        
        hiddenBalanceButton.layer.borderWidth = 1
        hiddenBalanceButton.layer.borderColor = Colors.borderColorNew.cgColor
        hiddenBalanceButton.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        hiddenBalanceButton.setTitleColor(Colors.bothGrayColor, for: .normal)
    }
    
    func availableBalanceButtonUtilities() {
        availableBalanceButton.layer.borderWidth = 1
        availableBalanceButton.layer.borderColor = Colors.bothGreenColor.cgColor
        availableBalanceButton.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        availableBalanceButton.setTitleColor(Colors.titleColor3, for: .normal)
        
        fullBalanceButton.layer.borderWidth = 1
        fullBalanceButton.layer.borderColor = Colors.borderColorNew.cgColor
        fullBalanceButton.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        fullBalanceButton.setTitleColor(Colors.bothGrayColor, for: .normal)
        
        hiddenBalanceButton.layer.borderWidth = 1
        hiddenBalanceButton.layer.borderColor = Colors.borderColorNew.cgColor
        hiddenBalanceButton.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        hiddenBalanceButton.setTitleColor(Colors.bothGrayColor, for: .normal)
    }
    
    func hiddenBalanceButtonUtilities() {
        hiddenBalanceButton.layer.borderWidth = 1
        hiddenBalanceButton.layer.borderColor = Colors.bothGreenColor.cgColor
        hiddenBalanceButton.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        hiddenBalanceButton.setTitleColor(Colors.titleColor3, for: .normal)
        
        availableBalanceButton.layer.borderWidth = 1
        availableBalanceButton.layer.borderColor = Colors.borderColorNew.cgColor
        availableBalanceButton.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        availableBalanceButton.setTitleColor(Colors.bothGrayColor, for: .normal)
        
        fullBalanceButton.layer.borderWidth = 1
        fullBalanceButton.layer.borderColor = Colors.borderColorNew.cgColor
        fullBalanceButton.titleLabel?.font = Fonts.OpenSans(ofSize: 16)
        fullBalanceButton.setTitleColor(Colors.bothGrayColor, for: .normal)
    }

}
