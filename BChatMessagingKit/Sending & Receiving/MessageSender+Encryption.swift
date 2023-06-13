import BChatUtilitiesKit
import Sodium

extension MessageSender {
    
    internal static func encryptWithSessionProtocol(_ plaintext: Data, for recipientHexEncodedX25519PublicKey: String) throws -> Data {
        let beldexAddres = UserDefaults.standard.string(forKey: "WalletpublicAddress")
        let senderBeldexAddress = Data(beldexAddres!.utf8)
        let plaintextWithBeldexAddress = senderBeldexAddress + plaintext
        guard let userED25519KeyPair = SNMessagingKitConfiguration.shared.storage.getUserED25519KeyPair() else { throw Error.noUserED25519KeyPair }
        let recipientX25519PublicKey = Data(hex: recipientHexEncodedX25519PublicKey.removing05PrefixIfNeeded())
        let sodium = Sodium()
        
        let verificationData = plaintextWithBeldexAddress + Data(userED25519KeyPair.publicKey) + recipientX25519PublicKey
        guard let signature = sodium.sign.signature(message: Bytes(verificationData), secretKey: userED25519KeyPair.secretKey) else { throw Error.signingFailed }
        let plaintextWithMetadata = plaintextWithBeldexAddress + Data(userED25519KeyPair.publicKey) + Data(signature)
        guard let ciphertext = sodium.box.seal(message: Bytes(plaintextWithMetadata), recipientPublicKey: Bytes(recipientX25519PublicKey)) else { throw Error.encryptionFailed }
        return Data(ciphertext)
    }
}
