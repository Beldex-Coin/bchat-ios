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

extension UserDefaults {
    var domainSchemas: [RecipientDomainSchema] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "RecipientDomainSchema") else { return [] }
            return (try? PropertyListDecoder().decode([RecipientDomainSchema].self, from: data)) ?? []
        }
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: "RecipientDomainSchema")
        }
    }
}
