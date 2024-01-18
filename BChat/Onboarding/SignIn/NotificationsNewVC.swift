// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Notifications"
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = NotificationTableCell(style: .default, reuseIdentifier: "NotificationTableCell")
            cell.backgroundColor = .clear
            
            
            return cell
        }else if indexPath.section == 1 {
            let cell = NotificationTableCell(style: .default, reuseIdentifier: "NotificationTableCell")
            cell.backgroundColor = .clear
            
            
            return cell
        }else if indexPath.section == 2 {
            let cell = NotificationTableCell(style: .default, reuseIdentifier: "NotificationTableCell")
            cell.backgroundColor = .clear
            
            return cell
        }else {
            let cell = NotificationTableCell(style: .default, reuseIdentifier: "NotificationTableCell")
            cell.backgroundColor = .clear
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        let sectionText = UILabel()
        sectionText.frame = CGRect(x: 32, y: 7, width: sectionHeader.frame.width - 10, height: sectionHeader.frame.height - 10)
        sectionText.font = Fonts.boldOpenSans(ofSize: 18)
        sectionText.textColor = Colors.greenColor
        switch section {
        case 0:
            sectionText.text = " "
        case 1:
            sectionText.text = "Notification Strategy"
        case 2:
            sectionText.text = "Notification Style"
        case 3:
            sectionText.text = "Notification Content"
        default:
            sectionText.text = "Default Header"
        }
        sectionHeader.backgroundColor = .clear
        sectionHeader.addSubview(sectionText)
        return sectionHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else if section == 1 {
            return 40
        }else if section == 2 {
            return 40
        }else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

class NotificationTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        view.layer.cornerRadius = 16
        return view
    }()
    private lazy var allNotificationsLogoImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Newcopy", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    private lazy var priorityLogoImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Newcopy", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var allNotificationsLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.text = "All Notifications"
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var priorityLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.text = "Priority"
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = .blue
        return toggle
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(allNotificationsLogoImg)
        backGroundView.addSubview(priorityLogoImg)
        backGroundView.addSubview(allNotificationsLabel)
        backGroundView.addSubview(priorityLabel)
        backGroundView.addSubview(toggleSwitch)

        // Set up constraints
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            backGroundView.heightAnchor.constraint(equalToConstant: 100),
            
            allNotificationsLogoImg.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 28),
            allNotificationsLogoImg.heightAnchor.constraint(equalToConstant: 16),
            allNotificationsLogoImg.widthAnchor.constraint(equalToConstant: 16),
            allNotificationsLogoImg.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 38),
//            allNotificationsLogoImg.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -10),
            
            priorityLogoImg.heightAnchor.constraint(equalToConstant: 16),
            priorityLogoImg.widthAnchor.constraint(equalToConstant: 16),
            priorityLogoImg.topAnchor.constraint(equalTo: allNotificationsLogoImg.bottomAnchor, constant: 38),
            priorityLogoImg.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 28),
            priorityLogoImg.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -38),
            
            allNotificationsLabel.leadingAnchor.constraint(equalTo: allNotificationsLogoImg.trailingAnchor, constant: 15),
            allNotificationsLabel.centerYAnchor.constraint(equalTo: allNotificationsLogoImg.centerYAnchor),
            
            priorityLabel.leadingAnchor.constraint(equalTo: priorityLogoImg.trailingAnchor, constant: 15),
            priorityLabel.centerYAnchor.constraint(equalTo: priorityLogoImg.centerYAnchor),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            toggleSwitch.centerYAnchor.constraint(equalTo: allNotificationsLabel.centerYAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
