// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class DecimalsPopUpVC: BaseVC {

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
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Decimals"
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
    lazy var fourButton: UIButton = {
        let button = UIButton()
        button.setTitle("4 - Four (0.0000)", for: .normal)
        button.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(fourButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var threeButton: UIButton = {
        let button = UIButton()
        button.setTitle("3 - Three (0.000)", for: .normal)
        button.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(threeButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var twoButton: UIButton = {
        let button = UIButton()
        button.setTitle("2 - Two (0.00)", for: .normal)
        button.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(twoButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var zeroButton: UIButton = {
        let button = UIButton()
        button.setTitle("0 - Zero (0)", for: .normal)
        button.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(zeroButtonTapped), for: .touchUpInside)
        return button
    }()
    var decimalValue = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, closeButton, fourButton, threeButton, twoButton, zeroButton)
        
        fourButtonUtilities()
        
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
            fourButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            fourButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            fourButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            fourButton.heightAnchor.constraint(equalToConstant: 60),
            threeButton.topAnchor.constraint(equalTo: fourButton.bottomAnchor, constant: 10),
            threeButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            threeButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            threeButton.heightAnchor.constraint(equalToConstant: 60),
            twoButton.topAnchor.constraint(equalTo: threeButton.bottomAnchor, constant: 10),
            twoButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            twoButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            twoButton.heightAnchor.constraint(equalToConstant: 60),
            zeroButton.topAnchor.constraint(equalTo: twoButton.bottomAnchor, constant: 10),
            zeroButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            zeroButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            zeroButton.heightAnchor.constraint(equalToConstant: 60),
            zeroButton.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -34)
        ])
        
        if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
            if SaveUserDefaultsData.SelectedDecimal.contains("4 - Four (0.0000)"){
                fourButtonUtilities()
            }else if SaveUserDefaultsData.SelectedDecimal.contains("3 - Three (0.000)"){
                threeButtonUtilities()
            }else if SaveUserDefaultsData.SelectedDecimal.contains("2 - Two (0.00)"){
                twoButtonUtilities()
            }else{
                zeroButtonUtilities()
            }
        }else{
            fourButton.setTitle("4 - Four (0.0000)", for: .normal)
        }
        
    }
    
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        SaveUserDefaultsData.SelectedDecimal = decimalValue
        NotificationCenter.default.post(name: Notification.Name("selectedDecimalNameKey"), object: SaveUserDefaultsData.SelectedDecimal)
    }
    @objc private func fourButtonTapped(_ sender: UIButton) {
        fourButtonUtilities()
        decimalValue = "4 - Four (0.0000)"
    }
    @objc private func threeButtonTapped(_ sender: UIButton) {
        threeButtonUtilities()
        decimalValue = "3 - Three (0.000)"
    }
    @objc private func twoButtonTapped(_ sender: UIButton) {
        twoButtonUtilities()
        decimalValue = "2 - Two (0.00)"
    }
    @objc private func zeroButtonTapped(_ sender: UIButton) {
        zeroButtonUtilities()
        decimalValue = "0 - Zero (0)"
    }
    
    func fourButtonUtilities(){
        fourButton.layer.borderWidth = 2
        fourButton.layer.borderColor = Colors.bothGreenColor.cgColor
        fourButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        fourButton.setTitleColor(Colors.titleColor3, for: .normal)
        
        threeButton.layer.borderWidth = 1
        threeButton.layer.borderColor = Colors.borderColorNew.cgColor
        threeButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        threeButton.setTitleColor(Colors.bothGrayColor, for: .normal)
        
        twoButton.layer.borderWidth = 1
        twoButton.layer.borderColor = Colors.borderColorNew.cgColor
        twoButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        twoButton.setTitleColor(Colors.bothGrayColor, for: .normal)
        
        zeroButton.layer.borderWidth = 1
        zeroButton.layer.borderColor = Colors.borderColorNew.cgColor
        zeroButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        zeroButton.setTitleColor(Colors.bothGrayColor, for: .normal)
    }
    func threeButtonUtilities(){
        threeButton.layer.borderWidth = 2
        threeButton.layer.borderColor = Colors.bothGreenColor.cgColor
        threeButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        threeButton.setTitleColor(Colors.titleColor3, for: .normal)
        
        fourButton.layer.borderWidth = 1
        fourButton.layer.borderColor = Colors.borderColorNew.cgColor
        fourButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        fourButton.setTitleColor(Colors.bothGrayColor, for: .normal)
        
        twoButton.layer.borderWidth = 1
        twoButton.layer.borderColor = Colors.borderColorNew.cgColor
        twoButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        twoButton.setTitleColor(Colors.bothGrayColor, for: .normal)
        
        zeroButton.layer.borderWidth = 1
        zeroButton.layer.borderColor = Colors.borderColorNew.cgColor
        zeroButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        zeroButton.setTitleColor(Colors.bothGrayColor, for: .normal)
    }
    func twoButtonUtilities(){
        twoButton.layer.borderWidth = 2
        twoButton.layer.borderColor = Colors.bothGreenColor.cgColor
        twoButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        twoButton.setTitleColor(Colors.titleColor3, for: .normal)
        
        threeButton.layer.borderWidth = 1
        threeButton.layer.borderColor = Colors.borderColorNew.cgColor
        threeButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        threeButton.setTitleColor(Colors.bothGrayColor, for: .normal)
        
        fourButton.layer.borderWidth = 1
        fourButton.layer.borderColor = Colors.borderColorNew.cgColor
        fourButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        fourButton.setTitleColor(Colors.bothGrayColor, for: .normal)
        
        zeroButton.layer.borderWidth = 1
        zeroButton.layer.borderColor = Colors.borderColorNew.cgColor
        zeroButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        zeroButton.setTitleColor(Colors.bothGrayColor, for: .normal)
    }
    func zeroButtonUtilities(){
        zeroButton.layer.borderWidth = 2
        zeroButton.layer.borderColor = Colors.bothGreenColor.cgColor
        zeroButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        zeroButton.setTitleColor(Colors.titleColor3, for: .normal)
        
        twoButton.layer.borderWidth = 1
        twoButton.layer.borderColor = Colors.borderColorNew.cgColor
        twoButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        twoButton.setTitleColor(Colors.bothGrayColor, for: .normal)
        
        threeButton.layer.borderWidth = 1
        threeButton.layer.borderColor = Colors.borderColorNew.cgColor
        threeButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        threeButton.setTitleColor(Colors.bothGrayColor, for: .normal)
        
        fourButton.layer.borderWidth = 1
        fourButton.layer.borderColor = Colors.borderColorNew.cgColor
        fourButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        fourButton.setTitleColor(Colors.bothGrayColor, for: .normal)
    }
    

}
