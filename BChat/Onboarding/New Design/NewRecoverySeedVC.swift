// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewRecoverySeedVC: BaseVC {
    
    
    
    lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_recovery_seed")
        result.set(.width, to: 148)
        result.set(.height, to: 120)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var infoLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xF0AF13)
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Copy your Recovery Seed and\nkeep it safe."
        result.adjustsFontSizeToFitWidth = true
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    private lazy var seedView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x111119)
        stackView.layer.cornerRadius = 16
         stackView.layer.borderWidth = 1
         stackView.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        return stackView
    }()
    
    private lazy var seedLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0x00BD40)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Lorem ipsum dolor sit amet consectetur adipiscing elit Ut et massa mi. Aliquam in hendrerit urna. Pellentesque sit amet sapien fringilla, mattis ligula consectetur,."
        result.adjustsFontSizeToFitWidth = true
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Copy", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 18)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        button.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var copyImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_copy")
        result.set(.width, to: 18)
        result.set(.height, to: 18)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Recovery Seed", style: .plain, target: nil, action: nil)
        
        view.addSubViews(iconImageView, infoLabel, seedView)
        seedView.addSubview(seedLabel)
        view.addSubview(copyButton)
        
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 33),
            
            seedView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 19),
            seedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            seedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            seedLabel.topAnchor.constraint(equalTo: seedView.topAnchor, constant: 16),
            seedLabel.leadingAnchor.constraint(equalTo: seedView.leadingAnchor, constant: 26),
            seedLabel.trailingAnchor.constraint(equalTo: seedView.trailingAnchor, constant: -25),
            seedLabel.bottomAnchor.constraint(equalTo: seedView.bottomAnchor, constant: -26),
            
            copyButton.topAnchor.constraint(equalTo: seedView.bottomAnchor, constant: 14),
            copyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            copyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            copyButton.heightAnchor.constraint(equalToConstant: 58)
            
            ])
    }
    
    
    @objc private func copyButtonTapped(_ sender: UIButton) {
        
    }

    

}
