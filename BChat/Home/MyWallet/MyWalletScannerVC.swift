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
        // self.qrData = QRData(codeString: str)
//        print("------------> \(str!)")
        
//        start with bx mandatry
//        char count 97 mandatry and 97 above not valid and 97 below not valid
        
        // First Way
//1        bxc7SkcJNj3GfahLNkxZqN4KdtBY9m2KWXr9BKYCmWeU1mpxDq1S2rxisYVL71sMmwZkGCz732F3QRLwfw3whBVR2ztUPczSa
//2        bxc7SkcJNj3GfahLNkxZqN4KdtBY9m2KWXr9BKYCmWeU1mpxDq1S2rxisYVL71sMmwZkGCz732F3QRLwfw3whBVR2ztUPczSa?amount=3.0
//3        bxc7SkcJNj3GfahLNkxZqN4KdtBY9m2KWXr9BKYCmWeU1mpxDq1S2rxisYVL71sMmwZkGCz732F3QRLwfw3whBVR2ztUPczSa?tx_amount=2.0
//4        Beldex:bxdCw3BWQHqXGXDDPp7o9kcEgtFE1M8F461WirHRyTSH1Px3rev3dAMC6pbyuxckiqVqTTuKNmJUw4wkZENkuPEK24uAZb11j?tx_amount=0.1
        
        // Second Way
//1        4L4sXh3mYWhiS5knMjBW4t4CDqa2yejy1RgkQUxgp8Eb6LDhS7GuHiRSY18DPrHH7wFaQ5N8tV3GEB8VXGgNTQin224EuGhimi37cwmbrz
        
        // Third Way
//1        84rHiWR4tYvZEERVLSzVms2AyoH4JyCQPD7FRKZ3Y7q79FGtT5CEGUigumawGbsCyK3H249gxzUJ5D4QWkYMqYy6K24abeW
        
        
        let fullName    = str!
        if fullName.count == 97 {
            var WalletAdrs    = str!
            if String(str!.prefix(2)) == "bx" {
                WalletAdrs = String(str!.prefix(97))
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletSendVC") as! MyWalletSendVC
                vc.wallet = self.wallet
                vc.WalletAddress = WalletAdrs
                vc.WalletAmt = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                self.showToastMsg(message: "Not a valid Payment QR Code", seconds: 1.0)
            }
        }
        if fullName.count < 97 {
            self.showToastMsg(message: "Not a valid Payment QR Code", seconds: 1.0)
        }
        else if String(str!.prefix(7)) == "Beldex:" {
            let fullNameArr = fullName.components(separatedBy: ":")
            let fulladdress    = fullNameArr[1]
            if fulladdress.count == 97 {
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletSendVC") as! MyWalletSendVC
                vc.wallet = self.wallet
                vc.WalletAddress = fulladdress
                vc.WalletAmt = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                let subaddress = fulladdress.components(separatedBy: "=")
                let WalletAdrs    = subaddress[0]
                let WalletAmt    = subaddress[1]
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletSendVC") as! MyWalletSendVC
                vc.wallet = self.wallet
                vc.WalletAddress = WalletAdrs
                vc.WalletAmt = WalletAmt
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
//            print("full 97 above count ------> \(fullName.count)")
            let fullNameArr = fullName.components(separatedBy: "=")
            var WalletAdrs    = fullNameArr[0]
            let WalletAmt    = fullNameArr[1]
            if String(str!.prefix(2)) == "bx" {
                WalletAdrs = String(str!.prefix(97))
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletSendVC") as! MyWalletSendVC
                vc.wallet = self.wallet
                vc.WalletAddress = WalletAdrs
                vc.WalletAmt = WalletAmt
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                self.showToastMsg(message: "Not a valid Payment QR Code", seconds: 1.0)
            }
        }
    }
    
}
