// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import AVFoundation
import BChatUIKit

class ScanNewVC: BaseVC,OWSQRScannerDelegate,AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private lazy var scannerView: QRScannerView = {
        let stackView = QRScannerView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x000000)
        stackView.layer.cornerRadius = 16
        stackView.delegate = self
        return stackView
    }()
    private lazy var isFromUploadGalleryOptionButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("UPLOAD_FROM_GALLERY", comment: ""), for: .normal)
        let logoImage = isLightMode ? "ic_scanimge_dark" : "ic_scanlogo_New"
        let image = UIImage(named: logoImage)?.scaled(to: CGSize(width: 15, height: 15))
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 9)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(Colors.aboutContentLabelColor, for: .normal)
        button.layer.borderColor = Colors.greenColor.cgColor
        button.layer.borderWidth = 1
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(isFromUploadGalleryOptionButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var scanDescLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor2
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    var imagePicker = UIImagePickerController()
    var qrData: QRData? = nil {
        didSet {
            if qrData != nil {
                // self.performSegue(withIdentifier: "detailSeuge", sender: self)
            }
        }
    }
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    private var isJoining = false
    var newChatScanflag = false
    //Wallet Scanner
    var isFromWallet = false
    var wallet: BDXWallet?
    var mainBalanceForScan = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorSocialGroup
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Scan"
        
        view.addSubViews(scannerView)
        view.addSubview(isFromUploadGalleryOptionButton)
        view.addSubview(scanDescLabel)
        
        NSLayoutConstraint.activate([
            scannerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 55),
            scannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            scannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            scannerView.heightAnchor.constraint(equalToConstant: 351),
            scannerView.widthAnchor.constraint(equalToConstant: 351),
            isFromUploadGalleryOptionButton.topAnchor.constraint(equalTo: scannerView.bottomAnchor, constant: 115),
            isFromUploadGalleryOptionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 84),
            isFromUploadGalleryOptionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -84),
            isFromUploadGalleryOptionButton.heightAnchor.constraint(equalToConstant: 58),
            scanDescLabel.topAnchor.constraint(equalTo: isFromUploadGalleryOptionButton.bottomAnchor, constant: 37),
            scanDescLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            scanDescLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
        ])
        
        if newChatScanflag == true{
            scanDescLabel.text = NSLocalizedString("SCAN_SUB_TITLE_FOR_NEWCHAT", comment: "")
        }
        if newChatScanflag == false{
            scanDescLabel.text = NSLocalizedString("SCAN_SUB_TITLE_FOR_NEWCHAT", comment: "")
        }
        if isFromWallet == true {
            scanDescLabel.text = NSLocalizedString("SCAN_SUB_TITLE", comment: "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let hasCameraAccess = (AVCaptureDevice.authorizationStatus(for: .video) == .authorized)
        if hasCameraAccess {
            if !scannerView.isRunning {
                scannerView.startScanning()
            }
        } else {
            guard requestCameraPermissionIfNeeded() else { return }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }
    // MARK: DIRECT SCAN for ONE to ONE
    fileprivate func startNewDMIfPossible(with bnsNameOrPublicKey: String) {
        if ECKeyPair.isValidHexEncodedPublicKey(candidate: bnsNameOrPublicKey) {
            startNewDM(with: bnsNameOrPublicKey)
        } else {
            // This could be an BNS name
            ModalActivityIndicatorViewController.present(fromViewController: navigationController!, canCancel: false) { [weak self] modalActivityIndicator in
                SnodeAPI.getBChatID(for: bnsNameOrPublicKey).done { bchatID in
                    modalActivityIndicator.dismiss {
                        self?.startNewDM(with: bchatID)
                    }
                }.catch { error in
                    modalActivityIndicator.dismiss {
                        var messageOrNil: String?
                        if let error = error as? SnodeAPI.Error {
                            switch error {
                            case .decryptionFailed, .hashingFailed, .validationFailed: messageOrNil = error.errorDescription
                            default: break
                            }
                        }
                        let message = messageOrNil ?? Alert.Alert_BChat_Invalid_ID
                        _ = CustomAlertController.alert(title: Alert.Alert_BChat_Error, message: String(format: message ) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
                        })
                    }
                }
            }
        }
    }
    
    private func startNewDM(with bchatID: String) {
        let thread = TSContactThread.getOrCreateThread(contactBChatID: bchatID)
        presentingViewController?.dismiss(animated: true, completion: nil)
        SignalApp.shared().presentConversation(for: thread, action: .compose, animated: false)
    }
    
    // MARK: SOCIAL GROUP SCAN
    fileprivate func joinOpenGroup(with string: String) {
        // A V2 open group URL will look like: <optional scheme> + <host> + <optional port> + <room> + <public key>
        // The host doesn't parse if no explicit scheme is provided
        if let (room, server, publicKey) = OpenGroupManagerV2.parseV2OpenGroup(from: string) {
            joinV2OpenGroup(room: room, server: server, publicKey: publicKey)
        } else {
            let title = NSLocalizedString("invalid_url", comment: "")
            let message = NSLocalizedString("VALID_URL_CHECKING", comment: "")
            showError(title: title, message: message)
        }
    }
    
    fileprivate func joinV2OpenGroup(room: String, server: String, publicKey: String) {
        guard !isJoining else { return }
        isJoining = true
        Storage.shared.write { transaction in
            OpenGroupManagerV2.shared.add(room: room, server: server, publicKey: publicKey, using: transaction)
                .done(on: DispatchQueue.main) { [weak self] _ in
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                    MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                    let registerVC = HomeVC()
                    self?.navigationController!.pushViewController(registerVC, animated: true)
                }
                .catch(on: DispatchQueue.main) { [weak self] error in
                    self?.dismiss(animated: true, completion: nil) // Dismiss the loader
                    let title = NSLocalizedString("COULDN_NOT_JOIN", comment: "")
                    let message = error.localizedDescription
                    self?.isJoining = false
                    self?.showError(title: title, message: message)
                }
        }
    }
    // MARK: Convenience
    private func showError(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
        presentAlert(alert)
    }
    
    @objc func isFromUploadGalleryOptionButtonTapped(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            self.openCamera(UIImagePickerController.SourceType.photoLibrary)
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        }
    }
    
    func openCamera(_ sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let qrcodeImg = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage),
            let detector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh]),
            let ciImage: CIImage = CIImage(image:qrcodeImg),
            let features = detector.features(in: ciImage) as? [CIQRCodeFeature]
        else {
            print("Something went wrong")
            return
        }
        var qrCodeLink = ""
        features.forEach { feature in
            if let messageString = feature.messageString {
                qrCodeLink += messageString
            }
        }
        if qrCodeLink.isEmpty {
            self.showToastMsg(message: NSLocalizedString("INVALID_QR_CODE", comment: ""), seconds: 1.0)
        } else {
            if ECKeyPair.isValidHexEncodedPublicKey(candidate: qrCodeLink) {
                startNewDM(with: qrCodeLink)
            } else {
                self.showToastMsg(message: NSLocalizedString("invalid_bchat_id", comment: ""), seconds: 1.0)
            }
        }
        self.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
extension ScanNewVC: QRScannerViewDelegate {
    func qrScanningDidStop() {}
    func qrScanningDidFail() {
        presentAlert(withTitle: NSLocalizedString("ERROR_MSG", comment: ""), message: NSLocalizedString("ERROR_SCANNING_PLS_TRY_AGAIN", comment: ""))
    }
    func qrScanningSucceededWithCode(_ str: String?) {
        if newChatScanflag == true { // Join Social Group QR Code Scanning
            self.qrData = QRData(codeString: str)
            joinOpenGroup(with: str!)
        }
//        if newChatScanflag == false {
//            self.qrData = QRData(codeString: str)
//            startNewDMIfPossible(with: str!)
//        }
        if isFromWallet == true { //Wallet QR Code Scanning
            var qrString = str!
            if qrString.contains("Beldex:") {
                qrString = qrString.replacingOccurrences(of: "Beldex:", with: "")
            }
            let vc = WalletSendNewVC()
            vc.wallet = self.wallet
            if qrString.contains("?") {
                let walletAddress = qrString.components(separatedBy: "?")
                guard BChatWalletWrapper.validAddress(walletAddress[0]) else {
                    let alertController = UIAlertController(title: "", message: "Not a valid Payment QR Code", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//                        self.scannerView.startScanning()
                        self.navigationController?.popViewController(animated: true)
                    }))
                    present(alertController, animated: true, completion: nil)
                    return
                }
                vc.walletAddress = walletAddress[0]
            } else {
                guard BChatWalletWrapper.validAddress(qrString) else {
                    let alertController = UIAlertController(title: "", message: "Not a valid Payment QR Code", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//                        self.scannerView.startScanning()
                        self.navigationController?.popViewController(animated: true)
                    }))
                    present(alertController, animated: true, completion: nil)
                    return
                }
                vc.walletAddress = qrString
            }
            if qrString.contains("=") {
                let walletAmount = qrString.components(separatedBy: "=")
                vc.walletAmount = walletAmount[1]
            } else {
                vc.walletAmount = ""
            }
            vc.mainBalance = mainBalanceForScan
            navigationController!.pushViewController(vc, animated: true)
        } else { // new Chat QR Code Scanning
            self.qrData = QRData(codeString: str)
            startNewDMIfPossible(with: str!)
        }
    }
}
