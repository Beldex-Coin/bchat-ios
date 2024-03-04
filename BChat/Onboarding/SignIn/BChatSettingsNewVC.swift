// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import SignalUtilitiesKit

class BChatSettingsNewVC: BaseVC, UITableViewDataSource, UITableViewDelegate {

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
    
    let sectionNames = ["App Access", "Wallet", "Communication"]
    
    var appAccessTitleArray = ["Screen Lock","Disable Preview in app switcher"]
    var appAccessDescArray = ["Require Touch ID, Face ID or your device passcode to unlock BChat’s screen. You can still receive notifications when Screen Lock is enabled. Use BChat’s notification settings to customise the information displayed in notifications.","Prevent BChat previews from appearing in the app switcher."]
    var appAccessImages = ["ic_Screen_securityNew","ic_surface_new"]
    
    var walletTitleArray = ["Start Wallet","Pay as you chat"]
    var walletDescArray = ["Enabling wallet will allow you to send and receive BDX","Enabling ‘Pay as you chat’ will allow you to send receive BDX right from the chat window"]
    var walletImages = ["ic_WalletNew","ic_GroupNew"]
    
    var communicationTitleArray = ["Read receipts","Type indicators","Send link previews","Voice and video calls","Clear conversation History"]
    var communicationDescArray = ["if read receipts are disabled, you won’t be able to see read receipts from others","if typing indicators are disabled, you won’t be able to see typing indicators from others.","Previews are supported for imgur, instagram, pinterest, Reddit, and Youtube links.","Allow access to accept voice and video calls from other users.",""]
    var communicationImages = ["ic_Read_receipetNew","ic_Type_indicaterNew","ic_send_linkNew","ic_video_callNew","ic_clear_imgaes"]
    var isScreenLockEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: nil, action: nil)
        self.title = ""
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: -15),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0)
        ])
    }

    
    // MARK: - Navigation

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            //            return 3//appAccessTitleArray.count
            if isScreenLockEnabled {
                return 3 // Include ScreenLockTableCell
            } else {
                return 2 // Exclude ScreenLockTableCell
            }
        }else if section == 1{
            return walletTitleArray.count
        }else {
            return communicationTitleArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = BChatSettingsTableCell2(style: .default, reuseIdentifier: "BChatSettingsTableCell2")
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.resultTitleLabel.isHidden = true
                cell.titleLabel.text = "Screen Lock"
                cell.titleDescriptionLabel.text = "Require Touch ID, Face ID or your device passcode to unlock BChat’s screen. You can still receive notifications when Screen Lock is enabled. Use BChat’s notification settings to customise the information displayed in notifications."
                cell.logoImage.image = UIImage(named: "ic_Screen_securityNew")
                //screen Lock
                let isScreenLockEnabled = OWSScreenLock.shared.isScreenLockEnabled()
                if isScreenLockEnabled{
                    cell.toggleSwitch.isOn = true
                }else {
                    cell.toggleSwitch.isOn = false
                }
                cell.toggleSwitch.tag = indexPath.row
                cell.toggleSwitch.addTarget(self, action: #selector(screenLockSwitchValueChanged(_:)), for: .valueChanged)
                return cell
            }else if indexPath.row == 1 && isScreenLockEnabled{
                let cell = ScreenLockTableCell(style: .default, reuseIdentifier: "ScreenLockTableCell")
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                
                return cell
            }else {
                let cell = BChatSettingsTableCell2(style: .default, reuseIdentifier: "BChatSettingsTableCell2")
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.resultTitleLabel.isHidden = true
                
                cell.titleLabel.text = "Disable Preview in app switcher"
                cell.titleDescriptionLabel.text = "Prevent BChat previews from appearing in the app switcher."
                cell.logoImage.image = UIImage(named: "ic_surface_new")
                //disable Preview in App Switcher
                let isScreenSecurityEnabled = Environment.shared.preferences.screenSecurityIsEnabled()
                if isScreenSecurityEnabled{
                    cell.toggleSwitch.isOn = true
                }else {
                    cell.toggleSwitch.isOn = false
                }
                cell.toggleSwitch.tag = indexPath.row
                cell.toggleSwitch.addTarget(self, action: #selector(disablePreviewInAppSwitcherSwitchValueChanged(_:)), for: .valueChanged)
                return cell
            }
        }else if indexPath.section == 1 {
            let cell = BChatSettingsTableCell(style: .default, reuseIdentifier: "BChatSettingsTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.titleLabel.text = walletTitleArray[indexPath.row]
            cell.titleDescriptionLabel.text = walletDescArray[indexPath.row]
            cell.logoImage.image = UIImage(named: walletImages[indexPath.row])
            
            if indexPath.row == 0 {
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                // Start Wallet
                let areWalletEnabled = SSKPreferences.areWalletEnabled
                if areWalletEnabled{
                    cell.toggleSwitch.isOn = true
                }else {
                    cell.toggleSwitch.isOn = false
                }
                cell.toggleSwitch.tag = indexPath.row
                cell.toggleSwitch.addTarget(self, action: #selector(startWalletSwitchValueChanged(_:)), for: .valueChanged)
            }else{
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                // Pay As You Chat
                let isPayAsYouChatEnabled = SSKPreferences.arePayAsYouChatEnabled
                if isPayAsYouChatEnabled{
                    cell.toggleSwitch.isOn = true
                }else {
                    cell.toggleSwitch.isOn = false
                }
                cell.toggleSwitch.tag = indexPath.row
                cell.toggleSwitch.addTarget(self, action: #selector(payAsYouChatSwitchValueChanged(_:)), for: .valueChanged)
            }
            
            return cell
        }else {
            let cell = BChatSettingsTableCell(style: .default, reuseIdentifier: "BChatSettingsTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.titleLabel.text = communicationTitleArray[indexPath.row]
            cell.titleDescriptionLabel.text = communicationDescArray[indexPath.row]
            cell.logoImage.image = UIImage(named: communicationImages[indexPath.row])
            
            if indexPath.row == 0 {
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                // Read Receipts
                let areReadReceiptsEnabled = OWSReadReceiptManager.shared().areReadReceiptsEnabled()
                if areReadReceiptsEnabled{
                    cell.toggleSwitch.isOn = true
                }else {
                    cell.toggleSwitch.isOn = false
                }
                cell.toggleSwitch.tag = indexPath.row
                cell.toggleSwitch.addTarget(self, action: #selector(readReceiptsSwitchValueChanged(_:)), for: .valueChanged)
            }
            if indexPath.row == 1 {
                // Type Indicators
                let areTypingIndicatorsEnabled = SSKEnvironment.shared.typingIndicators.areTypingIndicatorsEnabled()
                if areTypingIndicatorsEnabled{
                    cell.toggleSwitch.isOn = true
                }else {
                    cell.toggleSwitch.isOn = false
                }
                cell.toggleSwitch.tag = indexPath.row
                cell.toggleSwitch.addTarget(self, action: #selector(typeIndicatorsSwitchValueChanged(_:)), for: .valueChanged)
            }
            if indexPath.row == 2 {
                // Send Link Previews
                let areLinkPreviewsEnabled = SSKPreferences.areLinkPreviewsEnabled
                if areLinkPreviewsEnabled{
                    cell.toggleSwitch.isOn = true
                }else {
                    cell.toggleSwitch.isOn = false
                }
                cell.toggleSwitch.tag = indexPath.row
                cell.toggleSwitch.addTarget(self, action: #selector(sendLinkPreviewsSwitchValueChanged(_:)), for: .valueChanged)
            }
            if indexPath.row == 3 {
                // Voice And Video Calls
                let areCallsEnabled = SSKPreferences.areCallsEnabled
                if areCallsEnabled{
                    cell.toggleSwitch.isOn = true
                }else {
                    cell.toggleSwitch.isOn = false
                }
                cell.toggleSwitch.tag = indexPath.row
                cell.toggleSwitch.addTarget(self, action: #selector(voiceAndVideoCallsSwitchValueChanged(_:)), for: .valueChanged)
            }
            if indexPath.row == 4 {
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.toggleSwitch.isHidden = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
//                let logInfo = NSLocalizedString("", comment: "")
//                print(logInfo)
//                let alert = UIAlertController(title: NSLocalizedString("SETTINGS_SCREEN_LOCK_ACTIVITY_TIMEOUT", comment: "Label for the 'screen lock activity timeout' setting of the privacy settings."),
//                                              message: nil,
//                                              preferredStyle: .actionSheet)
//                for timeoutValue in OWSScreenLock.shared.screenLockTimeouts {
//                    let screenLockTimeout = UInt32(round(timeoutValue))
//                    let screenLockTimeoutString = formatScreenLockTimeout(Int(screenLockTimeout), useShortFormat: false)
//
//                    let action = UIAlertAction(title: screenLockTimeoutString,
//                                               style: .default,
//                                               handler: { _ in
//                        OWSScreenLock.shared.setScreenLockTimeout(TimeInterval(screenLockTimeout))
//                                               })
//                    action.accessibilityIdentifier = "settings.privacy.timeout.\(timeoutValue)"
//                    alert.addAction(action)
//                }
//                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"),
//                                              style: .cancel,
//                                              handler: nil))
//                if let fromViewController = UIApplication.shared.frontmostViewController {
//                    fromViewController.present(alert, animated: true, completion: nil)
//                }
                
            }
        }
        if indexPath.section == 2{
            if indexPath.row == 4 { // Clear Conversation History
                let alert = UIAlertController(
                    title: nil,
                    message: NSLocalizedString("Are you sure? This cannot be undone.", comment: "Alert message before user confirms clearing history"),
                    preferredStyle: .alert
                )
                alert.addAction(OWSAlerts.cancelAction)
                let deleteAction = UIAlertAction(
                    title: NSLocalizedString("SETTINGS_DELETE_HISTORYLOG_CONFIRMATION_BUTTON", comment: "Confirmation text for button which deletes all messages, calls, attachments, etc."),
                    style: .destructive,
                    handler: { [weak self] action in
                        guard let self = self else { return }
                        self.deleteThreadsAndMessages()
                    }
                )
                alert.addAction(deleteAction)
                presentAlert(alert)
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40)
        let footerView = UIView(frame:rect)
        footerView.backgroundColor = UIColor(hex: 0x11111A)
        let label = UILabel()
        label.text = sectionNames[section]
        label.textColor = Colors.greenColor
        label.frame = CGRect(x: 30, y: 5, width: tableView.frame.width - 30, height: 30)
        label.font = Fonts.semiOpenSans(ofSize: 18)
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
    
    // Screen Lock
    @objc func screenLockSwitchValueChanged(_ sender: UISwitch) {
        let shouldBeEnabled = sender.isOn
        isScreenLockEnabled = sender.isOn
        tableView.reloadData()
        
        if shouldBeEnabled == OWSScreenLock.shared.isScreenLockEnabled() {
            print("ignoring redundant screen lock.")
            return
        }
        print("trying to set is screen lock enabled:\(shouldBeEnabled)")
        OWSScreenLock.shared.setIsScreenLockEnabled(shouldBeEnabled)
    }
    // Disable Preview in App Switcher
    @objc func disablePreviewInAppSwitcherSwitchValueChanged(_ sender: UISwitch) {
        let isEnabled = sender.isOn
        print("toggled screen security: \(isEnabled ? "true" : "false")")
        Environment.shared.preferences.setScreenSecurity(isEnabled)
    }
    // Start Wallet
    @objc func startWalletSwitchValueChanged(_ sender: UISwitch) {
        let isEnabled = sender.isOn
        print("toggled to: \(isEnabled ? "true" : "false")")
        SSKPreferences.areWalletEnabled = isEnabled
    }
    // Pay As You Chat
    @objc func payAsYouChatSwitchValueChanged(_ sender: UISwitch) {
        let prefs = UserDefaults.standard
        if let myString = prefs.string(forKey: "WalletPassword"), !myString.isEmpty {
            let isEnabled = sender.isOn
            print("toggled to: \(isEnabled ? "true" : "false")")
            SSKPreferences.arePayAsYouChatEnabled = isEnabled
        } else {
            let alertController = UIAlertController(
                title: NSLocalizedString("Setup Pin", comment: "Alert title"),
                message: NSLocalizedString("Please set up wallet pin to enable pay as you chat feature.", comment: "Alert message"),
                preferredStyle: .alert
            )
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Cancel button title"),
                style: .cancel,
                handler: { action in
                    print("User tapped Cancel")
                }
            )
            alertController.addAction(cancelAction)
            let yesAction = UIAlertAction(
                title: NSLocalizedString("Setup", comment: "Setup button title"),
                style: .default,
                handler: { action in
                    print("User tapped Yes")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let controller = storyboard.instantiateViewController(withIdentifier: "MyWalletPasscodeVC") as? MyWalletPasscodeVC {
                        controller.isfromPayasUChat = true
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            )
            alertController.addAction(yesAction)
            // Present the alert
            self.present(alertController, animated: true, completion: nil)
        }
    }
    // Read Receipts
    @objc func readReceiptsSwitchValueChanged(_ sender: UISwitch) {
        let isEnabled = sender.isOn
        print("toggled areReadReceiptsEnabled: \(isEnabled ? "true" : "false")")
        OWSReadReceiptManager.shared().setAreReadReceiptsEnabled(isEnabled)
    }
    // Type Indicators
    @objc func typeIndicatorsSwitchValueChanged(_ sender: UISwitch) {
        let isEnabled = sender.isOn
        print("toggled areTypingIndicatorsEnabled: \(isEnabled ? "true" : "false")")
        SSKEnvironment.shared.typingIndicators.setTypingIndicatorsEnabled(value: isEnabled)
    }
    // Send Link Previews
    @objc func sendLinkPreviewsSwitchValueChanged(_ sender: UISwitch) {
        let isEnabled = sender.isOn
        print("toggled to: \(isEnabled ? "true" : "false")")
        SSKPreferences.areLinkPreviewsEnabled = isEnabled
    }
    // Voice And Video Calls
    @objc func voiceAndVideoCallsSwitchValueChanged(_ sender: UISwitch) {
        let userDefaults = UserDefaults.standard
        let isEnabled = sender.isOn
        if isEnabled && !userDefaults.bool(forKey: "hasSeenCallIPExposureWarning") {
            userDefaults.set(true, forKey: "hasSeenCallIPExposureWarning")
            let modal = CallModal { [weak self] in
                guard let self = self else { return }
                print("toggled to: \(isEnabled ? "true" : "OFF")")
                let audioSession = AVAudioSession.sharedInstance()
                if audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:))) {
                    audioSession.requestRecordPermission({ granted in
                        if granted {
                            // Microphone access granted, you can now use the microphone.
                            print("Microphone access granted")
                            // Perform any additional actions you want here.
                            // Check if the view controller is still presented
                            if let presentingViewController = self.presentingViewController {
                                DispatchQueue.main.async {
                                    // Dismiss the presented view controller
                                    presentingViewController.dismiss(animated: true, completion: {
                                        // This block is optional and can be used to perform any tasks after the view controller is dismissed
                                    })
                                }
                            }
                        } else {
                            // Microphone access denied. Handle this case accordingly.
                            print("Microphone access denied")
                        }
                    })
                }
            }
            present(modal, animated: true, completion: nil)
        } else {
            print("toggled to: \(isEnabled ? "true" : "false")")
            SSKPreferences.areCallsEnabled = isEnabled
        }
    }
    
    // Clear Conversation History
    func deleteThreadsAndMessages() {
        ThreadUtil.deleteAllContent()
    }
    
    
    func formatScreenLockTimeout(_ value: Int, useShortFormat: Bool) -> String {
        if value <= 1 {
            return NSLocalizedString("SCREEN_LOCK_ACTIVITY_TIMEOUT_NONE",
                comment: "Indicates a delay of zero seconds, and that 'screen lock activity' will timeout immediately.")
        }
        return String(formatDurationSeconds(UInt32(value), useShortFormat: useShortFormat))
    }
    func formatDurationSeconds(_ value: UInt32, useShortFormat: Bool) -> String {
        // Implement the logic for formatting duration in seconds
        // This might involve converting seconds into a formatted string representation
        // You can use DateComponentsFormatter or other methods based on your requirements
        // Replace the following placeholder with the actual implementation
        
        return "Formatted Duration"
    }
}

class BChatSettingsTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        return view
    }()
    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Newcopy", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var titleDescriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hexValue: 0xACACAC, a: 67.45)//UIColor(hex: 0xACACAC)
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
        toggle.onTintColor = Colors.greenColor
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(logoImage)
        backGroundView.addSubview(toggleSwitch)
        backGroundView.addSubview(stackView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            logoImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            logoImage.widthAnchor.constraint(equalToConstant: 22),
            logoImage.heightAnchor.constraint(equalToConstant: 22),
            logoImage.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: -5),
            toggleSwitch.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            toggleSwitch.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
            stackView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 22),
            stackView.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -22),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BChatSettingsTableCell2: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        return view
    }()
    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Newcopy", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var resultTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hexValue: 0xACACAC, a: 67.45)//UIColor(hex: 0xACACAC)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var titleDescriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hexValue: 0xACACAC, a: 67.45)//UIColor(hex: 0xACACAC)
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
        toggle.onTintColor = Colors.greenColor
        return toggle
    }()
    lazy var dropDownView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red//UIColor(hex: 0x1C1C26)
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
        backGroundView.addSubview(titleDescriptionLabel)
        backGroundView.addSubview(resultTitleLabel)
        backGroundView.addSubview(dropDownView)
        
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


class ScreenLockTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        return view
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hexValue: 0xACACAC, a: 67.45)//UIColor(hex: 0xACACAC)
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.text = "Screen Lock Timeout"
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var resultTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hexValue: 0xACACAC, a: 67.45)//UIColor(hex: 0xACACAC)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "30M"
        return result
    }()
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(titleLabel)
        backGroundView.addSubview(resultTitleLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 5),
            titleLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -5),
            resultTitleLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            resultTitleLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
