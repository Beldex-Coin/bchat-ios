import BChatUIKit

@objc(LKProfilePictureView)
public final class ProfilePictureView : UIView {
    private var hasTappableProfilePicture: Bool = false
    @objc public var size: CGFloat = 0 // Not an implicitly unwrapped optional due to Obj-C limitations
    @objc public var useFallbackPicture = false
    @objc public var publicKey: String!
    @objc public var additionalPublicKey: String?
    @objc public var openGroupProfilePicture: UIImage?
    @objc public var isNoteToSelfImage = false
    @objc public var groupThreadForGroupImage: TSGroupThread?
    // Constraints
    private var imageViewWidthConstraint: NSLayoutConstraint!
    private var imageViewHeightConstraint: NSLayoutConstraint!
    private var additionalImageViewWidthConstraint: NSLayoutConstraint!
    private var additionalImageViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Components
    private lazy var imageView = getImageView()
    private lazy var additionalImageView = getImageView()
    
    // MARK: Lifecycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViewHierarchy()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViewHierarchy()
    }
    
    private func setUpViewHierarchy() {
        // Set up image view
        addSubview(imageView)
        imageView.pin(.leading, to: .leading, of: self)
        imageView.pin(.top, to: .top, of: self)
        let imageViewSize = CGFloat(Values.mediumProfilePictureSize)
        imageViewWidthConstraint = imageView.set(.width, to: imageViewSize)
        imageViewHeightConstraint = imageView.set(.height, to: imageViewSize)
        // Set up additional image view
        addSubview(additionalImageView)
        additionalImageView.pin(.trailing, to: .trailing, of: self)
        additionalImageView.pin(.bottom, to: .bottom, of: self)
        let additionalImageViewSize = CGFloat(Values.smallProfilePictureSize)
        additionalImageViewWidthConstraint = additionalImageView.set(.width, to: additionalImageViewSize)
        additionalImageViewHeightConstraint = additionalImageView.set(.height, to: additionalImageViewSize)
        additionalImageView.layer.cornerRadius = 3
    }
    
    // MARK: Updating
    @objc(updateForContact:)
    public func update(for publicKey: String) {
        openGroupProfilePicture = nil
        self.publicKey = publicKey
        additionalPublicKey = nil
        useFallbackPicture = false
        update()
    }

    @objc(updateForThread:)
    public func update(for thread: TSThread) {
        openGroupProfilePicture = nil
        if let thread = thread as? TSGroupThread {
            groupThreadForGroupImage = thread
            if let openGroupProfilePicture = thread.groupModel.groupImage { // An open group with a profile picture
                self.openGroupProfilePicture = openGroupProfilePicture
                useFallbackPicture = false
                hasTappableProfilePicture = true
            } else if thread.groupModel.groupType == .openGroup { // An open group without a profile picture or an RSS feed
                publicKey = ""
                useFallbackPicture = true
            } else { // A closed group
                var users = Set(thread.groupModel.groupMemberIds)
                users.remove(getUserHexEncodedPublicKey())
                var randomUsers = users.sorted() // Sort to provide a level of stability
                if users.count == 1 {
                    randomUsers.insert(getUserHexEncodedPublicKey(), at: 0) // Ensure the current user is at the back visually
                }
                publicKey = randomUsers.count >= 1 ? randomUsers[0] : ""
                additionalPublicKey = randomUsers.count >= 2 ? randomUsers[1] : ""
                useFallbackPicture = false
            }
            update()
        } else { // A one-to-one chat
            let thread = thread as! TSContactThread
            update(for: thread.contactBChatID())
        }
    }

    @objc public func update() {
        AssertIsOnMainThread()
        func getProfilePicture(of size: CGFloat, for publicKey: String) -> UIImage? {
            guard !publicKey.isEmpty else { return nil }
            if let profilePicture = OWSProfileManager.shared().profileAvatar(forRecipientId: publicKey) {
                hasTappableProfilePicture = true
                return profilePicture
            } else {
                hasTappableProfilePicture = false
                // TODO: Pass in context?
                let displayName = Storage.shared.getContact(with: publicKey)?.name ?? publicKey
                return Identicon.generatePlaceholderIcon(seed: publicKey, text: displayName, size: size)
            }
        }
        let size: CGFloat
        if let additionalPublicKey = additionalPublicKey, !useFallbackPicture, openGroupProfilePicture == nil {
            if self.size == 40 {
                size = 32
            } else if self.size == Values.largeProfilePictureSize {
                size = 56
            } else if self.size == CGFloat(86) {
                size = 86//74
            } else if self.size == 60 {
                size = 55
            } else if self.size == 36 {
                size = 36
            } else if self.size == 22 {
                size = 22
            }
            else {
                size = 42//37
            }
            imageViewWidthConstraint.constant = size
            imageViewHeightConstraint.constant = size
            additionalImageViewWidthConstraint.constant = size
            additionalImageViewHeightConstraint.constant = size
            additionalImageView.isHidden = false
            
            additionalImageView.image = getgroupImage(of: size, for: publicKey, displayName: groupThreadForGroupImage?.groupModel.groupName ?? "")
//            additionalImageView.image = getProfilePicture(of: size, for: additionalPublicKey)
        } else {
            size = self.size
            imageViewWidthConstraint.constant = size
            imageViewHeightConstraint.constant = size
            additionalImageView.isHidden = true
            additionalImageView.image = nil
        }
        guard publicKey != nil || openGroupProfilePicture != nil else { return }
        imageView.image = useFallbackPicture ? nil : (openGroupProfilePicture ?? getProfilePicture(of: size, for: publicKey))
        imageView.backgroundColor = useFallbackPicture ? UIColor(rgbHex: 0x353535) : Colors.unimportant
        imageView.layer.cornerRadius = 3
        additionalImageView.layer.cornerRadius = 3
        if self.size == CGFloat(86) {
            imageView.layer.cornerRadius = 37
            additionalImageView.layer.cornerRadius = 37
        }
        if size == 37 {
            imageView.layer.cornerRadius = 18.5
            additionalImageView.layer.cornerRadius = 18.5
        }
        
        if size == 55 {
            imageView.layer.cornerRadius = 27.5
            additionalImageView.layer.cornerRadius = 27.5
        }
        
        if size == 36 {
            imageView.layer.cornerRadius = 18
            additionalImageView.layer.cornerRadius = 18
        }
        
        if size == 22 {
            imageView.layer.cornerRadius = 11
            additionalImageView.layer.cornerRadius = 11
        }
        
        imageView.contentMode = useFallbackPicture ? .center : .scaleAspectFit
        if useFallbackPicture {
            switch size {
                case Values.smallProfilePictureSize..<Values.mediumProfilePictureSize: imageView.image = #imageLiteral(resourceName: "96x96")
                case Values.mediumProfilePictureSize..<Values.largeProfilePictureSize: imageView.image = #imageLiteral(resourceName: "192x192")
                default: imageView.image = #imageLiteral(resourceName: "logo")
            }
        }
        if isNoteToSelfImage {
            imageView.image = UIImage(named: "ic_noteToSelf")
            imageView.backgroundColor = Colors.smallBackGroundViewCellColor
            imageView.contentMode = .center
            isNoteToSelfImage = false
        }
    }
    
    // MARK: Convenience
    private func getImageView() -> UIImageView {
        let result = UIImageView()
        result.layer.masksToBounds = true
        result.backgroundColor = Colors.unimportant
        result.contentMode = .scaleAspectFit
        return result
    }
    
    @objc public func getProfilePicture() -> UIImage? {
        return hasTappableProfilePicture ? imageView.image : nil
    }
    
    
    func getgroupImage(of size: CGFloat, for publicKey: String, displayName: String) -> UIImage? {
        guard !publicKey.isEmpty else { return nil }
        return Identicon.generatePlaceholderIcon(seed: publicKey, text: displayName, size: size)
    }
    
    
}
