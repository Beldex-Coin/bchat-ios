// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

@objc(BCSharedContactMessage)
public final class SharedContactMessage : MTLModel {
    
    @objc
    public var address: String?
    
    @objc
    public var name: String?
    
    @objc
    public init(address: String, name: String) {
        self.address = address
        self.name = name
        super.init()
    }
    
    @objc
    public override init() {
        super.init()
    }

    @objc
    public required init!(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc
    public required init(dictionary dictionaryValue: [String: Any]!) throws {
        try super.init(dictionary: dictionaryValue)
    }
    
    @objc
    public override func isEqual(_ object: Any!) -> Bool {
        guard let other = object as? SharedContactMessage else { return false }
        return other.address == self.address && other.name == self.name
     }
}
