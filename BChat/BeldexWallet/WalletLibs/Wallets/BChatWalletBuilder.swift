//
//  BChatWalletBuilder.swift
//

import Foundation

public struct BDXWalletBuilder {
    
    // MARK: - Properties (private)
    
    private var language: String
    private var name: String
    private var password: String
    private var mode: Mode?
    
    
    // MARK: - Life Cycles
    
    init(name: String, password: String) {
        self.language = "English"
        self.name = name
        self.password = password
    }
    
    public func fromScratch() -> BDXWalletBuilder {
        var builder = self
        builder.mode = .fromScratch
        return builder
    }
    
    public func fromSeed(_ seed: Seed) -> BDXWalletBuilder {
        var builder = self
        builder.mode = .fromSeed(seed: seed)
        print("builder.mode ----> \(seed)")
        return builder
    }

    func generate() -> BDXWallet? {
        var wrapper: BChatWalletWrapper?
        if let mode = self.mode {
            switch mode {
            case .fromScratch:
                wrapper = self.createWalletFromScratch()
            case .fromSeed(let seed):
                print("------ inside case ----->")
                wrapper = self.recoverWalletFromSeed(seed)
            }
        }
        guard let result = wrapper else {
            return nil
            
        }
        return BDXWallet(walletWrapper: result)
    }
    
    // MARK: - Methods (private)

    func createWalletFromScratch() -> BChatWalletWrapper? {
        return BChatWalletWrapper.generate(withPath: pathWithFileName(), password: password, language: language)
    }
    private func recoverWalletFromSeed(_ seed: Seed) -> BChatWalletWrapper? {
        return BChatWalletWrapper.recover(withSeed: seed.sentence, path: pathWithFileName(), password: password)
    }

    private func pathWithFileName() -> String {
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = allPaths[0]
        let documentPath = documentDirectory + "/"
        let pathWithFileName = documentPath + self.name
        return pathWithFileName
    }
}

extension BDXWalletBuilder {
    private enum Mode {
        case fromScratch
        case fromSeed(seed: Seed)
    }
}
