// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation
import UIKit

// Top level confirmation modal image type for popup
public enum ConfirmationModalType: Int {
    
    case gifEnable
    case payAsYouChat
    case leaveGroup
    case shareContact
    
    case cameraPermission
    case callPermission
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
            case .gifEnable, .payAsYouChat, .leaveGroup, .shareContact, .none:
                name = ""
        }
        
        return name
    }
    
    var isShowImage: Bool {
        let isShow: Bool
        
        switch self {
            case .gifEnable, .payAsYouChat, .leaveGroup, .shareContact, .none:
                    isShow = false
            case .cameraPermission,
                .callPermission,
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
            case .gifEnable, .payAsYouChat, .shareContact, .callPermission, .none:
                color = Colors.bothGreenColor
            case  .leaveGroup:
                color = Colors.bothRedColor
            case .cameraPermission,
                    .setPwdSuccess,
                    .changePwdSuccess,
                    .linkBnsSuccess,
                    .walletSync,
                    .transactionIntiate,
                    .transactionSuccess:
            // TODO: Set color
                color = .clear
        }
        
        return color
    }
}
