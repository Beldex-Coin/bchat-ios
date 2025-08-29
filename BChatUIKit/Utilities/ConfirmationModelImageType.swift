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
    case transactionInitiate
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
            case .transactionInitiate:
                name = ""
            case .transactionSuccess:
                name = ""
            default:
                name = ""
        }
        
        return name
    }
    
    var isShowImage: Bool {
        let isShow: Bool
        
        switch self {
            case .cameraPermission,
                .callPermission,
                .clearChat,
                .missedCall,
                .setPwdSuccess,
                .changePwdSuccess,
                .linkBnsSuccess,
                .walletSync,
                .transactionInitiate,
                .transactionSuccess:
                    isShow = true
            default:
                isShow = false
        }
        
        return isShow
    }
    
    var confirmationButtonBgColor: UIColor {
        var color: UIColor
        
        switch self {
            case .leaveGroup,
                .deleteMsgRequest,
                .blockUserRequest,
                .clearChat:
                color = Colors.bothRedColor
            default:
                color = Colors.bothGreenColor
        }
        
        return color
    }
}
