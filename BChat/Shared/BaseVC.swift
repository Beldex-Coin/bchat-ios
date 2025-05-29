
var isEmojiSheetPresented = false

class BaseVC : UIViewController {
    private var hasGradient = false

    override var preferredStatusBarStyle: UIStatusBarStyle { return isLightMode ? .default : .lightContent }

    lazy var navBarTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = Fonts.boldOpenSans(ofSize: Values.veryLargeFontSize)
        result.alpha = 1
        result.textAlignment = .center
        return result
    }()

    lazy var crossfadeLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = Fonts.boldOpenSans(ofSize: Values.veryLargeFontSize)
        result.alpha = 0
        result.textAlignment = .center
        return result
    }()

    override func viewDidLoad() {
        setNeedsStatusBarAppearanceUpdate()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppModeChangedNotification(_:)),
            name: .appModeChanged,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive(_:)),
            name: .OWSApplicationDidBecomeActive,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterBackground(_:)),
            name: .OWSApplicationWillEnterForeground,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(backToHomeScreen),
            name: .joinedOpenGroup,
            object: nil)
        
        let tapGesture: UITapGestureRecognizer =  UITapGestureRecognizer(
            target: self,
            action: #selector(resignKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func resignKeyboard() {
        if isEmojiSheetPresented == false {
            view.endEditing(true)
        }
    }
    
    internal func ensureWindowBackground() {
        let appMode = AppModeManager.shared.currentAppMode
        UIApplication.shared.delegate?.window??.backgroundColor = appMode == .light ? .white : .black
    }

    internal func setUpGradientBackground() {
        hasGradient = true
        view.backgroundColor = .clear
        let gradient = Gradients.defaultBackground
        view.setGradient(gradient)
    }

    internal func setUpNavBarStyle() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Colors.cancelButtonBackgroundColor//Colors.navigationBarBackground
            appearance.shadowColor = .clear
            navigationBar.standardAppearance = appearance;
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = Colors.navigationBarBackground
        }
        
        // Back button (to appear on pushed screen)
            let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            backButton.tintColor = Colors.text
            navigationItem.backBarButtonItem = backButton
    }

    internal func setNavBarTitle(_ title: String, customFontSize: CGFloat? = nil) {
        let container = UIView()
        navBarTitleLabel.text = title
        crossfadeLabel.text = title
        if let customFontSize = customFontSize {
            navBarTitleLabel.font = Fonts.boldOpenSans(ofSize: customFontSize)
            crossfadeLabel.font = Fonts.boldOpenSans(ofSize: customFontSize)
        }
        container.addSubview(navBarTitleLabel)
        navBarTitleLabel.pin(to: container)
        container.addSubview(crossfadeLabel)
        crossfadeLabel.pin(to: container)
        navigationItem.titleView = container
    }
    
    internal func setUpNavBarSessionHeading() {
        let headingImageView = UIImageView()
        headingImageView.tintColor = Colors.text
        headingImageView.image = UIImage(named: "BChat_chats")?.withRenderingMode(.alwaysTemplate)
        headingImageView.contentMode = .scaleAspectFit
        headingImageView.set(.width, to: 55)
        headingImageView.set(.height, to: 27)
        if let statusView = view.viewWithTag(333222) {
            statusView.removeFromSuperview()
        }
        // Path status indicator
        let pathStatusView = PathStatusView()
        pathStatusView.tag = 333222
        pathStatusView.accessibilityLabel = "Current onion routing path indicator"
        pathStatusView.set(.width, to: 6)
        pathStatusView.set(.height, to: 6)
        pathStatusView.layer.cornerRadius = 3
        let spacer = UIView()
        spacer.set(.width, to: UIScreen.main.bounds.width - 261 + 20)
        spacer.set(.height, to: Values.mediumFontSize)
        
        let spacer2 = UIView()
        spacer2.set(.width, to: 3)
        spacer2.set(.height, to: Values.mediumFontSize)
        
        let stack = UIStackView(arrangedSubviews: [headingImageView, spacer2, pathStatusView, spacer])
        stack.axis = .horizontal
        stack.alignment = .center
        navigationItem.titleView = stack
    }
    
    internal func setUpTopCornerRadius() {
        view.layer.cornerRadius = 22
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    internal func setUpNavBarSessionIcon() {
        let logoImageView = UIImageView()
        logoImageView.image = #imageLiteral(resourceName: "192x192")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.set(.width, to: 32)
        logoImageView.set(.height, to: 32)
        navigationItem.titleView = logoImageView
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func appDidBecomeActive(_ notification: Notification) {
        // To be implemented by child class
    }
    
    @objc
    func appWillEnterBackground(_ notification: Notification) {
        // To be implemented by child class
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            SNLog("Current trait collection: \(UITraitCollection.current), previous trait collection: \(previousTraitCollection)")
        }
//        if LKAppModeUtilities.isSystemDefault {
//             NotificationCenter.default.post(name: .appModeChanged, object: nil)
//        }
    }

    @objc internal func handleAppModeChangedNotification(_ notification: Notification) {
        if hasGradient {
            setUpGradientBackground() // Re-do the gradient
        }
        ensureWindowBackground()
    }
    
    // Back To BChat Home screen
    @objc func backToHomeScreen() {
        if let viewController = navigationController?.viewControllers.first(where: {$0 is HomeVC}) {
              navigationController?.popToViewController(viewController, animated: true)
        }
    }
}


extension BaseVC {
    
    func showCallScreen() {
        if SSKPreferences.areCallsEnabled {
            requestMicrophonePermissionIfNeeded { }
            guard let call = AppEnvironment.shared.callManager.currentCall else { return }
            guard MiniCallView.current == nil else { return }
            if let callVC = CurrentAppContext().frontmostViewController() as? NewIncomingCallVC, callVC.bChatCall == call { return }
            guard let presentingVC = CurrentAppContext().frontmostViewController() else { preconditionFailure() } // FIXME: Handle more gracefully
            let callVC = NewIncomingCallVC(for: call)
            if let conversationVC = presentingVC as? ConversationVC, let contactThread = conversationVC.thread as? TSContactThread, contactThread.contactBChatID() == call.bchatID {
                callVC.conversationVC = conversationVC
                if let viewController = callVC.conversationVC {
                    hideInputAccessoryView(viewController.inputAccessoryView)
                }
            }
            presentingVC.present(callVC, animated: true) {
                callVC.setupStateChangeCallbacks()
            }
        } else {
            showCallPermissionModel {
                debugPrint("On Confirmed")
            } onAfterClosed: {
                debugPrint("On After Closed")
            } onCompletion: {
                debugPrint("On Completion")
            }

        }
    }
    
    func showCallPermissionModel(
        onConfirmed: (() -> Void)? = nil,
        onAfterClosed: (() -> Void)? = nil,
        onCompletion: (() -> Void)? = nil) {
        
        let title = NSLocalizedString("modal_call_permission_request_title", comment: "")
        let description = callPermisionDescription()
        // show confirmation modal
        let confirmationModal: ConfirmationModal = ConfirmationModal(
            info: ConfirmationModal.Info(
                modalImageType: .callPermission,
                title: title,
                body: .attributedText(description),
                showCondition: .disabled,
                confirmTitle: "Settings",
                onConfirm: { _ in
                    onConfirmed?()
                }, afterClosed: {
                    onAfterClosed?()
                }
            )
        )
        present(confirmationModal, animated: true, completion:  {
            onCompletion?()
        })
        return
    }
    
    func hideInputAccessoryView(_ view: UIView?) {
        guard let aView = view else { return }
        aView.isHidden = true
        aView.alpha = 0
    }
    
    func callPermisionDescription() -> NSAttributedString {
        let string = "You can enable the ‘Voice and video calls’ permission in the Privacy Settings."
        let attributedString = NSMutableAttributedString(string: string)
        // Apply bold font to "Voice and video calls"
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.boldOpenSans(ofSize: 14)]
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "Voice and video calls"))
        // Apply bold font to "Privacy Settings"
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "Privacy Settings"))
        // The attributed string
        return attributedString
        
    }
}
