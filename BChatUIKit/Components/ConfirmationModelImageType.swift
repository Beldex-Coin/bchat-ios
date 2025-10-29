// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit

// Top level confirmation modal image type, color for popup
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
    case switchNode
    case refreshNodes
    
    case cameraPermission
    case callPermission
    case clearChat
    case missedCall
    case ownSeedWarning
    case mediaDownload
    case pwdUpdateSuccess
    case linkBnsSuccess
    case walletSync
    case initiateTransaction
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
            case .ownSeedWarning:
                name = "ic_warningSeed"
            case .mediaDownload:
                name = isLightMode ? "ic_download_white" : "ic_download_dark"
            case .pwdUpdateSuccess:
                    name = "ic_pinSuccess"
            case .linkBnsSuccess:
                name = ""
            case .walletSync:
                name = ""
            case .initiateTransaction:
                name = "ic_initiating_transaction"
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
                .ownSeedWarning,
                .mediaDownload,
                .pwdUpdateSuccess,
                .linkBnsSuccess,
                .walletSync,
                .initiateTransaction,
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
