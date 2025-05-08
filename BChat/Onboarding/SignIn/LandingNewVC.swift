// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit
import BChatUIKit

class LandingNewVC: BaseVC {
    var isChecked:Bool = false
    
    /// Create Button
    private lazy var createButton: UIButton = {
        let result = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.bothGreenColor
        result.layer.cornerRadius = Values.buttonRadius
        result.clipsToBounds = true
        result.setTitle(NSLocalizedString("CREATE_ACCOUNT_NEW", comment: ""), for: .normal)
        result.titleLabel!.font = Fonts.semiOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(createButtonActionTapped), for: .touchUpInside)
        result.setTitleColor(Colors.bothWhiteColor, for: .normal)
        return result
    }()
    
    /// Restore Button
    private lazy var restoreButton: UIButton = {
        let result = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor3
        result.layer.cornerRadius = Values.buttonRadius
        result.clipsToBounds = true
        result.setTitle(NSLocalizedString("RESTORE_ACCOUNT_NEW", comment: ""), for: .normal)
        result.titleLabel!.font = Fonts.semiOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(restoreButtonActionTapped), for: .touchUpInside)
        result.setTitleColor(Colors.titleColor3, for: .normal)
        result.layer.borderWidth = 1
        result.layer.borderColor = Colors.borderColorNew.cgColor
        return result
    }()
    
    /// Terms And Conditions Button
    private lazy var termsAndConditionsButton: UIButton = {
        let result = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.setTitle(NSLocalizedString("TERMS_AND_CONDITIONS_NEW", comment: ""), for: .normal)
        result.setTitleColor(Colors.textFieldPlaceHolderColor, for: .normal)
        result.contentHorizontalAlignment = .center
        result.titleLabel?.font = Fonts.OpenSans(ofSize: 14)
        result.addTarget(self, action: #selector(termsAndConditionsButtonActionTapped), for: .touchUpInside)
        return result
    }()
    
    /// Bottom Imge
    private lazy var bottomImge: UIImageView = {
        let result = UIImageView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .clear
        if let image = UIImage(named: "ic_bottomImg") {
            result.image = image
        }
        result.contentMode = .left
        return result
    }()
    
    /// Background Image
    private lazy var backgroundImage: UIImageView = {
        let result = UIImageView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .clear
        if let image = UIImage(named: "ic_NewLandingbg") {
            result.image = image
        }
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    /// Check Uncheck Button
    private lazy var checkUncheckButton: UIButton = {
        let result = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "ic_Newunchecked")
        result.tintColor = isLightMode ? .white : .white
        result.setImage(image, for: .normal)
        result.addTarget(self, action: #selector(checkedUncheckButtonActionTapped), for: .touchUpInside)
        return result
    }()

    // MARK: - UIViewController life cycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        self.navigationItem.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        WalletSharedData.sharedInstance.isCleardataStarting = false
        AppModeManager.shared.setCurrentAppMode(to: .dark)
        
        guard let navigationBar = navigationController?.navigationBar else { return }
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Colors.navigationBarBackgroundColor
            appearance.shadowColor = .clear
            navigationBar.standardAppearance = appearance;
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = Colors.navigationBarBackgroundColor
        }
        
        // Set up title label
        let titleLabel0 = UILabel()
        titleLabel0.textColor = Colors.titleColor4
        titleLabel0.font = Fonts.extraBoldOpenSans(ofSize: 28)
        titleLabel0.translatesAutoresizingMaskIntoConstraints = false
        titleLabel0.text = NSLocalizedString("WELCOME_TO_NEW", comment: "")
        
        // Set up Bchat logo
        let imageLogo = UIImageView()
        imageLogo.translatesAutoresizingMaskIntoConstraints = false
        imageLogo.backgroundColor = .clear
        imageLogo.image = UIImage(named: "ic_NewLandingLogo", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        imageLogo.contentMode = .scaleAspectFit
        
        // Set up title label
        let hellotitleLabel = UILabel()
        hellotitleLabel.translatesAutoresizingMaskIntoConstraints = false
        hellotitleLabel.textColor = Colors.titleColor4
        hellotitleLabel.font = Fonts.extraBoldOpenSans(ofSize: 28)
        hellotitleLabel.text = NSLocalizedString("HELLO_NEW", comment: "")
        
        let titleLabel2 = UILabel()
        titleLabel2.translatesAutoresizingMaskIntoConstraints = false
        titleLabel2.textColor = Colors.titleColor4
        titleLabel2.font = Fonts.extraBoldOpenSans(ofSize: 28)
        titleLabel2.text = NSLocalizedString("HELLO_SUBTITLE_NEW1", comment: "")
        titleLabel2.numberOfLines = 0
        titleLabel2.lineBreakMode = .byWordWrapping
        
        let titleLabel3 = UILabel()
        titleLabel3.translatesAutoresizingMaskIntoConstraints = false
        titleLabel3.textColor = Colors.titleColor4
        titleLabel3.font = Fonts.extraBoldOpenSans(ofSize: 28)
        titleLabel3.text = NSLocalizedString("HELLO_SUBTITLE_NEW2", comment: "")
        titleLabel3.numberOfLines = 0
        
        // Set up explanation label
        let explanationLabel = UILabel()
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.textColor = Colors.titleColor4
        explanationLabel.font = Fonts.lightOpenSans(ofSize: 14)
        explanationLabel.text = NSLocalizedString("HELLO_SUBTITLE_DECSC_NEW", comment: "")
        explanationLabel.numberOfLines = 0
        explanationLabel.textAlignment = .left
        
        view.addSubViews(titleLabel0)
        view.addSubViews(imageLogo)
        view.addSubViews(backgroundImage)
        view.addSubViews(hellotitleLabel)
        view.addSubViews(titleLabel2)
        view.addSubViews(titleLabel3)
        view.addSubViews(explanationLabel)
        view.addSubViews(createButton)
        view.addSubViews(restoreButton)
        view.addSubViews(termsAndConditionsButton)
        view.addSubViews(checkUncheckButton)
        view.addSubViews(bottomImge)
        
        NSLayoutConstraint.activate([
            titleLabel0.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            titleLabel0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 33),
            titleLabel0.heightAnchor.constraint(equalToConstant: 36),
            imageLogo.topAnchor.constraint(equalTo: titleLabel0.bottomAnchor, constant: 0),
            imageLogo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 33),
            imageLogo.heightAnchor.constraint(equalToConstant: 53),
            imageLogo.widthAnchor.constraint(equalToConstant: 255),
            backgroundImage.topAnchor.constraint(equalTo: titleLabel0.bottomAnchor, constant: -10),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            hellotitleLabel.topAnchor.constraint(equalTo: imageLogo.bottomAnchor, constant: 45),
            hellotitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 33),
            hellotitleLabel.heightAnchor.constraint(equalToConstant: 36),
            titleLabel2.topAnchor.constraint(equalTo: hellotitleLabel.bottomAnchor, constant: 5),
            titleLabel2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 33),
            titleLabel2.heightAnchor.constraint(equalToConstant: 36),
            titleLabel3.topAnchor.constraint(equalTo: titleLabel2.bottomAnchor, constant: -10),
            titleLabel3.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 33),
            titleLabel3.heightAnchor.constraint(equalToConstant: 36),
            explanationLabel.topAnchor.constraint(equalTo: titleLabel3.bottomAnchor, constant: 16),
            explanationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 33),
            explanationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -33),
            explanationLabel.heightAnchor.constraint(equalToConstant: 56),
            createButton.bottomAnchor.constraint(equalTo: restoreButton.topAnchor, constant: -14),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 59),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -59),
            createButton.heightAnchor.constraint(equalToConstant: 58),
            restoreButton.bottomAnchor.constraint(equalTo: termsAndConditionsButton.topAnchor, constant: -14),
            restoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 59),
            restoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -59),
            restoreButton.heightAnchor.constraint(equalToConstant: 58),
            termsAndConditionsButton.bottomAnchor.constraint(equalTo: bottomImge.topAnchor, constant: -10),
            termsAndConditionsButton.centerXAnchor.constraint(equalTo: restoreButton.centerXAnchor),
            checkUncheckButton.trailingAnchor.constraint(equalTo: termsAndConditionsButton.leadingAnchor, constant: -4),
            checkUncheckButton.centerYAnchor.constraint(equalTo: termsAndConditionsButton.centerYAnchor),
            checkUncheckButton.heightAnchor.constraint(equalToConstant: 25),
            checkUncheckButton.widthAnchor.constraint(equalToConstant: 25),
            bottomImge.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            bottomImge.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
            bottomImge.widthAnchor.constraint(equalToConstant: 100),
            bottomImge.heightAnchor.constraint(equalToConstant: 50),
        ])
        
    }
    
    /// View will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        guard let navigationBar = navigationController?.navigationBar else { return }
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Colors.cancelButtonBackgroundColor
            appearance.shadowColor = .clear
            navigationBar.standardAppearance = appearance;
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = Colors.cancelButtonBackgroundColor
        }
    }
    
    /// View Did Layout Subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createButton.layer.cornerRadius = Values.buttonRadius
        restoreButton.layer.cornerRadius = Values.buttonRadius
    }
    
    // MARK: - Navigation
    @objc private func checkedUncheckButtonActionTapped() {
        termsAndConditionsButton.isSelected = !termsAndConditionsButton.isSelected
        if termsAndConditionsButton.isSelected {
            isChecked = true
            createButton.backgroundColor = Colors.bothGreenColor
            let img = UIImage(named: "ic_Newcheckbox")!
            checkUncheckButton.tintColor = .white
            checkUncheckButton.setImage(img, for: .normal)
        } else {
            isChecked = false
            let img = UIImage(named: "ic_Newunchecked")!
            checkUncheckButton.tintColor = .white
            createButton.backgroundColor = Colors.bothGreenColor
            checkUncheckButton.setImage(img, for: .normal)
        }
    }
    
    /// Terms And Conditions Button Action Tapped
    @objc private func termsAndConditionsButtonActionTapped() {
        let urlAsString: String?
        urlAsString = bchat_TermsConditionUrl_Link
        if let urlAsString = urlAsString {
            let url = URL(string: urlAsString)!
            UIApplication.shared.open(url)
        }
    }
    
    /// Create Button Action Tapped
    @objc private func createButtonActionTapped() {
        if isChecked == true {
            let vc = DisplayNameNewVC()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Terms_Condition_Message) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
            })
        }
    }
    
    /// Restore Button Action Tapped
    @objc private func restoreButtonActionTapped() {
        let restoreVC = RestoreSeedNewVC()
        navigationController!.pushViewController(restoreVC, animated: true)
    }
}
