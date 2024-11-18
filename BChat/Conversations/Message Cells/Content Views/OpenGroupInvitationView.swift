
final class OpenGroupInvitationView : UIView {
    private let name: String
    private let rawURL: String
    private let textColor: UIColor
    private let isOutgoing: Bool
    
    private lazy var url: String = {
        if let range = rawURL.range(of: "?public_key=") {
            return String(rawURL[..<range.lowerBound])
        } else {
            return rawURL
        }
    }()
    
    // MARK: Settings
    private static let iconSize: CGFloat = 24
    private static let iconImageViewSize: CGFloat = 40//48
    
    private lazy var groupNameView: UIView = {
        let result = UIView()
        result.layer.cornerRadius = 10
        result.layer.masksToBounds = true
        result.backgroundColor = isOutgoing ? UIColor(hex: 0x136515) : Colors.mainBackGroundColor2
        return result
    }()
    
    
    // MARK: Lifecycle
    init(name: String, url: String, textColor: UIColor, isOutgoing: Bool) {
        self.name = name
        self.rawURL = url
        self.textColor = textColor
        self.isOutgoing = isOutgoing
        super.init(frame: CGRect.zero)
        setUpViewHierarchy()
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(name:url:textColor:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(name:url:textColor:) instead.")
    }
    
    private func setUpViewHierarchy() {
        // Title
        let titleLabel = UILabel()
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.text = name
        titleLabel.textColor = isOutgoing ? Colors.noDataLabelColor : Colors.titleColor5
        titleLabel.font = Fonts.OpenSans(ofSize: 10)
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.text = NSLocalizedString("view_open_group_invitation_description", comment: "")
        subtitleLabel.textColor = isOutgoing ? Colors.callCellTitle : Colors.titleColor
        subtitleLabel.font = Fonts.semiOpenSans(ofSize: 12)
        // URL
        let urlLabel = UILabel()
        urlLabel.lineBreakMode = .byCharWrapping
        urlLabel.text = url
        urlLabel.textColor = isOutgoing ? Colors.bothWhiteColor : Colors.titleColor3
        urlLabel.numberOfLines = 0
        urlLabel.font = Fonts.OpenSans(ofSize: 11)

        // Icon
        let iconSize = OpenGroupInvitationView.iconSize
        let iconName = isOutgoing ? "Globe" : "Plus"
        let icon = UIImage(named: iconName)?.withTint(.white)?.resizedImage(to: CGSize(width: iconSize, height: iconSize))
        let iconImageViewSize = OpenGroupInvitationView.iconImageViewSize
        let iconImageView = UIImageView(image: icon)
        iconImageView.contentMode = .center
        iconImageView.layer.cornerRadius = iconImageViewSize / 2
        iconImageView.layer.masksToBounds = true
        iconImageView.backgroundColor = Colors.bothGreenColor
        iconImageView.set(.width, to: iconImageViewSize)
        iconImageView.set(.height, to: iconImageViewSize)
        
        addSubview(groupNameView)
        groupNameView.pin(.right, to: .right, of: self, withInset: -6)
        groupNameView.pin(.top, to: .top, of: self, withInset: 5)
        groupNameView.pin(.left, to: .left, of: self, withInset: 6)
        
        
        let linkImageView = UIImageView(image: UIImage(named: "linkImage"))
        linkImageView.contentMode = .scaleAspectFit
        linkImageView.set(.width, to: 9.17)
        linkImageView.set(.height, to: 4.17)
        
        
        groupNameView.addSubViews([iconImageView, subtitleLabel, linkImageView, titleLabel])
        iconImageView.pin(.top, to: .top, of: groupNameView, withInset: 7)
        iconImageView.pin(.right, to: .right, of: groupNameView, withInset: -7)
        iconImageView.pin(.bottom, to: .bottom, of: groupNameView, withInset: -7)
        
        subtitleLabel.pin(.top, to: .top, of: groupNameView, withInset: 11)
        subtitleLabel.pin(.left, to: .left, of: groupNameView, withInset: 14)
        subtitleLabel.pin(.right, to: .left, of: iconImageView, withInset: -30)
        
        linkImageView.pin(.top, to: .bottom, of: subtitleLabel, withInset: 8.92)
        linkImageView.pin(.left, to: .left, of: groupNameView, withInset: 14.42)
        
        titleLabel.pin(.top, to: .bottom, of: subtitleLabel, withInset: 3)
        titleLabel.pin(.left, to: .right, of: linkImageView, withInset: 4.42)
        titleLabel.pin(.bottom, to: .bottom, of: groupNameView, withInset: -10)
        
        addSubview(urlLabel)
        urlLabel.pin(.top, to: .bottom, of: groupNameView, withInset: 5)
        urlLabel.pin(.left, to: .left, of: self, withInset: 14)
        urlLabel.pin(.bottom, to: .bottom, of: self, withInset: -10)
        
    }
}
