// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class MessageRequestCollectionViewCell: UICollectionViewCell {
    
    static let reuseidentifier = "MessageRequestCollectionViewCell"

    lazy var profileImageView = ProfilePictureView()
    
    lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_close_new"), for: .normal)
        return button
    }()
    
    lazy var nameLabel: UILabel = {
       let result = UILabel()
        result.textColor = Colors.titleColor3
       result.font = Fonts.boldOpenSans(ofSize: 12)
       result.textAlignment = .center
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    var removeCallback: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(removeButton)
        contentView.addSubview(nameLabel)
        
        let profilePictureViewSize = CGFloat(44)
        profileImageView.set(.width, to: profilePictureViewSize)
        profileImageView.set(.height, to: profilePictureViewSize)
        profileImageView.size = profilePictureViewSize
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 22
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            profileImageView.heightAnchor.constraint(equalToConstant: 44),
            profileImageView.widthAnchor.constraint(equalToConstant: 44),
            removeButton.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -4),
            removeButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 6),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func removeButtonTapped(_ sender: UIButton) {
        removeCallback?()
    }
}
