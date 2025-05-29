// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

// Top level confirmation modal image type for popup
public enum ConfirmationModalImageType: Int {

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
        case .none:
            name = ""
        }
        
        return name
    }
}
