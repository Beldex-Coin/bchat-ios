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
    var DateHeightdata = ["2019-03:21164",
                          "2019-04:42675",
                          "2019-05:64918",
                          "2019-06:87175",
                          "2019-07:108687",
                          "2019-08:130935",
                          "2019-09:152452",
                          "2019-10:174680",
                          "2019-11:196906",
                          "2019-12:217017",
                          "2020-01:239353",
                          "2020-02:260946",
                          "2020-03:283214",
                          "2020-04:304758",
                          "2020-05:326679",
                          "2020-06:348926",
                          "2020-07:370533",
                          "2020-08:392807",
                          "2020-09:414270",
                          "2020-10:436562",
                          "2020-11:458817",
                          "2020-12:479654",
                          "2021-01:501870",
                          "2021-02:523356",
                          "2021-03:545569",
                          "2021-04:567123",
                          "2021-05:589402",
                          "2021-06:611687",
                          "2021-07:633161",
                          "2021-08:655438",
                          "2021-09:677038",
                          "2021-10:699358",
                          "2021-11:721678",
                          "2021-12:741838",
                          "2022-01:788501",
                          "2022-02:877781",
                          "2022-03:958421",
                          "2022-04:1006790",
                          "2022-05:1093190",
                          "2022-06:1199750",
                          "2022-07:1291910",
                          "2022-08:1361030",
                          "2022-09:1456070",
                          "2022-10:1574150",
                          "2022-11:1674950",
                          "2022-12:1764230",
                          "2023-01:1850630"]
    var flag = false
    var finalheight = ""
    var BlockChainHeight: UInt64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Rescan"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
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
        self.lblBlockChainHeight.text = "\(BlockChainHeight)"
        
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
                        datePickerMode: .date) { [self] (date) in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.txtdate.text = formatter.string(from: dt)
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "yyyy-MM"
                let finalDate = formatter2.string(from: dt)
                for element in self.DateHeightdata {
                    let fullNameArr = element.components(separatedBy: ":")
                    let dateString  = fullNameArr[0]
                    let heightString = fullNameArr[1]
                    if dateString == finalDate {
                        finalheight = heightString
                    }else {
                        finalheight = "1850630"
                        SaveUserDefaultsData.WalletRestoreHeight = finalheight
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
            let number: Int64? = Int64("\(finalheight)")
            if number! > BlockChainHeight {
                let alert = UIAlertController(title: "Wallet", message: "Invalid BlockChainHeight", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                })
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }else {
                SaveUserDefaultsData.WalletRestoreHeight = finalheight
                if self.navigationController != nil{
                    let count = self.navigationController!.viewControllers.count
                    if count > 1
                    {
                        let VC = self.navigationController!.viewControllers[count-2] as! MyWalletHomeVC
                        VC.backAPIRescanVC = true
                    }
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
        if heightString != "" && dateString == "" {
            let number: Int64? = Int64("\(heightString!)")
            if number! > BlockChainHeight {
                print("In valid BlockChainHeight")
                let alert = UIAlertController(title: "Wallet", message: "Invalid BlockChainHeight", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                })
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }else if number! == BlockChainHeight {
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
                        VC.backAPIRescanVC = true
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
