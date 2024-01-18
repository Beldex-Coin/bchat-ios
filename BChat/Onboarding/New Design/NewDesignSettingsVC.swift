// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewDesignSettingsVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    
    let tableView : UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    
    let imageArray = ["ic_hops", "ic_change_password",/*"ic_app_lock"*/ "ic_chat_settings", "ic_blocked_contacts", "ic_clear_data", "ic_feedback", "ic_faq", "ic_changelog"]
    let titleArray = ["Hops", "Change Password",/*"App Lock"*/ "Chat Settings", "Blocked Contacts", "Clear Data", "Feedback", "FAQ", "Changelog"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: nil, action: nil)
        
        view.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 26).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.register(NewSettingsTableViewCell.self, forCellReuseIdentifier: "NewSettingsTableViewCell")
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
    }
    

    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titleArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewSettingsTableViewCell") as! NewSettingsTableViewCell
        
        if indexPath.row == 0 {
            cell.smallDotView.isHidden = false
        }
        cell.titleLabel.text = self.titleArray[indexPath.row]
        cell.iconImageView.image = UIImage(named: self.imageArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 2 {
            let vc = SyncingOptionPopUpVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        
        if indexPath.row == 3 {
            let vc = EnableWalletVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if indexPath.row == 4 {
            let vc = NewClearDataVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        
        if indexPath.row == 5 {
            let vc = PayAsYouChatPopUpVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        if indexPath.row == 6 {
            let vc = PINSuccessPopUp()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
        
    }
   

}
