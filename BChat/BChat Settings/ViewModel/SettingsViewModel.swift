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
                SettingItem(title: "Screen Security", subtitle: "Block Screenshots in the recents list and inside the app", isOn: true, iconName: "lock.shield"),
                SettingItem(title: "Incognito Keyboard", subtitle: "Request keyboard to disable personalized learning", isOn: true, iconName: "keyboard")
            ],
            .wallet: [
                SettingItem(title: "Start Wallet", subtitle: "Enabling wallet will allow you to send and receive BDX", isOn: false, iconName: "creditcard"),
                SettingItem(title: "Pay as you chat", subtitle: "Enabling ‘Pay as you chat’ will allow you to send receive BDX right from the chat window", isOn: false, iconName: "arrow.triangle.2.circlepath")
            ],
            .communication: [
                SettingItem(title: "Read receipts", subtitle: "If read receipts are disabled, you won’t be able to see read receipts from others", isOn: true, iconName: "envelope.open"),
                SettingItem(title: "Type indicators", subtitle: "If typing indicators are disabled, you won’t be able to see typing indicators from others", isOn: true, iconName: "text.bubble"),
                SettingItem(title: "Send link previews", subtitle: "Previews are supported for Imgur, Instagram, Pinterest, Reddit, and YouTube links", isOn: false, iconName: "link"),
                SettingItem(title: "Voice and video calls", subtitle: "Allow access to accept voice and video calls from other users", isOn: false, iconName: "phone")
            ]
        ]
    }
    
    func toggleSwitch(for indexPath: IndexPath) {
        let section = SettingsSection.allCases[indexPath.section]
        guard var items = settings[section] else { return }
        items[indexPath.row].isOn.toggle()
        settings[section] = items
    }
}
