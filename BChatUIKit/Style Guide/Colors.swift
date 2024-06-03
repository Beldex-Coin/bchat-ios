import UIKit

@objc public extension UIColor {

    @objc convenience init(hex value: UInt) {
        let red = CGFloat((value >> 16) & 0xff) / 255
        let green = CGFloat((value >> 8) & 0xff) / 255
        let blue = CGFloat((value >> 0) & 0xff) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

@objc(LKColors)
public final class Colors : NSObject {
    
    @objc public static var grey: UIColor { UIColor(named: "bchat_grey")! }
    @objc public static var accent: UIColor { UIColor(named: "bchat_accent")! }
    @objc public static var text: UIColor { UIColor(named: "bchat_text")! }
    @objc public static var destructive: UIColor { UIColor(named: "bchat_destructive")! }
    @objc public static var unimportant: UIColor { UIColor(named: "bchat_unimportant")! }
    @objc public static var border: UIColor { UIColor(named: "bchat_border")! }
    @objc public static var cellBackground: UIColor { UIColor(named: "bchat_cell_background")! }
    @objc public static var cellSelected: UIColor { UIColor(named: "bchat_cell_selected")! }
    @objc public static var cellPinned: UIColor { UIColor(named: "bchat_cell_pinned")! }
    @objc public static var cellPinnedColor: UIColor { UIColor(named: "cellPinnedColor")! }
    @objc public static var navigationBarBackground: UIColor { UIColor(named: "bchat_navigation_bar_background")! }
    @objc public static var searchBarPlaceholder: UIColor { UIColor(named: "bchat_search_bar_placeholder")! } // Also used for the icons
    @objc public static var searchBarBackground: UIColor { UIColor(named: "bchat_search_bar_background")! }
    @objc public static var expandedButtonGlowColor: UIColor { UIColor(named: "bchat_expanded_button_glow_color")! }
    @objc public static var separator: UIColor { UIColor(named: "bchat_separator")! }
    @objc public static var unimportantButtonBackground: UIColor { UIColor(named: "bchat_unimportant_button_background")! }
    @objc public static var buttonBackground: UIColor { UIColor(named: "bchat_button_background")! }
    @objc public static var buttonBackgroundColor: UIColor { UIColor(named: "buttonBackgroundColor")! }
    @objc public static var settingButtonSelected: UIColor { UIColor(named: "bchat_setting_button_selected")! }
    @objc public static var modalBackground: UIColor { UIColor(named: "bchat_modal_background")! }
    @objc public static var modalBorder: UIColor { UIColor(named: "bchat_modal_border")! }
    @objc public static var fakeChatBubbleBackground: UIColor { UIColor(named: "bchat_fake_chat_bubble_background")! }
    @objc public static var fakeChatBubbleText: UIColor { UIColor(named: "bchat_fake_chat_bubble_text")! }
    @objc public static var composeViewBackground: UIColor { UIColor(named: "bchat_compose_view_background")! }
    @objc public static var composeViewTextFieldBackground: UIColor { UIColor(named: "bchat_compose_view_text_field_background")! }
    @objc public static var receivedMessageBackground: UIColor { UIColor(named: "bchat_received_message_background")! }
    @objc public static var sentMessageBackground: UIColor { UIColor(named: "bchat_sent_message_background")! }
    @objc public static var newConversationButtonCollapsedBackground: UIColor { UIColor(named: "bchat_new_conversation_button_collapsed_background")! }
    @objc public static var pnOptionBackground: UIColor { UIColor(named: "bchat_pn_option_background")! }
    @objc public static var pnOptionBorder: UIColor { UIColor(named: "bchat_pn_option_border")! }
    @objc public static var pathsBuilding: UIColor { UIColor(named: "bchat_paths_building")! }
    @objc public static var callMessageBackground: UIColor { UIColor(named: "bchat_call_message_background")! }
    @objc public static var pinIcon: UIColor { UIColor(named: "bchat_pin_icon")! }
    @objc public static var bchatHeading: UIColor { UIColor(named: "bchat_heading")! }
    @objc public static var bchatMessageRequestsBubble: UIColor { UIColor(named: "bchat_message_requests_bubble")! }
    @objc public static var bchatMessageRequestsIcon: UIColor { UIColor(named: "bchat_message_requests_icon")! }
    @objc public static var bchatMessageRequestsTitle: UIColor { UIColor(named: "bchat_message_requests_title")! }
    @objc public static var bchatMessageRequestsInfoText: UIColor { UIColor(named: "bchat_message_requests_info_text")! }
    
    @objc public static var accentColor: UIColor { UIColor(named: "accentColor")! }
    @objc public static var accentFullColor: UIColor { UIColor(named: "accentFullColor")! }
    @objc public static var cellBackgroundColor: UIColor { UIColor(named: "cellBackgroundColor")! }
    @objc public static var navigationBarBackgroundColor: UIColor { UIColor(named: "navigationBarBackgroundColor")! }
    @objc public static var unimportantButtonBackgroundColor: UIColor { UIColor(named: "unimportantButtonBackgroundColor")! }
    
    @objc public static var bchatButtonColor: UIColor { UIColor(named: "bchat_button_clr")! }
    @objc public static var bchatButtonGreenColor: UIColor { UIColor(named: "bchat_button_clr2")! }
    @objc public static var bchatLabelNameColor: UIColor { UIColor(named: "bchat_lbl_name")! }
    @objc public static var bchatPlaceholderColor: UIColor { UIColor(named: "bchat_placeholder_clr")! }
    @objc public static var bchatSmallLabelColor: UIColor { UIColor(named: "bchat_small_label_clr")! }
    @objc public static var bchatStoryboardColor: UIColor { UIColor(named: "bchat_storyboard_clr")! }
    @objc public static var bchatViewBackgroundColor: UIColor { UIColor(named: "bchat_view_bg_clr")! }
    @objc public static var myAccountColor: UIColor { UIColor(named: "myaccountclrs")! }
    
    @objc public static var regBchatViewColor: UIColor { UIColor(named: "RegBChatViewcolors")! }
    @objc public static var slideMenuBackgroundColor: UIColor { UIColor(named: "SlidemenuBgcolor")! }
    @objc public static var slideMenuBackgroundColorBox: UIColor { UIColor(named: "SlidemenuBgcolorBOX")! }
    @objc public static var bchatpopupclr: UIColor { UIColor(named: "bchatpopupclr")! }
    @objc public static var bchatattachemnt: UIColor { UIColor(named: "bchatattachemnt")! }
    @objc public static var bchatmeassgeReq: UIColor { UIColor(named: "bchatmeassgeReq")! }
    @objc public static var bchatJoinOpenGpBackgroundGreen: UIColor { UIColor(named: "bchat_join_backgroundgreen")! }
    @objc public static var syncingPopColor: UIColor { UIColor(named: "SyncingPopColor")! }
    @objc public static var myWalletHomeBottomViewColor: UIColor { UIColor(named: "mywallethome_bottomview")! }
    
    
    //New Design Colors
    @objc public static var viewBackgroundColor: UIColor { UIColor(named: "viewBackgroundColor")! }
    @objc public static var backgroundViewColor: UIColor { UIColor(named: "backgroundViewColor")! }
    @objc public static var borderColor: UIColor { UIColor(named: "borderColor")! }
    @objc public static var textColor: UIColor { UIColor(named: "textColor")! }
    @objc public static var backgroundViewColor2: UIColor { UIColor(named: "backgroundViewColor2")! }
    @objc public static var placeholderColor: UIColor { UIColor(named: "placeholderColor")! }
    @objc public static var greenColor: UIColor { UIColor(named: "greenColor")! }
    @objc public static var blueColor: UIColor { UIColor(named: "blueColor")! }
    @objc public static var buttonBackgroundColor2: UIColor { UIColor(named: "buttonBackgroundColor2")! }
    @objc public static var buttonTextColor: UIColor { UIColor(named: "buttonTextColor")! }
    @objc public static var cellBackgroundColor2: UIColor { UIColor(named: "cellBackgroundColor2")! }
    
    @objc public static var searchViewBackgroundColor: UIColor { UIColor(named: "searchViewBackgroundColor")! }
    @objc public static var viewBackgroundColorNew: UIColor { UIColor(named: "viewBackgroundColorNew")! }
    @objc public static var addressBookSaveAddressLabelColor: UIColor { UIColor(named: "addressBookSaveAddressLabelColor")! }
    @objc public static var addressBookNoContactLabelColor: UIColor { UIColor(named: "addressBookNoContactLabelColor")! }
    @objc public static var setUpScreenBackgroundColor: UIColor { UIColor(named: "setUpScreenBackgroundColor")! }
    @objc public static var idLabelColor: UIColor { UIColor(named: "idLabelColor")! }
    @objc public static var aboutContentLabelColor: UIColor { UIColor(named: "aboutContentLabelColor")! }
    @objc public static var cellBackgroundColorForChangeLog: UIColor { UIColor(named: "cellBackgroundColorForChangeLog")! }
    @objc public static var cellBackgroundColorForNodeList: UIColor { UIColor(named: "cellBackgroundColorForNodeList")! }
    @objc public static var cellIpLabelColor: UIColor { UIColor(named: "cellIpLabelColor")! }
    @objc public static var cellIpLabelColor2: UIColor { UIColor(named: "cellIpLabelColor2")! }
    @objc public static var cellNodeOffColor: UIColor { UIColor(named: "cellNodeOffColor")! }
    @objc public static var settingsCellBackgroundColor: UIColor { UIColor(named: "settingsCellBackgroundColor")! }
    @objc public static var settingsCellLabelColor: UIColor { UIColor(named: "settingsCellLabelColor")! }
    @objc public static var settingsDescriptionCellLabelColor: UIColor { UIColor(named: "settingsDescriptionCellLabelColor")! }
    @objc public static var settingsResultTitleCellLabelColor: UIColor { UIColor(named: "settingsResultTitleCellLabelColor")! }
    @objc public static var myAccountViewBackgroundColor: UIColor { UIColor(named: "myAccountViewBackgroundColor")! }
    @objc public static var lineViewbackgroundColor: UIColor { UIColor(named: "lineViewbackgroundColor")! }
    @objc public static var outerProfileViewbackgroundColor: UIColor { UIColor(named: "outerProfileViewbackgroundColor")! }
    @objc public static var innerProfileImageViewColor: UIColor { UIColor(named: "innerProfileImageViewColor")! }
    @objc public static var profileImageViewButtonColor: UIColor { UIColor(named: "profileImageViewButtonColor")! }
    @objc public static var profileImageViewButtonTextColor: UIColor { UIColor(named: "profileImageViewButtonTextColor")! }
    @objc public static var cameraViewBackgroundColor: UIColor { UIColor(named: "cameraViewBackgroundColor")! }
    @objc public static var refreshNodePopUpBackgroundColor: UIColor { UIColor(named: "refreshNodePopUpBackgroundColor")! }
    @objc public static var popUpBackgroundColor: UIColor { UIColor(named: "popUpBackgroundColor")! }
    @objc public static var walletSettingsSubTitleLabelColor: UIColor { UIColor(named: "walletSettingsSubTitleLabelColor")! }

    @objc public static var bothGreenColor: UIColor { UIColor(named: "00BD40")! }
    @objc public static var bothRedColor: UIColor { UIColor(named: "FF3E3E")! }
    @objc public static var bothBlueColor: UIColor { UIColor(named: "0085FF")! }
    @objc public static var bothWhiteColor: UIColor { UIColor(named: "FFFFFF")! }
    @objc public static var bothGrayColor: UIColor { UIColor(named: "ACACAC")! }
    @objc public static var darkGreenColor: UIColor { UIColor(named: "008D06")! }
    @objc public static var callCellTitle: UIColor { UIColor(named: "EBEBEB")! }
    @objc public static var titleColor: UIColor { UIColor(named: "EBEBEB-333333")! }
    @objc public static var titleColor2: UIColor { UIColor(named: "EBEBEB-222222")! }
    @objc public static var titleColor3: UIColor { UIColor(named: "FFFFFF-333333")! }
    @objc public static var titleColor4: UIColor { UIColor(named: "FFFFFF-222222")! }
    @objc public static var titleColor5: UIColor { UIColor(named: "A7A7BA-333333")! }
    
    @objc public static var mainBackGroundColor: UIColor { UIColor(named: "111119-EBEBEB")! }
    @objc public static var mainBackGroundColor2: UIColor { UIColor(named: "11111A-EBEBEB")! }
    @objc public static var mainBackGroundColor3: UIColor { UIColor(named: "11111A-F8F8F8")! }
    @objc public static var mainBackGroundColor4: UIColor { UIColor(named: "11111A-F0F0F0")! }
    @objc public static var backGroundColorWithAlpha: UIColor { UIColor(named: "080812-E0E0E0")! }
    @objc public static var cellGroundColor: UIColor { UIColor(named: "1C1C26-F4F4F4")! }
    @objc public static var cellGroundColor2: UIColor { UIColor(named: "1C1C26-F8F8F8")! }
    @objc public static var cellGroundColor3: UIColor { UIColor(named: "282836-F8F8F8")! }
    @objc public static var borderColorNew: UIColor { UIColor(named: "4B4B64-A7A7BA")! }
    @objc public static var noBorderColor: UIColor { UIColor(named: "4B4B64-F8F8F8")! }
    @objc public static var noBorderColor2: UIColor { UIColor(named: "4B4B64-FFFFFF")! }
    @objc public static var noBorderColor3: UIColor { UIColor(named: "24242F-FFFFFF")! }
    @objc public static var borderColor3: UIColor { UIColor(named: "353544-A7A7BA")! }
    
    @objc public static var cancelButtonBackgroundColor: UIColor { UIColor(named: "1C1C26-F0F0F0")! }
    @objc public static var cancelButtonBackgroundColor2: UIColor { UIColor(named: "282836-ECECEC")! }
    @objc public static var cancelButtonTitleColor: UIColor { UIColor(named: "ACACAC")! }
    
    @objc public static var cancelButtonTitleColor1: UIColor { UIColor(named: "ACACAC-333333")! }
    
    @objc public static var smallBackGroundColor: UIColor { UIColor(named: "111119-F8F8F8")! }
    @objc public static var smallTitleColor: UIColor { UIColor(named: "6A6A77")! }
    @objc public static var yellowColor: UIColor { UIColor(named: "F0AF13-ECAB0F")! }
    @objc public static var seedBackgroundColor: UIColor { UIColor(named: "111119-FFFFFF")! }
    @objc public static var unlockButtonBackgroundColor: UIColor { UIColor(named: "282836-F4F4F4")! }
    @objc public static var unlockButtonBackgroundColor2: UIColor { UIColor(named: "282836-FFFFFF")! }
    @objc public static var textFieldPlaceHolderColor: UIColor { UIColor(named: "A7A7BA-8A8A9D")! }
    @objc public static var noDataLabelColor: UIColor { UIColor(named: "A7A7BA")! }
    @objc public static var placeHolderColor: UIColor { UIColor(named: "77778B-A7A7BA")! }
    @objc public static var buttonDisableColor: UIColor { UIColor(named: "6C6C78-A7A7BA")! }
    @objc public static var messageRequestBackgroundColor: UIColor { UIColor(named: "EBEBEB-FFFFFF")! }
    @objc public static var incomingMessageColor: UIColor { UIColor(named: "2C2C3B-E0E0E0")! }
    @objc public static var textViewColor: UIColor { UIColor(named: "2C2C3B-F4F4F4")! }
    @objc public static var holdViewbackgroundColor: UIColor { UIColor(named: "2C2C3B-ECECEC")! }
    
    @objc public static var viewBackgroundColorSocialGroup: UIColor { UIColor(named: "viewBackgroundColorSocialGroup")! }
    @objc public static var letsBChatButtonColor: UIColor { UIColor(named: "letsBChatButtonColor")! }
    @objc public static var scanButtonBackgroundColor: UIColor { UIColor(named: "scanButtonBackgroundColor")! }
    @objc public static var qrCodeBackgroundColor: UIColor { UIColor(named: "qrCodeBackgroundColor")! }
    @objc public static var confirmSendingViewBackgroundColor: UIColor { UIColor(named: "confirmSendingViewBackgroundColor")! }
    @objc public static var viewBackgroundColorNew2: UIColor { UIColor(named: "viewBackgroundColorNew2")! }
    
    
    
    @objc public static var walletHomeTopViewBackgroundColor: UIColor { UIColor(named: "walletHomeTopViewBackgroundColor")! }
    @objc public static var walletHomeReconnectBackgroundColor: UIColor { UIColor(named: "walletHomeReconnectBackgroundColor")! }
    @objc public static var walletHomeFilterLabelColor: UIColor { UIColor(named: "walletHomeFilterLabelColor")! }
    @objc public static var walletHomeDateViewBackgroundColor: UIColor { UIColor(named: "walletHomeDateViewBackgroundColor")! }
    
    
    @objc public static var darkThemeTextBoxColor: UIColor { UIColor(named: "1C1C26")! }
    @objc public static var homeScreenFloatingbackgroundColor: UIColor { UIColor(named: "1C1C26-ECECEC")! }
    @objc public static var newChatbackgroundColor: UIColor { UIColor(named: "2C2C3B-F4F4F4")! }
    @objc public static var messageRequestBackGroundColor: UIColor { UIColor(named: "111119-F8F8F8")! }
    @objc public static var alertBackGroundColor: UIColor { UIColor(named: "080812-E0E0E0")! }
    @objc public static var messageTimeLabelColor: UIColor { UIColor(named: "5F5F76-A7A7BA")! }
    @objc public static var titleNewColor: UIColor { UIColor(named: "ACACAC-8A8A9D")! }
    
    @objc public static var paymentViewInsideColor: UIColor { UIColor(named: "3F3F56-EBEBEB")! }
    @objc public static var paymentViewInsideReciverColor: UIColor { UIColor(named: "00A939")! }
    @objc public static var bdxColor: UIColor { UIColor(named: "ACACAC-ACACAC")! }
    
    @objc public static var callPermissionCancelbtnColor: UIColor { UIColor(named: "333333-ACACAC")! }
    @objc public static var attachmentViewBackgroundColor: UIColor { UIColor(named: "21212C-EBEBEB")! }
    @objc public static var switchBackgroundColor: UIColor { UIColor(named: "363645-FFFFFF")! }
    @objc public static var switchOffBackgroundColor: UIColor { UIColor(named: "9595B5")! }
    
    @objc public static var separatorHomeTableViewCellColor: UIColor { UIColor(named: "1C1C26-D5D5D5")! }
    @objc public static var smallBackGroundViewCellColor: UIColor { UIColor(named: "1C1C26-EBEBEB")! }
    @objc public static var chatSettingsGrayColor: UIColor { UIColor(named: "ACACAC-8A8A9D-Alpha")! }
    @objc public static var expandBackgroundColor: UIColor { UIColor(named: "282836-EBEBEB")! }
    @objc public static var betaBackgroundColor: UIColor { UIColor(named: "A7A7BA-E0E0E0")! }
    @objc public static var walletDisableButtonColor: UIColor { UIColor(named: "333343-E0E0E0")! }
    @objc public static var enableSendButtonColor: UIColor { UIColor(named: "2979FB")! }
    
    
}
