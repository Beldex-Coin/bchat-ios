// Copyright © 2022 Beldex International. All rights reserved.

@objc
final class CallPermissionRequestModal : Modal {

    // MARK: Lifecycle
    @objc
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Use init(onCallEnabled:) instead.")
    }

    override init(nibName: String?, bundle: Bundle?) {
        preconditionFailure("Use init(onCallEnabled:) instead.")
    }

    override func populateContentView() {
        // Title
        let titleLabel = UILabel()
        titleLabel.textColor = Colors.text
        titleLabel.font = Fonts.boldOpenSans(ofSize: Values.mediumFontSize)
        titleLabel.text = NSLocalizedString("modal_call_permission_request_title", comment: "")
        titleLabel.textAlignment = .center
        // Message
        let messageLabel = UILabel()
        messageLabel.textColor = Colors.text
        messageLabel.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        let message = NSLocalizedString("modal_call_permission_request_explanation", comment: "")
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textAlignment = .center
        
        // Cancel button
        let cancelButtonForCall = UIButton()
        cancelButtonForCall.set(.height, to: Values.mediumButtonHeight)
        cancelButtonForCall.layer.cornerRadius = 17//Modal.buttonCornerRadius
        if isDarkMode {
            cancelButtonForCall.backgroundColor = Colors.buttonBackground
        }else {
            cancelButtonForCall.backgroundColor = UIColor.lightGray
        }
        cancelButtonForCall.titleLabel!.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        cancelButtonForCall.setTitle(NSLocalizedString("cancel", comment: ""), for: UIControl.State.normal)
        cancelButtonForCall.addTarget(self, action: #selector(cancelButtonForCallAction), for: .touchUpInside)
        
        // Enable button
        let goToSettingsButton = UIButton()
        goToSettingsButton.set(.height, to: Values.mediumButtonHeight)
        goToSettingsButton.layer.cornerRadius = 17//Modal.buttonCornerRadius
        if isDarkMode {
            goToSettingsButton.backgroundColor = Colors.bchatJoinOpenGpBackgroundGreen
            goToSettingsButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        }else {
            goToSettingsButton.backgroundColor = Colors.bchatJoinOpenGpBackgroundGreen
            goToSettingsButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        }
        goToSettingsButton.titleLabel!.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        goToSettingsButton.setTitle(NSLocalizedString("vc_settings_title", comment: ""), for: UIControl.State.normal)
        goToSettingsButton.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        // Content stack view
        let contentStackView = UIStackView(arrangedSubviews: [ titleLabel, messageLabel ])
        contentStackView.axis = .vertical
        contentStackView.spacing = Values.largeSpacing
        // Button stack view
        let buttonStackView = UIStackView(arrangedSubviews: [ cancelButtonForCall, goToSettingsButton ])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = Values.mediumSpacing
        buttonStackView.distribution = .fillEqually
        // Main stack view
        let spacing = Values.largeSpacing - Values.smallFontSize / 2
        let mainStackView = UIStackView(arrangedSubviews: [ contentStackView, buttonStackView ])
        mainStackView.axis = .vertical
        mainStackView.spacing = spacing
        contentView.addSubview(mainStackView)
        mainStackView.pin(.leading, to: .leading, of: contentView, withInset: Values.largeSpacing)
        mainStackView.pin(.top, to: .top, of: contentView, withInset: Values.largeSpacing)
        contentView.pin(.trailing, to: .trailing, of: mainStackView, withInset: Values.largeSpacing)
        contentView.pin(.bottom, to: .bottom, of: mainStackView, withInset: spacing)
    }

    // MARK: Interaction
//    @objc func goToSettings(_ sender: Any) {
//        dismiss(animated: true, completion: {
//            if let vc = CurrentAppContext().frontmostViewController() {
//                let privacySettingsVC = PrivacySettingsTableViewController()
//                privacySettingsVC.shouldShowCloseButton = true
//                let nav = OWSNavigationController(rootViewController: privacySettingsVC)
//                nav.modalPresentationStyle = .fullScreen
//                vc.present(nav, animated: true, completion: nil)
//            }
//        })
//    }
    
    @objc func goToSettings(_ sender: Any) {
        dismiss(animated: true, completion: {
            if let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                let bChatSettingsNewVC = BChatSettingsNewVC()
                navController.pushViewController(bChatSettingsNewVC, animated: true)
            }
        })
    }
    
    @objc func cancelButtonForCallAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .showInputViewNotification, object: nil)
    }
    
}





@objc
final class PayAsYouChatPermissionRequestModal : Modal {

    // MARK: Lifecycle
    @objc
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Use init(onCallEnabled:) instead.")
    }

    override init(nibName: String?, bundle: Bundle?) {
        preconditionFailure("Use init(onCallEnabled:) instead.")
    }

    override func populateContentView() {
        
        let theImageView = UIImageView()
        theImageView.layer.masksToBounds = true
        theImageView.image = UIImage(named: "ic_popUpImage")
        theImageView.contentMode = .scaleAspectFit
        
        // Title
        let titleLabel = UILabel()
        titleLabel.textColor = Colors.text
        titleLabel.font = Fonts.boldOpenSans(ofSize: Values.mediumFontSize)
        titleLabel.text = NSLocalizedString("modal_pay_as_you_chat_permission_request_title", comment: "")
        titleLabel.textAlignment = .center
        // Message
        let messageLabel = UILabel()
        messageLabel.textColor = Colors.text
        messageLabel.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        let message = NSLocalizedString("modal_pay_as_you_chat_permission_request_explanation", comment: "")
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textAlignment = .center
        
        // Cancel button
        let cancelButtonPayAsChat = UIButton()
        cancelButtonPayAsChat.set(.height, to: Values.mediumButtonHeight)
        cancelButtonPayAsChat.layer.cornerRadius = Modal.buttonCornerRadius
        if isDarkMode {
            cancelButtonPayAsChat.backgroundColor = Colors.buttonBackground
        }else {
            cancelButtonPayAsChat.backgroundColor = UIColor.lightGray
        }
        cancelButtonPayAsChat.titleLabel!.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        cancelButtonPayAsChat.setTitle(NSLocalizedString("cancel", comment: ""), for: UIControl.State.normal)
        cancelButtonPayAsChat.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        
        // Enable button
        let goToSettingsButton = UIButton()
        goToSettingsButton.set(.height, to: Values.mediumButtonHeight)
        goToSettingsButton.layer.cornerRadius = Modal.buttonCornerRadius
        if isDarkMode {
            goToSettingsButton.backgroundColor = Colors.bchatJoinOpenGpBackgroundGreen
            goToSettingsButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        }else {
            goToSettingsButton.backgroundColor = Colors.bchatJoinOpenGpBackgroundGreen
            goToSettingsButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        }
        goToSettingsButton.titleLabel!.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        goToSettingsButton.setTitle(NSLocalizedString("vc_ok_title", comment: ""), for: UIControl.State.normal)
        goToSettingsButton.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        // Content stack view
        let contentStackView = UIStackView(arrangedSubviews: [theImageView, titleLabel, messageLabel ])
        contentStackView.axis = .vertical
        contentStackView.spacing = Values.largeSpacing
        // Button stack view
        let buttonStackView = UIStackView(arrangedSubviews: [ cancelButtonPayAsChat, goToSettingsButton ])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        // Main stack view
        let spacing = Values.largeSpacing - Values.smallFontSize / 2
        let mainStackView = UIStackView(arrangedSubviews: [ contentStackView, buttonStackView ])
        mainStackView.axis = .vertical
        mainStackView.spacing = spacing
        contentView.addSubview(mainStackView)
        mainStackView.pin(.leading, to: .leading, of: contentView, withInset: Values.largeSpacing)
        mainStackView.pin(.top, to: .top, of: contentView, withInset: Values.largeSpacing)
        contentView.pin(.trailing, to: .trailing, of: mainStackView, withInset: Values.largeSpacing)
        contentView.pin(.bottom, to: .bottom, of: mainStackView, withInset: spacing)
    }

    // MARK: Interaction
//    @objc func goToSettings(_ sender: Any) {
//        dismiss(animated: true, completion: {
//            if let vc = CurrentAppContext().frontmostViewController() {
//                let privacySettingsVC = PrivacySettingsTableViewController()
//                privacySettingsVC.shouldShowCloseButton = true
//                let nav = OWSNavigationController(rootViewController: privacySettingsVC)
//                nav.modalPresentationStyle = .fullScreen
//                vc.present(nav, animated: true, completion: nil)
//            }
//        })
//    }
    
    @objc func goToSettings(_ sender: Any) {
        dismiss(animated: true, completion: {
            if let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                let bChatSettingsNewVC = BChatSettingsNewVC()
                navController.pushViewController(bChatSettingsNewVC, animated: true)
            }
        })
    }
    
    @objc func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .showInputViewNotification, object: nil)
    }
}
