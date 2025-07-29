// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import BChatUtilitiesKit

public extension VisibleMessage {

    @objc(BCSharedContact)
    class SharedContact: NSObject, NSCoding {
        public var threadId: String?
        public var address: String?
        public var name: String?

        public init(threadId: String? = nil, address: String? = nil, name: String? = nil) {
            self.threadId = threadId
            self.address = address
            self.name = name
        }

        public required init?(coder: NSCoder) {
            if let threadId = coder.decodeObject(forKey: "threadId") as! String? { self.threadId = threadId }
            if let address = coder.decodeObject(forKey: "address") as! String? { self.address = address }
            if let name = coder.decodeObject(forKey: "name") as! String? { self.name = name }
        }

        public func encode(with coder: NSCoder) {
            coder.encode(threadId, forKey: "threadId")
            coder.encode(address, forKey: "address")
            coder.encode(name, forKey: "name")
        }

        public static func fromProto(_ proto: SNProtoDataMessage) -> SharedContact? {
            guard let shareContactProto = proto.sharedContact else { return nil }
            guard let threadID = shareContactProto.threadID, let address = shareContactProto.address, let name = shareContactProto.name else { return nil }
            return SharedContact(threadId: threadID, address: address, name: name)
        }

        public func toProto() -> SNProtoDataMessageSharedContact? {
            guard let threadId = threadId, let address = address, let name = name else {
                SNLog("Couldn't construct share contact proto from: \(self).")
                return nil
            }
            let dataMessageProto = SNProtoDataMessage.builder()
            let shareContactProto = SNProtoDataMessageSharedContact.builder()
            shareContactProto.setThreadID(threadId)
            shareContactProto.setAddress(address)
            shareContactProto.setName(name)
            
            do {
                dataMessageProto.setSharedContact(try shareContactProto.build())
                return try shareContactProto.build()
            } catch {
                SNLog("Couldn't construct share contact proto from: \(self).")
                return nil
            }
        }
        
        // MARK: - Description
        
        public override var description: String {
            """
            SharedContact(
                                threadId: \(threadId ?? "null"),
                                address: \(address ?? "null"),
                                name: \(name ?? "null")
            )
            """
        }
    }
}
