// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewSettingsTableViewCell: UITableViewCell {
    
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
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var smallDotView: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = UIColor(hex: 0x00BD40)
        View.isHidden = true
        View.layer.cornerRadius = 4
        return View
    }()
    
    lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 27)
        result.set(.height, to: 27)
        result.layer.masksToBounds = true
        result.contentMode = .center
        return result
    }()
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var arrowButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setBackgroundImage(UIImage(named: "ic_arrow"), for: .normal)
        return button
    }()
    
    
    func setUPLayout() {
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(iconImageView, titleLabel, arrowButton, smallDotView)
        
        NSLayoutConstraint.activate([
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            iconImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 29),
            iconImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 20),
            
            smallDotView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            smallDotView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6),
            smallDotView.heightAnchor.constraint(equalToConstant: 8),
            smallDotView.widthAnchor.constraint(equalToConstant: 8),
            
            arrowButton.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            arrowButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -31),
            
        ])
    }
    
    
}
