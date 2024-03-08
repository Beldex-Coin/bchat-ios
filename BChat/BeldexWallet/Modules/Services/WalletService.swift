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
    lazy var walletActiveState = { Observable<Int?>(nil) }()
    lazy var assetRefreshState = { Observable<Int?>(nil) }()
    
    // MARK: - Methods (Public)
    public static func validAddress(_ addr: String, symbol: String) -> Bool {
        if symbol == "BDX" {
            return BChatWalletWrapper.validAddress(addr)
        }
        return false
    }
    public func verifyPassword(_ name: String, password: String) -> Bool {
        return BDXWalletBuilder(name: name, password: password).isValidatePassword()
    }
    
    public func createWallet(with style: CreateWalletStyle, result: GetWalletHandler?) {
        var result_wallet: BDXWallet!
        switch style {
        case .new(let data):
            result_wallet = BDXWalletBuilder(name: data.name, password: data.pwd).fromScratch().generate()
            if result_wallet != nil {
                let WalletSeed = result_wallet.seed!
                SaveUserDefaultsData.WalletpublicAddress = result_wallet.publicAddress
                SaveUserDefaultsData.WalletSeed = WalletSeed.sentence
                SaveUserDefaultsData.WalletName = result_wallet.walletName
                SaveUserDefaultsData.WalletRestoreHeight = String(result_wallet.restoreHeight)
//                result_wallet.close()
            }else {
                result_wallet = BDXWalletBuilder(name: data.name, password: data.pwd).openExisting()
                if result_wallet != nil {
                    let WalletSeed = result_wallet.seed!
                    SaveUserDefaultsData.WalletpublicAddress = result_wallet.publicAddress
                    SaveUserDefaultsData.WalletSeed = WalletSeed.sentence
                    SaveUserDefaultsData.WalletName = result_wallet.walletName
                    SaveUserDefaultsData.WalletRestoreHeight = String(result_wallet.restoreHeight)
                    result_wallet.close()
                }
            }
        case .recovery(let data, let recover):
            switch recover.from {
            case .seed:
                let seedvaluedefault = SaveUserDefaultsData.WalletRecoverSeed as String?
                if let seedStr = seedvaluedefault, let seed = Seed.init(sentence: seedStr) {
                    result_wallet = BDXWalletBuilder(name: data.name, password: data.pwd).fromSeed(seed).generate()
                    if result_wallet != nil {
                        let WalletSeed = result_wallet.seed!
                        SaveUserDefaultsData.WalletpublicAddress = result_wallet.publicAddress
                        SaveUserDefaultsData.WalletSeed = WalletSeed.sentence
                        SaveUserDefaultsData.WalletName = result_wallet.walletName
//                        result_wallet.close()
                    } else {
                        result_wallet = BDXWalletBuilder(name: data.name, password: data.pwd).openExisting()
                        if result_wallet != nil {
                            let WalletSeed = result_wallet.seed!
                            SaveUserDefaultsData.WalletpublicAddress = result_wallet.publicAddress
                            SaveUserDefaultsData.WalletSeed = WalletSeed.sentence
                            SaveUserDefaultsData.WalletName = result_wallet.walletName
                            result_wallet.close()
                        }
                    }
                }
                if let seedStr = recover.seed, let seed = Seed.init(sentence: seedStr) {
                    result_wallet = BDXWalletBuilder(name: data.name, password: data.pwd).fromSeed(seed).generate()
                    if result_wallet != nil {
                        let WalletSeed = result_wallet.seed!
                        SaveUserDefaultsData.WalletpublicAddress = result_wallet.publicAddress
                        SaveUserDefaultsData.WalletSeed = WalletSeed.sentence
                        SaveUserDefaultsData.WalletName = result_wallet.walletName
                        result_wallet.close()
                    }
                }
            case .keys:
                print("case Keys")
            }
        }
    }
    
    public func openWallet(_ name: String, password: String, result: GetWalletHandler?) {
        DispatchQueuePool.shared["BDXWallet:" + name].async {
            if let wallet = BDXWalletBuilder(name: name, password: password).openExisting() {
                result?(.success(wallet))
            } else {
                result?(.failure(.openFailed))
            }
        }
    }
    
}
