// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import NVActivityIndicatorView
import PromiseKit
import BChatUIKit

class ChatNewVC: BaseVC,UITextViewDelegate,UITextFieldDelegate  {
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.extraBoldOpenSans(ofSize: 24)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var topView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.cornerRadius = 16
        stackView.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    private lazy var innerViewTop: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 16
        stackView.backgroundColor = .clear
        return stackView
    }()
    private lazy var leftView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 16
        stackView.backgroundColor = UIColor(hex: 0x282836)
        return stackView
    }()
    private lazy var rightView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 16
        stackView.backgroundColor = UIColor(hex: 0x282836)
        return stackView
    }()
    private lazy var bottomView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x282836)
        stackView.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    private lazy var chatIdTextView: UITextView = {
        let result = UITextView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 16
        result.backgroundColor = .clear
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 14)
        return result
    }()
    private lazy var chatIdDetailsButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("YOUR_CHAT_ID_NEW", comment: ""), for: .normal)
        let image = UIImage(named: "ic_NewID")?.scaled(to: CGSize(width: 20.0, height: 20.0))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white // Set the tint color to white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 9)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(isChatIdDetailsButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var scannerImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Newqr", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scannerImageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        return imageView
    }()
    private lazy var letsBChatButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("LETS_BCHAT_NEW", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
        button.setTitleColor(UIColor(hex: 0x6E6E7C), for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(letsBChatButtonTapped), for: .touchUpInside)
        return button
    }()
    var placeholderLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "New Chat"
        self.titleLabel.text = NSLocalizedString("NEW_CHAT_NEW", comment: "")
        
        view.addSubViews(titleLabel)
        view.addSubViews(topView)
        view.addSubViews(bottomView)
        
        topView.addSubview(innerViewTop)
        topView.addSubview(letsBChatButton)
        innerViewTop.addSubview(rightView)
        innerViewTop.addSubview(leftView)
        leftView.addSubview(chatIdTextView)
        rightView.addSubview(scannerImg)
        bottomView.addSubview(chatIdDetailsButton)
        chatIdDetailsButton.addRightIcon(image: UIImage(named: "ic-Newarrow")!.withRenderingMode(.alwaysTemplate))
        chatIdDetailsButton.tintColor = Colors.greenColor
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            topView.heightAnchor.constraint(equalToConstant: 202),
        ])
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            innerViewTop.topAnchor.constraint(equalTo: topView.topAnchor, constant: 18),
            innerViewTop.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
            innerViewTop.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -18),
            letsBChatButton.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
            letsBChatButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -18),
            letsBChatButton.topAnchor.constraint(equalTo: innerViewTop.bottomAnchor, constant: 10),
            innerViewTop.heightAnchor.constraint(equalTo: letsBChatButton.heightAnchor, constant: 58),
            letsBChatButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -18),
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
            scannerImg.centerXAnchor.constraint(equalTo: rightView.centerXAnchor),
            scannerImg.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
            scannerImg.widthAnchor.constraint(equalToConstant: 28),
            scannerImg.heightAnchor.constraint(equalToConstant: 28),
        ])
        NSLayoutConstraint.activate([
            bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 32),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            bottomView.heightAnchor.constraint(equalToConstant: 48),
            bottomView.widthAnchor.constraint(equalToConstant: 202),
            chatIdDetailsButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 0),
            chatIdDetailsButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -0),
            chatIdDetailsButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -0),
            chatIdDetailsButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 0),
        ])
        //textView
        chatIdTextView.delegate = self
        chatIdTextView.textAlignment = .left
        chatIdTextView.returnKeyType = .done
        chatIdTextView.setPlaceholderChatNew()
        //Button Action
        letsBChatButton.isUserInteractionEnabled = false
        letsBChatButton.backgroundColor = UIColor(hex: 0x282836)
        letsBChatButton.setTitleColor(UIColor(hex: 0x6E6E7C), for: .normal)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomView.layer.cornerRadius = bottomView.frame.height / 2
    }
    
    // MARK: General
    @objc private func dismissKeyboard() {
        chatIdTextView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let str = textView.text!
        if str.count == 0 {
            letsBChatButton.isUserInteractionEnabled = false
            letsBChatButton.backgroundColor = UIColor(hex: 0x282836)
            letsBChatButton.setTitleColor(UIColor(hex: 0x6E6E7C), for: .normal)
            chatIdTextView.checkPlaceholderChatNew()
        }else {
            letsBChatButton.isUserInteractionEnabled = true
            letsBChatButton.backgroundColor = UIColor(hex: 0x00BD40)
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
    
    // MARK: Button Actions :-
    @objc private func letsBChatButtonTapped() {
        let text = chatIdTextView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        self.startNewDMIfPossible(with: text)
    }
    
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
    
    func performAction() {
        let text = chatIdTextView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        self.startNewDMIfPossible(with: text)
    }
    
    @objc func scannerImageViewTapped() {
        let vc = ScanNewVC()
        vc.newChatScanflag = false
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @objc func isChatIdDetailsButtonTapped() {
        let vc = MyAccountNewVC()
        vc.isNavigationBarHideInChatNewVC = true
        navigationController!.pushViewController(vc, animated: true)
    }
    
}

