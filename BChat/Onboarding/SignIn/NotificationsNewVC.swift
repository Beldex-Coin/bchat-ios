// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import Sodium
import PromiseKit
import BChatMessagingKit

class NotificationsNewVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    @objc private lazy var tableView: UITableView = {
        let result = UITableView()
        result.dataSource = self
        result.delegate = self
        result.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        result.separatorStyle = .none
        result.backgroundColor = .clear
        result.translatesAutoresizingMaskIntoConstraints = false
        result.rowHeight = UITableView.automaticDimension
        return result
    }()
    
    let sectionNames = ["Notification Strategy", "Notification Sounds", "Notification Content"]
    
    var notificationStrategyTitleArray = ["Use Fast Mode"]
    var notificationStrategyDescArray = ["You will be notified for messaged reliably  and immediately using googles notification servers."]
    
    var notificationSoundsTitleArray = ["Message Sound","Play while App is open"]
    
    var notificationContentTitleArray = ["Show"]
    var notificationContentDescArray = ["The information shown in notifications when your phone is locked."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorNew
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Notifications"
        setUpTopCornerRadius()
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: -15),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0)
        ])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return notificationStrategyTitleArray.count
        }else if section == 1{
            return notificationSoundsTitleArray.count
        }else {
            return notificationContentTitleArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = NotificationTableCell2(style: .default, reuseIdentifier: "NotificationTableCell2")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.resultTitleLabel.isHidden = true
            cell.titleLabel.text = notificationStrategyTitleArray[indexPath.row]
            cell.titleDescriptionLabel.text = notificationStrategyDescArray[indexPath.row]
            let logoImage = isLightMode ? "ic_fast_mode_dark" : "ic_fast_mode"
            cell.logoImage.image = UIImage(named: logoImage)
            cell.backGroundView.layer.cornerRadius = 16
            let isUsingFullAPNs = UserDefaults.standard.bool(forKey: "isUsingFullAPNs")
            if isUsingFullAPNs {
                cell.toggleSwitch.isOn = true
                cell.toggleSwitch.thumbTintColor = Colors.bothGreenColor
            } else {
                cell.toggleSwitch.isOn = false
                cell.toggleSwitch.thumbTintColor = Colors.switchOffBackgroundColor
            }
            cell.toggleSwitch.tag = indexPath.row
            cell.toggleSwitch.addTarget(self, action: #selector(isFastModeSwitchValueChanged(_:)), for: .valueChanged)
            return cell
        }else if indexPath.section == 1 {
            let cell = NotificationTableCell(style: .default, reuseIdentifier: "NotificationTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.titleLabel.text = notificationSoundsTitleArray[indexPath.row]
            if indexPath.row == 0 {
                cell.toggleSwitch.isHidden = true
                cell.resultTitleLabel.isHidden = false
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                let logoImage = isLightMode ? "ic_Sound_dark" : "ic_soundsp"
                cell.logoImage.image = UIImage(named: logoImage)
                //display user seleted Sound Name
                let sound = OWSSounds.globalNotificationSound()
                let displayName = OWSSounds.displayName(for: sound)
                cell.resultTitleLabel.text = displayName
            }else{
                let logoImage = isLightMode ? "ic_Vibrate_dark" : "ic_Vibrate"
                cell.logoImage.image = UIImage(named: logoImage)
                cell.toggleSwitch.isHidden = false
                cell.resultTitleLabel.isHidden = true
                if Environment.shared.preferences.soundInForeground() {
                    cell.toggleSwitch.isOn = true
                    cell.toggleSwitch.thumbTintColor = Colors.bothGreenColor
                }else{
                    cell.toggleSwitch.isOn = false
                    cell.toggleSwitch.thumbTintColor = Colors.switchOffBackgroundColor
                }
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.toggleSwitch.tag = indexPath.row
                cell.toggleSwitch.addTarget(self, action: #selector(isSoundNotificationsSwitchValueChanged(_:)), for: .valueChanged)
            }
            return cell
        }else {
            let cell = NotificationTableCell2(style: .default, reuseIdentifier: "NotificationTableCell2")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.titleLabel.text = notificationContentTitleArray[indexPath.row]
            cell.titleDescriptionLabel.text = notificationContentDescArray[indexPath.row]
            let logoImage = isLightMode ? "ic_show_dark" : "ic_Show"
            cell.logoImage.image = UIImage(named: logoImage)
            cell.backGroundView.layer.cornerRadius = 16
            cell.toggleSwitch.isHidden = true
            cell.resultTitleLabel.isHidden = false
            //display user seleted Show Name
            let notificationType = Environment.shared.preferences.notificationPreviewType()
            let displayName = Environment.shared.preferences.name(forNotificationPreviewType: notificationType)
            cell.resultTitleLabel.text = displayName
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { }
        else if indexPath.section == 1 {
            if indexPath.row == 0{
                let vc = OWSSoundSettingsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else {
            if indexPath.row == 0{
                let vc = NotificationSettingsOptionsViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40)
        let footerView = UIView(frame:rect)
        footerView.backgroundColor = Colors.viewBackgroundColorNew
        let label = UILabel()
        label.text = sectionNames[section]
        label.textColor = Colors.bothGreenColor
        label.frame = CGRect(x: 30, y: 5, width: tableView.frame.width - 30, height: 30)
        label.font = Fonts.semiOpenSans(ofSize: 16)
        footerView.addSubview(label)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // Set the height of the header view as needed
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        }else if indexPath.section == 1 {
            return UITableView.automaticDimension
        }else {
            return UITableView.automaticDimension
        }
    }
    //Use Fast Mode
    @objc func isFastModeSwitchValueChanged(_ sender: UISwitch) {
        let isSwitchOn = sender.isOn
        if isSwitchOn == true {
            sender.thumbTintColor = Colors.bothGreenColor
        }else {
            sender.thumbTintColor = Colors.switchOffBackgroundColor
        }
        UserDefaults.standard.set(isSwitchOn, forKey: "isUsingFullAPNs")
        let syncTokensJob = SyncPushTokensJob(accountManager: AppEnvironment.shared.accountManager, preferences: Environment.shared.preferences)
        syncTokensJob.uploadOnlyIfStale = false
        let _: Promise<Void> = syncTokensJob.run()
    }
    //Play while App is open
    @objc func isSoundNotificationsSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn == true {
            sender.thumbTintColor = Colors.bothGreenColor
        }else {
            sender.thumbTintColor = Colors.switchOffBackgroundColor
        }
        Environment.shared.preferences.setSoundInForeground(sender.isOn)
    }
    
}

class NotificationTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.settingsCellBackgroundColor
        return view
    }()
    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
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
    lazy var resultTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.settingsResultTitleCellLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var bgview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.backgroundColor = .red
        return view
    }()
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(logoImage)
        backGroundView.addSubview(toggleSwitch)
        backGroundView.addSubview(titleLabel)
        backGroundView.addSubview(resultTitleLabel)
        
        if toggleSwitch.isOn == true {
            toggleSwitch.thumbTintColor = Colors.bothGreenColor
        }else {
            toggleSwitch.thumbTintColor = Colors.switchOffBackgroundColor
        }
        
        // Set up constraints
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            logoImage.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 24),
            logoImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            logoImage.widthAnchor.constraint(equalToConstant: 18),
            logoImage.heightAnchor.constraint(equalToConstant: 18),
            logoImage.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -24),
            toggleSwitch.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            toggleSwitch.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
            resultTitleLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            resultTitleLabel.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NotificationTableCell2: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.settingsCellBackgroundColor
        return view
    }()
    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var resultTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.settingsResultTitleCellLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var titleDescriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.settingsDescriptionCellLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
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
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(logoImage)
        backGroundView.addSubview(toggleSwitch)
        backGroundView.addSubview(titleLabel)
        backGroundView.addSubview(titleDescriptionLabel)
        backGroundView.addSubview(resultTitleLabel)
        
        if toggleSwitch.isOn == true {
            toggleSwitch.thumbTintColor = Colors.bothGreenColor
        }else {
            toggleSwitch.thumbTintColor = Colors.switchOffBackgroundColor
        }
        
        // Set up constraints
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            logoImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            logoImage.widthAnchor.constraint(equalToConstant: 18),
            logoImage.heightAnchor.constraint(equalToConstant: 18),
            logoImage.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 24),
            toggleSwitch.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            toggleSwitch.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
            resultTitleLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            resultTitleLabel.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -20),
            titleLabel.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
            titleDescriptionLabel.leadingAnchor.constraint(equalTo: logoImage.leadingAnchor),
            titleDescriptionLabel.trailingAnchor.constraint(equalTo: toggleSwitch.trailingAnchor),
            titleDescriptionLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -24),
            titleDescriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
