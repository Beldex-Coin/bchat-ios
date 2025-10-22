
final class ContactView : UIView {
    
    private let bChatID: String
    private let contactName: String
    private let isOutgoing: Bool
    private let searchString: String
    private let contactCount: Int
        
    private lazy var backGroundView: UIView = {
        let result = UIView()
        result.layer.cornerRadius = 10
        result.layer.masksToBounds = true
        result.backgroundColor = isOutgoing ? UIColor(hex: 0x136515) : Colors.mainBackGroundColor2
        return result
    }()
    
    
    // MARK: Lifecycle
    init(bChatID: String, isOutgoing: Bool, contactName: String, searchString: String, contactCount: Int) {
        self.bChatID = bChatID
        self.contactName = contactName
        self.isOutgoing = isOutgoing
        self.searchString = searchString
        self.contactCount = contactCount
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
        addressLabel.isHidden = contactCount >= 2
        
        // contactNameLabel
        let contactNameLabel = UILabel()
        contactNameLabel.text = contactName
        contactNameLabel.textColor = isOutgoing ? Colors.callCellTitle : Colors.titleColor
        contactNameLabel.font = Fonts.semiOpenSans(ofSize: 12)
        contactNameLabel.attributedText = highlight(text: contactName, search: searchString)
        contactNameLabel.numberOfLines = 0

        // profileImageView
        let profileImageView = UIImageView()
        let profilePictureViewSize = CGFloat(40)
        profileImageView.set(.width, to: profilePictureViewSize)
        profileImageView.set(.height, to: profilePictureViewSize)
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 20
        profileImageView.image = getProfilePicture(of: profilePictureViewSize, for: bChatID)
        
        lazy var verifiedImageView: UIImageView = {
            let result = UIImageView()
            result.set(.width, to: 18)
            result.set(.height, to: 18)
            result.contentMode = .center
            result.image = UIImage(named: "ic_verified_image")
            return result
        }()
        
        addSubview(backGroundView)
        backGroundView.pin(.right, to: .right, of: self, withInset: -6)
        backGroundView.pin(.top, to: .top, of: self, withInset: 6)
        backGroundView.pin(.left, to: .left, of: self, withInset: 6)
        backGroundView.pin(.bottom, to: .bottom, of: self, withInset: 0)
        backGroundView.set(.width, to: (UIScreen.main.bounds.width / 2) + 50 )
        
        let contactIconImageView = UIImageView(image: #imageLiteral(resourceName: "ic_contact"))
        contactIconImageView.contentMode = .scaleAspectFit
        contactIconImageView.set(.width, to: 10)
        contactIconImageView.set(.height, to: 10)
        
        backGroundView.addSubViews([profileImageView, verifiedImageView, contactNameLabel, contactIconImageView, addressLabel])
        profileImageView.pin(.top, to: .top, of: backGroundView, withInset: 7)
        profileImageView.pin(.right, to: .right, of: backGroundView, withInset: -7)
        profileImageView.pin(.bottom, to: .bottom, of: backGroundView, withInset: -7)
        
        contactNameLabel.pin(.top, to: .top, of: backGroundView, withInset: 11)
        contactNameLabel.pin(.left, to: .left, of: contactIconImageView, withInset: 16)
        contactNameLabel.pin(.right, to: .left, of: profileImageView, withInset: -16)
    
        contactIconImageView.pin(.top, to: .top, of: contactNameLabel, withInset: 3)
        contactIconImageView.pin(.left, to: .left, of: backGroundView, withInset: 13)
        
        addressLabel.pin(.top, to: .bottom, of: contactNameLabel, withInset: 4)
        addressLabel.pin(.left, to: .left, of: backGroundView, withInset: 13)
        addressLabel.pin(.left, to: .right, of: contactIconImageView, withInset: 4)
        addressLabel.pin(.bottom, to: .bottom, of: backGroundView, withInset: -10)
        addressLabel.pin(.right, to: .left, of: profileImageView, withInset: -16)
        
        verifiedImageView.pin(.trailing, to: .trailing, of: profileImageView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: profileImageView, withInset: 3)
        
        if contactCount != 1 {
            contactIconImageView.pin([ VerticalEdge.top, VerticalEdge.bottom ], to: backGroundView)
            contactNameLabel.pin([ VerticalEdge.top, VerticalEdge.bottom ], to: backGroundView)
            contactNameLabel.pin(.bottom, to: .bottom, of: backGroundView, withInset: -2)
        }
        
        let contact: Contact? = Storage.shared.getContact(with: bChatID)
        if let _ = contact, let isBnsUser = contact?.isBnsHolder {
            profileImageView.layer.borderWidth = isBnsUser ? Values.borderThickness : 0
            profileImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
            verifiedImageView.isHidden = isBnsUser ? false : true
        } else {
            verifiedImageView.isHidden = true
        }
    }
    
    func highlight(text: String, search: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: text)
        guard !search.isEmpty else { return attributed }
        let lowercasedText = text.lowercased()
        let lowercasedSearch = search.lowercased()
        var searchRange = lowercasedText.startIndex..<lowercasedText.endIndex
        while let foundRange = lowercasedText.range(of: lowercasedSearch, options: [], range: searchRange) {
            let nsRange = NSRange(foundRange, in: text)
            attributed.addAttribute(.backgroundColor, value: UIColor.systemOrange, range: nsRange)
            
            searchRange = foundRange.upperBound..<lowercasedText.endIndex
        }
        return attributed
    }
    
    func getProfilePicture(of size: CGFloat, for publicKey: String) -> UIImage? {
        guard !publicKey.isEmpty else { return nil }
        if let profilePicture = OWSProfileManager.shared().profileAvatar(forRecipientId: publicKey) {
            return profilePicture
        } else {
            let displayName = Storage.shared.getContact(with: publicKey)?.name ?? contactName
            return Identicon.generatePlaceholderIcon(seed: publicKey, text: displayName, size: size)
        }
    }
    
}
