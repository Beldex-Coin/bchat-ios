// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class AcceptMessageRequestPopUp: BaseVC {

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
        result.text = "Message Request"
        return result
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Are you sure you want to accept this request?"
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("Yes", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hexValue: 0x080812, a: 0.7)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, discriptionLabel, buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(okButton)
        
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 11),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 32),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -32),
            
            
            buttonStackView.topAnchor.constraint(equalTo: discriptionLabel.bottomAnchor, constant: 21),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -21),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            okButton.heightAnchor.constraint(equalToConstant: 52),
            cancelButton.heightAnchor.constraint(equalToConstant: 52),
            
        ])
        
        
    }
    
    
    
    
    @objc private func okButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "acceptMessageRequestTapped"), object: nil)
        self.dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

    

}




class DeleteMessageRequestPopUp: BaseVC {

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
        result.text = "Message Request"
        return result
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Are you sure you want to delete this request?"
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("Yes", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hexValue: 0x080812, a: 0.7)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, discriptionLabel, buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(okButton)
        
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 11),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 32),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -32),
            
            
            buttonStackView.topAnchor.constraint(equalTo: discriptionLabel.bottomAnchor, constant: 21),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -21),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            okButton.heightAnchor.constraint(equalToConstant: 52),
            cancelButton.heightAnchor.constraint(equalToConstant: 52),
            
        ])
        
        
    }
    
    
    
    
    @objc private func okButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "deleteMessageRequestTapped"), object: nil)
        self.dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

    

}



class BlockMessageRequestPopUp: BaseVC {

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
        result.text = "Message Request"
        return result
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Are you sure you want to Block this user?"
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("Yes", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hexValue: 0x080812, a: 0.7)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, discriptionLabel, buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(okButton)
        
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 11),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 32),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -32),
            
            
            buttonStackView.topAnchor.constraint(equalTo: discriptionLabel.bottomAnchor, constant: 21),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -21),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            okButton.heightAnchor.constraint(equalToConstant: 52),
            cancelButton.heightAnchor.constraint(equalToConstant: 52),
            
        ])
        
        
    }
    
    
    
    
    @objc private func okButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "deleteMessageRequestTapped"), object: nil)
        self.dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

    

}