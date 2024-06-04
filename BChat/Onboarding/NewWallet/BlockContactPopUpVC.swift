// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class BlockContactPopUpVC: BaseVC {

    /// BackGround View
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.popUpBackgroundColor
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColor.cgColor
        return stackView
    }()
    
    /// Title Label
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.extraBoldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Block contact"
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    /// Discription Label
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.OpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Are you sure you want to Block this contact?"
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    /// Yes Button
    private lazy var yesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Yes", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.greenColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Cancel Button
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.profileImageViewButtonColor
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 7
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    var isBlocked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, discriptionLabel, buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(yesButton)
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),

            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 50),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -50),

            buttonStackView.topAnchor.constraint(equalTo: discriptionLabel.bottomAnchor, constant: 21),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -23),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),

            yesButton.heightAnchor.constraint(equalToConstant: 52),
            cancelButton.heightAnchor.constraint(equalToConstant: 52),
        ])
        
        if isBlocked {
            titleLabel.text = "Unblock Contact"
            titleLabel.textColor = Colors.aboutContentLabelColor
        }
        
        
    }
    
    @objc private func okButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: .userBlockContactNotification, object: nil)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
