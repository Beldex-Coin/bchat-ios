// Copyright © 2026 Beldex International Limited OU. All rights reserved.

import Foundation


extension TSMessage {
    static func valueCountForTSQuotedMessage(for message: TSQuotedMessage?) -> Int {
        var count = 0
        if let body = message?.body, !body.isEmpty {
            count += 1
        }
        if let contentType = message?.contentType(), !contentType.isEmpty {
            count += 1
        }
        if let sourceFilename = message?.sourceFilename(), !sourceFilename.isEmpty {
            count += 1
        }
        if let thumbnailPointerId = message?.thumbnailAttachmentPointerId(), !thumbnailPointerId.isEmpty {
            count += 1
        }
        if let thumbnailStreamId = message?.thumbnailAttachmentStreamId(), !thumbnailStreamId.isEmpty {
            count += 1
        }
        let attachmentCount = message?.quotedAttachments.count
        if attachmentCount ?? 0 > 0 {
            count += attachmentCount ?? 0
        }
        return count
    }
}
