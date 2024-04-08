
@objc
final class CallModal : Modal {
    private let onCallEnabled: () -> Void

    // MARK: Lifecycle
    @objc
    init(onCallEnabled: @escaping () -> Void) {
        self.onCallEnabled = onCallEnabled
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
        titleLabel.font = Fonts.boldOpenSans(ofSize: Values.largeFontSize)
        titleLabel.text = NSLocalizedString("modal_call_title", comment: "")
        titleLabel.textAlignment = .center
        // Message
        let messageLabel = UILabel()
        messageLabel.textColor = Colors.text
        messageLabel.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        let message = NSLocalizedString("modal_call_explanation", comment: "")
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textAlignment = .center
        // Enable button
        let enableButton = UIButton()
        enableButton.set(.height, to: Values.mediumButtonHeight)
        enableButton.layer.cornerRadius = 17//Modal.buttonCornerRadius
        if isDarkMode {
            enableButton.backgroundColor = Colors.bchatJoinOpenGpBackgroundGreen
            enableButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        }else {
            enableButton.backgroundColor = Colors.bchatJoinOpenGpBackgroundGreen
            enableButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        }
        enableButton.titleLabel!.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        enableButton.setTitle(NSLocalizedString("modal_link_previews_button_title", comment: ""), for: UIControl.State.normal)
        enableButton.addTarget(self, action: #selector(enable), for: UIControl.Event.touchUpInside)
        // Button stack view
        cancelButton.layer.cornerRadius = 17
        let buttonStackView = UIStackView(arrangedSubviews: [ cancelButton, enableButton ])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = Values.mediumSpacing
        buttonStackView.distribution = .fillEqually
        // Main stack view
        let mainStackView = UIStackView(arrangedSubviews: [ titleLabel, messageLabel, buttonStackView ])
        mainStackView.axis = .vertical
        mainStackView.spacing = Values.largeSpacing
        contentView.addSubview(mainStackView)
        mainStackView.pin(.leading, to: .leading, of: contentView, withInset: Values.largeSpacing)
        mainStackView.pin(.top, to: .top, of: contentView, withInset: Values.largeSpacing)
        contentView.pin(.trailing, to: .trailing, of: mainStackView, withInset: Values.largeSpacing)
        contentView.pin(.bottom, to: .bottom, of: mainStackView, withInset: Values.largeSpacing)
    }

    // MARK: Interaction
    @objc private func enable() {
        SSKPreferences.areCallsEnabled = true
        presentingViewController?.dismiss(animated: true, completion: nil)
        onCallEnabled()
    }
}
