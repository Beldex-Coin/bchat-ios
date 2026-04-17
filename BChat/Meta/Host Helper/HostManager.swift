// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

final class HostManager: NSObject {
        
    // MARK: - Instance
    
    /// The shared host manager instance.
    class var shared: HostManager {
        struct Singleton {
            static let instance = HostManager()
        }
        return Singleton.instance
    }
    
    /// Specifies the Host net for the API
    var hostNet: [String] {
        #if MAINNET
            return ["publicnode1.rpcnode.stream:29095", "publicnode2.rpcnode.stream:29095", "publicnode3.rpcnode.stream:29095", "publicnode4.rpcnode.stream:29095", "publicnode5.rpcnode.stream:29095"]
        #else
            return ["209.126.86.93:29091"]
        #endif
    }
    
    /// Specifies the Server key for the API
    var serverKey: String {
        #if MAINNET
            return "http://notification.rpcnode.stream"
        #else
            return "http://194.233.68.227:1900"
        #endif
    }
    
    /// Specifies the Server public key for the API
    var serverPublicKey: String {
        #if MAINNET
            return "54e8ce6a688f6decd414350408cae373ab6070d91d4512e17454d2470c7cf911"
        #else
            return "aea4fcf485fb267fa98c5f24b1848a6a865ea8769c2823ac385de051723b5954"
        #endif
    }
    
    ///  the environment Host Type for API
    var hostType: HostType {
        #if MAINNET
            return .MAINNET
        #else
            return .TESTNET
        #endif
    }
}



