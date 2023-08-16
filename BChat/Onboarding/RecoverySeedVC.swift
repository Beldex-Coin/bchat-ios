// Copyright © 2022 Beldex. All rights reserved.

import UIKit

class RecoverySeedVC: BaseVC,UITextViewDelegate {
    
    @IBOutlet weak var backgroundView:UIView!
    @IBOutlet weak var clearRef:UIButton!
    @IBOutlet weak var nextRef:UIButton!
    @IBOutlet weak var pasteRef:UIButton!
    @IBOutlet weak var lblcount:UILabel!
    @IBOutlet weak var txtview:UITextView!
    var placeholderLabel : UILabel!
    var WordCount:Int!
    var fulllenthSeedStr = ""
    var lastWordSeedStr = ""
    var txtviewstr = ""
    var Seedflag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "Restore from seed"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        setUpGradientBackground()
        setUpNavBarStyle()
        
        let origImage = UIImage(named: "pasteicon")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        pasteRef.setImage(tintedImage, for: .normal)
        pasteRef.tintColor = Colors.accent2
        
        backgroundView.layer.cornerRadius = 10
        clearRef.layer.cornerRadius = 6
        nextRef.layer.cornerRadius = 6
        
        // Dismiss keyboard on tap
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        txtview.textAlignment = .left
        txtview.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter your recovery seed to restore\n your account."
        placeholderLabel.numberOfLines = 2
        placeholderLabel.font = Fonts.OpenSans(ofSize: (txtview.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        txtview.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtview.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !txtview.text.isEmpty
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // On small screens we hide the legal label when the keyboard is up, but it's important that the user sees it so
        // in those instances we don't make the keyboard come up automatically
        if !isIPhone5OrSmaller {
            txtview.becomeFirstResponder()
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: General
    @objc private func dismissKeyboard() {
        txtview.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let strings : String! = txtview.text.lowercased()
        let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let words = strings.components(separatedBy: spaces)
        if lastWordSeedStr == words.last! {
            Seedflag = true
        }else {
            Seedflag = false
        }
        if words.count == 25 {
            Seedflag = true
        }
        lblcount.text = "\(words.count)/25"
        if words.count > 25 {
            lblcount.text = "25/25"
            txtview.text = txtviewstr
        }else{
            txtviewstr = txtview.text.lowercased()
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
        
        if textView.text == "" {
            lblcount.text = "0/25"
        }
    }
    
    @IBAction func pasteAction(sender:UIButton){
        if let myString = UIPasteboard.general.string {
            self.txtview.text = ""
            let strings : String! = myString
            let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let words = strings.components(separatedBy: spaces)
            fulllenthSeedStr = myString
            lastWordSeedStr = words.last!
            txtview.insertText(myString)
        }
    }
    @IBAction func ClearAction(sender:UIButton){
        txtview.text = ""
        lblcount.text = "0/25"
    }
    @IBAction func NextAction(sender:UIButton){
        if Seedflag == false {
            self.showToastMsg(message: "Something went wrong.Please check your mnemonic and try again", seconds: 1.0)
        }else {
            let strings : String! = txtview.text.lowercased()
            let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let words = strings.components(separatedBy: spaces)
            print(words.count)
            if words.count > 25 {
                self.showToastMsg(message: "There appears to be an invalid word in your recovery phrase. Please check what you entered and try again.", seconds: 2.0)
            }else {
                func showError(title: String, message: String = "") {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
                    presentAlert(alert)
                }
                let mnemonic = txtview.text!.lowercased()
                do {
                    let hexEncodedSeed = try Mnemonic.decode(mnemonic: mnemonic)
                    let seed = Data(hex: hexEncodedSeed)
                    let (ed25519KeyPair, x25519KeyPair) = KeyPairUtilities.generate(from: seed)
                    Onboarding.Flow.recover.preregister(with: seed, ed25519KeyPair: ed25519KeyPair, x25519KeyPair: x25519KeyPair)
                    txtview.resignFirstResponder()
                    Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
                        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecoverySeedNameVC") as! RecoverySeedNameVC
                        navigationflowTag = true
                        vc.SeedPass = self.txtview.text!.lowercased()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } catch let error {
                    let error = error as? Mnemonic.DecodingError ?? Mnemonic.DecodingError.generic
                    showError(title: error.errorDescription!)
                }
            }
        }
    }
    
}
