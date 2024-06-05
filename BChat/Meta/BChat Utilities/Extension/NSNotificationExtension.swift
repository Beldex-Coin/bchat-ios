// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

extension Notification.Name {
    static var callConnectingTapNotification = Notification.Name(rawValue: Constants.callTapBackToReturn)
    static var connectingCallShowViewNotification = Notification.Name(rawValue: Constants.callConnectingShowView)
    static var connectingCallHideViewNotification = Notification.Name(rawValue: Constants.callConnectionHideView)
    static var showPayAsYouChatNotification = Notification.Name(rawValue: Constants.showPayAsYouChat)
    static var hideOrShowInputViewNotification = Notification.Name(rawValue: Constants.showHideInputView)
    static var reScaneButtonActionNotification = Notification.Name(rawValue: Constants.rescanAction)
    static var reconnectButtonActionNotification = Notification.Name(rawValue: Constants.reconnect)
    static var selectedDisplayNameKeyNotification = Notification.Name(rawValue: Constants.selectedNameDisplay)
    static var selectedDecimalNameKeyNotification = Notification.Name(rawValue: Constants.selectedDecimalDisplay)
    static var feePriorityNameKeyNotification = Notification.Name(rawValue: Constants.feePeriority)
    static var selectedCurrencyNameKeyNotification = Notification.Name(rawValue: Constants.selectedCurrency)
    static var refreshNodePopUpNotification = Notification.Name(rawValue: Constants.refreshNodePopup)
    static var switchNodePopUpNotification = Notification.Name(rawValue: Constants.switchNodePopup)
    static var reloadSettingScreenTableNotification = Notification.Name(rawValue: Constants.reloadSettingScreen)
    static var blockMessageRequestTappedNotification = Notification.Name(rawValue: Constants.blockMessageRequest)
    static var acceptMessageRequestTappedNotification = Notification.Name(rawValue: Constants.acceptMessageRequest)
    static var deleteMessageRequestTappedNotification = Notification.Name(rawValue: Constants.deleteMessageRequest)
    static var attachmentHiddenNotification = Notification.Name(rawValue: Constants.hideAttachment)
    static var userBlockContactNotification = Notification.Name(rawValue: Constants.userBlockContact)
    static let doodleChangeNotification = Notification.Name(rawValue: Constants.doodleChangeNotification)
}
