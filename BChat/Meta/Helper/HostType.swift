// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

enum HostType: Int, CaseIterable {
    
    /// indicate the `MAINNET` server.
    case MAINNET = 0
    
    /// indicate the `TESTNET`  server.
    case TESTNET
    
    // MARK: - Constatnt
    
    ///
    /// The default host type.
    ///
    static let `default`: HostType = .MAINNET
    
    // MARK: - Properties
    
    var hostValue: String {
        let akey: String
        switch self {
            case .MAINNET:
                akey = "MAINNET"
            case .TESTNET:
                akey = "TESTNET"
        }
        return akey
    }
}
