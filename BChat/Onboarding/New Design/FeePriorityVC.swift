// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class FeePriorityVC: BaseVC {

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
        result.text = "Fee Priority"
        return result
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_close"), for: .normal)
        return button
    }()
    lazy var flashButton: UIButton = {
        let button = UIButton()
        button.setTitle("Flash", for: .normal)
        button.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var slowButton: UIButton = {
        let button = UIButton()
        button.setTitle("Slow", for: .normal)
        button.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(slowButtonButtonTapped), for: .touchUpInside)
        return button
    }()
    var feeValue = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, closeButton, flashButton, slowButton)
        flashButtonUtilities()
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -18),
            closeButton.heightAnchor.constraint(equalToConstant: 22),
            closeButton.widthAnchor.constraint(equalToConstant: 22),
            flashButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 19),
            flashButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            flashButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            flashButton.heightAnchor.constraint(equalToConstant: 60),
            slowButton.topAnchor.constraint(equalTo: flashButton.bottomAnchor, constant: 13),
            slowButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            slowButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            slowButton.heightAnchor.constraint(equalToConstant: 60),
            slowButton.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -23)
        ])
        
        if !SaveUserDefaultsData.FeePriority.isEmpty {
            if SaveUserDefaultsData.FeePriority.contains("Flash"){
                flashButtonUtilities()
            }else{
                slowButtonButtonUtilities()
            }
        }else{
            flashButton.setTitle("Flash", for: .normal)
        }
        
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        SaveUserDefaultsData.FeePriority = feeValue
        NotificationCenter.default.post(name: Notification.Name("feePriorityNameKey"), object: SaveUserDefaultsData.FeePriority)
    }
    
    @objc private func flashButtonTapped(_ sender: UIButton) {
        flashButtonUtilities()
        feeValue = "Flash"
    }
    
    @objc private func slowButtonButtonTapped(_ sender: UIButton) {
        slowButtonButtonUtilities()
        feeValue = "Slow"
    }
    
    func flashButtonUtilities(){
        flashButton.layer.borderWidth = 2
        flashButton.layer.borderColor = Colors.bothGreenColor.cgColor
        flashButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        flashButton.setTitleColor(Colors.titleColor3, for: .normal)
        
        slowButton.layer.borderWidth = 1
        slowButton.layer.borderColor = Colors.borderColorNew.cgColor
        slowButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        slowButton.setTitleColor(Colors.bothGrayColor, for: .normal)
    }
    func slowButtonButtonUtilities(){
        slowButton.layer.borderWidth = 2
        slowButton.layer.borderColor = Colors.bothGreenColor.cgColor
        slowButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        slowButton.setTitleColor(Colors.titleColor3, for: .normal)
        
        flashButton.layer.borderWidth = 1
        flashButton.layer.borderColor = Colors.borderColorNew.cgColor
        flashButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        flashButton.setTitleColor(Colors.bothGrayColor, for: .normal)
    }

}
