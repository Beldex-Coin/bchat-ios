// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

extension Notification.Name {
    public static let myNotificationKey_doodlechange = Notification.Name(rawValue: "myNotificationKey_doodlechange")
}

class SideMenuVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = .clear
        result.separatorStyle = .none
        result.register(SideMenuTableViewCell.self, forCellReuseIdentifier: "SideMenuTableViewCell")
        result.register(SideMenuProfileTableViewCell.self, forCellReuseIdentifier: "SideMenuProfileTableViewCell")
        result.showsVerticalScrollIndicator = false
        return result
    }()
    
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
    lazy var sampleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.greenColor
        toggle.addTarget(self, action: #selector(self.sampleSwitchValueChanged(_:)), for: .valueChanged)
        return toggle
    }()
    
    lazy var menuTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bchatLabelNameColor
        result.font = Fonts.boldOpenSans(ofSize: 23)
        result.textAlignment = .right
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Menu"
        return result
    }()
    
    lazy var lblversion: UILabel = {
        let result = UILabel()
        result.textColor = Colors.noDataLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .right
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var lblmodeTitle: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .right
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Dark Mode"
        return result
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_closeNew"), for: .normal)
        return button
    }()
    
    var titlesArray = ["My Account","Settings","Notification","Message Requests","Recovery Seed","Wallet","Report Issue","Help","Invite","About"]
    private var hasTappableProfilePicture: Bool = false
    @objc public var size: CGFloat = 30 // Not an implicitly unwrapped optional due to Obj-C limitations
    @objc public var useFallbackPicture = false
    @objc public var publicKey: String!
    @objc public var additionalPublicKey: String?
    @objc public var openGroupProfilePicture: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        self.navigationController?.isNavigationBarHidden = true
        
        view.addSubViews(closeButton, menuTitleLabel, sampleSwitch, lblversion, lblmodeTitle)
        
        if isLightMode {
            sampleSwitch.isOn = false
        } else {
            sampleSwitch.isOn = true
        }
        let origImage = UIImage(named: isLightMode ? "X" : "X")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(tintedImage, for: .normal)
        closeButton.tintColor = isLightMode ? UIColor.black : UIColor.white
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"]!
        self.lblversion.text = "BChat \(version) (\(buildNumber))"
        
        // Table view
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.pin(.leading, to: .leading, of: view)
        tableView.pin(.top, to: .bottom, of: closeButton, withInset: 15)
        tableView.pin(.trailing, to: .trailing, of: view)
        tableViewHeightConstraint = tableView.set(.height, to: 550)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            menuTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            menuTitleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            sampleSwitch.trailingAnchor .constraint(equalTo: view.trailingAnchor, constant: -20),
            sampleSwitch.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24.333),
            
            lblmodeTitle.trailingAnchor .constraint(equalTo: sampleSwitch.leadingAnchor, constant: -12),
            lblmodeTitle.centerYAnchor.constraint(equalTo: sampleSwitch.centerYAnchor),
            
            lblversion.trailingAnchor .constraint(equalTo: view.trailingAnchor, constant: -20),
            lblversion.topAnchor.constraint(equalTo: sampleSwitch.bottomAnchor, constant: 25)
        ])
        
        
    }
    
    func getProfilePicture(of size: CGFloat, for publicKey: String) -> UIImage? {
        guard !publicKey.isEmpty else { return nil }
        if let profilePicture = OWSProfileManager.shared().profileAvatar(forRecipientId: publicKey) {
            hasTappableProfilePicture = true
            return profilePicture
        } else {
            hasTappableProfilePicture = false
            // TODO: Pass in context?
            let displayName = Storage.shared.getContact(with: publicKey)?.name ?? publicKey
            return Identicon.generatePlaceholderIcon(seed: publicKey, text: displayName, size: size)
        }
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func sampleSwitchValueChanged(_ x: UISwitch) {
        if sampleSwitch.isOn {
            AppModeManager.shared.setCurrentAppMode(to: .dark)
        }else {
            AppModeManager.shared.setCurrentAppMode(to: .light)
        }
        let origImage = UIImage(named: isLightMode ? "X" : "X")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(tintedImage, for: .normal)
        closeButton.tintColor = isLightMode ? UIColor.black : UIColor.white
        let userInfo = [ "text" : "dark" ]
        NotificationCenter.default.post(name: .myNotificationKey_doodlechange, object: nil, userInfo: userInfo)
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            self.tableViewHeightConstraint.constant = CGFloat(titlesArray.count * 60)
            return titlesArray.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return 50
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuProfileTableViewCell") as! SideMenuProfileTableViewCell
            
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = Colors.cancelButtonBackgroundColor
            cell.backGroundView.backgroundColor = Colors.cellGroundColor3
            cell.titleLabel.text = Storage.shared.getUser()?.name ?? UserDefaults.standard.string(forKey: "WalletName")?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            cell.titleLabel.textColor = Colors.titleColor
            
            let publicKey = getUserHexEncodedPublicKey()
            cell.iconImageView.image = useFallbackPicture ? nil : (openGroupProfilePicture ?? getProfilePicture(of: size, for: publicKey))
            
            let origImage = UIImage(named: isLightMode ? "ic_QR_white" : "ic_QR_dark")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            cell.scanImageView.image = tintedImage
            cell.scanImageView.tintColor = isLightMode ? UIColor.black : UIColor.white
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as! SideMenuTableViewCell
            
            cell.contentView.backgroundColor = Colors.cancelButtonBackgroundColor
            cell.selectionStyle = .none
            cell.titleLabel.text = titlesArray[indexPath.row]
            cell.titleLabel.textColor = Colors.titleColor2
            
            if indexPath.row == 0 { //My Account
                let logoName = "ic_menu_account"
                cell.iconImageView.image = UIImage(named: logoName)!
            }else if indexPath.row == 1 {   //Settings
                let logoName = "ic_menu_setting"
                cell.iconImageView.image = UIImage(named: logoName)!
            }else if indexPath.row == 2 {   //Notification
                let logoName = "ic_menu_notification"
                cell.iconImageView.image = UIImage(named: logoName)!
            }else if indexPath.row == 3 {   //Message Requests
                let logoName = "ic_menu_msg_rqst"
                cell.iconImageView.image = UIImage(named: logoName)!
            }else if indexPath.row == 4 {   //Recovery Seed
                let logoName = "ic_menu_recovery_seed"
                cell.iconImageView.image = UIImage(named: logoName)!
            }else if indexPath.row == 5 {   //My Wallet
                let logoName = "ic_menu_wallet"
                cell.iconImageView.image = UIImage(named: logoName)!
            }else if indexPath.row == 6 {   //Report Issue
                let logoName = "ic_menu_report_issue"
                cell.iconImageView.image = UIImage(named: logoName)!
            }else if indexPath.row == 7 {   //Help
                let logoName = "ic_menu_help"
                cell.iconImageView.image = UIImage(named: logoName)!
            }else if indexPath.row == 8{    //Invite
                let logoName = "ic_menu_invite"
                cell.iconImageView.image = UIImage(named: logoName)!
            }else { //About
                let logoName = "ic_menu_about"
                cell.iconImageView.image = UIImage(named: logoName)!
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = MyAccountNewVC()
            navigationController!.pushViewController(vc, animated: true)
        }else {
            if indexPath.row == 0 { //My Account
                let vc = MyAccountBnsNewVC()
                navigationController!.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 {   //Settings
                let vc = BChatSettingsNewVC()
                navigationController!.pushViewController(vc, animated: true)
            } else if indexPath.row == 2 {   //Notification
                let vc = NotificationsNewVC()
                navigationController!.pushViewController(vc, animated: true)
            } else if indexPath.row == 3 {   //Message Requests
                let vc = NewMessageRequestVC()
                navigationController!.pushViewController(vc, animated: true)
            } else if indexPath.row == 4 {   //Recovery Seed
                let vc = NewAlertRecoverySeedVC()
                navigationController!.pushViewController(vc, animated: true)
            } else if indexPath.row == 5 {   //My Wallet
                if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
                    // MARK: - Old flow (without wallet)
                    if SaveUserDefaultsData.israndomUUIDPassword == "" {
                        let vc = EnableWalletVC()
                        navigationController!.pushViewController(vc, animated: true)
                        return
                    }
                    // MARK: - New flow (with wallet)
                    if SSKPreferences.areWalletEnabled {
                        if SaveUserDefaultsData.WalletPassword.isEmpty {
                            let vc = NewPasswordVC()
                            vc.isGoingWallet = true
                            vc.isVerifyPassword = true
                            navigationController!.pushViewController(vc, animated: true)
                        }else {
                            let vc = NewPasswordVC()
                            vc.isGoingWallet = true
                            vc.isVerifyPassword = true
                            navigationController!.pushViewController(vc, animated: true)
                        }
                    }else {
                        let vc = EnableWalletVC()
                        navigationController!.pushViewController(vc, animated: true)
                    }
                }else {
                    self.showToastMsg(message: "Please check your internet connection", seconds: 1.0)
                }
            }else if indexPath.row == 6 {   //Report Issue
                let thread = TSContactThread.getOrCreateThread(contactBChatID: "\(bchat_report_IssueID)")
                SignalApp.shared().presentConversation(for: thread, action: .compose, animated: true)
            }else if indexPath.row == 7 {   //Help
                if let url = URL(string: "mailto:\(bchat_email_SupportMailID)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }else if indexPath.row == 8 {   //Invite
                let invitation = "\(bchat_Invite_Message)" + "\(getUserHexEncodedPublicKey()) !"
                let shareVC = UIActivityViewController(activityItems: [ invitation ], applicationActivities: nil)
                navigationController!.present(shareVC, animated: true, completion: nil)
            }else if indexPath.row == 9{    //About
                let vc = AboutNewVC()
                navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
}

class SideMenuTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.setUPLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 28)
        result.set(.height, to: 28)
        result.layer.masksToBounds = true
        result.contentMode = .center
        return result
    }()
    
    func setUPLayout() {
        contentView.addSubViews(titleLabel, iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            
        ])
    }
}

class SideMenuProfileTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        self.setUPLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    lazy var backGroundView: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = Colors.cellGroundColor3
        View.layer.cornerRadius = 10
        return View
    }()
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 44)
        result.set(.height, to: 44)
        result.contentMode = .scaleToFill
        result.layer.masksToBounds = false
        result.layer.cornerRadius = 22
        result.clipsToBounds = true
        return result
    }()
    
    lazy var scanImageView: UIImageView = {
        let result = UIImageView()
        result.set(.width, to: 33)
        result.set(.height, to: 33)
        result.contentMode = .center
        return result
    }()
    
    
    func setUPLayout() {
        contentView.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, iconImageView, scanImageView)
        
        NSLayoutConstraint.activate([
            backGroundView.heightAnchor.constraint(equalToConstant: 75),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            backGroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            backGroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            
            iconImageView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 10),
            iconImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            
            scanImageView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -15),
            scanImageView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            
            titleLabel.trailingAnchor.constraint(equalTo: scanImageView.leadingAnchor, constant: -5),
            
        ])
    }
    
}


