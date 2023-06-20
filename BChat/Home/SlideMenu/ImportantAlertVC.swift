// Copyright © 2022 Beldex. All rights reserved.

import UIKit

class ImportantAlertVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var contentlbl1:UILabel!
    @IBOutlet weak var contentlbl2:UILabel!
    @IBOutlet weak var contentlbl3:UILabel!
    @IBOutlet weak var contentlbl4:UILabel!
    @IBOutlet weak var nextRef:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        nextRef.layer.cornerRadius = 6
        
        self.contentlbl1.text = "IMPORTANT"
        self.contentlbl2.text = "Never share your seed with anyone!"
        self.contentlbl3.text = "Your seed can be used to restore your account. Never share it with anyone or store a digital copy of it. Never enter your seed in any other website or application other than BChat or the Beldex official wallet."
        self.contentlbl4.text = "Check your surroundings and ensure no one is overlooking. Do you want to proceed?"
        nextRef.setTitle("Yes, I'm Safe.", for: .normal)
        
    }
    //MARK:- UITextFieldDelegate
    
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
    
    // MARK: - Navigation
    @IBAction func NextAction(sender:UIButton){
        SwiftAlertView.show(title: "BChat",message: "Enter your password to view your seed. Write it down on paper.", buttonTitles: "Cancel", "Ok") { alertView in
            alertView.addTextField { textField in
                textField.attributedPlaceholder = NSAttributedString(string: "Please Enter Password", attributes: [.foregroundColor: UIColor.gray])
                textField.isSecureTextEntry = true
                textField.keyboardType = .numberPad
            }
            alertView.isEnabledValidationLabel = true
            alertView.isDismissOnActionButtonClicked = false
            alertView.style = .dark
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
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecoverySeedMenuVC") as! RecoverySeedMenuVC
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
