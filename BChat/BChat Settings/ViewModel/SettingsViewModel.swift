// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

protocol SettingsViewModelDelegate: AnyObject {
    func payAsYouChat(_ isEnabled: Bool)
    func voiceAndVideoCall(_ isEnabled: Bool)
    func reloadPayAsYouChatRow(_ indexPath: IndexPath)
}

@MainActor
final class SettingsViewModel {
    
    private(set) var settings: [SettingsSection: [SettingItem]] = [:]
    
    weak var delegate: SettingsViewModelDelegate?
    
    var isPayAsYouChatEnabled: Bool {
        if SSKPreferences.areWalletEnabled {
            return SSKPreferences.arePayAsYouChatEnabled
        }
        return false
    }
    
    init() {
        loadData()
    }
    
    private func loadData() {
        settings = [
            .appAccess: [
                SettingItem(title: SettingInfo.screenSecurity.title, subtitle: SettingInfo.screenSecurity.subTitle, isOn: false, isEnabled: true, isToggleSwitch: true, iconName: SettingInfo.screenSecurity.imageName),
                SettingItem(title: SettingInfo.incognitoKeyboard.title, subtitle: SettingInfo.incognitoKeyboard.subTitle, isOn: false, isEnabled: true, isToggleSwitch: true, iconName: SettingInfo.incognitoKeyboard.imageName)
            ],
            .wallet: [
                SettingItem(title: SettingInfo.startWallet.title, subtitle: SettingInfo.startWallet.subTitle, isOn: SSKPreferences.areWalletEnabled, isEnabled: true, isToggleSwitch: true, iconName: SettingInfo.startWallet.imageName),
                SettingItem(title: SettingInfo.payAsYouChat.title, subtitle: SettingInfo.payAsYouChat.subTitle, isOn: isPayAsYouChatEnabled, isEnabled: SSKPreferences.areWalletEnabled, isToggleSwitch: true, iconName: SettingInfo.payAsYouChat.imageName)
            ],
            .communication: [
                SettingItem(title: SettingInfo.readReceipts.title, subtitle: SettingInfo.readReceipts.subTitle, isOn: OWSReadReceiptManager.shared().areReadReceiptsEnabled(), isEnabled: true, isToggleSwitch: true, iconName: SettingInfo.readReceipts.imageName),
                SettingItem(title: SettingInfo.typeIndicators.title, subtitle: SettingInfo.typeIndicators.subTitle, isOn: SSKEnvironment.shared.typingIndicators.areTypingIndicatorsEnabled(), isEnabled: true, isToggleSwitch: true, iconName: SettingInfo.typeIndicators.imageName),
                SettingItem(title: SettingInfo.sendLinkPreviews.title, subtitle: SettingInfo.sendLinkPreviews.subTitle, isOn: SSKPreferences.areLinkPreviewsEnabled, isEnabled: true, isToggleSwitch: true, iconName: SettingInfo.sendLinkPreviews.imageName),
                SettingItem(title: SettingInfo.voiceAndVideoCalls.title, subtitle: SettingInfo.voiceAndVideoCalls.subTitle, isOn: SSKPreferences.areCallsEnabled, isEnabled: true, isToggleSwitch: true, iconName: SettingInfo.voiceAndVideoCalls.imageName),
                SettingItem(title: SettingInfo.clearConversationHistory.title, subtitle: SettingInfo.clearConversationHistory.subTitle, isOn: false, isEnabled: true, isToggleSwitch: false, iconName: SettingInfo.clearConversationHistory.imageName)
            ]
        ]
    }
    
    func toggleSwitch(for indexPath: IndexPath, completionHandler: @escaping () -> Void) {
        let section = SettingsSection.allCases[indexPath.section]
        guard var items = settings[section] else { return }
        items[indexPath.row].isOn.toggle()
        settings[section] = items
        completionHandler()
    }
    
    func switchValueChanged(rowAt indexPath: IndexPath) {
        let section = SettingsSection.allCases[indexPath.section]
        guard let items = settings[section] else { return }
        let isEnabled = items[indexPath.row].isOn
        if items[indexPath.row].title == SettingInfo.screenSecurity.title {
        } else if items[indexPath.row].title == SettingInfo.incognitoKeyboard.title {
        } else if items[indexPath.row].title == SettingInfo.startWallet.title {
            SSKPreferences.areWalletEnabled = isEnabled
            delegate?.reloadPayAsYouChatRow(indexPath)
        } else if items[indexPath.row].title == SettingInfo.payAsYouChat.title {
            delegate?.payAsYouChat(isEnabled)
        } else if items[indexPath.row].title == SettingInfo.readReceipts.title {
            OWSReadReceiptManager.shared().setAreReadReceiptsEnabled(isEnabled)
        } else if items[indexPath.row].title == SettingInfo.typeIndicators.title {
            SSKEnvironment.shared.typingIndicators.setTypingIndicatorsEnabled(value: isEnabled)
        } else if items[indexPath.row].title == SettingInfo.sendLinkPreviews.title {
            SSKPreferences.areLinkPreviewsEnabled = isEnabled
        } else if items[indexPath.row].title == SettingInfo.voiceAndVideoCalls.title {
            delegate?.voiceAndVideoCall(isEnabled)
        }
    }
}
