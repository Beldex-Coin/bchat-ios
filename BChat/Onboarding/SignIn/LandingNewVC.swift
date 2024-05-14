// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit
import BChatUIKit

public var navFlowTag = true

class LandingNewVC: BaseVC {
    var isFlagValue:Bool = false
    private lazy var createButton: UIButton = {
        let result = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.bchatButtonColor
        result.layer.cornerRadius = result.frame.height / 2
        result.clipsToBounds = true
        result.setTitle(NSLocalizedString("CREATE_ACCOUNT_NEW", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(isCreateButtonAction), for: UIControl.Event.touchUpInside)
        result.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        return result
    }()
    private lazy var restoreButton: UIButton = {
        let result = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x3B3946)
        result.layer.cornerRadius = result.frame.height / 2
        result.clipsToBounds = true
        result.setTitle(NSLocalizedString("RESTORE_ACCOUNT_NEW", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(isRestoreButtonAction), for: UIControl.Event.touchUpInside)
        result.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        return result
    }()
    private lazy var isTermsAndConditionsButton: UIButton = {
        let result = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.setTitle(NSLocalizedString("TERMS_AND_CONDITIONS_NEW", comment: ""), for: .normal)
        result.setTitleColor(UIColor(hex: 0xA7A7BA), for: .normal)
        result.contentHorizontalAlignment = .center
        result.titleLabel?.font = Fonts.OpenSans(ofSize: 14)
        result.addTarget(self, action: #selector(isTermsAndConditionsButtonAction), for: .touchUpInside)
        return result
    }()
    private lazy var isBottomImge: UIImageView = {
        let result = UIImageView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .clear
        if let image = UIImage(named: "ic_bottomImg") {
            result.image = image
        }
        result.contentMode = .left
        return result
    }()
    private lazy var isbackgroundImg: UIImageView = {
        let result = UIImageView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .clear
        if let image = UIImage(named: "ic_NewLandingbg") {
            result.image = image
        }
        result.contentMode = .scaleAspectFit
        return result
    }()
    private lazy var isCheckedOrNotButton: UIButton = {
        let result = UIButton()
        result.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "ic_Newunchecked")
        result.tintColor = isLightMode ? .white : .white
        result.setImage(image, for: .normal)
        result.addTarget(self, action: #selector(isCheckedOrNotButtonAction), for: UIControl.Event.touchUpInside)
        return result
    }()

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
        titleLabel0.textColor = UIColor(hex: 0xFFFFFF)
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
        hellotitleLabel.textColor = UIColor(hex: 0xFFFFFF)
        hellotitleLabel.font = Fonts.extraBoldOpenSans(ofSize: 28)
        hellotitleLabel.text = NSLocalizedString("HELLO_NEW", comment: "")
        
        let titleLabel2 = UILabel()
        titleLabel2.translatesAutoresizingMaskIntoConstraints = false
        titleLabel2.textColor = UIColor(hex: 0xFFFFFF)
        titleLabel2.font = Fonts.extraBoldOpenSans(ofSize: 28)
        titleLabel2.text = NSLocalizedString("HELLO_SUBTITLE_NEW1", comment: "")
        titleLabel2.numberOfLines = 0
        titleLabel2.lineBreakMode = .byWordWrapping
        
        let titleLabel3 = UILabel()
        titleLabel3.translatesAutoresizingMaskIntoConstraints = false
        titleLabel3.textColor = UIColor(hex: 0xFFFFFF)
        titleLabel3.font = Fonts.boldOpenSans(ofSize: 28)
        titleLabel3.text = NSLocalizedString("HELLO_SUBTITLE_NEW2", comment: "")
        titleLabel3.numberOfLines = 0
        
        // Set up explanation label
        let explanationLabel = UILabel()
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.textColor = UIColor(hex: 0xFFFFFF)
        explanationLabel.font = Fonts.lightOpenSans(ofSize: 14)
        explanationLabel.text = NSLocalizedString("HELLO_SUBTITLE_DECSC_NEW", comment: "")
        explanationLabel.numberOfLines = 0
        explanationLabel.textAlignment = .left
        
        view.addSubViews(titleLabel0)
        view.addSubViews(imageLogo)
        view.addSubViews(isbackgroundImg)
        view.addSubViews(hellotitleLabel)
        view.addSubViews(titleLabel2)
        view.addSubViews(titleLabel3)
        view.addSubViews(explanationLabel)
        view.addSubViews(createButton)
        view.addSubViews(restoreButton)
        view.addSubViews(isTermsAndConditionsButton)
        view.addSubViews(isCheckedOrNotButton)
        view.addSubViews(isBottomImge)
        
        NSLayoutConstraint.activate([
            titleLabel0.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            titleLabel0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 33),
            titleLabel0.heightAnchor.constraint(equalToConstant: 36),
            imageLogo.topAnchor.constraint(equalTo: titleLabel0.bottomAnchor, constant: 0),
            imageLogo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 33),
            imageLogo.heightAnchor.constraint(equalToConstant: 53),
            imageLogo.widthAnchor.constraint(equalToConstant: 255),
            isbackgroundImg.topAnchor.constraint(equalTo: titleLabel0.bottomAnchor, constant: -10),
            isbackgroundImg.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
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
            restoreButton.bottomAnchor.constraint(equalTo: isTermsAndConditionsButton.topAnchor, constant: -14),
            restoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 59),
            restoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -59),
            restoreButton.heightAnchor.constraint(equalToConstant: 58),
            isTermsAndConditionsButton.bottomAnchor.constraint(equalTo: isBottomImge.topAnchor, constant: -10),
            isTermsAndConditionsButton.centerXAnchor.constraint(equalTo: restoreButton.centerXAnchor),
            isCheckedOrNotButton.trailingAnchor.constraint(equalTo: isTermsAndConditionsButton.leadingAnchor, constant: -8),
            isCheckedOrNotButton.centerYAnchor.constraint(equalTo: isTermsAndConditionsButton.centerYAnchor),
            isCheckedOrNotButton.heightAnchor.constraint(equalToConstant: 16),
            isCheckedOrNotButton.widthAnchor.constraint(equalToConstant: 16),
            isBottomImge.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            isBottomImge.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
            isBottomImge.widthAnchor.constraint(equalToConstant: 100),
            isBottomImge.heightAnchor.constraint(equalToConstant: 50),
        ])
        
    }
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createButton.layer.cornerRadius = createButton.bounds.height / 2
        restoreButton.layer.cornerRadius = restoreButton.bounds.height / 2
    }
    
    // MARK: - Navigation
    @objc private func isCheckedOrNotButtonAction() {
        isTermsAndConditionsButton.isSelected = !isTermsAndConditionsButton.isSelected
        if isTermsAndConditionsButton.isSelected {
            isFlagValue = true
            createButton.backgroundColor = Colors.bchatButtonColor
            let img = UIImage(named: "ic_Newcheckbox")!
            isCheckedOrNotButton.tintColor = .white
            isCheckedOrNotButton.setImage(img, for: .normal)
        }else {
            isFlagValue = false
            let img = UIImage(named: "ic_Newunchecked")!
            isCheckedOrNotButton.tintColor = .white
            createButton.backgroundColor = Colors.bchatButtonColor
            isCheckedOrNotButton.setImage(img, for: .normal)
        }
    }
    
    @objc private func isTermsAndConditionsButtonAction() {
        let urlAsString: String?
        urlAsString = bchat_TermsConditionUrl_Link
        if let urlAsString = urlAsString {
            let url = URL(string: urlAsString)!
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func isCreateButtonAction() {
        if isFlagValue == true {
            let vc = DisplayNameNewVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Terms_Condition_Message) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
            })
        }
    }
    
    @objc private func isRestoreButtonAction() {
        let restoreVC = RestoreSeedNewVC()
        navigationController!.pushViewController(restoreVC, animated: true)
    }
}
