// Copyright © 2026 Beldex International Limited OU. All rights reserved.


class ArchiveChatsSettingTableviewCell: UITableViewCell {
    
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.mainBackGroundColor2
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.settingsCellLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var titleDescriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.settingsDescriptionCellLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.switchBackgroundColor
        toggle.transform = CGAffineTransform(scaleX: 0.80, y: 0.75)
        return toggle
    }()
    
    private lazy var stackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ titleLabel, titleDescriptionLabel ])
        result.axis = .vertical
        result.spacing = 5
        result.distribution = .fill
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(toggleSwitch)
        backGroundView.addSubview(stackView)
        
        if toggleSwitch.isOn == true {
            toggleSwitch.thumbTintColor = Colors.bothGreenColor
        } else {
            toggleSwitch.thumbTintColor = Colors.switchOffBackgroundColor
        }
        
        // Set up constraints
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -8),
            toggleSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            stackView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 22),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -22),
        ])
    }
}
