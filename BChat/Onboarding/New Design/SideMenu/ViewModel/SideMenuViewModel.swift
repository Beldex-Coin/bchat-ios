// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

// MARK: -

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
}
