// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

extension MyAccountBnsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableView datasources
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menuTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewSettingsTableViewCell.reuserIdentifier) as! NewSettingsTableViewCell
        
        var myAccountItem: MyAccountBNSItem = .default
        switch viewModel.menuTitles[indexPath.row] {
            case .hops:
                myAccountItem = .hops
            case .changePassword:
                myAccountItem = .changePassword
            case .blockedContacts:
                myAccountItem = .blockedContacts
            case .clearData:
                myAccountItem = .clearData
            case .feedback:
                myAccountItem = .feedback
            case .faq:
                myAccountItem = .faq
            case .changelog:
                myAccountItem = .changelog
        }
        
        cell.titleLabel.text = myAccountItem.title
        cell.iconImageView.image = UIImage(named: myAccountItem.imageName)
        cell.dotView.isHidden = myAccountItem != .hops
        if NetworkReachabilityStatus.isConnectedToNetworkSignal() {
            cell.dotView.backgroundColor = Colors.bothGreenColor
        } else {
            cell.dotView.backgroundColor = Colors.bothRedColor
        }
        cell.arrowButton.isHidden = myAccountItem == .clearData || myAccountItem == .feedback || myAccountItem == .faq || myAccountItem == .changelog
        
        return cell
    }
    
    // MARK: - UITableView delegates
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch viewModel.menuTitles[indexPath.row] {
            case .hops:
                let vc = NewHopsVC()
                navigationController?.pushViewController(vc, animated: true)
            case .changePassword:
                let vc = NewPasswordVC()
                vc.isGoingBack = true
                vc.isCreatePassword = true
                vc.isChangePassword = true
                navigationController?.pushViewController(vc, animated: true)
            case .blockedContacts:
                let vc = NewBlockedContactVC()
                navigationController?.pushViewController(vc, animated: true)
            case .clearData:
                let vc = NewClearDataVC()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                present(vc, animated: true, completion: nil)
            case .feedback:
                if let url = URL(string: "mailto:\(bchat_email_Feedback)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case .faq:
                if let url = URL(string: bchat_FAQ_Link) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case .changelog:
                let vc = ChangeLogNewVC()
                navigationController?.pushViewController(vc, animated: true)
        }
    }
}

