// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class SecretGroupTableViewCell: UITableViewCell {
    
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        self.setUPLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
     lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 36
        return stackView
    }()
    
     lazy var profileImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_test")
         result.set(.width, to: 40)
         result.set(.height, to: 40)
        result.layer.masksToBounds = true
        result.contentMode = .scaleToFill
         result.layer.cornerRadius = 20
        return result
    }()
    
     lazy var nameLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var lastMessageLabel: UILabel = {
       let result = UILabel()
       result.textColor = UIColor(hex: 0xA7A7BA)
       result.font = Fonts.OpenSans(ofSize: 12)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var dateLabel: UILabel = {
       let result = UILabel()
       result.textColor = UIColor(hex: 0xA7A7BA)
       result.font = Fonts.OpenSans(ofSize: 12)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var messageCountLabel: UILabel = {
       let result = PaddingLabel()
       result.textColor = UIColor(hex: 0xFFFFFF)
       result.font = Fonts.boldOpenSans(ofSize: 11)
       result.textAlignment = .center
       result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x00BD40)
        result.layer.masksToBounds = true
        result.layer.cornerRadius = 11
        result.paddingLeft = 5
        result.paddingRight = 5
       return result
   }()
    
    
    func setUPLayout() {
        nameLabel.text = "Group Name"
        lastMessageLabel.text = "Lorem ipsum dolor sit amet..."
        dateLabel.text = "2/2/23"
        messageCountLabel.text = "10"
        
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(profileImageView, nameLabel, lastMessageLabel, dateLabel, messageCountLabel)
        
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            profileImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            profileImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 17),
            
            lastMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            lastMessageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 0),
            //            lastMessageLabel.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 0),
            
            dateLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -28),
            dateLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -16),
            
            messageCountLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 14),
            messageCountLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -29),
            messageCountLabel.heightAnchor.constraint(equalToConstant: 22),
        ])
    }
}
