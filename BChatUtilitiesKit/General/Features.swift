
@objc(SNFeatures)
public final class Features : NSObject {
    
    /// Specifies the useOnionRequests for the API
    public static let useOnionRequests = true
    
    /// Specifies the Server public key for the API
    public static var isTestNet: Bool {
        #if TESTNET
            return true
        #else
            return false
        #endif
    }
}
