// Copyright © 2022 Beldex. All rights reserved.

import UIKit
import AVFoundation

class ScannerQRVC: BaseVC, OWSQRScannerDelegate,AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var scannerView: QRScannerView! {
        didSet {
            scannerView.delegate = self
            scannerView.layer.cornerRadius = 14
        }
    }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Scan QR Code"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if newChatScanflag == true {
            print("Social group func calling")
        }else {
            print("Dirct group one to one func calling")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !scannerView.isRunning {
            scannerView.startScanning()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }
    // MARK: DIRECT SCAN for ONE to ONE
    
    fileprivate func startNewDMIfPossible(with onsNameOrPublicKey: String) {
        if ECKeyPair.isValidHexEncodedPublicKey(candidate: onsNameOrPublicKey) {
            startNewDM(with: onsNameOrPublicKey)
        } else {
            // This could be an ONS name
            ModalActivityIndicatorViewController.present(fromViewController: navigationController!, canCancel: false) { [weak self] modalActivityIndicator in
                SnodeAPI.getBChatID(for: onsNameOrPublicKey).done { bchatuserID in
                    modalActivityIndicator.dismiss {
                        self?.startNewDM(with: bchatuserID)
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
    
    private func startNewDM(with bchatuserID: String) {
        let thread = TSContactThread.getOrCreateThread(contactBChatID: bchatuserID)
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
            let message = "Please check the URL you entered and try again."
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
                    MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete() // FIXME: It's probably cleaner to do this inside addOpenGroup(...)
                    
                    let registerVC = HomeVC()
                    self?.navigationController!.pushViewController(registerVC, animated: true)
                    
                }
                .catch(on: DispatchQueue.main) { [weak self] error in
                    self?.dismiss(animated: true, completion: nil) // Dismiss the loader
                    let title = "Couldn't Join"
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
}
extension ScannerQRVC: QRScannerViewDelegate {
    func qrScanningDidStop() {}
    func qrScanningDidFail() {
        presentAlert(withTitle: "Error", message: "Scanning Failed. Please try again")
    }
    func qrScanningSucceededWithCode(_ str: String?) {
        if newChatScanflag == true {
            print("Social group func calling")
            self.qrData = QRData(codeString: str)
            joinOpenGroup(with: str!)
        }else {
            print("Dirct group one to one func calling")
            self.qrData = QRData(codeString: str)
            startNewDMIfPossible(with: str!)
        }
    }
}
