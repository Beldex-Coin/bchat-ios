
final class QuoteView : UIView {
    private let mode: Mode
    private let thread: TSThread
    private let direction: Direction
    private let hInset: CGFloat
    private let maxWidth: CGFloat
    private let delegate: QuoteViewDelegate?

    private var maxBodyLabelHeight: CGFloat {
        switch mode {
        case .regular: return 60
        case .draft: return 40
        }
    }

    private var attachments: [OWSAttachmentInfo] {
        switch mode {
        case .regular(let viewItem): return (viewItem.interaction as? TSMessage)?.quotedMessage!.quotedAttachments ?? []
        case .draft(let model): return given(model.attachmentStream) { [ OWSAttachmentInfo(attachmentStream: $0) ] } ?? []
        }
    }

    private var thumbnail: UIImage? {
        switch mode {
        case .regular(let viewItem): return viewItem.quotedReply!.thumbnailImage
        case .draft(let model): return model.thumbnailImage
        }
    }
    
    private var thumbnailType: String? {
        switch mode {
        case .regular(let viewItem): return viewItem.quotedReply!.contentType
        case .draft(let model): return model.contentType
        }
    }

    private var body: String? {
        switch mode {
        case .regular(let viewItem): return (viewItem.interaction as? TSMessage)?.quotedMessage!.body
        case .draft(let model): return model.body
        }
    }

    private var authorID: String {
        switch mode {
        case .regular(let viewItem): return viewItem.quotedReply!.authorId
        case .draft(let model): return model.authorId
        }
    }

    private var lineColor: UIColor {
        switch (mode, AppModeManager.shared.currentAppMode) {
        case (.regular, .light): return (direction == .incoming) ? Colors.cellGroundColor2 : Colors.bothGreenColor
        case (.regular, .dark): return (direction == .incoming) ? Colors.cellGroundColor2 : Colors.bothGreenColor
        case (.draft, .dark): return Colors.cellGroundColor2
        case (.draft, .light): return Colors.cellGroundColor2
        }
    }

    private var textColor: UIColor {
        if case .draft = mode { return Colors.text }
        switch (direction) {
        case (.outgoing): return Colors.callCellTitle
        case (.incoming): return Colors.replyMessageColor
        default: return .white
        }
    }
    
    private var bodyColor: UIColor {
        if case .draft = mode { return Colors.text }
        switch (direction) {
        case (.outgoing): return Colors.bothWhiteWithAlpha60
        case (.incoming): return Colors.WhiteBlackWithAlpha60
        default: return .white
        }
    }

    // MARK: Mode
    enum Mode {
        case regular(ConversationViewItem)
        case draft(OWSQuotedReplyModel)
    }

    // MARK: Direction
    enum Direction { case incoming, outgoing }

    // MARK: Settings
    static let thumbnailSize: CGFloat = 48
    static let iconSize: CGFloat = 24
    static let labelStackViewSpacing: CGFloat = 2
    static let labelStackViewVMargin: CGFloat = 4
    static let cancelButtonSize: CGFloat = 33
    static let cancelButtonSizeNew: CGFloat = 43

    // MARK: Lifecycle
    init(for viewItem: ConversationViewItem, in thread: TSThread?, direction: Direction, hInset: CGFloat, maxWidth: CGFloat) {
        self.mode = .regular(viewItem)
        self.thread = thread ?? TSThread.fetch(uniqueId: viewItem.interaction.uniqueThreadId)!
        self.maxWidth = maxWidth
        self.direction = direction
        self.hInset = hInset
        self.delegate = nil
        super.init(frame: CGRect.zero)
        setUpViewHierarchy()
    }

    init(for model: OWSQuotedReplyModel, direction: Direction, hInset: CGFloat, maxWidth: CGFloat, delegate: QuoteViewDelegate) {
        self.mode = .draft(model)
        self.thread = TSThread.fetch(uniqueId: model.threadId)!
        self.maxWidth = maxWidth
        self.direction = direction
        self.hInset = hInset
        self.delegate = delegate
        super.init(frame: CGRect.zero)
        setUpViewHierarchy() 
        
    }
    //additional Background View
    private lazy var additionalBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()

    override init(frame: CGRect) {
        preconditionFailure("Use init(for:maxMessageWidth:) instead.")
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Use init(for:maxMessageWidth:) instead.")
    }

    private func setUpViewHierarchy() {
        // There's quite a bit of calculation going on here. It's a bit complex so don't make changes
        // if you don't need to. If you do then test:
        // • Quoted text in both private chats and group chats
        // • Quoted images and videos in both private chats and group chats
        // • Quoted voice messages and documents in both private chats and group chats
        // • All of the above in both dark mode and light mode
        let hasAttachments = !attachments.isEmpty
        let thumbnailSize = QuoteView.thumbnailSize
        let iconSize = QuoteView.iconSize
        let labelStackViewSpacing = QuoteView.labelStackViewSpacing
        let labelStackViewVMargin = QuoteView.labelStackViewVMargin
        let smallSpacing = Values.smallSpacing
        let cancelButtonSize = QuoteView.cancelButtonSize
        let cancelButtonSizeNew = QuoteView.cancelButtonSizeNew
        var availableWidth: CGFloat
        // Subtract smallSpacing twice; once for the spacing in between the stack view elements and
        // once for the trailing margin.
        if !hasAttachments {
            availableWidth = maxWidth - 2 * hInset - Values.accentLineThickness - 2 * smallSpacing
        } else {
            availableWidth = maxWidth - 2 * hInset - thumbnailSize - 2 * smallSpacing
        }
        if case .draft = mode {
            availableWidth -= cancelButtonSize
        }
        let availableSpace = CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
        var body = self.body
        // Main stack view
        let mainStackView = UIStackView(arrangedSubviews: [])
        mainStackView.axis = .horizontal
        mainStackView.spacing = 8
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = UIEdgeInsets(top: 0, leading: smallSpacing, bottom: 0, trailing: smallSpacing)
        mainStackView.alignment = .center
        mainStackView.distribution = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        // Content view
        let contentView = UIView()
        addSubview(contentView)
        contentView.pin([ UIView.HorizontalEdge.left, UIView.VerticalEdge.top, UIView.VerticalEdge.bottom ], to: self)
        contentView.rightAnchor.constraint(lessThanOrEqualTo: self.rightAnchor).isActive = true
        // Line view
        let lineView = UIView()
        lineView.backgroundColor = .clear
        lineView.set(.width, to: Values.accentLineThickness)
        if !hasAttachments {
            mainStackView.addArrangedSubview(lineView)
        } else {
            let isAudio = MIMETypeUtil.isAudio(attachments.first!.contentType ?? "")
            if (body ?? "").isEmpty {
                body = (thumbnail != nil) ? "Image" : (isAudio ? "Audio" : "Document")
                if thumbnailType?.lowercased().range(of:"video") != nil {
                    body = "Video"
                }
            }
        }
        // Body label
        let bodyLabel = UILabel()
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byTruncatingTail
        let isOutgoing = (direction == .outgoing)
        bodyLabel.font = Fonts.OpenSans(ofSize: 11)
        bodyLabel.attributedText = given(body) { MentionUtilities.highlightMentions(in: $0, isOutgoingMessage: isOutgoing, threadID: thread.uniqueId!, attributes: [:]) } ?? given(attachments.first?.contentType) { NSAttributedString(string: MIMETypeUtil.isAudio($0) ? "Audio" : "Document") } ?? NSAttributedString(string: "Document")
        bodyLabel.textColor = bodyColor
        let bodyLabelSize = bodyLabel.systemLayoutSizeFitting(availableSpace)
        // Label stack view
        var authorLabelHeight: CGFloat?
        if let groupThread = thread as? TSGroupThread {
            let authorLabel = UILabel()
            authorLabel.lineBreakMode = .byTruncatingTail
            let context: Contact.Context = groupThread.isOpenGroup ? .openGroup : .regular
            authorLabel.text = Storage.shared.getContact(with: authorID)?.displayName(for: context) ?? authorID
            authorLabel.textColor = textColor
            authorLabel.font = Fonts.semiOpenSans(ofSize: 12)
            let authorLabelSize = authorLabel.systemLayoutSizeFitting(availableSpace)
            authorLabel.set(.height, to: authorLabelSize.height)
            authorLabelHeight = authorLabelSize.height
            let labelStackView = UIStackView(arrangedSubviews: [ authorLabel, bodyLabel ])
            labelStackView.axis = .vertical
            labelStackView.spacing = labelStackViewSpacing
            labelStackView.distribution = .equalCentering
            labelStackView.set(.width, to: max(bodyLabelSize.width, authorLabelSize.width))
            labelStackView.isLayoutMarginsRelativeArrangement = true
            labelStackView.layoutMargins = UIEdgeInsets(top: labelStackViewVMargin, left: 0, bottom: labelStackViewVMargin, right: 0)
            mainStackView.addArrangedSubview(labelStackView)
        } else {
            let authorLabel = UILabel()
            authorLabel.lineBreakMode = .byTruncatingTail
            let context: Contact.Context = .regular
            authorLabel.text = Storage.shared.getContact(with: authorID)?.displayName(for: context) ?? authorID
            authorLabel.textColor = textColor
            authorLabel.font = Fonts.semiOpenSans(ofSize: 12)
            let authorLabelSize = authorLabel.systemLayoutSizeFitting(availableSpace)
            authorLabel.set(.height, to: authorLabelSize.height)
            authorLabelHeight = authorLabelSize.height
            let labelStackView = UIStackView(arrangedSubviews: [ authorLabel, bodyLabel ])
            labelStackView.axis = .vertical
            labelStackView.spacing = labelStackViewSpacing
            labelStackView.distribution = .equalCentering
            labelStackView.set(.width, to: max(bodyLabelSize.width, authorLabelSize.width))
            labelStackView.isLayoutMarginsRelativeArrangement = true
            labelStackView.layoutMargins = UIEdgeInsets(top: labelStackViewVMargin, left: 0, bottom: labelStackViewVMargin, right: 0)
            mainStackView.addArrangedSubview(labelStackView)
//            mainStackView.addArrangedSubview(bodyLabel)
        }
        // Cancel button
        let cancelButton = UIButton(type: .custom)
        let tint: UIColor = isLightMode ? .black : .white
        cancelButton.setImage(UIImage(named: "close_new")?.withTint(tint), for: UIControl.State.normal)
        cancelButton.set(.width, to: cancelButtonSizeNew)
        cancelButton.set(.height, to: cancelButtonSizeNew)
        cancelButton.addTarget(self, action: #selector(cancel), for: UIControl.Event.touchUpInside)
        
        if hasAttachments {
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            mainStackView.addArrangedSubview(spacer)

            
            let isAudio = MIMETypeUtil.isAudio(attachments.first!.contentType ?? "")
            let fallbackImageName = isAudio ? "ic_reply_audio" : "ic_reply_document"
            var tintColor: UIColor?
            if (isLightMode && direction == .incoming) {
                tintColor = .black
            } else {
                tintColor = .white
                if isLightMode {
                    if case .draft = mode {
                        tintColor = .black
                    }
                }
            }
            let fallbackImage = UIImage(named: fallbackImageName)?.withTint(tintColor!)?.resizedImage(to: CGSize(width: iconSize, height: iconSize))
            let imageView = UIImageView(image: thumbnail ?? fallbackImage)
            imageView.contentMode = (thumbnail != nil) ? .scaleAspectFill : .center
            imageView.backgroundColor = lineColor
            imageView.layer.cornerRadius = VisibleMessageCell.largeCornerRadius
            imageView.layer.masksToBounds = true
            imageView.set(.width, to: thumbnailSize)
            imageView.set(.height, to: thumbnailSize)
            mainStackView.addArrangedSubview(imageView)
        }
        
        // Constraints
        contentView.addSubview(mainStackView)
        mainStackView.pin(to: contentView)
        if !thread.isGroupThread() {
            bodyLabel.set(.width, to: bodyLabelSize.width)
        }
        let bodyLabelHeight = bodyLabelSize.height.clamp(0, maxBodyLabelHeight)
        let contentViewHeight: CGFloat
        if hasAttachments {
            contentViewHeight = thumbnailSize + 8 // Add a small amount of spacing above and below the thumbnail
            bodyLabel.set(.height, to: 18) // Experimentally determined
        } else {
            if let authorLabelHeight = authorLabelHeight { // Group thread
                contentViewHeight = bodyLabelHeight + (authorLabelHeight + labelStackViewSpacing) + 2 * labelStackViewVMargin
            } else {
                contentViewHeight = bodyLabelHeight + 2 * smallSpacing
            }
        }
        contentView.set(.height, to: contentViewHeight)
        lineView.set(.height, to: contentViewHeight - 8) // Add a small amount of spacing above and below the line
        if case .draft = mode {
            addSubview(cancelButton)
            cancelButton.pin(.top, to: .top, of: self, withInset: -5)
            cancelButton.pin(.right, to: .right, of: self, withInset: 5)
        }
//        contentView.pin(to: self)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    // MARK: Interaction
    @objc private func cancel() {
        delegate?.handleQuoteViewCancelButtonTapped()
    }
}

// MARK: Delegate
protocol QuoteViewDelegate {

    func handleQuoteViewCancelButtonTapped()
}
