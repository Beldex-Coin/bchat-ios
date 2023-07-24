
final class UserDetailsSheet : Sheet {
    private let bchatuserID: String
    
    init(for bchatuserID: String) {
        self.bchatuserID = bchatuserID
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName: String?, bundle: Bundle?) {
        preconditionFailure("Use init(for:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(for:) instead.")
    }
    
    override func populateContentView() {
        // Profile picture view
        let profilePictureView = ProfilePictureView()
        let size = Values.largeProfilePictureSize
        profilePictureView.size = size
        profilePictureView.set(.width, to: size)
        profilePictureView.set(.height, to: size)
        profilePictureView.publicKey = bchatuserID
        profilePictureView.update()
        // Display name label
        let displayNameLabel = UILabel()
        let displayName = Storage.shared.getContact(with: bchatuserID)?.displayName(for: .regular) ?? bchatuserID
        displayNameLabel.text = displayName
        displayNameLabel.font = Fonts.boldOpenSans(ofSize: Values.largeFontSize)
        displayNameLabel.textColor = Colors.text
        displayNameLabel.numberOfLines = 1
        displayNameLabel.lineBreakMode = .byTruncatingTail
        // BChat ID label
        let bchatIDLabel = UILabel()
        bchatIDLabel.textColor = Colors.text
        bchatIDLabel.font = Fonts.OpenSans(ofSize: isIPhone5OrSmaller ? Values.mediumFontSize : 20)
        bchatIDLabel.numberOfLines = 0
        bchatIDLabel.lineBreakMode = .byCharWrapping
        bchatIDLabel.accessibilityLabel = "BChat ID label"
        bchatIDLabel.text = bchatuserID
        // BChat ID label container
        let bchatIDLabelContainer = UIView()
        bchatIDLabelContainer.addSubview(bchatIDLabel)
        bchatIDLabel.pin(to: bchatIDLabelContainer, withInset: Values.mediumSpacing)
        bchatIDLabelContainer.layer.cornerRadius = TextField.cornerRadius
        bchatIDLabelContainer.layer.borderWidth = 1
        bchatIDLabelContainer.layer.borderColor = isLightMode ? UIColor.black.cgColor : UIColor.white.cgColor
        // Copy button
        let copyButton = Button(style: .prominentOutline, size: .medium)
        copyButton.setTitle(NSLocalizedString("copy", comment: ""), for: UIControl.State.normal)
        copyButton.addTarget(self, action: #selector(copyBChatID), for: UIControl.Event.touchUpInside)
        copyButton.set(.width, to: 160)
        // Stack view
        let stackView = UIStackView(arrangedSubviews: [ profilePictureView, displayNameLabel, bchatIDLabelContainer, copyButton, UIView.vSpacer(Values.largeSpacing) ])
        stackView.axis = .vertical
        stackView.spacing = Values.largeSpacing
        stackView.alignment = .center
        // Constraints
        contentView.addSubview(stackView)
        stackView.pin(to: contentView, withInset: Values.largeSpacing)
    }
    
    @objc private func copyBChatID() {
        UIPasteboard.general.string = bchatuserID
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
