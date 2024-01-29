// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class WalletAddressBookNewVC: UIViewController, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate {
    
    private lazy var searchTextField: UITextField = {
        let result = UITextField()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("SEARCH_CONTACT_NEW", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 14)
        result.backgroundColor = UIColor(hex: 0x353544)
        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        result.set(.height, to: 60)
        result.layer.cornerRadius = 24
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingViewLeft
        result.leftViewMode = .always
        // Create an UIImageView and set its image
        let imageView = UIImageView(image: UIImage(named: "ic_Search_Vector_New"))
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // Adjust the frame as needed
        imageView.contentMode = .scaleAspectFit // Set the content mode as needed
        // Add some padding between the image and the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        result.rightView = paddingView
        result.rightViewMode = UITextField.ViewMode.always
        // Set the rightView of the TextField to the created UIImageView
        result.rightView?.addSubview(imageView)
        result.delegate = self
        result.returnKeyType = .done
        result.clearButtonMode = .whileEditing
        return result
    }()
    private lazy var bottomBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x111119)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Address Book"
        
        view.addSubview(searchTextField)
        view.addSubview(bottomBackgroundView)
        bottomBackgroundView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 19),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            searchTextField.heightAnchor.constraint(equalToConstant: 48),
            bottomBackgroundView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 17),
            bottomBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            bottomBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            bottomBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: bottomBackgroundView.topAnchor, constant: 15),
            tableView.leadingAnchor.constraint(equalTo: bottomBackgroundView.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: bottomBackgroundView.trailingAnchor, constant: -0),
            tableView.bottomAnchor.constraint(equalTo: bottomBackgroundView.bottomAnchor, constant: -0),
        ])
        
    }
    
    // MARK: - Navigation

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AddressBookTableCell(style: .default, reuseIdentifier: "AddressBookTableCell")
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
class AddressBookTableCell: UITableViewCell {
    // MARK: - Properties
    lazy var backGroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear//UIColor(hex: 0x1C1C26)
        view.layer.cornerRadius = 16
        return view
    }()
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.greenColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.setImage(UIImage(named: "ic_copy_white2"), for: .normal)
        return button
    }()
    lazy var namebackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        view.layer.cornerRadius = 9
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        return view
    }()
    lazy var addressIDLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.semiOpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "akhsdaisdhasdhos0a9ysfhap9sdfhasf8wqef90wefhdsafhasdfkadsfdsfhasdkjvbvsdasmnbasdjasidgfluihdsafhasdfkadsfdsfhasdkjvbvsdasmnbasdjasidgfluidfasdcasjkdh8saodihdkagsdias"
        result.numberOfLines = 0
        return result
    }()
    lazy var nameLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "John"
        return result
    }()
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews to the cell
        contentView.addSubview(backGroundView)
        backGroundView.addSubview(copyButton)
        backGroundView.addSubview(namebackgroundView)
        namebackgroundView.addSubview(nameLabel)
        backGroundView.addSubview(addressIDLabel)
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            backGroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            backGroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            backGroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            copyButton.widthAnchor.constraint(equalToConstant: 38),
            copyButton.heightAnchor.constraint(equalToConstant: 38),
            copyButton.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 10),
            copyButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -0),
            namebackgroundView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 10),
            namebackgroundView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 0),
            namebackgroundView.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -10),
            namebackgroundView.centerYAnchor.constraint(equalTo: copyButton.centerYAnchor),
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
