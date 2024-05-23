// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class MyAccountBnsNewVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UIElements
    
    /// TopBackGround view
    private lazy var topBackGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.myAccountViewBackgroundColor
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    /// Bottom BackGround View
    private lazy var bottomBackGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.myAccountViewBackgroundColor
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    /// Profile Picture Image
    private lazy var profilePictureImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 43 // This will be updated correctly in `viewDidLayoutSubviews`
        imageView.clipsToBounds = true
        let logoImage = isLightMode ? "ic_userImageNew" : "ic_userImageNew"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
//        imageView.layer.borderWidth = 3
//        imageView.layer.borderColor = UIColor.red.cgColor
        return imageView
    }()
    
    /// Shadow Background Image
    private lazy var shadowBackgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "shadow_image" : "shadow_image"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// User Name Id Label
    private lazy var userNameIdLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.textColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.text = "Sreek"
        result.textAlignment = .center
        result.numberOfLines = 0
        result.lineBreakMode = .byCharWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Edit Icon Image
    private lazy var editIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_newedit" : "ic_newedit"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Stack View For UserName
    lazy var stackViewForUserName: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 1
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    /// Bns Verified Label
    private lazy var bnsVerifiedLabel: UILabel = {
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
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 4
        return result
    }()
    
    /// Beldex Address View
    private lazy var beldexAddressView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 10
        return stackView
    }()
    
    /// Beldex Address Button
    private lazy var beldexAddressButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(beldexAddressButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Bchat Id View
    private lazy var bchatIdView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 10
        return stackView
    }()
    
    /// Bchat Id Button
    private lazy var bchatIdButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(bchatIdButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Show Qr View
    private lazy var showQrView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 10
        return stackView
    }()
    
    /// Show Qr Button
    private lazy var showQrButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
        button.setTitleColor(.white, for: .normal)
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
    lazy var copyImageBeldexAddress: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_copy_newimage" : "ic_copy_newimage"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Copy Image Bchat ID
    lazy var copyImageBchatID: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_copy_newimage" : "ic_copy_newimage"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Beldex Address NameLabel
    private lazy var beldexAddressNameLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("Beldex Address", comment: "")
        result.textColor = .white//Colors.greenColor
        result.font = Fonts.semiOpenSans(ofSize: 11)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Bchat Name Label
    private lazy var bchatNameLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("BChat ID", comment: "")
        result.textColor = .white//Colors.greenColor
        result.font = Fonts.semiOpenSans(ofSize: 11)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Show Qr Code Label
    private lazy var showQrCodeLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("Show QR", comment: "")
        result.textColor = .white//Colors.greenColor
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
        let logoImage = isLightMode ? "ic_ShowQr_logo" : "ic_ShowQr_logo"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    /// Link Your BNS Background View
    private lazy var linkYourBNSBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.bothGreenColor//UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 12
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
        result.textColor = .white//Colors.greenColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Read More About Background View
    private lazy var readMoreAboutBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear//Colors.bothGreenColor//UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 12
        return stackView
    }()
    
    /// Read More About BNS Name Label
    private lazy var readMoreAboutBNSNameLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("Read more about BNS", comment: "")
        result.textColor = .white//Colors.greenColor
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
    
    let tableView : UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let imageArray = ["ic_hops", "ic_change_password",/*"ic_app_lock"*/ /*"ic_chat_settings",*/ "ic_blocked_contacts", "ic_clear_data", "ic_feedback", "ic_faq", "ic_changelog"]
    let titleArray = ["Hops", "Change Password",/*"App Lock"*/ /*"Chat Settings",*/ "Blocked Contacts", "Clear Data", "Feedback", "FAQ", "Changelog"]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorNew
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "My Account"
        
        view.addSubview(topBackGroundView)
        topBackGroundView.addSubview(profilePictureImage)
        topBackGroundView.addSubview(shadowBackgroundImage)
        
        topBackGroundView.addSubview(stackViewForUserName)
        stackViewForUserName.addArrangedSubview(userNameIdLabel)
        stackViewForUserName.addArrangedSubview(editIconImage)
        
        topBackGroundView.addSubview(stackViewForBNSVerifiedName)
        stackViewForBNSVerifiedName.addArrangedSubview(bnsVerifiedLabel)
        stackViewForBNSVerifiedName.addArrangedSubview(bnsTickIconImage)
        
        topBackGroundView.addSubview(stackViewForUserNameAndBnsVerifiedContainer)
        stackViewForUserNameAndBnsVerifiedContainer.addArrangedSubview(stackViewForUserName)
        stackViewForUserNameAndBnsVerifiedContainer.addArrangedSubview(stackViewForBNSVerifiedName)
        
        beldexAddressView.addSubview(copyImageBeldexAddress)
        bchatIdView.addSubview(copyImageBchatID)
        
        beldexAddressView.addSubview(beldexAddressNameLabel)
        bchatIdView.addSubview(bchatNameLabel)
        showQrView.addSubview(showQrCodeLabel)
        
        beldexAddressView.addSubview(beldexLogoImage)
        bchatIdView.addSubview(bchatLogoImage)
        showQrView.addSubview(showQrLogoImage)
        
        beldexAddressView.addSubview(beldexAddressButton)
        bchatIdView.addSubview(bchatIdButton)
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
        
        view.addSubview(stackViewForFinalLinkBNS)
        stackViewForFinalLinkBNS.addArrangedSubview(linkYourBNSBackgroundView)
        stackViewForFinalLinkBNS.addArrangedSubview(readMoreAboutBackgroundView)
        
        //bottom BackGround View
        view.addSubview(bottomBackGroundView)
        bottomBackGroundView.addSubview(tableView)
        
        
        // Not Verified
//        shadowBackgroundImage.isHidden = true
//        stackViewForBNSVerifiedName.isHidden = true
//        linkYourBNSBackgroundView.isHidden = false
//        readMoreAboutBackgroundView.isHidden = false
        
        // BNS Verified
        shadowBackgroundImage.isHidden = false
        stackViewForBNSVerifiedName.isHidden = false
        stackViewForFinalLinkBNS.isHidden = false
        linkYourBNSBackgroundView.isHidden = true
        readMoreAboutBackgroundView.isHidden = true
        
        
        NSLayoutConstraint.activate([
            topBackGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            topBackGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
//            topBackGroundView.widthAnchor.constraint(equalToConstant: 361),
//            topBackGroundView.heightAnchor.constraint(equalToConstant: 185),
            
            profilePictureImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            profilePictureImage.widthAnchor.constraint(equalToConstant: 86),
            profilePictureImage.heightAnchor.constraint(equalToConstant: 86),
            profilePictureImage.centerXAnchor.constraint(equalTo: topBackGroundView.centerXAnchor),
            profilePictureImage.centerYAnchor.constraint(equalTo: topBackGroundView.topAnchor),
            
            shadowBackgroundImage.leadingAnchor.constraint(equalTo: topBackGroundView.leadingAnchor, constant: 0),
            shadowBackgroundImage.trailingAnchor.constraint(equalTo: topBackGroundView.trailingAnchor, constant: -0),
            shadowBackgroundImage.topAnchor.constraint(equalTo: topBackGroundView.topAnchor, constant: 0),
            shadowBackgroundImage.bottomAnchor.constraint(equalTo: topBackGroundView.bottomAnchor, constant: -0),
            
//            userNameIdLabel.topAnchor.constraint(equalTo: profilePictureImage.bottomAnchor, constant: 2),
            userNameIdLabel.centerXAnchor.constraint(equalTo: profilePictureImage.centerXAnchor),
//
            editIconImage.widthAnchor.constraint(equalToConstant: 14),
            editIconImage.heightAnchor.constraint(equalToConstant: 14),
            editIconImage.leadingAnchor.constraint(equalTo: userNameIdLabel.trailingAnchor, constant: 4),
            editIconImage.centerYAnchor.constraint(equalTo: userNameIdLabel.centerYAnchor),
//
//            bnsVerifiedLabel.topAnchor.constraint(equalTo: nameIdLabel.bottomAnchor, constant: 2),
//            bnsVerifiedLabel.centerXAnchor.constraint(equalTo: nameIdLabel.centerXAnchor),
//            
            bnsTickIconImage.widthAnchor.constraint(equalToConstant: 14),
            bnsTickIconImage.heightAnchor.constraint(equalToConstant: 14),
            bnsTickIconImage.leadingAnchor.constraint(equalTo: bnsVerifiedLabel.trailingAnchor, constant: 4),
            bnsTickIconImage.centerYAnchor.constraint(equalTo: bnsVerifiedLabel.centerYAnchor),
            
            
//            stackViewIsName.topAnchor.constraint(equalTo: profilePictureImage.bottomAnchor, constant: 2),
//            stackViewIsName.centerXAnchor.constraint(equalTo: profilePictureImage.centerXAnchor),
            
//            stackViewIsBNSVerifiedName.topAnchor.constraint(equalTo: stackViewIsName.bottomAnchor, constant: 4),
//            stackViewIsBNSVerifiedName.centerXAnchor.constraint(equalTo: profilePictureImage.centerXAnchor),
            
            stackViewForUserNameAndBnsVerifiedContainer.topAnchor.constraint(equalTo: profilePictureImage.bottomAnchor, constant: 5),
            stackViewForUserNameAndBnsVerifiedContainer.centerXAnchor.constraint(equalTo: profilePictureImage.centerXAnchor),
//
            beldexAddressView.heightAnchor.constraint(equalToConstant: 73),
            bchatIdView.heightAnchor.constraint(equalToConstant: 73),
            showQrView.heightAnchor.constraint(equalToConstant: 73),
            
            copyImageBeldexAddress.topAnchor.constraint(equalTo: beldexAddressView.topAnchor, constant: 8),
            copyImageBeldexAddress.trailingAnchor.constraint(equalTo: beldexAddressView.trailingAnchor, constant: -8),
            copyImageBeldexAddress.widthAnchor.constraint(equalToConstant: 12),
            copyImageBeldexAddress.heightAnchor.constraint(equalToConstant: 12),
            
            copyImageBchatID.topAnchor.constraint(equalTo: bchatIdView.topAnchor, constant: 8),
            copyImageBchatID.trailingAnchor.constraint(equalTo: bchatIdView.trailingAnchor, constant: -8),
            copyImageBchatID.widthAnchor.constraint(equalToConstant: 12),
            copyImageBchatID.heightAnchor.constraint(equalToConstant: 12),
            
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
            
            stackViewThreeVerticalElementsContainer.topAnchor.constraint(equalTo: stackViewForUserNameAndBnsVerifiedContainer.bottomAnchor, constant: 15),
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
            
            
        ])
        
        // Display name label
        let nam = Storage.shared.getUser()?.name
        userNameIdLabel.text = nam ?? UserDefaults.standard.string(forKey: "WalletName")?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        
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
        
        
        
        
    }//LinkBNSVC
    
    /// View will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// View did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// View will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /// View did disappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePictureImage.layer.cornerRadius = profilePictureImage.frame.height / 2
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func beldexAddressButtonTapped(_ sender: UIButton){
        print("-------->beldexAddressButtonTapped")
    }
    
    @objc func bchatIdButtonTapped(_ sender: UIButton){
        print("-------->bchatIdButtonTapped")
    }
    
    @objc func showQrButtonTapped(_ sender: UIButton){
        print("-------->showQrButtonTapped")
    }
    
    @objc func linkYourBNSButtonTapped(_ sender: UIButton){
        print("-------->linkYourBNSButtonTapped")
        let vc = LinkBNSVC()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    // TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewSettingsTableViewCell") as! NewSettingsTableViewCell
        
        if indexPath.row == 0 {
            cell.smallDotView.isHidden = false
        }
        if indexPath.row  > 2 {
            cell.arrowButton.isHidden = true
        }
        cell.titleLabel.text = self.titleArray[indexPath.row]
        cell.iconImageView.image = UIImage(named: self.imageArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 { //Hops
            let vc = NewHopsVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if indexPath.row == 1 { //Change password
            let vc = NewPasswordVC()
            vc.isGoingBack = true
            vc.isCreatePassword = true
            vc.isChangePassword = true
            navigationController!.pushViewController(vc, animated: true)
        }
        
        if indexPath.row == 2 {//Blocked contact
            let vc = NewBlockedContactVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if indexPath.row == 3 {//Clear data
            let vc = NewClearDataVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        
        if indexPath.row == 4 {//Feedback
            if let url = URL(string: "mailto:\(bchat_email_Feedback)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        if indexPath.row == 5 {//FAQ
            let url = URL(string: bchat_FAQ_Link)!
            UIApplication.shared.open(url)
        }
        
        if indexPath.row == 6 {//Changelog
            let vc = ChangeLogNewVC()
            navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    
}
