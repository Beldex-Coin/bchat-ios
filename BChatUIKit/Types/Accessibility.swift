// Copyright © 2025 Beldex International Limited OU. All rights reserved.

import Foundation

public struct Accessibility: Hashable, Equatable {
    public let identifier: String?
    public let label: String?
    
    public init(
        identifier: String? = nil,
        label: String? = nil
    ) {
        self.identifier = identifier
        self.label = label
    }
}
