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
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 16)
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
        result.font = Fonts.OpenSans(ofSize: 14)
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
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Cancel Button
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
            titleLabel.textColor = Colors.titleColor3
            discriptionLabel.text = "Are you sure you want to Unblock this contact?"
            yesButton.setTitle("Unblock", for: .normal)
        }
        
        
    }
    
    @objc private func okButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        if isBlocked {
            NotificationCenter.default.post(name: .unblockContactNotification, object: nil)
        } else {
            NotificationCenter.default.post(name: .blockContactNotification, object: nil)
        }
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
