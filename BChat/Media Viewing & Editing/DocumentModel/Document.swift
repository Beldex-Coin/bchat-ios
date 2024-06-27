// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

struct Document: Codable {
    var contentType: String
    var originalFilePath: String
    var originalMediaURL: URL
    var createdTimeStamp: Date
    
    init(contentType: String, 
         originalFilePath: String,
         originalMediaURL: URL,
         createdTimeStamp: Date) {
        self.contentType = contentType
        self.originalFilePath = originalFilePath
        self.originalMediaURL = originalMediaURL
        self.createdTimeStamp = createdTimeStamp
    }
}
