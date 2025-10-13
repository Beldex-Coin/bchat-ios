// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

final class SettingsTableViewCell: UITableViewCell {
    static let identifier = "SettingsTableViewCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    
    var switchChanged: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        backgroundColor = Colors.settingsCellBackgroundColor
        selectionStyle = .none
        
        iconView.tintColor = isLightMode ? .black : .white
        iconView.contentMode = .scaleAspectFit
        
        titleLabel.font = Fonts.regularOpenSans(ofSize: 14)
        titleLabel.textColor = Colors.settingsCellLabelColor
        
        subtitleLabel.font = Fonts.semiOpenSans(ofSize: 12)
        subtitleLabel.textColor = Colors.settingsDescriptionCellLabelColor
        subtitleLabel.numberOfLines = 0
        
        toggleSwitch.onTintColor = Colors.switchBackgroundColor
        toggleSwitch.transform = CGAffineTransform(scaleX: 0.80, y: 0.75)
        toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 5
        
        contentView.addSubview(iconView)
        contentView.addSubview(stack)
        contentView.addSubview(toggleSwitch)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            
            stack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            stack.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -8),
            
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func switchValueChanged() {
        switchChanged?()
    }
    
    func configure(with item: SettingItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        iconView.image = UIImage(named: item.iconName)?.withRenderingMode(.alwaysTemplate)
        
        toggleSwitch.isOn = item.isOn
        toggleSwitch.isEnabled = item.isEnabled
        
        if item.title == SettingInfo.payAsYouChat.title {
            toggleSwitch.isOn = item.isOn && SSKPreferences.areWalletEnabled
            toggleSwitch.isEnabled = SSKPreferences.areWalletEnabled
        }
        
        toggleSwitch.thumbTintColor = toggleSwitch.isOn ? Colors.bothGreenColor : Colors.switchOffBackgroundColor
        
        iconView.tintColor = !item.isToggleSwitch ? .red : isLightMode ? .black : .white
        toggleSwitch.isHidden = !item.isToggleSwitch
        subtitleLabel.isHidden = !item.isToggleSwitch
    }
}
