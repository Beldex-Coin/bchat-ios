// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class SideMenuProfileTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "SideMenuProfileTableViewCell"
    
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
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = Colors.cellGroundColor3
        View.layer.cornerRadius = 10
        return View
    }()
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var subTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 44)
        result.set(.height, to: 44)
        result.contentMode = .scaleToFill
        result.layer.masksToBounds = false
        result.layer.cornerRadius = 22
        result.clipsToBounds = true
        return result
    }()
    
    lazy var scanImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 33)
        result.set(.height, to: 33)
        result.contentMode = .center
        return result
    }()
    
    func setUPLayout() {
        
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, iconImageView, subTitleLabel, scanImageView)
        
        NSLayoutConstraint.activate([
            backGroundView.heightAnchor.constraint(equalToConstant: 75),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            backGroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            backGroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            
            iconImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 10),
            iconImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            
            scanImageView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -15),
            scanImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            
            titleLabel.trailingAnchor.constraint(equalTo: scanImageView.leadingAnchor, constant: -5),
            subTitleLabel.trailingAnchor.constraint(equalTo: scanImageView.leadingAnchor, constant: -5)
        ])
    }
}


