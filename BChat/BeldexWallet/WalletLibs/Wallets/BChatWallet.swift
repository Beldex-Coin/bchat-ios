//
//  BChatWallet.swift
//

import Foundation

public enum BDXWalletError: Error {
    case noWalletName
    case noSeed
    
    case createFailed
    case openFailed
}


private func bdx_path(with name: String) -> String {
    let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentDirectory = allPaths[0]
    let documentPath = documentDirectory + "/"
    let pathWithFileName = documentPath + name
    print("### WALLET LOCATION: \(pathWithFileName)")
    return pathWithFileName
}



public class BDXWallet {
    
    // MARK: - Properties (public)
    
    public let walletName: String
    
    
    // MARK: - Properties (private)
    
    private let language: String
    private let walletWrapper: BChatWalletWrapper
    
//    private let safeQueue: DispatchQueue
    
    private var isClosing = false
    private var isSaving = false
    private var isClosed = false
    
    private var needSaveOnTerminate = false
    
    private var didEnterBackground: NSObjectProtocol?
    private var willTerminate: NSObjectProtocol?
    
    
    // MARK: - Life Cycles
    
    public init(walletWrapper: BChatWalletWrapper) {
        self.language = "English"
        self.walletWrapper = walletWrapper
        self.walletName = walletWrapper.name
    }
    
    public func connectToDaemon(address: String) -> Bool {
        return walletWrapper.connect(toDaemon: address)
    }
    
    public func connectToDaemon(address: String,result: @escaping (Bool) -> Void) {
        result(self.walletWrapper.connect(toDaemon: address))
    }
}

extension BDXWallet {

    public var publicAddress: String {
        return walletWrapper.publicAddress
    }

    public var seed: Seed? {
        let sentence = walletWrapper.getSeedString(language)
        return Seed(sentence: sentence!)
    }
    public var publicViewKey: String {
        return walletWrapper.publicViewKey
    }

    
    
//    public var publicAddress: String {
//            return walletWrapper.publicAddress
//        }
//
//        public var seed: Seed? {
//            let sentence = walletWrapper.getSeedString(language)
//            return Seed(sentence: sentence!)
//        }
//        public var publicViewKey: String {
//            return walletWrapper.publicViewKey
//        }
//        public var publicSpendKey: String {
//            return walletWrapper.publicSpendKey
//        }
//        public var secretViewKey: String {
//            return walletWrapper.secretViewKey
//        }
//        public var secretSpendKey: String {
//            return walletWrapper.secretSpendKey
//        }
//        public var balance: String {
//            return displayAmount(walletWrapper.balance)
//        }
//        public func displayAmount(_ value: UInt64) -> String {
//            return BeldexWalletWrapper.displayAmount(value)
//        }
    
    
}
