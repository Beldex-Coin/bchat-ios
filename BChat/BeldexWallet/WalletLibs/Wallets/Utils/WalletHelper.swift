
import Foundation


class WalletSharedData {
    
    var wallet: BDXWallet?
    
    static let sharedInstance: WalletSharedData = {
        let instance = WalletSharedData()
        return instance
    }()
    
}
