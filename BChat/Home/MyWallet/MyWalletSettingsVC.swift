// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit

class MyWalletSettingsVC: BaseVC,UITextFieldDelegate {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(MyWalletSettingsXibCell2.nib, forCellWithReuseIdentifier: MyWalletSettingsXibCell2.identifier)
            collectionView.register(MyWalletSettingsXibCell3.nib, forCellWithReuseIdentifier: MyWalletSettingsXibCell3.identifier)
            collectionView.register(MyWalletSettingsXibCell4.nib, forCellWithReuseIdentifier: MyWalletSettingsXibCell4.identifier)
        }
    }
    @IBOutlet weak var popview: UIView!
    @IBOutlet weak var btnclose: UIButton!
    @IBOutlet weak var lbltitlename: UILabel!
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.register(UINib(nibName: "PopXibCell", bundle: nil), forCellReuseIdentifier: "PopXibCell")
        }
    }
    var displayBalanceArray = ["Beldex Full Balance","Beldex Available Balance","Beldex Hidden"]
    var decimalArray = ["4 - Decimal","3 - Decimal","2 - Decimal","0 - Decimal"]
    var currencyNameArray = ["aud","brl","cad","chf","cny","czk","eur","dkk","gbp","hkd","huf","idr","ils","inr","jpy","krw","mxn","myr","nok","nzd","php","pln","rub","sek","sgd","thb","usd","vef","zar"]
    var feePriorityArray = ["Flash","Slow"]
    var flagString = ""
    var displayBalanceString = ""
    var decimalString = ""
    var currencyNameString = ""
    var feePriorityString = ""
    var nodeValue = ""
    var BackAPI = false
    @IBOutlet weak var txtSearchBar: UITextField!
    @IBOutlet weak var txtSearchBarHeightConstraint: NSLayoutConstraint!
    fileprivate var isSearched : Bool = false
    fileprivate var searchfilterCurrencyNamearray = [String]()
    
    
    var timerForShowScrollIndicator: Timer?
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Wallet Settings"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //depending upon direction of collection view
        self.collectionView?.setCollectionViewLayout(layout, animated: true)
        
        popview.layer.cornerRadius = 6
        popview.isHidden = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.collectionView.isUserInteractionEnabled = true
        txtSearchBar.delegate = self
        txtSearchBarHeightConstraint.constant = 0
        txtSearchBar.clearButtonMode = .whileEditing
        let logoName = isLightMode ? "ic_WalletClose" : "ic_WalletCloseWhite"
        btnclose.setImage(UIImage(named: logoName), for: .normal)
                
        if BackAPI == true{
            nodeValue = SaveUserDefaultsData.SelectedNode
            collectionView.reloadData()
        }else {
            if !SaveUserDefaultsData.SelectedNode.isEmpty {
                nodeValue = SaveUserDefaultsData.SelectedNode
            }
            if !SaveUserDefaultsData.FinalWallet_node.isEmpty {
                nodeValue = SaveUserDefaultsData.FinalWallet_node
            }
            collectionView.reloadData()
        }
    }
    
    // UITextFieldDelegate method to respond to the clear button action
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // This method is called when the clear button is pressed
        // You can perform any additional actions you need here
        self.isSearched = false
        self.txtSearchBar.text = ""
        self.tableView.reloadData()
        self.txtSearchBar.resignFirstResponder()
        self.collectionView.reloadData()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if BackAPI == true{
            nodeValue = SaveUserDefaultsData.SelectedNode
        }else {
            if !SaveUserDefaultsData.SelectedNode.isEmpty {
                nodeValue = SaveUserDefaultsData.SelectedNode
            }
            if !SaveUserDefaultsData.FinalWallet_node.isEmpty {
                nodeValue = SaveUserDefaultsData.FinalWallet_node
            }
        }
        collectionView.reloadData()
    }
    
    //Keyboard return action events
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  //if desired
        performAction()
        return true
    }
    func performAction() {
        self.isSearched = true
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
    
    // Show indicators for currency
    @objc func showScrollIndicatorsInContacts() {
        UIView.animate(withDuration: 0.001) {
            self.tableView.flashScrollIndicators()
        }
    }

    func startTimerForShowScrollIndicator() {
        self.timerForShowScrollIndicator = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.showScrollIndicatorsInContacts), userInfo: nil, repeats: true)
    }

    func stopTimerForShowScrollIndicator() {
        self.timerForShowScrollIndicator?.invalidate()
        self.timerForShowScrollIndicator = nil
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.startTimerForShowScrollIndicator()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.stopTimerForShowScrollIndicator()
    }
    
    // MARK: - Navigation
    @IBAction func popviewCloseAction(_ sender: UIButton) {
        self.isSearched = false
        self.txtSearchBar.text = ""
        self.tableView.reloadData()
        self.txtSearchBar.resignFirstResponder()
        self.collectionView.reloadData()
        popview.isHidden = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.collectionView.isUserInteractionEnabled = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        var searchText  = textField.text! + string
        if string  == "" {
            searchText = (searchText as String).substring(to: searchText.index(before: searchText.endIndex))
        }
        if searchText == "" {
            isSearched = false
            tableView.reloadData()
        }
        else{
            getSearchArrayContains(searchText)
        }
        return true
    }
    // Predicate to filter data
    func getSearchArrayContains(_ text : String) {
        searchfilterCurrencyNamearray = self.currencyNameArray.filter( { $0.hasPrefix(text) } )
        isSearched = true
        tableView.reloadData()
    }
    
}
extension MyWalletSettingsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1{
            return 1
        }else {
            return 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyWalletSettingsXibCell2.identifier, for: indexPath) as! MyWalletSettingsXibCell2
            if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
                cell.lblnodename.text = nodeValue
            }else{
                cell.lblnodename.text = "Waiting for network.."
            }
            return cell
        }else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyWalletSettingsXibCell3.identifier, for: indexPath) as! MyWalletSettingsXibCell3
            
            cell.btnDisplayNameAS.tag = indexPath.row
            cell.btnDisplayNameAS.addTarget(self, action: #selector(self.displayNameASButtonTapped(_:)), for: .touchUpInside)
            
            if !SaveUserDefaultsData.SelectedBalance.isEmpty {
                cell.btnDisplayNameAS.setTitle(SaveUserDefaultsData.SelectedBalance, for: .normal)
            }else if displayBalanceString == "" {
                cell.btnDisplayNameAS.setTitle("Beldex Available Balance", for: .normal)
            }else {
                cell.btnDisplayNameAS.setTitle("\(displayBalanceString)", for: .normal)
            }
            
            cell.btnDecimals.tag = indexPath.row
            cell.btnDecimals.addTarget(self, action: #selector(self.decimalsButtonTapped(_:)), for: .touchUpInside)
            
            if !SaveUserDefaultsData.SelectedDecimal.isEmpty {
                cell.btnDecimals.setTitle(SaveUserDefaultsData.SelectedDecimal, for: .normal)
            }else if decimalString == "" {
                cell.btnDecimals.setTitle("4 - Decimal", for: .normal)
            }else {
                cell.btnDecimals.setTitle("\(decimalString)", for: .normal)
            }
            
            cell.btnCurrency.tag = indexPath.row
            cell.btnCurrency.addTarget(self, action: #selector(self.currencyButtonTapped(_:)), for: .touchUpInside)
            
            if !SaveUserDefaultsData.SelectedCurrency.isEmpty {
                cell.btnCurrency.setTitle(SaveUserDefaultsData.SelectedCurrency.uppercased(), for: .normal)
            }else if currencyNameString == "" {
                cell.btnCurrency.setTitle("USD", for: .normal)
            }else {
                cell.btnCurrency.setTitle("\(currencyNameString.uppercased())", for: .normal)
            }
            
            cell.btnFeepriority.tag = indexPath.row
            cell.btnFeepriority.addTarget(self, action: #selector(self.feepriorityButtonTapped(_:)), for: .touchUpInside)
            if !SaveUserDefaultsData.FeePriority.isEmpty {
                let val = SaveUserDefaultsData.FeePriority
                cell.btnFeepriority.setTitle(val, for: .normal)
            } else {
                cell.btnFeepriority.setTitle("Flash", for: .normal)
            }
            
            cell.btnSaveRecipientAddress.tag = indexPath.row
            cell.btnSaveRecipientAddress.addTarget(self, action: #selector(self.saveRecipientAddressButtonTapped(_:)), for: .valueChanged)
            
            if SaveUserDefaultsData.SaveReceipeinetSwitch == false {
                cell.btnSaveRecipientAddress.isOn = false
            }else {
                cell.btnSaveRecipientAddress.isOn = true
            }
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyWalletSettingsXibCell4.identifier, for: indexPath) as! MyWalletSettingsXibCell4
            
            cell.btnAddress.tag = indexPath.row
            cell.btnAddress.addTarget(self, action: #selector(self.btnAddress_action(_:)), for: .touchUpInside)
            
            cell.btnchangePin.tag = indexPath.row
            cell.btnchangePin.addTarget(self, action: #selector(self.btnchangePin_action(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.frame.size.width, height: 105)
        }else if indexPath.section == 1 {
            return CGSize(width: collectionView.frame.size.width, height: 320)
        }else {
            return CGSize(width: collectionView.frame.size.width, height: 150)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletNodeVC") as! MyWalletNodeVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func btnAddress_action(_ x: AnyObject) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletAddressBookVC") as! MyWalletAddressBookVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnchangePin_action(_ x: AnyObject) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletPasscodeVC") as! MyWalletPasscodeVC
        vc.isChangePin = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // displayNameAS ButtonTapped
    @objc func displayNameASButtonTapped(_ x: AnyObject) {
        txtSearchBarHeightConstraint.constant = 0
        lbltitlename.text = "Display Balance As"
        popview.isHidden = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.collectionView.isUserInteractionEnabled = false
        flagString = "11"
        tableView.reloadData()
    }
    // decimals ButtonTapped
    @objc func decimalsButtonTapped(_ x: AnyObject) {
        txtSearchBarHeightConstraint.constant = 0
        lbltitlename.text = "Decimals"
        popview.isHidden = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.collectionView.isUserInteractionEnabled = false
        flagString = "22"
        tableView.reloadData()
    }
   // currency ButtonTapped
    @objc func currencyButtonTapped(_ x: AnyObject) {
        txtSearchBarHeightConstraint.constant = 30
        lbltitlename.text = "Currency"
        popview.isHidden = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.collectionView.isUserInteractionEnabled = false
        flagString = "33"
        tableView.reloadData()
        self.tableView.flashScrollIndicators()
    }
  // feepriority ButtonTapped
    @objc func feepriorityButtonTapped(_ x: AnyObject) {
        txtSearchBarHeightConstraint.constant = 0
        lbltitlename.text = "Fee Priority"
        popview.isHidden = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.collectionView.isUserInteractionEnabled = false
        flagString = "44"
        tableView.reloadData()
    }
   // saveRecipientAddress ButtonTapped
    @objc func saveRecipientAddressButtonTapped(_ x: UISwitch) {
        if (x.isOn){
            SaveUserDefaultsData.SaveReceipeinetSwitch = true
        }else{
            SaveUserDefaultsData.SaveReceipeinetSwitch = false
        }
    }
    
}
extension MyWalletSettingsVC:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if flagString == "11" {
            return displayBalanceArray.count
        }else if flagString == "22"{
            return decimalArray.count
        }else if flagString == "33" {
            if isSearched == true{
                return searchfilterCurrencyNamearray.count
            }else {
                return currencyNameArray.count
            }
        }else {
            return feePriorityArray.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopXibCell", for: indexPath) as! PopXibCell
        cell.selectionStyle = .none
        
        if flagString == "11" {
            cell.lblname.text = displayBalanceArray[indexPath.row]
        }else if flagString == "22"{
            cell.lblname.text = decimalArray[indexPath.row]
        }else if flagString == "33" {
            if isSearched == true{
                cell.lblname.text = searchfilterCurrencyNamearray[indexPath.row].uppercased()
            }else{
                cell.lblname.text = currencyNameArray[indexPath.row].uppercased()
            }
        }else {
            cell.lblname.text = feePriorityArray[indexPath.row]
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if flagString == "11" {
            displayBalanceString = displayBalanceArray[indexPath.row]
            popview.isHidden = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.collectionView.isUserInteractionEnabled = true
            SaveUserDefaultsData.SelectedBalance = displayBalanceString
            if self.navigationController != nil{
                let count = self.navigationController!.viewControllers.count
                if count > 1
                {
                    let VC = self.navigationController!.viewControllers[count-2] as! MyWalletHomeVC
                    VC.BackAPI = true
                }
            }
            collectionView.reloadData()
        }else if flagString == "22"{
            decimalString = decimalArray[indexPath.row]
            popview.isHidden = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.collectionView.isUserInteractionEnabled = true
            SaveUserDefaultsData.SelectedDecimal = decimalString
            if self.navigationController != nil{
                let count = self.navigationController!.viewControllers.count
                if count > 1
                {
                    let VC = self.navigationController!.viewControllers[count-2] as! MyWalletHomeVC
                    VC.backAPISelectedDecimal = true
                }
            }
            collectionView.reloadData()
        }else if flagString == "33" {
            if isSearched == true{
                currencyNameString = searchfilterCurrencyNamearray[indexPath.row]
            }else {
                currencyNameString = currencyNameArray[indexPath.row]
            }
            popview.isHidden = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.collectionView.isUserInteractionEnabled = true
            SaveUserDefaultsData.SelectedCurrency = currencyNameString
            if self.navigationController != nil{
                let count = self.navigationController!.viewControllers.count
                if count > 1
                {
                    let VC = self.navigationController!.viewControllers[count-2] as! MyWalletHomeVC
                    VC.backAPISelectedCurrency = true
                }
            }
            self.txtSearchBar.resignFirstResponder()
            self.isSearched = false
            self.txtSearchBar.text = ""
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }else {
            feePriorityString = feePriorityArray[indexPath.row]
            SaveUserDefaultsData.FeePriority = feePriorityString
            collectionView.reloadData()
            popview.isHidden = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.collectionView.isUserInteractionEnabled = true
        }
    }
}
