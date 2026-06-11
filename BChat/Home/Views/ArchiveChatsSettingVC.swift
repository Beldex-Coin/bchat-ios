// Copyright © 2026 Beldex International Limited OU. All rights reserved.

import UIKit

class ArchiveChatsSettingVC: BaseVC {
    
    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = Colors.mainBackGroundColor2
        result.separatorStyle = .none
        result.register(ArchiveChatsSettingTableviewCell.self, forCellReuseIdentifier: "ArchiveChatsSettingTableviewCell")
        result.showsVerticalScrollIndicator = false
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.mainBackGroundColor2
        self.title = "Archive Settings"
        setUpTopCornerRadius()
        
        // Table view
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.pin(.leading, to: .leading, of: view)
        tableView.pin(.top, to: .top, of: view)
        tableView.pin(.trailing, to: .trailing, of: view)
        tableView.pin(.bottom, to: .bottom, of: view)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
}


extension ArchiveChatsSettingVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArchiveChatsSettingTableviewCell") as! ArchiveChatsSettingTableviewCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.titleLabel.text = "Keep chats archived"
        cell.titleDescriptionLabel.text = "Archived chats will remain archived when you receive a new message"
        let keepChatArchive = SSKPreferences.keepChatArchive
        if keepChatArchive {
            cell.toggleSwitch.isOn = true
            cell.toggleSwitch.thumbTintColor = Colors.bothGreenColor
        } else {
            cell.toggleSwitch.isOn = false
            cell.toggleSwitch.thumbTintColor = Colors.switchOffBackgroundColor
        }
        cell.toggleSwitch.tag = indexPath.row
        cell.toggleSwitch.addTarget(self, action: #selector(keepChatsArchivedSwitchValueChanged(_:)), for: .valueChanged)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    @objc func keepChatsArchivedSwitchValueChanged(_ sender: UISwitch) {
        let isSwitchOn = sender.isOn
        sender.thumbTintColor = isSwitchOn ? Colors.bothGreenColor : Colors.switchOffBackgroundColor
        SSKPreferences.keepChatArchive = isSwitchOn
    }
    
}
