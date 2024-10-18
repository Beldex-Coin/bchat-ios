// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewMessageRequestTableViewCell: UITableViewCell {

    var threadViewModel: ThreadViewModel! {
        didSet {
            update()
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
    
    
    lazy var backGroundView: UIView = {
       let stackView = UIView()
       stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.cellGroundColor
       stackView.layer.cornerRadius = 30
       return stackView
   }()
    
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
        result.textColor = Colors.titleColor
       result.font = Fonts.OpenSans(ofSize: 14)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 7
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()

    lazy var acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_accept"), for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    lazy var declineButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x2C2C3B)
        button.addTarget(self, action: #selector(blockButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_decline"), for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x2C2C3B)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_delete"), for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    
    var deleteCallback: (() -> Void)?
    var acceptCallback: (() -> Void)?
    var blockCallback: (() -> Void)?
    
    
    func setUPLayout() {
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(profileImageView, nameLabel, buttonStackView, verifiedImageView)
        buttonStackView.addArrangedSubview(deleteButton)
        buttonStackView.addArrangedSubview(declineButton)
        buttonStackView.addArrangedSubview(acceptButton)
        
        let profilePictureViewSize = CGFloat(36)
        profileImageView.set(.width, to: profilePictureViewSize)
        profileImageView.set(.height, to: profilePictureViewSize)
        profileImageView.size = profilePictureViewSize
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 18
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            profileImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 14),
            profileImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 11),
            buttonStackView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -22),
            buttonStackView.heightAnchor.constraint(equalToConstant: 32),
            deleteButton.heightAnchor.constraint(equalToConstant: 32),
            deleteButton.widthAnchor.constraint(equalToConstant: 32),
            declineButton.heightAnchor.constraint(equalToConstant: 32),
            declineButton.widthAnchor.constraint(equalToConstant: 32),
            acceptButton.heightAnchor.constraint(equalToConstant: 32),
            acceptButton.widthAnchor.constraint(equalToConstant: 32)
        ])
        
        verifiedImageView.pin(.trailing, to: .trailing, of: profileImageView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: profileImageView, withInset: 3)
    }
    
    
    // MARK: Updating
    private func update() {
        AssertIsOnMainThread()
        guard let thread = threadViewModel?.threadRecord else { return }
        profileImageView.update(for: thread)
        nameLabel.text = getDisplayName()
    }
    
    private func getDisplayName() -> String {
        let hexEncodedPublicKey: String = threadViewModel.contactBChatID!
        let displayName: String = (Storage.shared.getContact(with: hexEncodedPublicKey)?.displayName(for: .regular) ?? hexEncodedPublicKey)
        let middleTruncatedHexKey: String = "\(hexEncodedPublicKey.prefix(4))...\(hexEncodedPublicKey.suffix(4))"
        return (displayName == hexEncodedPublicKey ? middleTruncatedHexKey : displayName)
    }
    
    
    @objc private func acceptButtonTapped(_ sender: UIButton) {
        acceptCallback?()
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        deleteCallback?()
    }
    
    @objc private func blockButtonTapped(_ sender: UIButton) {
        blockCallback?()
    }

}
