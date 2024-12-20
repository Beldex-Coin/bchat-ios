// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class SideMenuTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "SideMenuTableViewCell"
    
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
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var betaTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = .black
        result.backgroundColor = Colors.betaBackgroundColor
        result.text = "BETA"
        result.font = Fonts.semiOpenSans(ofSize: 8)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.set(.width, to: 40)
        result.set(.height, to: 16)
        result.clipsToBounds = true
        result.layer.cornerRadius = 4
        return result
    }()
    
    lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 28)
        result.set(.height, to: 28)
        result.layer.masksToBounds = true
        result.contentMode = .center
        return result
    }()
    
    func setUPLayout() {
        
        contentView.addSubViews(titleLabel, iconImageView, betaTitleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            
            betaTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            betaTitleLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: -2),
        ])
    }
}

