// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewAlertRecoverySeedVC: BaseVC {
    
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.smallBackGroundColor
        stackView.layer.cornerRadius = 20
         stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.noBorderColor.cgColor
        return stackView
    }()
     
    lazy var iconImageView: UIImageView = {
       let result = UIImageView()
       result.image = UIImage(named: "ic_important")
        result.set(.width, to: 78)
        result.set(.height, to: 78)
       result.layer.masksToBounds = true
       result.contentMode = .scaleToFill
        result.layer.cornerRadius = 18
       return result
   }()
    
    private lazy var importantLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Important"
        result.adjustsFontSizeToFitWidth = true
        return result
    }()
    
    private lazy var label1: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("NEVER_SHARE_YOUR_SEED_WITH_ANYONE", comment: "")
        result.adjustsFontSizeToFitWidth = true
        return result
    }()
    
    private lazy var label2: UILabel = {
        let result = UILabel()
        result.textColor = Colors.cancelButtonTitleColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("RECOVERY_SEED_DISCRIPTION", comment: "")
        result.adjustsFontSizeToFitWidth = true
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    private lazy var label3: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "RECOVERY_SEED_DISCRIPTION2"
        result.adjustsFontSizeToFitWidth = true
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Yes, I’m Safe :)", for: .normal)
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.cancelButtonBackgroundColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Recovery Seed", style: .plain, target: nil, action: nil)
        
        view.addSubview(backGroundView)
        backGroundView.addSubViews(iconImageView, importantLabel, label1, label2, label3, nextButton)
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            iconImageView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 38),
            iconImageView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            importantLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 7),
            importantLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            label1.topAnchor.constraint(equalTo: importantLabel.bottomAnchor, constant: 26),
            label1.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 0),
            label2.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 26),
            label2.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -21),
            
            label3.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 24),
            label3.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 49),
            label3.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -44),
            
            nextButton.topAnchor.constraint(equalTo: label3.bottomAnchor, constant: 19),
            nextButton.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -42),
            nextButton.heightAnchor.constraint(equalToConstant: 48),
            nextButton.widthAnchor.constraint(equalToConstant: 180)
            
            ])
    }
    

    @objc private func nextButtonTapped(_ sender: UIButton) {
        let vc = NewPasswordVC()
        vc.isGoingNewRecoverySeed = true
        vc.isVerifyPassword = true
        navigationController!.pushViewController(vc, animated: true)
    }
    
    
   

}
