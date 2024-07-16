// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class RestoreSeedNewVC: BaseVC {

    // MARK: - UIElements
    
    /// BackGround View
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    /// Paste Button
    private lazy var pasteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_PasteNew"), for: .normal)
        button.addTarget(self, action: #selector(pasteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Word Count Label
    private lazy var wordCountLabel: UILabel = {
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
    
    /// Mnemonic TextView
    private lazy var mnemonicTextView: UITextView = {
        let result = UITextView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.borderColor = Colors.bchatButtonColor.cgColor
        result.backgroundColor = .clear
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 14)
        return result
    }()
    
    /// Clear Button
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
    
    /// Restore Button
    private lazy var restoreButton: UIButton = {
        let result = UIButton(type: .custom)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.setTitle(NSLocalizedString("continue_2", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: isIPhone5OrSmaller ? Values.mediumFontSize : Values.mediumFontSize)
        result.addTarget(self, action: #selector(restoreActionTapped), for: UIControl.Event.touchUpInside)
        result.layer.cornerRadius = 16
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.setTitleColor(UIColor(hex: 0x6C6C78), for: .normal)
        return result
    }()
    
    /// Description Label
    private lazy var descriptionLabel: UILabel = {
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
    
    var seedFlag = false
    var lastSeedWord = ""
    var textViewString = ""
    var fullLenthSeedStr = ""
    var placeholderLabel : UILabel!
    
    
    // MARK: - UIViewController life cycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Restore seed"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setUpTopCornerRadius()
        view.backgroundColor = UIColor(hex: 0x11111A)
        
        view.addSubview(backGroundView)
        backGroundView.addSubview(pasteButton)
        backGroundView.addSubview(wordCountLabel)
        backGroundView.addSubview(mnemonicTextView)
        view.addSubview(clearButton)
        view.addSubview(restoreButton)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            backGroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -41),
            backGroundView.heightAnchor.constraint(equalToConstant: 140),
            pasteButton.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 20),
            pasteButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            pasteButton.heightAnchor.constraint(equalToConstant: 18),
            pasteButton.heightAnchor.constraint(equalToConstant: 18),
            wordCountLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -20),
            wordCountLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            mnemonicTextView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 21),
            mnemonicTextView.trailingAnchor.constraint(equalTo: pasteButton.leadingAnchor, constant: -10),
            mnemonicTextView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -10),
            mnemonicTextView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 10),
            clearButton.topAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: 12),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            clearButton.heightAnchor.constraint(equalToConstant: 44),
            clearButton.widthAnchor.constraint(equalToConstant: 116),
            restoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            restoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            restoreButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
            restoreButton.heightAnchor.constraint(equalToConstant: 58),
            descriptionLabel.bottomAnchor.constraint(equalTo: restoreButton.topAnchor, constant: -14),
            descriptionLabel.centerXAnchor.constraint(equalTo: restoreButton.centerXAnchor),
        ])
        
        self.placeHolderSeedLabel()
        restoreButton.backgroundColor = UIColor(hex: 0x1C1C26)
        restoreButton.setTitleColor(UIColor(hex: 0x6C6C78), for: .normal)
        restoreButton.isUserInteractionEnabled = false
        
    }
    
    /// View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isIPhone5OrSmaller {
            mnemonicTextView.becomeFirstResponder()
        }
    }
    
    /// View Did Layout Subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        clearButton.layer.cornerRadius = clearButton.bounds.height / 2
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// PlaceHolder Seed Label
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
    
    func showError(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
        presentAlert(alert)
    }
    
    // MARK: Button Actions :-
    
    /// Paste Button Tapped
    @objc func pasteButtonTapped(_ sender: UIButton){
        if let myString = UIPasteboard.general.string, !myString.isEmpty {
            self.mnemonicTextView.text = ""
            let strings = myString
            let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let words = strings.components(separatedBy: spaces).filter { !$0.isEmpty } // filter out any empty strings
            fullLenthSeedStr = myString
            if let lastWord = words.last {
                lastSeedWord = lastWord
            }
            mnemonicTextView.insertText(myString)
        } else {
            showToast(message: NSLocalizedString("Make sure you have copied the seed!", comment: ""), seconds: 1.0)
        }
    }
    
    /// Clear Button Tapped
    @objc func clearButtonTapped(_ sender: UIButton){
        mnemonicTextView.text = ""
        wordCountLabel.text = "0/25"
        descriptionLabel.isHidden = false
        self.placeHolderSeedLabel()
        restoreButton.backgroundColor = UIColor(hex: 0x1C1C26)
        restoreButton.setTitleColor(UIColor(hex: 0x6C6C78), for: .normal)
        restoreButton.isUserInteractionEnabled = false
        self.restoreButton.isUserInteractionEnabled = true
    }
    
    /// Restore Action Tapped
    @objc func restoreActionTapped(_ sender: UIButton){
        if seedFlag == false {
            showToast(message: NSLocalizedString("WRONG_SEED_ERROR_NEW", comment: ""), seconds: 1.0)
        } else {
            self.restoreButton.isUserInteractionEnabled = false
            let strings : String! = mnemonicTextView.text.lowercased()
            let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let words = strings.components(separatedBy: spaces)
            print(words.count)
            if words.count > 25 {
                showToast(message: NSLocalizedString("INVALID_SEED_ERROR_NEW", comment: ""), seconds: 2.0)
                self.restoreButton.isUserInteractionEnabled = true
            } else {
                let mnemonic = mnemonicTextView.text!.lowercased()
                do {
                    let hexEncodedSeed = try Mnemonic.decode(mnemonic: mnemonic)
                    let seed = Data(hex: hexEncodedSeed)
                    let (ed25519KeyPair, x25519KeyPair) = KeyPairUtilities.generate(from: seed)
                    Onboarding.Flow.recover.preregister(with: seed, ed25519KeyPair: ed25519KeyPair, x25519KeyPair: x25519KeyPair)
                    mnemonicTextView.resignFirstResponder()
                    Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
                        let restoreNameVC = RestoreNameVC()
                        self.restoreButton.isUserInteractionEnabled = true
                        restoreNameVC.seedPassing = self.mnemonicTextView.text!.lowercased()
                        self.navigationController!.pushViewController(restoreNameVC, animated: true)
                    }
                } catch let error {
                    self.restoreButton.isUserInteractionEnabled = true
                    let error = error as? Mnemonic.DecodingError ?? Mnemonic.DecodingError.generic
                    showError(title: error.errorDescription!)
                }
            }
        }
    }
    
}


// MARK: - UITextViewDelegate methods

extension RestoreSeedNewVC: UITextViewDelegate {
    
    /// Text View Did Change
    func textViewDidChange(_ textView: UITextView) {
        let strings : String! = mnemonicTextView.text.lowercased()
        let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let words = strings.components(separatedBy: spaces)
        if lastSeedWord == words.last! {
            seedFlag = true
        }else {
            seedFlag = false
        }
        if words.count == 25 {
            seedFlag = true
            descriptionLabel.isHidden = true
            restoreButton.backgroundColor = UIColor(hex: 0x00BD40)
            restoreButton.setTitleColor(.white, for: .normal)
            restoreButton.isUserInteractionEnabled = true
        } else {
            descriptionLabel.isHidden = false
            restoreButton.backgroundColor = UIColor(hex: 0x1C1C26)
            restoreButton.setTitleColor(UIColor(hex: 0x6C6C78), for: .normal)
            restoreButton.isUserInteractionEnabled = false
        }
        wordCountLabel.text = "\(words.count)/25"
        if words.count > 25 {
            wordCountLabel.text = "25/25"
            mnemonicTextView.text = textViewString
        }else{
            textViewString = mnemonicTextView.text.lowercased()
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
        if textView.text == "" {
            wordCountLabel.text = "0/25"
        }
    }
    
}
