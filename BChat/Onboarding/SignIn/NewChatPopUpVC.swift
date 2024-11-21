// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewChatPopUpVC: BaseVC {
    
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var mainBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor
        stackView.layer.cornerRadius = 20
        stackView.layer.borderColor = Colors.newBorderColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    private lazy var chatIdTextView: UITextView = {
        let result = UITextView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = Values.buttonRadius
        result.backgroundColor = .clear
        result.font = Fonts.OpenSans(ofSize: 14)
        return result
    }()
    
    private lazy var chatIdView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = Values.buttonRadius
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.borderWidth = 1
        result.layer.borderColor = Colors.borderColorNew.cgColor
        return result
    }()
    
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .fill
        result.distribution = .fillEqually
        result.spacing = 8
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    private lazy var letsBChatButton: UIButton = {
        let button = UIButton()
        button.setTitle("Let’s Bchat", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(letsBChatButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 0.5
        button.layer.borderColor = Colors.bothGreenColor.cgColor
        button.backgroundColor = Colors.bothGreenWithAlpha10
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        
        view.addSubview(mainBackgroundView)
        mainBackgroundView.addSubViews(titleLabel, chatIdView, buttonStackView)
        chatIdView.addSubview(chatIdTextView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(letsBChatButton)
        
        titleLabel.text = "New Chat"
        
        NSLayoutConstraint.activate([
            mainBackgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            mainBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            
            titleLabel.topAnchor.constraint(equalTo: mainBackgroundView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: mainBackgroundView.centerXAnchor),
            
            chatIdView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            chatIdView.leadingAnchor.constraint(equalTo: mainBackgroundView.leadingAnchor, constant: 15),
            chatIdView.trailingAnchor.constraint(equalTo: mainBackgroundView.trailingAnchor, constant: -15),
            chatIdView.heightAnchor.constraint(equalToConstant: 115),
            
            chatIdTextView.topAnchor.constraint(equalTo: chatIdView.topAnchor, constant: 10),
            chatIdTextView.bottomAnchor.constraint(equalTo: chatIdView.bottomAnchor, constant: -10),
            chatIdTextView.leadingAnchor.constraint(equalTo: chatIdView.leadingAnchor, constant: 10),
            chatIdTextView.trailingAnchor.constraint(equalTo: chatIdView.trailingAnchor, constant: -10),
            
            buttonStackView.topAnchor.constraint(equalTo: chatIdView.bottomAnchor, constant: 12),
            buttonStackView.leadingAnchor.constraint(equalTo: mainBackgroundView.leadingAnchor, constant: 15),
            buttonStackView.trailingAnchor.constraint(equalTo: mainBackgroundView.trailingAnchor, constant: -15),
            buttonStackView.bottomAnchor.constraint(equalTo: mainBackgroundView.bottomAnchor, constant: -13),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        
        chatIdTextView.delegate = self
        chatIdTextView.textAlignment = .left
        chatIdTextView.returnKeyType = .done
        chatIdTextView.setPlaceholderChatNew()
        
        letsBChatButton.isUserInteractionEnabled = false
        letsBChatButton.backgroundColor = Colors.backgroundViewColor
        letsBChatButton.setTitleColor(Colors.buttonTextColor, for: .normal)
    }
    
    
    
    
    
    
    @objc private func letsBChatButtonTapped() {
        let text = chatIdTextView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        self.startNewDMIfPossible(with: text)
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    func performAction() {
        let text = chatIdTextView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        self.startNewDMIfPossible(with: text)
    }

    /// Start New DM If Possible
    fileprivate func startNewDMIfPossible(with bnsNameOrPublicKey: String) {
        let newChatId = bnsNameOrPublicKey.lowercased()
        if ECKeyPair.isValidHexEncodedPublicKey(candidate: newChatId) {
            startNewDM(with: newChatId)
        } else {
            ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { [weak self] modalActivityIndicator in
                SnodeAPI.getBChatID(for: newChatId).done { bchatID in
                    modalActivityIndicator.dismiss {
                        self?.startNewDM(with: bchatID)
                        BNSBool.bnsName = newChatId
                        BNSBool.isFromBNS = true
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
                        self?.chatIdView.layer.borderColor = Colors.bothRedColor.cgColor
                        self?.letsBChatButton.isUserInteractionEnabled = false
                        self?.letsBChatButton.backgroundColor = Colors.backgroundViewColor
                        self?.letsBChatButton.setTitleColor(Colors.buttonTextColor, for: .normal)
                        BNSBool.bnsName = ""
                        BNSBool.isFromBNS = false
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

}


extension NewChatPopUpVC: UITextViewDelegate {
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
            letsBChatButton.backgroundColor = Colors.bothGreenColor
            letsBChatButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
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
