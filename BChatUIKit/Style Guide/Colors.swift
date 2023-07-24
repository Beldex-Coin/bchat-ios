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
    @objc public static var cellPinned2: UIColor { UIColor(named: "bchat_cell_pinned2")! }
    @objc public static var navigationBarBackground: UIColor { UIColor(named: "bchat_navigation_bar_background")! }
    @objc public static var searchBarPlaceholder: UIColor { UIColor(named: "bchat_search_bar_placeholder")! } // Also used for the icons
    @objc public static var searchBarBackground: UIColor { UIColor(named: "bchat_search_bar_background")! }
    @objc public static var expandedButtonGlowColor: UIColor { UIColor(named: "bchat_expanded_button_glow_color")! }
    @objc public static var separator: UIColor { UIColor(named: "bchat_separator")! }
    @objc public static var unimportantButtonBackground: UIColor { UIColor(named: "bchat_unimportant_button_background")! }
    @objc public static var buttonBackground: UIColor { UIColor(named: "bchat_button_background")! }
    @objc public static var buttonBackground2: UIColor { UIColor(named: "bchat_button_background2")! }
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
    
    @objc public static var accent2: UIColor { UIColor(named: "bchat_accent2")! }
    @objc public static var accent3: UIColor { UIColor(named: "bchat_accent3")! }
    @objc public static var cellBackground2: UIColor { UIColor(named: "bchat_cell_background2")! }
    @objc public static var navigationBarBackground2: UIColor { UIColor(named: "bchat_navigation_bar_background2")! }
    @objc public static var unimportantButtonBackground2: UIColor { UIColor(named: "bchat_unimportant_button_background2")! }
    
    @objc public static var bchat_button_clr: UIColor { UIColor(named: "bchat_button_clr")! }
    @objc public static var bchat_button_clr2: UIColor { UIColor(named: "bchat_button_clr2")! }
    @objc public static var bchat_lbl_name: UIColor { UIColor(named: "bchat_lbl_name")! }
    @objc public static var bchat_placeholder_clr: UIColor { UIColor(named: "bchat_placeholder_clr")! }
    @objc public static var bchat_small_label_clr: UIColor { UIColor(named: "bchat_small_label_clr")! }
    @objc public static var bchat_storyboard_clr: UIColor { UIColor(named: "bchat_storyboard_clr")! }
    @objc public static var bchat_view_bg_clr: UIColor { UIColor(named: "bchat_view_bg_clr")! }
    @objc public static var myaccountclrs: UIColor { UIColor(named: "myaccountclrs")! }
    
    @objc public static var RegBChatViewcolors: UIColor { UIColor(named: "RegBChatViewcolors")! }
    @objc public static var SlidemenuBgcolor: UIColor { UIColor(named: "SlidemenuBgcolor")! }
    @objc public static var SlidemenuBgcolorBOX: UIColor { UIColor(named: "SlidemenuBgcolorBOX")! }
    @objc public static var bchatpopupclr: UIColor { UIColor(named: "bchatpopupclr")! }
    @objc public static var bchatattachemnt: UIColor { UIColor(named: "bchatattachemnt")! }
    @objc public static var bchatmeassgeReq: UIColor { UIColor(named: "bchatmeassgeReq")! }
    @objc public static var bchat_join_backgroundgreen: UIColor { UIColor(named: "bchat_join_backgroundgreen")! }
    @objc public static var SyncingPopColor: UIColor { UIColor(named: "SyncingPopColor")! }
    @objc public static var mywallethome_bottomview: UIColor { UIColor(named: "mywallethome_bottomview")! }
}
