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
    case screenSecurity
    
    /// Indicated Incognito keyboard
    case incognitoKeyboard
    
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
        let aKey: String
        switch self {
        case .screenSecurity:
            aKey = "Screen Security"
        case .incognitoKeyboard:
            aKey = "Incognito Keyboard"
        case .startWallet:
            aKey = "Start Wallet"
        case .payAsYouChat:
            aKey = "Pay as you chat"
        case .readReceipts:
            aKey = "Read receipts"
        case .typeIndicators:
            aKey = "Type indicators"
        case .sendLinkPreviews:
            aKey = "Send link previews"
        case .voiceAndVideoCalls:
            aKey = "Voice and video calls"
        case .clearConversationHistory:
            aKey = "Clear conversation History"
        }
        return aKey
    }
    
    /// sub title
    var subTitle: String {
        let aKey: String
        switch self {
        case .screenSecurity:
            aKey = "Block Screenshots in the recents list and inside the app"
        case .incognitoKeyboard:
            aKey = "Request keyboard to disable personalized learning"
        case .startWallet:
            aKey = "Enabling wallet will allow you to send and receive BDX"
        case .payAsYouChat:
            aKey = "Enabling ‘Pay as you chat’ will allow you to send receive BDX right from the chat window"
        case .readReceipts:
            aKey = "If read receipts are disabled, you won’t be able to see read receipts from others"
        case .typeIndicators:
            aKey = "If typing indicators are disabled, you won’t be able to see typing indicators from others"
        case .sendLinkPreviews:
            aKey = "Previews are supported for Imgur, Instagram, Pinterest, Reddit, and YouTube links"
        case .voiceAndVideoCalls:
            aKey = "Allow access to accept voice and video calls from other users"
        case .clearConversationHistory:
            aKey = ""
        }
        return aKey
    }
    
    /// image name
    var imageName: String {
        let aKey: String
        switch self {
            case .screenSecurity:
                aKey = "ic_security"
            case .incognitoKeyboard:
                aKey = "ic_keyboard"
            case .startWallet:
                aKey = "ic_startWallet_white"
            case .payAsYouChat:
                aKey = "ic_pay_as_you_chat"
            case .readReceipts:
                aKey = "ic_Read_receipetNew"
            case .typeIndicators:
                aKey = "ic_Type_indicaterNew"
            case .sendLinkPreviews:
                aKey = "ic_send_linkNew"
            case .voiceAndVideoCalls:
                aKey = "ic_video_callNew"
            case .clearConversationHistory:
                aKey = "ic_clear_imgaes"
        }
        return aKey
    }
}
