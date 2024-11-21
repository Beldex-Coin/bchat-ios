
final class MediaPlaceholderView : UIView {
    private let viewItem: ConversationViewItem
    private let textColor: UIColor
    
    // MARK: Settings
    private static let iconSize: CGFloat = 24
    private static let iconImageViewSize: CGFloat = 40
    
    // MARK: Lifecycle
    init(viewItem: ConversationViewItem, textColor: UIColor) {
        self.viewItem = viewItem
        self.textColor = textColor
        super.init(frame: CGRect.zero)
        setUpViewHierarchy()
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(viewItem:textColor:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(viewItem:textColor:) instead.")
    }
    
    private func setUpViewHierarchy() {
        let (iconName, attachmentDescription): (String, String) = {
            guard let message = viewItem.interaction as? TSIncomingMessage else { return ("ic_DocumentAttachment", "file") } // Should never occur
            var attachments: [TSAttachment] = []
            Storage.read { transaction in
                attachments = message.attachments(with: transaction)
            }
            guard let contentType = attachments.first?.contentType else { return ("ic_DocumentAttachment", "File") } // Should never occur
            if MIMETypeUtil.isAudio(contentType) { return ("ic_AudioAttachment", "Audio") }
            if MIMETypeUtil.isImage(contentType) { return ("ic_imageAttachment", "Image") }
            if MIMETypeUtil.isVideo(contentType) { return ("ic_videoImage", "Video") }
            return ("ic_DocumentAttachment", "File")
        }()
        // Image view
        let iconSize = CGFloat(18)//MediaPlaceholderView.iconSize
        let icon = UIImage(named: iconName)?.withTint(textColor)?.resizedImage(to: CGSize(width: iconSize, height: iconSize))
        let imageView = UIImageView(image: icon)
        imageView.contentMode = .center
        let iconImageViewSize = MediaPlaceholderView.iconImageViewSize
        imageView.set(.width, to: 30)
        imageView.set(.height, to: 30)
        // Body label
        let titleLabel = UILabel()
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.text = "\(attachmentDescription)"//"Tap to download \(attachmentDescription)"
        titleLabel.textColor = Colors.textFieldPlaceHolderColor
        titleLabel.font = Fonts.boldOpenSans(ofSize: 12)
        
        //download image
        let downloadimageView = UIImageView(image: UIImage(named: "ic_downloadImage"))
        downloadimageView.contentMode = .center
        let iconSize1 = MediaPlaceholderView.iconImageViewSize
        downloadimageView.set(.width, to: iconSize1)
        downloadimageView.set(.height, to: iconSize1)
        
        let spacer = UIView.spacer(withWidth: 5)
        let spacer1 = UIView.spacer(withWidth: 16)
        
        // Stack view
        let stackView = UIStackView(arrangedSubviews: [spacer, imageView, titleLabel, spacer1, downloadimageView ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        stackView.layer.cornerRadius = 20
        stackView.backgroundColor = Colors.smallBackGroundViewCellColor
        addSubview(stackView)
        stackView.pin(to: self, withInset: 4)
    }
}
