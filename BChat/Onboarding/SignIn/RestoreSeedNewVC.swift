// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class RestoreSeedNewVC: BaseVC,UITextViewDelegate {

    // MARK: Components
    var seedFlag = false
    var lastWordSeedStr = ""
    var txtViewStr = ""
    var fullLenthSeedStr = ""
    var placeholderLabel : UILabel!
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    private lazy var isFromPasteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_PasteNew"), for: .normal)
        button.addTarget(self, action: #selector(isFromPasteButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var lblCountLabel: UILabel = {
        let result = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.text = NSLocalizedString("0/25", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .right
        return result
    }()
    private lazy var mnemonicTextView: UITextView = {
        let result = UITextView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.borderColor = Colors.bchatButtonColor.cgColor
        result.backgroundColor = .clear
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 14)
        return result
    }()
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: 0x1C1C26)
        button.setTitle(NSLocalizedString("CLEAR_BUTTON", comment: ""), for: .normal)
        let image = UIImage(named: "ic_EraseNew")?.scaled(to: CGSize(width: 20.0, height: 20.0))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(hex: 0xA7A7BA) // Set the tint color to white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(hex: 0xA7A7BA), for: .normal)
        button.titleLabel!.font = Fonts.semiOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var isFromRestoreButton: UIButton = {
        let result = UIButton(type: .custom)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.setTitle(NSLocalizedString("continue_2", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: isIPhone5OrSmaller ? Values.mediumFontSize : Values.mediumFontSize)
        result.addTarget(self, action: #selector(isFromRestoreAction), for: UIControl.Event.touchUpInside)
        result.layer.cornerRadius = 16
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.setTitleColor(UIColor(hex: 0x6C6C78), for: .normal)
        return result
    }()
    private lazy var descPasteLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.font = Fonts.OpenSans(ofSize: 12)
        result.text = NSLocalizedString("PASTE_THE_SEED_NEW", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .center
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Restore seed"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = UIColor(hex: 0x11111A)
        
        view.addSubview(backGroundView)
        backGroundView.addSubview(isFromPasteButton)
        backGroundView.addSubview(lblCountLabel)
        backGroundView.addSubview(mnemonicTextView)
        view.addSubview(clearButton)
        view.addSubview(isFromRestoreButton)
        view.addSubview(descPasteLabel)
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            backGroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -41),
            backGroundView.heightAnchor.constraint(equalToConstant: 140),
            isFromPasteButton.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 20),
            isFromPasteButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            isFromPasteButton.heightAnchor.constraint(equalToConstant: 18),
            isFromPasteButton.heightAnchor.constraint(equalToConstant: 18),
            lblCountLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -20),
            lblCountLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            mnemonicTextView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 21),
            mnemonicTextView.trailingAnchor.constraint(equalTo: isFromPasteButton.leadingAnchor, constant: -10),
            mnemonicTextView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -10),
            mnemonicTextView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 10),
            clearButton.topAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: 12),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            clearButton.heightAnchor.constraint(equalToConstant: 44),
            clearButton.widthAnchor.constraint(equalToConstant: 116),
            isFromRestoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            isFromRestoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            isFromRestoreButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
            isFromRestoreButton.heightAnchor.constraint(equalToConstant: 58),
            descPasteLabel.bottomAnchor.constraint(equalTo: isFromRestoreButton.topAnchor, constant: -14),
            descPasteLabel.centerXAnchor.constraint(equalTo: isFromRestoreButton.centerXAnchor),
        ])
        
        self.placeHolderSeedLabel()
        isFromRestoreButton.backgroundColor = UIColor(hex: 0x1C1C26)
        isFromRestoreButton.setTitleColor(UIColor(hex: 0x6C6C78), for: .normal)
        
        // Dismiss keyboard on tap
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isIPhone5OrSmaller {
            mnemonicTextView.becomeFirstResponder()
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        clearButton.layer.cornerRadius = clearButton.bounds.height / 2
    }
    @objc private func dismissKeyboard() {
        mnemonicTextView.resignFirstResponder()
    }
    
    func placeHolderSeedLabel(){
        mnemonicTextView.textAlignment = .left
        mnemonicTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("ENTER_YOUR_SEED_NEW", comment: "")
        placeholderLabel.numberOfLines = 0
        placeholderLabel.font = Fonts.OpenSans(ofSize: (mnemonicTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        mnemonicTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 2, y: 8)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !mnemonicTextView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let strings : String! = mnemonicTextView.text.lowercased()
        let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let words = strings.components(separatedBy: spaces)
        if lastWordSeedStr == words.last! {
            seedFlag = true
        }else {
            seedFlag = false
        }
        if words.count == 25 {
            seedFlag = true
            descPasteLabel.isHidden = true
            isFromRestoreButton.backgroundColor = UIColor(hex: 0x00BD40)
            isFromRestoreButton.setTitleColor(.white, for: .normal)
        }else {
            descPasteLabel.isHidden = false
            isFromRestoreButton.backgroundColor = UIColor(hex: 0x1C1C26)
            isFromRestoreButton.setTitleColor(UIColor(hex: 0x6C6C78), for: .normal)
        }
        lblCountLabel.text = "\(words.count)/25"
        if words.count > 25 {
            lblCountLabel.text = "25/25"
            mnemonicTextView.text = txtViewStr
        }else{
            txtViewStr = mnemonicTextView.text.lowercased()
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
        if textView.text == "" {
            lblCountLabel.text = "0/25"
        }
    }
    
    func showError(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
        presentAlert(alert)
    }
    
    // MARK: - Navigation
    @objc func isFromPasteButtonTapped(_ sender: UIButton){
        if let myString = UIPasteboard.general.string {
            self.mnemonicTextView.text = ""
            let strings : String! = myString
            let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let words = strings.components(separatedBy: spaces)
            fullLenthSeedStr = myString
            lastWordSeedStr = words.last!
            mnemonicTextView.insertText(myString)
        }
    }
    @objc func clearButtonTapped(_ sender: UIButton){
        mnemonicTextView.text = ""
        lblCountLabel.text = "0/25"
        descPasteLabel.isHidden = false
        self.placeHolderSeedLabel()
        isFromRestoreButton.backgroundColor = UIColor(hex: 0x1C1C26)
        isFromRestoreButton.setTitleColor(UIColor(hex: 0x6C6C78), for: .normal)
        self.isFromRestoreButton.isUserInteractionEnabled = true
    }
    @objc func isFromRestoreAction(_ sender: UIButton){
        if seedFlag == false {
            self.showToastMsg(message: NSLocalizedString("WRONG_SEED_ERROR_NEW", comment: ""), seconds: 1.0)
        }else {
            self.isFromRestoreButton.isUserInteractionEnabled = false
            let strings : String! = mnemonicTextView.text.lowercased()
            let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let words = strings.components(separatedBy: spaces)
            print(words.count)
            if words.count > 25 {
                self.showToastMsg(message: NSLocalizedString("INVALID_SEED_ERROR_NEW", comment: ""), seconds: 2.0)
                self.isFromRestoreButton.isUserInteractionEnabled = true
            }else {
                let mnemonic = mnemonicTextView.text!.lowercased()
                do {
                    let hexEncodedSeed = try Mnemonic.decode(mnemonic: mnemonic)
                    let seed = Data(hex: hexEncodedSeed)
                    let (ed25519KeyPair, x25519KeyPair) = KeyPairUtilities.generate(from: seed)
                    Onboarding.Flow.recover.preregister(with: seed, ed25519KeyPair: ed25519KeyPair, x25519KeyPair: x25519KeyPair)
                    mnemonicTextView.resignFirstResponder()
                    Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
                        let restoreNameVC = RestoreNameVC()
                        navigationflowTag = true
                        self.isFromRestoreButton.isUserInteractionEnabled = true
                        restoreNameVC.seedPassing = self.mnemonicTextView.text!.lowercased()
                        self.navigationController!.pushViewController(restoreNameVC, animated: true)
                    }
                } catch let error {
                    self.isFromRestoreButton.isUserInteractionEnabled = true
                    let error = error as? Mnemonic.DecodingError ?? Mnemonic.DecodingError.generic
                    showError(title: error.errorDescription!)
                }
            }
        }
    }
    
}
