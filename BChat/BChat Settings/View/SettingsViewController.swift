// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

final class SettingsViewController: BaseVC {
    
    private let tableView = UITableView() //frame: .zero, style: .grouped)
    private let viewModel = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = Colors.viewBackgroundColorNew
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
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
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = SettingsSection.allCases[section]
        return viewModel.settings[sectionType]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        SettingsSection.allCases[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = Colors.bothGreenColor
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as? SettingsTableViewCell else {
            return UITableViewCell()
        }
        let section = SettingsSection.allCases[indexPath.section]
        if let item = viewModel.settings[section]?[indexPath.row] {
            cell.configure(with: item)
            cell.switchChanged = { [weak self] in
                self?.viewModel.toggleSwitch(for: indexPath)
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Colors.settingsCellBackgroundColor
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        
        // Add spacing between sections
        let sectionCount = tableView.numberOfRows(inSection: indexPath.section)
        
        // Top corners
        if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        // Bottom corners
        else if indexPath.row == sectionCount - 1 {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
        }
        
        // Add vertical spacing between section groups
        tableView.sectionHeaderTopPadding = 8
        tableView.sectionFooterHeight = 8
        tableView.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
    }
}
