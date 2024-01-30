// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit
import BChatUIKit

public var navFlowTag = true

class LandingNewVC: BaseVC {
    private var spacer1HeightConstraint: NSLayoutConstraint!
    private var spacer2HeightConstraint: NSLayoutConstraint!
    private var spacer3HeightConstraint: NSLayoutConstraint!
    private var spacer4HeightConstraint: NSLayoutConstraint!
    private var spacer5HeightConstraint: NSLayoutConstraint!
    private var spacer6HeightConstraint: NSLayoutConstraint!
    private var spacer7HeightConstraint: NSLayoutConstraint!
    var isFlagValue:Bool = false
    
    // MARK: Components
    private lazy var createButton: UIButton = {
        let result = UIButton(type: .custom)
        result.backgroundColor = UIColor(hex: 0x3B3946)
        result.layer.cornerRadius = result.frame.height / 2
        result.clipsToBounds = true
        result.set(.height, to: 58)
        result.setTitle(NSLocalizedString("CREATE_ACCOUNT_NEW", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(isCreateButtonAction), for: UIControl.Event.touchUpInside)
        result.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        return result
    }()
    private lazy var restoreButton: UIButton = {
        let result = UIButton(type: .custom)
        result.backgroundColor = UIColor(hex: 0x3B3946)
        result.layer.cornerRadius = result.frame.height / 2
        result.clipsToBounds = true
        result.set(.height, to: 58)
        result.setTitle(NSLocalizedString("RESTORE_ACCOUNT_NEW", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(isRestoreButtonAction), for: UIControl.Event.touchUpInside)
        result.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        return result
    }()
    private lazy var isTermsAndConditionsButton: UIButton = {
        let result = UIButton(type: .custom)
        result.setTitle(NSLocalizedString("TERMS_AND_CONDITIONS_NEW", comment: ""), for: .normal)
        result.setTitleColor(UIColor(hex: 0xA7A7BA), for: .normal)
        result.contentHorizontalAlignment = .left
        result.titleLabel?.font = Fonts.OpenSans(ofSize: 14)
        result.addTarget(self, action: #selector(isTermsAndConditionsButtonAction), for: .touchUpInside)
        return result
    }()
    private lazy var isBottomImge: UIImageView = {
        let result = UIImageView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .clear
        result.set(.height, to: 45)
        result.set(.width, to: 100)
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
        result.set(.height, to: 246)
        result.set(.width, to: 246)
        if let image = UIImage(named: "ic_NewLandingbg") {
            result.image = image
        }
        result.contentMode = .scaleAspectFit
        return result
    }()
    private lazy var isCheckedOrNotButton: UIButton = {
        let result = UIButton(type: .system)
        let image = UIImage(named: "ic_Newunchecked")
        let resizedImage = image?.scaled(to: CGSize(width: 25.0, height: 25.0))
        result.tintColor = isLightMode ? .white : .white
        result.setImage(resizedImage, for: .normal)
        result.addTarget(self, action: #selector(isCheckedOrNotButtonAction), for: UIControl.Event.touchUpInside)
        return result
    }()
    private lazy var isPasteViewContainer: UIStackView = {
        let result = UIStackView()
        result.axis = .horizontal
        result.spacing = UIDevice.current.isIPad ? Values.iPadButtonSpacing : Values.verySmallSpacing
        result.distribution = .fillProportionally
        result.alignment = .center
        if (UIDevice.current.isIPad) {
            result.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            result.isLayoutMarginsRelativeArrangement = true
        }
        return result
    }()
    private lazy var bottomView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.set(.width, to: 80)
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpGradientBackground()
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
        view.addSubview(isbackgroundImg)
        
        let spacer1 = UIView()
        spacer1HeightConstraint = spacer1.set(.height, to: 220)
        let spacer2 = UIView()
        spacer2HeightConstraint = spacer2.set(.height, to: isIPhone5OrSmaller ? Values.smallSpacing : Values.veryLargeSpacing)
        let spacer3 = UIView()
        spacer3HeightConstraint = spacer3.set(.height, to: 30)
        let spacer4 = UIView()
        spacer4HeightConstraint = spacer4.set(.height, to: isIPhone5OrSmaller ? Values.smallSpacing : Values.veryLargeSpacing)
        let spacer5 = UIView()
        spacer5HeightConstraint = spacer5.set(.height, to: 16)
        let spacer6 = UIView()
        spacer6HeightConstraint = spacer6.set(.height, to: isIPhone5OrSmaller ? Values.smallSpacing : Values.veryLargeSpacing)
        let spacer7 = UIView()
        spacer7HeightConstraint = spacer7.set(.height, to: 10)
        
        // Set up restore button container
        let createButtonContainer = UIView(wrapping: createButton, withInsets: UIEdgeInsets(top: 0, leading: 21, bottom: 0, trailing: 21), shouldAdaptForIPadWithWidth: Values.iPadButtonWidth)
        let restoreButtonContainer = UIView(wrapping: restoreButton, withInsets: UIEdgeInsets(top: 0, leading: 21, bottom: 0, trailing: 21), shouldAdaptForIPadWithWidth: Values.iPadButtonWidth)
        
        let img = UIImage(named: "ic_Newunchecked")!
        let resizedImage = img.scaled(to: CGSize(width: 25.0, height: 25.0))
        isCheckedOrNotButton.tintColor = isLightMode ? .white : .white
        isCheckedOrNotButton.setImage(resizedImage, for: .normal)
        
        // Set up title label
        let titleLabel0 = UILabel()
        titleLabel0.textColor = UIColor(hex: 0xFFFFFF)
        titleLabel0.font = Fonts.boldOpenSans(ofSize: 28)
        titleLabel0.text = NSLocalizedString("WELCOME_TO_NEW", comment: "")
        
        // Set up Bchat logo
        let imageLogo = UIImageView()
        imageLogo.translatesAutoresizingMaskIntoConstraints = false
        imageLogo.backgroundColor = .clear
        imageLogo.set(.height, to: 53)
        imageLogo.set(.width, to: 255.35)
        // Set the image for the UIImageView
        if let image = UIImage(named: "ic_NewLandingLogo") {
            imageLogo.image = image
        }
        imageLogo.contentMode = .left
        
        // Set up title label
        let hellotitleLabel = UILabel()
        hellotitleLabel.textColor = UIColor(hex: 0xFFFFFF)
        hellotitleLabel.font = Fonts.boldOpenSans(ofSize: 28)
        hellotitleLabel.text = NSLocalizedString("HELLO_NEW", comment: "")
        
        let titleLabel2 = UILabel()
        titleLabel2.textColor = UIColor(hex: 0xFFFFFF)
        titleLabel2.font = Fonts.boldOpenSans(ofSize: 28)
        titleLabel2.text = NSLocalizedString("HELLO_SUBTITLE_NEW", comment: "")
        titleLabel2.numberOfLines = 0
        titleLabel2.lineBreakMode = .byWordWrapping
        // Set up explanation label
        let explanationLabel = UILabel()
        explanationLabel.textColor = UIColor(hex: 0xFFFFFF)
        explanationLabel.font = Fonts.OpenSans(ofSize: 14)
        explanationLabel.text = NSLocalizedString("HELLO_SUBTITLE_DECSC_NEW", comment: "")
        explanationLabel.numberOfLines = 0
        explanationLabel.lineBreakMode = .byWordWrapping
        // Set up spacers
        let topSpacer = UIView.vStretchingSpacer()
        let bottomSpacer = UIView.vStretchingSpacer()
        
        // Set up button stack view
        let buttonStackView = UIStackView(arrangedSubviews: [ isBottomImge ])
        buttonStackView.axis = .vertical
        buttonStackView.spacing = isIPhone5OrSmaller ? Values.mediumSpacing : Values.largeSpacing
        buttonStackView.alignment = .fill
        if UIDevice.current.isIPad {
            createButton.set(.width, to: Values.iPadButtonWidth)
            isBottomImge.set(.width, to: Values.iPadButtonWidth)
            buttonStackView.alignment = .center
        }
        // Set up button stack view container
        let buttonStackViewContainer = UIView()
        buttonStackViewContainer.addSubview(buttonStackView)
        buttonStackView.pin(.leading, to: .leading, of: buttonStackViewContainer, withInset: Values.veryLargeSpacing)
        buttonStackView.pin(.top, to: .top, of: buttonStackViewContainer)
        buttonStackViewContainer.pin(.trailing, to: .trailing, of: buttonStackView, withInset: Values.veryLargeSpacing)
        buttonStackViewContainer.pin(.bottom, to: .bottom, of: buttonStackView, withInset: isIPhone5OrSmaller ? 6 : 10)
        
        isPasteViewContainer.addArrangedSubview(bottomView)
        isPasteViewContainer.addArrangedSubview(isCheckedOrNotButton)
        isPasteViewContainer.addArrangedSubview(isTermsAndConditionsButton)
        
        // Set up top stack view
        let topStackView = UIStackView(arrangedSubviews: [ titleLabel0, imageLogo, spacer2, hellotitleLabel, spacer7, titleLabel2, spacer4, explanationLabel, spacer1, createButtonContainer, spacer5, restoreButtonContainer, spacer3, isPasteViewContainer ])
        topStackView.axis = .vertical
        topStackView.spacing = 0
        topStackView.alignment = .fill
        // Set up top stack view container
        let topStackViewContainer = UIView()
        topStackViewContainer.addSubview(topStackView)
        topStackView.pin(.leading, to: .leading, of: topStackViewContainer, withInset: Values.veryLargeSpacing)
        topStackView.pin(.top, to: .top, of: topStackViewContainer)
        topStackViewContainer.pin(.trailing, to: .trailing, of: topStackView, withInset: Values.veryLargeSpacing)
        topStackViewContainer.pin(.bottom, to: .bottom, of: topStackView)
        // Set up main stack view
        let mainStackView = UIStackView(arrangedSubviews: [ topSpacer, topStackViewContainer, bottomSpacer, buttonStackViewContainer ])
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        view.addSubview(mainStackView)
        mainStackView.pin(to: view)
        topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor, multiplier: 0.1).isActive = true
        
        NSLayoutConstraint.activate([
            isbackgroundImg.topAnchor.constraint(equalTo: titleLabel0.bottomAnchor, constant: 0),
            isbackgroundImg.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
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
        isFlagValue = false
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
            let resizedImage = img.scaled(to: CGSize(width: 25.0, height: 25.0))
            isCheckedOrNotButton.tintColor = .white
            isCheckedOrNotButton.setImage(resizedImage, for: .normal)
        }else {
            isFlagValue = false
            let img = UIImage(named: "ic_Newunchecked")!
            let resizedImage = img.scaled(to: CGSize(width: 25.0, height: 25.0))
            isCheckedOrNotButton.tintColor = .white
            createButton.backgroundColor = UIColor(hex: 0x3B3946)
            isCheckedOrNotButton.setImage(resizedImage, for: .normal)
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
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DisplayNameVC") as! DisplayNameVC
            navigationflowTag = false
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Terms_Condition_Message) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
                
            })
        }
    }
    
    @objc private func isRestoreButtonAction() {
        let restoreVC = RestoreVC()
        navigationflowTag = true
        navigationController!.pushViewController(restoreVC, animated: true)
    }
}

