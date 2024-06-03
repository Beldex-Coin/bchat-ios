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
    let sectionNames = [" ", "Wallet", "Personal"]
    var personalNamesArray = ["Address Book","Change PIN"]
    var backAPI = false
    var nodeValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorNew
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
            nodeValue = SaveUserDefaultsData.FinalWallet_node
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
            let logoImage = isLightMode ? "ic_current_node_dark" : "ic_current_node_new"
            cell.logoImage.image = UIImage(named: logoImage)
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
            if indexPath.row == 0 {
                let logoImage = isLightMode ? "ic_addressbook_dark" : "ic_Address_book_new"
                cell.logoImage.image = UIImage(named: logoImage)
                cell.backGroundView.layer.cornerRadius = 16
                cell.backGroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }else{
                let logoImage = isLightMode ? "ic_change_pin_dark" : "ic_Change_pin_new"
                cell.logoImage.image = UIImage(named: logoImage)
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
                let vc = NewPasswordVC()
                vc.isGoingBack = true
                vc.isCreatePassword = true
                vc.isChangePassword = true
                navigationController!.pushViewController(vc, animated: true)
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
        label.frame = CGRect(x: 30, y: 0, width: tableView.frame.width - 30, height: 30)
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
            return 350 + 28
        }else {
            return 56.5//UITableView.automaticDimension
        }
    }
}

class CurrentNodeTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cellBackgroundColorForNodeList
        view.layer.cornerRadius = 16
        return view
    }()
    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_expand_arrow_dark" : "ic_back_New"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(logoImage)
        backGroundView.addSubview(currentNodeTitleLabel)
        backGroundView.addSubview(nodeNameLabel)
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
            currentNodeTitleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 20),
            currentNodeTitleLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: -10),
           
            currentNodeTitleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 20),
            
            nodeNameLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 20),
            nodeNameLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: 13),
          
            nodeNameLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -20),
            
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


class PersonalSettingsTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cellBackgroundColorForNodeList
        view.layer.cornerRadius = 16
        return view
    }()
    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
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
        let logoImage = isLightMode ? "ic_expand_arrow_dark" : "ic_back_New"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
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
//            logoImage.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 10),
//            logoImage.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -10),
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
                                               name: .selectedDisplayNameKeyNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSelectedDecimalName),
                                               name: .selectedDecimalNameKeyNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleFeePriorityName),
                                               name: .feePriorityNameKeyNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSelectedCurrencyName),
                                               name: .selectedCurrencyNameKeyNotification,
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
            if indexPath.row == 0 {
                let cell = WalletSettingsSubTableCell(style: .default, reuseIdentifier: "WalletSettingsSubTableCell")
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.titleLabel.text = "Display Balance As"//walletNameArray[indexPath.row]
                cell.subTitleLabel.text = "Beldex Full Balances"//walletSubNameArray[indexPath.row]
                let logoImage = isLightMode ? "ic_displaybalance_dark" : "ic_Display_balance_new"
                cell.logoImage.image = UIImage(named: logoImage)
                cell.spaceView.layer.cornerRadius = 14
                cell.spaceView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                if !SaveUserDefaultsData.SelectedBalance.isEmpty{
                    cell.subTitleLabel.text = SaveUserDefaultsData.SelectedBalance
                }else{
                    cell.subTitleLabel.text = "Beldex Full Balance"
                }
                return cell
            }else if indexPath.row == 1 {
                let cell = WalletSettingsSubTableCell33(style: .default, reuseIdentifier: "WalletSettingsSubTableCell33")
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.titleLabel.text = "Decimals"//walletNameArray[indexPath.row]
                cell.subTitleLabel.text = "2 - Two (0.00)"//walletSubNameArray[indexPath.row]
                let logoImage = isLightMode ? "ic_decimal_dark" : "ic_Decimal_new"
                cell.logoImage.image = UIImage(named: logoImage)
                if !SaveUserDefaultsData.SelectedDecimal.isEmpty{
                    cell.subTitleLabel.text = SaveUserDefaultsData.SelectedDecimal
                }else{
                    cell.subTitleLabel.text = "4 - Four (0.0000)"
                }
                return cell
            }else if indexPath.row == 2 {
                let cell = WalletSettingsSubTableCell33(style: .default, reuseIdentifier: "WalletSettingsSubTableCell33")
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.titleLabel.text = "Currency"//walletNameArray[indexPath.row]
                cell.subTitleLabel.text = "USD"//walletSubNameArray[indexPath.row]
                let logoImage = isLightMode ? "ic_currency_dark" : "ic_currency_new"
                cell.logoImage.image = UIImage(named: logoImage)
                if !SaveUserDefaultsData.SelectedCurrency.isEmpty{
                    cell.subTitleLabel.text = SaveUserDefaultsData.SelectedCurrency.uppercased()
                }else{
                    cell.subTitleLabel.text = "USD".uppercased()
                }
                return cell
            }else {
                let cell = WalletSettingsSubTableCell33(style: .default, reuseIdentifier: "WalletSettingsSubTableCell33")
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.titleLabel.text = "Fee Priority"//walletNameArray[indexPath.row]
                cell.subTitleLabel.text = "Flash"//walletSubNameArray[indexPath.row]
                let logoImage = isLightMode ? "ic_feeperiority_dark" : "ic_fee_priority_new"
                cell.logoImage.image = UIImage(named: logoImage)
                if !SaveUserDefaultsData.FeePriority.isEmpty {
                    cell.subTitleLabel.text = SaveUserDefaultsData.FeePriority
                }else{
                    cell.subTitleLabel.text = "Flash"
                }
                return cell
            }
        }else {
            let cell = WalletSettingsSubTableCell2(style: .default, reuseIdentifier: "WalletSettingsSubTableCell2")
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            cell.titleLabel.text = NSLocalizedString("SAVE_RECEIPIENT_ADDRESS", comment: "")
            cell.spaceView.layer.cornerRadius = 16
            cell.spaceView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            let logoImage = isLightMode ? "ic_saverecepientaddress_dark" : "ic_save_new"
            cell.logoImage.image = UIImage(named: logoImage)
            cell.toggleSwitch.tag = indexPath.row
            cell.toggleSwitch.addTarget(self, action: #selector(self.saveRecipientAddressButtonTapped(_:)), for: .valueChanged)
            if SaveUserDefaultsData.SaveReceipeinetSwitch == false {
                cell.toggleSwitch.isOn = false
                cell.toggleSwitch.thumbTintColor = Colors.switchOffBackgroundColor
            }else{
                cell.toggleSwitch.isOn = true
                cell.toggleSwitch.thumbTintColor = Colors.bothGreenColor
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
             x.thumbTintColor = Colors.bothGreenColor
         }else{
             SaveUserDefaultsData.SaveReceipeinetSwitch = false
             x.thumbTintColor = Colors.switchOffBackgroundColor
         }
     }
}


class WalletSettingsSubTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var spaceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cellBackgroundColorForNodeList
        return view
    }()
    
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cellBackgroundColorForNodeList
        return view
    }()
    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var subTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.walletSettingsSubTitleLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_expand_arrow_dark" : "ic_back_New"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(spaceView)
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(logoImage)
        backGroundView.addSubview(titleLabel)
        backGroundView.addSubview(subTitleLabel)
        backGroundView.addSubview(arrowImage)
        NSLayoutConstraint.activate([
            spaceView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            spaceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            spaceView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            spaceView.heightAnchor.constraint(equalToConstant: 14),
            
            backGroundView.topAnchor.constraint(equalTo: spaceView.bottomAnchor, constant: 0),
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

class WalletSettingsSubTableCell33: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cellBackgroundColorForNodeList
        return view
    }()
    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var subTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.walletSettingsSubTitleLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_expand_arrow_dark" : "ic_back_New"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
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
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 10),
            
            subTitleLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 20),
            subTitleLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: 12),
            subTitleLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -10),
           
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
    
    lazy var spaceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cellBackgroundColorForNodeList
        return view
    }()
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cellBackgroundColorForNodeList
        return view
    }()
    lazy var logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.isEnabled = true
        toggle.onTintColor = Colors.switchBackgroundColor
        toggle.transform = CGAffineTransform(scaleX: 0.80, y: 0.75)
        return toggle
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(spaceView)
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(logoImage)
        backGroundView.addSubview(titleLabel)
        backGroundView.addSubview(toggleSwitch)
        
        if toggleSwitch.isOn == true {
            toggleSwitch.thumbTintColor = Colors.bothGreenColor
        }else {
            toggleSwitch.thumbTintColor = Colors.switchOffBackgroundColor
        }
        
        NSLayoutConstraint.activate([
            spaceView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            spaceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            spaceView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            spaceView.heightAnchor.constraint(equalToConstant: 14),
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: spaceView.topAnchor, constant: -0),
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
