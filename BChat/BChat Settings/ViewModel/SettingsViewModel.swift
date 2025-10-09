// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

@MainActor
final class SettingsViewModel {
    
    private(set) var settings: [SettingsSection: [SettingItem]] = [:]
    
    init() {
        loadData()
    }
    
    private func loadData() {
        settings = [
            .appAccess: [
                SettingItem(title: "Screen Security", subtitle: "Block Screenshots in the recents list and inside the app", isOn: true, iconName: "ic_security"),
                SettingItem(title: "Incognito Keyboard", subtitle: "Request keyboard to disable personalized learning", isOn: true, iconName: "ic_keyboard")
            ],
            .wallet: [
                SettingItem(title: "Start Wallet", subtitle: "Enabling wallet will allow you to send and receive BDX", isOn: false, iconName: "ic_startWallet_white"),
                SettingItem(title: "Pay as you chat", subtitle: "Enabling ‘Pay as you chat’ will allow you to send receive BDX right from the chat window", isOn: false, iconName: "ic_pay_as_you_chat")
            ],
            .communication: [
                SettingItem(title: "Read receipts", subtitle: "If read receipts are disabled, you won’t be able to see read receipts from others", isOn: true, iconName: "ic_Read_receipetNew"),
                SettingItem(title: "Type indicators", subtitle: "If typing indicators are disabled, you won’t be able to see typing indicators from others", isOn: true, iconName: "ic_Type_indicaterNew"),
                SettingItem(title: "Send link previews", subtitle: "Previews are supported for Imgur, Instagram, Pinterest, Reddit, and YouTube links", isOn: false, iconName: "ic_send_linkNew"),
                SettingItem(title: "Voice and video calls", subtitle: "Allow access to accept voice and video calls from other users", isOn: false, iconName: "ic_video_callNew")
            ]
        ]
    }
    
    func toggleSwitch(for indexPath: IndexPath) {
        let section = SettingsSection.allCases[indexPath.section]
        guard var items = settings[section] else { return }
        items[indexPath.row].isOn.toggle()
        settings[section] = items
    }
    
    func switchValueChanged(rowAt indexPath: IndexPath) {
        let section = SettingsSection.allCases[indexPath.section]
        guard var items = settings[section] else { return }
        var isSwitchOn = items[indexPath.row].isOn
        if items[indexPath.row].title == "Screen Security" {
        } else if items[indexPath.row].title == "Incognito Keyboard" {
        } else if items[indexPath.row].title == "Start Wallet" {
            SSKPreferences.areWalletEnabled = isSwitchOn
        } else if items[indexPath.row].title == "Pay as you chat" {
            // delegate
        } else if items[indexPath.row].title == "Read receipts" {
            OWSReadReceiptManager.shared().setAreReadReceiptsEnabled(isSwitchOn)
        } else if items[indexPath.row].title == "Type indicators" {
            SSKEnvironment.shared.typingIndicators.setTypingIndicatorsEnabled(value: isSwitchOn)
        } else if items[indexPath.row].title == "Send link previews" {
            SSKPreferences.areLinkPreviewsEnabled = isSwitchOn
        } else if items[indexPath.row].title == "Voice and video calls" {
            // delegate
        }
    }
}
