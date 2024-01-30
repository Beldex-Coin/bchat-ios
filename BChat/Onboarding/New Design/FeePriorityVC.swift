// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class FeePriorityVC: BaseVC {

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
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Fee Priority"
        return result
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
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
        button.backgroundColor = UIColor(hex: 0x1C1C26)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var slowButton: UIButton = {
        let button = UIButton()
        button.setTitle("Slow", for: .normal)
        button.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x1C1C26)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(slowButtonButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hexValue: 0x080812, a: 0.7)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, closeButton, flashButton, slowButton)
        
        
        flashButton.layer.borderWidth = 2
        flashButton.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        flashButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        flashButton.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        
        slowButton.layer.borderWidth = 1
        slowButton.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        slowButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        slowButton.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
        
        
        
        
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
        
        
    }
    

    
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc private func flashButtonTapped(_ sender: UIButton) {
        flashButton.layer.borderWidth = 2
        flashButton.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        flashButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        flashButton.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        
        slowButton.layer.borderWidth = 1
        slowButton.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        slowButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        slowButton.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
        
    }
    
    @objc private func slowButtonButtonTapped(_ sender: UIButton) {
        slowButton.layer.borderWidth = 2
        slowButton.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        slowButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 18)
        slowButton.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        
        flashButton.layer.borderWidth = 1
        flashButton.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        flashButton.titleLabel?.font = Fonts.boldOpenSans(ofSize: 16)
        flashButton.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
        
    }
    
   

}
