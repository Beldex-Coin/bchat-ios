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
        View.backgroundColor = .clear
        View.layer.cornerRadius = 36
       return View
   }()
    
    lazy var iconImageView = ProfilePictureView()
    
    lazy var verifiedImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 18)
        result.set(.height, to: 18)
        result.contentMode = .center
        result.image = UIImage(named: "ic_verified_image")
        return result
    }()
    
    lazy var nameLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.titleColor3
       result.font = Fonts.boldOpenSans(ofSize: 15)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var lastMessageLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.textFieldPlaceHolderColor
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
    
    lazy var messageCountStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fill
        result.spacing = 7
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var notifyMentionImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 18)
        result.set(.height, to: 18)
        result.contentMode = .scaleAspectFit
        result.image = UIImage(named: "ic_notifyMention")
        return result
    }()
    
    lazy var muteImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 18)
        result.set(.height, to: 18)
        result.contentMode = .scaleAspectFit
        result.image = UIImage(named: "ic_mute_homeTableCell")
        return result
    }()
    
    
    lazy var messageCountLabel: UILabel = {
        let result = PaddingLabel()
        result.textColor = Colors.bothWhiteColor
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
    
    lazy var separatorLineView: UIView = {
       let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = Colors.separatorHomeTableViewCellColor
       return View
   }()
    
    func setUPLayout() {
        contentView.addSubview(backGroundView)
        contentView.addSubview(pinImageView)
        contentView.addSubview(separatorLineView)
        pinImageView.image = UIImage(named: "ic_pinned")
        backGroundView.addSubViews(iconImageView, verifiedImageView, nameLabel, lastMessageLabel, messageCountAndDateStackView)
        
//        messageCountAndDateStackView.addArrangedSubview(messageCountLabel)
        messageCountAndDateStackView.addArrangedSubview(messageCountStackView)
        messageCountAndDateStackView.addArrangedSubview(dateLabel)
        
        messageCountStackView.addArrangedSubview(muteImageView)
        messageCountStackView.addArrangedSubview(notifyMentionImageView)
        messageCountStackView.addArrangedSubview(messageCountLabel)

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
            
            verifiedImageView.trailingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 2),
            verifiedImageView.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 3),
            
            nameLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 17),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: messageCountAndDateStackView.leadingAnchor, constant: -8),
            
            lastMessageLabel.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor),
            lastMessageLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 17),
            lastMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: messageCountAndDateStackView.leadingAnchor, constant: -8),
            
            messageCountLabel.heightAnchor.constraint(equalToConstant: 22),
            messageCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 22),
            
            messageCountAndDateStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            messageCountAndDateStackView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 15),
            messageCountAndDateStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -15),
            messageCountAndDateStackView.widthAnchor.constraint(equalToConstant: 56 + 30),
            
            separatorLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLineView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            separatorLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLineView.heightAnchor.constraint(equalToConstant: 1),
            
        ])
    }
    
    
    // MARK: Updating for search results
    private func updateForSearchResult() {
        AssertIsOnMainThread()
        guard let thread = threadViewModel?.threadRecord else { return }
        iconImageView.update(for: thread)
        messageCountLabel.isHidden = true
    }
    
    public func configureForRecent() {
        nameLabel.attributedText = NSMutableAttributedString(string: getDisplayName(), attributes: [.foregroundColor:Colors.titleColor3])
        let snippet = String(format: NSLocalizedString("RECENT_SEARCH_LAST_MESSAGE_DATETIME", comment: ""), DateUtil.formatDate(forDisplay: threadViewModel.lastMessageDate))
        lastMessageLabel.attributedText = NSMutableAttributedString(string: snippet, attributes: [.foregroundColor:Colors.textFieldPlaceHolderColor.withAlphaComponent(Values.lowOpacity)])
        dateLabel.isHidden = true
    }
    
    
    public func configure(snippet: String?, searchText: String, message: TSMessage? = nil) {
        let normalizedSearchText = searchText.lowercased()
        if let messageTimestamp = message?.timestamp, let snippet = snippet {
            // Message
            let messageDate = NSDate.ows_date(withMillisecondsSince1970: messageTimestamp)
            nameLabel.attributedText = NSMutableAttributedString(string: getDisplayName(), attributes: [.foregroundColor:Colors.titleColor3])
            dateLabel.isHidden = false
            dateLabel.text = DateUtil.formatDate(forDisplay: messageDate)
            var rawSnippet = snippet
            if let message = message, let name = getMessageAuthorName(message: message) {
                rawSnippet = "\(name): \(snippet)"
            }
            lastMessageLabel.attributedText = getHighlightedSnippet(snippet: rawSnippet, searchText: normalizedSearchText, fontSize: 12)
        } else {
            // Contact
            if threadViewModel.isGroupThread, let thread = threadViewModel.threadRecord as? TSGroupThread {
                nameLabel.attributedText = getHighlightedSnippet(snippet: getDisplayName(), searchText: normalizedSearchText, fontSize: 15)
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
                } else {
                    lastMessageLabel.attributedText = getHighlightedSnippet(snippet: rawSnippet, searchText: normalizedSearchText, fontSize: 12)
                }
            } else {
                nameLabel.attributedText = getHighlightedSnippet(snippet: getDisplayNameForSearch(threadViewModel.contactBChatID!), searchText: normalizedSearchText, fontSize: 15)
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
        iconImageView.update(for: thread)
        
        if let contactThread: TSContactThread = thread as? TSContactThread {
            let contact: Contact? = Storage.shared.getContact(with: contactThread.contactBChatID())
            // BeldexAddress view in Conversation Page (Get from DB)
            guard let _ = contact, let isBnsUser = contact?.isBnsHolder else { return }
            iconImageView.layer.borderWidth = isBnsUser ? 3 : 0
            iconImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
            verifiedImageView.isHidden = isBnsUser ? false : true
        } else {
            iconImageView.layer.borderWidth = 0
            iconImageView.layer.borderColor = UIColor.clear.cgColor
            verifiedImageView.isHidden = true
        }
        
        nameLabel.text = getDisplayName().firstCharacterUpperCase()
        dateLabel.text = DateUtil.formatDate(forDisplay: threadViewModel.lastMessageDate)
        if SSKEnvironment.shared.typingIndicators.typingRecipientId(forThread: thread) != nil {
            lastMessageLabel.text = ""
        } else {
            lastMessageLabel.attributedText = getSnippet()
        }
        let lastMessage = threadViewModel.lastMessageForInbox
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
        muteImageView.isHidden = true
        notifyMentionImageView.isHidden = true
        let result = NSMutableAttributedString()
        if threadViewModel.isMuted {
            muteImageView.isHidden = false
            // Don't Delete i will remove after confirmation of flow
            
//            result.append(NSAttributedString(string: "\u{e067}  ", attributes: [ .font : UIFont.ows_elegantIconsFont(10), .foregroundColor : Colors.unimportant ]))
        }
        if threadViewModel.isOnlyNotifyingForMentions {
            notifyMentionImageView.isHidden = false
            // Don't Delete i will remove after confirmation of flow
            
//            let imageAttachment = NSTextAttachment()
//            imageAttachment.image = UIImage(named: "NotifyMentions.png")?.asTintedImage(color: Colors.unimportant)
//            imageAttachment.bounds = CGRect(x: 0, y: -2, width: Values.smallFontSize, height: Values.smallFontSize)
//            let imageString = NSAttributedString(attachment: imageAttachment)
//            result.append(imageString)
//            result.append(NSAttributedString(string: "  ", attributes: [ .font : UIFont.ows_elegantIconsFont(10), .foregroundColor : Colors.unimportant ]))
        }
        let font = threadViewModel.hasUnreadMessages ? Fonts.OpenSans(ofSize: Values.smallFontSize) : Fonts.OpenSans(ofSize: Values.smallFontSize)
        if threadViewModel.isGroupThread, let message = threadViewModel.lastMessageForInbox as? TSMessage, let name = getMessageAuthorName(message: message) {
            result.append(NSAttributedString(string: "\(name): ", attributes: [ .font : font, .foregroundColor : Colors.textFieldPlaceHolderColor ]))
        }
        if let rawSnippet = threadViewModel.lastMessageText {
            let snippet = MentionUtilities.highlightMentions(in: rawSnippet, threadID: threadViewModel.threadRecord.uniqueId!)
            result.append(NSAttributedString(string: snippet, attributes: [ .font : font, .foregroundColor : Colors.textFieldPlaceHolderColor ]))
        }
        return result
    }

}
