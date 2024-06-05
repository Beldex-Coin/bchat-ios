// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

// MARK: - MyAccount BNS view model

final class MyAccountBNSViewModel: NSObject {
    
    /// my account BNS Titles
    var menuTitles: [MyAccountBNSItem] = [.hops, .changePassword, .blockedContacts, .clearData, .feedback, .faq, .changelog]
    
}

// MARK: - MyAccount BNS item

enum MyAccountBNSItem {
    
    /// Indicated MyAccount BNS - Hops
    case hops
    
    /// Indicated MyAccount BNS - Change Password
    case changePassword
    
    /// Indicated MyAccount BNS - Blocked Contacts
    case blockedContacts
    
    /// Indicated MyAccount BNS - Clear Data
    case clearData
    
    /// Indicated MyAccount BNS - Feedback
    case feedback
    
    /// Indicated MyAccount BNS - FAQ
    case faq
    
    /// Indicated MyAccount BNS - Changelog
    case changelog
    
    //MARK: -  Constant
    
    /// the Default MyAccountBNSItem = `.myAccount`
    static let `default`: MyAccountBNSItem = .hops
    
    /// title
    var title: String {
        let aKey: String
        switch self {
            case .hops:
                aKey = "Hops"
            case .changePassword:
                aKey = "Change Password"
            case .blockedContacts:
                aKey = "Blocked Contacts"
            case .clearData:
                aKey = "Clear Data"
            case .feedback:
                aKey = "Feedback"
            case .faq:
                aKey = "FAQ"
            case .changelog:
                aKey = "Changelog"
        }
        return aKey
    }
    
    /// image name
    var imageName: String {
        let aKey: String
        switch self {
            case .hops:
                aKey = "ic_hops"
            case .changePassword:
                aKey = "ic_change_password"
            case .blockedContacts:
                aKey = "ic_blocked_contacts"
            case .clearData:
                aKey = "ic_clear_data"
            case .feedback:
                aKey = "ic_feedback"
            case .faq:
                aKey = "ic_faq"
            case .changelog:
                aKey = "ic_changelog"
        }
        return aKey
    }
}
