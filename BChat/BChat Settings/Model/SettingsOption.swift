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
    let iconName: String
}
