// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class LinkBNSVC: BaseVC {

    
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
        result.textColor = Colors.titleColor
        result.font = Fonts.boldOpenSans(ofSize: 20)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Link BNS"
        return result
    }()
    
    private lazy var bchatIdTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Link BNS"
        return result
    }()
    
    private lazy var bchatIdLabel: UILabel = {
        let result = PaddingLabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor3
        result.paddingTop = 13
        result.paddingLeft = 16
        result.paddingRight = 16
        result.paddingBottom = 13
        result.numberOfLines = 0
        result.layer.cornerRadius = 10
        result.layer.masksToBounds = true
        return result
    }()
    
    private lazy var bnsNameTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "BNS Name"
        return result
    }()
    
    private lazy var bnsNameTextField: UITextField = {
        let result = UITextField()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.placeholder = "Enter BNS name"
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 16
        result.setLeftPaddingPoints(17)
        return result
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.cancelButtonTitleColor, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var verifyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Verify", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.cancelButtonTitleColor, for: .normal)
        button.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var linkButton: UIButton = {
        let button = UIButton()
        button.setTitle("Link", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.buttonDisableColor, for: .normal)
        button.addTarget(self, action: #selector(linkButtonTapped), for: .touchUpInside)
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
        
        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, bchatIdTitleLabel, bchatIdLabel, bnsNameTitleLabel, bnsNameTextField, buttonStackView, linkButton)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(verifyButton)
        
        
        NSLayoutConstraint.activate([
            
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            bchatIdTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            bchatIdTitleLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 25),
            
            bchatIdLabel.topAnchor.constraint(equalTo: bchatIdTitleLabel.bottomAnchor, constant: 6),
            bchatIdLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            bchatIdLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -15),
            
            bnsNameTitleLabel.topAnchor.constraint(equalTo: bchatIdLabel.bottomAnchor, constant: 13),
            bnsNameTitleLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 23),
            
            bnsNameTextField.topAnchor.constraint(equalTo: bnsNameTitleLabel.bottomAnchor, constant: 9),
            bnsNameTextField.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            bnsNameTextField.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -15),
            
            buttonStackView.topAnchor.constraint(equalTo: bnsNameTextField.bottomAnchor, constant: 23),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            
            linkButton.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 13),
            linkButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            linkButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            linkButton.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -22),
            
            
            cancelButton.heightAnchor.constraint(equalToConstant: 52),
            verifyButton.heightAnchor.constraint(equalToConstant: 52),
            linkButton.heightAnchor.constraint(equalToConstant: 52),
        ])
        
    }
    

    
    
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc private func verifyButtonTapped(_ sender: UIButton) {
       
    }
    
    @objc private func linkButtonTapped(_ sender: UIButton) {
       
    }
   

}
