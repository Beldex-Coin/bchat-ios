
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppModeChangedNotification(_:)), name: .appModeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: .OWSApplicationDidBecomeActive, object: nil)
        
        let tapGesture: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(resignKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func resignKeyboard() {
        view.endEditing(true)
    }
    
    internal func ensureWindowBackground() {
        let appMode = AppModeManager.shared.currentAppMode
        switch appMode {
            case .light:
                UIApplication.shared.delegate?.window??.backgroundColor = .white
            case .dark:
                UIApplication.shared.delegate?.window??.backgroundColor = .black
        }
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
        headingImageView.image = UIImage(named: "BChat_")?.withRenderingMode(.alwaysTemplate)
        headingImageView.contentMode = .scaleAspectFit
        headingImageView.set(.width, to: 90)
        headingImageView.set(.height, to: Values.mediumFontSize)
        if let statusView = view.viewWithTag(333222) {
            statusView.removeFromSuperview()
        }
        // Path status indicator
        let pathStatusView = PathStatusView()
        pathStatusView.tag = 333222
        pathStatusView.accessibilityLabel = "Current onion routing path indicator"
        pathStatusView.set(.width, to: PathStatusView.size)
        pathStatusView.set(.height, to: PathStatusView.size)
        pathStatusView.layer.borderWidth = 2
        pathStatusView.layer.borderColor = UIColor(hex: 0x1C1C26).cgColor
        let spacer = UIView()
        spacer.set(.width, to: UIScreen.main.bounds.width - 261)
        spacer.set(.height, to: Values.mediumFontSize)
        let stack = UIStackView(arrangedSubviews: [headingImageView, pathStatusView, spacer])
        stack.axis = .horizontal
        stack.alignment = .center
        navigationItem.titleView = stack
    }
    
    internal func setUpTopCornerRadius() {
        view.layer.cornerRadius = 18
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
    
    @objc func appDidBecomeActive(_ notification: Notification) {
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
