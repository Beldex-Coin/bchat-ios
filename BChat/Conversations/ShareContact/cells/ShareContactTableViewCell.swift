// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit

final class ShareContactTableViewCell: UITableViewCell {

    static let identifier = "ShareContactTableViewCell"
    
    // MARK: - UI Elements
    
    let profileImageView = ProfilePictureView()
    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let verifiedImageView = UIImageView()
    let checkboxButton = UIButton()
    let chatButton = UIButton()
    let removeContactButton = UIButton()
    
    // MARK: - Properties
    
    var isContactSelected: Bool = false
    var checkboxToggleSelection: (() -> Void)?
    var chatToggle: (() -> Void)?
    var removeContactToggle: (() -> Void)?
    var threadViewModel: ThreadViewModel! { didSet { update() } }
    var state: SharedContactState?
    var publicKey = ""
    
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
        
        checkboxButton.isHidden = true
        checkboxButton.setImage(UIImage(named: "contact_uncheck"), for: .normal)
        checkboxButton.setImage(UIImage(named: "contact_check"), for: .selected)
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        
        chatButton.isHidden = true
        chatButton.setImage(UIImage(named: "contact_chat"), for: .normal)
        chatButton.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        
        removeContactButton.isHidden = true
        removeContactButton.setImage(UIImage(named: "contact_delete"), for: .normal)
        removeContactButton.addTarget(self, action: #selector(removeContactTapped), for: .touchUpInside)
        removeContactButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStackView = UIStackView(arrangedSubviews: [checkboxButton, chatButton, removeContactButton])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.spacing = 5
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonStackView)
        
        contentView.addSubview(containerView)
        containerView.addSubViews(profileImageView, verifiedImageView, nameLabel, addressLabel, buttonStackView)
        
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
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -80),
            
            addressLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            addressLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3),
            addressLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -80),
            
            buttonStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            checkboxButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            chatButton.widthAnchor.constraint(equalToConstant: 24),
            chatButton.heightAnchor.constraint(equalToConstant: 22),
            chatButton.centerYAnchor.constraint(equalTo: buttonStackView.centerYAnchor),
            
            removeContactButton.widthAnchor.constraint(equalToConstant: 24),
            removeContactButton.heightAnchor.constraint(equalToConstant: 22),
            removeContactButton.centerYAnchor.constraint(equalTo: buttonStackView.centerYAnchor)
        ])
        
        verifiedImageView.pin(.trailing, to: .trailing, of: profileImageView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: profileImageView, withInset: 3)
    }
    
    // MARK: - Event Handlers

    @objc private func checkboxTapped() {
        checkboxToggleSelection?()
    }
    
    @objc private func chatTapped() {
        chatToggle?()
    }
    
    @objc private func removeContactTapped() {
        removeContactToggle?()
    }
    
    // MARK: - Update Cell Items
    
    func update() {
        AssertIsOnMainThread()
        
        checkboxButton.isHidden = state == .fromChat
        chatButton.isHidden = state == .fromAttachment
        removeContactButton.isHidden = state == .fromAttachment
        
        profileImageView.publicKey = publicKey
        profileImageView.update()
        
        let contact: Contact? = Storage.shared.getContact(with: publicKey)
        nameLabel.text = contact?.displayName(for: .regular) ?? publicKey
        addressLabel.text = publicKey.truncateMiddle()
        
        if let _ = contact, let isBnsUser = contact?.isBnsHolder {
            profileImageView.layer.borderWidth = isBnsUser ? Values.borderThickness : 0
            profileImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
            verifiedImageView.isHidden = isBnsUser ? false : true
        } else {
            verifiedImageView.isHidden = true
        }
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
}

