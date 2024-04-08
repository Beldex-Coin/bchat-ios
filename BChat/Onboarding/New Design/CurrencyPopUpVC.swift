// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class CurrencyPopUpVC: BaseVC,UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate {

    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.smallBackGroundColor
        stackView.layer.cornerRadius = 20
         stackView.layer.borderWidth = 1
         stackView.layer.borderColor = Colors.borderColorNew.cgColor
        return stackView
    }()
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Currency"
        return result
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_closeNew"), for: .normal)
        return button
    }()
    @objc private lazy var tableView: UITableView = {
        let result = UITableView()
        result.dataSource = self
        result.delegate = self
        result.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        result.separatorStyle = .none
        result.backgroundColor = .clear
        result.separatorColor = .clear
        result.translatesAutoresizingMaskIntoConstraints = false
        result.rowHeight = UITableView.automaticDimension
        return result
    }()
    private lazy var searchTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("Search Currency", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: Colors.noDataLabelColor])
        result.font = Fonts.OpenSans(ofSize: 14)
        result.layer.borderColor = Colors.borderColorNew.cgColor
        result.backgroundColor = Colors.cellGroundColor2
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
    var currencyNameArray = ["aud","brl","cad","chf","cny","czk","eur","dkk","gbp","hkd","huf","idr","ils","inr","jpy","krw","mxn","myr","nok","nzd","php","pln","rub","sek","sgd","thb","usd","vef","zar"]
    var filteredCurrencyArray: [String] = []
    var searchText: String = ""
    var currencyNameString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, closeButton)
        backGroundView.addSubview(tableView)
        backGroundView.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            backGroundView.heightAnchor.constraint(equalToConstant: 360),
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -18),
            closeButton.heightAnchor.constraint(equalToConstant: 22),
            closeButton.widthAnchor.constraint(equalToConstant: 22),
            searchTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchTextField.heightAnchor.constraint(equalToConstant: 48),
            searchTextField.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            tableView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 23),
            tableView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -23),
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -23),
        ])
        
        filteredCurrencyArray = currencyNameArray
        if !SaveUserDefaultsData.SelectedCurrency.isEmpty {
            currencyNameString = SaveUserDefaultsData.SelectedCurrency
        }
        
    }
    
    @objc func closeIconTapped() {
        searchTextField.text = ""
        filteredCurrencyArray = currencyNameArray
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
                let currentText = textField.text ?? ""
                if currentText != searchText {
                    // Update searchText
                    searchText = currentText
                    // Update filteredCurrencyArray based on the search text
                    if searchText.isEmpty {
                        // If the search text is empty, show all currencies without filtering
                        filteredCurrencyArray = currencyNameArray
                    } else {
                        // Update the filteredCurrencyArray based on the search text
                        let predicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", searchText)
                        filteredCurrencyArray = currencyNameArray.filter { predicate.evaluate(with: $0) }
                    }
                    // Reload the table view with the filtered or unfiltered data
                    tableView.reloadData()
                }
            }
            if let closeIconImageView = rightView.subviews.first(where: { $0 is UIImageView && $0.tag == 1 }) as? UIImageView {
                closeIconImageView.isHidden = textField.text!.isEmpty
                let currentText = textField.text ?? ""
                if currentText != searchText {
                    // Update searchText
                    searchText = currentText
                    // Update filteredCurrencyArray based on the search text
                    if searchText.isEmpty {
                        // If the search text is empty, show all currencies without filtering
                        filteredCurrencyArray = currencyNameArray
                    } else {
                        // Update the filteredCurrencyArray based on the search text
                        let predicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", searchText)
                        filteredCurrencyArray = currencyNameArray.filter { predicate.evaluate(with: $0) }
                    }
                    // Reload the table view with the filtered or unfiltered data
                    tableView.reloadData()
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the current text in the search field
        searchText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if searchText.isEmpty {
            // If the search text is empty, show all currencies without filtering
            filteredCurrencyArray = currencyNameArray
        } else {
            // Update the filteredCurrencyArray based on the search text
            let predicate = NSPredicate(format: "SELF BEGINSWITH[c] %@", searchText)
            filteredCurrencyArray = currencyNameArray.filter { predicate.evaluate(with: $0) }
        }
        // Reload the table view with the filtered or unfiltered data
        tableView.reloadData()
        return true
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        SaveUserDefaultsData.SelectedCurrency = currencyNameString
        NotificationCenter.default.post(name: Notification.Name("selectedCurrencyNameKey"), object: SaveUserDefaultsData.SelectedCurrency)
        self.tableView.reloadData()
        self.searchTextField.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCurrencyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CurrencyPopUpTableCell(style: .default, reuseIdentifier: "CurrencyPopUpTableCell")
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.nameLabel.text = filteredCurrencyArray[indexPath.row].uppercased()
        if filteredCurrencyArray[indexPath.row].contains(SaveUserDefaultsData.SelectedCurrency) {
            cell.nameLabel.textColor = Colors.bothGreenColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CurrencyPopUpTableCell
        cell.selectionStyle = .none
        cell.nameLabel.textColor = Colors.bothGreenColor
        cell.nameLabel.font = Fonts.boldOpenSans(ofSize: 16)
        currencyNameString = filteredCurrencyArray[indexPath.row]
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CurrencyPopUpTableCell
        cell.selectionStyle = .none
        cell.nameLabel.textColor = Colors.bothGrayColor
        cell.nameLabel.font = Fonts.OpenSans(ofSize: 16)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

class CurrencyPopUpTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear//UIColor(hex: 0x1C1C26)
        return view
    }()
    lazy var lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.borderColorNew
        return view
    }()
    lazy var nameLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothGrayColor
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(nameLabel)
        backGroundView.addSubview(lineView)
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -0),
            nameLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 15),
            nameLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            lineView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            lineView.heightAnchor.constraint(equalToConstant: 1),
            lineView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 70),
            lineView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -70),
            lineView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -0),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

