// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class MessageDetailsVC: BaseVC {
    
    
    private lazy var failedView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColorNew.cgColor
        return stackView
    }()
    
    private lazy var failedLabel: UILabel = {
        let result = UILabel()
        result.text = "Failed"
        result.textColor = Colors.bothRedColor
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var timeLabelFailedView: UILabel = {
        let result = UILabel()
        result.text = "May 22 2024, 4:21:50 PM GMT +5.30"
        result.textColor = Colors.textFieldPlaceHolderColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.textAlignment = .right
        return result
    }()
    
    private lazy var errorTitleLabel: UILabel = {
        let result = UILabel()
        result.text = "Error"
        result.textColor = Colors.titleColor3
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var errorTypeLabel: UILabel = {
        let result = UILabel()
        result.text = "No network connection"
        result.textColor = Colors.textFieldPlaceHolderColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.textAlignment = .right
        return result
    }()
    
    private lazy var resendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Resend", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var successView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColorNew.cgColor
        return stackView
    }()
    
    private lazy var sentLabel: UILabel = {
        let result = UILabel()
        result.text = "Sent"
        result.textColor = Colors.titleColor3
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var timeLabelSuccessView: UILabel = {
        let result = UILabel()
        result.text = "May 22 2024, 4:21:50 PM GMT +5.30"
        result.textColor = Colors.textFieldPlaceHolderColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.textAlignment = .right
        return result
    }()
    
    
    private let viewItem: ConversationViewItem
    let thread: TSThread
    
    init(with viewItem: ConversationViewItem, thread: TSThread) {
        self.viewItem = viewItem
        self.thread = thread
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Message Detail"
        view.backgroundColor = Colors.mainBackGroundColor2
        
        
        view.addSubViews(failedView, successView)
        failedView.addSubViews(failedLabel, timeLabelFailedView, errorTitleLabel, errorTypeLabel, resendButton)
        successView.addSubViews(sentLabel, timeLabelSuccessView)
        
        NSLayoutConstraint.activate([
            failedView.topAnchor.constraint(equalTo: view.topAnchor, constant: 19),
            failedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            failedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            
            failedLabel.topAnchor.constraint(equalTo: failedView.topAnchor, constant: 28),
            failedLabel.leadingAnchor.constraint(equalTo: failedView.leadingAnchor, constant: 23),
            timeLabelFailedView.topAnchor.constraint(equalTo: failedView.topAnchor, constant: 28),
            timeLabelFailedView.leadingAnchor.constraint(equalTo: failedLabel.trailingAnchor, constant: 8),
            timeLabelFailedView.trailingAnchor.constraint(equalTo: failedView.trailingAnchor, constant: -23),
            errorTitleLabel.topAnchor.constraint(equalTo: failedLabel.bottomAnchor, constant: 13),
            errorTitleLabel.leadingAnchor.constraint(equalTo: failedView.leadingAnchor, constant: 23),
            errorTypeLabel.centerYAnchor.constraint(equalTo: errorTitleLabel.centerYAnchor),
            errorTypeLabel.leadingAnchor.constraint(equalTo: errorTitleLabel.trailingAnchor, constant: 8),
            errorTypeLabel.trailingAnchor.constraint(equalTo: failedView.trailingAnchor, constant: -23),
            resendButton.heightAnchor.constraint(equalToConstant: 52),
            resendButton.widthAnchor.constraint(equalToConstant: 148),
            resendButton.centerXAnchor.constraint(equalTo: failedView.centerXAnchor),
            resendButton.topAnchor.constraint(equalTo: errorTypeLabel.bottomAnchor, constant: 27),
            resendButton.bottomAnchor.constraint(equalTo: failedView.bottomAnchor, constant: -25),
                        
            successView.topAnchor.constraint(equalTo: view.topAnchor, constant: 19),
            successView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            successView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            sentLabel.topAnchor.constraint(equalTo: successView.topAnchor, constant: 20),
            sentLabel.leadingAnchor.constraint(equalTo: successView.leadingAnchor, constant: 23),
            sentLabel.bottomAnchor.constraint(equalTo: successView.bottomAnchor, constant: -20),
            timeLabelSuccessView.leadingAnchor.constraint(equalTo: sentLabel.trailingAnchor, constant: 8),
            timeLabelSuccessView.trailingAnchor.constraint(equalTo: successView.trailingAnchor, constant: -23),
            timeLabelSuccessView.centerYAnchor.constraint(equalTo: sentLabel.centerYAnchor),
            
        ])
        
        
        
        if let message = self.viewItem.interaction as? TSOutgoingMessage {
            if message.messageState == .failed {
                self.successView.isHidden = true
                self.failedView.isHidden = false
                self.timeLabelFailedView.text = self.customDateFormate(message: message)
                self.errorTypeLabel.text = message.mostRecentFailureText
            } else {
                self.failedView.isHidden = true
                self.successView.isHidden = false
                self.timeLabelSuccessView.text = self.customDateFormate(message: message)
            }
        }
        
    }
    
    
    
    func customDateFormate(message: TSOutgoingMessage) -> String {
        let date = message.dateForUI()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d yyyy, h:mm:ss a z"
        dateFormatter.timeZone = TimeZone(identifier: "GMT+5:30")
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    
    @objc private func resendButtonTapped(_ sender: UIButton) {
        let thread = self.thread
        let message = VisibleMessage.from((self.viewItem.interaction as? TSOutgoingMessage)!)
        Storage.write { transaction in
            var attachments: [TSAttachmentStream] = []
            (self.viewItem.interaction as? TSOutgoingMessage)!.attachmentIds.forEach { attachmentID in
                guard let attachmentID = attachmentID as? String else { return }
                let attachment = TSAttachment.fetch(uniqueId: attachmentID, transaction: transaction)
                guard let stream = attachment as? TSAttachmentStream else { return }
                attachments.append(stream)
            }
            MessageSender.prep(attachments, for: message, using: transaction)
            MessageSender.send(message, in: thread, using: transaction)
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }


}
