//
//  WalletService.swift


import Foundation

public enum WalletError: Error {
    case noWalletName
    case noSeed
    case createFailed
    case openFailed
}

class WalletService {
    
    typealias GetWalletHandler = (Result<BDXWallet, WalletError>) -> Void
    
    // MARK: - Properties (static)
    
    static let shared = { WalletService() }()
    
    public func createWallet(with style: CreateWalletStyle, result: GetWalletHandler?) {
        var result_wallet: BDXWallet!
        switch style {
        case .new(let data):
            result_wallet = BDXWalletBuilder(name: data.name, password: data.pwd).fromScratch().generate()
            
            if result_wallet != nil {
                let WalletSeed = result_wallet.seed!
                UserDefaultsData.WalletpublicAddress = result_wallet.publicAddress
                UserDefaultsData.WalletSeed = WalletSeed.sentence
            }else {
                
            }
        case .recovery(let data, let recover):
            switch recover.from {
            case .seed:
                let seedvaluedefault = UserDefaultsData.WalletRecoverSeed
                if let seed = Seed.init(sentence: seedvaluedefault) {
                    
                    result_wallet = BDXWalletBuilder(name: data.name, password: data.pwd).fromSeed(seed).generate()
                    
                    if result_wallet != nil {
                        let WalletSeed = result_wallet.seed!
                        UserDefaultsData.WalletpublicAddress = result_wallet.publicAddress
                        UserDefaultsData.WalletSeed = WalletSeed.sentence
                    }else {
                        
                    }
                }
            case .keys:
                print("case Keys")
                
            }
        }
    }
}
