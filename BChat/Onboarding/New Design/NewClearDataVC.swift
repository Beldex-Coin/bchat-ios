// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewClearDataVC: BaseVC {
    
    
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
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Clear all data"
        return result
    }()
    
    private lazy var clearDataLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Clear Data From Device"
        return result
    }()
    
    private lazy var clearDataDiscriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0x6A6A77)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Delete data on this device"
        return result
    }()
    
    private lazy var deleteLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Delete Entire Account"
        return result
    }()
    
    private lazy var deleteDiscriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0x6A6A77)
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
        button.layer.cornerRadius = 23
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 23
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
        result.spacing = 11
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hexValue: 0x080812, a: 0.7)
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
            buttonStackView.heightAnchor.constraint(equalToConstant: 46),
            okButton.heightAnchor.constraint(equalToConstant: 46),
            cancelButton.heightAnchor.constraint(equalToConstant: 46),
            
            
        ])
        
    }
    
    
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