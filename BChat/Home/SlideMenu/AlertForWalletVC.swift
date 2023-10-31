// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import UIKit

class AlertForWalletVC: BaseVC, UITextFieldDelegate {
    
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var proceedButton:UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        proceedButton.layer.cornerRadius = 6
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 4
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if newString.length == maxLength {
            textField.text = textField.text! + string
            textField.resignFirstResponder()
        }
        return newString.length <= maxLength
    }
    
    
    // - Button Action -
    @IBAction func proceedButtonAction(sender:UIButton){
        SwiftAlertView.show(title: "BChat",message: "Enter your password to view your seed. Write it down on paper.", buttonTitles: "Cancel", "Ok") { alertView in
            alertView.addTextField { textField in
                textField.attributedPlaceholder = NSAttributedString(string: "Please Enter Password", attributes: [.foregroundColor: UIColor.gray])
                textField.isSecureTextEntry = true
                textField.keyboardType = .numberPad
            }
            alertView.isEnabledValidationLabel = true
            alertView.isDismissOnActionButtonClicked = false
            alertView.style = isLightMode ? .light : .dark
        }
        .onActionButtonClicked { alert, buttonIndex in
            let username = alert.textField(at: 0)?.text ?? ""
            var a = false
            if SaveUserDefaultsData.BChatPassword == username {
                a = true
            }
            else {
                alert.validationLabel.text = "Password Do Not Match"
            }
            if a == true {
                alert.dismiss()
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecoverySeedForWalletVC") as! RecoverySeedForWalletVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        .onTextChanged { _, text, index in
            if index == 0 {
                print("Username text changed: ", text ?? "")
            }
        }
    }


}
