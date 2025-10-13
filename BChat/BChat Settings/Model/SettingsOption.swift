// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

enum SettingsSection: String, CaseIterable {
    case appAccess = "App Access"
    case wallet = "Wallet"
    case communication = "Communication"
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
    case screenLock
    
    /// Indicated Incognito keyboard
    case disablePreview
    
    /// Indicated Start wallet
    case startWallet
    
    /// Indicated Pay as you chat
    case payAsYouChat
    
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
        case .screenLock:
            title = "Screen Lock"
        case .disablePreview:
            title = "Disable Preview in app switcher"
        case .startWallet:
            title = "Start Wallet"
        case .payAsYouChat:
            title = "Pay as you chat"
        case .readReceipts:
            title = "Read receipts"
        case .typeIndicators:
            title = "Type indicators"
        case .sendLinkPreviews:
            title = "Send link previews"
        case .voiceAndVideoCalls:
            title = "Voice and video calls"
        case .clearConversationHistory:
            title = "Clear conversation History"
        }
        return title
    }
    
    /// sub title
    var subTitle: String {
        let subTitle: String
        switch self {
            case .screenLock:
                subTitle = "Require Touch ID, Face ID or your device passcode to unlock BChat’s screen. You can still receive notifications when screen lock is enabled. Use BChat’s notification settings to customise the information displayed in notifications."
            case .disablePreview:
                subTitle = "Prevent BChat previews from appearing in the app switcher."
            case .startWallet:
                subTitle = "Enabling wallet will allow you to send and receive BDX."
            case .payAsYouChat:
                subTitle = "Enabling ‘Pay as you chat’ will allow you to send receive BDX right from the chat window."
            case .readReceipts:
                subTitle = "If read receipts are disabled, you won’t be able to see read receipts from others."
            case .typeIndicators:
                subTitle = "If typing indicators are disabled, you won’t be able to see typing indicators from others."
            case .sendLinkPreviews:
                subTitle = "Previews are supported for Imgur, Instagram, Pinterest, Reddit, and YouTube links."
            case .voiceAndVideoCalls:
                subTitle = "Allow access to accept voice and video calls from other users."
            case .clearConversationHistory:
                subTitle = ""
        }
        return subTitle
    }
    
    /// image name
    var imageName: String {
        let imageName: String
        switch self {
            case .screenLock:
                imageName = "ic_security"
            case .disablePreview:
                imageName = "ic_keyboard"
            case .startWallet:
                imageName = "ic_startWallet_white"
            case .payAsYouChat:
                imageName = "ic_pay_as_you_chat"
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
