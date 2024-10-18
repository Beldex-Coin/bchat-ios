// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import BChatUtilitiesKit

class MyAccountBnsViewController: BaseVC {
    
    // MARK: - UIElements
    
    /// TopBackGround view
    private lazy var topBackGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.cellGroundColor2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    /// Bottom BackGround View
    private lazy var bottomBackGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.cellGroundColor2
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    /// Profile Picture Image
    private lazy var profilePictureImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 43
        imageView.clipsToBounds = true
        let logoImage = isLightMode ? "ic_userImageNew" : "ic_userImageNew"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = Colors.bothGreenColor.cgColor
        return imageView
    }()
    
    /// Bns Approval Icon Image
    private lazy var bnsApprovalIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        let logoImage = isLightMode ? "ic_Bns_Approval_icon" : "ic_Bns_Approval_icon"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Shadow Background Image
    private lazy var shadowBackgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_background_image" : "shadow_image"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// User Name Id Label
    private lazy var userNameIdLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.text = "Sreek"
        result.textAlignment = .center
        result.numberOfLines = 0
        result.lineBreakMode = .byCharWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Stack View For UserName
    lazy var stackViewForUserName: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 0
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    /// Bns Verified Label
    private lazy var bnsVerifiedTitleNameLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.text = "BNS Verified"
        result.textAlignment = .center
        result.numberOfLines = 0
        result.lineBreakMode = .byCharWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Bns Tick Icon Image
    private lazy var bnsTickIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_success_node" : "ic_success_node"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// StackView For BNS VerifiedName
    lazy var stackViewForBNSVerifiedName: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 4
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var stackViewForUserNameAndBnsVerifiedContainer: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 5
        return result
    }()
    
    /// Beldex Address View
    private lazy var beldexAddressView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 10
        return stackView
    }()
    
    /// Beldex Address Button
    private lazy var beldexAddressButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(beldexAddressButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Bchat Id View
    private lazy var bchatIdView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 10
        return stackView
    }()
    
    /// Bchat Id Button
    private lazy var bchatIdButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(bchatIdButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Show Qr View
    private lazy var showQrView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 10
        return stackView
    }()
    
    /// Show Qr Button
    private lazy var showQrButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showQrButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var stackViewThreeVerticalElementsContainer: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .fill
        result.distribution = .fillEqually
        result.spacing = 6
        return result
    }()

    /// Copy Image Beldex Address
    private lazy var copyImageBeldexAddress: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_copy_newimage" : "ic_copy_newimage"
        button.setImage(UIImage(named: logoImage), for: .normal)
        button.addTarget(self, action: #selector(copyBeldexAddressButtonTapped), for: .touchUpInside)
        return button
    }()

    /// Copy Image Bchat ID
    private lazy var copyImageBchatID: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_copy_newimage" : "ic_copy_newimage"
        button.setImage(UIImage(named: logoImage), for: .normal)
        button.addTarget(self, action: #selector(copyBChatIDButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Beldex Address NameLabel
    private lazy var beldexAddressNameLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("Beldex Address", comment: "")
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 11)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Bchat Name Label
    private lazy var bchatNameLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("BChat ID", comment: "")
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 11)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Show Qr Code Label
    private lazy var showQrCodeLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("Show QR", comment: "")
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 11)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Beldex Logo Image
    private lazy var beldexLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_Beldex_logo" : "ic_Beldex_logo"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Bchat Logo Image
    private lazy var bchatLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_bchatid_logo" : "ic_bchatid_logo"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Show Qr Logo Image
    private lazy var showQrLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_ShowQr_logo_dark" : "ic_ShowQr_logo"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Link Your BNS Background View
    private lazy var linkYourBNSBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.bothGreenColor
        stackView.layer.cornerRadius = Values.buttonRadius
        return stackView
    }()
    
    private lazy var linkYourBNSButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(linkYourBNSButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Bns Logo Image
    private lazy var bnsLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_BNS_logo" : "ic_BNS_logo"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Link Your BNS Name Label
    private lazy var linkYourBNSNameLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("Link Your BNS", comment: "")
        result.textColor = .white
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Read More About Background View
    private lazy var readMoreAboutBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.layer.cornerRadius = Values.buttonRadius
        return stackView
    }()
    
    /// Read More About BNS Name Label
    private lazy var readMoreAboutBNSNameLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("Read more about BNS", comment: "")
        result.textColor = Colors.textFieldPlaceHolderColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Read More About BNS logo
    private lazy var readMoreAboutBNSLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_readMoreAboutBNS_logo" : "ic_readMoreAboutBNS_logo"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    lazy var stackViewForFinalLinkBNS: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 4
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    /// Beldex Address Expand View
    lazy var beldexAddressExpandView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.expandBackgroundColor
        stackView.layer.cornerRadius = Values.buttonRadius
        return stackView
    }()
    
    /// bchat ID Expand View
    lazy var bchatIDExpandView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.expandBackgroundColor
        stackView.layer.cornerRadius = Values.buttonRadius
        return stackView
    }()
    
    /// Show QR Expand View
    lazy var showQRExpandView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.expandBackgroundColor
        stackView.layer.cornerRadius = Values.buttonRadius
        return stackView
    }()
    
    /// Beldex Address Name Title Label
    private lazy var beldexAddressNameTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("Beldex Address", comment: "")
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Beldex Address Id Label
    private lazy var beldexAddressIdLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.lineBreakMode = .byCharWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Bchat ID Title Label
    private lazy var bchatIDTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("BChat ID", comment: "")
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Bchat Id Label
    private lazy var bchatIdLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.lineBreakMode = .byCharWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Scan QR Title Label
    private lazy var scanQRTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("Scan QR Code", comment: "")
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Copy For Beldex Address Button
    private lazy var copyForBeldexAddressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_copy_image"), for: .normal)
        button.addTarget(self, action: #selector(copyForBeldexAddressButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    /// Copy For BChat Id Button
    private lazy var copyForBChatIdButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_copy_image"), for: .normal)
        button.addTarget(self, action: #selector(copyForBChatIdButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    /// Share Button
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("SHARE_OPTION_NEW", comment: ""), for: .normal)
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.greenColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(shareButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    /// Qr Background View
    private lazy var qrBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 10
        return stackView
    }()
    
    /// Qr Code Image
    private lazy var qrCodeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    /// tableView
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Properties
    
    let viewModel = MyAccountBNSViewModel()
    
    /// is fallback picture
    @objc public var isFallbackPicture = false
    
    /// openGroupProfilePicture
    @objc public var openGroupProfilePicture: UIImage?
    
    /// size
    @objc public var size: CGFloat = 30
    
    // MARK: - UIViewController life cycle
    
    /// View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorNew
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setUpTopCornerRadius()
        self.title = "My Account"
        
        shareButton.addRightIcon(image: UIImage(named: "ic_black_share")!.withRenderingMode(.alwaysTemplate))
        shareButton.tintColor = .white
        
        view.addSubview(topBackGroundView)
        topBackGroundView.addSubview(shadowBackgroundImage)
        topBackGroundView.addSubview(profilePictureImage)
        
        view.addSubview(bnsApprovalIconImage)
        
        topBackGroundView.addSubview(stackViewForBNSVerifiedName)
        stackViewForBNSVerifiedName.addArrangedSubview(bnsVerifiedTitleNameLabel)
        stackViewForBNSVerifiedName.addArrangedSubview(bnsTickIconImage)
        
        topBackGroundView.addSubview(stackViewForUserNameAndBnsVerifiedContainer)
        stackViewForUserNameAndBnsVerifiedContainer.addArrangedSubview(userNameIdLabel)
        stackViewForUserNameAndBnsVerifiedContainer.addArrangedSubview(stackViewForBNSVerifiedName)
        
        beldexAddressView.addSubview(beldexAddressNameLabel)
        bchatIdView.addSubview(bchatNameLabel)
        showQrView.addSubview(showQrCodeLabel)
        
        beldexAddressView.addSubview(beldexLogoImage)
        bchatIdView.addSubview(bchatLogoImage)
        showQrView.addSubview(showQrLogoImage)
        
        beldexAddressView.addSubview(beldexAddressButton)
        beldexAddressView.addSubview(copyImageBeldexAddress)
        bchatIdView.addSubview(bchatIdButton)
        bchatIdView.addSubview(copyImageBchatID)
        showQrView.addSubview(showQrButton)
        
        topBackGroundView.addSubview(stackViewThreeVerticalElementsContainer)
        stackViewThreeVerticalElementsContainer.addArrangedSubview(beldexAddressView)
        stackViewThreeVerticalElementsContainer.addArrangedSubview(bchatIdView)
        stackViewThreeVerticalElementsContainer.addArrangedSubview(showQrView)
        
        //link Your BNS Background View
        view.addSubview(linkYourBNSBackgroundView)
        linkYourBNSBackgroundView.addSubview(linkYourBNSNameLabel)
        linkYourBNSBackgroundView.addSubview(bnsLogoImage)
        
        linkYourBNSBackgroundView.addSubview(linkYourBNSButton)
        
        view.addSubview(readMoreAboutBackgroundView)
        readMoreAboutBackgroundView.addSubview(readMoreAboutBNSNameLabel)
        readMoreAboutBackgroundView.addSubview(readMoreAboutBNSLogoImage)
        
        let tapGestureForReadmoreAboutBNSLabel = UITapGestureRecognizer(target: self, action: #selector(self.readMoreAboutBNSViewTapped(_:)))
        let tapGestureForReadmoreAboutBNSLogoImage = UITapGestureRecognizer(target: self, action: #selector(self.readMoreAboutBNSViewTapped(_:)))
        tapGestureForReadmoreAboutBNSLabel.numberOfTapsRequired = 1
        readMoreAboutBNSNameLabel.isUserInteractionEnabled = true
        readMoreAboutBNSLogoImage.isUserInteractionEnabled = true
        tapGestureForReadmoreAboutBNSLabel.cancelsTouchesInView = false
        tapGestureForReadmoreAboutBNSLogoImage.cancelsTouchesInView = false
        readMoreAboutBNSNameLabel.addGestureRecognizer(tapGestureForReadmoreAboutBNSLabel)
        readMoreAboutBNSLogoImage.addGestureRecognizer(tapGestureForReadmoreAboutBNSLogoImage)
        
        view.addSubview(stackViewForFinalLinkBNS)
        stackViewForFinalLinkBNS.addArrangedSubview(linkYourBNSBackgroundView)
        stackViewForFinalLinkBNS.addArrangedSubview(readMoreAboutBackgroundView)
        
        //bottom BackGround View
        view.addSubview(bottomBackGroundView)
        bottomBackGroundView.addSubview(tableView)
        
        view.addSubview(beldexAddressExpandView)
        view.addSubview(bchatIDExpandView)
        view.addSubview(showQRExpandView)
        
        beldexAddressExpandView.addSubview(beldexAddressNameTitleLabel)
        beldexAddressExpandView.addSubview(beldexAddressIdLabel)
        beldexAddressExpandView.addSubview(copyForBeldexAddressButton)
        
        bchatIDExpandView.addSubview(bchatIDTitleLabel)
        bchatIDExpandView.addSubview(bchatIdLabel)
        bchatIDExpandView.addSubview(copyForBChatIdButton)
        
        showQRExpandView.addSubview(scanQRTitleLabel)
        showQRExpandView.addSubview(qrBackgroundView)
        qrBackgroundView.addSubview(qrCodeImage)
        showQRExpandView.addSubview(shareButton)
        
        updateBNSDetails()
        
        NSLayoutConstraint.activate([
            topBackGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            topBackGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            profilePictureImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            profilePictureImage.widthAnchor.constraint(equalToConstant: 86),
            profilePictureImage.heightAnchor.constraint(equalToConstant: 86),
            profilePictureImage.centerXAnchor.constraint(equalTo: topBackGroundView.centerXAnchor),
            profilePictureImage.centerYAnchor.constraint(equalTo: topBackGroundView.topAnchor),
            
            shadowBackgroundImage.leadingAnchor.constraint(equalTo: topBackGroundView.leadingAnchor, constant: 0),
            shadowBackgroundImage.trailingAnchor.constraint(equalTo: topBackGroundView.trailingAnchor, constant: -0),
            shadowBackgroundImage.topAnchor.constraint(equalTo: topBackGroundView.topAnchor, constant: 0),
            shadowBackgroundImage.bottomAnchor.constraint(equalTo: topBackGroundView.bottomAnchor, constant: -0),
            
            bnsApprovalIconImage.trailingAnchor.constraint(equalTo: profilePictureImage.trailingAnchor, constant: -1),
            bnsApprovalIconImage.bottomAnchor.constraint(equalTo: profilePictureImage.bottomAnchor, constant: 9),
            bnsApprovalIconImage.widthAnchor.constraint(equalToConstant: 34),
            bnsApprovalIconImage.heightAnchor.constraint(equalToConstant: 34),
            
            userNameIdLabel.centerXAnchor.constraint(equalTo: profilePictureImage.centerXAnchor),
            userNameIdLabel.heightAnchor.constraint(equalToConstant: 22),
            bnsTickIconImage.widthAnchor.constraint(equalToConstant: 14),
            bnsTickIconImage.heightAnchor.constraint(equalToConstant: 14),
            
            stackViewForUserNameAndBnsVerifiedContainer.topAnchor.constraint(equalTo: profilePictureImage.bottomAnchor, constant: 8),
            stackViewForUserNameAndBnsVerifiedContainer.centerXAnchor.constraint(equalTo: profilePictureImage.centerXAnchor),
            
            beldexAddressView.heightAnchor.constraint(equalToConstant: 73),
            bchatIdView.heightAnchor.constraint(equalToConstant: 73),
            showQrView.heightAnchor.constraint(equalToConstant: 73),
            
            copyImageBeldexAddress.topAnchor.constraint(equalTo: beldexAddressView.topAnchor, constant: 0),
            copyImageBeldexAddress.trailingAnchor.constraint(equalTo: beldexAddressView.trailingAnchor, constant: -0),
            copyImageBeldexAddress.widthAnchor.constraint(equalToConstant: 30),
            copyImageBeldexAddress.heightAnchor.constraint(equalToConstant: 30),
            
            copyImageBchatID.topAnchor.constraint(equalTo: bchatIdView.topAnchor, constant: 0),
            copyImageBchatID.trailingAnchor.constraint(equalTo: bchatIdView.trailingAnchor, constant: -0),
            copyImageBchatID.widthAnchor.constraint(equalToConstant: 30),
            copyImageBchatID.heightAnchor.constraint(equalToConstant: 30),
            
            beldexAddressNameLabel.bottomAnchor.constraint(equalTo: beldexAddressView.bottomAnchor, constant: -9),
            beldexAddressNameLabel.centerXAnchor.constraint(equalTo: beldexAddressView.centerXAnchor),
            
            bchatNameLabel.bottomAnchor.constraint(equalTo: bchatIdView.bottomAnchor, constant: -9),
            bchatNameLabel.centerXAnchor.constraint(equalTo: bchatIdView.centerXAnchor),
            
            showQrCodeLabel.bottomAnchor.constraint(equalTo: showQrView.bottomAnchor, constant: -9),
            showQrCodeLabel.centerXAnchor.constraint(equalTo: showQrView.centerXAnchor),
            
            beldexLogoImage.widthAnchor.constraint(equalToConstant: 28),
            beldexLogoImage.heightAnchor.constraint(equalToConstant: 28),
            beldexLogoImage.bottomAnchor.constraint(equalTo: beldexAddressNameLabel.topAnchor, constant: -7),
            beldexLogoImage.centerXAnchor.constraint(equalTo: beldexAddressNameLabel.centerXAnchor),
            
            bchatLogoImage.widthAnchor.constraint(equalToConstant: 28),
            bchatLogoImage.heightAnchor.constraint(equalToConstant: 28),
            bchatLogoImage.bottomAnchor.constraint(equalTo: bchatNameLabel.topAnchor, constant: -7),
            bchatLogoImage.centerXAnchor.constraint(equalTo: bchatNameLabel.centerXAnchor),
            
            showQrLogoImage.widthAnchor.constraint(equalToConstant: 28),
            showQrLogoImage.heightAnchor.constraint(equalToConstant: 28),
            showQrLogoImage.bottomAnchor.constraint(equalTo: showQrCodeLabel.topAnchor, constant: -7),
            showQrLogoImage.centerXAnchor.constraint(equalTo: showQrCodeLabel.centerXAnchor),
            
            beldexAddressButton.topAnchor.constraint(equalTo: beldexAddressView.topAnchor, constant: 0),
            beldexAddressButton.leadingAnchor.constraint(equalTo: beldexAddressView.leadingAnchor, constant: 0),
            beldexAddressButton.trailingAnchor.constraint(equalTo: beldexAddressView.trailingAnchor, constant: -0),
            beldexAddressButton.bottomAnchor.constraint(equalTo: beldexAddressView.bottomAnchor, constant: -0),
            
            bchatIdButton.topAnchor.constraint(equalTo: bchatIdView.topAnchor, constant: 0),
            bchatIdButton.leadingAnchor.constraint(equalTo: bchatIdView.leadingAnchor, constant: 0),
            bchatIdButton.trailingAnchor.constraint(equalTo: bchatIdView.trailingAnchor, constant: -0),
            bchatIdButton.bottomAnchor.constraint(equalTo: bchatIdView.bottomAnchor, constant: -0),
            
            showQrButton.topAnchor.constraint(equalTo: showQrView.topAnchor, constant: 0),
            showQrButton.leadingAnchor.constraint(equalTo: showQrView.leadingAnchor, constant: 0),
            showQrButton.trailingAnchor.constraint(equalTo: showQrView.trailingAnchor, constant: -0),
            showQrButton.bottomAnchor.constraint(equalTo: showQrView.bottomAnchor, constant: -0),
            
            stackViewThreeVerticalElementsContainer.topAnchor.constraint(equalTo: stackViewForUserNameAndBnsVerifiedContainer.bottomAnchor, constant: 14),
            stackViewThreeVerticalElementsContainer.leadingAnchor.constraint(equalTo: topBackGroundView.leadingAnchor, constant: 12),
            stackViewThreeVerticalElementsContainer.trailingAnchor.constraint(equalTo: topBackGroundView.trailingAnchor, constant: -12),
            stackViewThreeVerticalElementsContainer.bottomAnchor.constraint(equalTo: topBackGroundView.bottomAnchor, constant: -14),
            
            //link Your BNS Background View
            linkYourBNSBackgroundView.topAnchor.constraint(equalTo: topBackGroundView.bottomAnchor, constant: 8),
            linkYourBNSBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            linkYourBNSBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            linkYourBNSBackgroundView.heightAnchor.constraint(equalToConstant: 44),
            
            linkYourBNSNameLabel.centerXAnchor.constraint(equalTo: linkYourBNSBackgroundView.centerXAnchor),
            linkYourBNSNameLabel.centerYAnchor.constraint(equalTo: linkYourBNSBackgroundView.centerYAnchor),
            
            bnsLogoImage.trailingAnchor.constraint(equalTo: linkYourBNSNameLabel.leadingAnchor, constant: -5),
            bnsLogoImage.centerYAnchor.constraint(equalTo: linkYourBNSNameLabel.centerYAnchor),
            bnsLogoImage.widthAnchor.constraint(equalToConstant: 14),
            bnsLogoImage.heightAnchor.constraint(equalToConstant: 14),
            
            linkYourBNSButton.topAnchor.constraint(equalTo: linkYourBNSBackgroundView.topAnchor, constant: 0),
            linkYourBNSButton.leadingAnchor.constraint(equalTo: linkYourBNSBackgroundView.leadingAnchor, constant: 0),
            linkYourBNSButton.trailingAnchor.constraint(equalTo: linkYourBNSBackgroundView.trailingAnchor, constant: -0),
            linkYourBNSButton.bottomAnchor.constraint(equalTo: linkYourBNSBackgroundView.bottomAnchor, constant: -0),
            
            readMoreAboutBackgroundView.topAnchor.constraint(equalTo: linkYourBNSBackgroundView.bottomAnchor, constant: 4),
            readMoreAboutBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            readMoreAboutBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            readMoreAboutBackgroundView.heightAnchor.constraint(equalToConstant: 22),
            
            readMoreAboutBNSNameLabel.centerXAnchor.constraint(equalTo: readMoreAboutBackgroundView.centerXAnchor),
            readMoreAboutBNSNameLabel.centerYAnchor.constraint(equalTo: readMoreAboutBackgroundView.centerYAnchor),
            
            readMoreAboutBNSLogoImage.leadingAnchor.constraint(equalTo: readMoreAboutBNSNameLabel.trailingAnchor, constant: 5),
            readMoreAboutBNSLogoImage.centerYAnchor.constraint(equalTo: readMoreAboutBNSNameLabel.centerYAnchor),
            readMoreAboutBNSLogoImage.widthAnchor.constraint(equalToConstant: 14),
            readMoreAboutBNSLogoImage.heightAnchor.constraint(equalToConstant: 14),
            
            stackViewForFinalLinkBNS.topAnchor.constraint(equalTo: topBackGroundView.bottomAnchor, constant: 8),
            stackViewForFinalLinkBNS.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            stackViewForFinalLinkBNS.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            //bottom BackGround View
            bottomBackGroundView.topAnchor.constraint(equalTo: stackViewForFinalLinkBNS.bottomAnchor, constant: 8),
            bottomBackGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            bottomBackGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            bottomBackGroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -18),
            
            //Expand Views
            beldexAddressExpandView.topAnchor.constraint(equalTo: topBackGroundView.bottomAnchor, constant: 0),
            beldexAddressExpandView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            beldexAddressExpandView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            
            bchatIDExpandView.topAnchor.constraint(equalTo: topBackGroundView.bottomAnchor, constant: 0),
            bchatIDExpandView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26),
            bchatIDExpandView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            
            showQRExpandView.topAnchor.constraint(equalTo: topBackGroundView.bottomAnchor, constant: 0),
            showQRExpandView.widthAnchor.constraint(equalToConstant: 270),
            showQRExpandView.centerXAnchor.constraint(equalTo: topBackGroundView.centerXAnchor),
            
            copyForBeldexAddressButton.widthAnchor.constraint(equalToConstant: 18),
            copyForBeldexAddressButton.heightAnchor.constraint(equalToConstant: 18),
            copyForBeldexAddressButton.centerYAnchor.constraint(equalTo: beldexAddressExpandView.centerYAnchor),
            copyForBeldexAddressButton.trailingAnchor.constraint(equalTo: beldexAddressExpandView.trailingAnchor, constant: -16),
            
            beldexAddressNameTitleLabel.topAnchor.constraint(equalTo: beldexAddressExpandView.topAnchor, constant: 14),
            beldexAddressNameTitleLabel.leadingAnchor.constraint(equalTo: beldexAddressExpandView.leadingAnchor, constant: 19),
            
            beldexAddressIdLabel.topAnchor.constraint(equalTo: beldexAddressNameTitleLabel.bottomAnchor, constant: 4),
            beldexAddressIdLabel.leadingAnchor.constraint(equalTo: beldexAddressExpandView.leadingAnchor, constant: 19),
            beldexAddressIdLabel.trailingAnchor.constraint(equalTo: copyForBeldexAddressButton.leadingAnchor, constant: -8),
            beldexAddressIdLabel.bottomAnchor.constraint(equalTo: beldexAddressExpandView.bottomAnchor, constant: -14),
            
            copyForBChatIdButton.widthAnchor.constraint(equalToConstant: 18),
            copyForBChatIdButton.heightAnchor.constraint(equalToConstant: 18),
            copyForBChatIdButton.centerYAnchor.constraint(equalTo: bchatIDExpandView.centerYAnchor),
            copyForBChatIdButton.trailingAnchor.constraint(equalTo: bchatIDExpandView.trailingAnchor, constant: -16),
            
            bchatIDTitleLabel.topAnchor.constraint(equalTo: bchatIDExpandView.topAnchor, constant: 14),
            bchatIDTitleLabel.leadingAnchor.constraint(equalTo: bchatIDExpandView.leadingAnchor, constant: 19),
            
            bchatIdLabel.topAnchor.constraint(equalTo: bchatIDTitleLabel.bottomAnchor, constant: 4),
            bchatIdLabel.leadingAnchor.constraint(equalTo: bchatIDExpandView.leadingAnchor, constant: 19),
            bchatIdLabel.trailingAnchor.constraint(equalTo: copyForBChatIdButton.leadingAnchor, constant: -8),
            bchatIdLabel.bottomAnchor.constraint(equalTo: bchatIDExpandView.bottomAnchor, constant: -14),
            
            scanQRTitleLabel.topAnchor.constraint(equalTo: showQRExpandView.topAnchor, constant: 19),
            scanQRTitleLabel.centerXAnchor.constraint(equalTo: showQRExpandView.centerXAnchor),
            
            qrBackgroundView.widthAnchor.constraint(equalToConstant: 138),
            qrBackgroundView.heightAnchor.constraint(equalToConstant: 138),
            qrBackgroundView.topAnchor.constraint(equalTo: scanQRTitleLabel.bottomAnchor, constant: 13),
            qrBackgroundView.centerXAnchor.constraint(equalTo: scanQRTitleLabel.centerXAnchor),
            
            qrCodeImage.topAnchor.constraint(equalTo: qrBackgroundView.topAnchor, constant: 10),
            qrCodeImage.leadingAnchor.constraint(equalTo: qrBackgroundView.leadingAnchor, constant: 10),
            qrCodeImage.trailingAnchor.constraint(equalTo: qrBackgroundView.trailingAnchor, constant: -10),
            qrCodeImage.bottomAnchor.constraint(equalTo: qrBackgroundView.bottomAnchor, constant: -10),
            
            shareButton.widthAnchor.constraint(equalToConstant: 150),
            shareButton.heightAnchor.constraint(equalToConstant: 48),
            shareButton.centerXAnchor.constraint(equalTo: qrBackgroundView.centerXAnchor),
            shareButton.topAnchor.constraint(equalTo: qrBackgroundView.bottomAnchor, constant: 19),
            shareButton.bottomAnchor.constraint(equalTo: showQRExpandView.bottomAnchor, constant: -26),
            
        ])
        
        // Display image
        let publicKey = getUserHexEncodedPublicKey()
        profilePictureImage.image = isFallbackPicture ? nil : (openGroupProfilePicture ?? getProfilePicture(of: size, for: publicKey))
        profilePictureImage.clipsToBounds = true
        profilePictureImage.layer.cornerRadius = profilePictureImage.frame.height/2
        
        // Display name label
        let nam = Storage.shared.getUser()?.name
        userNameIdLabel.text = nam ?? UserDefaults.standard.string(forKey: "WalletName")?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        bchatIdLabel.text = "\(getUserHexEncodedPublicKey())"
        beldexAddressIdLabel.text = "\(SaveUserDefaultsData.WalletpublicAddress)"
        let qrCode = QRCode.generate(for: getUserHexEncodedPublicKey(), hasBackground: true)
        qrCodeImage.image = qrCode
        
        tableView.leftAnchor.constraint(equalTo: bottomBackGroundView.leftAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: bottomBackGroundView.topAnchor, constant: 16).isActive = true
        tableView.rightAnchor.constraint(equalTo: bottomBackGroundView.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomBackGroundView.bottomAnchor, constant: 0).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(NewSettingsTableViewCell.self, forCellReuseIdentifier: "NewSettingsTableViewCell")
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(updateBNSDetailsTapped), name: .navigateToMyAccountNotification, object: nil)
        
    }
    
    /// View will appear
    /// - Parameter animated: the Animated
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// View did appear
    /// - Parameter animated: the Animated
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// View will disappear
    ///  - Parameter animated: the Animated
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /// View did disappear
    ///  - Parameter animated: the Animated
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    /// View did layout subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profilePictureImage.layer.cornerRadius = profilePictureImage.frame.height / 2
    }
    
    /// UITouch ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            showQRExpandView.isHidden = true
            beldexAddressExpandView.isHidden = true
            bchatIDExpandView.isHidden = true
        }
    }
    
     // MARK: - Private methods
    
    /// Update BNS Details Tapped
    /// - Parameter notification: notification
    @objc func updateBNSDetailsTapped(notification: NSNotification) {
        updateBNSDetails()
    }
    
    /// Update BNS Details
    func updateBNSDetails() {
        let isBnsUser = UserDefaults.standard.bool(forKey: Constants.isBnsVerifiedUser)
        shadowBackgroundImage.isHidden = !isBnsUser
        stackViewForBNSVerifiedName.isHidden = !isBnsUser
        linkYourBNSBackgroundView.isHidden = isBnsUser
        readMoreAboutBackgroundView.isHidden = isBnsUser
        bchatIDExpandView.isHidden = isBnsUser
        showQRExpandView.isHidden = isBnsUser
        bnsApprovalIconImage.isHidden = !isBnsUser
        profilePictureImage.layer.borderWidth = isBnsUser ? 3 : 0
        profilePictureImage.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
        
        beldexAddressExpandView.isHidden = true
        bchatIDExpandView.isHidden = true
        showQRExpandView.isHidden = true
        
        if isBnsUser {
            stackViewForFinalLinkBNS.isHidden = false
        }
    }
    
    /// Get Profile Picture
    /// - Parameters:
    ///   - size: the size
    ///   - publicKey: the public key
    /// - Returns: UIImage
    func getProfilePicture(of size: CGFloat, for publicKey: String) -> UIImage? {
        guard !publicKey.isEmpty else { return nil }
        if let profilePicture = OWSProfileManager.shared().profileAvatar(forRecipientId: publicKey) {
            return profilePicture
        } else {
            // TODO: Pass in context?
            let displayName = Storage.shared.getContact(with: publicKey)?.name ?? publicKey
            return Identicon.generatePlaceholderIcon(seed: publicKey, text: displayName, size: size)
        }
    }
    
    // MARK: - UIButton Actions
    
    @objc func shareButtonTapped(_ sender: UIButton) {
        let qrCode = QRCode.generate(for: getUserHexEncodedPublicKey(), hasBackground: true)
        let shareVC = UIActivityViewController(activityItems: [ qrCode ], applicationActivities: nil)
        self.navigationController!.present(shareVC, animated: true, completion: nil)
    }
    
    @objc func copyForBeldexAddressButtonTapped(_ sender: UIButton){
        UIPasteboard.general.string = SaveUserDefaultsData.WalletpublicAddress
        beldexAddressIdLabel.isUserInteractionEnabled = false
        showToast(message: NSLocalizedString("BELDEX_ADDRESS_COPIED_NEW", comment: ""), seconds: 1.0)
    }
    
    @objc func copyForBChatIdButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string = getUserHexEncodedPublicKey()
        bchatIdLabel.isUserInteractionEnabled = false
        showToast(message: NSLocalizedString("BCHAT_ID_COPIED_NEW", comment: ""), seconds: 1.0)
    }
    
    @objc func beldexAddressButtonTapped(_ sender: UIButton){
        beldexAddressExpandView.isHidden = false
        bchatIDExpandView.isHidden = true
        showQRExpandView.isHidden = true
    }
    
    @objc func bchatIdButtonTapped(_ sender: UIButton){
        bchatIDExpandView.isHidden = false
        beldexAddressExpandView.isHidden = true
        showQRExpandView.isHidden = true
    }
    
    @objc func showQrButtonTapped(_ sender: UIButton){
        showQRExpandView.isHidden = false
        beldexAddressExpandView.isHidden = true
        bchatIDExpandView.isHidden = true
    }
    
    @objc func linkYourBNSButtonTapped(_ sender: UIButton){
        let vc = LinkBNSVC()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func copyBeldexAddressButtonTapped(_ sender: UIButton){
        UIPasteboard.general.string = SaveUserDefaultsData.WalletpublicAddress
        beldexAddressIdLabel.isUserInteractionEnabled = false
        showToast(message: NSLocalizedString("BELDEX_ADDRESS_COPIED_NEW", comment: ""), seconds: 1.0)
    }
    
    @objc func copyBChatIDButtonTapped(_ sender: UIButton){
        UIPasteboard.general.string = getUserHexEncodedPublicKey()
        bchatIdLabel.isUserInteractionEnabled = false
        showToast(message: NSLocalizedString("BCHAT_ID_COPIED_NEW", comment: ""), seconds: 1.0)
    }
    
    @objc func readMoreAboutBNSViewTapped(_ sender: UITapGestureRecognizer? = nil) {
        let viewController = AboutBNSViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
