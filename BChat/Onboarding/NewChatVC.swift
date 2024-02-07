// Copyright © 2022 Beldex. All rights reserved.

import UIKit
import BChatUIKit

class NewChatVC: BaseVC,UITextViewDelegate {
    weak var NewChatVC: NewChatVC!
    @IBOutlet weak var bcakgroundBChatIdView:UIView!
    @IBOutlet weak var bcakgroundBChatIdSelfView:UIView!
    @IBOutlet weak var lblchatid:UILabel!
    @IBOutlet weak var copyref:UIButton!
    @IBOutlet weak var shareref:UIButton!
    @IBOutlet weak var nextRef:UIButton!
    var placeholderLabel : UILabel!
    @IBOutlet weak var txtview:UITextView!
    @IBOutlet weak var scanRef:UIButton!
    @IBOutlet weak var bcakgroundCopyView:UIView!
    @IBOutlet weak var bcakgroundShareView:UIView!
    @IBOutlet weak var copyimg:UIImageView!
    @IBOutlet weak var shareimg:UIImageView!
    @IBOutlet weak var lblcopy:UILabel!
    
    private lazy var publicKeyTextView: TextView = {
        let result = TextView(placeholder: NSLocalizedString("Enter BChat ID", comment: ""))
        result.autocapitalizationType = .none
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        bcakgroundBChatIdView.layer.cornerRadius = 10
        bcakgroundBChatIdSelfView.layer.cornerRadius = 10
        nextRef.layer.cornerRadius = 6
        self.title = "New Chat"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        copyref.layer.cornerRadius = 6
        shareref.layer.cornerRadius = 6
        bcakgroundCopyView.layer.cornerRadius = 6
        bcakgroundShareView.layer.cornerRadius = 6
        lblcopy.isHidden = true
        copyref.setTitle("Copy", for: .normal)
        copyimg.image = UIImage(named: isLightMode ? "copy-dark" : "copy_white")!
        shareimg.image = UIImage(named: isLightMode ? "share_dark" : "share")!
        let origImage = UIImage(named: isLightMode ? "scan_QR" : "scan_QR_dark")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        scanRef.setImage(tintedImage, for: .normal)
        scanRef.tintColor = isLightMode ? UIColor.black : UIColor.white
        
        txtview.delegate = self
        txtview.returnKeyType = .done
        txtview.setPlaceholder()
        self.lblchatid.text = getUserHexEncodedPublicKey()
        self.lblchatid.textColor = Colors.bchatButtonColor
        self.lblchatid.font = Fonts.OpenSans(ofSize: Values.mediumFontSize)
        self.lblchatid.numberOfLines = 0
        self.lblchatid.textAlignment = .center
        self.lblchatid.lineBreakMode = .byCharWrapping
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        nextRef.isUserInteractionEnabled = false
        nextRef.backgroundColor = Colors.bchatViewBackgroundColor
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // On small screens we hide the legal label when the keyboard is up, but it's important that the user sees it so
        // in those instances we don't make the keyboard come up automatically
        if !isIPhone5OrSmaller {
            //  txtview.becomeFirstResponder()
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
        let str = textView.text!
        if str.count == 0 {
            nextRef.isUserInteractionEnabled = false
            nextRef.backgroundColor = Colors.bchatViewBackgroundColor
            nextRef.setTitleColor(UIColor.lightGray, for: .normal)
            txtview.checkPlaceholder()
        }else {
            nextRef.isUserInteractionEnabled = true
            nextRef.backgroundColor = Colors.bchatButtonColor
            nextRef.setTitleColor(UIColor.white, for: .normal)
            txtview.checkPlaceholder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            performAction()
            return false
        }
        else if text.count == 0 {
            nextRef.isUserInteractionEnabled = false
            nextRef.backgroundColor = Colors.bchatViewBackgroundColor
        }
        else {
            nextRef.isUserInteractionEnabled = false
            nextRef.backgroundColor = Colors.bchatViewBackgroundColor
        }
        return true
    }
    
    private func textFieldDidBeginEditing(_ textField: UITextField) {
        // became first responder
        print("TextField did begin editing method called")
    }
    
    @IBAction func copyAction(sender:UIButton){
        UIPasteboard.general.string = getUserHexEncodedPublicKey()
        copyref.isUserInteractionEnabled = false
        UIView.transition(with: copyref, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.copyref.setTitle(NSLocalizedString("copied", comment: ""), for: UIControl.State.normal)
        }, completion: nil)
        Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(enableCopyButton), userInfo: nil, repeats: false)
    }
    @objc private func enableCopyButton() {
        copyref.isUserInteractionEnabled = true
        UIView.transition(with: copyref, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.copyref.setTitle(NSLocalizedString("Copy", comment: ""), for: UIControl.State.normal)
        }, completion: nil)
    }
    
    @IBAction func shareAction(sender:UIButton){
        let shareVC = UIActivityViewController(activityItems: [ getUserHexEncodedPublicKey() ], applicationActivities: nil)
        navigationController!.present(shareVC, animated: true, completion: nil)
    }
    
    @IBAction func nextAction(sender:UIButton){
        let text = txtview.text?.trimmingCharacters(in: .whitespaces) ?? ""
        self.startNewDMIfPossible(with: text)
    }
    
    func performAction() {
        let text = txtview.text?.trimmingCharacters(in: .whitespaces) ?? ""
        self.startNewDMIfPossible(with: text)
    }
    
    fileprivate func startNewDMIfPossible(with bnsNameOrPublicKey: String) {
        if ECKeyPair.isValidHexEncodedPublicKey(candidate: bnsNameOrPublicKey) {
            startNewDM(with: bnsNameOrPublicKey)
        } else {
            // This could be an BNS name
            self.showToastMsg(message: "invalid BChat ID", seconds: 1.0)
        }
    }
    private func startNewDM(with bchatID: String) {
        let thread = TSContactThread.getOrCreateThread(contactBChatID: bchatID)
        presentingViewController?.dismiss(animated: true, completion: nil)
        SignalApp.shared().presentConversation(for: thread, action: .compose, animated: false)
    }
    @IBAction func scanAction(sender:UIButton){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScannerQRVC") as! ScannerQRVC
        vc.newChatScanflag = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension UITextView{
    func setPlaceholder() {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Enter BChat ID"
        placeholderLabel.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 0.7)
        placeholderLabel.textColor = Colors.text.withAlphaComponent(Values.mediumOpacity)
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
    }
    func checkPlaceholder() {
        let placeholderLabel = self.viewWithTag(222) as! UILabel
        placeholderLabel.isHidden = !self.text.isEmpty
    }
}
