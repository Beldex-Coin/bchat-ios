// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class CreateSecretGroupTableViewCell: UITableViewCell {
    
    var publicKey = ""
    
    var selectionButtonCallback: (() -> Void)?

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
       stackView.backgroundColor = Colors.viewBackgroundColorSocialGroup
       stackView.layer.cornerRadius = 26
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColor3.cgColor
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
        result.textColor = Colors.titleColor3
       result.font = Fonts.OpenSans(ofSize: 16)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var selectionButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setBackgroundImage(UIImage(named: "ic_button_normal"), for: .normal)
        button.setBackgroundImage(UIImage(named: "ic_button_selected"), for: .selected)
        button.addTarget(self, action: #selector(selectionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    func setUPLayout() {
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(profileImageView, nameLabel, selectionButton, verifiedImageView)
        let profilePictureViewSize = CGFloat(36)
        profileImageView.set(.width, to: profilePictureViewSize)
        profileImageView.set(.height, to: profilePictureViewSize)
        profileImageView.size = profilePictureViewSize
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 18
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2.5),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2.5),
            profileImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 10),
            profileImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -44),
            selectionButton.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            selectionButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -14),
        ])
        
        verifiedImageView.pin(.trailing, to: .trailing, of: profileImageView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: profileImageView, withInset: 3)
    }
    
    // MARK: Updating
    func update() {
        profileImageView.publicKey = publicKey
        profileImageView.update()
        nameLabel.text = Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
    }
    
    @objc private func selectionButtonTapped(_ sender: UIButton) {
        selectionButtonCallback?()
    }
    
}
