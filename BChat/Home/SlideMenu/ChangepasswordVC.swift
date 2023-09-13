// Copyright © 2022 Beldex. All rights reserved.

import UIKit
import BChatUIKit

class ChangepasswordVC: BaseVC,UITextFieldDelegate {
    
    @IBOutlet weak var backgroundOldPinView:UIView!
    @IBOutlet weak var backgroundNewPinView:UIView!
    @IBOutlet weak var oldPintxt:UITextField!
    @IBOutlet weak var newPintxt:UITextField!
    @IBOutlet weak var continueRef:UIButton!
    @IBOutlet weak var btneye1:UIButton!
    @IBOutlet weak var btneye2:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Change Password"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //Keyboard Done Option
        oldPintxt.addDoneButtonKeybord()
        newPintxt.addDoneButtonKeybord()
        
        let imgName = isLightMode ? "eye_icon" : "eye_unclosedicon_white"
        let image = UIImage(named: "\(imgName).png")!
        self.btneye1.setImage(image, for: .normal)
        self.btneye2.setImage(image, for: .normal)
        
        backgroundOldPinView.layer.cornerRadius = 10
        backgroundNewPinView.layer.cornerRadius = 10
        continueRef.layer.cornerRadius = 6
        oldPintxt.attributedPlaceholder = NSAttributedString(string:"Eg.0089", attributes:[NSAttributedString.Key.foregroundColor: isLightMode ? UIColor.darkGray : UIColor.lightGray])
        newPintxt.attributedPlaceholder = NSAttributedString(string:"Eg.0089", attributes:[NSAttributedString.Key.foregroundColor: isLightMode ? UIColor.darkGray : UIColor.lightGray])
        oldPintxt.delegate = self
        newPintxt.delegate = self
        oldPintxt.isSecureTextEntry = true
        newPintxt.isSecureTextEntry = true
        oldPintxt.keyboardType = .numberPad
        newPintxt.keyboardType = .numberPad
        
        let dismiss: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismiss)
        
    }
    @IBAction func eyeAction1(sender:UIButton){
        btneye1.isSelected = !btneye1.isSelected
        if btneye1.isSelected {
            oldPintxt.isSecureTextEntry = false
            let imgName = isLightMode ? "eye_Closedicon" : "eye_icon_white"
            let image1 = UIImage(named: "\(imgName).png")!
            self.btneye1.setImage(image1, for: .normal)
        }else {
            oldPintxt.isSecureTextEntry = true
            let imgName = isLightMode ? "eye_icon" : "eye_unclosedicon_white"
            let image1 = UIImage(named: "\(imgName).png")!
            self.btneye1.setImage(image1, for: .normal)
        }
    }
    @IBAction func eyeAction2(sender:UIButton){
        btneye2.isSelected = !btneye2.isSelected
        if btneye2.isSelected {
            newPintxt.isSecureTextEntry = false
            let imgName = isLightMode ? "eye_Closedicon" : "eye_icon_white"
            let image1 = UIImage(named: "\(imgName).png")!
            self.btneye2.setImage(image1, for: .normal)
        }else {
            let imgName = isLightMode ? "eye_icon" : "eye_unclosedicon_white"
            let image1 = UIImage(named: "\(imgName).png")!
            self.btneye2.setImage(image1, for: .normal)
            newPintxt.isSecureTextEntry = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        oldPintxt.becomeFirstResponder()
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
                newPintxt.becomeFirstResponder()
                // RESIGN FIRST RERSPONDER TO HIDE KEYBOARD
                return textField.resignFirstResponder()
            }
        }
        return true
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func continueAction(sender:UIButton){
        var a = false
        var b = false
        var c = false
        if(oldPintxt.text! == "" || newPintxt.text! == ""){
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Enter_Pin_Message3) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
                
            })
        }
        if SaveUserDefaultsData.BChatPassword == oldPintxt.text! {
            a = true
        }
        else{
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Enter_Pin_Message2) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
                
            })
        }
        if newPintxt.text?.count == 4 {
            b = true
        }
        else{
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Enter_Pin_Message4) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
                
            })
        }
        if SaveUserDefaultsData.BChatPassword == newPintxt.text! {
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Enter_Pin_Message5) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
                
            })
        }else {
            c = true
        }
        if a == true && b == true && c == true {
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Password_Message) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
                
                SaveUserDefaultsData.BChatPassword = self.newPintxt.text!
                self.navigationController?.popViewController(animated: true)
                
            })
        }
    }
    
}
