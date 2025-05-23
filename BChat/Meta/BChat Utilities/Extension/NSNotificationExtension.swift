// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

extension Notification.Name {
    static var callConnectingTapNotification = Notification.Name(rawValue: Constants.callTapBackToReturn)
    static var connectingCallShowViewNotification = Notification.Name(rawValue: Constants.callConnectingShowView)
    static var connectingCallHideViewNotification = Notification.Name(rawValue: Constants.callConnectionHideView)
    static var showPayAsYouChatNotification = Notification.Name(rawValue: Constants.showPayAsYouChat)
    static var showInputViewNotification = Notification.Name(rawValue: Constants.showInputView)
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
    static var blockContactNotification = Notification.Name(rawValue: Constants.blockContact)
    static let doodleChangeNotification = Notification.Name(rawValue: Constants.doodleChangeNotification)
    static var unblockContactNotification = Notification.Name(rawValue: Constants.unblockContact)
    static var clearChatHistoryNotification = Notification.Name(rawValue: Constants.clearChatHistory)
    static var dismissLinkBNSPopUpNotification = Notification.Name(rawValue: Constants.dismissLinkBNSPopUp)
    static var navigateToMyAccountNotification = Notification.Name(rawValue: Constants.navigateToMyAccount)
    static var LeaveGroupNotification = Notification.Name(rawValue: Constants.leaveGroup)
    static var dismissMiniView = Notification.Name(rawValue: Constants.dismissMiniView)
    static var joinedOpenGroup = Notification.Name(rawValue: Constants.joinedOpenGroup)
}
