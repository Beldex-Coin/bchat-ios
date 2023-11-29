// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit

class MyWalletRescanVC: BaseVC,UITextFieldDelegate {
    
    @IBOutlet weak var backgroundHeightView: UIView!
    @IBOutlet weak var backgroundDateView: UIView!
    @IBOutlet weak var btnrescan: UIButton!
    @IBOutlet weak var txthight: UITextField!
    @IBOutlet weak var txtdate: UITextField!
    @IBOutlet weak var backgroundCurrentHeightView: UIView!
    @IBOutlet weak var lblBlockChainHeight: UILabel!
    let datePicker = DatePickerDialog()
    var flag = false
    var daemonBlockChainHeight: UInt64 = 0
    var dateHeight = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Rescan"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.lblBlockChainHeight.text = "\(daemonBlockChainHeight)"
        //Keyboard Done Option
        txthight.addDoneButtonKeybord()
        backgroundHeightView.layer.cornerRadius = 6
        backgroundDateView.layer.cornerRadius = 6
        backgroundCurrentHeightView.layer.cornerRadius = 6
        btnrescan.layer.cornerRadius = 6
        txthight.keyboardType = .numberPad
        txthight.delegate = self
        txtdate.delegate = self
        
        let dismiss: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismiss)
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == txthight){
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return (string == numberFiltered) && textLimit(existingText: textField.text,
                                                           newText: string,
                                                           limit: 9)
        }
        return true
    }
    
    func textLimit(existingText: String?,
                   newText: String,
                   limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtdate {
            datePickerTapped()
            return false
        }
        return true
    }
    
    func datePickerTapped() {
        datePicker.show("Select Date",
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        maximumDate: Date(),
                        datePickerMode: .date) { [self] (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.txtdate.text = formatter.string(from: dt)
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "yyyy-MM"
                let finalDate = formatter2.string(from: dt)
                for element in DateHeight.getBlockHeight {
                    let fullNameArr = element.components(separatedBy: ":")
                    let dateString  = fullNameArr[0]
                    let heightString = fullNameArr[1]
                    if dateString == finalDate {
                        dateHeight = heightString
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    @IBAction func info_Action(_ sender: UIButton) {
        let alert = UIAlertController(title: "Block Height", message: "Blockheight is the block number in a blockchain at a given time.Enter the block height at which you created the wallet for fast synchronization.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
            
        })
        alert.addAction(ok)
        ok.setValue(UIColor.green, forKey: "titleTextColor")
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    @IBAction func Rescan_Action(_ sender: UIButton) {
        let heightString = txthight.text
        let dateString = txtdate.text
        if heightString == "" && dateString != ""{
            if !dateHeight.isEmpty {
                SaveUserDefaultsData.WalletRestoreHeight = dateHeight
            }else {
                SaveUserDefaultsData.WalletRestoreHeight = ""
            }
            if self.navigationController != nil{
                let count = self.navigationController!.viewControllers.count
                if count > 1
                {
                    let VC = self.navigationController!.viewControllers[count-2] as! MyWalletHomeVC
                    VC.backApiRescanVC = true
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
        if heightString != "" && dateString == "" {
            let number: Int64? = Int64("\(heightString!)")
            if number! > daemonBlockChainHeight {
                print("In valid BlockChainHeight")
                let alert = UIAlertController(title: "Wallet", message: "Invalid BlockChainHeight", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                })
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }else if number! == daemonBlockChainHeight {
                let alert = UIAlertController(title: "Wallet", message: "Invalid BlockChainHeight", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                })
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                SaveUserDefaultsData.WalletRestoreHeight = txthight.text!
                if self.navigationController != nil{
                    let count = self.navigationController!.viewControllers.count
                    if count > 1
                    {
                        let VC = self.navigationController!.viewControllers[count-2] as! MyWalletHomeVC
                        VC.backApiRescanVC = true
                    }
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        if txthight.text != "" && txtdate.text != "" {
            let alert = UIAlertController(title: "Wallet", message: "Please pick a restore height or restore from date", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
            })
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
        if txthight.text!.isEmpty && txtdate.text!.isEmpty {
            let alert = UIAlertController(title: "Wallet", message: "Please pick a restore height or restore from date", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
            })
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
