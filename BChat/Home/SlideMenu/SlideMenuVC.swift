//
//  SlideMenuVC.swift
//  Partea
//
//  Created by Blockhash on 30/08/21.
//

import UIKit
import SideMenu
import BChatUIKit

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
    var titlesArray = ["My Account","My Wallet","Notification","Message Requests","Privacy","Recovery Seed","Report Issue","Help","Invite","About"]
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
        
        self.navigationController?.isNavigationBarHidden = true
        if isLightMode {
            sampleSwitch.isOn = false
            let origImage = UIImage(named: "X")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            closebtn.setImage(tintedImage, for: .normal)
            closebtn.tintColor = .black
        }else {
            sampleSwitch.isOn = true
            let origImage = UIImage(named: "X")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            closebtn.setImage(tintedImage, for: .normal)
            closebtn.tintColor = .white
        }
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"]!
        self.lblversion.text = "BChat \(version) (\(buildNumber))"
    }
    
    @IBAction func sampleSwitchValueChanged(_ sender: Any) {
        if sampleSwitch.isOn {
            AppModeManager.shared.setCurrentAppMode(to: .dark)
            let origImage = UIImage(named: "X")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            closebtn.setImage(tintedImage, for: .normal)
            closebtn.tintColor = .white
            let userInfo = [ "text" : "dark" ]
            NotificationCenter.default.post(name: .myNotificationKey_doodlechange, object: nil, userInfo: userInfo)
        }else {
            AppModeManager.shared.setCurrentAppMode(to: .light)
            let origImage = UIImage(named: "X")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            closebtn.setImage(tintedImage, for: .normal)
            closebtn.tintColor = .black
            let userInfo = [ "text" : "light" ]
            NotificationCenter.default.post(name: .myNotificationKey_doodlechange, object: nil, userInfo: userInfo)
        }
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
            
            cell.lblname.text = Storage.shared.getUser()?.name
            cell.lblIDName.text = "ID: \(getUserHexEncodedPublicKey())"
            
            let publicKey = getUserHexEncodedPublicKey()
            cell.imgpic.image = useFallbackPicture ? nil : (openGroupProfilePicture ?? getProfilePicture(of: size, for: publicKey))
            // Path status indicator
            let pathStatusView = PathStatusView()
            pathStatusView.accessibilityLabel = "Current onion routing path indicator"
            pathStatusView.set(.width, to: PathStatusView.size)
            pathStatusView.set(.height, to: PathStatusView.size)
            cell.imgpic.addSubview(pathStatusView)
            pathStatusView.layer.borderWidth = 0.8
            pathStatusView.layer.borderColor = UIColor.white.cgColor
            pathStatusView.pin(.trailing, to: .trailing, of: cell.imgpic)
            pathStatusView.pin(.bottom, to: .bottom, of: cell.imgpic)
            let origImage = UIImage(named: isLightMode ? "ic_QR_white" : "ic_QR_dark")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            cell.scanRef.setImage(tintedImage, for: .normal)
            cell.scanRef.tintColor = isLightMode ? UIColor.black : UIColor.white
            cell.scanRef.tag = indexPath.row
            cell.scanRef.addTarget(self, action: #selector(didSelectViewAll), for: .touchUpInside)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SlideMenuCell", for: indexPath) as! SlideMenuCell
            cell.selectionStyle = .none
            cell.lblname.text = titlesArray[indexPath.row]
            cell.lblbeta.isHidden = true
            
            if indexPath.row == 0 {
                let logoName = isLightMode ? "my_account" : "round-account-button-with-user-inside"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 1 {
                cell.lblbeta.isHidden = false
                let logoName = isLightMode ? "ic_MyWalletDark" : "ic_MyWalletWhite"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 2 {
                let logoName = isLightMode ? "notification" : "icons8-notification"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 3 {
                let logoName = isLightMode ? "message_request" : "MsgReq"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 4 {
                let logoName = isLightMode ? "privacy44" : "privacy-1"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 5 {
                let logoName = isLightMode ? "recovery_seed" : "recovery_seed-1"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 6 {
                let logoName = isLightMode ? "ic_ReportDark" : "ic_ReportWhite"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 7 {
                let logoName = isLightMode ? "icons8-help" : "help-web-button"
                cell.img.image = UIImage(named: logoName)!
            }else if indexPath.row == 8{
                let logoName = isLightMode ? "invite" : "invite-1"
                cell.img.image = UIImage(named: logoName)!
            }else {
                let logoName = isLightMode ? "about_dark" : "about987"
                cell.img.image = UIImage(named: logoName)!
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyAccountVC") as! MyAccountVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            if indexPath.row == 0 {
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyAccountVC") as! MyAccountVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else if indexPath.row == 1 {
                if NetworkReachabilityStatus.isConnectedToNetworkSignal(){
                    if SaveUserDefaultsData.WalletPassword.isEmpty {
                        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletPasscodeVC") as! MyWalletPasscodeVC
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletPasscodeVC") as! MyWalletPasscodeVC
                        vc.isEnterPin = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }else {
                    self.showToastMsg(message: "Please check your internet connection", seconds: 1.0)
                }
            }else if indexPath.row == 2 {
                let notificationSettingsVC = NotificationSettingsViewController()
                navigationController!.pushViewController(notificationSettingsVC, animated: true)
            }else if indexPath.row == 3 {
                let viewController: MessageRequestsViewController = MessageRequestsViewController()
                self.navigationController?.pushViewController(viewController, animated: true)
            }else if indexPath.row == 4 {
                let privacySettingsVC = PrivacySettingsTableViewController()
                navigationController!.pushViewController(privacySettingsVC, animated: true)
            }else if indexPath.row == 5 {
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImportantAlertVC") as! ImportantAlertVC
                self.navigationController?.pushViewController(vc, animated: true)
            }else if indexPath.row == 6 {
                let thread = TSContactThread.getOrCreateThread(contactBChatID: "\(bchat_report_IssueID)")
                SignalApp.shared().presentConversation(for: thread, action: .compose, animated: true)
            }else if indexPath.row == 7 {
                if let url = URL(string: "mailto:\(bchat_email_SupportMailID)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }else if indexPath.row == 8 {
                let invitation = "\(bchat_Invite_Message)" + "\(getUserHexEncodedPublicKey()) !"
                let shareVC = UIActivityViewController(activityItems: [ invitation ], applicationActivities: nil)
                navigationController!.present(shareVC, animated: true, completion: nil)
            }else if indexPath.row == 9{
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AboutUs") as! AboutUs
                self.navigationController?.pushViewController(vc, animated: true)
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
