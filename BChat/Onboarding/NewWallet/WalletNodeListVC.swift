// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import Alamofire
import BChatUIKit

class WalletNodeListVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
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
    private lazy var refreshButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString(NSLocalizedString("REFRESH_BUTTON_NEW", comment: ""), comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        result.addTarget(self, action: #selector(refreshButtonAction), for: UIControl.Event.touchUpInside)
        result.backgroundColor = Colors.backgroundViewColor
        result.setTitleColor(Colors.addressBookNoContactLabelColor, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var addNodeButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString(NSLocalizedString("ADD_NODE_BUTTON_NEW", comment: ""), comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        result.addTarget(self, action: #selector(addNodeButtonAction), for: UIControl.Event.touchUpInside)
        result.backgroundColor = Colors.greenColor
        result.setTitleColor(UIColor.white, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var buttonStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ refreshButton, addNodeButton ])
        result.axis = .horizontal
        result.spacing = 15
        result.distribution = .fillEqually
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    //MAINNET
    var nodeArray = ["explorer.beldex.io:19091","mainnet.beldex.io:29095","publicnode1.rpcnode.stream:29095","publicnode2.rpcnode.stream:29095","publicnode3.rpcnode.stream:29095","publicnode4.rpcnode.stream:29095"]//["149.102.156.174:19095"]
    //TESTNET
//    var nodeArray = ["149.102.156.174:19095"]
    var randomNodeValue = ""
    var randomValueAfterAddNewNode = ""
    var selectedIndex : Int = 70
    var selectedValue = ""
    var testResultFlag = false
    var netType = false
    var nodePopViewInitial = 0.0
    var currentIndexForEditNode = -1
    var indexForStatusOfNode = -1
    var checkedData = [String: String]()
    var checkedDataForTimeInterval = [String: String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.viewBackgroundColorNew
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Nodes", style: .plain, target: nil, action: nil)
//        self.title = ""
        
        view.addSubview(tableView)
        view.addSubview(buttonStackView)
        let logoImage = isLightMode ? "ic_refresh_new" : "ic_refresh_black"
        refreshButton.tintColor = isLightMode ? UIColor.black : UIColor.white
        refreshButton.addRightIcon(image: UIImage(named: logoImage)!.withRenderingMode(.alwaysTemplate))
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            buttonStackView.heightAnchor.constraint(equalToConstant: 54),
            buttonStackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
        
        randomNodeValue = SaveUserDefaultsData.FinalWallet_node
        randomValueAfterAddNewNode = nodeArray.randomElement()!
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
        }else{
            nodeArray.removeAll()
            tableView.reloadData();
        }
        
        for i in 0 ..< nodeArray.count {
            self.forVerifyAllNodeURI(host_port: self.nodeArray[i])
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNodePopUpOkeyAction(_:)), name: Notification.Name(rawValue: "refreshNodePopUpOk"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(switchNodePopUpOkeyAction(_:)), name: Notification.Name(rawValue: "switchNodePopUpVCOk"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SaveUserDefaultsData.SaveLocalNodelist != []{
            if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
                nodeArray = SaveUserDefaultsData.SaveLocalNodelist
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshButton.layer.cornerRadius = refreshButton.frame.height/2
        addNodeButton.layer.cornerRadius = addNodeButton.frame.height/2
    }
    
    func forVerifyAllNodeURI(host_port:String) {
        let url = "http://" + host_port + "/json_rpc"
        let param = ["jsonrpc": "2.0", "id": "0", "method": "getlastblockheader"]
        let dataTask = Session.default.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
        dataTask.responseJSON { (response) in
            if let json = response.value as? [String: Any],
               let result = json["result"] as? [String: Any],
               let status = result["status"] as? String,
               let header = result["block_header"] as? [String: Any],
               let timestamp = header["timestamp"] as? Int,
               timestamp > 0
            {
                self.checkedData[host_port] = status
                let date = NSDate(timeIntervalSince1970: TimeInterval(timestamp))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(name: "Asia/Kolkata") as TimeZone?
                let diffinSeconds = Date().timeIntervalSince1970 - date.timeIntervalSince1970
                let diffinMinutes = diffinSeconds/60
                let diffinhours = diffinSeconds / (60.0 * 60.0)
                let diffindays = diffinSeconds / (60.0 * 60.0 * 24.0)
                if (diffinMinutes < 2) {
                    self.checkedDataForTimeInterval[host_port] = String(Int(diffinSeconds)) + " seconds ago"
                } else if (diffinhours < 2) {
                    self.checkedDataForTimeInterval[host_port] = String(Int(diffinMinutes)) + " minutes ago"
                } else if (diffindays < 2) {
                    self.checkedDataForTimeInterval[host_port] = String(Int(diffinhours)) + " hours ago"
                } else {
                    self.checkedDataForTimeInterval[host_port] = String(Int(diffindays)) + " days ago"
                }
            } else {
                self.checkedData[host_port] = "FALSE"
                self.checkedDataForTimeInterval[host_port] = "CONNECTION ERROR"
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = NodeListTableCell(style: .default, reuseIdentifier: "NodeListTableCell")
        cell.backgroundColor = .clear
        cell.nodeNameTitleLabel.text = nodeArray[indexPath.row]
        cell.isUserInteractionEnabled = true
        
        if checkedData.keys.contains(nodeArray[indexPath.row]) {
            let dictionaryIndex = checkedData.index(forKey: nodeArray[indexPath.row])
            let status = checkedData.values[dictionaryIndex!]
            if status == "OK" {
                cell.circularView.image = UIImage(named: "ic_fullCircle")
            } else {
                cell.circularView.image = UIImage(named: "ic_EllipseNew")
            }
        }
        
        if checkedDataForTimeInterval.keys.contains(nodeArray[indexPath.row]) {
            let dictionaryIndex = checkedDataForTimeInterval.index(forKey: nodeArray[indexPath.row])
            let notError = checkedDataForTimeInterval.values[dictionaryIndex!]
            if notError == "CONNECTION ERROR" {
                cell.nodeNameTitleLabel.textColor = Colors.cellNodeOffColor
                cell.nodeIPLabel.text = checkedDataForTimeInterval.values[dictionaryIndex!]
            } else {
                cell.nodeIPLabel.text = "Last Block: " +  checkedDataForTimeInterval.values[dictionaryIndex!]
            }
        }
        
        if(!SaveUserDefaultsData.SelectedNode.isEmpty) {
            let selectedNodeData = SaveUserDefaultsData.SelectedNode
            if(nodeArray[indexPath.row] == selectedNodeData) {
                selectedIndex = indexPath.row
                cell.backGroundView.layer.borderWidth = 1.5
                cell.backGroundView.layer.borderColor = Colors.greenColor.cgColor
                cell.isUserInteractionEnabled = false
                cell.nodeNameTitleLabel.textColor = Colors.textColor
                cell.nodeIPLabel.textColor = Colors.cellIpLabelColor2
            }
        } else if (nodeArray.count == 6) {
            if(nodeArray[indexPath.row] == randomNodeValue) {
                cell.backGroundView.layer.borderWidth = 1.5
                cell.backGroundView.layer.borderColor = Colors.greenColor.cgColor
                cell.isUserInteractionEnabled = false
                cell.nodeNameTitleLabel.textColor = Colors.textColor
                cell.nodeIPLabel.textColor = Colors.cellIpLabelColor2
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NodeListTableCell
        cell.selectionStyle = .none
        if checkedDataForTimeInterval.keys.contains(nodeArray[indexPath.row]) {
            let dictionaryIndex = checkedDataForTimeInterval.index(forKey: nodeArray[indexPath.row])
            let notError = checkedDataForTimeInterval.values[dictionaryIndex!]
            if notError == "CONNECTION ERROR" {
                self.showToastMsg(message: "Please connect some another node", seconds: 1.0)
            }else{
                selectedIndex = indexPath.row
                selectedValue = self.nodeArray[indexPath.row]
                let vc = SwitchNodePopUpVC()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NodeListTableCell
        cell.backGroundView.layer.borderWidth = 0
        cell.backGroundView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func refreshButtonAction(_ sender: UIButton){
        let vc = RefreshNodePopUpVC()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func refreshNodePopUpOkeyAction(_ notification: Notification) {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
            SaveUserDefaultsData.SwitchNode = true
            //MAINNET
            self.nodeArray = ["explorer.beldex.io:19091","mainnet.beldex.io:29095","publicnode1.rpcnode.stream:29095","publicnode2.rpcnode.stream:29095","publicnode3.rpcnode.stream:29095","publicnode4.rpcnode.stream:29095"]//["149.102.156.174:19095"]
            //TESTNET
            //                self.nodeArray = ["149.102.156.174:19095"]
            SaveUserDefaultsData.SaveLocalNodelist = []
            for i in 0 ..< self.nodeArray.count {
                self.forVerifyAllNodeURI(host_port: self.nodeArray[i])
            }
            self.randomNodeValue = self.nodeArray.randomElement()!
            SaveUserDefaultsData.SelectedNode = randomNodeValue
//            if self.navigationController != nil{
//                let count = self.navigationController!.viewControllers.count
//                if count > 1
//                {
//                    let VC = self.navigationController!.viewControllers[count-2] as! WalletSettingsNewVC
//                    VC.BackAPI = true
//                }
//            }
            self.tableView.reloadData()
        }else{
            nodeArray.removeAll()
            tableView.reloadData();
        }
    }
    
    @objc func switchNodePopUpOkeyAction(_ notification: Notification) {
        SaveUserDefaultsData.SwitchNode = true
        SaveUserDefaultsData.SelectedNode = selectedValue
        if self.navigationController != nil{
            let count = self.navigationController!.viewControllers.count
            if count > 1
            {
                let VC = self.navigationController!.viewControllers[count-2] as! WalletSettingsNewVC
                VC.backAPI = true
            }
        }
        tableView.reloadData()
    }
    
    @objc func addNodeButtonAction(_ sender: UIButton){
        
    }
    
}
class NodeListTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.cellBackgroundColorForNodeList
        view.layer.cornerRadius = 16
        return view
    }()
    lazy var circularView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_fullCircle", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    lazy var nodeNameTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.greenColor
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var nodeIPLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.cellIpLabelColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(circularView)
        backGroundView.addSubview(nodeNameTitleLabel)
        backGroundView.addSubview(nodeIPLabel)
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            circularView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 28),
            circularView.widthAnchor.constraint(equalToConstant: 10),
            circularView.heightAnchor.constraint(equalToConstant: 10),
            circularView.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor),
            nodeNameTitleLabel.leadingAnchor.constraint(equalTo: circularView.trailingAnchor, constant: 20),
            nodeNameTitleLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: -11),
            nodeNameTitleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 18),
            nodeIPLabel.leadingAnchor.constraint(equalTo: circularView.trailingAnchor, constant: 20),
            nodeIPLabel.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor, constant: 11),
            nodeIPLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -18),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
