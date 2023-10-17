
import Foundation


class WalletSharedData {
    
    var wallet: BDXWallet?
    
    var isCleardataStarting = false
    
    static let sharedInstance: WalletSharedData = {
        let instance = WalletSharedData()
        return instance
    }()
    
}
