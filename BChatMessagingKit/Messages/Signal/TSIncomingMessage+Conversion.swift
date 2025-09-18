
public extension TSIncomingMessage {

    static func from(_ visibleMessage: VisibleMessage, quotedMessage: TSQuotedMessage?, linkPreview: OWSLinkPreview?, associatedWith thread: TSThread) -> TSIncomingMessage {
        let sender = visibleMessage.sender!
        var expiration: UInt32 = 0
        Storage.read { transaction in
            expiration = thread.disappearingMessagesDuration(with: transaction)
        }
        let openGroupServerMessageID = visibleMessage.openGroupServerMessageID ?? 0
        let isOpenGroupMessage = (openGroupServerMessageID != 0)
        
        let quotedMessageFromReceiver = quotedMessage
        let quotedMessageFromVisibleMessage = TSQuotedMessage.from(visibleMessage.quote)
        
        let countOfQuotedMessageFromReceiver = valueCount(for: quotedMessageFromReceiver)
        let countOfQuotedMessageFromVisibleMessage = valueCount(for: quotedMessageFromVisibleMessage)
        
        let result = TSIncomingMessage(
            timestamp: visibleMessage.sentTimestamp!,
            in: thread,
            authorId: sender,
            sourceDeviceId: 1,
            messageBody: visibleMessage.text,
            attachmentIds: visibleMessage.attachmentIDs,
            expiresInSeconds: !isOpenGroupMessage ? expiration : 0, // Ensure we don't ever expire open group messages
            quotedMessage: countOfQuotedMessageFromReceiver > countOfQuotedMessageFromVisibleMessage ? quotedMessageFromReceiver : quotedMessageFromVisibleMessage,
            linkPreview: linkPreview,
            wasReceivedByUD: true,
            openGroupInvitationName: visibleMessage.openGroupInvitation?.name,
            openGroupInvitationURL: visibleMessage.openGroupInvitation?.url,
            serverHash: visibleMessage.serverHash,
            paymentTxnid: visibleMessage.payment?.txnId,
            paymentAmount: visibleMessage.payment?.amount,
            sharedContactMessage: SharedContactMessage.from(visibleMessage.sharedContact)
        )
        result.openGroupServerMessageID = openGroupServerMessageID
        return result
    }
    
    static func valueCount(for message: TSQuotedMessage?) -> Int {
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
