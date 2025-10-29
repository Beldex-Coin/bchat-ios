// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit


final class ReactionListCell : UITableViewCell {
    
    var publicKey = ""
    var emoji = ""
    
    // MARK: Components
    lazy var profilePictureView = ProfilePictureView()

    private lazy var displayNameLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    lazy var verifiedImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 11)
        result.set(.height, to: 11)
        result.contentMode = .scaleAspectFit
        result.image = UIImage(named: "ic_verified_image")
        return result
    }()
    
    private lazy var emojiLabel: UILabel = {
        let result = UILabel()
        result.font = .systemFont(ofSize: Values.mediumFontSize)
        result.translatesAutoresizingMaskIntoConstraints = false
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
        // Background color
        backgroundColor = Colors.smallBackGroundViewCellColor
        // Highlight color
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .clear // Disabled for now
        self.selectedBackgroundView = selectedBackgroundView
        // Profile picture image view
        let profilePictureViewSize = CGFloat(22)
        profilePictureView.set(.width, to: 22)
        profilePictureView.set(.height, to: 22)
        profilePictureView.size = profilePictureViewSize
        profilePictureView.layer.cornerRadius = 11
        
        contentView.addSubViews(profilePictureView, displayNameLabel, verifiedImageView, emojiLabel)
        NSLayoutConstraint.activate([
            profilePictureView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profilePictureView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            profilePictureView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            displayNameLabel.leadingAnchor.constraint(equalTo: profilePictureView.trailingAnchor, constant: 12),
            displayNameLabel.centerYAnchor.constraint(equalTo: profilePictureView.centerYAnchor),
            displayNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -70),
            
            emojiLabel.centerYAnchor.constraint(equalTo: profilePictureView.centerYAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
        ])
        
        verifiedImageView.pin(.trailing, to: .trailing, of: profilePictureView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: profilePictureView, withInset: 3)

    }

    // MARK: Updating
    func update() {
        profilePictureView.publicKey = publicKey
        profilePictureView.update()
        displayNameLabel.text = publicKey == getUserHexEncodedPublicKey() ? "You \nTap to remove" : Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
        emojiLabel.text = emoji
    }
}
