// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import BChatMessagingKit

protocol MyDataSendingDelegateProtocol {
    func sendDataToMyWalletSendVC(myData: String)
}

class MyWalletAddressBookVC: BaseVC,UITextFieldDelegate {
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(MyWalletAddressXibCell.nib, forCellWithReuseIdentifier: MyWalletAddressXibCell.identifier)
            collectionView.register(MyWalletAddressXibCell2.nib, forCellWithReuseIdentifier: MyWalletAddressXibCell2.identifier)
        }
    }
    @IBOutlet weak var noContactdatalbl:UILabel!
    @IBOutlet weak var txtSearchBar:UITextField!
    var delegate: MyDataSendingDelegateProtocol? = nil
    var contacts = ContactUtilities.getAllContacts()
    var filterContactNameArray = [String]()
    var filterBeldexAddressArray = [String]()
    var allFilterData = [String: String]()
    var flagSendAddress = false
    fileprivate var isSearched : Bool = false
    fileprivate var searchfilterNamearray = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Address Book"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //depending upon direction of collection view
        self.collectionView?.setCollectionViewLayout(layout, animated: true)
        txtSearchBar.delegate = self
        txtSearchBar.returnKeyType = .done
        var contactNameArray = [String]()
        var beldexAddressArray = [String]()
        for publicKey in contacts {
            let isApprovedflag = Storage.shared.getContact(with: publicKey)!.isApproved
            if isApprovedflag == true {
                let blockedflag = Storage.shared.getContact(with: publicKey)!.isBlocked
                if blockedflag == false {
                    let contactName = Storage.shared.getContact(with: publicKey)?.displayName(for: .regular) ?? publicKey
                    contactNameArray.append(contactName)
                    let pukey = Storage.shared.getContact(with: publicKey)
                    if pukey!.beldexAddress != nil {
                        beldexAddressArray.append(pukey!.beldexAddress!)
                    }
                }
            }
            collectionView.reloadData()
        }
        
        let nameSeparator = contactNameArray.joined(separator: ",")
        let allcontactNameArray = nameSeparator.components(separatedBy: ",")
        let beldexnameSeparator = beldexAddressArray.joined(separator: ",")
        let allbeldexAddressArray = beldexnameSeparator.components(separatedBy: ",")
        filterContactNameArray = allcontactNameArray.filter({ $0 != ""})
        filterBeldexAddressArray = allbeldexAddressArray.filter({ $0 != ""})
        
        self.allFilterData = Dictionary(uniqueKeysWithValues: zip(filterContactNameArray, filterBeldexAddressArray))
        if filterContactNameArray.count == 0 {
            noContactdatalbl.isHidden = false
            collectionView.isHidden = true
        }else {
            noContactdatalbl.isHidden = true
            collectionView.isHidden = false
        }
    }
    // MARK: Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        var searchText  = textField.text! + string
        if string  == "" {
            searchText = (searchText as String).substring(to: searchText.index(before: searchText.endIndex))
        }
        if searchText == "" {
            isSearched = false
            collectionView.reloadData()
        }
        else{
            getSearchArrayContains(searchText)
        }
        return true
    }
    // Predicate to filter data
    func getSearchArrayContains(_ text : String) {
        searchfilterNamearray = self.allFilterData.filter({$0.key.lowercased().hasPrefix(text.lowercased())})
        isSearched = true
        collectionView.reloadData()
    }
    
}
extension MyWalletAddressBookVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearched == true{
            return searchfilterNamearray.count
        }else {
            return filterBeldexAddressArray.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if flagSendAddress == false {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyWalletAddressXibCell.identifier, for: indexPath) as! MyWalletAddressXibCell
            if isSearched == true{
                let intIndex = indexPath.item
                let index = searchfilterNamearray.index(searchfilterNamearray.startIndex, offsetBy: intIndex)
                cell.lblname.text = searchfilterNamearray.keys[index]
                cell.lblmyaddress.text = searchfilterNamearray.values[index]
            }else {
                cell.lblname.text = filterContactNameArray[indexPath.item]
                cell.lblmyaddress.text = filterBeldexAddressArray[indexPath.item]
            }
            cell.btncopy.tag = indexPath.row
            cell.btncopy.addTarget(self, action: #selector(self.copy_action(_:)), for: .touchUpInside)
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyWalletAddressXibCell2.identifier, for: indexPath) as! MyWalletAddressXibCell2
            if isSearched == true{
                let intIndex = indexPath.item
                let index = searchfilterNamearray.index(searchfilterNamearray.startIndex, offsetBy: intIndex)
                cell.lblname.text = searchfilterNamearray.keys[index]
                cell.lblmyaddress.text = searchfilterNamearray.values[index]
            }else {
                cell.lblname.text = filterContactNameArray[indexPath.item]
                cell.lblmyaddress.text = filterBeldexAddressArray[indexPath.item]
            }
            cell.btnshare.tag = indexPath.row
            cell.btnshare.addTarget(self, action: #selector(self.share_action(_:)), for: .touchUpInside)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 120)
    }
    @objc func copy_action(_ x: AnyObject) {
        let indexPath = IndexPath(item: x.tag!, section: 0);
        if collectionView.cellForItem(at: indexPath) is MyWalletAddressXibCell {
            var addresscopy = ""
            if isSearched == true {
                let intIndex = x.tag!
                let index = searchfilterNamearray.index(searchfilterNamearray.startIndex, offsetBy: intIndex)
                addresscopy = searchfilterNamearray.values[index]
            } else {
                addresscopy = filterBeldexAddressArray[indexPath.item]
            }
            UIPasteboard.general.string = "\(addresscopy)"
            self.showToastMsg(message: "Copied to clipboard", seconds: 1.0)
        }
    }
    @objc func share_action(_ x: AnyObject) {
        let indexPath = IndexPath(item: x.tag!, section: 0);
        if collectionView.cellForItem(at: indexPath) is MyWalletAddressXibCell2 {
            let addrescopy = filterBeldexAddressArray[indexPath.item]
            if self.delegate != nil && !addrescopy.isEmpty {
                let dataToBeSent = addrescopy
                self.delegate?.sendDataToMyWalletSendVC(myData: dataToBeSent)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
