// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit
import Alamofire
import BChatUIKit

class MyWalletNodeVC: BaseVC,UITextFieldDelegate {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(MyWalletNodeXibCell.nib, forCellWithReuseIdentifier: MyWalletNodeXibCell.identifier)
        }
    }
    @IBOutlet var NodePopView: UIView!
    var rightBarButtonItems: [UIBarButtonItem] = []
    var NodeArray = ["explorer.beldex.io:19091","mainnet.beldex.io:29095","publicnode1.rpcnode.stream:29095","publicnode2.rpcnode.stream:29095","publicnode3.rpcnode.stream:29095","publicnode4.rpcnode.stream:29095","publicnode5.rpcnode.stream:29095"]
    var randomNodeValue = ""
    var randomValueAfterAddNewNode = ""
    var selectedIndex : Int = 70
    var selectedValue = ""
    @IBOutlet var nodeAddressTxtFld: UITextField!
    @IBOutlet var nodePortNumTxtFld: UITextField!
    @IBOutlet var nodenameTxtFld: UITextField!
    @IBOutlet var nodePasswordTxtFld: UITextField!
    @IBOutlet var nodeUsernameTxtFld: UITextField!
    @IBOutlet var lbltestresult: UILabel!
    @IBOutlet var imgtestresult: UIImageView!
    @IBOutlet var testResultView: UIView!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var addbtn: UIButton!
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setUpGradientBackground()
        setUpNavBarStyle()
        self.title = "Nodes"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //depending upon direction of collection view
        self.collectionView?.setCollectionViewLayout(layout, animated: true)
        let settingsButton = UIBarButtonItem(image: UIImage(named: "ic_add_node")!, style: .plain, target: self, action: #selector(addnodeoption))
        rightBarButtonItems.append(settingsButton)
        let refreButton = UIBarButtonItem(image: UIImage(named: "ic_resync"), style: .plain, target: self, action: #selector(refreshoptn22))
        refreButton.accessibilityLabel = "Settings button"
        refreButton.isAccessibilityElement = true
        rightBarButtonItems.append(refreButton)
        navigationItem.rightBarButtonItems = rightBarButtonItems
        
        //Keyboard Done Option
        nodePortNumTxtFld.addDoneButtonKeybord()
        
        //Long Press Node
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressGR)
        
        self.nodeAddressTxtFld.delegate = self
        self.nodePortNumTxtFld.delegate = self
        self.nodeUsernameTxtFld.delegate = self
        self.nodePasswordTxtFld.delegate = self
        self.nodenameTxtFld.delegate = self
        self.nodePortNumTxtFld.delegate = self
        self.nodePortNumTxtFld.keyboardType = .numberPad
        
        randomNodeValue = SaveUserDefaultsData.FinalWallet_node
        randomValueAfterAddNewNode = NodeArray.randomElement()!
        self.NodePopView.isHidden = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.NodePopView.layer.cornerRadius = 6
        self.testResultView.layer.cornerRadius = 6
        
        let dismiss: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismiss)
        dismiss.cancelsTouchesInView = false
        
        if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
        }else{
            NodeArray.removeAll()
            collectionView.reloadData();
        }
        
        for i in 0 ..< NodeArray.count {
            self.forVerifyAllNodeURI(host_port: self.NodeArray[i])
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.nodePopViewInitial = self.NodePopView.frame.origin.y
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if self.NodePopView.frame.origin.y == nodePopViewInitial {
            self.NodePopView.frame.origin.y -= nodePopViewInitial
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.NodePopView.frame.origin.y != nodePopViewInitial {
            self.NodePopView.frame.origin.y = nodePopViewInitial
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == nodePortNumTxtFld){
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return (string == numberFiltered) && textLimit(existingText: textField.text,
                                                           newText: string,
                                                           limit: 5)
        }
        return true
    }
    func textLimit(existingText: String?,
                   newText: String,
                   limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        return isAtLimit
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.isUserInteractionEnabled = false
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SaveUserDefaultsData.SaveLocalNodelist != []{
            if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
                NodeArray = SaveUserDefaultsData.SaveLocalNodelist
                collectionView.reloadData()
            }
        }
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc
    func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .ended {
            return
        }
        let point = longPressGR.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if let indexPath = indexPath {
            self.collectionView.isHidden = true
            self.NodePopView.isHidden = false
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            self.nodeAddressTxtFld.text = NodeArray[indexPath.row]
            self.currentIndexForEditNode = indexPath.row
            
            if let range1 = NodeArray[indexPath.row].range(of: ":") {
                let port = NodeArray[indexPath.row][range1.upperBound...]
                self.nodePortNumTxtFld.text = String(port)
            }
            let name = NodeArray[indexPath.row].components(separatedBy: ":")
            self.nodeAddressTxtFld.text = name[0]
            self.nodenameTxtFld.text = name[0]
            
            let txtfldStr = nodeAddressTxtFld.text! + ":" + nodePortNumTxtFld.text!
            verifyNodeURI(host_port: txtfldStr)
            
        } else {
            print("Could not find index path")
        }
    }
    
    // MARK: Settings
    @objc func addnodeoption(_ sender: Any?) {
        self.collectionView.isHidden = true
        self.NodePopView.isHidden = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    // MARK: Refresh
    @objc func refreshoptn22(_ sender: Any?) {
        if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
            let refreshAlert = UIAlertController(title: "Wallet Node", message: "Are you sure you want to refresh Node", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [self] (action: UIAlertAction!) in
                SaveUserDefaultsData.SwitchNode = true
                self.NodeArray = ["explorer.beldex.io:19091","mainnet.beldex.io:29095","publicnode1.rpcnode.stream:29095","publicnode2.rpcnode.stream:29095","publicnode3.rpcnode.stream:29095","publicnode4.rpcnode.stream:29095","publicnode5.rpcnode.stream:29095"]
                SaveUserDefaultsData.SaveLocalNodelist = []
                for i in 0 ..< self.NodeArray.count {
                    self.forVerifyAllNodeURI(host_port: self.NodeArray[i])
                }
                self.randomNodeValue = self.NodeArray.randomElement()!
                SaveUserDefaultsData.SelectedNode = randomNodeValue
                if self.navigationController != nil{
                    let count = self.navigationController!.viewControllers.count
                    if count > 1
                    {
                        let VC = self.navigationController!.viewControllers[count-2] as! MyWalletSettingsVC
                        VC.BackAPI = true
                    }
                }
                self.collectionView.reloadData()
            }))
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Handle Cancel Logic here")
                refreshAlert .dismiss(animated: true, completion: nil)
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        }else{
            NodeArray.removeAll()
            collectionView.reloadData();
        }
    }
    func setUPButtonUI(button : UIButton,borderRed : Float, borderGreen : Float, borderBlue : Float) {
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor(red: CGFloat(borderRed), green: CGFloat(borderGreen), blue: CGFloat(borderBlue), alpha: 1).cgColor
    }
    //MARK: button actions for Add Node View
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.NodePopView.isHidden = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.collectionView.isHidden = false
        nodeAddressTxtFld.text = ""
        nodePortNumTxtFld.text = ""
        nodeUsernameTxtFld.text = ""
        nodePasswordTxtFld.text = ""
        nodenameTxtFld.text = ""
        testResultView.backgroundColor = Colors.accent
        lbltestresult.textColor = Colors.bchat_lbl_name
        lbltestresult.text = "Test result:"
        imgtestresult.isHidden = true
    }
    @IBAction func addBtnAction(_ sender: Any) {
        if (nodeAddressTxtFld.text == "") {
            let alert = UIAlertController(title: "", message: "Please Enter Node Address", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (nodePortNumTxtFld.text == "") {
            let alert = UIAlertController(title: "", message: "Please Enter Node Port", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if self.testResultFlag == true {
                let txtfldStr = nodeAddressTxtFld.text! + ":" + nodePortNumTxtFld.text!
                if NodeArray.contains(txtfldStr){
                    let alert = UIAlertController(title: "", message: "This Node is already exists", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else{
                    verifyNodeURICheking(host_port: txtfldStr)
                }
            }else {
                self.showToastMsg(message: "Make sure you test the node before adding it", seconds: 1.0)
            }
        }
    }
    
    // Node Validation func developed
    @IBAction func TestBtnAction(_ sender: Any) {
        if (nodeAddressTxtFld.text == "") {
            let alert = UIAlertController(title: "", message: "Please Enter Node Address", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (nodePortNumTxtFld.text == "") {
            let alert = UIAlertController(title: "", message: "Please Enter Node Port", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let txtfldStr = nodeAddressTxtFld.text! + ":" + nodePortNumTxtFld.text!
            verifyNodeURI(host_port: txtfldStr)
        }
    }
    
    func verifyNodeURI(host_port:String) {
        let url = "http://" + host_port + "/json_rpc"
        let param = ["jsonrpc": "2.0", "id": "0", "method": "getlastblockheader"]
        let dataTask = Session.default.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
        dataTask.responseJSON { (response) in
            if let json = response.value as? [String: Any],
               let result = json["result"] as? [String: Any],
               let header = result["block_header"] as? [String: Any],
               let timestamp = header["timestamp"] as? Int,
               timestamp > 0
            {
                self.testResultView.backgroundColor = Colors.accent
                self.lbltestresult.text = "Test result: Success"
                self.imgtestresult.isHidden = false
                self.imgtestresult.image = UIImage(named: "ic_NodeTest")
                self.testResultFlag = true
            } else {
                self.testResultView.backgroundColor = .red
                self.imgtestresult.isHidden = false
                self.lbltestresult.text = "Test result: CONNECTION ERROR"
                self.imgtestresult.image = UIImage(named: "ic_NodeTestAlert")
                self.testResultFlag = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            dataTask.cancel()
        }
    }
    
    func verifyNodeURICheking(host_port:String) {
        let url = "http://" + host_port + "/json_rpc"
        let param = ["jsonrpc": "2.0", "id": "0", "method": "get_info"]
        let dataTask = Session.default.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
        dataTask.responseJSON { (response) in
            let json = response.value as? [String: AnyObject]
            let result = json?["result"] as? [String: AnyObject]
            let nettype = result?["nettype"] as! String
            if nettype == "testnet" {
                let alert = UIAlertController(title: "", message: "This Node is TestNet", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                
                if self.currentIndexForEditNode != -1 {
                    self.NodeArray[self.currentIndexForEditNode] = host_port
                } else {
                    self.NodeArray.append(host_port)
                }
                for i in 0 ..< self.NodeArray.count {
                    self.forVerifyAllNodeURI(host_port: self.NodeArray[i])
                }
                self.NodePopView.isHidden = true
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
                self.collectionView.isHidden = false
                SaveUserDefaultsData.SaveLocalNodelist = self.NodeArray
                SaveUserDefaultsData.SelectedNode = self.NodeArray.last!
                self.nodeAddressTxtFld.text = ""
                self.nodePortNumTxtFld.text = ""
                self.nodeUsernameTxtFld.text = ""
                self.nodePasswordTxtFld.text = ""
                self.nodenameTxtFld.text = ""
                self.lbltestresult.text = ""
                self.imgtestresult.isHidden = true
                self.collectionView.reloadData()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            dataTask.cancel()
        }
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
            self.collectionView.reloadData()
        }
    }
    
}
extension MyWalletNodeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NodeArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyWalletNodeXibCell.identifier, for: indexPath) as! MyWalletNodeXibCell
        if checkedData.keys.contains(NodeArray[indexPath.row]) {
            let dictionaryIndex = checkedData.index(forKey: NodeArray[indexPath.row])
            let status = checkedData.values[dictionaryIndex!]
            if status == "OK" {
                cell.viewcolour.backgroundColor = .green
            } else {
                cell.viewcolour.backgroundColor = .red
            }
        }
        
        if checkedDataForTimeInterval.keys.contains(NodeArray[indexPath.row]) {
            let dictionaryIndex = checkedDataForTimeInterval.index(forKey: NodeArray[indexPath.row])
            let notError = checkedDataForTimeInterval.values[dictionaryIndex!]
            if notError == "CONNECTION ERROR" {
                cell.lblDetails.textColor = .red
                cell.lblDetails.text = checkedDataForTimeInterval.values[dictionaryIndex!]
            } else {
                cell.lblDetails.textColor = Colors.bchat_lbl_name
                cell.lblDetails.text = "Last Block: " +  checkedDataForTimeInterval.values[dictionaryIndex!]
            }
        }
        
        cell.lblmyaddress.text = NodeArray[indexPath.row]
        cell.mainView.layer.backgroundColor = Colors.bchat_view_bg_clr.cgColor
        cell.isUserInteractionEnabled = true
        if(!SaveUserDefaultsData.SelectedNode.isEmpty) {
            let selectedNodeData = SaveUserDefaultsData.SelectedNode
            if(NodeArray[indexPath.row] == selectedNodeData) {
                selectedIndex = indexPath.row
                cell.mainView.layer.backgroundColor = UIColor(red: 35.0/255, green: 130.0/255, blue: 244.0/255, alpha: 1.0).cgColor
                cell.isUserInteractionEnabled = false
            }
        } else if (NodeArray.count == 7) {
            if(NodeArray[indexPath.row] == randomNodeValue) {
                cell.mainView.layer.backgroundColor = UIColor(red: 35.0/255, green: 130.0/255, blue: 244.0/255, alpha: 1.0).cgColor
                cell.isUserInteractionEnabled = false
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let alertView = UIAlertController(title: "", message: "Are you sure you want to switch to another node?", preferredStyle: UIAlertController.Style.alert)
        alertView.addAction(UIAlertAction(title: "YES", style: .default, handler: { [self] (action: UIAlertAction!) in
            SaveUserDefaultsData.SwitchNode = true
            selectedValue = self.NodeArray[indexPath.row]
            SaveUserDefaultsData.SelectedNode = selectedValue
            if self.navigationController != nil{
                let count = self.navigationController!.viewControllers.count
                if count > 1
                {
                    let VC = self.navigationController!.viewControllers[count-2] as! MyWalletSettingsVC
                    VC.BackAPI = true
                }
            }
            collectionView.reloadData()
        }))
        alertView.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(alertView, animated: true, completion: nil)
    }
}

