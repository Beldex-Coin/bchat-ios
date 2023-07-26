// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit
import AVFoundation

class MyWalletScannerVC: BaseVC,OWSQRScannerDelegate,AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var infoLabel: UILabel!
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
    var isFromWallet = false
    var wallet: BDXWallet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Scanner"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if self.isFromWallet {
            self.infoLabel.isHidden = true
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
    
    // MARK: - Navigation
}
extension MyWalletScannerVC: QRScannerViewDelegate {
    func qrScanningDidStop() {
        
    }
    func qrScanningDidFail() {
        presentAlert(withTitle: "Error", message: "Scanning Failed. Please try again")
    }
    func qrScanningSucceededWithCode(_ str: String?) {
        var qrString = str!
        if qrString.contains("Beldex:") {
            qrString = qrString.replacingOccurrences(of: "Beldex:", with: "")
        }
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletSendVC") as! MyWalletSendVC
        vc.wallet = self.wallet
        
        if qrString.contains("?") {
            let walletAddress = qrString.components(separatedBy: "?")
            vc.walletAddress = walletAddress[0]
        } else {
            vc.walletAddress = qrString
        }
        
        if qrString.contains("=") {
            let walletAmount = qrString.components(separatedBy: "=")
            vc.walletAmount = walletAmount[1]
        } else {
            vc.walletAmount = ""
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
