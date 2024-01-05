// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import UIKit

class RestoreVC: BaseVC,UITextViewDelegate {
    private var spacer1HeightConstraint: NSLayoutConstraint!
    private var spacer2HeightConstraint: NSLayoutConstraint!
    private var restoreButtonBottomOffsetConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    var seedFlag = false
    var lastWordSeedStr = ""
    var txtViewStr = ""
    var fullLenthSeedStr = ""
    var placeholderLabel : UILabel!
    
    // MARK: Components
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.set(.height, to: 130)
        stackView.set(.width, to: 270)
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.text = NSLocalizedString("Paste the seed to continue", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .center
        return result
    }()
    
    private lazy var mnemonicTextView: UITextView = {
        let result = UITextView()
        result.layer.borderColor = Colors.bchatButtonColor.cgColor
        result.backgroundColor = .clear
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: isIPhone5OrSmaller ? 14 : 14)
        return result
    }()
    
    private lazy var isFromPasteButton: UIButton = {
        let result = UIButton(type: .custom)
        result.setTitle(NSLocalizedString("  Paste Seed", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: isIPhone5OrSmaller ? 14 : 14)
        result.addTarget(self, action: #selector(fromPasteSeedAction), for: UIControl.Event.touchUpInside)
        // Set the image
//        let image = UIImage(named: "pasteicon")?.withRenderingMode(.alwaysTemplate)
//        result.setImage(image, for: .normal)
//        result.tintColor = Colors.accentColor
        result.backgroundColor = UIColor(hex: 0x00BD40)
        result.layer.cornerRadius = 25
//        result.clipsToBounds = true
//        result.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        result.set(.height, to: 50)
        return result
    }()
    
    private lazy var isFromRestoreButton: UIButton = {
        let result = UIButton(type: .custom)
        result.setTitle(NSLocalizedString("continue_2", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: isIPhone5OrSmaller ? Values.mediumFontSize : Values.mediumFontSize)
        result.addTarget(self, action: #selector(isFromRestoreAction), for: UIControl.Event.touchUpInside)
        result.layer.cornerRadius = 16
        result.set(.height, to: 58)
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.setTitleColor(.lightGray, for: .normal)
        return result
    }()
        
    private lazy var isPasteViewContainer: UIStackView = {
        let result = UIStackView()
        result.axis = .horizontal
        result.spacing = UIDevice.current.isIPad ? Values.iPadButtonSpacing : Values.mediumSpacing
        result.distribution = .fillEqually
        if (UIDevice.current.isIPad) {
            result.layoutMargins = UIEdgeInsets(top: 0, left: Values.iPadButtonContainerMargin, bottom: 0, right: Values.iPadButtonContainerMargin)
            result.isLayoutMarginsRelativeArrangement = true
        }
        return result
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Restore seed"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        setUpGradientBackground()
//        setUpNavBarStyle()
        view.backgroundColor = UIColor(hex: 0x11111A)
        isFromPasteButton.addRightIcon(image: UIImage(named: "pasteicon")!.withRenderingMode(.alwaysTemplate))
        isFromPasteButton.tintColor = .white
        
        mnemonicTextView.textAlignment = .left
        mnemonicTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = " Enter your Seed"
        placeholderLabel.numberOfLines = 0
        placeholderLabel.font = Fonts.OpenSans(ofSize: (mnemonicTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        mnemonicTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 2, y: 8)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !mnemonicTextView.text.isEmpty
        isFromRestoreButton.backgroundColor = UIColor(hex: 0x1C1C26)
        // Set up spacers
        let topSpacer = UIView.vStretchingSpacer()
        let spacer1 = UIView()
        spacer1HeightConstraint = spacer1.set(.height, to: 20)
        let spacer2 = UIView()
        spacer2HeightConstraint = spacer2.set(.height, to: 20)
        let bottomSpacer = UIView.vStretchingSpacer()
        let restoreButtonBottomOffsetSpacer = UIView()
        restoreButtonBottomOffsetConstraint = restoreButtonBottomOffsetSpacer.set(.height, to: 33)
        
        // Set up restore button container
        let restoreButtonContainer = UIView(wrapping: isFromRestoreButton, withInsets: UIEdgeInsets(top: 0, leading: 21, bottom: 0, trailing: 21), shouldAdaptForIPadWithWidth: Values.iPadButtonWidth)
        
        let emptyViewContainer = UIView()
        isPasteViewContainer.addArrangedSubview(emptyViewContainer)
        isPasteViewContainer.addArrangedSubview(isFromPasteButton)
        
        backGroundView.addSubview(mnemonicTextView)
        mnemonicTextView.pin(.leading, to: .leading, of: backGroundView, withInset: 21)
        mnemonicTextView.pin(.top, to: .top, of: backGroundView, withInset: 21)
        mnemonicTextView.pin(.trailing, to: .trailing, of: backGroundView, withInset: -21)
        mnemonicTextView.pin(.bottom, to: .bottom, of: backGroundView, withInset: -21)
        
        // Set up top stack view
        let topStackView = UIStackView(arrangedSubviews: [ backGroundView, spacer1, isPasteViewContainer ])
        topStackView.axis = .vertical
        topStackView.alignment = .fill
        // Set up top stack view container
        let topStackViewContainer = UIView()
        topStackViewContainer.addSubview(topStackView)
        topStackView.pin(.leading, to: .leading, of: topStackViewContainer, withInset: 21)
        topStackView.pin(.top, to: .top, of: topStackViewContainer)
        topStackViewContainer.pin(.trailing, to: .trailing, of: topStackView, withInset: 21)
        topStackViewContainer.pin(.bottom, to: .bottom, of: topStackView)
        // Set up main stack view
        let mainStackView = UIStackView(arrangedSubviews: [ topSpacer, topStackViewContainer, bottomSpacer, titleLabel, spacer2, restoreButtonContainer, restoreButtonBottomOffsetSpacer ])
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        view.addSubview(mainStackView)
        mainStackView.pin(.leading, to: .leading, of: view)
        mainStackView.pin(.top, to: .top, of: view)
        mainStackView.pin(.trailing, to: .trailing, of: view)
        bottomConstraint = mainStackView.pin(.bottom, to: .bottom, of: view)
        topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor, multiplier: 1).isActive = true
        
        // Dismiss keyboard on tap
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        // Listen to keyboard notifications
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillChangeFrameNotification(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        isFromPasteButton.layer.cornerRadius = isFromPasteButton.bounds.height / 2
    }

    
    // MARK: - Navigation
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // On small screens we hide the legal label when the keyboard is up, but it's important that the user sees it so
        // in those instances we don't make the keyboard come up automatically
        if !isIPhone5OrSmaller {
            mnemonicTextView.becomeFirstResponder()
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Updating
    @objc private func handleKeyboardWillChangeFrameNotification(_ notification: Notification) {
        guard let newHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else { return }
        bottomConstraint.constant = -newHeight // Negative due to how the constraint is set up
        restoreButtonBottomOffsetConstraint.constant = isIPhone6OrSmaller ? Values.smallSpacing : Values.largeSpacing
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleKeyboardWillHideNotification(_ notification: Notification) {
        bottomConstraint.constant = 0
        restoreButtonBottomOffsetConstraint.constant = 33
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: General
    @objc private func dismissKeyboard() {
        mnemonicTextView.resignFirstResponder()
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        let strings : String! = mnemonicTextView.text.lowercased()
//        let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
//        let words = strings.components(separatedBy: spaces)
//        if lastWordSeedStr == words.last! {
//            seedFlag = true
//        }else {
//            seedFlag = false
//        }
//        if words.count == 25 {
//            seedFlag = true
//            isFromRestoreButton.backgroundColor = Colors.bchatButtonColor
//        }else {
//            isFromRestoreButton.backgroundColor = Colors.bchatViewBackgroundColor
//        }
//        if words.count > 25 {
//            mnemonicTextView.text = txtViewStr
//        }else{
//            txtViewStr = mnemonicTextView.text.lowercased()
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "hidePlaceholderLabel"), object: nil)
//        }
//    }
    
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
            titleLabel.isHidden = true
            isFromRestoreButton.backgroundColor = UIColor(hex: 0x00BD40)
            isFromRestoreButton.setTitleColor(.white, for: .normal)
        }else {
            titleLabel.isHidden = false
            isFromRestoreButton.backgroundColor = UIColor(hex: 0x1C1C26)
            isFromRestoreButton.setTitleColor(.lightGray, for: .normal)
        }
//        lblcount.text = "\(words.count)/25"
        if words.count > 25 {
//            lblcount.text = "25/25"
            mnemonicTextView.text = txtViewStr
        }else{
            txtViewStr = mnemonicTextView.text.lowercased()
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
        
//        if textView.text == "" {
//            lblcount.text = "0/25"
//        }
    }
    
    func showError(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
        presentAlert(alert)
    }
    
    // MARK: Interaction
    @objc private func fromPasteSeedAction() {
        if let myString = UIPasteboard.general.string {
            mnemonicTextView.text = ""
            let strings : String! = myString
            let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let words = strings.components(separatedBy: spaces)
            fullLenthSeedStr = myString
            lastWordSeedStr = words.last!
            mnemonicTextView.insertText(myString)
        }
    }
    
    @objc private func isFromRestoreAction() {
        if seedFlag == false {
            self.showToastMsg(message: "Something went wrong.Please check your mnemonic and try again", seconds: 1.0)
        }else {
            self.isFromRestoreButton.isUserInteractionEnabled = false
            let strings : String! = mnemonicTextView.text.lowercased()
            let spaces = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
            let words = strings.components(separatedBy: spaces)
            print(words.count)
            if words.count > 25 {
                self.showToastMsg(message: "There appears to be an invalid word in your recovery phrase. Please check what you entered and try again.", seconds: 2.0)
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
