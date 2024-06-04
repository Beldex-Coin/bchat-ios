// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            viewModel.tableViewHeightConstraint.constant = CGFloat(viewModel.menuTitles.count * 60)
            return viewModel.menuTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 100 : 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuProfileTableViewCell.reuseIdentifier) as! SideMenuProfileTableViewCell
            
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = Colors.cancelButtonBackgroundColor
            cell.backGroundView.backgroundColor = Colors.cellGroundColor3
            cell.titleLabel.text = Storage.shared.getUser()?.name ?? UserDefaults.standard.string(forKey: "WalletName")?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            cell.subTitleLabel.text = "ID: \(getUserHexEncodedPublicKey())"
            cell.titleLabel.textColor = Colors.titleColor
            cell.subTitleLabel.textColor = Colors.noDataLabelColor
            
            let publicKey = getUserHexEncodedPublicKey()
            cell.iconImageView.image = useFallbackPicture ? nil : (openGroupProfilePicture ?? getProfilePicture(of: size, for: publicKey))
            
            let origImage = UIImage(named: isLightMode ? "ic_QR_white" : "ic_QR_dark")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            cell.scanImageView.image = tintedImage
            cell.scanImageView.tintColor = isLightMode ? .black : .white
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.reuseIdentifier) as! SideMenuTableViewCell
            
            cell.contentView.backgroundColor = Colors.cancelButtonBackgroundColor
            cell.selectionStyle = .none
            cell.titleLabel.textColor = Colors.titleColor2
            
            var menuItems: SideMenuItem = .default
            switch viewModel.menuTitles[indexPath.row] {
                case .myAccount:
                    menuItems = .myAccount
                case .settings:
                    menuItems = .settings
                case .notification:
                    menuItems = .notification
                case .messageRequests:
                    menuItems = .messageRequests
                case .recoverySeed:
                    menuItems = .recoverySeed
                case .wallet:
                    menuItems = .wallet
                case .reportIssue:
                    menuItems = .reportIssue
                case .help:
                    menuItems = .help
                case .invite:
                    menuItems = .invite
                case .about:
                    menuItems = .about
            }
            
            cell.titleLabel.text = menuItems.title
            cell.iconImageView.image = UIImage(named: menuItems.imageName)!
            cell.betaTitleLabel.isHidden = viewModel.menuTitles[indexPath.row] != .wallet
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            let viewController = MyAccountNewVC()
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            switch viewModel.menuTitles[indexPath.row] {
                case .myAccount:
                    let viewController = MyAccountNewVC()
                    navigationController?.pushViewController(viewController, animated: true)
                case .settings:
                    let viewController = BChatSettingsNewVC()
                    navigationController?.pushViewController(viewController, animated: true)
                case .notification:
                    let viewController = NotificationsNewVC()
                    navigationController?.pushViewController(viewController, animated: true)
                case .messageRequests:
                    let viewController = NewMessageRequestVC()
                    navigationController?.pushViewController(viewController, animated: true)
                case .recoverySeed:
                    let viewController = NewAlertRecoverySeedVC()
                    navigationController?.pushViewController(viewController, animated: true)
                case .wallet:
                    if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
                        // Old flow (without wallet)
                        if SaveUserDefaultsData.israndomUUIDPassword == "" {
                            let viewController = EnableWalletVC()
                            navigationController?.pushViewController(viewController, animated: true)
                            return
                        }
                        // New flow (with wallet)
                        if SSKPreferences.areWalletEnabled {
                            let viewController = NewPasswordVC()
                            viewController.isGoingWallet = true
                            viewController.isVerifyPassword = true
                            navigationController?.pushViewController(viewController, animated: true)
                        } else {
                            let viewController = EnableWalletVC()
                            navigationController?.pushViewController(viewController, animated: true)
                        }
                    } else {
                        self.showToastMsg(message: "Please check your internet connection", seconds: 1.0)
                    }
                case .reportIssue:
                    let thread = TSContactThread.getOrCreateThread(contactBChatID: "\(bchat_report_IssueID)")
                    SignalApp.shared().presentConversation(for: thread, action: .compose, animated: true)
                case .help:
                    if let url = URL(string: "mailto:\(bchat_email_SupportMailID)") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                case .invite:
                    let invitation = "\(bchat_Invite_Message)" + "\(getUserHexEncodedPublicKey()) !"
                    let shareVC = UIActivityViewController(activityItems: [ invitation ], applicationActivities: nil)
                    navigationController?.present(shareVC, animated: true, completion: nil)
                case .about:
                    let viewController = AboutNewVC()
                    navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}
