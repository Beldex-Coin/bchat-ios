// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

extension UserDefaults {
    
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
    
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
