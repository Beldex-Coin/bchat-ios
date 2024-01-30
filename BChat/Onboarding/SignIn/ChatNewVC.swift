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
    private lazy var chatIDTextView: UITextView = {
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
        button.addTarget(self, action: #selector(ischatIdDetailsButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var scannerImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Newqr", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scannerimageViewTapped))
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
        leftView.addSubview(chatIDTextView)
        rightView.addSubview(scannerImg)
        bottomView.addSubview(chatIdDetailsButton)
        
        chatIDTextView.textAlignment = .left
        chatIDTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("ENTER_CHAT_ID_NEW", comment: "")
        placeholderLabel.numberOfLines = 0
        placeholderLabel.font = Fonts.OpenSans(ofSize: 14)
        placeholderLabel.sizeToFit()
        chatIDTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 2, y: 8)
        placeholderLabel.textColor = UIColor(hex: 0xA7A7BA)
        placeholderLabel.isHidden = !chatIDTextView.text.isEmpty
        
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
        ])
        NSLayoutConstraint.activate([
            rightView.topAnchor.constraint(equalTo: innerViewTop.topAnchor, constant: 0),
            rightView.bottomAnchor.constraint(equalTo: innerViewTop.bottomAnchor, constant: -0),
            rightView.trailingAnchor.constraint(equalTo: innerViewTop.trailingAnchor, constant: -0),
            rightView.widthAnchor.constraint(equalToConstant: 55),
        ])
        NSLayoutConstraint.activate([
            leftView.topAnchor.constraint(equalTo: innerViewTop.topAnchor, constant: 0),
            leftView.bottomAnchor.constraint(equalTo: innerViewTop.bottomAnchor, constant: -0),
            leftView.leadingAnchor.constraint(equalTo: innerViewTop.leadingAnchor, constant: 0),
            leftView.trailingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: -9),
        ])
        NSLayoutConstraint.activate([
            chatIDTextView.topAnchor.constraint(equalTo: leftView.topAnchor, constant: 10),
            chatIDTextView.bottomAnchor.constraint(equalTo: leftView.bottomAnchor, constant: -10),
            chatIDTextView.leadingAnchor.constraint(equalTo: leftView.leadingAnchor, constant: 10),
            chatIDTextView.trailingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: -10),
        ])
        NSLayoutConstraint.activate([
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
        ])
        NSLayoutConstraint.activate([
            chatIdDetailsButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 0),
            chatIdDetailsButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -0),
            chatIdDetailsButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -0),
            chatIdDetailsButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 0),
        ])
        
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
        chatIDTextView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !chatIDTextView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            performAction()
            return false
        }
        else if text.count == 0 {
            letsBChatButton.isUserInteractionEnabled = false
            letsBChatButton.backgroundColor = UIColor(hex: 0x282836)
            letsBChatButton.setTitleColor(UIColor(hex: 0x6E6E7C), for: .normal)
        }
        else {
            letsBChatButton.isUserInteractionEnabled = true
            letsBChatButton.backgroundColor = UIColor(hex: 0x00BD40)
            letsBChatButton.setTitleColor(.white, for: .normal)
            placeholderLabel.isHidden = !chatIDTextView.text.isEmpty
        }
        return true
    }
    
    
    // MARK: Button Actions :-
    @objc private func letsBChatButtonTapped() {
        let text = chatIDTextView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        self.startNewDMIfPossible(with: text)
    }
    
    fileprivate func startNewDMIfPossible(with onsNameOrPublicKey: String) {
        if ECKeyPair.isValidHexEncodedPublicKey(candidate: onsNameOrPublicKey) {
            startNewDM(with: onsNameOrPublicKey)
        } else {
            self.showToastMsg(message: NSLocalizedString("INVALID_BCHAT_ID_NEW", comment: ""), seconds: 1.0)
        }
    }
    private func startNewDM(with bchatID: String) {
        let thread = TSContactThread.getOrCreateThread(contactBChatID: bchatID)
        presentingViewController?.dismiss(animated: true, completion: nil)
        SignalApp.shared().presentConversation(for: thread, action: .compose, animated: false)
    }
    
    func performAction() {
        let text = chatIDTextView.text?.trimmingCharacters(in: .whitespaces) ?? ""
        self.startNewDMIfPossible(with: text)
    }
    
    @objc func scannerimageViewTapped() {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScannerQRVC") as! ScannerQRVC
        vc.newChatScanflag = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func ischatIdDetailsButtonTapped() {
        let vc = MyAccountNewVC()
        vc.isNavigationBarHideInChatNewVC = true
        navigationController!.pushViewController(vc, animated: true)
    }
    
    // MARK: - Navigation
    @objc func profilePictureImageTapped() {
        
    }
    
    @objc func shareButtonTapped() {
        let qrCode = QRCode.generate(for: getUserHexEncodedPublicKey(), hasBackground: true)
        let shareVC = UIActivityViewController(activityItems: [ qrCode ], applicationActivities: nil)
        self.navigationController!.present(shareVC, animated: true, completion: nil)
    }
    
    
}
