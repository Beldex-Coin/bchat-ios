// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit

// Top level confirmation modal image type for popup
public enum ConfirmationModalType: Int {
    
    case gifEnable
    case payAsYouChat
    case leaveGroup
    case shareContact
    case acceptMsgRequest
    case deleteMsgRequest
    case blockUserRequest
    case blockContact
    case unblockContact
    
    case cameraPermission
    case callPermission
    case clearChat
    case missedCall
    case setPwdSuccess
    case changePwdSuccess
    case linkBnsSuccess
    case walletSync
    case transactionIntiate
    case transactionSuccess
    case none
    
    /// image name
    var imageName: String {
        let name: String
        
        switch self {
            case .cameraPermission:
                name = ""
            case .callPermission:
                name = "ic_settings_call_permission"
            case .clearChat:
                name = "ic_clearChatPopUp"
            case .missedCall:
                name = "ic_missedCall"
            case .setPwdSuccess, .changePwdSuccess:
                    name = ""
            case .linkBnsSuccess:
                name = ""
            case .walletSync:
                name = ""
            case .transactionIntiate:
                name = ""
            case .transactionSuccess:
                name = ""
            case .gifEnable,
                .payAsYouChat,
                .leaveGroup,
                .shareContact,
                .acceptMsgRequest,
                .deleteMsgRequest,
                .blockUserRequest,
                .blockContact,
                .unblockContact,
                .none:
                name = ""
        }
        
        return name
    }
    
    var isShowImage: Bool {
        let isShow: Bool
        
        switch self {
            case .gifEnable,
                .payAsYouChat,
                .leaveGroup,
                .shareContact,
                .acceptMsgRequest,
                .deleteMsgRequest,
                .blockUserRequest,
                .blockContact,
                .unblockContact,
                .none:
                    isShow = false
            case .cameraPermission,
                .callPermission,
                .clearChat,
                .missedCall,
                .setPwdSuccess,
                .changePwdSuccess,
                .linkBnsSuccess,
                .walletSync,
                .transactionIntiate,
                .transactionSuccess:
                    isShow = true
        }
        
        return isShow
    }
    
    var confirmationButtonBgColor: UIColor {
        var color: UIColor
        
        switch self {
            case .gifEnable,
                .payAsYouChat,
                .shareContact,
                .callPermission,
                .acceptMsgRequest,
                .blockContact,
                .unblockContact,
            
                .cameraPermission,
                .missedCall,
                .setPwdSuccess,
                .changePwdSuccess,
                .linkBnsSuccess,
                .walletSync,
                .transactionIntiate,
                .transactionSuccess,
                .none:
                color = Colors.bothGreenColor
            case  .leaveGroup,
                .deleteMsgRequest,
                .blockUserRequest,
                .clearChat:
                color = Colors.bothRedColor
        }
        
        return color
    }
    
//    var cancelButtonBgColor: UIColor {
//        var color: UIColor
//        
//        switch self {
//            case .gifEnable,
//                .payAsYouChat,
//                .shareContact,
//                .callPermission,
//                .acceptMsgRequest,
//                .blockContact,
//                .unblockContact,
//                .cameraPermission,
//                .setPwdSuccess,
//                .changePwdSuccess,
//                .linkBnsSuccess,
//                .walletSync,
//                .transactionIntiate,
//                .transactionSuccess,
//                .leaveGroup,
//                .deleteMsgRequest,
//                .blockUserRequest,
//                .clearChat,
//                .none:
//                color = Colors.bothGreenWithAlpha10
//            case .missedCall:
//                    color = Colors.bothGreenColor
//        }
//        
//        return color
//    }
}
