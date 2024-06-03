// Copyright © 2023 Vee4 Pty Ltd. All rights reserved.

import Foundation

struct RecipientDomainSchema: Codable {
    var localhash: String
    var localaddress: String
    init(localhash: String, localaddress: String) {
        self.localhash = localhash
        self.localaddress = localaddress
    }
}
