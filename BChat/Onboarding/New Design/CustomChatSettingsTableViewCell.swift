// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class CustomChatSettingsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    lazy var leftIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    lazy var rightIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var rightTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.chatSettingsGrayColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var rightSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.switchBackgroundColor
        toggle.transform = CGAffineTransform(scaleX: 0.80, y: 0.75)
        return toggle
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setUPCellUI()
    }
    
    
    func setUPCellUI() {
        contentView.addSubViews(leftIconImageView, titleLabel, rightIconImageView, rightTitleLabel, rightSwitch)
        titleLabel.text = "Search Conversation"
        rightTitleLabel.text = "Default"
        leftIconImageView.image = UIImage(named: "ic_search_setting")
        rightIconImageView.image = UIImage(named: "chatSetting_rightArrow")
        
        NSLayoutConstraint.activate([
            leftIconImageView.heightAnchor.constraint(equalToConstant: 22),
            leftIconImageView.widthAnchor.constraint(equalToConstant: 22),
            leftIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            leftIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leftIconImageView.trailingAnchor, constant: 26),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -63),
            rightIconImageView.heightAnchor.constraint(equalToConstant: 25),
            rightIconImageView.widthAnchor.constraint(equalToConstant: 25),
            rightIconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            rightIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            rightTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
]            rightSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rightSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
        self.rightTitleLabel.isHidden = true
        self.rightIconImageView.isHidden = true
        self.rightSwitch.isHidden = true
        
        if rightSwitch.isOn == true {
            rightSwitch.thumbTintColor = Colors.bothGreenColor
        } else {
            rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
        }
    }
    

}


class NotifyChatSettingsTableViewCell: UITableViewCell {
    
    
    lazy var leftIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
        
    lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.chatSettingsGrayColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    lazy var rightSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.switchBackgroundColor
        toggle.transform = CGAffineTransform(scaleX: 0.80, y: 0.75)
        return toggle
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setUPCellUI()
    }
    
    func setUPCellUI() {
        
        contentView.addSubViews(leftIconImageView, titleLabel, discriptionLabel, rightSwitch)
        
        NSLayoutConstraint.activate([
            leftIconImageView.heightAnchor.constraint(equalToConstant: 22),
            leftIconImageView.widthAnchor.constraint(equalToConstant: 22),
            leftIconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            leftIconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
            titleLabel.leadingAnchor.constraint(equalTo: leftIconImageView.trailingAnchor, constant: 26),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -63),
            rightSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rightSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            discriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            discriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -76),
            discriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
        
        if rightSwitch.isOn == true {
            rightSwitch.thumbTintColor = Colors.bothGreenColor
        } else {
            rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
        }
        
    }
    
    
}


class DisappearingChatSettingsTableViewCell: UITableViewCell {
    
    
    lazy var leftIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
        
    lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.chatSettingsGrayColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    lazy var rightSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.switchBackgroundColor
        toggle.transform = CGAffineTransform(scaleX: 0.80, y: 0.75)
        return toggle
    }()
    
    
     lazy var topView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
        
     lazy var bottomView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var stackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .fill
        result.distribution = .fill
        result.spacing = 21
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var leftIconImageViewForSlider: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLabelForSlider: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    lazy var rightTitleLabelForSlider: UILabel = {
        let result = UILabel()
        result.textColor = Colors.chatSettingsGrayColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setUPCellUI()
    }
    
    func setUPCellUI() {
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(topView)
        stackView.addArrangedSubview(bottomView)
        topView.addSubViews(leftIconImageView, titleLabel, discriptionLabel, rightSwitch)
        bottomView.addSubViews(leftIconImageViewForSlider, titleLabelForSlider, rightTitleLabelForSlider)
        leftIconImageViewForSlider.image = UIImage(named: "chatSetting_disSlider")
        titleLabelForSlider.text = "Disappear"
        rightTitleLabelForSlider.text = "after 1 day"
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leftIconImageView.heightAnchor.constraint(equalToConstant: 22),
            leftIconImageView.widthAnchor.constraint(equalToConstant: 22),
            leftIconImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 22),
            leftIconImageView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 11),
            
            titleLabel.leadingAnchor.constraint(equalTo: leftIconImageView.trailingAnchor, constant: 26),
            titleLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -63),
            rightSwitch.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
            rightSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            discriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            discriptionLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -76),
            discriptionLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -6),
            leftIconImageViewForSlider.heightAnchor.constraint(equalToConstant: 22),
            leftIconImageViewForSlider.widthAnchor.constraint(equalToConstant: 22),
            leftIconImageViewForSlider.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 22),
            leftIconImageViewForSlider.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 0),
            titleLabelForSlider.leadingAnchor.constraint(equalTo: leftIconImageViewForSlider.trailingAnchor, constant: 26),
            titleLabelForSlider.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 0),
            titleLabelForSlider.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -70),
            rightTitleLabelForSlider.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -18),
            rightTitleLabelForSlider.centerYAnchor.constraint(equalTo: titleLabelForSlider.centerYAnchor),
        ])
        
        if rightSwitch.isOn == true {
            rightSwitch.thumbTintColor = Colors.bothGreenColor
        } else {
            rightSwitch.thumbTintColor = Colors.switchOffBackgroundColor
        }
        
    }
    
    
}


