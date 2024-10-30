
final class PaymentView : UIView {
    // Name = txnid
    //rawURL = rawAmount
    private let txnid: String
    private let rawAmount: String
    private let textColor: UIColor
    private let isOutgoing: Bool
    private let viewItem: ConversationViewItem
    
    private lazy var amount: String = {
        return rawAmount
    }()
    
    // MARK: Settings
    private static let iconSize: CGFloat = 26
    private static let iconImageViewSize: CGFloat = 40
    
    // MARK: Lifecycle
    init(txnid: String, rawAmount: String, textColor: UIColor, isOutgoing: Bool, viewItem: ConversationViewItem) {
        self.txnid = txnid
        self.rawAmount = rawAmount
        self.textColor = textColor
        self.isOutgoing = isOutgoing
        self.viewItem = viewItem
        super.init(frame: CGRect.zero)
        setUpViewHierarchy()
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(txnid:amount:textColor:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(txnid:amount:textColor:) instead.")
    }
    
    
    private func setUpViewHierarchy() {
        // Amount
        let titleLabel = UILabel()
        titleLabel.lineBreakMode = .byTruncatingTail
        let fullText = "\(rawAmount) BDX  "
        if let rangeBeldex = fullText.range(of: "\(rawAmount)"),
           let rangeAddress = fullText.range(of: "BDX  ") {
            let attributedString = NSMutableAttributedString(string: fullText)
            let direction = isOutgoing ? "send" : "receive"
            if direction != "send" {
                attributedString.addAttribute(.foregroundColor, value: Colors.titleColor, range: NSRange(rangeBeldex, in: fullText))
                let colorCode = isLightMode ? UIColor(hex: 0xACACAC) : UIColor(hex: 0xACACAC)
                attributedString.addAttribute(.foregroundColor, value: colorCode, range: NSRange(rangeAddress, in: fullText))
            } else {
                attributedString.addAttribute(.foregroundColor, value: Colors.bothWhiteColor, range: NSRange(rangeBeldex, in: fullText))
                let colorCode2 = isLightMode ? UIColor(hex: 0xCCFFDD) : UIColor(hex: 0xCCFFDD)
                attributedString.addAttribute(.foregroundColor, value: colorCode2, range: NSRange(rangeAddress, in: fullText))
            }
            titleLabel.attributedText = attributedString
        }
        titleLabel.font = Fonts.boldOpenSans(ofSize: 20)
        // Direction
        let direction = isOutgoing ? "send" : "receive"
        let subtitleLabel = UILabel()
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.font = Fonts.OpenSans(ofSize: 10)
        
        if direction == "send" {
            subtitleLabel.text = NSLocalizedString("Send Successfully", comment: "")
        } else {
            subtitleLabel.text = NSLocalizedString("Received Successfully", comment: "")
        }
        
        if direction == "receive" {
            subtitleLabel.textColor = Colors.bothGreenColor
        }
        
        // Bottom time label
        let timeLabel = UILabel()
        timeLabel.lineBreakMode = .byTruncatingTail
        timeLabel.font = Fonts.OpenSans(ofSize: 9)
        let date = viewItem.interaction.dateForUI()
        let description = DateUtil.formatDate(forDisplay2: date)
        timeLabel.text = description
        if direction != "send" {
            timeLabel.textColor = Colors.messageTimeLabelColor
        } else {
            timeLabel.textColor = Colors.callCellTitle
        }
        
        
        // Tick mark imageView
        let tickMarkImageView = UIImageView()
        tickMarkImageView.contentMode = .scaleAspectFit
        if direction != "send" {
            tickMarkImageView.image = UIImage(named: "ic_tick_mark")
        } else {
            tickMarkImageView.image = UIImage(named: "ic_tick_mark2")
        }
        
        // Container for subtitle and tick mark
        let subtitleContainerView = UIView()
        subtitleContainerView.addSubview(subtitleLabel)
        subtitleContainerView.addSubview(tickMarkImageView)
        // Constraints for subtitle label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subtitleLabel.leadingAnchor.constraint(equalTo: subtitleContainerView.leadingAnchor),
            subtitleLabel.centerYAnchor.constraint(equalTo: subtitleContainerView.centerYAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: tickMarkImageView.leadingAnchor, constant: -3)
        ])
        // Constraints for tick mark imageView
        tickMarkImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tickMarkImageView.leadingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor, constant: 8),
            tickMarkImageView.trailingAnchor.constraint(equalTo: subtitleContainerView.trailingAnchor),
            tickMarkImageView.centerYAnchor.constraint(equalTo: subtitleContainerView.centerYAnchor),
            tickMarkImageView.widthAnchor.constraint(equalToConstant: 12),
            tickMarkImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        // txnid
        let urlLabel = UILabel()
        urlLabel.lineBreakMode = .byCharWrapping
        urlLabel.text = txnid
        urlLabel.textColor = textColor
        urlLabel.numberOfLines = 0
        urlLabel.font = Fonts.OpenSans(ofSize: Values.verySmallFontSize)
        
        // Icon
        let iconSize = PaymentView.iconSize
        var iconName = "beldeximg"
        if direction == "receive" && isLightMode {
            iconName = "beldeximg2"
        }
        let icon = UIImage(named: iconName)?.resizedImage(to: CGSize(width: iconSize, height: iconSize))
        let iconImageViewSize = PaymentView.iconImageViewSize
        let iconImageView = UIImageView(image: icon)
        iconImageView.contentMode = .center
        iconImageView.layer.cornerRadius = iconImageViewSize / 2
        iconImageView.layer.masksToBounds = true
        iconImageView.set(.width, to: iconImageViewSize)
        iconImageView.set(.height, to: iconImageViewSize)
        
        // SubView
        let titleLabelContainer = UIView()
        let labelStackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        titleLabelContainer.set(.height, to: PaymentView.iconImageViewSize)
        labelStackView.layer.cornerRadius = 16
        if direction != "send" {
            labelStackView.backgroundColor = Colors.paymentViewInsideColor
        } else {
            labelStackView.backgroundColor = Colors.paymentViewInsideReciverColor
        }
        labelStackView.axis = .horizontal
        labelStackView.alignment = .center
        labelStackView.spacing = 2
        titleLabelContainer.addSubview(labelStackView)
        
        // Main stack
        let mainStackView = UIStackView(arrangedSubviews: [ labelStackView, subtitleContainerView ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 17
        mainStackView.alignment = .leading
        let direction1 = isOutgoing ? "send" : "receive"
        if direction1 == "send" {
            subtitleLabel.text = NSLocalizedString("Send Successfully", comment: "")
            subtitleLabel.textColor = UIColor.white
        } else {
            subtitleLabel.text = NSLocalizedString("Received Successfully", comment: "")
            subtitleLabel.textColor = Colors.bothGreenColor
        }
        addSubview(mainStackView)
        addSubview(timeLabel)
        mainStackView.pin(to: self, withInset: Values.mediumSpacing)
        timeLabel.pin(.right, to: .right, of: self, withInset: -15)
        timeLabel.pin(.bottom, to: .bottom, of: self, withInset: -9)
        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: tickMarkImageView.trailingAnchor, constant: 4)
            ])
    }
}
