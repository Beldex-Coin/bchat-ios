// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class DownloadAttachmentPopUpViewController: BaseVC {
    
    // MARK: - UIElements
    
    /// BackGround View
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.smallBackGroundColor
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColorNew.cgColor
        return stackView
    }()
    
    /// Download Logo Img
    lazy var downloadLogoImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_download_white" : "ic_download_dark"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Title Label
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.extraBoldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    /// Discription Label
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    /// Download Button
    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.regularOpenSans(ofSize: 14)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Cancel Button
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 0.5
        button.layer.borderColor = Colors.bothGreenColor.cgColor
        button.backgroundColor = Colors.bothGreenWithAlpha10
        button.titleLabel!.font = Fonts.regularOpenSans(ofSize: 14)
        button.setTitleColor(Colors.cancelButtonTitleColor, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Button Stack View
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 8
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    private let viewItem: ConversationViewItem
    init(viewItem: ConversationViewItem) {
        self.viewItem = viewItem
        super.init(nibName: nil, bundle: nil)
    }
    override init(nibName: String?, bundle: Bundle?) {
        preconditionFailure("Use init(viewItem:) instead.")
    }
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(viewItem:) instead.")
    }
    
    // MARK: - UIViewController life cycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(backGroundView)
        
        backGroundView.addSubViews(downloadLogoImg, titleLabel, discriptionLabel, buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(downloadButton)
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            downloadLogoImg.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 22),
            downloadLogoImg.heightAnchor.constraint(equalToConstant: 58),
            downloadLogoImg.widthAnchor.constraint(equalToConstant: 58),
            downloadLogoImg.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: downloadLogoImg.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 50),
            titleLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -50),
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 50),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -50),
            buttonStackView.topAnchor.constraint(equalTo: discriptionLabel.bottomAnchor, constant: 21),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -23),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            downloadButton.heightAnchor.constraint(equalToConstant: 52),
            cancelButton.heightAnchor.constraint(equalToConstant: 52),
        ])
        
        guard let publicKey = (viewItem.interaction as? TSIncomingMessage)?.authorId else { return }
        let name = Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
        titleLabel.text = "Trust \(name)?"
        
        let string = "Are you sure you want to download media sent by \(name)?"
        let attributedString = NSMutableAttributedString(string: string)
        // Apply bold font to "Voice and video calls"
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.boldOpenSans(ofSize: 14)]
        // Apply bold font to "Privacy Settings"
        attributedString.addAttributes(boldFontAttribute, range: (string as NSString).range(of: "\(name)"))
        // Display the attributed string
        discriptionLabel.attributedText = attributedString
        
        
    }
    
    /// Download Button Tapped
    @objc private func downloadButtonTapped(_ sender: UIButton) {
        guard let message = viewItem.interaction as? TSIncomingMessage else { return }
        let publicKey = message.authorId
        let contact = Storage.shared.getContact(with: publicKey) ?? Contact(bchatID: publicKey)
        contact.isTrusted = true
        Storage.write(with: { transaction in
            Storage.shared.setContact(contact, using: transaction)
            MessageInvalidator.invalidate(message, with: transaction)
        }, completion: {
            Storage.shared.resumeAttachmentDownloadJobsIfNeeded(for: message.uniqueThreadId)
        })
        presentingViewController?.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .showInputViewNotification, object: nil)
    }
    
    /// Cancel Button Tapped
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .showInputViewNotification, object: nil)
    }
    
}
