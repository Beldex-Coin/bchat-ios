// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewRestoreSeedVC: BaseVC {
    
    private lazy var iconView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_seed")
        result.set(.width, to: 148)
        result.set(.height, to: 120)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var seedInfoLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xF0AF13)
        result.font = Fonts.boldOpenSans(ofSize: 17)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 2
        return result
    }()
    
    private lazy var seedView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var seedLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 0
        return result
    }()
    
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 6
        result.isLayoutMarginsRelativeArrangement = true
        
        return result
    }()
    
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var copySeedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Copy Seed", for: .normal)
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    
    private lazy var infoLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 18)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Restore Seed"
        
        self.seedInfoLabel.text = "Copy your Recovery Seed and\nkeep it safe."
        self.infoLabel.text = "Copy and save the seed to continue"
        self.seedLabel.text = "Ut34co m56m 77odo8 6ve66ne natis023 3diam0id 5accum s3an3 6383ut7 purus eges tas34f acilisis is0233 diam0 id5acc ums3an36383ut7p"
        
        view.addSubViews(seedInfoLabel, iconView, seedView)
        seedView.addSubview(seedLabel)
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(copySeedButton)
        buttonStackView.addArrangedSubview(saveButton)
        view.addSubViews(infoLabel, continueButton)
        
        
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            seedInfoLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 29),
            seedInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            seedView.topAnchor.constraint(equalTo: seedInfoLabel.bottomAnchor, constant: 38),
            seedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            seedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            seedLabel.topAnchor.constraint(equalTo: seedView.topAnchor, constant: 17),
            seedLabel.leadingAnchor.constraint(equalTo: seedView.leadingAnchor, constant: 12),
            seedLabel.trailingAnchor.constraint(equalTo: seedView.trailingAnchor, constant: -12),
            seedLabel.bottomAnchor.constraint(equalTo: seedView.bottomAnchor, constant: -25),
            
            
            buttonStackView.topAnchor.constraint(equalTo: seedView.bottomAnchor, constant: 14),
            buttonStackView.leadingAnchor.constraint(equalTo: seedView.leadingAnchor, constant: 0),
            buttonStackView.trailingAnchor.constraint(equalTo: seedView.trailingAnchor, constant: 0),
            buttonStackView.heightAnchor.constraint(equalToConstant: 48),
            saveButton.heightAnchor.constraint(equalToConstant: 48),
            copySeedButton.heightAnchor.constraint(equalToConstant: 48),
            
            
            
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            infoLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -14),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
            continueButton.heightAnchor.constraint(equalToConstant: 58),

        ])
        
    }
    

//    private lazy var apnsOptionView: OptionView = {
//        let explanation = NSLocalizedString("fast_mode_explanation", comment: "")
//        let result = OptionView(title: "Fast Mode", explanation: explanation, delegate: self, isRecommended: true)
//        result.accessibilityLabel = "Fast mode option"
//        return result
//    }()
//
//    private lazy var backgroundPollingOptionView: OptionView = {
//        let explanation = NSLocalizedString("slow_mode_explanation", comment: "")
//        let result = OptionView(title: "Slow Mode", explanation: explanation, delegate: self)
//        result.accessibilityLabel = "Slow mode option"
//        return result
//    }()
//
//    private let mnemonic: String = {
//        let identityManager = OWSIdentityManager.shared()
//        let databaseConnection = identityManager.value(forKey: "dbConnection") as! YapDatabaseConnection
//        var hexEncodedSeed: String! = databaseConnection.object(forKey: "BeldexSeed", inCollection: OWSPrimaryStorageIdentityKeyStoreCollection) as! String?
//        if hexEncodedSeed == nil {
//            hexEncodedSeed = identityManager.identityKeyPair()!.hexEncodedPrivateKey // Legacy account
//        }
//        return Mnemonic.encode(hexEncodedString: hexEncodedSeed)
//    }()
    
    
    
    // MARK: Button Actions :-
    @objc private func continueButtonTapped() {
        let vc = NewDesignSecretGroupVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}