// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

struct Document: Codable {
    var contentType: String
    var originalFilePath: String
    var originalMediaUrl: String
    var createdTimeStamp: Date
    var documentId: String
    
    init(contentType: String, 
         originalFilePath: String,
         originalMediaURL: String,
         createdTimeStamp: Date,
         documentId: String) {
        self.contentType = contentType
        self.originalFilePath = originalFilePath
        self.originalMediaUrl = originalMediaURL
        self.createdTimeStamp = createdTimeStamp
        self.documentId = documentId
    }
}
