// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

final class SettingsTableViewCell: UITableViewCell {
    static let identifier = "SettingsTableViewCell"
    
    private let containerView = UIView()
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
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = Colors.settingsCellBackgroundColor
        
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
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(stack)
        containerView.addSubview(toggleSwitch)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -0),
            
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            
            stack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 22),
            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -22),
            stack.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -8),
            
            toggleSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
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
        
        subtitleLabel.isHidden = !item.isToggleSwitch
        toggleSwitch.isHidden = !item.isToggleSwitch
        iconView.tintColor = !item.isToggleSwitch ? .red : isLightMode ? .black : .white
        toggleSwitch.thumbTintColor = toggleSwitch.isOn ? Colors.bothGreenColor : Colors.switchOffBackgroundColor
    }
    
    func updateContainerView(with indexPath: IndexPath, item: SettingItem) {
        if item.title == SettingInfo.screenSecurity.title ||
            item.title == SettingInfo.startWallet.title ||
            item.title == SettingInfo.readReceipts.title {
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if item.title == SettingInfo.incognitoKeyboard.title ||
            item.title == SettingInfo.payAsYouChat.title ||
            item.title == SettingInfo.clearConversationHistory.title {
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
}
