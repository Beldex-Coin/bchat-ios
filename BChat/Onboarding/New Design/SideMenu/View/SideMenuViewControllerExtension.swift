// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

extension SideMenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            tableViewHeightConstraint.constant = CGFloat(menuTitles.count * 60)
            return menuTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuProfileTableViewCell") as! SideMenuProfileTableViewCell
            
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
            cell.scanImageView.tintColor = isLightMode ? UIColor.black : UIColor.white
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as! SideMenuTableViewCell
            
            cell.contentView.backgroundColor = Colors.cancelButtonBackgroundColor
            cell.selectionStyle = .none
            cell.titleLabel.textColor = Colors.titleColor2
            
            var menuItems: SideMenuItem = .myAccount
            var logoName: String?
            switch menuTitles[indexPath.row] {
                case .myAccount:
                    logoName = "ic_menu_account"
                    menuItems = .myAccount
                case .settings:
                    logoName = "ic_menu_setting"
                    menuItems = .settings
                case .notification:
                    logoName = "ic_menu_notification"
                    menuItems = .notification
                case .messageRequests:
                    logoName = "ic_menu_msg_rqst"
                    menuItems = .messageRequests
                case .recoverySeed:
                    logoName = "ic_menu_recovery_seed"
                    menuItems = .recoverySeed
                case .wallet:
                    logoName = "ic_menu_wallet"
                    menuItems = .wallet
                case .reportIssue:
                    logoName = "ic_menu_report_issue"
                    menuItems = .reportIssue
                case .help:
                    logoName = "ic_menu_help"
                    menuItems = .help
                case .invite:
                    logoName = "ic_menu_invite"
                    menuItems = .invite
                case .about:
                    logoName = "ic_menu_about"
                    menuItems = .about
            }
            
            cell.titleLabel.text = menuItems.title
            cell.iconImageView.image = UIImage(named: logoName ?? "")!
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = MyAccountNewVC()
            navigationController!.pushViewController(vc, animated: true)
        }else {
            if indexPath.row == 0 { //My Account
                let vc = MyAccountNewVC()
                navigationController!.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 {   //Settings
                let vc = BChatSettingsNewVC()
                navigationController!.pushViewController(vc, animated: true)
            } else if indexPath.row == 2 {   //Notification
                let vc = NotificationsNewVC()
                navigationController!.pushViewController(vc, animated: true)
            } else if indexPath.row == 3 {   //Message Requests
                let vc = NewMessageRequestVC()
                navigationController!.pushViewController(vc, animated: true)
            } else if indexPath.row == 4 {   //Recovery Seed
                let vc = NewAlertRecoverySeedVC()
                navigationController!.pushViewController(vc, animated: true)
            } else if indexPath.row == 5 {   //My Wallet
                if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
                    // MARK: - Old flow (without wallet)
                    if SaveUserDefaultsData.israndomUUIDPassword == "" {
                        let vc = EnableWalletVC()
                        navigationController!.pushViewController(vc, animated: true)
                        return
                    }
                    // MARK: - New flow (with wallet)
                    if SSKPreferences.areWalletEnabled {
                        if SaveUserDefaultsData.WalletPassword.isEmpty {
                            let vc = NewPasswordVC()
                            vc.isGoingWallet = true
                            vc.isVerifyPassword = true
                            navigationController!.pushViewController(vc, animated: true)
                        }else {
                            let vc = NewPasswordVC()
                            vc.isGoingWallet = true
                            vc.isVerifyPassword = true
                            navigationController!.pushViewController(vc, animated: true)
                        }
                    }else {
                        let vc = EnableWalletVC()
                        navigationController!.pushViewController(vc, animated: true)
                    }
                }else {
                    self.showToastMsg(message: "Please check your internet connection", seconds: 1.0)
                }
            }else if indexPath.row == 6 {   //Report Issue
                let thread = TSContactThread.getOrCreateThread(contactBChatID: "\(bchat_report_IssueID)")
                SignalApp.shared().presentConversation(for: thread, action: .compose, animated: true)
            }else if indexPath.row == 7 {   //Help
                if let url = URL(string: "mailto:\(bchat_email_SupportMailID)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }else if indexPath.row == 8 {   //Invite
                let invitation = "\(bchat_Invite_Message)" + "\(getUserHexEncodedPublicKey()) !"
                let shareVC = UIActivityViewController(activityItems: [ invitation ], applicationActivities: nil)
                navigationController!.present(shareVC, animated: true, completion: nil)
            }else if indexPath.row == 9{    //About
                let vc = AboutNewVC()
                navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
}
