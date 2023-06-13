import Curve25519Kit

public extension ECKeyPair {
    
    @objc var hexEncodedPrivateKey: String {
        return privateKey.map { String(format: "%02hhx", $0) }.joined()
    }
    
    @objc var hexEncodedPublicKey: String {
        // Prefixing with "bd" is necessary for what seems to be a sort of Signal public key versioning system
        return "bd" + publicKey.map { String(format: "%02hhx", $0) }.joined()
    }
    
    @objc static func isValidHexEncodedPublicKey(candidate: String) -> Bool {
        // Check that it's a valid hexadecimal encoding
        guard Hex.isValid(candidate) else { return false }
        // Check that it has length 66 and a leading "bd"
        guard candidate.count == 66 && candidate.hasPrefix("bd") else { return false }
        // It appears to be a valid public key
        return true
    }
}
