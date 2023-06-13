// Copyright © 2022 Beldex. All rights reserved.

import UIKit

class RecoverySeedMenuVC2: UIViewController {
    
    @IBOutlet weak var copyref:UIButton!
    @IBOutlet weak var backgroundView:UIView!
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var copyimg:UIImageView!
    @IBOutlet weak var backgroundCopyView:UIView!
    @IBOutlet weak var lblcopy:UILabel!
  
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

        // Do any additional setup after loading the view.
        
        self.title = "Seed"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        backgroundView.layer.cornerRadius = 10
        self.lblname.text = mnemonic
        lblname.textColor = Colors.bchat_button_clr
        lblname.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        lblname.numberOfLines = 0
        lblname.lineBreakMode = .byWordWrapping
        lblname.textAlignment = .center
        
        copyref.layer.cornerRadius = 6
        backgroundCopyView.layer.cornerRadius = 6
        
        lblcopy.isHidden = true
        copyref.setTitle("Copy", for: .normal)
        
        let logoName2 = isLightMode ? "copy-dark" : "copy_white"
        copyimg.image = UIImage(named: logoName2)!
        
        UserDefaults.standard[.hasViewedSeed] = true
        NotificationCenter.default.post(name: .seedViewed, object: nil)
        
    }
    // MARK: - Navigation

    @IBAction func copyAction(sender:UIButton){
        UIPasteboard.general.string = mnemonic
        copyref.isUserInteractionEnabled = false
        UIView.transition(with: copyref, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.copyref.setTitle(NSLocalizedString("copied", comment: ""), for: UIControl.State.normal)
        }, completion: nil)
        Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(enableCopyButton), userInfo: nil, repeats: false)
    }
    
    
}
