
final class ContactView : UIView {
    
    private let bChatID: String
    private let contactName: String
    private let isOutgoing: Bool
        
    private lazy var backGroundView: UIView = {
        let result = UIView()
        result.layer.cornerRadius = 10
        result.layer.masksToBounds = true
        result.backgroundColor = isOutgoing ? UIColor(hex: 0x136515) : Colors.mainBackGroundColor2
        return result
    }()
    
    
    // MARK: Lifecycle
    init(bChatID: String, isOutgoing: Bool, contactName: String) {
        self.bChatID = bChatID
        self.contactName = contactName
        self.isOutgoing = isOutgoing
        super.init(frame: .zero)
        setUpViewHierarchy()
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(name:url:textColor:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(name:url:textColor:) instead.")
    }
    
    private func setUpViewHierarchy() {
        // addressLabel
        let addressLabel = UILabel()
        addressLabel.text = bChatID.truncateMiddle()
        addressLabel.textColor = isOutgoing ? Colors.noDataLabelColor : Colors.textFieldPlaceHolderColor
        addressLabel.font = Fonts.regularOpenSans(ofSize: 10)
        
        // contactNameLabel
        let contactNameLabel = UILabel()
        contactNameLabel.text = contactName
        contactNameLabel.textColor = isOutgoing ? Colors.callCellTitle : Colors.titleColor
        contactNameLabel.font = Fonts.semiOpenSans(ofSize: 12)

        // profileImageView
        let profileImageView = ProfilePictureView()
        let profilePictureViewSize = CGFloat(40)
        profileImageView.set(.width, to: profilePictureViewSize)
        profileImageView.set(.height, to: profilePictureViewSize)
        profileImageView.size = profilePictureViewSize
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 20
        profileImageView.publicKey = bChatID
        profileImageView.update()
        
        addSubview(backGroundView)
        backGroundView.pin(.right, to: .right, of: self, withInset: -6)
        backGroundView.pin(.top, to: .top, of: self, withInset: 6)
        backGroundView.pin(.left, to: .left, of: self, withInset: 6)
        backGroundView.pin(.bottom, to: .bottom, of: self, withInset: -15)
        backGroundView.set(.width, to: (UIScreen.main.bounds.width / 2) + 70 )
        
        let contactIconImageView = UIImageView(image: #imageLiteral(resourceName: "ic_contact"))
        contactIconImageView.contentMode = .scaleAspectFit
        contactIconImageView.set(.width, to: 10)
        contactIconImageView.set(.height, to: 10)
        
        backGroundView.addSubViews([profileImageView, contactNameLabel, contactIconImageView, addressLabel])
        profileImageView.pin(.top, to: .top, of: backGroundView, withInset: 7)
        profileImageView.pin(.right, to: .right, of: backGroundView, withInset: -7)
        profileImageView.pin(.bottom, to: .bottom, of: backGroundView, withInset: -7)
        
        contactNameLabel.pin(.top, to: .top, of: backGroundView, withInset: 11)
        contactNameLabel.pin(.left, to: .left, of: backGroundView, withInset: 14)
        contactNameLabel.pin(.right, to: .left, of: profileImageView, withInset: -16)
        
        contactIconImageView.pin(.top, to: .bottom, of: contactNameLabel, withInset: 6)
        contactIconImageView.pin(.left, to: .left, of: backGroundView, withInset: 13)
        
        addressLabel.pin(.top, to: .bottom, of: contactNameLabel, withInset: 4)
        addressLabel.pin(.left, to: .right, of: contactIconImageView, withInset: 4)
        addressLabel.pin(.bottom, to: .bottom, of: backGroundView, withInset: -10)
        addressLabel.pin(.right, to: .left, of: profileImageView, withInset: -16)
    }
}
