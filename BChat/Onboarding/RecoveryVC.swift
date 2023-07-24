// Copyright © 2022 Beldex. All rights reserved.

import UIKit
import Sodium
import PromiseKit

class RecoveryVC: BaseVC,UITextFieldDelegate,OptionViewDelegate {
    @IBOutlet weak var backgroundView:UIView!
    @IBOutlet weak var nextRef:UIButton!
    @IBOutlet weak var copyRef:UIButton!
    @IBOutlet weak var notelbl:UILabel!
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var lblrecovery:UILabel!
    
    private var optionViews: [OptionView] {
        [ apnsOptionView, backgroundPollingOptionView ]
    }
    
    private var selectedOptionView: OptionView? {
        return optionViews.first { $0.isSelected }
    }
    
    func optionViewDidActivate(_ optionView: OptionView) {
        optionViews.filter { $0 != optionView }.forEach { $0.isSelected = false }
    }
    
    // MARK: Components
    private lazy var apnsOptionView: OptionView = {
        let explanation = NSLocalizedString("fast_mode_explanation", comment: "")
        let result = OptionView(title: "Fast Mode", explanation: explanation, delegate: self, isRecommended: true)
        result.accessibilityLabel = "Fast mode option"
        return result
    }()
    
    private lazy var backgroundPollingOptionView: OptionView = {
        let explanation = NSLocalizedString("slow_mode_explanation", comment: "")
        let result = OptionView(title: "Slow Mode", explanation: explanation, delegate: self)
        result.accessibilityLabel = "Slow mode option"
        return result
    }()
    
    private let mnemonic: String = {
        let identityManager = OWSIdentityManager.shared()
        let databaseConnection = identityManager.value(forKey: "dbConnection") as! YapDatabaseConnection
        var hexEncodedSeed: String! = databaseConnection.object(forKey: "BeldexSeed", inCollection: OWSPrimaryStorageIdentityKeyStoreCollection) as! String?
        if hexEncodedSeed == nil {
            hexEncodedSeed = identityManager.identityKeyPair()!.hexEncodedPrivateKey // Legacy account
        }
        return Mnemonic.encode(hexEncodedString: hexEncodedSeed)
    }()
    
    var seedcopy = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Recovery Phrase"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        setUpGradientBackground()
        setUpNavBarStyle()
        
        let origImage = UIImage(named: "copy")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        copyRef.setImage(tintedImage, for: .normal)
        copyRef.tintColor = Colors.accent2
        backgroundView.layer.cornerRadius = 10
        nextRef.layer.cornerRadius = 6
        lblrecovery.isHidden = false
        self.lblname.text = "\(mnemonic)"
        lblname.textColor = Colors.bchat_button_clr2
        lblname.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        lblname.numberOfLines = 0
        lblname.lineBreakMode = .byWordWrapping
        lblname.textAlignment = .center
        
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(string: "Note: ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]));
        text.append(NSAttributedString(string: "Save your recovery seed! Only your recovery seed can be used to recover your account on another device. Copy the recovery seed to continue.", attributes: [NSAttributedString.Key.foregroundColor: Colors.bchat_lbl_name.cgColor]))
        notelbl.attributedText = text
        optionViews[1].isSelected = true
        nextRef.isUserInteractionEnabled = false
        nextRef.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func CopyAction(sender:UIButton){
        nextRef.isUserInteractionEnabled = true
        nextRef.backgroundColor = Colors.bchat_button_clr
        self.showToastMsg(message: "Please copy the seed and save it", seconds: 1.0)
        UIPasteboard.general.string = mnemonic
        copyRef.isUserInteractionEnabled = false
        seedcopy = true
        lblrecovery.isHidden = true
    }
    
    @IBAction func NextAction(sender:UIButton){
        if seedcopy == true {
            guard selectedOptionView != nil else {
                let title = NSLocalizedString("vc_pn_mode_no_option_picked_modal_title", comment: "")
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
                return present(alert, animated: true, completion: nil)
            }
            UserDefaults.standard[.isUsingFullAPNs] = true//(selectedOptionView == apnsOptionView)
            TSAccountManager.sharedInstance().didRegister()
            let homeVC = HomeVC()
            navigationController!.setViewControllers([ homeVC ], animated: true)
            let syncTokensJob = SyncPushTokensJob(accountManager: AppEnvironment.shared.accountManager, preferences: Environment.shared.preferences)
            syncTokensJob.uploadOnlyIfStale = false
            let _: Promise<Void> = syncTokensJob.run()
        }else {
            self.showToastMsg(message: "Please copy the Seed...", seconds: 1.0)
        }
    }
    
}


