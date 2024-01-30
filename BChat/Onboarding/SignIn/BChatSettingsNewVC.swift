// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class BChatSettingsNewVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

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
    
    var appAccessTitleArray = ["Screen Security","Incognito Keyboard"]
    var appAccessDescArray = ["Block Screenshots in the recents list and inside the app","Request keyboard to disable personalized learning"]
    var appAccessimages = ["ic_Screen_securityNew","ic_IncognitoNew"]
    
    var walletTitleArray = ["Start Wallet","Pay as you chat"]
    var walletDescArray = ["Enabling wallet will allow you to send and receive BDX","Enabling ‘Pay as you chat’ will allow you to send receive BDX right from the chat window"]
    var walletimages = ["ic_WalletNew","ic_GroupNew"]
    
    var communicationTitleArray = ["Read receipts","Type indicators","Send link previews","Voice and video calls"]
    var communicationDescArray = ["if read receipts are disabled, you won’t be able to see read receipts from others","if typing indicators are disabled, you won’t be able to see typing indicators from others.","Previews are supported for imgur, instagram, pinterest, Reddit, and Youtube links.","Allow access to accept voice and video calls from other users."]
    var communicationimages = ["ic_Read_receipetNew","ic_Type_indicaterNew","ic_send_linkNew","ic_video_callNew"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Settings"
        
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
            return appAccessTitleArray.count
        }else if section == 1{
            return walletTitleArray.count
        }else {
            return communicationTitleArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = BChatSettingsTableCell(style: .default, reuseIdentifier: "BChatSettingsTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.titleLabel.text = appAccessTitleArray[indexPath.row]
            cell.titleDescriptionLabel.text = appAccessDescArray[indexPath.row]
            cell.logoImage.image = UIImage(named: appAccessimages[indexPath.row])
            
            if indexPath.row == 0 {
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }else{
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            
            return cell
        }else if indexPath.section == 1 {
            let cell = BChatSettingsTableCell(style: .default, reuseIdentifier: "BChatSettingsTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.titleLabel.text = walletTitleArray[indexPath.row]
            cell.titleDescriptionLabel.text = walletDescArray[indexPath.row]
            cell.logoImage.image = UIImage(named: walletimages[indexPath.row])
            
            if indexPath.row == 0 {
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }else{
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            
            return cell
        }else {
            let cell = BChatSettingsTableCell(style: .default, reuseIdentifier: "BChatSettingsTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.titleLabel.text = communicationTitleArray[indexPath.row]
            cell.titleDescriptionLabel.text = communicationDescArray[indexPath.row]
            cell.logoImage.image = UIImage(named: communicationimages[indexPath.row])
            
            if indexPath.row == 0 {
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            if indexPath.row == 3 {
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40)
        let footerView = UIView(frame:rect)
        footerView.backgroundColor = .clear
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
        result.text = "SRee"
        return result
    }()
    lazy var titleDescriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.text = "Enabling ‘Pay as you chat’ will allow you to send receive BDX right from the chat window BDX right from the chat window"
        return result
    }()
    lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.greenColor
        return toggle
    }()
    
    lazy var bgview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.backgroundColor = .red
        return view
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
