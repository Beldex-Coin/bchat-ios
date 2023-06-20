// Copyright © 2022 Beldex. All rights reserved.

import UIKit
import Sodium
import PromiseKit


class EnterPinVC: BaseVC,UITextFieldDelegate,OptionViewDelegate {
    
    var maxLen:Int = 4
    private var optionViews: [OptionView] {
        [ apnsOptionView, backgroundPollingOptionView ]
    }
    
    private var selectedOptionView: OptionView? {
        return optionViews.first { $0.isSelected }
    }
    
    func optionViewDidActivate(_ optionView: OptionView) {
        optionViews.filter { $0 != optionView }.forEach { $0.isSelected = true }
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
    
    @IBOutlet weak var backgroundEnterPinView:UIView!
    @IBOutlet weak var backgroundReEnterPinView:UIView!
    
    @IBOutlet weak var enterPintxt:UITextField!
    @IBOutlet weak var reEnterPintxt:UITextField!
    
    @IBOutlet weak var nextRef:UIButton!
    
    @IBOutlet weak var btneye1:UIButton!
    @IBOutlet weak var btneye2:UIButton!
    var iconClick = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "Create Password"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        setUpGradientBackground()
        setUpNavBarStyle()
        
        let imgName = isLightMode ? "eye_icon" : "eye_unclosedicon_white"
        let image1 = UIImage(named: "\(imgName).png")!
        self.btneye1.setImage(image1, for: .normal)
        
        let imgName2 = isLightMode ? "eye_icon" : "eye_unclosedicon_white"
        let image12 = UIImage(named: "\(imgName2).png")!
        self.btneye2.setImage(image12, for: .normal)
        
        backgroundEnterPinView.layer.cornerRadius = 10
        backgroundReEnterPinView.layer.cornerRadius = 10
        nextRef.layer.cornerRadius = 6
        
        if isLightMode {
            enterPintxt.attributedPlaceholder = NSAttributedString(string:"Eg.0089", attributes:[NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            reEnterPintxt.attributedPlaceholder = NSAttributedString(string:"Eg.0089", attributes:[NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }else {
            enterPintxt.attributedPlaceholder = NSAttributedString(string:"Eg.0089", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            reEnterPintxt.attributedPlaceholder = NSAttributedString(string:"Eg.0089", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        
        enterPintxt.delegate = self
        reEnterPintxt.delegate = self
        enterPintxt.isSecureTextEntry = true
        reEnterPintxt.isSecureTextEntry = true
        enterPintxt.keyboardType = .numberPad
        reEnterPintxt.keyboardType = .numberPad
        
        let dismiss: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismiss)
        
    }
    
    @IBAction func eyeAction1(sender:UIButton){
        btneye1.isSelected = !btneye1.isSelected
        if btneye1.isSelected {
            enterPintxt.isSecureTextEntry = false
            let imgName = isLightMode ? "eye_Closedicon" : "eye_icon_white"
            let image1 = UIImage(named: "\(imgName).png")!
            self.btneye1.setImage(image1, for: .normal)
        }else {
            enterPintxt.isSecureTextEntry = true
            let imgName = isLightMode ? "eye_icon" : "eye_unclosedicon_white"
            let image1 = UIImage(named: "\(imgName).png")!
            self.btneye1.setImage(image1, for: .normal)
        }
    }
    @IBAction func eyeAction2(sender:UIButton){
        btneye2.isSelected = !btneye2.isSelected
        if btneye2.isSelected {
            reEnterPintxt.isSecureTextEntry = false
            let imgName = isLightMode ? "eye_Closedicon" : "eye_icon_white"
            let image1 = UIImage(named: "\(imgName).png")!
            self.btneye2.setImage(image1, for: .normal)
        }else {
            let imgName = isLightMode ? "eye_icon" : "eye_unclosedicon_white"
            let image1 = UIImage(named: "\(imgName).png")!
            self.btneye2.setImage(image1, for: .normal)
            reEnterPintxt.isSecureTextEntry = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enterPintxt.becomeFirstResponder()
        // txt2.becomeFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // YOU SHOULD FIRST CHECK FOR THE BACKSPACE. IF BACKSPACE IS PRESSED ALLOW IT
        if string == "" {
            return true
        }
        if let characterCount = textField.text?.count {
            // CHECK FOR CHARACTER COUNT IN TEXT FIELD
            if characterCount >= 4 {
                reEnterPintxt.becomeFirstResponder()
                // RESIGN FIRST RERSPONDER TO HIDE KEYBOARD
                return textField.resignFirstResponder()
            }
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        enterPintxt.text = String(enterPintxt.text!.prefix(4))
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func NextAction(sender:UIButton){
        var a = false
        var b = false
        var c = false
        if enterPintxt.text?.count == 4 {
            c = true
        }else {
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Enter_Pin_Message) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
            })
        }
        if enterPintxt.text! == reEnterPintxt.text! {
            a = true
        } else {
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Enter_Pin_Message2) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
            })
        }
        if(enterPintxt.text! == "" || reEnterPintxt.text! == "") {
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Enter_Pin_Message3) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
            })
        } else {
            b = true
        }
        if a == true && b == true && c == true {
            SaveUserDefaultsData.BChatPassword = reEnterPintxt.text!
            if navigationflowTag == false {
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecoveryVC") as! RecoveryVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                UserDefaults.standard[.isUsingFullAPNs] = true//(selectedOptionView == apnsOptionView)
                TSAccountManager.sharedInstance().didRegister()
                let homeVC = HomeVC()
                navigationController!.setViewControllers([ homeVC ], animated: true)
                let syncTokensJob = SyncPushTokensJob(accountManager: AppEnvironment.shared.accountManager, preferences: Environment.shared.preferences)
                syncTokensJob.uploadOnlyIfStale = false
                let _: Promise<Void> = syncTokensJob.run()
            }
        }
    }
    
    
}
