// Copyright © 2022 Beldex. All rights reserved.

import UIKit
import BChatUIKit

class MyAccountVC: BaseVC,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(MyAccountXibCell.nib, forCellWithReuseIdentifier: MyAccountXibCell.identifier)
        }
    }
    var array = ["Hops","Clear Data","Delete Account","Change Password","Blocked Contacts","FAQ","FeedBack","Changelog"]
    @IBOutlet weak var first_view:UIView!
    @IBOutlet weak var second_view:UIView!
    @IBOutlet weak var myBtn:UIButton!
    @IBOutlet weak var myBtn2:UIButton!
    @IBOutlet weak var pathbtn:UIButton!
    @IBOutlet weak var shareview:UIView!
    @IBOutlet weak var shareref:UIButton!
    @IBOutlet weak var qrCodeImageView:UIImageView!
    @IBOutlet weak var editImageView:UIImageView!
    @IBOutlet weak var sharelogoimg:UIImageView!
    @IBOutlet weak var editProfilepiclogoimg:UIImageView!
    @IBOutlet weak var displayNameTextFieldWidth:NSLayoutConstraint!
    @IBOutlet weak var publicKeyLabel:UILabel!
    @IBOutlet weak var beldexaddressLabel:UILabel!
    @IBOutlet weak var displayNameTextField:UITextField!
    private var profilePictureToBeUploaded: UIImage?
    private var displayNameToBeUploaded: String?
    private var isEditingDisplayName = false { didSet { handleIsEditingDisplayNameChanged() } }
    @IBOutlet weak var profilePictureView:UIImageView!
    @objc public var useFallbackPicture = false
    @objc public var openGroupProfilePicture: UIImage?
    @objc public var size: CGFloat = 30
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "My Account"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        first_view.layer.borderWidth = 1
        second_view.layer.borderWidth = 1
        first_view.layer.borderColor = UIColor.lightGray.cgColor
        second_view.layer.borderColor = UIColor.lightGray.cgColor
        first_view.layer.cornerRadius = 10
        second_view.layer.cornerRadius = 10
        
        self.first_view.isHidden = true
        self.second_view.isHidden = false
        let origImage = UIImage(named: isLightMode ? "ic_QR_dark" : "ic_QR_white")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        myBtn.setImage(tintedImage, for: .normal)
        myBtn.tintColor = isLightMode ? UIColor.black : UIColor.white
        //Share logo Image
        sharelogoimg.image = UIImage(named: isLightMode ? "share" : "share")!
        //editProfilepiclogoimg
        editProfilepiclogoimg.image = UIImage(named: isLightMode ? "ic_camera_dark" : "ic_camera_white")!
        //Share
        shareview.layer.cornerRadius = 5
        shareref.layer.cornerRadius = 6
        
        let qrCode = QRCode.generate(for: getUserHexEncodedPublicKey(), hasBackground: true)
        qrCodeImageView.image = qrCode
        qrCodeImageView.contentMode = .scaleAspectFit
        let smallLogo = UIImage(named: "bchat_QR")
        smallLogo?.addToCenter(of: qrCodeImageView)
        
        // Display name label
        let nam = Storage.shared.getUser()?.name
        displayNameTextField.text = nam?.firstCharacterUpperCase()
        
        displayNameTextField.textColor = Colors.text
        displayNameTextField.font = Fonts.boldOpenSans(ofSize: Values.largeFontSize)
        displayNameTextField.delegate = self
        
        //Bacht ID
        //  publicKeyLabel.textColor = Colors.text
        publicKeyLabel.font = Fonts.OpenSans(ofSize: isIPhone5OrSmaller ? Values.mediumFontSize : Values.mediumFontSize)
        publicKeyLabel.textAlignment = .left
        publicKeyLabel.adjustsFontSizeToFitWidth = false
        publicKeyLabel.lineBreakMode = .byTruncatingTail
        publicKeyLabel.backgroundColor = Colors.myAccountColor
        publicKeyLabel?.layer.masksToBounds = true
        publicKeyLabel.layer.cornerRadius = 6
        publicKeyLabel.text = " \(getUserHexEncodedPublicKey())"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MyAccountVC.tapFunction))
        publicKeyLabel.isUserInteractionEnabled = true
        publicKeyLabel.addGestureRecognizer(tap)
        
        //Beldex address ID
        //  beldexaddressLabel.textColor = Colors.text
        beldexaddressLabel.font = Fonts.OpenSans(ofSize: isIPhone5OrSmaller ? Values.mediumFontSize : Values.mediumFontSize)
        beldexaddressLabel.textAlignment = .left
        beldexaddressLabel.adjustsFontSizeToFitWidth = false
        beldexaddressLabel.lineBreakMode = .byTruncatingTail
        beldexaddressLabel.backgroundColor = Colors.myAccountColor
        beldexaddressLabel?.layer.masksToBounds = true
        beldexaddressLabel.layer.cornerRadius = 6
        beldexaddressLabel.text = " \(SaveUserDefaultsData.WalletpublicAddress)"
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(MyAccountVC.tapFunction2))
        beldexaddressLabel.isUserInteractionEnabled = true
        beldexaddressLabel.addGestureRecognizer(tap1)
        
        //Get Profile Pic
        let publicKey = getUserHexEncodedPublicKey()
        profilePictureView.image = useFallbackPicture ? nil : (openGroupProfilePicture ?? getProfilePicture(of: size, for: publicKey))
        profilePictureView.layer.cornerRadius = profilePictureView.frame.height/2
        // profilePictureView.layer.cornerRadius = 10
        
        let profilePictureTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyAccountVC.tappedMe))
        profilePictureView.addGestureRecognizer(profilePictureTapGestureRecognizer)
        profilePictureView.isUserInteractionEnabled = true
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //depending upon direction of collection view
        self.collectionView?.setCollectionViewLayout(layout, animated: true)
        
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        UIPasteboard.general.string = getUserHexEncodedPublicKey()
        publicKeyLabel.isUserInteractionEnabled = false
        self.showToastMsg(message: "Your BChat ID copied to clipboard", seconds: 1.0)
    }
    
    @objc func tapFunction2(sender:UITapGestureRecognizer) {
        UIPasteboard.general.string = SaveUserDefaultsData.WalletpublicAddress
        beldexaddressLabel.isUserInteractionEnabled = false
        self.showToastMsg(message: "Your Beldex Address is copied to clipboard", seconds: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    }
    @IBAction func shareAction(sender:UIButton){
        let qrCode = QRCode.generate(for: getUserHexEncodedPublicKey(), hasBackground: true)
        let shareVC = UIActivityViewController(activityItems: [ qrCode ], applicationActivities: nil)
        self.navigationController!.present(shareVC, animated: true, completion: nil)
    }
    
    @IBAction func action(sender:UIButton){
        UIView.transition(with: first_view, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            // self.first_view.isHidden = true
            self.myBtn.alpha = 1
        })
        UIView.transition(with: second_view, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            //  self.second_view.isHidden = false
            if self.second_view.isHidden == false {
                let origImage = UIImage(named: isLightMode ? "ic_QR_dark" : "ic_QR_white")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                self.myBtn.setImage(tintedImage, for: .normal)
                self.myBtn.tintColor = isLightMode ? UIColor.black : UIColor.white
                self.first_view.isHidden = false
                self.second_view.isHidden = true
            }
            else {
                let origImage = UIImage(named: isLightMode ? "user_dark" : "user_light")
                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                self.myBtn2.setImage(tintedImage, for: .normal)
                self.myBtn2.tintColor = isLightMode ? UIColor.black : UIColor.white
                self.first_view.isHidden = true
                self.second_view.isHidden = false
            }
        })
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isEditingDisplayName = true
    }
    
    // MARK: Updating
    private func handleIsEditingDisplayNameChanged() {
        updateNavigationBarButtons()
        UIView.animate(withDuration: 0.25) { [self] in
            displayNameTextField.text = displayNameToBeUploaded
        }
        if isEditingDisplayName {
            displayNameTextField.becomeFirstResponder()
            displayNameTextField.attributedPlaceholder = NSAttributedString(
                string: " Enter a Display Name",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
            displayNameTextField.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
            displayNameTextField.layer.masksToBounds = true
            displayNameTextField.layer.cornerRadius = 4
            displayNameTextField.layer.borderWidth = 0.1
        } else {
            displayNameTextField.resignFirstResponder()
        }
    }
    
    private func updateNavigationBarButtons() {
        if isEditingDisplayName {
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelDisplayNameEditingButtonTapped))
            cancelButton.tintColor = Colors.text
            cancelButton.accessibilityLabel = "Cancel button"
            cancelButton.isAccessibilityElement = true
            navigationItem.leftBarButtonItem = cancelButton
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleSaveDisplayNameButtonTapped))
            doneButton.tintColor = Colors.text
            doneButton.accessibilityLabel = "Done button"
            doneButton.isAccessibilityElement = true
            navigationItem.rightBarButtonItem = doneButton
        }
        else
        {
            let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "NavBarBack"), style: .plain, target: self, action: #selector(close))
            closeButton.tintColor = Colors.text
            closeButton.accessibilityLabel = "Close button"
            closeButton.isAccessibilityElement = true
            navigationItem.leftBarButtonItem = closeButton
            
            if #available(iOS 13, *) { // Pre iOS 13 the user can't switch actively but the app still responds to system changes
                let appModeIcon: UIImage
                if isSystemDefault {
                    appModeIcon = isDarkMode ? #imageLiteral(resourceName: "ic_theme_auto").withTintColor(.white) : #imageLiteral(resourceName: "ic_theme_auto").withTintColor(.black)
                } else {
                    appModeIcon = isDarkMode ? #imageLiteral(resourceName: "ic_dark_theme_on").withTintColor(.white) : #imageLiteral(resourceName: "ic_dark_theme_off").withTintColor(.black)
                }
                let appModeButton = UIButton()
                appModeButton.setImage(appModeIcon, for: UIControl.State.normal)
                appModeButton.tintColor = Colors.text
                // appModeButton.addTarget(self, action: #selector(switchAppMode), for: UIControl.Event.touchUpInside)
                appModeButton.accessibilityLabel = "Switch app mode button"
                let qrCodeIcon = isDarkMode ? #imageLiteral(resourceName: "QRCode").withTintColor(.white) : #imageLiteral(resourceName: "QRCode").withTintColor(.black)
                let qrCodeButton = UIButton()
                
                qrCodeButton.setImage(qrCodeIcon, for: UIControl.State.normal)
                qrCodeButton.tintColor = Colors.text
                //   qrCodeButton.addTarget(self, action: #selector(showQRCode), for: UIControl.Event.touchUpInside)
                qrCodeButton.accessibilityLabel = "Show QR code button"
                
                //   let stackView = UIStackView(arrangedSubviews: [ appModeButton, qrCodeButton ])
                
                let stackView = UIStackView(arrangedSubviews: [ qrCodeButton ])
                stackView.isHidden = true
                stackView.axis = .horizontal
                stackView.spacing = Values.mediumSpacing
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
            } else {
                let qrCodeIcon = isDarkMode ? #imageLiteral(resourceName: "QRCode").asTintedImage(color: .white) : #imageLiteral(resourceName: "QRCode").asTintedImage(color: .black)
            }
        }
    }
    
    @objc private func handleCancelDisplayNameEditingButtonTapped() {
        isEditingDisplayName = false
        // Display name label
        let nam = Storage.shared.getUser()?.name
        displayNameTextField.text = nam?.firstCharacterUpperCase()
        displayNameTextField.layer.cornerRadius = 0
        displayNameTextField.layer.borderWidth = 0
    }
    @objc private func handleSaveDisplayNameButtonTapped() {
        func showError(title: String, message: String = "") {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
            presentAlert(alert)
        }
        let displayName = displayNameTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !displayName.isEmpty else {
            return showError(title: NSLocalizedString("vc_settings_display_name_missing_error", comment: ""))
        }
        guard !OWSProfileManager.shared().isProfileNameTooLong(displayName) else {
            return showError(title: NSLocalizedString("vc_settings_display_name_too_long_error", comment: ""))
        }
        isEditingDisplayName = false
        displayNameToBeUploaded = displayName
        displayNameTextField.layer.cornerRadius = 0
        displayNameTextField.layer.borderWidth = 0
        updateProfile(isUpdatingDisplayName: true, isUpdatingProfilePicture: false)
    }
    
    private func updateProfile(isUpdatingDisplayName: Bool, isUpdatingProfilePicture: Bool) {
        let userDefaults = UserDefaults.standard
        let name = displayNameToBeUploaded ?? Storage.shared.getUser()?.name
        let profilePicture = profilePictureToBeUploaded ?? OWSProfileManager.shared().profileAvatar(forRecipientId: getUserHexEncodedPublicKey())
        ModalActivityIndicatorViewController.present(fromViewController: navigationController!, canCancel: false) { [weak self, displayNameToBeUploaded, profilePictureToBeUploaded] modalActivityIndicator in
            OWSProfileManager.shared().updateLocalProfileName(name, avatarImage: profilePicture, success: {
                if displayNameToBeUploaded != nil {
                    userDefaults[.lastDisplayNameUpdate] = Date()
                }
                if profilePictureToBeUploaded != nil {
                    userDefaults[.lastProfilePictureUpdate] = Date()
                }
                MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                DispatchQueue.main.async {
                    modalActivityIndicator.dismiss {
                        guard let self = self else { return }
                        self.displayNameTextField.text = name
                        self.profilePictureToBeUploaded = nil
                        self.displayNameToBeUploaded = nil
                    }
                }
            }, failure: { error in
                DispatchQueue.main.async {
                    modalActivityIndicator.dismiss {
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
    
    
    // MARK: Interaction
    @objc private func close() {
        // dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
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
    
    @objc func tappedMe(){
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
        profilePictureView.image = profilePictureToBeUploaded
        profilePictureView.contentMode = .scaleAspectFit
        imagePicker.dismiss(animated: true, completion: nil)
        updateProfile(isUpdatingDisplayName: false, isUpdatingProfilePicture: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func clearAvatar() {
        profilePictureToBeUploaded = nil
        updateProfile(isUpdatingDisplayName: false, isUpdatingProfilePicture: true)
    }
    
}
extension String {
    func firstCharacterUpperCase() -> String? {
        guard !isEmpty else { return nil }
        let lowerCasedString = self.lowercased()
        return lowerCasedString.replacingCharacters(in: lowerCasedString.startIndex...lowerCasedString.startIndex, with: String(lowerCasedString[lowerCasedString.startIndex]).uppercased())
    }
}

extension MyAccountVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyAccountXibCell.identifier, for: indexPath) as! MyAccountXibCell
        cell.lblname.text = array[indexPath.item]
        if indexPath.row == 0 {
            let pathStatusView = PathStatusView()
            pathStatusView.set(.width, to: PathStatusView.size)
            pathStatusView.set(.height, to: PathStatusView.size)
            cell.lblname.addSubview(pathStatusView)
            pathStatusView.pin(.leading, to: .trailing, of: cell.lblname, withInset: Values.smallSpacing)
            pathStatusView.autoVCenterInSuperview()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let pathVC = PathVC()
            navigationController!.pushViewController(pathVC, animated: true)
        }else if indexPath.row == 1 {
            let nukeDataModal = NukeDataModal()
            nukeDataModal.modalPresentationStyle = .overFullScreen
            nukeDataModal.modalTransitionStyle = .crossDissolve
            present(nukeDataModal, animated: true, completion: nil)
        }else if indexPath.row == 2 {
            let nukeDataModal = DeleteAccountModel()
            nukeDataModal.modalPresentationStyle = .overFullScreen
            nukeDataModal.modalTransitionStyle = .crossDissolve
            present(nukeDataModal, animated: true, completion: nil)
        }else if indexPath.row == 3 {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangepasswordVC") as! ChangepasswordVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 4 {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BlockedContactVC") as! BlockedContactVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 5 {
            let url = URL(string: bchat_FAQ_Link)!
            UIApplication.shared.open(url)
        }else if indexPath.row == 6 {
            if let url = URL(string: "mailto:\(bchat_email_Feedback)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }else {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangeLogVC") as! ChangeLogVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
