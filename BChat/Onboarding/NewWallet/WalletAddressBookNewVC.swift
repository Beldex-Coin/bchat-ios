// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import BChatMessagingKit

protocol MyDataSendingDelegateProtocol {
    func sendBeldexAddressToMyWalletSendVC(myData: String)
}


class WalletAddressBookNewVC: BaseVC, UITextFieldDelegate {
    
    private lazy var searchTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("SEARCH_CONTACT_NEW", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: Colors.placeholderColor])
        result.font = Fonts.OpenSans(ofSize: 14)
        result.layer.borderColor = Colors.borderColor.cgColor
        result.backgroundColor = Colors.searchViewBackgroundColor
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 24
        result.layer.borderWidth = 1
        
        // Add left padding
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingViewLeft
        result.leftViewMode = .always
        
        // Add right padding
        let paddingViewRight = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 12))
        result.rightView = paddingViewRight
        result.rightViewMode = .always
        
        // Create an UIImageView and set its image for search icon
        let searchIconImageView = UIImageView(image: UIImage(named: "ic_Search_Vector_New"))
        searchIconImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 12)
        searchIconImageView.contentMode = .scaleAspectFit
        paddingViewRight.addSubview(searchIconImageView)
        
        // Create an UIImageView for close icon initially hidden
        let closeIconImageView = UIImageView(image: UIImage(named: "ic_closeNew"))
        closeIconImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 12)
        closeIconImageView.contentMode = .scaleAspectFit
        closeIconImageView.tag = 1 // Set a tag to distinguish it from the search icon
        closeIconImageView.isHidden = true
        paddingViewRight.addSubview(closeIconImageView)
        
        // Add tap gesture recognizer to closeIconImageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeIconTapped))
        closeIconImageView.isUserInteractionEnabled = true
        closeIconImageView.addGestureRecognizer(tapGestureRecognizer)
        result.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return result
    }()
    
    private lazy var backgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.viewBackgroundColorNew
        stackView.layer.cornerRadius = 20
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    
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
    
    private lazy var noAddressTitleLabel: UILabel = {
        let result = UILabel()
        result.text = "No Addresses!"
        result.textColor = Colors.placeholderColor
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var noSubAddressTitleLabel: UILabel = {
        let result = UILabel()
        result.text = "Save address to show!"
        result.textColor = Colors.addressBookSaveAddressLabelColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var noContactsYetLogoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_no_transactions_light" : "ic_no_transactions"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    private lazy var noContactsTitleLabel: UILabel = {
        let result = PaddingLabel()
        result.text = "No Contacts"
        result.textColor = Colors.addressBookNoContactLabelColor
        result.backgroundColor = Colors.searchViewBackgroundColor
        result.font = Fonts.OpenSans(ofSize: 15)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = result.frame.size.height / 2
        result.clipsToBounds = true
        result.textAlignment = .left
        result.paddingLeft = 25
        return result
    }()
    
    var contacts = ContactUtilities.getAllContacts()
    var filterContactNameArray = [String]()
    var filterBeldexAddressArray = [String]()
    var allFilterData = [String: String]()
    var flagSendAddress = false
    internal var isSearched : Bool = false
    internal var searchfilterNameArray = [String: String]()
    var isGoingToSendScreen = false
    var delegate: MyDataSendingDelegateProtocol? = nil
    
    // For Add Address Don't Remove
//    var savedDict = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.setUpScreenBackgroundColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Address Book"
        
        // don't delete the below lines.
//        let rightBarItemImage = isLightMode ? "add_address_light" : "add_address_dark"
//        let rightBarItem = UIBarButtonItem(image: UIImage(named: rightBarItemImage)!, style: .plain, target: self, action: #selector(addAddressBookAction))
//        let rightBarButtonItems = [rightBarItem]
//        navigationItem.rightBarButtonItems = rightBarButtonItems
        
        view.addSubview(searchTextField)
        view.addSubview(backgroundView)
        backgroundView.addSubview(tableView)
        backgroundView.addSubview(noAddressTitleLabel)
        backgroundView.addSubview(noSubAddressTitleLabel)
        backgroundView.addSubview(noContactsYetLogoImage)
        view.addSubview(noContactsTitleLabel)
        noContactsTitleLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 19),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            searchTextField.heightAnchor.constraint(equalToConstant: 48),
            backgroundView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 17),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -0),
            tableView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -0),
        ])
        NSLayoutConstraint.activate([
            noContactsTitleLabel.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            noContactsTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            noContactsTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            noContactsTitleLabel.heightAnchor.constraint(equalToConstant: 48),
            noContactsYetLogoImage.heightAnchor.constraint(equalToConstant: 141),
            noContactsYetLogoImage.widthAnchor.constraint(equalToConstant: 141),
            noContactsYetLogoImage.centerXAnchor.constraint(equalTo: noAddressTitleLabel.centerXAnchor),
            noContactsYetLogoImage.bottomAnchor.constraint(equalTo: noAddressTitleLabel.topAnchor, constant: -16),
            noAddressTitleLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            noAddressTitleLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            noSubAddressTitleLabel.topAnchor.constraint(equalTo: noAddressTitleLabel.bottomAnchor, constant: 6),
            noSubAddressTitleLabel.centerXAnchor.constraint(equalTo: noAddressTitleLabel.centerXAnchor),
        ])
        
        var contactNameArray = [String]()
        var beldexAddressArray = [String]()
        for publicKey in contacts {
            let isApprovedflag = Storage.shared.getContact(with: publicKey)!.isApproved
            if isApprovedflag == true {
                let blockedflag = Storage.shared.getContact(with: publicKey)!.isBlocked
                if blockedflag == false {
                    if let contact = Storage.shared.getContact(with: publicKey) {
                        if contact.beldexAddress != nil {
                            beldexAddressArray.append(contact.beldexAddress!)
                            let userName = Storage.shared.getContact(with: publicKey)?.name
                            contactNameArray.append(userName!)
                        }
                    }
                }
            }
            tableView.reloadData()
        }
        
        // For Add Address Don't Remove
//        savedDict = UserDefaults.standard.object([String: String].self, with: "savedDict") ?? [:]
//
//        let kvp = Array(savedDict).sorted { $0.key < $1.key }
//        let (keys, values) = unzip(kvp)
//        contactNameArray.append(contentsOf: keys)
//        beldexAddressArray.append(contentsOf: values)

        
        let nameSeparator = contactNameArray.joined(separator: ",")
        let allcontactNameArray = nameSeparator.components(separatedBy: ",")
        let beldexnameSeparator = beldexAddressArray.joined(separator: ",")
        let allbeldexAddressArray = beldexnameSeparator.components(separatedBy: ",")
        filterContactNameArray = allcontactNameArray.filter({ $0 != ""})
        filterBeldexAddressArray = allbeldexAddressArray.filter({ $0 != ""})
        
        self.allFilterData = Dictionary(zip(filterContactNameArray, filterBeldexAddressArray), uniquingKeysWith: { (first, _) in first })
        if filterContactNameArray.count == 0 {
            tableView.isHidden = true
            noContactsYetLogoImage.isHidden = false
            noAddressTitleLabel.isHidden = false
            noSubAddressTitleLabel.isHidden = false
        } else {
            tableView.isHidden = false
            noContactsYetLogoImage.isHidden = true
            noAddressTitleLabel.isHidden = true
            noSubAddressTitleLabel.isHidden = true
        }
    }
    
    @objc func closeIconTapped() {
        searchTextField.text = ""
        guard let searchText = searchTextField.text else {
            return
        }
        if searchText.isEmpty {
            isSearched = true
            tableView.reloadData() // Reload the tableView with original data
            noContactsTitleLabel.isHidden = true
            getSearchArrayContains(searchText)
        } else {
            getSearchArrayContains(searchText) // Update filtered data based on search text
        }
        tableView.reloadData()
        // Get the right view of the search text field
        if let rightView = searchTextField.rightView {
            // Iterate through subviews of the right view to find the close icon image view
            for subview in rightView.subviews {
                if let closeIconImageView = subview as? UIImageView, closeIconImageView.tag == 1 {
                    // Hide the close icon image view
                    closeIconImageView.isHidden = true
                }
            }
        }
        // Get the right view of the search text field
        if let rightView = searchTextField.rightView {
            // Iterate through subviews of the right view to find the search icon image view
            for subview in rightView.subviews {
                if let searchIconImageView = subview as? UIImageView, searchIconImageView.tag != 1 {
                    // Show the search icon image view
                    searchIconImageView.isHidden = false
                }
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Show/hide search and close icons based on text
        if let rightView = textField.rightView {
            if let searchIconImageView = rightView.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                searchIconImageView.isHidden = !textField.text!.isEmpty
                guard let searchText = textField.text else {
                    return
                }
                if searchText.isEmpty {
                    isSearched = true
                    tableView.reloadData() // Reload the tableView with original data
                    noContactsTitleLabel.isHidden = true
                    getSearchArrayContains(searchText)
                } else {
                    getSearchArrayContains(searchText) // Update filtered data based on search text
                }
            }
            if let closeIconImageView = rightView.subviews.first(where: { $0 is UIImageView && $0.tag == 1 }) as? UIImageView {
                closeIconImageView.isHidden = textField.text!.isEmpty
                guard let searchText = textField.text else {
                    return
                }
                if searchText.isEmpty {
                    isSearched = true
                    tableView.reloadData() // Reload the tableView with original data
                    noContactsTitleLabel.isHidden = true
                    getSearchArrayContains(searchText)
                } else {
                    getSearchArrayContains(searchText) // Update filtered data based on search text
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noContactsTitleLabel.layer.cornerRadius = noContactsTitleLabel.frame.height/2
    }
    
    // MARK: - Add address book
    
    @objc func addAddressBookAction () {
        let addAddressViewController = AddAddressBookViewController()
        navigationController?.pushViewController(addAddressViewController, animated: true)
    }
    
    // MARK: - UITextField delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // This method will be called whenever the text field's text changes
        // Get the current text from the text field
        guard let searchText = textField.text else {
            return
        }
        if searchText.isEmpty {
            textField.clearButtonMode = .never
            isSearched = true
            tableView.reloadData() // Reload the tableView with original data
            noContactsTitleLabel.isHidden = true
            getSearchArrayContains(searchText)
        } else {
            textField.clearButtonMode = .whileEditing
            getSearchArrayContains(searchText) // Update filtered data based on search text
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var searchText = (textField.text ?? "") + string
        if string == "" {
            searchText = String(searchText.prefix(searchText.count - 1))
        }
        if searchText.isEmpty {
            textField.clearButtonMode = .never
            isSearched = true
            tableView.reloadData() // Reload the tableView with original data
            noContactsTitleLabel.isHidden = true
            getSearchArrayContains(searchText)
        } else {
            textField.clearButtonMode = .whileEditing
            getSearchArrayContains(searchText) // Update filtered data based on search text
        }
        return true
    }
    
    // UITextFieldDelegate method to respond to the clear button action
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // This method is called when the clear button is pressed
        // You can perform any additional actions you need here
        self.isSearched = false
        self.searchTextField.text = ""
        self.searchTextField.resignFirstResponder()
        self.tableView.reloadData()
        return true
    }
    
    // Predicate to filter data
    func getSearchArrayContains(_ text: String) {
        searchfilterNameArray = self.allFilterData.filter({ $0.key.lowercased().hasPrefix(text.lowercased()) })
        isSearched = true
        tableView.reloadData() // Reload tableView with filtered data
        if searchfilterNameArray.isEmpty {
            // Show appropriate UI elements based on search results
            noContactsTitleLabel.isHidden = false
            tableView.isHidden = true
            noContactsYetLogoImage.isHidden = false
            noAddressTitleLabel.isHidden = false
            noSubAddressTitleLabel.isHidden = false
        } else {
            // Hide no results UI elements if there are search results
            noContactsTitleLabel.isHidden = true
            tableView.isHidden = false
            noContactsYetLogoImage.isHidden = true
            noAddressTitleLabel.isHidden = true
            noSubAddressTitleLabel.isHidden = true
        }
    }
    
    
    // For Add Address Don't Remove
//    func unzip<K, V>(_ array: [(key: K, value: V)]) -> ([K], [V]) {
//        var keys = [K]()
//        var values = [V]()
//
//        keys.reserveCapacity(array.count)
//        values.reserveCapacity(array.count)
//
//        array.forEach { key, value in
//            keys.append(key)
//            values.append(value)
//        }
//
//        return (keys, values)
//    }
    
    /// Copy Address and Send Address
    @objc func copyAndSendActionTapped(_ x: AnyObject) {
        if isGoingToSendScreen {
            //Send Address
            let indexPath = IndexPath(item: x.tag!, section: 0);
            if tableView.cellForRow(at: indexPath) is AddressBookTableCell {
                var addressshare = ""
                if isSearched == true {
                    let intIndex = x.tag!
                    let index = searchfilterNameArray.index(searchfilterNameArray.startIndex, offsetBy: intIndex)
                    addressshare = searchfilterNameArray.values[index]
                } else {
                    addressshare = filterBeldexAddressArray[indexPath.item]
                }
                self.delegate?.sendBeldexAddressToMyWalletSendVC(myData: addressshare)
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            //Copy the Address
            let indexPath = IndexPath(item: x.tag!, section: 0)
            if tableView.cellForRow(at: indexPath) is AddressBookTableCell {
                var addresscopy = ""
                if isSearched == true {
                    let intIndex = x.tag!
                    let index = searchfilterNameArray.index(searchfilterNameArray.startIndex, offsetBy: intIndex)
                    addresscopy = searchfilterNameArray.values[index]
                } else {
                    addresscopy = filterBeldexAddressArray[indexPath.item]
                }
                UIPasteboard.general.string = "\(addresscopy)"
                self.showToastMsg(message: "Copied to clipboard", seconds: 1.0)
            }
        }
    }
    
}
class AddressBookTableCell: UITableViewCell {
    
    // MARK: - Properties
    
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        return view
    }()
    lazy var copyAndSendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.backgroundViewColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.setImage(UIImage(named: "ic_copy_white2"), for: .normal)
        return button
    }()
    lazy var namebackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.backgroundViewColor
        view.layer.cornerRadius = 9
        return view
    }()
    lazy var addressIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.idLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    lazy var nameLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.addressBookNoContactLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(copyAndSendButton)
        backGroundView.addSubview(namebackgroundView)
        namebackgroundView.addSubview(nameLabel)
        backGroundView.addSubview(addressIDLabel)
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            copyAndSendButton.widthAnchor.constraint(equalToConstant: 38),
            copyAndSendButton.heightAnchor.constraint(equalToConstant: 38),
            copyAndSendButton.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 10),
            copyAndSendButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -0),
            namebackgroundView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 10),
            namebackgroundView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 0),
            namebackgroundView.trailingAnchor.constraint(equalTo: copyAndSendButton.leadingAnchor, constant: -10),
            namebackgroundView.centerYAnchor.constraint(equalTo: copyAndSendButton.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: namebackgroundView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: namebackgroundView.trailingAnchor, constant: -10),
            nameLabel.centerYAnchor.constraint(equalTo: namebackgroundView.centerYAnchor),
            addressIDLabel.topAnchor.constraint(equalTo: namebackgroundView.bottomAnchor, constant: 12),
            addressIDLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 0),
            addressIDLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -5),
            addressIDLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -10),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
