// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

enum SettingsSection: String, CaseIterable {
    case appAccess = "App Access"
    case communication = "Communication"
}

extension SettingsSection {
    var title: String {
        switch self {
        case .appAccess:
            return NSLocalizedString("APP_ACCESS", comment: "")
        case .communication:
            return NSLocalizedString("COMMUNICATION", comment: "")
        }
    }
}

struct SettingItem {
    let title: String
    let subtitle: String?
    var isOn: Bool
    var isEnabled: Bool = true
    var isToggleSwitch: Bool = true
    let iconName: String
}

// MARK: - Setting item

enum SettingInfo {
    
    /// Indicated Screen security
    case screenSecurity
    
    /// Indicated Incognito keyboard
    case incognitoKeyboard
    
    /// Indicated Read receipts
    case readReceipts
    
    /// Indicated Type indicators
    case typeIndicators
    
    /// Indicated Send link previews
    case sendLinkPreviews
    
    /// Indicated Voice and video calls
    case voiceAndVideoCalls
    
    /// Indicated Clear conversation History
    case clearConversationHistory
    
    //MARK: -  Constant
    
    /// title
    var title: String {
        let title: String
        switch self {
        case .screenSecurity:
            title = "Screen Security"
        case .incognitoKeyboard:
            title = NSLocalizedString("INCOGNITO_KEYBOARD", comment: "")
        case .readReceipts:
            title = NSLocalizedString("READ_RECEIPTS", comment: "")
        case .typeIndicators:
            title = NSLocalizedString("TYPING_INDICATORS", comment: "")
        case .sendLinkPreviews:
            title = NSLocalizedString("SEND_LINK_PREVIEWS", comment: "")
        case .voiceAndVideoCalls:
            title = NSLocalizedString("VOICE_VIDEO_CALLS", comment: "")
        case .clearConversationHistory:
            title = NSLocalizedString("SETTINGS_CLEAR_HISTORY", comment: "")
        }
        return title
    }
    
    /// sub title
    var subTitle: String {
        let subTitle: String
        switch self {
        case .screenSecurity:
            subTitle = "Block Screenshots in the recents list and inside the app"
        case .incognitoKeyboard:
            subTitle = NSLocalizedString("REQUEST_KEYBOARD_DISABLE_PERSONALIZED_LEARNING", comment: "")
        case .readReceipts:
            subTitle = NSLocalizedString("READ_RECEIPTS_DESCRIPTION", comment: "")
        case .typeIndicators:
            subTitle = NSLocalizedString("TYPING_INDICATORS_DESCRIPTION", comment: "")
        case .sendLinkPreviews:
            subTitle = NSLocalizedString("LINK_PREVIEWS_DESCRIPTION", comment: "")
        case .voiceAndVideoCalls:
            subTitle = NSLocalizedString("VOICE_VIDEO_CALLS_DESCRIPTION", comment: "")
        case .clearConversationHistory:
            subTitle = ""
        }
        return subTitle
    }
    
    /// image name
    var imageName: String {
        let imageName: String
        switch self {
            case .screenSecurity:
                imageName = "ic_security"
            case .incognitoKeyboard:
                imageName = "ic_keyboard"
            case .readReceipts:
                imageName = "ic_Read_receipetNew"
            case .typeIndicators:
                imageName = "ic_Type_indicaterNew"
            case .sendLinkPreviews:
                imageName = "ic_send_linkNew"
            case .voiceAndVideoCalls:
                imageName = "ic_video_callNew"
            case .clearConversationHistory:
                imageName = "ic_clear_imgaes"
        }
        return imageName
    }
}
