
//import Foundation
//import BChatUIKit
//import PromiseKit
//import UIKit
//import BChatMessagingKit
//import SignalUtilitiesKit
//import BChatUtilitiesKit
//
//// MARK: - Constants
//
//let SNAudioDidFinishPlayingNotification = "SNAudioDidFinishPlayingNotification"
//
//// MARK: - Enum
//
//enum OWSMessageCellType: Int {
//    case unknown
//    case textOnlyMessage
//    case audio
//    case genericAttachment
//    case mediaMessage
//    case oversizeTextDownloading
//    case deletedMessage
//}
//
//func stringForOWSMessageCellType(_ cellType: OWSMessageCellType) -> String {
//    switch cellType {
//    case .textOnlyMessage:
//        return "OWSMessageCellType_TextOnlyMessage"
//    case .audio:
//        return "OWSMessageCellType_Audio"
//    case .genericAttachment:
//        return "OWSMessageCellType_GenericAttachment"
//    case .unknown:
//        return "OWSMessageCellType_Unknown"
//    case .mediaMessage:
//        return "OWSMessageCellType_MediaMessage"
//    case .oversizeTextDownloading:
//        return "OWSMessageCellType_OversizeTextDownloading"
//    case .deletedMessage:
//        return "OWSMessageCellType_DeletedMessage"
//    }
//}
//
//class ConversationMediaAlbumItem {
//    let attachment: TSAttachment
//    let attachmentStream: TSAttachmentStream?
//    let caption: String?
//    let mediaSize: CGSize
//
//    init(attachment: TSAttachment,
//         attachmentStream: TSAttachmentStream?,
//         caption: String?,
//         mediaSize: CGSize) {
//        self.attachment = attachment
//        self.attachmentStream = attachmentStream
//        self.caption = caption
//        self.mediaSize = mediaSize
//    }
//
//    var isFailedDownload: Bool {
//        guard let pointer = attachment as? TSAttachmentPointer else {
//            return false
//        }
//        return pointer.state == .failed
//    }
//}
//
//
//class ConversationInteractionViewItem: ConversationViewItem {
//    var interaction: TSInteraction
//    var quotedReply: OWSQuotedReplyModel?
//
//    var isGroupThread: Bool
//    var userCanDeleteGroupMessage: Bool = false
//    var userHasModerationPermission: Bool = false
//
//    var hasBodyText: Bool = false
//    var isQuotedReply: Bool = false
//    var hasQuotedAttachment: Bool = false
//    var hasQuotedText: Bool = false
//    var hasCellHeader: Bool = false
//    var isExpiringMessage: Bool = false
//
//    var shouldShowDate: Bool = false
//    var shouldShowSenderProfilePicture: Bool = false
//    var senderName: NSAttributedString?
//    var shouldHideFooter: Bool = false
//    var isFirstInCluster: Bool = false
//    var isOnlyMessageInCluster: Bool = false
//    var isLastInCluster: Bool = false
//    var wasPreviousItemInfoMessage: Bool = false
//
//    var unreadIndicator: OWSUnreadIndicator?
//    var lastAudioMessageView: VoiceMessageView?
//
//    var audioDurationSeconds: CGFloat = 0
//    var audioProgressSeconds: CGFloat = 0
//
//    var messageCellType: OWSMessageCellType = .unknown
//    var displayableBodyText: DisplayableText?
//    var displayableQuotedText: DisplayableText?
//    var attachmentStream: TSAttachmentStream?
//    var attachmentPointer: TSAttachmentPointer?
//    var mediaAlbumItems: [ConversationMediaAlbumItem]?
////    var contactShare: ContactShareViewModel?
//    var linkPreview: OWSLinkPreview?
//    var linkPreviewAttachment: TSAttachment?
//    var systemMessageText: String?
//    var authorConversationColorName: String?
//
//    var didCellMediaFailToLoad: Bool = false
//
//    private var hasViewState = false
//    private var cachedCellSize: CGSize?
//
//    init(interaction: TSInteraction, isGroupThread: Bool, transaction: YapDatabaseReadTransaction) {
//        self.interaction = interaction
//        self.isGroupThread = isGroupThread
//        ensureViewState(transaction)
//    }
//
//    func replaceInteraction(_ interaction: TSInteraction, transaction: YapDatabaseReadTransaction) {
//        self.interaction = interaction
//
//        hasViewState = false
//        messageCellType = .unknown
//        displayableBodyText = nil
//        attachmentStream = nil
//        attachmentPointer = nil
//        mediaAlbumItems = nil
//        displayableQuotedText = nil
//        quotedReply = nil
////        contactShare = nil
//        systemMessageText = nil
//        authorConversationColorName = nil
//        linkPreview = nil
//        linkPreviewAttachment = nil
//
//        clearCachedLayoutState()
//        ensureViewState(transaction)
//    }
//
//    func ensureViewState(_ transaction: YapDatabaseReadTransaction) {
//        // This should be implemented with whatever state setup logic is required
//        hasViewState = true
//    }
//
//    func clearCachedLayoutState() {
//        cachedCellSize = nil
//    }
//
//    var hasCachedLayoutState: Bool {
//        return cachedCellSize != nil
//    }
//
//    func copyMediaAction() {}
//    func copyTextAction() {}
//    func saveMediaAction() {}
//    func deleteLocallyAction() {}
//    func deleteRemotelyAction() {}
//    func deleteAction() {}
//
//    func canCopyMedia() -> Bool { false }
//    func canSaveMedia() -> Bool { false }
//
//    func itemId() -> String {
//        // Replace with actual interaction ID if available
//        return UUID().uuidString
//    }
//
//    func firstValidAlbumAttachment() -> TSAttachmentStream? {
//        return mediaAlbumItems?.first(where: { $0.attachmentStream != nil })?.attachmentStream
//    }
//
//    func mediaAlbumHasFailedAttachment() -> Bool {
//        return mediaAlbumItems?.contains(where: { $0.isFailedDownload }) ?? false
//    }
//}










//let SNAudioDidFinishPlayingNotification = "SNAudioDidFinishPlayingNotification"
//
//// MARK: - Enums
//
//enum OWSMessageCellType: Int {
//    case unknown
//    case textOnlyMessage
//    case audio
//    case genericAttachment
//    case mediaMessage
//    case oversizeTextDownloading
//    case deletedMessage
//}
//
//func stringForOWSMessageCellType(_ cellType: OWSMessageCellType) -> String {
//    // You can implement the string representation here
//    return "\(cellType)"
//}
//
//// MARK: - Models
//
//class ConversationMediaAlbumItem {
//    let attachment: TSAttachment
//    let attachmentStream: TSAttachmentStream?
//    let mediaSize: CGSize
//    let caption: String?
//    let isFailedDownload: Bool
//
//    init(
//        attachment: TSAttachment,
//        attachmentStream: TSAttachmentStream?,
//        mediaSize: CGSize,
//        caption: String?,
//        isFailedDownload: Bool
//    ) {
//        self.attachment = attachment
//        self.attachmentStream = attachmentStream
//        self.mediaSize = mediaSize
//        self.caption = caption
//        self.isFailedDownload = isFailedDownload
//    }
//}
//
//// MARK: - Protocol
//
//protocol ConversationViewItem: OWSAudioPlayerDelegate {
//    var interaction: TSInteraction { get }
//    var quotedReply: OWSQuotedReplyModel? { get }
//
//    var isGroupThread: Bool { get }
//    var userCanDeleteGroupMessage: Bool { get }
//    var userHasModerationPermission: Bool { get }
//
//    var hasBodyText: Bool { get }
//
//    var isQuotedReply: Bool { get }
//    var hasQuotedAttachment: Bool { get }
//    var hasQuotedText: Bool { get }
//    var hasCellHeader: Bool { get }
//
//    var isExpiringMessage: Bool { get }
//
//    var shouldShowDate: Bool { get set }
//    var shouldShowSenderProfilePicture: Bool { get set }
//    var senderName: NSAttributedString? { get set }
//    var shouldHideFooter: Bool { get set }
//    var isFirstInCluster: Bool { get set }
//    var isOnlyMessageInCluster: Bool { get set }
//    var isLastInCluster: Bool { get set }
//    var wasPreviousItemInfoMessage: Bool { get set }
//
//    var unreadIndicator: OWSUnreadIndicator? { get set }
//
//    func replaceInteraction(_ interaction: TSInteraction, transaction: YapDatabaseReadTransaction)
//    func clearCachedLayoutState()
//    var hasCachedLayoutState: Bool { get }
//
//    // MARK: - Audio Playback
//
//    var lastAudioMessageView: VoiceMessageView? { get set }
//    var audioDurationSeconds: CGFloat { get }
//    var audioProgressSeconds: CGFloat { get }
//
//    // MARK: - View State Caching
//
//    var messageCellType: OWSMessageCellType { get }
//    var displayableBodyText: DisplayableText? { get }
//    var attachmentStream: TSAttachmentStream? { get }
//    var attachmentPointer: TSAttachmentPointer? { get }
//    var mediaAlbumItems: [ConversationMediaAlbumItem]? { get }
//
//    var displayableQuotedText: DisplayableText? { get }
//    var quotedAttachmentMimetype: String? { get }
//    var quotedRecipientId: String? { get }
//
//    var didCellMediaFailToLoad: Bool { get set }
//
//    var contactShare: ContactShareViewModel? { get }
//
//    var linkPreview: OWSLinkPreview? { get }
//    var linkPreviewAttachment: TSAttachment? { get }
//
//    var systemMessageText: String? { get }
//
//    var authorConversationColorName: String? { get }
//
//    // MARK: - Message Actions
//
//    var hasBodyTextActionContent: Bool { get }
//    var hasMediaActionContent: Bool { get }
//
//    func copyMediaAction()
//    func copyTextAction()
//    func saveMediaAction()
//    func deleteLocallyAction()
//    func deleteRemotelyAction()
//
//    func deleteAction()
//
//    func canCopyMedia() -> Bool
//    func canSaveMedia() -> Bool
//
//    func itemId() -> String
//    func firstValidAlbumAttachment() -> TSAttachmentStream?
//    func mediaAlbumHasFailedAttachment() -> Bool
//}
//
//// MARK: - Class
//
//class ConversationInteractionViewItem: ConversationViewItem {
//    let interaction: TSInteraction
//    let quotedReply: OWSQuotedReplyModel?
//
//    var isGroupThread: Bool
//    var userCanDeleteGroupMessage: Bool
//    var userHasModerationPermission: Bool
//
//    var hasBodyText: Bool
//    var isQuotedReply: Bool
//    var hasQuotedAttachment: Bool
//    var hasQuotedText: Bool
//    var hasCellHeader: Bool
//    var isExpiringMessage: Bool
//
//    var shouldShowDate: Bool = false
//    var shouldShowSenderProfilePicture: Bool = false
//    var senderName: NSAttributedString?
//    var shouldHideFooter: Bool = false
//    var isFirstInCluster: Bool = false
//    var isOnlyMessageInCluster: Bool = false
//    var isLastInCluster: Bool = false
//    var wasPreviousItemInfoMessage: Bool = false
//
//    var unreadIndicator: OWSUnreadIndicator?
//
//    var lastAudioMessageView: VoiceMessageView?
//
//    var audioDurationSeconds: CGFloat { 0 }
//    var audioProgressSeconds: CGFloat { 0 }
//
//    var messageCellType: OWSMessageCellType { .unknown }
//    var displayableBodyText: DisplayableText? { nil }
//    var attachmentStream: TSAttachmentStream? { nil }
//    var attachmentPointer: TSAttachmentPointer? { nil }
//    var mediaAlbumItems: [ConversationMediaAlbumItem]? { nil }
//
//    var displayableQuotedText: DisplayableText? { nil }
//    var quotedAttachmentMimetype: String? { nil }
//    var quotedRecipientId: String? { nil }
//
//    var didCellMediaFailToLoad: Bool = false
//
//    var contactShare: ContactShareViewModel? { nil }
//
//    var linkPreview: OWSLinkPreview? { nil }
//    var linkPreviewAttachment: TSAttachment? { nil }
//
//    var systemMessageText: String? { nil }
//
//    var authorConversationColorName: String? { nil }
//
//    var hasBodyTextActionContent: Bool { false }
//    var hasMediaActionContent: Bool { false }
//
//    init(interaction: TSInteraction, isGroupThread: Bool, transaction: YapDatabaseReadTransaction) {
//        self.interaction = interaction
//        self.isGroupThread = isGroupThread
//        self.quotedReply = nil
//        self.userCanDeleteGroupMessage = false
//        self.userHasModerationPermission = false
//        self.hasBodyText = false
//        self.isQuotedReply = false
//        self.hasQuotedAttachment = false
//        self.hasQuotedText = false
//        self.hasCellHeader = false
//        self.isExpiringMessage = false
//    }
//
//    func replaceInteraction(_ interaction: TSInteraction, transaction: YapDatabaseReadTransaction) {}
//    func clearCachedLayoutState() {}
//    var hasCachedLayoutState: Bool { false }
//
//    func copyMediaAction() {}
//    func copyTextAction() {}
//    func saveMediaAction() {}
//    func deleteLocallyAction() {}
//    func deleteRemotelyAction() {}
//    func deleteAction() {}
//
//    func canCopyMedia() -> Bool { false }
//    func canSaveMedia() -> Bool { false }
//
//    func itemId() -> String { UUID().uuidString }
//    func firstValidAlbumAttachment() -> TSAttachmentStream? { nil }
//    func mediaAlbumHasFailedAttachment() -> Bool { false }
//}
