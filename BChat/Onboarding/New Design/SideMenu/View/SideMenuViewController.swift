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
        return result
    }()
    
    /// darkLightModeSwitch
    lazy var darkLightModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.switchBackgroundColor
        toggle.addTarget(self, action: #selector(darkLightModeValueChanged(_:)), for: .valueChanged)
        toggle.transform = CGAffineTransform(scaleX: 0.80, y: 0.75)
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
        button.setBackgroundImage(UIImage(named: "ic_closeNew"), for: .normal)
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
        darkLightModeSwitch.thumbTintColor = darkLightModeSwitch.isOn == true ? Colors.bothGreenColor : Colors.switchOffBackgroundColor
        
        let origImage = UIImage(named: isLightMode ? "X" : "X")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(tintedImage, for: .normal)
        closeButton.tintColor = isLightMode ? .black : .white
        
        guard let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] else { return }
        guard let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] else { return }
        self.lblversion.text = "BChat \(version) (\(buildNumber))"
        
        // Table view
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.pin(.leading, to: .leading, of: view)
        tableView.pin(.top, to: .bottom, of: closeButton, withInset: 15)
        tableView.pin(.trailing, to: .trailing, of: view)
        viewModel.tableViewHeightConstraint = tableView.set(.height, to: 550)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 15),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            
            menuTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            menuTitleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            darkLightModeSwitch.trailingAnchor .constraint(equalTo: view.trailingAnchor, constant: -20),
            darkLightModeSwitch.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24.333),
            
            lblmodeTitle.trailingAnchor .constraint(equalTo: darkLightModeSwitch.leadingAnchor, constant: -12),
            lblmodeTitle.centerYAnchor.constraint(equalTo: darkLightModeSwitch.centerYAnchor),
            
            lblversion.trailingAnchor .constraint(equalTo: view.trailingAnchor, constant: -20),
            lblversion.topAnchor.constraint(equalTo: darkLightModeSwitch.bottomAnchor, constant: 25)
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
        if darkLightModeSwitch.isOn {
            AppModeManager.shared.setCurrentAppMode(to: .dark)
            darkLightModeSwitch.thumbTintColor = Colors.bothGreenColor
        } else {
            AppModeManager.shared.setCurrentAppMode(to: .light)
            darkLightModeSwitch.thumbTintColor = Colors.switchOffBackgroundColor
        }
        let origImage = UIImage(named: isLightMode ? "X" : "X")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        closeButton.setImage(tintedImage, for: .normal)
        closeButton.tintColor = isLightMode ? UIColor.black : UIColor.white
        let userInfo = [ "text" : "dark" ]
        NotificationCenter.default.post(name: .doodleChangeNotification, object: nil, userInfo: userInfo)
        tableView.reloadData()
    }
}


