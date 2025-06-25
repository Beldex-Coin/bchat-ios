// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import UIKit

class UserInfoPopUp: BaseVC {
    
    // MARK: - UIElements
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.smallBackGroundColor
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColorNew.cgColor
        return stackView
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_closeNew"), for: .normal)
        return button
    }()
    
    private lazy var messageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Message to ", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 18)
        button.setTitleColor(Colors.titleColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Copy BChat ID", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 18)
        button.setTitleColor(Colors.titleColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var thread: TSContactThread?
    var name: String?
    
    
    
    // MARK: - UIViewController life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(closeButton, messageButton, copyButton)
                
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            closeButton.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 22),
            closeButton.widthAnchor.constraint(equalToConstant: 22),
            
            messageButton.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 40),
            messageButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            messageButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            messageButton.heightAnchor.constraint(equalToConstant: 50),
            
            copyButton.topAnchor.constraint(equalTo: messageButton.bottomAnchor, constant: 8),
            copyButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            copyButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            copyButton.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -22),
            copyButton.heightAnchor.constraint(equalToConstant: 50),
            
        ])
        
        messageButton.setTitle("Message to \(name ?? "")", for: .normal)
        
    }
    
    
    @objc func show(_ thread: TSThread, with action: ConversationViewAction, highlightedMessageID: String?, animated: Bool) {
        DispatchMainThreadSafe {
            if let presentedVC = self.presentedViewController {
                presentedVC.dismiss(animated: false, completion: nil)
            }
        }
        let conversationVC = ConversationVC(thread: thread)
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        if let navController = UIWindow.keyWindow?.rootViewController as? UINavigationController {
            navController.view.layer.add(transition, forKey: kCATransition)
            navController.pushViewController(conversationVC, animated: true)
        }
        
    }
    
    // MARK: - UIButton actions
    
    @objc private func messageButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: false, completion: {
            self.show(self.thread!, with: ConversationViewAction.none, highlightedMessageID: nil, animated: true)
        })
    }
    
    @objc private func copyButtonTapped(_ sender: UIButton) {
        UIPasteboard.general.string = thread!.contactBChatID()
        let toast = UIAlertController(title: nil, message: "Your BChat ID copied to clipboard", preferredStyle: .alert)
        present(toast, animated: true)
        
        let duration = Int(1.0)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Double(duration) * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
            toast.dismiss(animated: true)
            self.dismiss(animated: true)
        })
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
