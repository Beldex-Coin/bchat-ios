// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewMessageRequestVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    
    
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0x111119)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Message Request", style: .plain, target: nil, action: nil)
        
        
        view.addSubview(tableView)
            
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 22.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(NewMessageRequestTableViewCell.self, forCellReuseIdentifier: "NewMessageRequestTableViewCell")
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewMessageRequestTableViewCell") as! NewMessageRequestTableViewCell
        
        
        
        return cell
    }
    

    

}
