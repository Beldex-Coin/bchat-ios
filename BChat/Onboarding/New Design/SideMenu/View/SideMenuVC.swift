// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

extension Notification.Name {
    public static let myNotificationKey_doodlechange = Notification.Name(rawValue: "myNotificationKey_doodlechange")
}

class SideMenuVC: BaseVC {
    
    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = .clear
        result.separatorStyle = .none
        result.register(SideMenuTableViewCell.self, forCellReuseIdentifier: "SideMenuTableViewCell")
        result.register(SideMenuProfileTableViewCell.self, forCellReuseIdentifier: "SideMenuProfileTableViewCell")
        result.showsVerticalScrollIndicator = false
        return result
    }()
    
    lazy var sampleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.switchBackgroundColor
        toggle.addTarget(self, action: #selector(self.sampleSwitchValueChanged(_:)), for: .valueChanged)
        toggle.transform = CGAffineTransform(scaleX: 0.80, y: 0.75)
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
    
    private var hasTappableProfilePicture: Bool = false
    @objc public var size: CGFloat = 30 // Not an implicitly unwrapped optional due to Obj-C limitations
    @objc public var useFallbackPicture = false
    @objc public var publicKey: String!
    @objc public var additionalPublicKey: String?
    @objc public var openGroupProfilePicture: UIImage?
    internal var tableViewHeightConstraint: NSLayoutConstraint!
    
    var menuTitles: [SideMenuItem] = [.myAccount, .settings, .notification, .messageRequests, .recoverySeed, .wallet, .reportIssue, .help, .invite, .about]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        self.navigationController?.isNavigationBarHidden = true
        
        view.addSubViews(closeButton, menuTitleLabel, sampleSwitch, lblversion, lblmodeTitle)
        sampleSwitch.isOn = !isLightMode
        sampleSwitch.thumbTintColor = sampleSwitch.isOn == true ? Colors.bothGreenColor : Colors.switchOffBackgroundColor
        
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
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
    
    @objc func sampleSwitchValueChanged(_ x: UISwitch) {
        if sampleSwitch.isOn {
            AppModeManager.shared.setCurrentAppMode(to: .dark)
            sampleSwitch.thumbTintColor = Colors.bothGreenColor
        } else {
            AppModeManager.shared.setCurrentAppMode(to: .light)
            sampleSwitch.thumbTintColor = Colors.switchOffBackgroundColor
        }
        let origImage = UIImage(named: isLightMode ? "X" : "X")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(tintedImage, for: .normal)
        closeButton.tintColor = isLightMode ? UIColor.black : UIColor.white
        let userInfo = [ "text" : "dark" ]
        NotificationCenter.default.post(name: .myNotificationKey_doodlechange, object: nil, userInfo: userInfo)
        tableView.reloadData()
    }
}


