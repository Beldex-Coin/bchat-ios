// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class ChatSettingsTableViewCell: UITableViewCell {

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
        stackView.backgroundColor = Colors.cellGroundColor2
       stackView.layer.cornerRadius = 29
       return stackView
   }()
    
    lazy var profileImageView: UIImageView = {
       let result = UIImageView()
       result.image = UIImage(named: "")
        result.set(.width, to: 42)
        result.set(.height, to: 42)
       result.layer.masksToBounds = true
       result.contentMode = .scaleToFill
        result.layer.cornerRadius = 21
       return result
   }()
    
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
       result.font = Fonts.semiOpenSans(ofSize: 14)
       result.textAlignment = .left
       result.translatesAutoresizingMaskIntoConstraints = false
       return result
   }()
    
    lazy var adminButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setBackgroundImage(UIImage(named: "ic_groupAdmin"), for: .normal)
        return button
    }()
    
    
    func setUPLayout() {
        
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(profileImageView, nameLabel, adminButton, verifiedImageView)
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            profileImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 18),
            profileImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            
            nameLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 11),
            nameLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -100),
            
            adminButton.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            adminButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -19),
        ])
        
        verifiedImageView.pin(.trailing, to: .trailing, of: profileImageView, withInset: 2)
        verifiedImageView.pin(.bottom, to: .bottom, of: profileImageView, withInset: 3)
    }
    

}
