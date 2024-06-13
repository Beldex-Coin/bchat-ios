//
//  SingConstants.swift
//  
//


import Foundation

let bchat_Invite_Message : String = "Hey, I've been using BChat to chat with complete privacy and security. Come join me! Download it at https://apps.apple.com/kg/app/bchat-messenger/id1626066143. My Chat ID is"
let bchat_email_SupportMailID = "support@beldex.io"
let bchat_report_IssueID = "bdb890a974a25ef50c64cc4e3270c4c49c7096c433b8eecaf011c1ad000e426813"
let bchat_TermsConditionUrl_Link = "https://bchat.beldex.io/terms-and-conditions"
let bchat_FAQ_Link = "https://bchat.beldex.io/faq.html"
let bchat_email_Feedback = "feedback@beldex.io"
var globalDynamicNodeArray = [String]()
//let globalDynamicNodeUrl = "https://deb.beldex.io/Beldex-projects/Beldex-flutter-wallet/node_list.json"
let globalDynamicNodeUrl = "https://testdeb.beldex.dev/Beldex-Projects/Beldex-flutter-wallet/mainnet-apk/testing/15-04-2024/node_list.json"


// MARK: - Constants

struct Constants: Equatable {
    
    /// NotificationCenter name strings
    static let callTapBackToReturn = "connectingCallTapToReturnToTheCall"
    static let callConnectingShowView = "connectingCallShowView"
    static let callConnectionHideView = "connectingCallHideView"
    static let showPayAsYouChat = "showPayAsYouChat"
    static let showHideInputView = "hideOrShowInputView"
    static let bdxSlidingView = "bdxAmountPassingSliderView"
    static let rescanAction = "reScaneButtonAction"
    static let reconnect = "reconnectButtonAction"
    static let selectedNameDisplay = "selectedDisplayNameKey"
    static let selectedDecimalDisplay = "selectedDecimalNameKey"
    static let feePeriority = "feePriorityNameKey"
    static let selectedCurrency = "selectedCurrencyNameKey"
    static let refreshNodePopup = "refreshNodePopup"
    static let switchNodePopup = "switchNodePopUp"
    static let reloadSettingScreen = "reloadSettingScreenTable"
    static let blockMessageRequest = "blockMessageRequestTapped"
    static let acceptMessageRequest = "acceptMessageRequestTapped"
    static let deleteMessageRequest = "deleteMessageRequestTapped"
    static let blockContact = "blockContact"
    static let hideAttachment = "attachmentHidden"
    static let doodleChangeNotification = "doodleChangeNotification"
    static let unblockContact = "unblockContact"
    static let clearChatHistory = "clearChatHistory"
    static let dismissLinkBNSPopUp = "dismissLinkBNSPopUp"
    static let navigateToMyAccount = "navigateToMyAccount"
    
    
    /// Userdefaults strings
    static let isBnsVerifiedUser = "isBnsVerifiedUser"
}
