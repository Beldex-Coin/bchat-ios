// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewClearDataVC: BaseVC {
    
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
        result.textColor = Colors.titleColor2
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("CLEAR_ALL_DATA", comment: "")
        return result
    }()
    
    private lazy var clearDataLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor2
        result.font = Fonts.OpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("CLEAR_DATA_FROM_DEVICE", comment: "")
        return result
    }()
    
    private lazy var clearDataDiscriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.smallTitleColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Delete data on this device"
        return result
    }()
    
    private lazy var deleteLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor2
        result.font = Fonts.OpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Delete Entire Account"
        return result
    }()
    
    private lazy var deleteDiscriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.smallTitleColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Delete data from the network"
        return result
    }()
    
    private lazy var clearDataButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(clearDataButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_radioButton"), for: .normal)
        button.setBackgroundImage(UIImage(named: "ic_radioButton_selected"), for: .selected)
        return button
    }()
    
    private lazy var deleteAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(deleteAccountButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_radioButton"), for: .normal)
        button.setBackgroundImage(UIImage(named: "ic_radioButton_selected"), for: .selected)
        return button
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("OK", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
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
        button.setTitleColor(Colors.cancelButtonTitleColor, for: .normal)
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, clearDataButton, clearDataLabel, clearDataDiscriptionLabel, deleteAccountButton, deleteLabel, deleteDiscriptionLabel, buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(okButton)
        
        self.clearDataButton.isSelected = true
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            clearDataLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 23),
            clearDataDiscriptionLabel.topAnchor.constraint(equalTo: clearDataLabel.bottomAnchor, constant: 2),
            clearDataDiscriptionLabel.leadingAnchor.constraint(equalTo: clearDataLabel.leadingAnchor),
            
            clearDataButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 33),
            clearDataButton.trailingAnchor.constraint(equalTo: clearDataLabel.leadingAnchor, constant: -18),
            clearDataButton.widthAnchor.constraint(equalToConstant: 18),
            clearDataButton.heightAnchor.constraint(equalToConstant: 18),
            clearDataButton.topAnchor.constraint(equalTo: clearDataLabel.topAnchor, constant: 5),
            
            deleteLabel.topAnchor.constraint(equalTo: clearDataDiscriptionLabel.bottomAnchor, constant: 16),
            deleteDiscriptionLabel.topAnchor.constraint(equalTo: deleteLabel.bottomAnchor, constant: 2),
            deleteDiscriptionLabel.leadingAnchor.constraint(equalTo: deleteLabel.leadingAnchor),
            
            deleteAccountButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 33),
            deleteAccountButton.trailingAnchor.constraint(equalTo: deleteLabel.leadingAnchor, constant: -18),
            deleteAccountButton.widthAnchor.constraint(equalToConstant: 18),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 18),
            deleteAccountButton.topAnchor.constraint(equalTo: deleteLabel.topAnchor, constant: 5),
            
            buttonStackView.topAnchor.constraint(equalTo: deleteDiscriptionLabel.bottomAnchor, constant: 26),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 22),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -22),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -22),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            okButton.heightAnchor.constraint(equalToConstant: 52),
            cancelButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    
    //MARK: - Buttons Actions -
    @objc private func clearDataButtonTapped(_ sender: UIButton) {
        sender.isSelected = true
        self.deleteAccountButton.isSelected = false
    }
    
    @objc private func deleteAccountButtonTapped(_ sender: UIButton) {
        sender.isSelected = true
        self.clearDataButton.isSelected = false
    }
    
    @objc private func okButtonTapped(_ sender: UIButton) {
        
        if clearDataButton.isSelected {
            let nukeDataModal = NukeDataModal()
            nukeDataModal.modalPresentationStyle = .overFullScreen
            nukeDataModal.modalTransitionStyle = .crossDissolve
            present(nukeDataModal, animated: true, completion: nil)
        } else {
            let nukeDataModal = DeleteAccountModel()
            nukeDataModal.modalPresentationStyle = .overFullScreen
            nukeDataModal.modalTransitionStyle = .crossDissolve
            present(nukeDataModal, animated: true, completion: nil)
        }
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

}
