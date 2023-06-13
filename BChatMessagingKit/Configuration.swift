
@objc
public final class SNMessagingKitConfiguration : NSObject {
    public let storage: BChatMessagingKitStorageProtocol

    @objc public static var shared: SNMessagingKitConfiguration!

    fileprivate init(storage: BChatMessagingKitStorageProtocol) {
        self.storage = storage
    }
}

public enum SNMessagingKit { // Just to make the external API nice

    public static func configure(storage: BChatMessagingKitStorageProtocol) {
        SNMessagingKitConfiguration.shared = SNMessagingKitConfiguration(storage: storage)
    }
}
