// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

final class SettingsViewController: BaseVC {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let viewModel = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
        setupUI()
        setObserver()
    }
    
    private func initializeView() {
        viewModel.delegate = self
    }
    
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = Colors.viewBackgroundColorNew
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCallPermissionCancelTapped), name: .reloadSettingScreenTableNotification, object: nil)
    }
    
    private func deleteThreadsAndMessages() {
        ThreadUtil.deleteAllContent()
    }
    
    @objc func handleCallPermissionCancelTapped(notification: NSNotification) {
        tableView.reloadData()
    }
    
    private func clearConversations() {
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

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = SettingsSection.allCases[section]
        return viewModel.settings[sectionType]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as? SettingsTableViewCell else {
            return UITableViewCell()
        }
        let section = SettingsSection.allCases[indexPath.section]
        if let item = viewModel.settings[section]?[indexPath.row] {
            cell.configure(with: item)
            cell.switchChanged = { [weak self] in
                self?.viewModel.toggleSwitch(for: indexPath) {
                    tableView.reloadRows(at: [indexPath], with: .none)
                    self?.viewModel.switchValueChanged(rowAt: indexPath)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Colors.viewBackgroundColorNew
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = SettingsSection.allCases[section].rawValue
        titleLabel.font = Fonts.semiOpenSans(ofSize: 16)
        titleLabel.textColor = Colors.bothGreenColor
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -14)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = SettingsSection.allCases[indexPath.section]
        if let item = viewModel.settings[section]?[indexPath.row] {
            if item.title == SettingInfo.clearConversationHistory.title {
                clearConversations()
            }
        }
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    
    internal func payAsYouChat(_ isEnabled: Bool)  {
        if let myString = UserDefaults.standard.string(forKey: "WalletPassword"), !myString.isEmpty {
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
                    let viewController = NewPasswordVC()
                    viewController.isGoingWallet = true
                    if SaveUserDefaultsData.WalletPassword.isEmpty {
                        viewController.isGoingPopUp = true
                        viewController.isCreateWalletPassword = true
                    } else {
                        viewController.isVerifyWalletPassword = true
                    }
                    self.navigationController!.pushViewController(viewController, animated: true)
                }
            )
            alertController.addAction(yesAction)
            // Present the alert
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    internal func voiceAndVideoCall(_ isEnabled: Bool) {
        let userDefaults = UserDefaults.standard
        if isEnabled && !userDefaults.bool(forKey: "hasSeenCallIPExposureWarning") {
            let modal = CallPermissionPopUp { [weak self] in
                guard let self = self else { return }
                print("toggled to: \(isEnabled ? "true" : "OFF")")
                let audioSession = AVAudioSession.sharedInstance()
                if audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:))) {
                    audioSession.requestRecordPermission({ granted in
                        if granted {
                            // Microphone access granted, you can now use the microphone.
                            print("Microphone access granted")
                            userDefaults.set(true, forKey: "hasSeenCallIPExposureWarning")
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
    
    internal func reloadPayAsYouChatRow(_ indexPath: IndexPath) {
        let updatedIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        tableView.reloadRows(at: [updatedIndexPath], with: .none)
    }
}
