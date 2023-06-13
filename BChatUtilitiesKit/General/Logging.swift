import SignalCoreKit

public func SNLog(_ message: String) {
    #if DEBUG
    print("[BChat] \(message)")
    #endif
    OWSLogger.info("[BChat] \(message)")
}
