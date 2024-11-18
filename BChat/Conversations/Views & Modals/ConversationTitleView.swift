
final class ConversationTitleView : UIView {
    private let thread: TSThread
    weak var delegate: ConversationTitleViewDelegate?

    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }

    // MARK: UI Components
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.semiOpenSans(ofSize: Values.mediumFontSize)
        result.lineBreakMode = .byTruncatingTail
        return result
    }()

    private lazy var subtitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = Fonts.OpenSans(ofSize: 13)
        result.lineBreakMode = .byTruncatingTail
        return result
    }()
    
    private lazy var stackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ titleLabel, subtitleLabel ])
        result.axis = .vertical
        result.alignment = .leading
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()

    // MARK: Lifecycle
    init(thread: TSThread) {
        self.thread = thread
        super.init(frame: CGRect.zero)
        initialize()
    }

    override init(frame: CGRect) {
        preconditionFailure("Use init(thread:) instead.")
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Use init(coder:) instead.")
    }

    private func initialize() {
        addSubview(stackView)
        stackView.pin(to: self)
        let shouldShowCallButton = BChatCall.isEnabled && !thread.isNoteToSelf() && !thread.isGroupThread()
        let leftMargin: CGFloat = shouldShowCallButton ? 54 : 8 // Contact threads also have the call button to compensate for
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(update), name: Notification.Name.groupThreadUpdated, object: nil)
        notificationCenter.addObserver(self, selector: #selector(update), name: Notification.Name.muteSettingUpdated, object: nil)
        notificationCenter.addObserver(self, selector: #selector(update), name: Notification.Name.contactUpdated, object: nil)
        update()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Updating
    @objc private func update() {
        titleLabel.text = getTitle().firstCharacterUpperCase()
        let subtitle = getSubtitle()
        subtitleLabel.attributedText = subtitle
        let titleFontSize = (subtitle != nil) ? Values.mediumFontSize : Values.mediumFontSize
        titleLabel.font = Fonts.semiOpenSans(ofSize: titleFontSize)
    }

    // MARK: General
    private func getTitle() -> String {
        if let thread = thread as? TSGroupThread {
            return thread.groupModel.groupName!
        }
        else if thread.isNoteToSelf() {
            return "Note to Self"
        }
        else {
            let bchatID = (thread as! TSContactThread).contactBChatID()
            var result = bchatID
            Storage.read { transaction in
                let displayName: String = ((Storage.shared.getContact(with: bchatID)?.displayName(for: .regular)) ?? bchatID)
                let middleTruncatedHexKey: String = "\(bchatID.prefix(4))...\(bchatID.suffix(4))"
                result = (displayName == bchatID ? middleTruncatedHexKey : displayName)
                
                if BNSBool.isFromBNS {
                    result = (displayName == bchatID) ? BNSBool.bnsName : displayName
                    if displayName == bchatID {
                        if let contact: Contact = Storage.shared.getContact(with: bchatID) {
                            Storage.write(
                                with: { transaction in
                                    contact.name = BNSBool.bnsName
                                    Storage.shared.setContact(contact, using: transaction)
                                    BNSBool.isFromBNS = false
                                    BNSBool.bnsName = ""
                                },
                                completion: {
                                    MessageSender.syncConfiguration(forceSyncNow: true).retainUntilComplete()
                                }
                            )
                        }
                    }
                }
                
            }
            return result
        }
    }

    private func getSubtitle() -> NSAttributedString? {
        let result = NSMutableAttributedString()
        if thread.isMuted {
            result.append(NSAttributedString(string: "\u{e067}  ", attributes: [ .font : UIFont.ows_elegantIconsFont(10), .foregroundColor : Colors.text ]))
            result.append(NSAttributedString(string: "Muted"))
            return result
        } else if let thread = self.thread as? TSGroupThread {
            if thread.isOnlyNotifyingForMentions {
                let imageAttachment = NSTextAttachment()
                let color: UIColor = isDarkMode ? .white : .black
                imageAttachment.image = UIImage(named: "NotifyMentions.png")?.asTintedImage(color: color)
                imageAttachment.bounds = CGRect(x: 0, y: -2, width: Values.smallFontSize, height: Values.smallFontSize)
                let imageAsString = NSAttributedString(attachment: imageAttachment)
                result.append(imageAsString)
                result.append(NSAttributedString(string: "  " + NSLocalizedString("view_conversation_title_notify_for_mentions_only", comment: "")))
                return result
            } else {
                var userCount: UInt64?
                switch thread.groupModel.groupType {
                case .closedGroup: userCount = UInt64(thread.groupModel.groupMemberIds.count)
                case .openGroup:
                    guard let openGroupV2 = Storage.shared.getV2OpenGroup(for: self.thread.uniqueId!) else { return nil }
                    userCount = Storage.shared.getUserCount(forV2OpenGroupWithID: openGroupV2.id)
                default: break
                }
                if let userCount = userCount {
                    return NSAttributedString(string: "\(userCount) members")
                }
            }
        }
        return nil
    }
    
    // MARK: Interaction
    @objc private func handleTap() {
        delegate?.handleTitleViewTapped()
    }
}

// MARK: - ConversationTitleViewDelegate

protocol ConversationTitleViewDelegate: AnyObject {
    func handleTitleViewTapped()
}


struct BNSBool {
    static var isFromBNS = false
    static var bnsName = ""
}
