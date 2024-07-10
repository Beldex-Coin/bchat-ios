// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import Sodium
import PromiseKit

class NewRestoreSeedVC: BaseVC, UITextFieldDelegate, OptionViewDelegate {
    
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
        result.textColor = Colors.yellowColor
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
        stackView.backgroundColor = Colors.cellGroundColor2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var seedLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
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
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var copySeedButton: UIButton = {
        let button = UIButton()
        button.setTitle("Copy Seed", for: .normal)
        let image = UIImage(named: "ic_copySeed")?.scaled(to: CGSize(width: 12.0, height: 12.0))
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.semanticContentAttribute = .forceRightToLeft
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor3
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        return button
    }()    
    
    private lazy var infoLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.textFieldPlaceHolderColor
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
        button.backgroundColor = Colors.cellGroundColor2
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private var optionViews: [OptionView] {
        [ apnsOptionView, backgroundPollingOptionView ]
    }
    
    private var selectedOptionView: OptionView? {
        return optionViews.first { $0.isSelected }
    }
    
    func optionViewDidActivate(_ optionView: OptionView) {
        optionViews.filter { $0 != optionView }.forEach { $0.isSelected = false }
    }
    
    // MARK: Components
    private lazy var apnsOptionView: OptionView = {
        let explanation = NSLocalizedString("fast_mode_explanation", comment: "")
        let result = OptionView(title: "Fast Mode", explanation: explanation, delegate: self, isRecommended: true)
        result.accessibilityLabel = "Fast mode option"
        return result
    }()
    
    private lazy var backgroundPollingOptionView: OptionView = {
        let explanation = NSLocalizedString("slow_mode_explanation", comment: "")
        let result = OptionView(title: "Slow Mode", explanation: explanation, delegate: self)
        result.accessibilityLabel = "Slow mode option"
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
    
    var seedcopy = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Recovery Seed"
        
        self.seedInfoLabel.text = "Copy your Recovery Seed and\nkeep it safe."
        self.infoLabel.text = "Copy and save the seed to continue"
        self.seedLabel.text = "\(mnemonic)"
        
        view.addSubViews(seedInfoLabel, iconView, seedView)
        seedView.addSubview(seedLabel)
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(copySeedButton)
        buttonStackView.addArrangedSubview(saveButton)
        view.addSubViews(infoLabel, continueButton)
        
        self.infoLabel.isHidden = false
        
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
     
    
    // MARK: Button Actions :-
    @objc private func continueButtonTapped() {
        if seedcopy == true {
            UserDefaults.standard[.isUsingFullAPNs] = true//(selectedOptionView == apnsOptionView)
            TSAccountManager.sharedInstance().didRegister()
            let homeVC = HomeVC()
            navigationController!.setViewControllers([ homeVC ], animated: true)
            let syncTokensJob = SyncPushTokensJob(accountManager: AppEnvironment.shared.accountManager, preferences: Environment.shared.preferences)
            syncTokensJob.uploadOnlyIfStale = false
            let _: Promise<Void> = syncTokensJob.run()
        } else {
            self.showToast(message: "Please copy the Seed...", seconds: 1.0)
        }
    }
    
    @objc private func copyButtonTapped() {
        continueButton.backgroundColor = Colors.bothGreenColor
        self.showToast(message: "Copied", seconds: 1.0)
        UIPasteboard.general.string = mnemonic
        seedcopy = true
        self.infoLabel.isHidden = true
    }
    
    @objc private func saveButtonTapped() {
        continueButton.backgroundColor = Colors.bothGreenColor
//        self.showToastMsg(message: "Please save the seed", seconds: 1.0)
        UIPasteboard.general.string = mnemonic
        seedcopy = true
        self.infoLabel.isHidden = true
        
        let shareVC = UIActivityViewController(activityItems: [ mnemonic ], applicationActivities: nil)
        if UIDevice.current.isIPad {
            shareVC.excludedActivityTypes = []
            shareVC.popoverPresentationController?.permittedArrowDirections = []
            shareVC.popoverPresentationController?.sourceView = self.view
            shareVC.popoverPresentationController?.sourceRect = self.view.bounds
        }
        self.navigationController!.present(shareVC, animated: true, completion: nil)        
    }
    

}
