// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

// MARK: - Side menu item

enum SideMenuItem {
    
    /// Indicated Side menu - My Account
    case myAccount
    
    /// Indicated Side menu - Settings
    case settings
    
    /// Indicated Side menu - Notification
    case notification
    
    /// Indicated Side menu - Message Requests
    case messageRequests
    
    /// Indicated Side menu - Recovery Seed
    case recoverySeed
    
    /// Indicated Side menu - Wallet
    case wallet
    
    /// Indicated Side menu - Report Issue
    case reportIssue
    
    /// Indicated Side menu - Help
    case help
    
    /// Indicated Side menu - Invite
    case invite
    
    /// Indicated Side menu - About
    case about
    
    //MARK: -  Constant
    
    /// the Default SideMenuItem = `.myAccount`
    static let `default`: SideMenuItem = .myAccount
    
    /// title
    var title: String {
        let aKey: String
        switch self {
            case .myAccount:
                aKey = "My Account"
            case .settings:
                aKey = "Settings"
            case .notification:
                aKey = "Notification"
            case .messageRequests:
                aKey = "Message Requests"
            case .recoverySeed:
                aKey = "Recovery Seed"
            case .wallet:
                aKey = "Wallet"
            case .reportIssue:
                aKey = "Report Issue"
            case .help:
                aKey = "Help"
            case .invite:
                aKey = "Invite"
            case .about:
                aKey = "About"
        }
        return aKey
    }
    
    /// image name
    var imageName: String {
        let aKey: String
        switch self {
            case .myAccount:
                aKey = "ic_menu_account_settings"
            case .settings:
                aKey = "ic_settings_sideMenu"
            case .notification:
                aKey = "ic_menu_notification"
            case .messageRequests:
                aKey = "ic_menu_msg_rqst"
            case .recoverySeed:
                aKey = "ic_menu_recovery_seed_settings"
            case .wallet:
                aKey = "ic_menu_wallet"
            case .reportIssue:
                aKey = "ic_menu_report_issue"
            case .help:
                aKey = "ic_menu_help"
            case .invite:
                aKey = "ic_menu_invite"
            case .about:
                aKey = "ic_menu_about"
        }
        return aKey
    }
}

// MARK: - Side menu view model

final class SideMenuViewModel: NSObject {
    
    /// menuTitles
    var menuTitles: [SideMenuItem] = [.myAccount, .settings, .notification, .messageRequests, .recoverySeed, .wallet, .reportIssue, .help, .invite, .about]
    
    /// hasTappableProfilePictureOSideMenuV
    var hasTappableProfilePicture: Bool = false
    
    /// tableViewHeightConstraint
    var tableViewHeightConstraint: NSLayoutConstraint!
}
