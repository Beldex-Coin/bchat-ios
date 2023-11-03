// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import UIKit

class RecoverySeedForWalletVC: UIViewController {
    
    
    @IBOutlet weak var copyref:UIButton!
    @IBOutlet weak var backgroundView:UIView!
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var copyimg:UIImageView!
    @IBOutlet weak var backgroundCopyView:UIView!
    @IBOutlet weak var lblcopy:UILabel!
    @IBOutlet weak var continueButton:UIButton!
    @IBOutlet weak var titleLabel:UILabel!
    
    private let mnemonic: String = {
        let identityManager = OWSIdentityManager.shared()
        let databaseConnection = identityManager.value(forKey: "dbConnection") as! YapDatabaseConnection
        var hexEncodedSeed: String! = databaseConnection.object(forKey: "BeldexSeed", inCollection: OWSPrimaryStorageIdentityKeyStoreCollection) as! String?
        if hexEncodedSeed == nil {
            hexEncodedSeed = identityManager.identityKeyPair()!.hexEncodedPrivateKey // Legacy account
        }
        return Mnemonic.encode(hexEncodedString: hexEncodedSeed)
    }()
    
    @objc private func enableCopyButton() {
        copyref.isUserInteractionEnabled = true
        UIView.transition(with: copyref, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.copyref.setTitle(NSLocalizedString("copy", comment: ""), for: UIControl.State.normal)
        }, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Seed"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        backgroundView.layer.cornerRadius = 10
        self.lblname.text = mnemonic
        lblname.textColor = Colors.bchatButtonColor
        lblname.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        lblname.numberOfLines = 0
        lblname.lineBreakMode = .byWordWrapping
        lblname.textAlignment = .center
        
        copyref.layer.cornerRadius = 6
        backgroundCopyView.layer.cornerRadius = 6
        
        continueButton.layer.cornerRadius = 6
        continueButton.backgroundColor = UIColor.lightGray
        continueButton.isUserInteractionEnabled = false
        
        lblcopy.isHidden = true
        copyref.setTitle("Copy", for: .normal)
        
        let logoName2 = isLightMode ? "copy-dark" : "copy_white"
        copyimg.image = UIImage(named: logoName2)!
        
        UserDefaults.standard[.hasViewedSeed] = true
        NotificationCenter.default.post(name: .seedViewed, object: nil)
        let text = "Note: Copy your Recovery Seed and save it. You will need the Recovery Seed to restore your account and generate a wallet password.\nIf you lose your seed, you will permanently lose access to your account."
        let redTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.red.cgColor]
        let whiteTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: Colors.bchatLabelNameColor.cgColor]
        let attributedText = NSMutableAttributedString(string: text, attributes: whiteTextAttributes)
        let range = (text as NSString).range(of: "Note:")
        attributedText.addAttributes(redTextAttributes, range: range)
        titleLabel.attributedText = attributedText
    }
    
    
    @IBAction func copyAction(sender:UIButton){
        UIPasteboard.general.string = mnemonic
        copyref.isUserInteractionEnabled = false
        continueButton.backgroundColor = Colors.bchatButtonColor
        continueButton.isUserInteractionEnabled = true
        UIView.transition(with: copyref, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.copyref.setTitle(NSLocalizedString("copied", comment: ""), for: UIControl.State.normal)
        }, completion: nil)
        Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(enableCopyButton), userInfo: nil, repeats: false)
    }

    @IBAction func continueAction(sender:UIButton){
        let alert = UIAlertController(title: "", message: "Do you wish to continue to sign-in and restore your account?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        })
        alert.addAction(cancel)
        let settings = UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            WalletSharedData.sharedInstance.isCleardataStarting = true
            ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { [weak self] _ in
                guard let strongSelf = self else { return }
                MessageSender.syncConfiguration(forceSyncNow: true).ensure(on: DispatchQueue.main) {
                    strongSelf.dismiss(animated: true, completion: nil) // Dismiss the loader
                    strongSelf.deleteAllWalletFiles()
                    AppEnvironment.shared.notificationPresenter.clearAllNotifications()
                    UserDefaults.removeAll() // Not done in the nuke data implementation as unlinking requires this to happen later
                    General.Cache.cachedEncodedPublicKey.mutate { $0 = nil } // Remove the cached key so it gets re-cached on next access
                    NotificationCenter.default.post(name: .dataNukeRequested, object: nil)
                }.retainUntilComplete()
            }
            
        })
        alert.addAction(settings)
        cancel.setValue(isLightMode ? UIColor.black : UIColor.white, forKey: "titleTextColor")
        settings.setValue(Colors.bchatButtonColor, forKey: "titleTextColor")
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func deleteAllWalletFiles() {
        let username = SaveUserDefaultsData.NameForWallet
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = allPaths[0]
        let documentPath = documentDirectory + "/"
        let pathWithFileName = documentPath + username
        let pathWithFileKeys = documentPath + "\(username).keys"
        let pathWithFileAddress = documentPath + "\(username).address.txt"
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponentForFileName = url.appendingPathComponent("\(username)") {
            let filePath = pathComponentForFileName.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                try? FileManager.default.removeItem(atPath: "\(pathWithFileName)")
            }
        }
        if let pathComponentForFileKeys = url.appendingPathComponent("\(username).keys") {
            let filePath = pathComponentForFileKeys.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                try? FileManager.default.removeItem(atPath: "\(pathWithFileKeys)")
            }
        }
        if let pathComponentForFileAddress = url.appendingPathComponent("\(username).address.txt") {
            let filePath = pathComponentForFileAddress.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                try? FileManager.default.removeItem(atPath: "\(pathWithFileAddress)")
            }
        }
    }

}
