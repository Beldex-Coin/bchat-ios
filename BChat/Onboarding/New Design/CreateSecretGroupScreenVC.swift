// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class CreateSecretGroupScreenVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.boldOpenSans(ofSize: 22)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    private lazy var groupNameTextField: UITextField = {
        let result = UITextField()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x282836)
        result.layer.cornerRadius = 16
        result.setLeftPaddingPoints(23)
        result.attributedPlaceholder = NSAttributedString(
            string: "Enter Group name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)]
        )
        return result
    }()
    
    private lazy var separatorView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x4B4B64)
        return stackView
    }()
    
    private lazy var searchTextField: UITextField = {
        let result = UITextField()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x282836)
        result.layer.cornerRadius = 24
        result.setLeftPaddingPoints(23)
        result.attributedPlaceholder = NSAttributedString(
            string: "Search Contact",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)]
        )
        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        result.rightViewMode = UITextField.ViewMode.always
        return result
    }()
    
    lazy var searchImageView: UIImageView = {
       let result = UIImageView()
       result.image = UIImage(named: "ic_search")
        result.set(.width, to: 16)
        result.set(.height, to: 16)
       result.layer.masksToBounds = true
       result.contentMode = .center
       return result
   }()
    
    
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    
    private lazy var bottomButtonView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x000000)
        return stackView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Secret Group"
        
        view.addSubViews(titleLabel, groupNameTextField, separatorView, searchTextField, bottomButtonView, searchImageView)
        bottomButtonView.addSubview(createButton)
        view.addSubview(tableView)
        
            
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 14.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomButtonView.topAnchor, constant: 0).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(CreateSecretGroupTableViewCell.self, forCellReuseIdentifier: "CreateSecretGroupTableViewCell")
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        self.titleLabel.text = "Create Secret Group"
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            
            groupNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            groupNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            groupNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            groupNameTextField.heightAnchor.constraint(equalToConstant: 60),
            
            
            separatorView.topAnchor.constraint(equalTo: groupNameTextField.bottomAnchor, constant: 20),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            searchTextField.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 19),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            searchTextField.heightAnchor.constraint(equalToConstant: 48),
            
            searchImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            searchImageView.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
            
            bottomButtonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            bottomButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            bottomButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            bottomButtonView.heightAnchor.constraint(equalToConstant: 88),
            
            createButton.centerYAnchor.constraint(equalTo: bottomButtonView.centerYAnchor),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            createButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateSecretGroupTableViewCell") as! CreateSecretGroupTableViewCell
        
        return cell
    }
    
    

    // MARK: Button Actions :-
    @objc private func createButtonTapped() {
        let vc = NewDesignSettingsVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
