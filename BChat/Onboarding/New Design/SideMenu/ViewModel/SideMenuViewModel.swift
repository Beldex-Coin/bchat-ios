// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

// MARK: - Side menu item

enum SideMenuItem {
    
    /// Indicated Side menu - Settings
    case settings
    
    /// Indicated Side menu - Notification
    case notification
    
    /// Indicated Side menu - Message Requests
    case messageRequests
    
    /// Indicated Side menu - Recovery Seed
    case recoverySeed
    
    /// Indicated MyAccount BNS - Language
    case language
    
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
    static let `default`: SideMenuItem = .settings
    
    /// title
    var title: String {
        let aKey: String
        switch self {
            case .settings:
                aKey = NSLocalizedString("SIDE_MENU_SETTINGS", comment: "")
            case .notification:
                aKey = NSLocalizedString("SIDE_MENU_NOTIFICATION", comment: "")
            case .messageRequests:
                aKey = NSLocalizedString("SIDE_MENU_MESSAGE_REQUESTS", comment: "")
            case .recoverySeed:
                aKey = NSLocalizedString("SIDE_MENU_RECOVERY_SEED", comment: "")
            case .reportIssue:
                aKey = NSLocalizedString("SIDE_MENU_REPORT_ISSUE", comment: "")
            case .language:
                aKey = NSLocalizedString("SIDE_MENU_LANGUAGE", comment: "")
            case .help:
                aKey = NSLocalizedString("SIDE_MENU_HELP", comment: "")
            case .invite:
                aKey = NSLocalizedString("SIDE_MENU_INVITE", comment: "")
            case .about:
                aKey = NSLocalizedString("SIDE_MENU_ABOUT", comment: "")
        }
        return aKey
    }
    
    /// image name
    var imageName: String {
        let aKey: String
        switch self {
            case .settings:
                aKey = "ic_settings_sideMenu"
            case .notification:
                aKey = "ic_menu_notification"
            case .messageRequests:
                aKey = "ic_menu_msg_rqst"
            case .recoverySeed:
                aKey = "ic_menu_recovery_seed_settings"
            case .language:
                aKey = "ic_menu_language"
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
    var menuTitles: [SideMenuItem] = [.settings, .notification, .messageRequests, .recoverySeed, .language, .reportIssue, .help, .invite, .about]
    
    /// hasTappableProfilePictureOSideMenuV
    var hasTappableProfilePicture: Bool = false
    
    /// tableViewHeightConstraint
    var tableViewHeightConstraint: NSLayoutConstraint!
}
