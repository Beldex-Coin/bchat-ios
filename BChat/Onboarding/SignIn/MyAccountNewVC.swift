// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class MyAccountNewVC: BaseVC,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
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
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.viewBackgroundColor
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    private lazy var profilePictureImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_userImageNew", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profilePictureImageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    private lazy var cameraImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Newcamera", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    private lazy var cameraImage2: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Newcamera", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.viewBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "X"), for: .normal)
        button.layer.borderColor = Colors.borderColor.cgColor
        button.layer.borderWidth = 1
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
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var beldexAddressIdLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.textColor
        result.font = Fonts.OpenSans(ofSize: 12)
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
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var bchatIdLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.textColor
        result.font = Fonts.OpenSans(ofSize: 12)
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
        result.font = Fonts.OpenSans(ofSize: 18)
        result.backgroundColor = Colors.viewBackgroundColor
        result.textAlignment = .center
        if isNavigationBarHideInChatNewVC == true {
            result.isUserInteractionEnabled = false
        }else {
            let rightImageView = UIImageView(image: UIImage(named: "ic_newedit"))
            rightImageView.contentMode = .center
            let imageWidth = 14.0
            rightImageView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: result.frame.height)
            result.rightView = rightImageView
            result.rightViewMode = .always
        }
        return result
    }()
    
    
    //-------------------------------------------------------------------------
    
    private lazy var outerProfileView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        return stackView
    }()
    private lazy var innerProfileImageView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x111119)
        stackView.layer.cornerRadius = 16
        stackView.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    private lazy var profilePictureLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("PROFILE_PICTURE_NEW", comment: "")
        result.textColor = Colors.greenColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var innerProfileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_userImageNew", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(innerProfileImageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    private lazy var innerProfileCloseButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "X"), for: .normal)
        button.addTarget(self, action: #selector(innerProfileCloseTapped), for: .touchUpInside)
        return button
    }()
    private lazy var removePictureButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString(NSLocalizedString("REMOVE_PICTURE_ACTION_NEW", comment: ""), comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(removePictureButtonAction), for: UIControl.Event.touchUpInside)
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.setTitleColor(.lightGray, for: .normal)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x11111A)
        if isNavigationBarHideInChatNewVC == true {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            closeButton.isHidden = false
            cameraImage.isHidden = true
            profilePictureImage.isUserInteractionEnabled = false
        }else {
            navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "My Account", style: .plain, target: nil, action: nil)
            closeButton.isHidden = true
            cameraImage.isHidden = false
        }
        self.outerProfileView.isHidden = true
        view.addSubview(backGroundView)
        view.addSubview(shareButton)
        
        backGroundView.addSubview(qrBackgroundView)
        qrBackgroundView.addSubview(qrCodeImage)
        backGroundView.addSubview(profilePictureImage)
        backGroundView.addSubview(cameraImage)
        backGroundView.addSubview(closeButton)
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
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            backGroundView.bottomAnchor.constraint(equalTo: shareButton.topAnchor, constant: -36),
            backGroundView.topAnchor.constraint(equalTo: profilePictureImage.firstBaselineAnchor, constant: 48),
        ])
        //Close
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: 15),
            closeButton.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: -15),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
        ])
        //Profile
        NSLayoutConstraint.activate([
            profilePictureImage.widthAnchor.constraint(equalToConstant: 96.5),
            profilePictureImage.heightAnchor.constraint(equalToConstant: 96.5),
            profilePictureImage.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            profilePictureImage.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: -12),
        ])
        NSLayoutConstraint.activate([
            cameraImage.trailingAnchor.constraint(equalTo: profilePictureImage.trailingAnchor, constant: -1),
            cameraImage.bottomAnchor.constraint(equalTo: profilePictureImage.bottomAnchor, constant: -1),
            cameraImage.widthAnchor.constraint(equalToConstant: 30),
            cameraImage.heightAnchor.constraint(equalToConstant: 30),
        ])
        //Name Textfiled
        NSLayoutConstraint.activate([
            nameTextField.bottomAnchor.constraint(equalTo: bchatLabel.topAnchor, constant: -21),
            nameTextField.heightAnchor.constraint(equalToConstant: 25),
            nameTextField.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
        ])
        //BChat ID
        NSLayoutConstraint.activate([
            bchatLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 23),
            bchatLabel.bottomAnchor.constraint(equalTo: bchatIdBgView.topAnchor, constant: -7),
        ])
        NSLayoutConstraint.activate([
            copyForBChatIdButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            copyForBChatIdButton.centerYAnchor.constraint(equalTo: bchatIdBgView.centerYAnchor),
            copyForBChatIdButton.widthAnchor.constraint(equalToConstant: 28),
            copyForBChatIdButton.heightAnchor.constraint(equalToConstant: 28),
        ])
        NSLayoutConstraint.activate([
            bchatIdBgView.trailingAnchor.constraint(equalTo: copyForBChatIdButton.leadingAnchor, constant: -9),
            bchatIdBgView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 23),
            bchatIdBgView.bottomAnchor.constraint(equalTo: beldexAddressLabel.topAnchor, constant: -14),
            bchatIdBgView.heightAnchor.constraint(equalToConstant: 64),
        ])
        NSLayoutConstraint.activate([
            bchatIdLabel.topAnchor.constraint(equalTo: bchatIdBgView.topAnchor, constant: 10),
            bchatIdLabel.bottomAnchor.constraint(equalTo: bchatIdBgView.bottomAnchor, constant: -10),
            bchatIdLabel.leadingAnchor.constraint(equalTo: bchatIdBgView.leadingAnchor, constant: 10),
            bchatIdLabel.trailingAnchor.constraint(equalTo: bchatIdBgView.trailingAnchor, constant: -10),
        ])
        //Beldex Address
        NSLayoutConstraint.activate([
            beldexAddressLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 23),
            beldexAddressLabel.bottomAnchor.constraint(equalTo: beldexAddressBgView.topAnchor, constant: -7),
        ])
        NSLayoutConstraint.activate([
            copyForBeldexAddressButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            copyForBeldexAddressButton.centerYAnchor.constraint(equalTo: beldexAddressBgView.centerYAnchor),
            copyForBeldexAddressButton.widthAnchor.constraint(equalToConstant: 28),
            copyForBeldexAddressButton.heightAnchor.constraint(equalToConstant: 28),
        ])
        NSLayoutConstraint.activate([
            beldexAddressBgView.trailingAnchor.constraint(equalTo: copyForBeldexAddressButton.leadingAnchor, constant: -9),
            beldexAddressBgView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 23),
            beldexAddressBgView.bottomAnchor.constraint(equalTo: qrBackgroundView.topAnchor, constant: -27),
            beldexAddressBgView.heightAnchor.constraint(equalToConstant: 64),
        ])
        NSLayoutConstraint.activate([
            beldexAddressIdLabel.topAnchor.constraint(equalTo: beldexAddressBgView.topAnchor, constant: 10),
            beldexAddressIdLabel.bottomAnchor.constraint(equalTo: beldexAddressBgView.bottomAnchor, constant: -10),
            beldexAddressIdLabel.leadingAnchor.constraint(equalTo: beldexAddressBgView.leadingAnchor, constant: 10),
            beldexAddressIdLabel.trailingAnchor.constraint(equalTo: beldexAddressBgView.trailingAnchor, constant: -10),
        ])
        //QR Code
        NSLayoutConstraint.activate([
            qrBackgroundView.widthAnchor.constraint(equalToConstant: 142),
            qrBackgroundView.heightAnchor.constraint(equalToConstant: 142),
            qrBackgroundView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -33),
            qrBackgroundView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
        ])
        NSLayoutConstraint.activate([
            qrCodeImage.topAnchor.constraint(equalTo: qrBackgroundView.topAnchor, constant: 8),
            qrCodeImage.bottomAnchor.constraint(equalTo: qrBackgroundView.bottomAnchor, constant: -8),
            qrCodeImage.leadingAnchor.constraint(equalTo: qrBackgroundView.leadingAnchor, constant: 8),
            qrCodeImage.trailingAnchor.constraint(equalTo: qrBackgroundView.trailingAnchor, constant: -8),
        ])
        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            shareButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
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
        nameTextField.text = nam ?? UserDefaults.standard.string(forKey: "WalletName")?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        nameTextField.delegate = self
        bchatIdLabel.text = "\(getUserHexEncodedPublicKey())"
        beldexAddressIdLabel.text = "\(SaveUserDefaultsData.WalletpublicAddress)"
        let qrCode = QRCode.generate(for: getUserHexEncodedPublicKey(), hasBackground: true)
        qrCodeImage.image = qrCode
       
        innerProfileImageView.addSubview(profilePictureLabel)
        innerProfileImageView.addSubview(innerProfileCloseButton)
        innerProfileImageView.addSubview(innerProfileImage)
        innerProfileImageView.addSubview(cameraImage2)
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
            
            cameraImage2.trailingAnchor.constraint(equalTo: innerProfileImage.trailingAnchor, constant: -1),
            cameraImage2.bottomAnchor.constraint(equalTo: innerProfileImage.bottomAnchor, constant: -1),
            cameraImage2.widthAnchor.constraint(equalToConstant: 30),
            cameraImage2.heightAnchor.constraint(equalToConstant: 30),
            
            buttonStackView1.heightAnchor.constraint(equalToConstant: 52),
            buttonStackView1.topAnchor.constraint(equalTo: innerProfileImage.bottomAnchor, constant: 20),
            buttonStackView1.trailingAnchor.constraint(equalTo: innerProfileImageView.trailingAnchor, constant: -20),
            buttonStackView1.leadingAnchor.constraint(equalTo: innerProfileImageView.leadingAnchor, constant: 20),
            buttonStackView1.bottomAnchor.constraint(equalTo: innerProfileImageView.bottomAnchor, constant: -22),
            
        ])
    
    
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePictureImage.layer.cornerRadius = profilePictureImage.frame.height / 2
        innerProfileImage.layer.cornerRadius = innerProfileImage.frame.height / 2
        closeButton.layer.cornerRadius = closeButton.frame.height / 2
        copyForBeldexAddressButton.layer.cornerRadius = copyForBeldexAddressButton.frame.height / 2
        copyForBChatIdButton.layer.cornerRadius = copyForBChatIdButton.frame.height / 2
        removePictureButton.layer.cornerRadius = removePictureButton.frame.height / 2
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
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
    @objc func profilePictureImageTapped(){
        self.outerProfileView.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func innerProfileImageTapped(){
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
    
    @objc func innerProfileCloseTapped(){
        self.outerProfileView.isHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func openCamera(_ sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK:UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage:UIImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!
        let maxSize = Int(kOWSProfileManager_MaxAvatarDiameter)
        profilePictureToBeUploaded = tempImage.resizedImage(toFillPixelSize: CGSize(width: maxSize, height: maxSize))
        profilePictureImage.image = profilePictureToBeUploaded
        profilePictureImage.contentMode = .scaleAspectFit
        innerProfileImage.image = profilePictureToBeUploaded
        innerProfileImage.contentMode = .scaleAspectFit
        imagePicker.dismiss(animated: true, completion: nil)
//        self.outerProfileView.isHidden = true
        updateProfile(isUpdatingDisplayName: false, isUpdatingProfilePicture: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateProfile(isUpdatingDisplayName: Bool, isUpdatingProfilePicture: Bool) {
        let userDefaults = UserDefaults.standard
        let name = displayNameToBeUploaded ?? Storage.shared.getUser()?.name
        var profilePicture: UIImage?
//        if self.isProfileRemove {
//           profilePicture = openGroupProfilePicture
//        } else {
           profilePicture = profilePictureToBeUploaded ?? OWSProfileManager.shared().profileAvatar(forRecipientId: getUserHexEncodedPublicKey())
//        }
        
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
//                    self?.isProfileRemove = false
                }
                let publicKey = getUserHexEncodedPublicKey()
                self?.innerProfileImage.image = self!.useFallbackPicture ? nil : (self?.openGroupProfilePicture ?? self?.getProfilePicture(of: self!.size, for: publicKey))
//                self?.outerProfileView.isHidden = true
                MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                DispatchQueue.main.async {
                    modalActivityIndicator.dismiss {
                        guard let self = self else { return }
                        self.nameTextField.text = name
                        self.profilePictureToBeUploaded = nil
                        self.displayNameToBeUploaded = nil
                    }
                }
            }, failure: { error in
                DispatchQueue.main.async {
                    modalActivityIndicator.dismiss {
//                        self?.outerProfileView.isHidden = true
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
    }
    
    @objc func removePictureButtonAction(){
        
    }
    
    @objc func saveButtonAction(){
        
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
        self.showToastMsg(message: NSLocalizedString("BELDEX_ADDRESS_COPIED_NEW", comment: ""), seconds: 1.0)
    }
    
    @objc func copyForBChatIdButtonTapped() {
        UIPasteboard.general.string = getUserHexEncodedPublicKey()
        bchatIdLabel.isUserInteractionEnabled = false
        self.showToastMsg(message: NSLocalizedString("BCHAT_ID_COPIED_NEW", comment: ""), seconds: 1.0)
    }
    
}
