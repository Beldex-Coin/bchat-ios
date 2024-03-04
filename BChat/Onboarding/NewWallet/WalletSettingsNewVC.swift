// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class WalletSettingsNewVC: BaseVC, UITableViewDataSource, UITableViewDelegate {

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
    //MAINNET
    var nodeArray = ["explorer.beldex.io:19091","mainnet.beldex.io:29095","publicnode1.rpcnode.stream:29095","publicnode2.rpcnode.stream:29095","publicnode3.rpcnode.stream:29095","publicnode4.rpcnode.stream:29095"]//["149.102.156.174:19095"]
    //TESTNET
//    var nodeArray = ["149.102.156.174:19095"]
    let sectionNames = [" ", "Wallet", "Personal"]
    var personalNamesArray = ["Address Book","Change PIN"]
    var personalImagesArray = ["ic_Address_book_new","ic_Change_pin_new"]
    var backAPI = false
    var nodeValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Wallet Settings"
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: -35),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0)
        ])
        
        //Here Random node and Selected node
        if !SaveUserDefaultsData.SelectedNode.isEmpty {
            nodeValue = SaveUserDefaultsData.SelectedNode
        }else{
            nodeValue = nodeArray.randomElement()!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Selected node
        if backAPI == true{
            nodeValue = SaveUserDefaultsData.SelectedNode
            tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1{
            return 1
        }else {
            return personalNamesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = CurrentNodeTableCell(style: .default, reuseIdentifier: "CurrentNodeTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            //Selected node
            if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
                cell.nodeNameLabel.text = nodeValue
            }else{
                cell.nodeNameLabel.text = "Waiting for network.."
            }
            return cell
        }else if indexPath.section == 1 {
            let cell = WalletSettingsTableCell(style: .default, reuseIdentifier: "WalletSettingsTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            return cell
        }else {
            let cell = PersonalSettingsTableCell(style: .default, reuseIdentifier: "PersonalSettingsTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            cell.titleLabel.text = personalNamesArray[indexPath.row]
            cell.logoImage.image = UIImage(named: personalImagesArray[indexPath.row])
            
            if indexPath.row == 0 {
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }else{
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let vc = WalletNodeListVC()
                navigationController!.pushViewController(vc, animated: true)
            }
        }else if indexPath.section == 1{
            
        }else{
            if indexPath.row == 0 {
                let vc = WalletAddressBookNewVC()
                navigationController!.pushViewController(vc, animated: true)
            }else {
                
            }
        }
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
            return 420
        }else {
            return UITableView.automaticDimension
        }
    }
}

class CurrentNodeTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        view.layer.cornerRadius = 16
        return view
    }()
    lazy var directionLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_current_node_new", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var currentNodeTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.greenColor
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("CURRENT_NODE_TITLE_NEW", comment: "")
        return result
    }()
    lazy var nodeNameLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor.white
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "publicnode3.rpcnode.stream"
        return result
    }()
    lazy var arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_back_New", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(directionLogoImage)
        backGroundView.addSubview(currentNodeTitleLabel)
        backGroundView.addSubview(nodeNameLabel)
        backGroundView.addSubview(arrowImage)
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            directionLogoImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 28),
            directionLogoImage.widthAnchor.constraint(equalToConstant: 18),
            directionLogoImage.heightAnchor.constraint(equalToConstant: 18),
            directionLogoImage.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            currentNodeTitleLabel.leadingAnchor.constraint(equalTo: directionLogoImage.trailingAnchor, constant: 20),
            currentNodeTitleLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: -10),
            currentNodeTitleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 28),
            nodeNameLabel.leadingAnchor.constraint(equalTo: directionLogoImage.trailingAnchor, constant: 20),
            nodeNameLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: 13),
            nodeNameLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -28),
            arrowImage.heightAnchor.constraint(equalToConstant: 15),
            arrowImage.widthAnchor.constraint(equalToConstant: 15),
            arrowImage.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -28),
            arrowImage.centerYAnchor.constraint(equalTo: directionLogoImage.centerYAnchor),
        ])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class PersonalSettingsTableCell: UITableViewCell {
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
        imageView.image = UIImage(named: "ic_Address_book_new", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("ADDRESS_BOOK_TITLE_NEW", comment: "")
        return result
    }()
    lazy var arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_back_New", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(logoImage)
        backGroundView.addSubview(titleLabel)
        backGroundView.addSubview(arrowImage)
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            logoImage.widthAnchor.constraint(equalToConstant: 18),
            logoImage.heightAnchor.constraint(equalToConstant: 18),
            logoImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 28),
            logoImage.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            logoImage.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 20),
            logoImage.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -20),

            titleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),

            arrowImage.heightAnchor.constraint(equalToConstant: 15),
            arrowImage.widthAnchor.constraint(equalToConstant: 15),
            arrowImage.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -25),
            arrowImage.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
        ])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class WalletSettingsTableCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
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
    
    var walletNameArray = ["Display Balance As","Decimals","Currency","Fee Priority"]
    var walletSubNameArray = ["Beldex Full Balances","2 - Two (0.00)","USD","Flash"]
    var walletImageArray = ["ic_Display_balance_new","ic_Decimal_new","ic_currency_new","ic_fee_priority_new"]
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -0),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0)
        ])
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSelectedDisplayName),
                                               name: Notification.Name("selectedDisplayNameKey"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSelectedDecimalName),
                                               name: Notification.Name("selectedDecimalNameKey"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleFeePriorityName),
                                               name: Notification.Name("feePriorityNameKey"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSelectedCurrencyName),
                                               name: Notification.Name("selectedCurrencyNameKey"),
                                               object: nil)
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Here Balance display
    @objc func handleSelectedDisplayName(notification: NSNotification) {
        if let stringValue = notification.object as? NSObject {
            if let myMessage = stringValue as? String{
                SaveUserDefaultsData.SelectedBalance = myMessage
                tableView.reloadData()
            }
        }
    }
    //Here Decimal display
    @objc func handleSelectedDecimalName(notification: NSNotification) {
        if let stringValue = notification.object as? NSObject {
            if let myMessage = stringValue as? String{
                SaveUserDefaultsData.SelectedDecimal = myMessage
                tableView.reloadData()
            }
        }
    }
    //Here Fee Priority
    @objc func handleFeePriorityName(notification: NSNotification) {
        if let stringValue = notification.object as? NSObject {
            if let myMessage = stringValue as? String{
                SaveUserDefaultsData.FeePriority = myMessage
                tableView.reloadData()
            }
        }
    }
    //Here Currency name
    @objc func handleSelectedCurrencyName(notification: NSNotification) {
        if let stringValue = notification.object as? NSObject {
            if let myMessage = stringValue as? String{
                SaveUserDefaultsData.SelectedCurrency = myMessage
                tableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return walletNameArray.count
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = WalletSettingsSubTableCell(style: .default, reuseIdentifier: "WalletSettingsSubTableCell")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.titleLabel.text = walletNameArray[indexPath.row]
            cell.subTitleLabel.text = walletSubNameArray[indexPath.row]
            cell.logoImage.image = UIImage(named: walletImageArray[indexPath.row])
            if indexPath.row == 0 {
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                if !SaveUserDefaultsData.SelectedBalance.isEmpty{
                    cell.subTitleLabel.text = SaveUserDefaultsData.SelectedBalance
                }else{
                    cell.subTitleLabel.text = "Beldex Full Balance"
                }
            }else if indexPath.row == 1{
                if !SaveUserDefaultsData.SelectedDecimal.isEmpty{
                    cell.subTitleLabel.text = SaveUserDefaultsData.SelectedDecimal
                }else{
                    cell.subTitleLabel.text = "4 - Four (0.0000)"
                }
            }else if indexPath.row == 2 {
                if !SaveUserDefaultsData.SelectedCurrency.isEmpty{
                    cell.subTitleLabel.text = SaveUserDefaultsData.SelectedCurrency.uppercased()
                }else{
                    cell.subTitleLabel.text = "USD".uppercased()
                }
            }else if indexPath.row == 3 {
                if !SaveUserDefaultsData.FeePriority.isEmpty {
                    cell.subTitleLabel.text = SaveUserDefaultsData.FeePriority
                }else{
                    cell.subTitleLabel.text = "Flash"
                }
            }
            return cell
        }else {
            let cell = WalletSettingsSubTableCell2(style: .default, reuseIdentifier: "WalletSettingsSubTableCell2")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.titleLabel.text = NSLocalizedString("SAVE_RECEIPIENT_ADDRESS", comment: "")
            cell.backGroundView.layer.cornerRadius = 16
            cell.backGroundView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
            cell.toggleSwitch.tag = indexPath.row
            cell.toggleSwitch.addTarget(self, action: #selector(self.saveRecipientAddressButtonTapped(_:)), for: .valueChanged)
            if SaveUserDefaultsData.SaveReceipeinetSwitch == false {
                cell.toggleSwitch.isOn = false
            }else{
                cell.toggleSwitch.isOn = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0{
                if let viewController = parentViewController() as? WalletSettingsNewVC {
                    let vc = DisplayBalanceOptionVC()
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    viewController.present(vc, animated: true, completion: nil)
                }
            }else if indexPath.row == 1{
                if let viewController = parentViewController() as? WalletSettingsNewVC {
                    let vc = DecimalsPopUpVC()
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    viewController.present(vc, animated: true, completion: nil)
                }
            }else if indexPath.row == 2{
                if let viewController = parentViewController() as? WalletSettingsNewVC {
                    let vc = CurrencyPopUpVC()
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    viewController.present(vc, animated: true, completion: nil)
                }
            }else if indexPath.row == 3{
                if let viewController = parentViewController() as? WalletSettingsNewVC {
                    let vc = FeePriorityVC()
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    viewController.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // Save Recipient Address
     @objc func saveRecipientAddressButtonTapped(_ x: UISwitch) {
         if (x.isOn){
             SaveUserDefaultsData.SaveReceipeinetSwitch = true
         }else{
             SaveUserDefaultsData.SaveReceipeinetSwitch = false
         }
     }
}


class WalletSettingsSubTableCell: UITableViewCell {
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
        imageView.image = UIImage(named: "ic_receive_New 1", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var subTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_back_New", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(logoImage)
        backGroundView.addSubview(titleLabel)
        backGroundView.addSubview(subTitleLabel)
        backGroundView.addSubview(arrowImage)
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            logoImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 28),
            logoImage.widthAnchor.constraint(equalToConstant: 18),
            logoImage.heightAnchor.constraint(equalToConstant: 18),
            logoImage.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 20),
            subTitleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 20),
            subTitleLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: 12),
            subTitleLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -20),
            arrowImage.heightAnchor.constraint(equalToConstant: 15),
            arrowImage.widthAnchor.constraint(equalToConstant: 15),
            arrowImage.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -28),
            arrowImage.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
        ])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class WalletSettingsSubTableCell2: UITableViewCell {
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
        imageView.image = UIImage(named: "ic_save_new", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
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
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(logoImage)
        backGroundView.addSubview(titleLabel)
        backGroundView.addSubview(toggleSwitch)
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            logoImage.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 20),
            logoImage.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -28),
            logoImage.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 28),
            logoImage.widthAnchor.constraint(equalToConstant: 18),
            logoImage.heightAnchor.constraint(equalToConstant: 18),
            logoImage.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
            toggleSwitch.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -28),
            toggleSwitch.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
        ])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
