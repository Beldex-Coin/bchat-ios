// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class CallPermissionRequestModalNewVC: UIViewController {
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.smallBackGroundColor
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColorNew.cgColor
        return stackView
    }()
    
    lazy var callPermissionLogoImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_CallPermission_white" : "ic_CallPermission"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Call Permission Required!"
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Settings", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
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
        result.spacing = 7
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(backGroundView)
        
        backGroundView.addSubViews(callPermissionLogoImg, titleLabel, discriptionLabel, buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(settingsButton)
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            callPermissionLogoImg.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 22),
            callPermissionLogoImg.heightAnchor.constraint(equalToConstant: 58),
            callPermissionLogoImg.widthAnchor.constraint(equalToConstant: 58),
            callPermissionLogoImg.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: callPermissionLogoImg.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 50),
            titleLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -50),
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 50),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -50),
            buttonStackView.topAnchor.constraint(equalTo: discriptionLabel.bottomAnchor, constant: 21),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -23),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            settingsButton.heightAnchor.constraint(equalToConstant: 52),
            cancelButton.heightAnchor.constraint(equalToConstant: 52),
        ])
        
        
        let string = "You can enable the ‘Voice and video calls’ permission in the Privacy Settings."
        let attributedString = NSMutableAttributedString(string: string)
        // Apply bold font to "Voice and video calls"
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.boldOpenSans(ofSize: 14)]
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "Voice and video calls"))
        // Apply bold font to "Privacy Settings"
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "Privacy Settings"))
        // Display the attributed string
        discriptionLabel.attributedText = attributedString
        
    }
    
    @objc private func settingsButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: {
            if let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                let bChatSettingsNewVC = BChatSettingsNewVC()
                navController.pushViewController(bChatSettingsNewVC, animated: true)
            }
        })
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .showInputViewNotification, object: nil)
    }
    
}
