
final class MentionSelectionView : UIView, UITableViewDataSource, UITableViewDelegate {
    var candidates: [Mention] = [] {
        didSet {
            tableView.isScrollEnabled = (candidates.count > 5)
            tableView.reloadData()
        }
    }
    var openGroupServer: String?
    var openGroupChannel: UInt64?
    var openGroupRoom: String?
    weak var delegate: MentionSelectionViewDelegate?
    
    // MARK: Components
    lazy var tableView: UITableView = { // TODO: Make this private
        let result = UITableView()
        result.dataSource = self
        result.delegate = self
        result.register(MentionsCell.self, forCellReuseIdentifier: MentionsCell.identifier)
        result.separatorStyle = .none
        result.backgroundColor = .clear
        result.showsVerticalScrollIndicator = false
        return result
    }()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViewHierarchy()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViewHierarchy()
    }
    
    private func setUpViewHierarchy() {
        // Table view
        addSubview(tableView)
        tableView.pin(to: self)
        // Top separator
        let topSeparator = UIView()
        topSeparator.backgroundColor = Colors.separator
        topSeparator.set(.height, to: Values.separatorThickness)
        addSubview(topSeparator)
        topSeparator.pin(.leading, to: .leading, of: self)
        topSeparator.pin(.top, to: .top, of: self)
        topSeparator.pin(.trailing, to: .trailing, of: self)
        // Bottom separator
        let bottomSeparator = UIView()
        bottomSeparator.backgroundColor = Colors.separator
        bottomSeparator.set(.height, to: Values.separatorThickness)
        addSubview(bottomSeparator)
        bottomSeparator.pin(.leading, to: .leading, of: self)
        bottomSeparator.pin(.trailing, to: .trailing, of: self)
        bottomSeparator.pin(.bottom, to: .bottom, of: self)
    }
    
    // MARK: Data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return candidates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MentionsCell.identifier) as! MentionsCell
        let mentionCandidate = candidates[indexPath.row]
        cell.mentionCandidate = mentionCandidate
        cell.openGroupServer = openGroupServer
        cell.openGroupChannel = openGroupChannel
        cell.openGroupRoom = openGroupRoom
        cell.separator.isHidden = (indexPath.row == (candidates.count - 1))
        return cell
    }
    
    // MARK: Interaction
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mentionCandidate = candidates[indexPath.row]
        delegate?.handleMentionSelected(mentionCandidate, from: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
}

// MARK: - Cell

final class MentionsCell: UITableViewCell {

    static let identifier = "MentionsCell"
    
    // MARK: - UI Elements
    
    let profileImageView = ProfilePictureView()
    let verifiedImageView = UIImageView()
    
    private lazy var moderatorIconImageView = UIImageView(image: #imageLiteral(resourceName: "Crown"))
    
    private lazy var nameLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = Fonts.regularOpenSans(ofSize: Values.smallFontSize)
        result.lineBreakMode = .byTruncatingTail
        return result
    }()
    
    lazy var separator: UIView = {
        let result = UIView()
        result.backgroundColor = Colors.separator
        result.set(.height, to: Values.separatorThickness)
        return result
    }()
    
    // MARK: - Properties
    
    var mentionCandidate = Mention(publicKey: "", displayName: "") { didSet { update() } }
    var openGroupServer: String?
    var openGroupChannel: UInt64?
    var openGroupRoom: String?
    
    
    // MARK: - Initialize
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Cell

    private func setupCell() {
        backgroundColor = .clear
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .clear
        self.selectedBackgroundView = selectedBackgroundView
        
        let profilePictureViewSize = CGFloat(36)
        profileImageView.set(.width, to: profilePictureViewSize)
        profileImageView.set(.height, to: profilePictureViewSize)
        profileImageView.size = profilePictureViewSize
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 18
        
        verifiedImageView.set(.width, to: 18)
        verifiedImageView.set(.height, to: 18)
        verifiedImageView.contentMode = .center
        verifiedImageView.image = UIImage(named: "ic_verified_image")
        
        contentView.addSubViews(profileImageView, verifiedImageView)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
        verifiedImageView.pin(.trailing, to: .trailing, of: profileImageView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: profileImageView, withInset: 3)
        
        // Moderator icon image view
        moderatorIconImageView.set(.width, to: 20)
        moderatorIconImageView.set(.height, to: 20)
        contentView.addSubview(moderatorIconImageView)
        moderatorIconImageView.pin(.trailing, to: .trailing, of: profileImageView, withInset: 1)
        moderatorIconImageView.pin(.bottom, to: .bottom, of: profileImageView, withInset: 4.5)
        
        // Separator
        contentView.addSubview(separator)
        separator.pin(.leading, to: .leading, of: self)
        separator.pin(.trailing, to: .trailing, of: self)
        separator.pin(.bottom, to: .bottom, of: self)
    }
    
    // MARK: - Update Cell Items
    
    func update() {
        AssertIsOnMainThread()
        
        nameLabel.text = mentionCandidate.displayName
        profileImageView.publicKey = mentionCandidate.publicKey
        profileImageView.update()
        
        let contact: Contact? = Storage.shared.getContact(with: mentionCandidate.publicKey)
        if let _ = contact, let isBnsUser = contact?.isBnsHolder {
            profileImageView.layer.borderWidth = isBnsUser ? Values.borderThickness : 0
            profileImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
            verifiedImageView.isHidden = isBnsUser ? false : true
        } else {
            verifiedImageView.isHidden = true
        }
        
        if let server = openGroupServer, let room = openGroupRoom {
            let isUserModerator = OpenGroupAPIV2.isUserModerator(mentionCandidate.publicKey, for: room, on: server)
            moderatorIconImageView.isHidden = !isUserModerator
        } else {
            moderatorIconImageView.isHidden = true
        }
    }
}

private extension MentionSelectionView {
    
    final class Cell : UITableViewCell {
        var mentionCandidate = Mention(publicKey: "", displayName: "") { didSet { update() } }
        var openGroupServer: String?
        var openGroupChannel: UInt64?
        var openGroupRoom: String?
        
        // MARK: Components
        private lazy var profilePictureView = ProfilePictureView()
        
        private lazy var moderatorIconImageView = UIImageView(image: #imageLiteral(resourceName: "Crown"))
        
        private lazy var displayNameLabel: UILabel = {
            let result = UILabel()
            result.textColor = Colors.text
            result.font = Fonts.regularOpenSans(ofSize: Values.smallFontSize)
            result.lineBreakMode = .byTruncatingTail
            return result
        }()
        
        lazy var separator: UIView = {
            let result = UIView()
            result.backgroundColor = Colors.separator
            result.set(.height, to: Values.separatorThickness)
            return result
        }()
        
        // MARK: Initialization
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setUpViewHierarchy()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setUpViewHierarchy()
        }
        
        private func setUpViewHierarchy() {
            // Cell background color
            backgroundColor = .clear
            // Highlight color
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = .clear
            self.selectedBackgroundView = selectedBackgroundView
            // Profile picture image view
            let profilePictureViewSize = Values.smallProfilePictureSize
            profilePictureView.set(.width, to: profilePictureViewSize)
            profilePictureView.set(.height, to: profilePictureViewSize)
            profilePictureView.size = profilePictureViewSize
            // Main stack view
            let mainStackView = UIStackView(arrangedSubviews: [ profilePictureView, displayNameLabel ])
            mainStackView.axis = .horizontal
            mainStackView.alignment = .center
            mainStackView.spacing = Values.mediumSpacing
            mainStackView.set(.height, to: profilePictureViewSize)
            contentView.addSubview(mainStackView)
            mainStackView.pin(.leading, to: .leading, of: contentView, withInset: Values.mediumSpacing)
            mainStackView.pin(.top, to: .top, of: contentView, withInset: Values.smallSpacing)
            contentView.pin(.trailing, to: .trailing, of: mainStackView, withInset: Values.mediumSpacing)
            contentView.pin(.bottom, to: .bottom, of: mainStackView, withInset: Values.smallSpacing)
            mainStackView.set(.width, to: UIScreen.main.bounds.width - 2 * Values.mediumSpacing)
            // Moderator icon image view
            moderatorIconImageView.set(.width, to: 20)
            moderatorIconImageView.set(.height, to: 20)
            contentView.addSubview(moderatorIconImageView)
            moderatorIconImageView.pin(.trailing, to: .trailing, of: profilePictureView, withInset: 1)
            moderatorIconImageView.pin(.bottom, to: .bottom, of: profilePictureView, withInset: 4.5)
            // Separator
            addSubview(separator)
            separator.pin(.leading, to: .leading, of: self)
            separator.pin(.trailing, to: .trailing, of: self)
            separator.pin(.bottom, to: .bottom, of: self)
        }
        
        // MARK: Updating
        private func update() {
            displayNameLabel.text = mentionCandidate.displayName
            profilePictureView.publicKey = mentionCandidate.publicKey
            profilePictureView.update()
            if let server = openGroupServer, let room = openGroupRoom {
                let isUserModerator = OpenGroupAPIV2.isUserModerator(mentionCandidate.publicKey, for: room, on: server)
                moderatorIconImageView.isHidden = !isUserModerator
            } else {
                moderatorIconImageView.isHidden = true
            }
        }
    }
}

// MARK: - Delegate

protocol MentionSelectionViewDelegate : class {
    
    func handleMentionSelected(_ mention: Mention, from view: MentionSelectionView)
}
