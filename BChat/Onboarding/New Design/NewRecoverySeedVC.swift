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
        result.textColor = Colors.yellowColor
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
        stackView.backgroundColor = Colors.seedBackgroundColor
        stackView.layer.cornerRadius = 16
         stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.noBorderColor2.cgColor
        return stackView
    }()
    
    private lazy var seedLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = ""
        result.adjustsFontSizeToFitWidth = true
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Copy", for: .normal)
        let image = UIImage(named: "ic_copy_recovery")?.scaled(to: CGSize(width: 18.0, height: 18.0))
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 0, right: 0)
        button.semanticContentAttribute = .forceRightToLeft
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
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
    
    
    private let mnemonic: String = {
        let identityManager = OWSIdentityManager.shared()
        let databaseConnection = identityManager.value(forKey: "dbConnection") as! YapDatabaseConnection
        var hexEncodedSeed: String! = databaseConnection.object(forKey: "BeldexSeed", inCollection: OWSPrimaryStorageIdentityKeyStoreCollection) as! String?
        if hexEncodedSeed == nil {
            hexEncodedSeed = identityManager.identityKeyPair()!.hexEncodedPrivateKey // Legacy account
        }
        return Mnemonic.encode(hexEncodedString: hexEncodedSeed)
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.mainBackGroundColor2//UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Recovery Seed", style: .plain, target: nil, action: nil)
        
        view.addSubViews(iconImageView, infoLabel, seedView)
        seedView.addSubview(seedLabel)
        view.addSubview(copyButton)
        self.seedLabel.text = mnemonic
        
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
        UIPasteboard.general.string = mnemonic
        copyButton.isUserInteractionEnabled = false
        UIView.transition(with: copyButton, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.copyButton.setTitle(NSLocalizedString("Copied", comment: ""), for: UIControl.State.normal)
        }, completion: nil)
        Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(enableCopyButton), userInfo: nil, repeats: false)
    }

    @objc private func enableCopyButton() {
        copyButton.isUserInteractionEnabled = true
        UIView.transition(with: copyButton, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.copyButton.setTitle(NSLocalizedString("Copy", comment: ""), for: UIControl.State.normal)
        }, completion: nil)
    }
    

}
