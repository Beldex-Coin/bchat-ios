// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class MyAccountViewController: BaseVC, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Components
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("SHARE_OPTION_NEW", comment: ""), for: .normal)
        let image = UIImage(named: "ic_shareNew")?.scaled(to: CGSize(width: 25.0, height: 25.0))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white // Set the tint color to white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.greenColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel!.font = UIDevice.current.isIPad ? Fonts.boldOpenSans(ofSize: 18) : Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.myAccountViewBackgroundColor
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var profilePictureImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profilePictureImageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    
    lazy var verifiedImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 34)
        result.set(.height, to: 34)
        result.contentMode = .scaleAspectFit
        result.image = UIImage(named: "ic_verified_image")
        return result
    }()
    
    private lazy var profilePictureImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(profilePictureImageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cameraImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_camera_dark" : "ic_camera_white1"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    private lazy var cameraImage2: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_camera_dark" : "ic_camera_green"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    private lazy var cameraView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.cameraViewBackgroundColor
        return stackView
    }()
    
    private lazy var cameraView2: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.cameraViewBackgroundColor
        return stackView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.myAccountViewBackgroundColor
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.borderColor.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_close_dark" : "ic_close_white"
        let image = UIImage(named: logoImage)?.scaled(to: CGSize(width: 15, height: 14))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var copyForBeldexAddressButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.greenColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_Newcopy"), for: .normal)
        button.addTarget(self, action: #selector(copyForBeldexAddressButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var beldexAddressBgView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = Colors.backgroundViewColor2
        return stackView
    }()
    
    private lazy var beldexAddressLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("BELDEX_ADDRESS_TITLE_NEW", comment: "")
        result.textColor = Colors.blueColor
        result.font = UIDevice.current.isIPad ? Fonts.semiOpenSans(ofSize: 14) : Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var beldexAddressIdLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.textColor
        result.font = UIDevice.current.isIPad ? Fonts.OpenSans(ofSize: 14) : Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.lineBreakMode = .byCharWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var copyForBChatIdButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.greenColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_Newcopy"), for: .normal)
        button.addTarget(self, action: #selector(copyForBChatIdButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle("", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var bchatIdBgView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = Colors.backgroundViewColor2
        return stackView
    }()
    
    private lazy var bchatLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("BCHAT_ID_NEW", comment: "")
        result.textColor = Colors.greenColor
        result.font = UIDevice.current.isIPad ? Fonts.semiOpenSans(ofSize: 14) : Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var bchatIdLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.textColor
        result.font = UIDevice.current.isIPad ? Fonts.OpenSans(ofSize: 14) : Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.lineBreakMode = .byCharWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var qrBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.backgroundViewColor
        stackView.layer.borderColor = Colors.borderColor.cgColor
        stackView.layer.borderWidth = 1
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var qrCodeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var nameTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("NAME_TITLE_NEW", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.backgroundColor = .clear
        result.textAlignment = .center
        if isNavigationBarHideInChatNewVC == true {
            result.isUserInteractionEnabled = false
        }
        return result
    }()
    
    private lazy var nameIdLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.textColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.textAlignment = .center
        result.numberOfLines = 0
        result.lineBreakMode = .byCharWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nameIdLabelTapped))
        result.isUserInteractionEnabled = true
        result.addGestureRecognizer(tapGesture)
        return result
    }()
    
    private lazy var editIconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_newedit" : "ic_newedit"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nameIdLabelTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private lazy var lineView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.lineViewbackgroundColor
        return stackView
    }()
    
    private lazy var outerProfileView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.outerProfileViewbackgroundColor
        return stackView
    }()
    
    private lazy var innerProfileImageView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.innerProfileImageViewColor
        stackView.layer.cornerRadius = 16
        stackView.layer.borderColor = Colors.borderColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    private lazy var profilePictureLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("PROFILE_PICTURE_NEW", comment: "")
        result.textColor = Colors.greenColor
        result.font = UIDevice.current.isIPad ? Fonts.boldOpenSans(ofSize: 20) : Fonts.boldOpenSans(ofSize: 18)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var innerProfileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(innerProfileImageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    
    private lazy var innerProfileCloseButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_close_dark" : "ic_close_white"
        button.setImage(UIImage(named: logoImage), for: .normal)
        button.addTarget(self, action: #selector(innerProfileCloseTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var removePictureButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString(NSLocalizedString("REMOVE_PICTURE_ACTION_NEW", comment: ""), comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(removePictureButtonAction), for: UIControl.Event.touchUpInside)
        result.backgroundColor = Colors.profileImageViewButtonColor
        result.setTitleColor(Colors.profileImageViewButtonTextColor, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var saveButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString(NSLocalizedString("SAVA_OPTION_NEW", comment: ""), comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(saveButtonAction), for: UIControl.Event.touchUpInside)
        result.layer.cornerRadius = 16
        result.backgroundColor = Colors.greenColor
        result.setTitleColor(UIColor.white, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var buttonStackView1: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ removePictureButton, saveButton ])
        result.axis = .horizontal
        result.spacing = 15
        result.distribution = .fillEqually
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private var displayNameToBeUploaded: String?
    var imagePicker = UIImagePickerController()
    private var profilePictureToBeUploaded: UIImage?
    @objc public var size: CGFloat = 30
    @objc public var openGroupProfilePicture: UIImage?
    @objc public var useFallbackPicture = false
    var isNavigationBarHideInChatNewVC = false
    var isProfileRemove = false
    private var isEditingDisplayName = false { didSet { handleIsEditingDisplayNameChanged() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorNew
        var backGroundViewTopAnchor: CGFloat = 32
        if isNavigationBarHideInChatNewVC == true {
            backGroundViewTopAnchor = 82
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            closeButton.isHidden = false
            cameraView.isHidden = true
            profilePictureImage.isUserInteractionEnabled = false
            profilePictureImageButton.isUserInteractionEnabled = false
            lineView.isHidden = true
            doneButton.isHidden = true
            nameTextField.isHidden = true
            editIconImage.isHidden = true
            nameTextField.isUserInteractionEnabled = false
            nameIdLabel.isUserInteractionEnabled = false
        } else {
            navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.title = "My Account"
            closeButton.isHidden = true
            cameraView.isHidden = false
            lineView.isHidden = true
            doneButton.isHidden = false
            nameTextField.isHidden = true
            editIconImage.isHidden = false
        }
        setUpTopCornerRadius()
        self.outerProfileView.isHidden = true
        view.addSubview(backGroundView)
        view.addSubview(shareButton)
        view.addSubview(verifiedImageView)
        view.addSubview(closeButton)
        
        backGroundView.addSubview(lineView)
        backGroundView.addSubview(qrBackgroundView)
        qrBackgroundView.addSubview(qrCodeImage)
        backGroundView.addSubview(profilePictureImage)
        backGroundView.addSubview(cameraView)
        cameraView.addSubview(cameraImage)
        backGroundView.addSubview(profilePictureImageButton)
        backGroundView.addSubview(nameIdLabel)
        backGroundView.addSubview(editIconImage)
        backGroundView.addSubview(nameTextField)
        backGroundView.addSubview(copyForBeldexAddressButton)
        backGroundView.addSubview(copyForBChatIdButton)
        backGroundView.addSubview(bchatLabel)
        backGroundView.addSubview(bchatIdBgView)
        bchatIdBgView.addSubview(bchatIdLabel)
        backGroundView.addSubview(beldexAddressLabel)
        backGroundView.addSubview(beldexAddressBgView)
        beldexAddressBgView.addSubview(beldexAddressIdLabel)
        view.addSubview(outerProfileView)
        outerProfileView.addSubview(innerProfileImageView)
        view.addSubview(doneButton)
     
        NSLayoutConstraint.activate([
            doneButton.widthAnchor.constraint(equalToConstant: 80),
            doneButton.heightAnchor.constraint(equalToConstant: 28),
            doneButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -12),
            doneButton.centerYAnchor.constraint(equalTo: nameTextField.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            backGroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: backGroundViewTopAnchor),
            //Close
            closeButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: 15),
            closeButton.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: -15),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            //Profile
            profilePictureImage.widthAnchor.constraint(equalToConstant: 96.5),
            profilePictureImage.heightAnchor.constraint(equalToConstant: 96.5),
            profilePictureImage.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 21),
            profilePictureImage.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            profilePictureImage.bottomAnchor.constraint(equalTo: nameIdLabel.topAnchor, constant: -12),
            cameraView.widthAnchor.constraint(equalToConstant: 30),
            cameraView.heightAnchor.constraint(equalToConstant: 30),
            
            profilePictureImageButton.widthAnchor.constraint(equalToConstant: 96.5),
            profilePictureImageButton.heightAnchor.constraint(equalToConstant: 96.5),
            
            cameraImage.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor),
            cameraImage.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor),
            cameraImage.widthAnchor.constraint(equalToConstant: 18),
            cameraImage.heightAnchor.constraint(equalToConstant: 18),
            
            //Name Textfiled
            nameIdLabel.bottomAnchor.constraint(equalTo: bchatLabel.topAnchor, constant: -21),
            nameIdLabel.heightAnchor.constraint(equalToConstant: 30),
            nameIdLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            nameTextField.bottomAnchor.constraint(equalTo: bchatLabel.topAnchor, constant: -21),
            nameTextField.heightAnchor.constraint(equalToConstant: 30),
            nameTextField.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            editIconImage.widthAnchor.constraint(equalToConstant: 14),
            editIconImage.heightAnchor.constraint(equalToConstant: 14),
            editIconImage.leadingAnchor.constraint(equalTo: nameIdLabel.trailingAnchor, constant: 4),
            editIconImage.centerYAnchor.constraint(equalTo: nameIdLabel.centerYAnchor),
            
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor, constant: -5),
            lineView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor, constant: 3),
            lineView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 5),
            //BChat ID
            bchatLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 23),
            bchatLabel.bottomAnchor.constraint(equalTo: bchatIdBgView.topAnchor, constant: -7),
            copyForBChatIdButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            copyForBChatIdButton.centerYAnchor.constraint(equalTo: bchatIdBgView.centerYAnchor),
            copyForBChatIdButton.widthAnchor.constraint(equalToConstant: 28),
            copyForBChatIdButton.heightAnchor.constraint(equalToConstant: 28),
            bchatIdBgView.trailingAnchor.constraint(equalTo: copyForBChatIdButton.leadingAnchor, constant: -9),
            bchatIdBgView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 23),
            bchatIdBgView.bottomAnchor.constraint(equalTo: beldexAddressLabel.topAnchor, constant: -14),
            bchatIdBgView.heightAnchor.constraint(equalToConstant: 64),
            bchatIdLabel.topAnchor.constraint(equalTo: bchatIdBgView.topAnchor, constant: 10),
            bchatIdLabel.bottomAnchor.constraint(equalTo: bchatIdBgView.bottomAnchor, constant: -10),
            bchatIdLabel.leadingAnchor.constraint(equalTo: bchatIdBgView.leadingAnchor, constant: 10),
            bchatIdLabel.trailingAnchor.constraint(equalTo: bchatIdBgView.trailingAnchor, constant: -10),
            //Beldex Address
            beldexAddressLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 23),
            beldexAddressLabel.bottomAnchor.constraint(equalTo: beldexAddressBgView.topAnchor, constant: -7),
            copyForBeldexAddressButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            copyForBeldexAddressButton.centerYAnchor.constraint(equalTo: beldexAddressBgView.centerYAnchor),
            copyForBeldexAddressButton.widthAnchor.constraint(equalToConstant: 28),
            copyForBeldexAddressButton.heightAnchor.constraint(equalToConstant: 28),
            beldexAddressBgView.trailingAnchor.constraint(equalTo: copyForBeldexAddressButton.leadingAnchor, constant: -9),
            beldexAddressBgView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 23),
            beldexAddressBgView.bottomAnchor.constraint(equalTo: qrBackgroundView.topAnchor, constant: -27),
            beldexAddressBgView.heightAnchor.constraint(equalToConstant: 64),
            beldexAddressIdLabel.topAnchor.constraint(equalTo: beldexAddressBgView.topAnchor, constant: 10),
            beldexAddressIdLabel.bottomAnchor.constraint(equalTo: beldexAddressBgView.bottomAnchor, constant: -10),
            beldexAddressIdLabel.leadingAnchor.constraint(equalTo: beldexAddressBgView.leadingAnchor, constant: 10),
            beldexAddressIdLabel.trailingAnchor.constraint(equalTo: beldexAddressBgView.trailingAnchor, constant: -10),
            //QR Code
            qrBackgroundView.widthAnchor.constraint(equalToConstant: 142),
            qrBackgroundView.heightAnchor.constraint(equalToConstant: 142),
            qrBackgroundView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -33),
            qrBackgroundView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            qrCodeImage.topAnchor.constraint(equalTo: qrBackgroundView.topAnchor, constant: 12),
            qrCodeImage.bottomAnchor.constraint(equalTo: qrBackgroundView.bottomAnchor, constant: -12),
            qrCodeImage.leadingAnchor.constraint(equalTo: qrBackgroundView.leadingAnchor, constant: 12),
            qrCodeImage.trailingAnchor.constraint(equalTo: qrBackgroundView.trailingAnchor, constant: -12),
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            shareButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
        verifiedImageView.pin(.trailing, to: .trailing, of: profilePictureImage, withInset: 1)
        verifiedImageView.pin(.bottom, to: .bottom, of: profilePictureImage, withInset: 6)
        let isBnsUser = UserDefaults.standard.bool(forKey: Constants.isBnsVerifiedUser)
        profilePictureImage.layer.borderColor = Colors.bothGreenColor.cgColor
        profilePictureImage.layer.borderWidth = isBnsUser ? 3 : 0
        verifiedImageView.isHidden = isBnsUser ? false : true
        
        if isBnsUser {
            NSLayoutConstraint.activate([
                cameraView.leadingAnchor.constraint(equalTo: profilePictureImage.trailingAnchor, constant: 9),
                cameraView.centerYAnchor.constraint(equalTo: profilePictureImage.centerYAnchor),
                profilePictureImageButton.leadingAnchor.constraint(equalTo: profilePictureImage.trailingAnchor, constant: 9),
                profilePictureImageButton.centerYAnchor.constraint(equalTo: profilePictureImage.centerYAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                cameraView.trailingAnchor.constraint(equalTo: profilePictureImage.trailingAnchor, constant: -1),
                cameraView.bottomAnchor.constraint(equalTo: profilePictureImage.bottomAnchor, constant: -1),
                profilePictureImageButton.centerXAnchor.constraint(equalTo: profilePictureImage.centerXAnchor),
                profilePictureImageButton.centerYAnchor.constraint(equalTo: profilePictureImage.centerYAnchor),
            ])
        }
        
        
        
        if isNavigationBarHideInChatNewVC == true {
            backGroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 160).isActive = true
            shareButton.topAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: 36).isActive = true
        } else {
            backGroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
            shareButton.topAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: 36).isActive = true
        }
        
        shareButton.backgroundColor = Colors.greenColor
        shareButton.setTitleColor(.white, for: .normal)
        // Display image
        let publicKey = getUserHexEncodedPublicKey()
        profilePictureImage.image = useFallbackPicture ? nil : (openGroupProfilePicture ?? getProfilePicture(of: size, for: publicKey))
        profilePictureImage.layer.cornerRadius = profilePictureImage.frame.height/2
        profilePictureImage.clipsToBounds = true
        innerProfileImage.image = useFallbackPicture ? nil : (openGroupProfilePicture ?? getProfilePicture(of: size, for: publicKey))
        innerProfileImage.clipsToBounds = true
        // Display name label
        let nam = Storage.shared.getUser()?.name
        nameIdLabel.text = nam ?? UserDefaults.standard.string(forKey: "WalletName")?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        bchatIdLabel.text = "\(getUserHexEncodedPublicKey())"
        beldexAddressIdLabel.text = "\(SaveUserDefaultsData.WalletpublicAddress)"
        let qrCode = QRCode.generate(for: getUserHexEncodedPublicKey(), hasBackground: true)
        qrCodeImage.image = qrCode
        
        // Edit name textfiled
        nameTextField.delegate = self
        nameTextField.text = nam ?? UserDefaults.standard.string(forKey: "WalletName")?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        innerProfileImageView.addSubview(profilePictureLabel)
        innerProfileImageView.addSubview(innerProfileCloseButton)
        innerProfileImageView.addSubview(innerProfileImage)
        innerProfileImageView.addSubview(cameraView2)
        cameraView2.addSubview(cameraImage2)
        innerProfileImageView.addSubview(buttonStackView1)
        
        NSLayoutConstraint.activate([
            outerProfileView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            outerProfileView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            outerProfileView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
            outerProfileView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            innerProfileImageView.leadingAnchor.constraint(equalTo: outerProfileView.leadingAnchor, constant: 15),
            innerProfileImageView.trailingAnchor.constraint(equalTo: outerProfileView.trailingAnchor, constant: -15),
            innerProfileImageView.centerXAnchor.constraint(equalTo: outerProfileView.centerXAnchor),
            innerProfileImageView.centerYAnchor.constraint(equalTo: outerProfileView.centerYAnchor),
            profilePictureLabel.topAnchor.constraint(equalTo: innerProfileImageView.topAnchor, constant: 20),
            profilePictureLabel.centerXAnchor.constraint(equalTo: innerProfileImageView.centerXAnchor),
            innerProfileCloseButton.trailingAnchor.constraint(equalTo: innerProfileImageView.trailingAnchor, constant: -10),
            innerProfileCloseButton.centerYAnchor.constraint(equalTo: profilePictureLabel.centerYAnchor),
            innerProfileCloseButton.widthAnchor.constraint(equalToConstant: 30),
            innerProfileCloseButton.heightAnchor.constraint(equalToConstant: 30),
            innerProfileImage.widthAnchor.constraint(equalToConstant: 96.5),
            innerProfileImage.heightAnchor.constraint(equalToConstant: 96.5),
            innerProfileImage.centerXAnchor.constraint(equalTo: innerProfileImageView.centerXAnchor),
            innerProfileImage.topAnchor.constraint(equalTo: profilePictureLabel.bottomAnchor, constant: 15),
            cameraView2.trailingAnchor.constraint(equalTo: innerProfileImage.trailingAnchor, constant: -1),
            cameraView2.bottomAnchor.constraint(equalTo: innerProfileImage.bottomAnchor, constant: -1),
            cameraView2.widthAnchor.constraint(equalToConstant: 30),
            cameraView2.heightAnchor.constraint(equalToConstant: 30),
            cameraImage2.centerYAnchor.constraint(equalTo: cameraView2.centerYAnchor),
            cameraImage2.centerXAnchor.constraint(equalTo: cameraView2.centerXAnchor),
            cameraImage2.widthAnchor.constraint(equalToConstant: 18),
            cameraImage2.heightAnchor.constraint(equalToConstant: 18),
            buttonStackView1.heightAnchor.constraint(equalToConstant: 52),
            buttonStackView1.topAnchor.constraint(equalTo: innerProfileImage.bottomAnchor, constant: 20),
            buttonStackView1.trailingAnchor.constraint(equalTo: innerProfileImageView.trailingAnchor, constant: -20),
            buttonStackView1.leadingAnchor.constraint(equalTo: innerProfileImageView.leadingAnchor, constant: 20),
            buttonStackView1.bottomAnchor.constraint(equalTo: innerProfileImageView.bottomAnchor, constant: -22),
        ])
        
        let dismiss: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismiss)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePictureImage.layer.cornerRadius = profilePictureImage.frame.height / 2
        profilePictureImageButton.layer.cornerRadius = profilePictureImageButton.frame.height / 2
        innerProfileImage.layer.cornerRadius = innerProfileImage.frame.height / 2
        closeButton.layer.cornerRadius = closeButton.frame.height / 2
        copyForBeldexAddressButton.layer.cornerRadius = copyForBeldexAddressButton.frame.height / 2
        copyForBChatIdButton.layer.cornerRadius = copyForBChatIdButton.frame.height / 2
        removePictureButton.layer.cornerRadius = removePictureButton.frame.height / 2
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        doneButton.layer.cornerRadius = doneButton.frame.height / 2
        cameraView.layer.cornerRadius = cameraView.frame.height / 2
        cameraView2.layer.cornerRadius = cameraView2.frame.height / 2
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func getProfilePicture(of size: CGFloat, for publicKey: String) -> UIImage? {
        guard !publicKey.isEmpty else { return nil }
        if let profilePicture = OWSProfileManager.shared().profileAvatar(forRecipientId: publicKey) {
            //  hasTappableProfilePicture = true
            return profilePicture
        } else {
            //  hasTappableProfilePicture = false
            // TODO: Pass in context?
            let displayName = Storage.shared.getContact(with: publicKey)?.name ?? publicKey
            return Identicon.generatePlaceholderIcon(seed: publicKey, text: displayName, size: size)
        }
    }
    
    // MARK: General
    @objc func profilePictureImageTapped() {
        self.outerProfileView.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    //Profile pic action
    @objc func profilePictureImageButtonTapped() {
        self.outerProfileView.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func innerProfileImageTapped() {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openCamera(UIImagePickerController.SourceType.camera)
        }
        let gallaryAction = UIAlertAction(title: "Choose Photo", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.openCamera(UIImagePickerController.SourceType.photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
        }
        // Add the actions
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func innerProfileCloseTapped() {
        self.outerProfileView.isHidden = true
        profilePictureToBeUploaded = nil
        let publicKey = getUserHexEncodedPublicKey()
        profilePictureImage.image = useFallbackPicture ? nil : (openGroupProfilePicture ?? getProfilePicture(of: size, for: publicKey))
        innerProfileImage.image = useFallbackPicture ? nil : (openGroupProfilePicture ?? getProfilePicture(of: size, for: publicKey))
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func openCamera(_ sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isEditingDisplayName = true
        lineView.isHidden = false
    }
    
    private func handleIsEditingDisplayNameChanged() {

    }
    
    // Action to perform when label is tapped
    @objc private func nameIdLabelTapped() {
        UIView.animate(withDuration: 0.25) { [self] in
            nameIdLabel.text = displayNameToBeUploaded
        }
        nameTextField.becomeFirstResponder()
        nameIdLabel.font = Fonts.boldOpenSans(ofSize: 18)
        doneButton.backgroundColor = Colors.greenColor
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = Fonts.semiOpenSans(ofSize: 14)
        isEditingDisplayName = true
        nameTextField.isHidden = false
        nameIdLabel.isHidden = true
        editIconImage.isHidden = true
        lineView.isHidden = false
    }
    
    //MARK:UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage:UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        let maxSize = Int(kOWSProfileManager_MaxAvatarDiameter)
        profilePictureToBeUploaded = tempImage.resizedImage(toFillPixelSize: CGSize(width: maxSize, height: maxSize))
        innerProfileImage.image = profilePictureToBeUploaded
        innerProfileImage.contentMode = .scaleAspectFit
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateProfile(isUpdatingDisplayName: Bool, isUpdatingProfilePicture: Bool) {
        let userDefaults = UserDefaults.standard
        let name = displayNameToBeUploaded ?? Storage.shared.getUser()?.name
        var profilePicture: UIImage?
        if self.isProfileRemove {
            profilePicture = openGroupProfilePicture
        } else {
            profilePicture = profilePictureToBeUploaded ?? OWSProfileManager.shared().profileAvatar(forRecipientId: getUserHexEncodedPublicKey())
        }
        
        ModalActivityIndicatorViewController.present(fromViewController: navigationController!, canCancel: false) { [weak self, displayNameToBeUploaded, profilePictureToBeUploaded] modalActivityIndicator in
            OWSProfileManager.shared().updateLocalProfileName(name, avatarImage: profilePicture, success: {
                if displayNameToBeUploaded != nil {
                    userDefaults[.lastDisplayNameUpdate] = Date()
                }
                if profilePictureToBeUploaded != nil {
                    userDefaults[.lastProfilePictureUpdate] = Date()
                } else {
                    let publicKey = getUserHexEncodedPublicKey()
                    let displayName = Storage.shared.getContact(with: publicKey)?.name ?? publicKey
                    self?.profilePictureImage.image = Identicon.generatePlaceholderIcon(seed: publicKey, text: displayName, size: self!.size)
                    self?.isProfileRemove = false
                }
                let publicKey = getUserHexEncodedPublicKey()
                self?.innerProfileImage.image = self!.useFallbackPicture ? nil : (self?.openGroupProfilePicture ?? self?.getProfilePicture(of: self!.size, for: publicKey))
                self?.outerProfileView.isHidden = true
                
                MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                DispatchQueue.main.async {
                    modalActivityIndicator.dismiss {
                        guard let self = self else { return }
                        self.nameIdLabel.text = name
                        //get the Profile picture
                        let publicKey = getUserHexEncodedPublicKey()
                        self.profilePictureImage.image = self.useFallbackPicture ? nil : (self.openGroupProfilePicture ?? self.getProfilePicture(of: self.size, for: publicKey))
                        self.profilePictureToBeUploaded = nil
                        self.displayNameToBeUploaded = nil
                    }
                }
            }, failure: { error in
                DispatchQueue.main.async {
                    modalActivityIndicator.dismiss {
                        self?.outerProfileView.isHidden = true
                        var isMaxFileSizeExceeded = false
                        if let error = error as? FileServerAPIV2.Error {
                            isMaxFileSizeExceeded = (error == .maxFileSizeExceeded)
                        }
                        let title = isMaxFileSizeExceeded ? "Maximum File Size Exceeded" : "Couldn't Update Profile"
                        let message = isMaxFileSizeExceeded ? "Please select a smaller photo and try again" : "Please check your internet connection and try again"
                        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }, requiresSync: true)
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func removePictureButtonAction(){
        let publicKey = getUserHexEncodedPublicKey()
        guard !publicKey.isEmpty else { return  }
        if OWSProfileManager.shared().profileAvatar(forRecipientId: publicKey) == nil {
            return
        }
        self.isProfileRemove = true
        self.outerProfileView.isHidden = true
        clearAvatar()
    }
    
    @objc func saveButtonAction() {
        if profilePictureToBeUploaded != nil {
            profilePictureImage.image = profilePictureToBeUploaded
            profilePictureImage.contentMode = .scaleAspectFit
            self.outerProfileView.isHidden = true
            updateProfile(isUpdatingDisplayName: false, isUpdatingProfilePicture: true)
        } else {
            let alert = UIAlertController(title: "Please pick a profile picture", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //name Edit Save Button
    @objc func doneButtonTapped(_ sender: UIButton){
        if isEditingDisplayName {
            lineView.isHidden = true
            func showError(title: String, message: String = "") {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
                presentAlert(alert)
            }
            let displayName = nameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            guard !displayName.isEmpty else {
                return showError(title: NSLocalizedString("vc_settings_display_name_missing_error", comment: ""))
            }
            guard !OWSProfileManager.shared().isProfileNameTooLong(displayName) else {
                return showError(title: NSLocalizedString("vc_settings_display_name_too_long_error", comment: ""))
            }
            isEditingDisplayName = false
            displayNameToBeUploaded = displayName
            updateProfile(isUpdatingDisplayName: true, isUpdatingProfilePicture: false)
        }
        doneButton.backgroundColor = .clear
        doneButton.setTitle("", for: .normal)
        nameTextField.isHidden = true
        nameIdLabel.isHidden = false
        editIconImage.isHidden = false
    }
    
    func clearAvatar() {
        profilePictureToBeUploaded = nil
        updateProfile(isUpdatingDisplayName: false, isUpdatingProfilePicture: true)
    }
    
    @objc func shareButtonTapped() {
        let qrCode = QRCode.generate(for: getUserHexEncodedPublicKey(), hasBackground: true)
        let shareVC = UIActivityViewController(activityItems: [ qrCode ], applicationActivities: nil)
        self.navigationController!.present(shareVC, animated: true, completion: nil)
    }
    
    @objc func closeButtonTapped(){
        navigationController?.popViewController(animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func copyForBeldexAddressButtonTapped(){
        UIPasteboard.general.string = SaveUserDefaultsData.WalletpublicAddress
        beldexAddressIdLabel.isUserInteractionEnabled = false
        self.showToast(message: NSLocalizedString("BELDEX_ADDRESS_COPIED_NEW", comment: ""), seconds: 1.0)
    }
    
    @objc func copyForBChatIdButtonTapped() {
        UIPasteboard.general.string = getUserHexEncodedPublicKey()
        bchatIdLabel.isUserInteractionEnabled = false
        self.showToast(message: NSLocalizedString("BCHAT_ID_COPIED_NEW", comment: ""), seconds: 1.0)
    }
    
}
