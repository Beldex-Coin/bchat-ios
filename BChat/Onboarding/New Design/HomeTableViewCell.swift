// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class HomeTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.setUPLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    var isShowingGlobalSearchResult = false
    var threadViewModel: ThreadViewModel! {
        didSet {
            isShowingGlobalSearchResult ? updateForSearchResult() : update()
        }
    }
        
    
    lazy var backGroundView: UIView = {
       let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = .clear//Colors.cellGroundColor3
        View.layer.cornerRadius = 36
       return View
   }()
    
    lazy var iconImageView = ProfilePictureView()
    
    lazy var nameLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.titleColor3
       result.font = Fonts.boldOpenSans(ofSize: 16)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var lastMessageLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.titleColor3
       result.font = Fonts.OpenSans(ofSize: 12)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    
    lazy var messageCountAndDateStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .trailing
        result.distribution = .fill
        result.spacing = 4
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var messageCountLabel: UILabel = {
       let result = PaddingLabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
       result.font = Fonts.boldOpenSans(ofSize: 11)
       result.textAlignment = .center
       result.translatesAutoresizingMaskIntoConstraints = false
        result.paddingTop = 3
        result.paddingBottom = 3
        result.paddingLeft = 5
        result.paddingRight = 5
        result.layer.masksToBounds = true
        result.layer.cornerRadius = 11
        result.backgroundColor = Colors.bothGreenColor
       return result
   }()
    
    lazy var dateLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.textFieldPlaceHolderColor
       result.font = Fonts.OpenSans(ofSize: 12)
       result.textAlignment = .center
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var pinImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 28)
        result.set(.height, to: 28)
        result.layer.cornerRadius = 14
        result.layer.masksToBounds = true
        result.contentMode = .center
        return result
    }()
    
    
    func setUPLayout() {
        
        contentView.addSubview(backGroundView)
        contentView.addSubview(pinImageView)
        pinImageView.image = UIImage(named: "ic_pinned")
        backGroundView.addSubViews(iconImageView, nameLabel, lastMessageLabel, messageCountAndDateStackView)
        
        messageCountAndDateStackView.addArrangedSubview(messageCountLabel)
        messageCountAndDateStackView.addArrangedSubview(dateLabel)
        
        
        let profilePictureViewSize = CGFloat(42)
        iconImageView.set(.width, to: profilePictureViewSize)
        iconImageView.set(.height, to: profilePictureViewSize)
        iconImageView.size = profilePictureViewSize
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 21
        
        
        NSLayoutConstraint.activate([
            backGroundView.heightAnchor.constraint(equalToConstant: 72),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            
            pinImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            pinImageView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: 14),
            
            iconImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            
            nameLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 17),
            
            lastMessageLabel.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor),
            lastMessageLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 17),
            lastMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: messageCountAndDateStackView.leadingAnchor, constant: -8),
            
            messageCountLabel.heightAnchor.constraint(equalToConstant: 22),
            messageCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 22),
            
            messageCountAndDateStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            messageCountAndDateStackView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 15),
            messageCountAndDateStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -15),
            messageCountAndDateStackView.widthAnchor.constraint(equalToConstant: 56),
            
        ])
    }
    
    
    // MARK: Updating for search results
    private func updateForSearchResult() {
        AssertIsOnMainThread()
        guard let thread = threadViewModel?.threadRecord else { return }
        iconImageView.update(for: thread)
//        isPinnedIcon.isHidden = true
        messageCountLabel.isHidden = true
//        hasMentionView.isHidden = true
    }
    
    public func configureForRecent() {
        nameLabel.attributedText = NSMutableAttributedString(string: getDisplayName(), attributes: [.foregroundColor:Colors.text])
//        bottomLabelStackView.isHidden = false
        let snippet = String(format: NSLocalizedString("RECENT_SEARCH_LAST_MESSAGE_DATETIME", comment: ""), DateUtil.formatDate(forDisplay: threadViewModel.lastMessageDate))
        lastMessageLabel.attributedText = NSMutableAttributedString(string: snippet, attributes: [.foregroundColor:Colors.text.withAlphaComponent(Values.lowOpacity)])
        dateLabel.isHidden = true
    }
    
    
    public func configure(snippet: String?, searchText: String, message: TSMessage? = nil) {
        let normalizedSearchText = searchText.lowercased()
        if let messageTimestamp = message?.timestamp, let snippet = snippet {
            // Message
            let messageDate = NSDate.ows_date(withMillisecondsSince1970: messageTimestamp)
            nameLabel.attributedText = NSMutableAttributedString(string: getDisplayName(), attributes: [.foregroundColor:Colors.text])
            dateLabel.isHidden = false
            dateLabel.text = DateUtil.formatDate(forDisplay: messageDate)
//            bottomLabelStackView.isHidden = false
            var rawSnippet = snippet
            if let message = message, let name = getMessageAuthorName(message: message) {
                rawSnippet = "\(name): \(snippet)"
            }
            lastMessageLabel.attributedText = getHighlightedSnippet(snippet: rawSnippet, searchText: normalizedSearchText, fontSize: Values.smallFontSize)
        } else {
            // Contact
            if threadViewModel.isGroupThread, let thread = threadViewModel.threadRecord as? TSGroupThread {
                nameLabel.attributedText = getHighlightedSnippet(snippet: getDisplayName(), searchText: normalizedSearchText, fontSize: Values.mediumFontSize)
                let context: Contact.Context = thread.isOpenGroup ? .openGroup : .regular
                var rawSnippet: String = ""
                thread.groupModel.groupMemberIds.forEach{ id in
                    if let displayName = Storage.shared.getContact(with: id)?.displayName(for: context) {
                        if !rawSnippet.isEmpty {
                            rawSnippet += ", \(displayName)"
                        }
                        if displayName.lowercased().contains(normalizedSearchText) {
                            rawSnippet = displayName
                        }
                    }
                }
                if rawSnippet.isEmpty {
//                    bottomLabelStackView.isHidden = true
                } else {
//                    bottomLabelStackView.isHidden = false
                    lastMessageLabel.attributedText = getHighlightedSnippet(snippet: rawSnippet, searchText: normalizedSearchText, fontSize: Values.smallFontSize)
                }
            } else {
                nameLabel.attributedText = getHighlightedSnippet(snippet: getDisplayNameForSearch(threadViewModel.contactBChatID!), searchText: normalizedSearchText, fontSize: Values.mediumFontSize)
//                bottomLabelStackView.isHidden = true
            }
            dateLabel.isHidden = true
        }
    }
    
    private func getHighlightedSnippet(snippet: String, searchText: String, fontSize: CGFloat) -> NSMutableAttributedString {
        guard snippet != NSLocalizedString("NOTE_TO_SELF", comment: "") else {
            return NSMutableAttributedString(string: snippet, attributes: [.foregroundColor:Colors.text])
        }

        let result = NSMutableAttributedString(string: snippet, attributes: [.foregroundColor:Colors.text.withAlphaComponent(Values.lowOpacity)])
        let normalizedSnippet = snippet.lowercased() as NSString

        guard normalizedSnippet.contains(searchText) else { return result }

        let range = normalizedSnippet.range(of: searchText)
        result.addAttribute(.foregroundColor, value: Colors.text, range: range)
        result.addAttribute(.font, value: Fonts.boldOpenSans(ofSize: fontSize), range: range)
        return result
    }
    
    // MARK: Updating
    private func update() {
        AssertIsOnMainThread()
        guard let thread = threadViewModel?.threadRecord else { return }
//        backgroundColor = threadViewModel.isPinned ? Colors.cellPinned : Colors.cellBackgroundColor

        if thread.isBlocked() {
//            accentLineView.backgroundColor = Colors.destructive
//            accentLineView.alpha = 1
        }
        else {
//            accentLineView.backgroundColor = Colors.accent
//            accentLineView.alpha = threadViewModel.hasUnreadMessages ? 1 : 0.0001 // Setting the alpha to exactly 0 causes an issue on iOS 12
        }
//        isPinnedIcon.isHidden = !threadViewModel.isPinned
        messageCountLabel.isHidden = !threadViewModel.hasUnreadMessages
        backgroundColor = .clear
        if !messageCountLabel.isHidden {
            backGroundView.backgroundColor = Colors.cellGroundColor3
        } else {
            backGroundView.backgroundColor = .clear
        }
        
        pinImageView.isHidden = true
        if threadViewModel.isPinned {
            backGroundView.backgroundColor = Colors.cellGroundColor3
            pinImageView.isHidden = false
        }
        
        let unreadCount = threadViewModel.unreadCount
        messageCountLabel.text = unreadCount < 10000 ? "\(unreadCount)" : "9999+"
        let fontSize = (unreadCount < 10000) ? Values.verySmallFontSize : 8
        messageCountLabel.font = Fonts.boldOpenSans(ofSize: fontSize)
//        hasMentionView.isHidden = !(threadViewModel.hasUnreadMentions && thread.isGroupThread())
        iconImageView.update(for: thread)
        nameLabel.text = getDisplayName()
        dateLabel.text = DateUtil.formatDate(forDisplay: threadViewModel.lastMessageDate)
        if SSKEnvironment.shared.typingIndicators.typingRecipientId(forThread: thread) != nil {
            lastMessageLabel.text = ""
//            typingIndicatorView.isHidden = false
//            typingIndicatorView.startAnimation()
        } else {
            lastMessageLabel.attributedText = getSnippet()
//            typingIndicatorView.isHidden = true
//            typingIndicatorView.stopAnimation()
        }
//        statusIndicatorView.backgroundColor = nil
        let lastMessage = threadViewModel.lastMessageForInbox
//        if let lastMessage = lastMessage as? TSOutgoingMessage, !lastMessage.isCallMessage {
//
//            let status = MessageRecipientStatusUtils.recipientStatus(outgoingMessage: lastMessage)
//
//            switch status {
//                case .uploading, .sending:
//                    statusIndicatorView.image = #imageLiteral(resourceName: "CircleDotDotDot").withRenderingMode(.alwaysTemplate)
//                    statusIndicatorView.tintColor = Colors.text
//
//                case .sent, .skipped, .delivered:
//                    statusIndicatorView.image = #imageLiteral(resourceName: "CircleCheck").withRenderingMode(.alwaysTemplate)
//                    statusIndicatorView.tintColor = Colors.text
//
//                case .read:
//                    statusIndicatorView.image = isLightMode ? #imageLiteral(resourceName: "FilledCircleCheckLightMode") : #imageLiteral(resourceName: "FilledCircleCheckDarkMode")
//                    statusIndicatorView.tintColor = nil
//                    statusIndicatorView.backgroundColor = (isLightMode ? .black : .white)
//
//                case .failed:
//                    statusIndicatorView.image = #imageLiteral(resourceName: "message_status_failed").withRenderingMode(.alwaysTemplate)
//                    statusIndicatorView.tintColor = Colors.destructive
//            }
//
//            statusIndicatorView.isHidden = false
//        }
//        else {
//            statusIndicatorView.isHidden = true
//        }
    }
    
    private func getMessageAuthorName(message: TSMessage) -> String? {
        guard threadViewModel.isGroupThread else { return nil }
        if let incomingMessage = message as? TSIncomingMessage {
            return Storage.shared.getContact(with: incomingMessage.authorId)?.displayName(for: .regular) ?? "Anonymous"
        }
        return nil
    }
    
    private func getDisplayNameForSearch(_ bchatID: String) -> String {
        if threadViewModel.threadRecord.isNoteToSelf() {
            return NSLocalizedString("NOTE_TO_SELF", comment: "")
        } else {
            var result = bchatID
            if let contact = Storage.shared.getContact(with: bchatID), let name = contact.name {
                result = name
                if let nickname = contact.nickname { result += "(\(nickname))"}
            }
            return result
        }
    }
    
    private func getDisplayName() -> String {
        if threadViewModel.isGroupThread {
            if threadViewModel.name.isEmpty {
                return "Unknown Group"
            }
            else {
                return threadViewModel.name
            }
        }
        else {
            if threadViewModel.threadRecord.isNoteToSelf() {
                return NSLocalizedString("NOTE_TO_SELF", comment: "")
            }
            else {
                let hexEncodedPublicKey: String = threadViewModel.contactBChatID!
                let displayName: String = (Storage.shared.getContact(with: hexEncodedPublicKey)?.displayName(for: .regular) ?? hexEncodedPublicKey)
                let middleTruncatedHexKey: String = "\(hexEncodedPublicKey.prefix(4))...\(hexEncodedPublicKey.suffix(4))"
                return (displayName == hexEncodedPublicKey ? middleTruncatedHexKey : displayName)
            }
        }
    }
    
    private func getSnippet() -> NSMutableAttributedString {
        let result = NSMutableAttributedString()
        if threadViewModel.isMuted {
            result.append(NSAttributedString(string: "\u{e067}  ", attributes: [ .font : UIFont.ows_elegantIconsFont(10), .foregroundColor : Colors.unimportant ]))
        } else if threadViewModel.isOnlyNotifyingForMentions {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(named: "NotifyMentions.png")?.asTintedImage(color: Colors.unimportant)
            imageAttachment.bounds = CGRect(x: 0, y: -2, width: Values.smallFontSize, height: Values.smallFontSize)
            let imageString = NSAttributedString(attachment: imageAttachment)
            result.append(imageString)
            result.append(NSAttributedString(string: "  ", attributes: [ .font : UIFont.ows_elegantIconsFont(10), .foregroundColor : Colors.unimportant ]))
        }
        let font = threadViewModel.hasUnreadMessages ? Fonts.OpenSans(ofSize: Values.smallFontSize) : Fonts.OpenSans(ofSize: Values.smallFontSize)
        if threadViewModel.isGroupThread, let message = threadViewModel.lastMessageForInbox as? TSMessage, let name = getMessageAuthorName(message: message) {
            result.append(NSAttributedString(string: "\(name): ", attributes: [ .font : font, .foregroundColor : Colors.text ]))
        }
        if let rawSnippet = threadViewModel.lastMessageText {
            let snippet = MentionUtilities.highlightMentions(in: rawSnippet, threadID: threadViewModel.threadRecord.uniqueId!)
            result.append(NSAttributedString(string: snippet, attributes: [ .font : font, .foregroundColor : Colors.text ]))
        }
        return result
    }

}






class MessageRequestCollectionViewCell: UICollectionViewCell {


    lazy var profileImageView = ProfilePictureView()
//    UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleAspectFit
//        imageView.layer.cornerRadius = 22
//        imageView.clipsToBounds = true
//        imageView.image = UIImage(named: "ic_test", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
//        return imageView
//    }()
    
    
    lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_close_new"), for: .normal)
        return button
    }()
    
    lazy var nameLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.titleColor3
       result.font = Fonts.boldOpenSans(ofSize: 12)
       result.textAlignment = .center
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    var removeCallback: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(removeButton)
        contentView.addSubview(nameLabel)
        
        let profilePictureViewSize = CGFloat(44)
        profileImageView.set(.width, to: profilePictureViewSize)
        profileImageView.set(.height, to: profilePictureViewSize)
        profileImageView.size = profilePictureViewSize
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 22
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            profileImageView.heightAnchor.constraint(equalToConstant: 44),
            profileImageView.widthAnchor.constraint(equalToConstant: 44),
            
            removeButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -4),
            removeButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 6),
//            removeButton.heightAnchor.constraint(equalToConstant: 16),
//            removeButton.widthAnchor.constraint(equalToConstant: 16),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func removeButtonTapped(_ sender: UIButton) {
        removeCallback?()
    }


}
