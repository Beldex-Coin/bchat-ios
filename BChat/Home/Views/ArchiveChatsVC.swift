// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class ArchiveChatsVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    
    private lazy var infoLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.textFieldPlaceHolderColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.numberOfLines = 0
        result.lineBreakMode = .byCharWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var tableView: UITableView = {
        let result = UITableView()
        result.backgroundColor = Colors.mainBackGroundColor2
        result.separatorStyle = .none
        result.register(HomeTableViewCell.self, forCellReuseIdentifier: "HomeTableViewCell")
        result.showsVerticalScrollIndicator = false
        return result
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.mainBackGroundColor2
        
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Archived Chats"
        setUpTopCornerRadius()
        
        view.addSubview(infoLabel)
        
        infoLabel.text = "Chats will automatically Unarchived when new messages are received."
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 19),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -19),
        ])
        
        // Table view
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        tableView.pin(.leading, to: .leading, of: view)
        tableView.pin(.top, to: .top, of: view, withInset: 16)
        tableView.pin(.trailing, to: .trailing, of: view)
        tableView.pin(.bottom, to: .bottom, of: view)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as! HomeTableViewCell
        
        return cell
    }

   
}
