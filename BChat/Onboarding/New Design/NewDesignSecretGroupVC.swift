// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewDesignSecretGroupVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
      }()
    
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("CREATE_GROUP", comment: ""), for: .normal)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Secret Group"
        
        view.addSubview(createButton)
        view.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        tableView.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 25.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(SecretGroupTableViewCell.self, forCellReuseIdentifier: "SecretGroupTableViewCell")
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        NSLayoutConstraint.activate([
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            createButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            createButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    

    
    
    
    // MARK: Button Actions :-
    @objc private func createButtonTapped() {
        let vc = CreateSecretGroupScreenVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: TableView Methods :-
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SecretGroupTableViewCell") as! SecretGroupTableViewCell
        
        if indexPath.row == 0 || indexPath.row == 2 {
            cell.backGroundView.backgroundColor = UIColor(hex: 0x282836)
        }
        return cell
    }
    
}
