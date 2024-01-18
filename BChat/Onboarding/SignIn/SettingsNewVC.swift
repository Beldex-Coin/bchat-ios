// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class SettingsNewVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Settings"
        
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = SettingsTableCell(style: .default, reuseIdentifier: "SettingsTableCell")
            cell.backgroundColor = .clear
            cell.titleLabel.text = "Screen Security"
            cell.subTitleLabel.text = "Incognito Keyboard"
            cell.titleDescriptionLabel.text = "Block Screenshots in the recents list and inside the app"
            cell.subTitleDescriptionLabel.text = "Request keyboard to disable personalized learning"
            cell.logoImage.image = UIImage(named: "ic_Screen_securityNew")
            cell.logoImage2.image = UIImage(named: "ic_IncognitoNew")
            
            return cell
        }else if indexPath.section == 1 {
            let cell = SettingsTableCell(style: .default, reuseIdentifier: "SettingsTableCell")
            cell.backgroundColor = .clear
            cell.titleLabel.text = "Start Wallet"
            cell.subTitleLabel.text = "Pay as you chat"
            cell.titleDescriptionLabel.text = "Enabling wallet will allow you to send and receive BDX"
            cell.subTitleDescriptionLabel.text = "Enabling ‘Pay as you chat’ will allow you to send receive BDX right from the chat window"
            cell.logoImage.image = UIImage(named: "ic_WalletNew")
            cell.logoImage2.image = UIImage(named: "ic_GroupNew")
            
            return cell
        }else {
            let cell = SettingsCommunicationTableCell(style: .default, reuseIdentifier: "SettingsCommunicationTableCell")
            cell.backgroundColor = .clear
            
            
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear//UIColor.lightGray // Set the background color as needed
        let label = UILabel()
        label.text = sectionNames[section] // Get the name for the specific section
        label.textColor = Colors.greenColor // Set the text color as needed
        label.frame = CGRect(x: 30, y: 5, width: tableView.frame.width - 30, height: 30) // Adjust the frame as needed
        label.font = Fonts.semiOpenSans(ofSize: 18)
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // Set the height of the header view as needed
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

class SettingsTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        view.layer.cornerRadius = 16
        return view
    }()
    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Newcopy", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var logoImage2: UIImageView = {
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
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    lazy var subTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var subTitleDescriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
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
    lazy var toggleSwitch2: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = .blue
        return toggle
    }()
    lazy var bgview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    lazy var bgview2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        
        backGroundView.addSubview(logoImage)
        backGroundView.addSubview(toggleSwitch)
        backGroundView.addSubview(bgview)
        bgview.addSubview(titleLabel)
        bgview.addSubview(titleDescriptionLabel)
        backGroundView.addSubview(logoImage2)
        backGroundView.addSubview(toggleSwitch2)
        backGroundView.addSubview(bgview2)
        bgview2.addSubview(subTitleLabel)
        bgview2.addSubview(subTitleDescriptionLabel)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            logoImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            logoImage.widthAnchor.constraint(equalToConstant: 22),
            logoImage.heightAnchor.constraint(equalToConstant: 22),
            logoImage.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 40),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            toggleSwitch.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
            
            bgview.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 5),
            bgview.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 10),
            bgview.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -10),
            
            titleLabel.leadingAnchor.constraint(equalTo: bgview.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: bgview.trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: bgview.topAnchor, constant: 17),
            
            titleDescriptionLabel.leadingAnchor.constraint(equalTo: bgview.leadingAnchor, constant: 10),
            titleDescriptionLabel.trailingAnchor.constraint(equalTo: bgview.trailingAnchor, constant: -5),
            titleDescriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            logoImage2.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            logoImage2.widthAnchor.constraint(equalToConstant: 22),
            logoImage2.heightAnchor.constraint(equalToConstant: 22),
            logoImage2.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 60),
            logoImage2.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -40),
            
            toggleSwitch2.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            toggleSwitch2.centerYAnchor.constraint(equalTo: logoImage2.centerYAnchor),
            
            bgview2.topAnchor.constraint(equalTo: bgview.bottomAnchor, constant: 10),
            bgview2.leadingAnchor.constraint(equalTo: logoImage2.trailingAnchor, constant: 10),
            bgview2.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -30),
            bgview2.trailingAnchor.constraint(equalTo: toggleSwitch2.leadingAnchor, constant: -10),
            bgview2.heightAnchor.constraint(equalTo: bgview.heightAnchor),
            
            subTitleLabel.leadingAnchor.constraint(equalTo: bgview2.leadingAnchor, constant: 10),
            subTitleLabel.trailingAnchor.constraint(equalTo: bgview2.trailingAnchor, constant: -10),
            subTitleLabel.topAnchor.constraint(equalTo: bgview2.topAnchor, constant: 17),
            
            subTitleDescriptionLabel.leadingAnchor.constraint(equalTo: bgview2.leadingAnchor, constant: 10),
            subTitleDescriptionLabel.trailingAnchor.constraint(equalTo: bgview2.trailingAnchor, constant: -5),
            subTitleDescriptionLabel.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 4),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SettingsCommunicationTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        view.layer.cornerRadius = 16
        return view
    }()
    lazy var readReceiptsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Read_receipetNew", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var typeIndicatorsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Type_indicaterNew", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var sendLinkPreviewsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_send_linkNew", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var voiceAndVideoCallsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_video_callNew", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var readReceiptsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Read receipts"
        return result
    }()
    lazy var typeIndicatorsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Type indicators"
        return result
    }()
    lazy var sendLinkPreviewsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Send link previews"
        return result
    }()
    lazy var voiceAndVideoCallsTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Voice and video calls"
        return result
    }()
    lazy var readReceiptsDescriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.text = "if read receipts are disabled, you won’t be able to see read receipts from others"
        return result
    }()
    lazy var typeIndicatorsDescriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.text = "if typing indicators are disabled, you won’t be able to see typing indicators from others."
        return result
    }()
    lazy var sendLinkPreviewsDescriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.text = "Previews are supported for imgur, instagram, pinterest, Reddit, and Youtube links."
        return result
    }()
    lazy var voiceAndVideoCallsDescriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.text = "Allow access to accept voice and video calls from other users."
        return result
    }()
    lazy var readReceiptsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = .blue
        return toggle
    }()
    lazy var typeIndicatorsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = .blue
        return toggle
    }()
    lazy var sendLinkPreviewsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = .blue
        return toggle
    }()
    lazy var voiceAndVideoCallsSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = .blue
        return toggle
    }()
    let verticalLeftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 55 // Adjust the spacing as needed
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var bgview: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    lazy var bgview2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    lazy var bgview3: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    lazy var bgview4: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        return view
    }()
    
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(readReceiptsImage)
        backGroundView.addSubview(readReceiptsSwitch)
        backGroundView.addSubview(bgview)
        bgview.addSubview(readReceiptsTitleLabel)
        bgview.addSubview(readReceiptsDescriptionLabel)
        
        backGroundView.addSubview(typeIndicatorsImage)
        backGroundView.addSubview(typeIndicatorsSwitch)
        backGroundView.addSubview(bgview2)
        bgview2.addSubview(typeIndicatorsTitleLabel)
        bgview2.addSubview(typeIndicatorsDescriptionLabel)
        
        backGroundView.addSubview(sendLinkPreviewsImage)
        backGroundView.addSubview(sendLinkPreviewsSwitch)
        backGroundView.addSubview(bgview3)
        bgview3.addSubview(sendLinkPreviewsTitleLabel)
        bgview3.addSubview(sendLinkPreviewsDescriptionLabel)
        
        backGroundView.addSubview(voiceAndVideoCallsImage)
        backGroundView.addSubview(voiceAndVideoCallsSwitch)
        backGroundView.addSubview(bgview4)
        bgview4.addSubview(voiceAndVideoCallsTitleLabel)
        bgview4.addSubview(voiceAndVideoCallsDescriptionLabel)
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            readReceiptsImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            readReceiptsImage.widthAnchor.constraint(equalToConstant: 22),
            readReceiptsImage.heightAnchor.constraint(equalToConstant: 22),
            readReceiptsImage.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 40),
            
            readReceiptsSwitch.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            readReceiptsSwitch.centerYAnchor.constraint(equalTo: readReceiptsImage.centerYAnchor),
            
            bgview.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 5),
            bgview.leadingAnchor.constraint(equalTo: readReceiptsImage.trailingAnchor, constant: 10),
            bgview.trailingAnchor.constraint(equalTo: readReceiptsSwitch.leadingAnchor, constant: -10),
            
            readReceiptsTitleLabel.leadingAnchor.constraint(equalTo: bgview.leadingAnchor, constant: 10),
            readReceiptsTitleLabel.trailingAnchor.constraint(equalTo: bgview.trailingAnchor, constant: -10),
            readReceiptsTitleLabel.topAnchor.constraint(equalTo: bgview.topAnchor, constant: 17),
            
            readReceiptsDescriptionLabel.leadingAnchor.constraint(equalTo: bgview.leadingAnchor, constant: 10),
            readReceiptsDescriptionLabel.trailingAnchor.constraint(equalTo: bgview.trailingAnchor, constant: -5),
            readReceiptsDescriptionLabel.topAnchor.constraint(equalTo: readReceiptsTitleLabel.bottomAnchor, constant: 4),
            
            typeIndicatorsImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            typeIndicatorsImage.widthAnchor.constraint(equalToConstant: 22),
            typeIndicatorsImage.heightAnchor.constraint(equalToConstant: 22),
            typeIndicatorsImage.topAnchor.constraint(equalTo: readReceiptsImage.bottomAnchor, constant: 60),
            
            typeIndicatorsSwitch.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            typeIndicatorsSwitch.centerYAnchor.constraint(equalTo: typeIndicatorsImage.centerYAnchor),
            
            bgview2.topAnchor.constraint(equalTo: bgview.bottomAnchor, constant: 10),
            bgview2.leadingAnchor.constraint(equalTo: typeIndicatorsImage.trailingAnchor, constant: 10),
            bgview2.trailingAnchor.constraint(equalTo: typeIndicatorsSwitch.leadingAnchor, constant: -10),
            bgview2.heightAnchor.constraint(equalTo: bgview.heightAnchor),
            
            typeIndicatorsTitleLabel.leadingAnchor.constraint(equalTo: bgview2.leadingAnchor, constant: 10),
            typeIndicatorsTitleLabel.trailingAnchor.constraint(equalTo: bgview2.trailingAnchor, constant: -10),
            typeIndicatorsTitleLabel.topAnchor.constraint(equalTo: bgview2.topAnchor, constant: 10),
            
            typeIndicatorsDescriptionLabel.leadingAnchor.constraint(equalTo: bgview2.leadingAnchor, constant: 10),
            typeIndicatorsDescriptionLabel.trailingAnchor.constraint(equalTo: bgview2.trailingAnchor, constant: -5),
            typeIndicatorsDescriptionLabel.topAnchor.constraint(equalTo: typeIndicatorsTitleLabel.bottomAnchor, constant: 4),
            
            sendLinkPreviewsImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            sendLinkPreviewsImage.widthAnchor.constraint(equalToConstant: 22),
            sendLinkPreviewsImage.heightAnchor.constraint(equalToConstant: 22),
            sendLinkPreviewsImage.topAnchor.constraint(equalTo: typeIndicatorsImage.bottomAnchor, constant: 60),
            
            sendLinkPreviewsSwitch.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            sendLinkPreviewsSwitch.centerYAnchor.constraint(equalTo: sendLinkPreviewsImage.centerYAnchor),
            
            bgview3.topAnchor.constraint(equalTo: bgview2.bottomAnchor, constant: 10),
            bgview3.leadingAnchor.constraint(equalTo: sendLinkPreviewsImage.trailingAnchor, constant: 10),
            bgview3.trailingAnchor.constraint(equalTo: sendLinkPreviewsSwitch.leadingAnchor, constant: -10),
            bgview3.heightAnchor.constraint(equalTo: bgview2.heightAnchor),
            
            sendLinkPreviewsTitleLabel.leadingAnchor.constraint(equalTo: bgview3.leadingAnchor, constant: 10),
            sendLinkPreviewsTitleLabel.trailingAnchor.constraint(equalTo: bgview3.trailingAnchor, constant: -10),
            sendLinkPreviewsTitleLabel.topAnchor.constraint(equalTo: bgview3.topAnchor, constant: 7),
            
            sendLinkPreviewsDescriptionLabel.leadingAnchor.constraint(equalTo: bgview3.leadingAnchor, constant: 10),
            sendLinkPreviewsDescriptionLabel.trailingAnchor.constraint(equalTo: bgview3.trailingAnchor, constant: -5),
            sendLinkPreviewsDescriptionLabel.topAnchor.constraint(equalTo: sendLinkPreviewsTitleLabel.bottomAnchor, constant: 4),
            
            voiceAndVideoCallsImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 24),
            voiceAndVideoCallsImage.widthAnchor.constraint(equalToConstant: 22),
            voiceAndVideoCallsImage.heightAnchor.constraint(equalToConstant: 22),
            voiceAndVideoCallsImage.topAnchor.constraint(equalTo: sendLinkPreviewsImage.bottomAnchor, constant: 60),
            voiceAndVideoCallsImage.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -45),
            
            voiceAndVideoCallsSwitch.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            voiceAndVideoCallsSwitch.centerYAnchor.constraint(equalTo: voiceAndVideoCallsImage.centerYAnchor),
            
            bgview4.topAnchor.constraint(equalTo: bgview3.bottomAnchor, constant: 10),
            bgview4.leadingAnchor.constraint(equalTo: voiceAndVideoCallsImage.trailingAnchor, constant: 10),
            bgview4.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -10),
            bgview4.trailingAnchor.constraint(equalTo: voiceAndVideoCallsSwitch.leadingAnchor, constant: -10),
            bgview4.heightAnchor.constraint(equalTo: bgview3.heightAnchor),
            
            voiceAndVideoCallsTitleLabel.leadingAnchor.constraint(equalTo: bgview4.leadingAnchor, constant: 10),
            voiceAndVideoCallsTitleLabel.trailingAnchor.constraint(equalTo: bgview4.trailingAnchor, constant: -10),
            voiceAndVideoCallsTitleLabel.topAnchor.constraint(equalTo: bgview4.topAnchor, constant: 7),
            
            voiceAndVideoCallsDescriptionLabel.leadingAnchor.constraint(equalTo: bgview4.leadingAnchor, constant: 10),
            voiceAndVideoCallsDescriptionLabel.trailingAnchor.constraint(equalTo: bgview4.trailingAnchor, constant: -5),
            voiceAndVideoCallsDescriptionLabel.topAnchor.constraint(equalTo: voiceAndVideoCallsTitleLabel.bottomAnchor, constant: 4),
            
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
