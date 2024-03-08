//
//  SlideMenuVC.swift
//  Partea
//
//  Created by Blockhash on 30/08/21.
//

import UIKit
import SideMenu
import BChatUIKit
import BChatMessagingKit

extension Notification.Name {
    public static let myNotificationKey_doodlechange = Notification.Name(rawValue: "myNotificationKey_doodlechange")
}

@available(iOS 13.0, *)
class SlideMenuVC: BaseVC ,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
            tableView.register(UINib(nibName: "SlideMenuCell", bundle: nil), forCellReuseIdentifier: "SlideMenuCell")
        }
    }
    @IBOutlet weak var tableViewhightConst: NSLayoutConstraint!
    @IBOutlet weak var sampleSwitch: UISwitch!
    var titlesArray = ["My Account","Settings","Notification","Message Requests","Recovery Seed","Wallet","Report Issue","Help","Invite","About"]
    @IBOutlet weak var closebtn: UIButton!
    @IBOutlet weak var lblversion: UILabel!
    private var hasTappableProfilePicture: Bool = false
    @objc public var size: CGFloat = 30 // Not an implicitly unwrapped optional due to Obj-C limitations
    @objc public var useFallbackPicture = false
    @objc public var publicKey: String!
    @objc public var additionalPublicKey: String?
    @objc public var openGroupProfilePicture: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sampleSwitch.isUserInteractionEnabled = false
        self.navigationController?.isNavigationBarHidden = true
        if isLightMode {
            sampleSwitch.isOn = false
        }else {
            sampleSwitch.isOn = true
        }
        let origImage = UIImage(named: isLightMode ? "X" : "X")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        closebtn.setImage(tintedImage, for: .normal)
        closebtn.tintColor = isLightMode ? UIColor.black : UIColor.white
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"]!
        self.lblversion.text = "BChat \(version) (\(buildNumber))"
    }
    
    @IBAction func sampleSwitchValueChanged(_ sender: Any) {
        if sampleSwitch.isOn {
            AppModeManager.shared.setCurrentAppMode(to: .dark)
        }else {
            AppModeManager.shared.setCurrentAppMode(to: .light)
        }
        let origImage = UIImage(named: isLightMode ? "X" : "X")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        closebtn.setImage(tintedImage, for: .normal)
        closebtn.tintColor = isLightMode ? UIColor.black : UIColor.white
        let userInfo = [ "text" : "dark" ]
        NotificationCenter.default.post(name: .myNotificationKey_doodlechange, object: nil, userInfo: userInfo)
        tableView.reloadData()
    }
    
    @IBAction func CloseAction(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            self.tableViewhightConst.constant = CGFloat(titlesArray.count * 60)
            return titlesArray.count
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            cell.selectionStyle = .none
            
            cell.lblname.text = Storage.shared.getUser()?.name ?? UserDefaults.standard.string(forKey: "WalletName")?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            cell.lblIDName.text = "ID: \(getUserHexEncodedPublicKey())"
            
            let publicKey = getUserHexEncodedPublicKey()
            cell.imgpic.image = useFallbackPicture ? nil : (openGroupProfilePicture ?? getProfilePicture(of: size, for: publicKey))
            
            if let statusView = view.viewWithTag(333222) {
                statusView.removeFromSuperview()
            }
            // Path status indicator
//            let pathStatusView = PathStatusView()
//            pathStatusView.tag = 333222
//            pathStatusView.accessibilityLabel = "Current onion routing path indicator"
//            pathStatusView.set(.width, to: PathStatusView.size)
//            pathStatusView.set(.height, to: PathStatusView.size)
//            cell.imgpic.addSubview(pathStatusView)
//            pathStatusView.layer.borderWidth = 0.8
//            pathStatusView.layer.borderColor = UIColor.white.cgColor
//            pathStatusView.pin(.trailing, to: .trailing, of: cell.imgpic)
//            pathStatusView.pin(.bottom, to: .bottom, of: cell.imgpic)
            let origImage = UIImage(named: isLightMode ? "ic_QR_white" : "ic_QR_dark")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            cell.scanRef.setImage(tintedImage, for: .normal)
            cell.scanRef.tintColor = isLightMode ? UIColor.black : UIColor.white
            cell.scanRef.tag = indexPath.row
//            cell.scanRef.addTarget(self, action: #selector(didSelectViewAll), for: .touchUpInside)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SlideMenuCell", for: indexPath) as! SlideMenuCell
            cell.selectionStyle = .none
            cell.lblname.text = titlesArray[indexPath.row]
            cell.lblbeta.isHidden = true
            
            if indexPath.row == 0 { //My Account
                let logoName = isLightMode ? "my_account" : "ic_menu_account"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 1 {   //Settings
                let logoName = isLightMode ? "ic_settings" : "ic_menu_setting"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 2 {   //Notification
                let logoName = isLightMode ? "notification" : "ic_menu_notification"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 3 {   //Message Requests
                let logoName = isLightMode ? "message_request" : "ic_menu_msg_rqst"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 4 {   //Recovery Seed
                let logoName = isLightMode ? "recovery_seed" : "ic_menu_recovery_seed"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 5 {   //My Wallet
                let logoName = isLightMode ? "ic_MyWalletDark" : "ic_menu_wallet"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 6 {   //Report Issue
                let logoName = isLightMode ? "ic_ReportDark" : "ic_menu_report_issue"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 7 {   //Help
                let logoName = isLightMode ? "icons8-help" : "ic_menu_help"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 8{    //Invite
                let logoName = isLightMode ? "invite" : "ic_menu_invite"
                cell.img.image = UIImage(named: logoName)!
            }else { //About
                let logoName = isLightMode ? "about_dark" : "ic_menu_about"
                cell.img.image = UIImage(named: logoName)!
            }
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
                        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlertForWalletVC") as! AlertForWalletVC
                        self.navigationController?.pushViewController(vc, animated: true)
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
    
    @objc func didSelectViewAll(_ x: AnyObject) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRCodeScanVC") as! QRCodeScanVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getProfilePicture(of size: CGFloat, for publicKey: String) -> UIImage? {
        guard !publicKey.isEmpty else { return nil }
        if let profilePicture = OWSProfileManager.shared().profileAvatar(forRecipientId: publicKey) {
            hasTappableProfilePicture = true
            return profilePicture
        } else {
            hasTappableProfilePicture = false
            // TODO: Pass in context?
            let displayName = Storage.shared.getContact(with: publicKey)?.name ?? publicKey
            return Identicon.generatePlaceholderIcon(seed: publicKey, text: displayName, size: size)
        }
    }
    
}
