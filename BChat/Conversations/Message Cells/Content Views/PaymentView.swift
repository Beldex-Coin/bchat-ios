
final class PaymentView : UIView {
    // Name = txnid
    //rawURL = rawAmount
    private let txnid: String
    private let rawAmount: String
    private let textColor: UIColor
    private let isOutgoing: Bool
    
    private lazy var amount: String = {
//        if let range = rawAmount.range(of: "?public_key=") {
//            return String(rawAmount[..<range.lowerBound])
//        } else {
//            return rawAmount
//        }
        return rawAmount
    }()
    
    // MARK: Settings
    private static let iconSize: CGFloat = 26
    private static let iconImageViewSize: CGFloat = 40
    
    // MARK: Lifecycle
    init(txnid: String, rawAmount: String, textColor: UIColor, isOutgoing: Bool) {
        self.txnid = txnid
        self.rawAmount = rawAmount
        self.textColor = textColor
        self.isOutgoing = isOutgoing
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
        titleLabel.text = "\(rawAmount) BDX "
        titleLabel.textColor = UIColor.white
        titleLabel.font = Fonts.boldOpenSans(ofSize: Values.largeFontSize)
        // Direction
        let subtitleLabel = UILabel()
        let direction = isOutgoing ? "send" : "receive"
        if direction == "send" {
            subtitleLabel.text = NSLocalizedString("Send Successfully", comment: "")
        }else {
            subtitleLabel.text = NSLocalizedString("Received Successfully", comment: "")
        }
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.textColor = UIColor.white
        subtitleLabel.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        // txnid
        let urlLabel = UILabel()
        urlLabel.lineBreakMode = .byCharWrapping
        urlLabel.text = txnid
        urlLabel.textColor = textColor
        urlLabel.numberOfLines = 0
        urlLabel.font = Fonts.OpenSans(ofSize: Values.verySmallFontSize)
        
        // Icon
        let iconSize = PaymentView.iconSize
        let iconName = isOutgoing ? "beldeximg" : "beldeximg"
        let icon = UIImage(named: iconName)?.withTint(.white)?.resizedImage(to: CGSize(width: iconSize, height: iconSize))
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
        labelStackView.layer.cornerRadius = 6
        if direction == "send" {
            labelStackView.backgroundColor = UIColor(red: 0.24, green: 0.53, blue: 1.00, alpha: 1.00)
        }else {
            labelStackView.backgroundColor = UIColor(red: 0.13, green: 0.66, blue: 0.15, alpha: 1.00)
        }
        labelStackView.axis = .horizontal
        labelStackView.alignment = .center
        labelStackView.spacing = 2
        titleLabelContainer.addSubview(labelStackView)
        
        // Main stack
        let mainStackView = UIStackView(arrangedSubviews: [ labelStackView, subtitleLabel ])
        mainStackView.axis = .vertical
        mainStackView.spacing = Values.mediumSpacingBChat
        mainStackView.alignment = .leading
        let direction1 = isOutgoing ? "send" : "receive"
        if direction1 == "send" {
            subtitleLabel.text = NSLocalizedString("Send Successfully", comment: "")
        }else {
            subtitleLabel.text = NSLocalizedString("Received Successfully", comment: "")
        }
        addSubview(mainStackView)
        mainStackView.pin(to: self, withInset: Values.mediumSpacing)
    }
}
