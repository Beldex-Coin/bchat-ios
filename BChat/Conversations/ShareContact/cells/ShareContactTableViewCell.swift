// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit

class ShareContactTableViewCell: UITableViewCell {

    static let identifier = "ShareContactTableViewCell"
    
    let profileImageView = ProfilePictureView()
    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let verifiedImageView = UIImageView()
    
    lazy var checkbox: UIButton = {
        let button = UIButton()
        //button.setTitle("", for: .normal)
//        button.backgroundColor = .clear
        button.setBackgroundImage(UIImage(named: "contact_uncheck"), for: .normal)
        button.setBackgroundImage(UIImage(named: "contact_check"), for: .selected)
        button.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var isContactSelected: Bool = false
    var toggleSelection: (() -> Void)?
    var threadViewModel: ThreadViewModel! { didSet { update() } }
    
    var publicKey = ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        let containerView = UIView()
        containerView.layer.cornerRadius = 31
        containerView.layer.borderColor = Colors.borderColor3.cgColor
        containerView.layer.borderWidth = 1
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        verifiedImageView.set(.width, to: 18)
        verifiedImageView.set(.height, to: 18)
        verifiedImageView.contentMode = .center
        verifiedImageView.image = UIImage(named: "ic_verified_image")

        nameLabel.textColor = Colors.titleColor3
        nameLabel.font = Fonts.semiOpenSans(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        addressLabel.textColor = Colors.textFieldPlaceHolderColor
        addressLabel.font = Fonts.regularOpenSans(ofSize: 12)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(containerView)
        containerView.addSubViews(profileImageView, nameLabel, addressLabel, checkbox, verifiedImageView)
        let profilePictureViewSize = CGFloat(36)
        profileImageView.set(.width, to: profilePictureViewSize)
        profileImageView.set(.height, to: profilePictureViewSize)
        profileImageView.size = profilePictureViewSize
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 18
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            profileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60),
            addressLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            addressLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60),
            checkbox.widthAnchor.constraint(equalToConstant: 24),
            checkbox.heightAnchor.constraint(equalToConstant: 24),
            checkbox.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkbox.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
        ])
        
        verifiedImageView.pin(.trailing, to: .trailing, of: profileImageView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: profileImageView, withInset: 3)
    }

    @objc private func checkboxTapped() {
        toggleSelection?()
    }
    
    private func getDisplayName() -> String {
        if threadViewModel.threadRecord.isNoteToSelf() {
            return NSLocalizedString("NOTE_TO_SELF", comment: "")
        } else {
            let hexEncodedPublicKey: String = threadViewModel.contactBChatID!
            let displayName: String = (Storage.shared.getContact(with: hexEncodedPublicKey)?.displayName(for: .regular) ?? hexEncodedPublicKey)
            let middleTruncatedHexKey: String = "\(hexEncodedPublicKey.prefix(4))...\(hexEncodedPublicKey.suffix(4))"
            return (displayName == hexEncodedPublicKey ? middleTruncatedHexKey : displayName)
        }
    }
    
    func update() {
        AssertIsOnMainThread()
        profileImageView.publicKey = publicKey
        profileImageView.update()
        nameLabel.text = Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
        addressLabel.text = publicKey
    }
}

