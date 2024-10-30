// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewChatTableViewCell: UITableViewCell {
    
        var publicKey = ""
    
    var isShowingGlobalSearchResult = false
    var threadViewModel: ThreadViewModel! {
        didSet {
            isShowingGlobalSearchResult ? updateForSearchResult() : update()
        }
    }
        
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)

            // Configure the view for the selected state
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            self.setUPLayout()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        
        lazy var profileImageView = ProfilePictureView()
        
        lazy var verifiedImageView: UIImageView = {
            let result = UIImageView()
            result.set(.width, to: 18)
            result.set(.height, to: 18)
            result.contentMode = .center
            result.image = UIImage(named: "ic_verified_image")
            return result
        }()
       
        lazy var nameLabel: UILabel = {
           let result = UILabel()
            result.textColor = Colors.titleColor3
           result.font = Fonts.semiOpenSans(ofSize: 14)
           result.textAlignment = .left
           result.translatesAutoresizingMaskIntoConstraints = false
           return result
       }()
        
        
        
        func setUPLayout() {
            contentView.addSubViews(profileImageView, nameLabel, verifiedImageView)
            let profilePictureViewSize = CGFloat(36)
            profileImageView.set(.width, to: profilePictureViewSize)
            profileImageView.set(.height, to: profilePictureViewSize)
            profileImageView.size = profilePictureViewSize
            profileImageView.layer.masksToBounds = true
            profileImageView.layer.cornerRadius = 18
            
            NSLayoutConstraint.activate([
        
                profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
                profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 14),
                nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -44),
                
            ])
            
            verifiedImageView.pin(.trailing, to: .trailing, of: profileImageView, withInset: 2)
            verifiedImageView.pin(.bottom, to: .bottom, of: profileImageView, withInset: 3)
        }
        
        // MARK: Updating
//        func update() {
//            profileImageView.publicKey = publicKey
//            profileImageView.update()
//            nameLabel.text = Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
//        }
    
    private func getDisplayName() -> String {
        if threadViewModel.isGroupThread {
            if threadViewModel.name.isEmpty {
                return "Unknown Group"
            }
            else {
                return threadViewModel.name
            }
        }
        else {
            if threadViewModel.threadRecord.isNoteToSelf() {
                return NSLocalizedString("NOTE_TO_SELF", comment: "")
            }
            else {
                let hexEncodedPublicKey: String = threadViewModel.contactBChatID!
                let displayName: String = (Storage.shared.getContact(with: hexEncodedPublicKey)?.displayName(for: .regular) ?? hexEncodedPublicKey)
                let middleTruncatedHexKey: String = "\(hexEncodedPublicKey.prefix(4))...\(hexEncodedPublicKey.suffix(4))"
                return (displayName == hexEncodedPublicKey ? middleTruncatedHexKey : displayName)
            }
        }
    }
    
    
    private func updateForSearchResult() {
//        AssertIsOnMainThread()
//        guard let thread = threadViewModel?.threadRecord else { return }
//        iconImageView.update(for: thread)
//        messageCountLabel.isHidden = true
    }
    
    private func update() {
        AssertIsOnMainThread()
        guard let thread = threadViewModel?.threadRecord else { return }
        profileImageView.update(for: thread)
        nameLabel.text = getDisplayName().firstCharacterUpperCase()
    }
        

}
