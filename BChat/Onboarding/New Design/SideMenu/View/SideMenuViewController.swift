// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class SideMenuViewController: BaseVC {
    
    // MARK: - UIElements
    
    /// tableView
    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = .clear
        result.separatorStyle = .none
        result.register(SideMenuTableViewCell.self, forCellReuseIdentifier: SideMenuTableViewCell.reuseIdentifier)
        result.register(SideMenuProfileTableViewCell.self, forCellReuseIdentifier: SideMenuProfileTableViewCell.reuseIdentifier)
        result.showsVerticalScrollIndicator = false
        result.dataSource = self
        result.delegate = self
        return result
    }()
    
    /// darkLightModeSwitch
    lazy var darkLightModeSwitch: CustomSwitch = {
        let toggle = CustomSwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.switchOnTintColor
        toggle.offTintColor = Colors.bothWhiteColor
        toggle.addTarget(self, action: #selector(darkLightModeValueChanged(_:)), for: .valueChanged)
        toggle.onThumbColor = Colors.bothGreenColor
        toggle.offThumbColor = Colors.bothGreenColor
        // For Thumb Image
        toggle.onThumbImage = UIImage(named: "switchon_appmode")
        toggle.offThumbImage = UIImage(named: "switchoff_appmode")
        // For Background Image
//        toggle.onBackImage = UIImage(named: "darkmode_switch_image")
//        toggle.offBackImage = UIImage(named: "lightmode_switch_image")
        return toggle
    }()
    
    /// menuTitleLabel
    lazy var menuTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bchatLabelNameColor
        result.font = Fonts.boldOpenSans(ofSize: 23)
        result.textAlignment = .right
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Menu"
        return result
    }()
    
    /// lblversion
    lazy var lblversion: UILabel = {
        let result = UILabel()
        result.textColor = Colors.noDataLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .right
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    /// lblmodeTitle
    lazy var lblmodeTitle: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .right
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Dark Mode"
        return result
    }()
    
    /// closeButton
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        if #available(iOS 15.0, *) {
            button.configuration?.imagePadding = 2.5
        }
        return button
    }()
    
    // MARK: - Properties
    
    @objc public var size: CGFloat = 30 // Not an implicitly unwrapped optional due to Obj-C limitations
    @objc public var useFallbackPicture = false
    @objc public var publicKey: String!
    @objc public var additionalPublicKey: String?
    @objc public var openGroupProfilePicture: UIImage?
    
    var viewModel = SideMenuViewModel()
    
    // MARK: - UIViewController life cycle
    
    /// view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        self.navigationController?.isNavigationBarHidden = true
        
        view.addSubViews(closeButton, menuTitleLabel, darkLightModeSwitch, lblversion, lblmodeTitle)
        
        darkLightModeSwitch.isOn = !isLightMode
        let origImage = UIImage(named: "X")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(tintedImage, for: .normal)
        closeButton.tintColor = isLightMode ? .black : .white
        
        guard let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] else { return }
        guard let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] else { return }
        self.lblversion.text = "BChat \(version)"

        view.addSubview(tableView)
        
        tableView.pin(.leading, to: .leading, of: view)
        tableView.pin(.top, to: .bottom, of: closeButton, withInset: 15)
        tableView.pin(.trailing, to: .trailing, of: view)
        viewModel.tableViewHeightConstraint = tableView.set(.height, to: 550)
        
        NSLayoutConstraint.activate([
            
            menuTitleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15),
            menuTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            closeButton.centerYAnchor.constraint(equalTo: menuTitleLabel.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            darkLightModeSwitch.trailingAnchor .constraint(equalTo: view.trailingAnchor, constant: -20),
            darkLightModeSwitch.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 70),
            darkLightModeSwitch.widthAnchor.constraint(equalToConstant: 41.48),
            darkLightModeSwitch.heightAnchor.constraint(equalToConstant: 22.57),
            
            lblmodeTitle.trailingAnchor .constraint(equalTo: darkLightModeSwitch.leadingAnchor, constant: -12),
            lblmodeTitle.centerYAnchor.constraint(equalTo: darkLightModeSwitch.centerYAnchor),
            
            lblversion.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 70),
            lblversion.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    // MARK: - UIButton action
    
    /// close button tapped
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    
    /// Get profile picture
    func getProfilePicture(of size: CGFloat, for publicKey: String) -> UIImage? {
        guard !publicKey.isEmpty else { return nil }
        if let profilePicture = OWSProfileManager.shared().profileAvatar(forRecipientId: publicKey) {
            viewModel.hasTappableProfilePicture = true
            return profilePicture
        } else {
            viewModel.hasTappableProfilePicture = false
            // TODO: Pass in context?
            let displayName = Storage.shared.getContact(with: publicKey)?.name ?? publicKey
            return Identicon.generatePlaceholderIcon(seed: publicKey, text: displayName, size: size)
        }
    }
    
    /// darkLightModeValueChanged
    @objc func darkLightModeValueChanged(_ sender: UISwitch) {
        AppModeManager.shared.setCurrentAppMode(to: darkLightModeSwitch.isOn ? .dark : .light)
        let image = UIImage(named: "X")?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(image, for: .normal)
        closeButton.tintColor = isLightMode ? .black : .white
        let userInfo = [ "text" : "dark" ]
        NotificationCenter.default.post(name: .doodleChangeNotification, object: nil, userInfo: userInfo)
        tableView.reloadData()
    }
}

