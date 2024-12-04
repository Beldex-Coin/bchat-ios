// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class LeaveGroupPopUp: BaseVC {
    
    // MARK: - UIElements
    
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
        result.text = "Leave Group?"
        return result
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = ""
        result.numberOfLines = 0
        return result
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("Leave", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothRedColor
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
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
        result.alignment = .fill
        result.distribution = .fillEqually
        result.spacing = 8
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    var message = ""
    
    // MARK: - UIViewController life cycle
    
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
        buttonStackView.addArrangedSubview(clearButton)
        
        discriptionLabel.text = message
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 21),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 9),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 30),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -30),
            discriptionLabel.bottomAnchor.constraint(equalTo: clearButton.topAnchor, constant: -19),
            
            buttonStackView.topAnchor.constraint(equalTo: discriptionLabel.bottomAnchor, constant: 19),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -15),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            
            clearButton.heightAnchor.constraint(equalToConstant: 52),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 52),
        ])
        
    }
    
    // MARK: - UIButton actions
    
    /// Ok button action
    @objc private func clearButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: .LeaveGroupNotification, object: nil)
    }
    
    /// Cancel button action
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
