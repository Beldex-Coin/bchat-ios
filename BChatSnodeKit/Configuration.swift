
public struct SNSnodeKitConfiguration {
    public let storage: BChatSnodeKitStorageProtocol

    internal static var shared: SNSnodeKitConfiguration!
}

public enum SNSnodeKit { // Just to make the external API nice

    public static func configure(storage: BChatSnodeKitStorageProtocol) {
        SNSnodeKitConfiguration.shared = SNSnodeKitConfiguration(storage: storage)
    }
}
