// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation


extension SharedContactMessage {

    /// To be used for outgoing messages only.
    public static func from(_ sharedContact: VisibleMessage.SharedContact?) -> SharedContactMessage? {
        guard let contact = sharedContact else { return nil }
        return SharedContactMessage(address: contact.address ?? "", name: contact.name ?? "")
    }
}

extension VisibleMessage.SharedContact {
    
    public static func from(_ sharedContact: SharedContactMessage?) -> VisibleMessage.SharedContact? {
        guard let contact = sharedContact else { return nil }
        let result = VisibleMessage.SharedContact()
        result.address = contact.address
        result.name = contact.name
        return result
    }
}
