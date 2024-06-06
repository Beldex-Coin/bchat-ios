// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import NVActivityIndicatorView
import PromiseKit
import BChatUIKit

class ChatNewVC: BaseVC  {
    
    /// Title Label
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.textColor
        result.font = Fonts.extraBoldOpenSans(ofSize: 24)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// Top Background View
    private lazy var topBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.viewBackgroundColorSocialGroup
        stackView.layer.cornerRadius = 16
        stackView.layer.borderColor = Colors.borderColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    /// Inner View Top
    private lazy var innerViewTop: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 16
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    /// Left View
    private lazy var leftView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 16
        stackView.backgroundColor = Colors.backgroundViewColor
        return stackView
    }()
    
    /// Right View
    private lazy var rightView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 16
        stackView.backgroundColor = Colors.backgroundViewColor
        return stackView
    }()
    
    /// Bottom Background View
    private lazy var bottomBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.backgroundViewColor
        stackView.layer.borderColor = Colors.borderColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    /// Chat Id TextView
    private lazy var chatIdTextView: UITextView = {
        let result = UITextView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 16
        result.backgroundColor = .clear
        result.font = Fonts.OpenSans(ofSize: 14)
        return result
    }()
    
    /// Chat Id Details Button
    private lazy var chatIdDetailsButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("YOUR_CHAT_ID_NEW", comment: ""), for: .normal)
        let logoImage = isLightMode ? "ic_yourChatid_details" : "ic_NewID"
        let image = UIImage(named: logoImage)?.scaled(to: CGSize(width: 16, height: 13))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white // Set the tint color to white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 9)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.backgroundViewColor
        button.setTitleColor(Colors.textColor, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(chatIdDetailsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// Scanner Image
    private lazy var scannerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_scanner_dark" : "ic_Newqr"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scannerImageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    
    /// Lets BChat Button
    private lazy var letsBChatButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("LETS_BCHAT_NEW", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.backgroundViewColor
        button.setTitleColor(Colors.buttonTextColor, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(letsBChatButtonTapped), for: .touchUpInside)
        return button
    }()
    var placeholderLabel : UILabel!
    
    
    // MARK: - UIViewController life cycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorSocialGroup
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "New Chat"
        self.titleLabel.text = NSLocalizedString("NEW_CHAT_NEW", comment: "")
        
        view.addSubViews(titleLabel)
        view.addSubViews(topBackgroundView)
        view.addSubViews(bottomBackgroundView)
        
        topBackgroundView.addSubview(innerViewTop)
        topBackgroundView.addSubview(letsBChatButton)
        innerViewTop.addSubview(rightView)
        innerViewTop.addSubview(leftView)
        leftView.addSubview(chatIdTextView)
        rightView.addSubview(scannerImage)
        bottomBackgroundView.addSubview(chatIdDetailsButton)
        chatIdDetailsButton.addRightIcon(image: UIImage(named: "ic-Newarrow")!.withRenderingMode(.alwaysTemplate))
        chatIdDetailsButton.tintColor = Colors.greenColor
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
           
            topBackgroundView.heightAnchor.constraint(equalToConstant: 202),
            topBackgroundView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            innerViewTop.topAnchor.constraint(equalTo: topBackgroundView.topAnchor, constant: 18),
            innerViewTop.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 13),
            innerViewTop.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -13),
            letsBChatButton.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 13),
            letsBChatButton.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -13),
            letsBChatButton.topAnchor.constraint(equalTo: innerViewTop.bottomAnchor, constant: 10),
            innerViewTop.heightAnchor.constraint(equalTo: letsBChatButton.heightAnchor, constant: 58),
            letsBChatButton.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: -18),
            rightView.topAnchor.constraint(equalTo: innerViewTop.topAnchor, constant: 0),
            rightView.bottomAnchor.constraint(equalTo: innerViewTop.bottomAnchor, constant: -0),
            rightView.trailingAnchor.constraint(equalTo: innerViewTop.trailingAnchor, constant: -0),
            rightView.widthAnchor.constraint(equalToConstant: 55),
            leftView.topAnchor.constraint(equalTo: innerViewTop.topAnchor, constant: 0),
            leftView.bottomAnchor.constraint(equalTo: innerViewTop.bottomAnchor, constant: -0),
            leftView.leadingAnchor.constraint(equalTo: innerViewTop.leadingAnchor, constant: 0),
            leftView.trailingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: -9),
            chatIdTextView.topAnchor.constraint(equalTo: leftView.topAnchor, constant: 10),
            chatIdTextView.bottomAnchor.constraint(equalTo: leftView.bottomAnchor, constant: -10),
            chatIdTextView.leadingAnchor.constraint(equalTo: leftView.leadingAnchor, constant: 10),
            chatIdTextView.trailingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: -10),
            scannerImage.centerXAnchor.constraint(equalTo: rightView.centerXAnchor),
            scannerImage.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
            scannerImage.widthAnchor.constraint(equalToConstant: 28),
            scannerImage.heightAnchor.constraint(equalToConstant: 28),
          
            bottomBackgroundView.topAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: 32),
            bottomBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            bottomBackgroundView.heightAnchor.constraint(equalToConstant: 48),
            bottomBackgroundView.widthAnchor.constraint(equalToConstant: 202),
            chatIdDetailsButton.leadingAnchor.constraint(equalTo: bottomBackgroundView.leadingAnchor, constant: 0),
            chatIdDetailsButton.trailingAnchor.constraint(equalTo: bottomBackgroundView.trailingAnchor, constant: -0),
            chatIdDetailsButton.bottomAnchor.constraint(equalTo: bottomBackgroundView.bottomAnchor, constant: -0),
            chatIdDetailsButton.topAnchor.constraint(equalTo: bottomBackgroundView.topAnchor, constant: 0),
        ])
        //textView
        chatIdTextView.delegate = self
        chatIdTextView.textAlignment = .left
        chatIdTextView.returnKeyType = .done
        chatIdTextView.setPlaceholderChatNew()
        //Button Action
        letsBChatButton.isUserInteractionEnabled = false
        letsBChatButton.backgroundColor = Colors.backgroundViewColor
        letsBChatButton.setTitleColor(Colors.buttonTextColor, for: .normal)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /// View Did Layout Subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomBackgroundView.layer.cornerRadius = bottomBackgroundView.frame.height / 2
    }
    
    /// View will appear
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /// View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: General
    @objc private func dismissKeyboard() {
        chatIdTextView.resignFirstResponder()
    }
    
    // MARK: Button Actions :-
    @objc private func letsBChatButtonTapped() {
        let text = chatIdTextView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        self.startNewDMIfPossible(with: text)
    }
    
    /// Start New DM If Possible
    fileprivate func startNewDMIfPossible(with bnsNameOrPublicKey: String) {
        if ECKeyPair.isValidHexEncodedPublicKey(candidate: bnsNameOrPublicKey) {
            startNewDM(with: bnsNameOrPublicKey)
        } else {
            ModalActivityIndicatorViewController.present(fromViewController: navigationController!, canCancel: false) { [weak self] modalActivityIndicator in
                SnodeAPI.getBChatID(for: bnsNameOrPublicKey).done { bchatID in
                    modalActivityIndicator.dismiss {
                        self?.startNewDM(with: bchatID)
                    }
                }.catch { error in
                    modalActivityIndicator.dismiss {
                        var messageOrNil: String?
                        if let error = error as? SnodeAPI.Error {
                            switch error {
                            case .decryptionFailed, .hashingFailed, .validationFailed: messageOrNil = error.errorDescription
                            default: break
                            }
                        }
                        let message = messageOrNil ?? Alert.Alert_BChat_Invalid_Id_or_BNS_Name
                        _ = CustomAlertController.alert(title: Alert.Alert_BChat_Error, message: String(format: message ) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
                        })
                    }
                }
            }
        }
    }
    
    private func startNewDM(with bchatID: String) {
        let thread = TSContactThread.getOrCreateThread(contactBChatID: bchatID)
        presentingViewController?.dismiss(animated: true, completion: nil)
        SignalApp.shared().presentConversation(for: thread, action: .compose, animated: false)
    }
    
    /// Perform Action
    func performAction() {
        let text = chatIdTextView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        self.startNewDMIfPossible(with: text)
    }
    
    /// Scanner Image View Tapped
    @objc func scannerImageViewTapped() {
        let vc = ScanNewVC()
        vc.newChatScanflag = false
        navigationController!.pushViewController(vc, animated: true)
    }
    
    /// Chat Id Details Button Tapped
    @objc func chatIdDetailsButtonTapped() {
        let vc = MyAccountViewController()
        vc.isNavigationBarHideInChatNewVC = true
        navigationController!.pushViewController(vc, animated: true)
    }
}

// MARK: - UITextViewDelegate methods

extension ChatNewVC: UITextViewDelegate {
    /// UI Text View Delegate
    func textViewDidChange(_ textView: UITextView) {
        let str = textView.text!
        if str.count == 0 {
            letsBChatButton.isUserInteractionEnabled = false
            letsBChatButton.backgroundColor = Colors.backgroundViewColor
            letsBChatButton.setTitleColor(Colors.buttonTextColor, for: .normal)
            chatIdTextView.checkPlaceholderChatNew()
        } else {
            letsBChatButton.isUserInteractionEnabled = true
            letsBChatButton.backgroundColor = Colors.greenColor
            letsBChatButton.setTitleColor(.white, for: .normal)
            chatIdTextView.checkPlaceholderChatNew()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            performAction()
            return false
        }
        return true
    }
}

