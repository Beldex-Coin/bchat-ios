// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit

class ShareContactTableViewCell: UITableViewCell {

    static let identifier = "ShareContactTableViewCell"
    
    let profileImageView = ProfilePictureView()
    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let checkbox = UIButton(type: .custom)
    let verifiedImageView = UIImageView()
    
    var toggleSelection: (() -> Void)?
    
    var threadViewModel: ThreadViewModel! { didSet { update() } }
    
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

        let profilePictureViewSize = CGFloat(36)
        profileImageView.set(.width, to: profilePictureViewSize)
        profileImageView.set(.height, to: profilePictureViewSize)
        profileImageView.size = profilePictureViewSize
        profileImageView.layer.cornerRadius = 18
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        verifiedImageView.set(.width, to: 18)
        verifiedImageView.set(.height, to: 18)
        verifiedImageView.contentMode = .center
        verifiedImageView.image = UIImage(named: "ic_verified_image")

        nameLabel.textColor = Colors.titleColor3
        nameLabel.font = Fonts.semiOpenSans(ofSize: 16)

        addressLabel.textColor = Colors.textFieldPlaceHolderColor
        addressLabel.font = Fonts.regularOpenSans(ofSize: 12)

        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)

        let labelsStack = UIStackView(arrangedSubviews: [nameLabel, addressLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [profileImageView, verifiedImageView, labelsStack, checkbox])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(mainStack)
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 62),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
//            profileImageView.widthAnchor.constraint(equalToConstant: 36),
//            profileImageView.heightAnchor.constraint(equalToConstant: 36),
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            checkbox.widthAnchor.constraint(equalToConstant: 24),
            checkbox.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        verifiedImageView.pin(.trailing, to: .trailing, of: profileImageView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: profileImageView, withInset: 3)
    }

    func configure(with contact: [String]) {
//        nameLabel.text = contact.name
//        addressLabel.text = contact.address
//        //profileImageView.image = UIImage(named: contact.imageName)
//
//        let imageName = contact.isSelected ? "contact_check" : "contact_uncheck"
//        checkbox.setImage(UIImage(named: imageName), for: .normal)
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
    
    private func update() {
        AssertIsOnMainThread()
        guard let thread = threadViewModel?.threadRecord else { return }
        profileImageView.update(for: thread)
        nameLabel.text = getDisplayName().firstCharacterUpperCase()
        addressLabel.text = threadViewModel.contactBChatID
        
        if let contactThread: TSContactThread = thread as? TSContactThread {
            let contact: Contact? = Storage.shared.getContact(with: contactThread.contactBChatID())
            if let _ = contact, let isBnsUser = contact?.isBnsHolder {
                profileImageView.layer.borderWidth = isBnsUser ? Values.borderThickness : 0
                profileImageView.layer.borderColor = isBnsUser ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
                verifiedImageView.isHidden = isBnsUser ? false : true
            } else {
                setupImageView()
            }
        } else {
            setupImageView()
        }
    }
    
    private func setupImageView() {
        verifiedImageView.isHidden = true
        profileImageView.layer.borderWidth = 0
        profileImageView.layer.borderColor = UIColor.clear.cgColor
    }
}
