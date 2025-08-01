
import Foundation
import BChatUIKit
import PromiseKit
import UIKit
import BChatMessagingKit
import SignalUtilitiesKit
import BChatUtilitiesKit
import Photos



// MARK: - Notification

let SNAudioDidFinishPlayingNotification = Notification.Name("SNAudioDidFinishPlayingNotification")

// MARK: - Enum

@objc enum OWSMessageCellType: Int {
    case unknown
    case textOnlyMessage
    case audio
    case genericAttachment
    case mediaMessage
    case oversizeTextDownloading
    case deletedMessage
}

func string(for cellType: OWSMessageCellType) -> String {
    switch cellType {
    case .textOnlyMessage:
        return "OWSMessageCellType_TextOnlyMessage"
    case .audio:
        return "OWSMessageCellType_Audio"
    case .genericAttachment:
        return "OWSMessageCellType_GenericAttachment"
    case .unknown:
        return "OWSMessageCellType_Unknown"
    case .mediaMessage:
        return "OWSMessageCellType_MediaMessage"
    case .oversizeTextDownloading:
        return "OWSMessageCellType_OversizeTextDownloading"
    case .deletedMessage:
        return "OWSMessageCellType_DeletedMessage"
    }
}

// MARK: - ConversationMediaAlbumItem

@objc class ConversationMediaAlbumItem: NSObject {
    let attachment: TSAttachment
    let attachmentStream: TSAttachmentStream?
    let caption: String?
    let mediaSize: CGSize

    init(
        attachment: TSAttachment,
        attachmentStream: TSAttachmentStream?,
        caption: String?,
        mediaSize: CGSize
    ) {
        self.attachment = attachment
        self.attachmentStream = attachmentStream
        self.caption = caption
        self.mediaSize = mediaSize
    }

    var isFailedDownload: Bool {
        guard let pointer = attachment as? TSAttachmentPointer else { return false }
        return pointer.state == .failed
    }
}

// MARK: - ConversationViewItem Protocol

@objc protocol ConversationViewItem: OWSAudioPlayerDelegate, NSObjectProtocol {
   @objc var interaction: TSInteraction { get }
    var quotedReply: OWSQuotedReplyModel? { get }

    var isGroupThread: Bool { get }
    var userCanDeleteGroupMessage: Bool { get }
    var userHasModerationPermission: Bool { get }

    var hasBodyText: Bool { get }

    var isQuotedReply: Bool { get }
    var hasQuotedAttachment: Bool { get }
    var hasQuotedText: Bool { get }
    var hasCellHeader: Bool { get }

    var isExpiringMessage: Bool { get }

    var shouldShowDate: Bool { get set }
    var shouldShowSenderProfilePicture: Bool { get set }
    var senderName: NSAttributedString? { get set }
    var shouldHideFooter: Bool { get set }
    var isFirstInCluster: Bool { get set }
    var isOnlyMessageInCluster: Bool { get set }
    var isLastInCluster: Bool { get set }
    var wasPreviousItemInfoMessage: Bool { get set }

    var unreadIndicator: OWSUnreadIndicator? { get set }

    func replaceInteraction(_ interaction: TSInteraction, transaction: YapDatabaseReadTransaction)
    func clearCachedLayoutState()
    var hasCachedLayoutState: Bool { get }

    var lastAudioMessageView: VoiceMessageView? { get set }
    var audioDurationSeconds: CGFloat { get }
    var audioProgressSeconds: CGFloat { get }

    var messageCellType: OWSMessageCellType { get }
    var displayableBodyText: DisplayableText? { get }
    var attachmentStream: TSAttachmentStream? { get }
    var attachmentPointer: TSAttachmentPointer? { get }
    var mediaAlbumItems: [ConversationMediaAlbumItem]? { get }

    var displayableQuotedText: DisplayableText? { get }
    var quotedAttachmentMimetype: String? { get }
    var quotedRecipientId: String? { get }

    var didCellMediaFailToLoad: Bool { get set }

//    var contactShare: ContactShareViewModel? { get }
    var linkPreview: OWSLinkPreview? { get }
    var linkPreviewAttachment: TSAttachment? { get }

    var systemMessageText: String? { get }

    var authorConversationColorName: String? { get }

    var hasBodyTextActionContent: Bool { get }
    var hasMediaActionContent: Bool { get }

    func copyMediaAction()
    func copyTextAction()
    func saveMediaAction()
    func deleteLocallyAction()
    func deleteRemotelyAction()
    func deleteAction()

    func canCopyMedia() -> Bool
    func canSaveMedia() -> Bool

    func itemId() -> String
    func firstValidAlbumAttachment() -> TSAttachmentStream?
    func mediaAlbumHasFailedAttachment() -> Bool
}

// MARK: - ConversationInteractionViewItem

@objc class ConversationInteractionViewItem: NSObject, ConversationViewItem {
    
   @objc var interaction: TSInteraction
//    @objc private(set) var interaction: TSInteraction
    let isGroupThread: Bool

    var quotedReply: OWSQuotedReplyModel?
    var isOnlyMessageInCluster = false
    var wasPreviousItemInfoMessage = false
    var lastAudioMessageView: VoiceMessageView?
    var didCellMediaFailToLoad = false

    private(set) var audioProgressSeconds: CGFloat = 0
    private(set) var audioDurationSeconds: CGFloat = 0
    private var cachedCellSize: CGSize?

    var messageCellType: OWSMessageCellType = .unknown
    var displayableBodyText: DisplayableText?
    var attachmentStream: TSAttachmentStream?
    var attachmentPointer: TSAttachmentPointer?
    var mediaAlbumItems: [ConversationMediaAlbumItem]?
    var displayableQuotedText: DisplayableText?
//    var contactShare: ContactShareViewModel?
    var linkPreview: OWSLinkPreview?
    var linkPreviewAttachment: TSAttachment?
    var systemMessageText: String?
    var authorConversationColorName: String?

    private var hasViewState = false

    init(interaction: TSInteraction, isGroupThread: Bool, transaction: YapDatabaseReadTransaction) {
        self.interaction = interaction
        self.isGroupThread = isGroupThread
        super.init()
        ensureViewState(transaction: transaction)
    }
    
    func replaceInteraction(_ interaction: TSInteraction, transaction: YapDatabaseReadTransaction) {
        self.messageCellType = .unknown
        self.displayableBodyText = nil
        self.attachmentStream = nil
        self.attachmentPointer = nil
        self.mediaAlbumItems = nil
        self.displayableQuotedText = nil
        self.quotedReply = nil
//        self.contactShare = nil
        self.systemMessageText = nil
        self.authorConversationColorName = nil
        self.linkPreview = nil
        self.linkPreviewAttachment = nil
        clearCachedLayoutState()
        ensureViewState(transaction: transaction)
    }

    // MARK: - Derived Properties

    var hasCellHeader: Bool {
        return shouldShowDate || unreadIndicator != nil
    }

    var primaryStorage: OWSPrimaryStorage {
        return SSKEnvironment.shared.primaryStorage
    }

    func itemId() -> String {
        return interaction.uniqueId!
    }

    var hasBodyText: Bool {
        return displayableBodyText != nil
    }

    var hasQuotedText: Bool {
        return displayableQuotedText != nil
    }

    var hasQuotedAttachment: Bool {
        return !(quotedAttachmentMimetype ?? "").isEmpty
    }

    var isQuotedReply: Bool {
        return hasQuotedAttachment || hasQuotedText
    }
    
    var isExpiringMessage: Bool {
        guard interaction.interactionType() == .outgoingMessage || interaction.interactionType() == .incomingMessage else {
            return false
        }

        if let message = interaction as? TSMessage {
            return message.isExpiringMessage
        }
        return false
    }

    var shouldShowDate: Bool = false {
        didSet {
            if oldValue != shouldShowDate {
                clearCachedLayoutState()
            }
        }
    }

    var shouldShowSenderProfilePicture: Bool = false {
        didSet {
            if oldValue != shouldShowSenderProfilePicture {
                clearCachedLayoutState()
            }
        }
    }

    var senderName: NSAttributedString? {
        didSet {
            // Assuming isNullableObject(equalTo:) is a helper method you have,
            // in Swift you could just check equality or implement your own method
            if NSObject.isNullableObject(senderName, equalTo: oldValue) {
                return
            }
            clearCachedLayoutState()
        }
    }

    var shouldHideFooter: Bool = false {
        didSet {
            if oldValue != shouldHideFooter {
                clearCachedLayoutState()
            }
        }
    }

    var isFirstInCluster: Bool = false {
        didSet {
            if oldValue != isFirstInCluster {
                clearCachedLayoutState()
            }
        }
    }

    var isLastInCluster: Bool = false {
        didSet {
            if oldValue != isLastInCluster {
                clearCachedLayoutState()
            }
        }
    }
    
    var unreadIndicator: OWSUnreadIndicator? {
        didSet {
            if NSObject.isNullableObject(unreadIndicator, equalTo: oldValue) {
                return
            }
            clearCachedLayoutState()
        }
    }

    func clearCachedLayoutState() {
        cachedCellSize = nil
    }

    var hasCachedLayoutState: Bool {
        return cachedCellSize != nil
    }
    
    func firstValidAlbumAttachment() -> TSAttachmentStream? {
        guard let mediaAlbumItems = mediaAlbumItems, !mediaAlbumItems.isEmpty else {
            assertionFailure("mediaAlbumItems should not be empty")
            return nil
        }

        for mediaAlbumItem in mediaAlbumItems {
            if let stream = mediaAlbumItem.attachmentStream,
               stream.isValidVisualMedia {
                return stream
            }
        }

        return nil
    }

    // MARK: - OWSAudioPlayerDelegate
    
    func audioPlaybackState() -> AudioPlaybackState {
        return .stopped
    }
    
    func setAudioPlaybackState(_ audioPlaybackState: AudioPlaybackState) {
        //        self.audioPlaybackState = audioPlaybackState
        
        let isPlaying = (audioPlaybackState == .playing)
        lastAudioMessageView?.isPlaying = isPlaying
    }
    
    func setAudioProgress(_ progress: CGFloat, duration: CGFloat) {
        assert(Thread.isMainThread)

        audioProgressSeconds = progress
        lastAudioMessageView?.progress = Int(progress)
    }

    func showInvalidAudioFileAlert() {
        assert(Thread.isMainThread, "Must be called on main thread")
        
        OWSAlerts.showErrorAlert(message: NSLocalizedString("INVALID_AUDIO_FILE_ALERT_ERROR_MESSAGE",
                                                              comment: "Message for the alert indicating that an audio file is invalid."))
    }

    func audioPlayerDidFinishPlaying(_ player: OWSAudioPlayer, successfully flag: Bool) {
        guard flag else { return }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SNAudioDidFinishPlayingNotification.rawValue), object: nil)
    }
    
    private static let displayableTextCache: NSCache<NSString, DisplayableText> = {
        let cache = NSCache<NSString, DisplayableText>()
        cache.countLimit = 1000
        return cache
    }()

    func displayableBodyText(forText text: String, interactionId: String) -> DisplayableText {
        assert(!text.isEmpty)
        assert(!interactionId.isEmpty)

        let cacheKey = "body-" + interactionId
        return displayableText(forCacheKey: cacheKey) {
            return text
        }
    }

    func displayableBodyText(forOversizeTextAttachment attachmentStream: TSAttachmentStream, interactionId: String) -> DisplayableText {
        assert(attachmentStream.originalMediaURL != nil)
        assert(!interactionId.isEmpty)

        let cacheKey = "oversize-body-" + interactionId
        return displayableText(forCacheKey: cacheKey) {
            if let url = attachmentStream.originalMediaURL,
               let textData = try? Data(contentsOf: url),
               let text = String(data: textData, encoding: .utf8) {
                return text
            }
            return ""
        }
    }

    func displayableQuotedText(forText text: String, interactionId: String) -> DisplayableText {
        assert(!text.isEmpty)
        assert(!interactionId.isEmpty)

        let cacheKey = "quoted-" + interactionId
        return displayableText(forCacheKey: cacheKey) {
            return text
        }
    }

    func displayableCaption(forText text: String, attachmentId: String) -> DisplayableText {
        assert(!text.isEmpty)
        assert(!attachmentId.isEmpty)

        let cacheKey = "attachment-caption-" + attachmentId
        return displayableText(forCacheKey: cacheKey) {
            return text
        }
    }

    func displayableText(forCacheKey cacheKey: String, textBlock: () -> String) -> DisplayableText {
        assert(!cacheKey.isEmpty)

        if let cachedText = Self.displayableTextCache.object(forKey: cacheKey as NSString) {
            return cachedText
        } else {
            let text = textBlock()
            let displayableText = DisplayableText.displayableText(text)
            Self.displayableTextCache.setObject(displayableText, forKey: cacheKey as NSString)
            return displayableText
        }
    }
    
    func ensureViewState(transaction: YapDatabaseReadTransaction) {
//        OWSAssertIsOnMainThread()
//        OWSAssertDebug(transaction != nil)
//        OWSAssertDebug(!self.hasViewState)

        switch self.interaction.interactionType() {
        case .unknown, .offer, .typingIndicator:
            return
        case .info, .call:
            self.systemMessageText = self.systemMessageText(transaction: transaction)
//            OWSAssertDebug(self.systemMessageText?.isEmpty == false)
            return
        case .incomingMessage, .outgoingMessage:
            break
        @unknown default:
//            OWSFailDebug("Unknown interaction type.")
            return
        }

//        OWSAssertDebug(self.interaction is TSOutgoingMessage || self.interaction is TSIncomingMessage)

        self.hasViewState = true

        guard let message = self.interaction as? TSMessage else { return }

        if message.isDeleted {
            self.messageCellType = .deletedMessage
            return
        }

        // Handle quoted message
        if let quotedMessage = message.quotedMessage {
            self.quotedReply = OWSQuotedReplyModel.quotedReply(
                with: quotedMessage,
                threadId: message.uniqueThreadId,
                transaction: transaction
            )

            if let body = self.quotedReply?.body, !body.isEmpty {
                self.displayableQuotedText = self.displayableQuotedText(
                    forText: body,
                    interactionId: message.uniqueId!
                )
            }
        }

        if let oversizeAttachment = message.oversizeTextAttachment(with: transaction) {
            if let stream = oversizeAttachment as? TSAttachmentStream {
                self.displayableBodyText = self.displayableBodyText(
                    forOversizeTextAttachment: stream,
                    interactionId: message.uniqueId!
                )
            } else if let pointer = oversizeAttachment as? TSAttachmentPointer {
                // TODO: Handle backup restore.
                self.messageCellType = .oversizeTextDownloading
                self.attachmentPointer = pointer
                return
            }
        } else if let bodyText = message.bodyText(with: transaction) {
            self.displayableBodyText = self.displayableBodyText(
                forText: bodyText,
                interactionId: message.uniqueId!
            )
        }

        let mediaAttachments = message.mediaAttachments(with: transaction)
        let mediaAlbumItems = self.albumItems(for: mediaAttachments)

        if !mediaAlbumItems.isEmpty {
            if mediaAlbumItems.count == 1, let item = mediaAlbumItems.first {
                if let stream = item.attachmentStream, !stream.isValidVisualMedia {
//                    OWSLogWarn("Treating invalid media as generic attachment.")
                    self.messageCellType = .genericAttachment
                    return
                }
            }

            self.mediaAlbumItems = mediaAlbumItems
            self.messageCellType = .mediaMessage
            return
        }

//        OWSAssertDebug(mediaAttachments.count <= 1)

        if let mediaAttachment = mediaAttachments.first {
            if let stream = mediaAttachment as? TSAttachmentStream {
                self.attachmentStream = stream
                if stream.isAudio {
                    let duration = stream.audioDurationSeconds()
                    if duration > 0 {
                        self.audioDurationSeconds = duration
                        self.messageCellType = .audio
                    } else {
                        self.messageCellType = .genericAttachment
                    }
                } else if self.messageCellType == .unknown {
                    self.messageCellType = .genericAttachment
                }
            } else if let pointer = mediaAttachment as? TSAttachmentPointer {
                if mediaAttachment.isAudio {
                    self.audioDurationSeconds = 0
                    self.messageCellType = .audio
                } else {
                    self.messageCellType = .genericAttachment
                }
                self.attachmentPointer = pointer
            } else {
//                OWSFailDebug("Unknown attachment type")
            }
        }

        if self.hasBodyText {
            if self.messageCellType == .unknown {
                self.messageCellType = .textOnlyMessage
            }
//            OWSAssertDebug(self.displayableBodyText != nil)
        }

        if self.hasBodyText, let preview = message.linkPreview {
            self.linkPreview = preview

            let className = String(describing: type(of: preview))
            if className == "OWSUnknownDBObject" {
                return
            } else {
                print("Unexpected class: \(className)")
            }

            if let attachmentId = preview.imageAttachmentId, !attachmentId.isEmpty {
                let previewAttachment = TSAttachment.fetch(uniqueId: attachmentId, transaction: transaction)
                if let previewAttachment = previewAttachment {
                    if !previewAttachment.isImage {
//                        OWSLogDebug("Link preview attachment isn't an image.")
                    } else if let stream = previewAttachment as? TSAttachmentStream {
                        if stream.isValidImage {
                            self.linkPreviewAttachment = previewAttachment
                        } else {
//                            OWSLogDebug("Link preview image attachment isn't valid.")
                        }
                    } else {
                        self.linkPreviewAttachment = previewAttachment
                    }
                } else {
//                    OWSLogDebug("Could not load link preview image attachment.")
                }
            }
        }

        if self.messageCellType == .unknown {
//            OWSLogWarn("Treating unknown message as empty text message: \(type(of: message)) \(message.timestamp)")
            self.messageCellType = .textOnlyMessage
            self.displayableBodyText = DisplayableText(
                fullText: "",
                displayText: "",
                isTextTruncated: false
            )
        }
    }
    
    
    func albumItems(for attachments: [TSAttachment]) -> [ConversationMediaAlbumItem] {
        AssertIsOnMainThread()

        var mediaAlbumItems: [ConversationMediaAlbumItem] = []

        for attachment in attachments {
            guard attachment.isVisualMedia else {
                // Mixed media types are unsupported — return empty list.
//                OWSAssertDebug(mediaAlbumItems.isEmpty)
                return []
            }

            let caption: String? = {
                if let rawCaption = attachment.caption {
                    return self.displayableCaption(forText: rawCaption, attachmentId: attachment.uniqueId!).displayText
                }
                return nil
            }()

            if !(attachment is TSAttachmentStream) {
                if let attachmentPointer = attachment as? TSAttachmentPointer {
                    var mediaSize = CGSize.zero
                    if attachmentPointer.mediaSize.width > 0 && attachmentPointer.mediaSize.height > 0 {
                        mediaSize = attachmentPointer.mediaSize
                    }

                    mediaAlbumItems.append(
                        ConversationMediaAlbumItem(
                            attachment: attachment,
                            attachmentStream: nil,
                            caption: caption,
                            mediaSize: mediaSize
                        )
                    )
                }
                continue
            }

            guard let attachmentStream = attachment as? TSAttachmentStream else { continue }

            if !attachmentStream.isValidVisualMedia {
//                OWSLogWarn("Filtering invalid media.")
                mediaAlbumItems.append(
                    ConversationMediaAlbumItem(
                        attachment: attachment,
                        attachmentStream: nil,
                        caption: caption,
                        mediaSize: .zero
                    )
                )
                continue
            }

            let mediaSize = attachmentStream.imageSize()
            if mediaSize.width <= 0 || mediaSize.height <= 0 {
//                OWSLogWarn("Filtering media with invalid size.")
                mediaAlbumItems.append(
                    ConversationMediaAlbumItem(
                        attachment: attachment,
                        attachmentStream: nil,
                        caption: caption,
                        mediaSize: .zero
                    )
                )
                continue
            }

            let mediaAlbumItem = ConversationMediaAlbumItem(
                attachment: attachment,
                attachmentStream: attachmentStream,
                caption: caption,
                mediaSize: mediaSize
            )

            mediaAlbumItems.append(mediaAlbumItem)
        }

        return mediaAlbumItems
    }
    
    func systemMessageText(transaction: YapDatabaseReadTransaction) -> String? {
//        OWSAssertDebug(transaction != nil)

        switch self.interaction.interactionType() {
        case .info:
            if let infoMessage = self.interaction as? TSInfoMessage {
                return infoMessage.previewText(with: transaction)
            }
            return nil
        default:
//            OWSFailDebug("Not a system message.")
            return nil
        }
    }
    
    
    var quotedAttachmentMimetype: String? {
        return self.quotedReply?.contentType
    }

    var quotedRecipientId: String? {
        return self.quotedReply?.authorId
    }
    
    
    func copyTextAction() {
        if self.attachmentPointer != nil {
//            OWSFailDebug("Can't copy not-yet-downloaded attachment")
            return
        }

        switch self.messageCellType {
        case .textOnlyMessage, .audio, .mediaMessage, .genericAttachment:
            guard let displayableBodyText = self.displayableBodyText else {
//                OWSFailDebug("Missing body text")
                return
            }
            UIPasteboard.general.string = displayableBodyText.fullText

        case .unknown: break
//            OWSFailDebug("No text to copy")

        case .oversizeTextDownloading: break
//            OWSFailDebug("Can't copy not-yet-downloaded attachment")
        case .deletedMessage: break
//            OWSFailDebug("Missing body text")
        }
    }
    
    func copyMediaAction() {
        if self.attachmentPointer != nil {
//            OWSFailDebug("Can't copy not-yet-downloaded attachment")
            return
        }

        switch self.messageCellType {
        case .unknown, .textOnlyMessage, .audio, .genericAttachment:
            if let stream = self.attachmentStream {
                self.copyAttachmentToPasteboard(attachment: stream)
            }

        case .mediaMessage:
            if mediaAlbumItems!.count == 1,
               let item = mediaAlbumItems?.first,
               let stream = item.attachmentStream,
               stream.isValidVisualMedia {
                self.copyAttachmentToPasteboard(attachment: stream)
                return
            }

//            OWSFailDebug("Can't copy media album")

        case .oversizeTextDownloading:
//            OWSFailDebug("Can't copy not-yet-downloaded attachment")
            return

        case .deletedMessage:
            break
        }
    }

    
    func copyAttachmentToPasteboard(attachment: TSAttachmentStream) {
//        OWSAssertDebug(true)  // Replace with actual assertion logic if needed

        var utiType = MIMETypeUtil.utiType(forMIMEType: attachment.contentType)
        if utiType == nil {
//            OWSFailDebug("Unknown MIME type: \(attachment.contentType)")
            utiType = OWSMimeTypeImageGif as String
        }

        guard let url = attachment.originalMediaURL,
              let data = try? Data(contentsOf: url) else {
//            OWSFailDebug("Could not load attachment data")
            return
        }

        if let uti = utiType {
            UIPasteboard.general.setData(data, forPasteboardType: uti)
        }
    }
    
    func canCopyMedia() -> Bool {
        if self.attachmentPointer != nil {
            // The attachment is still downloading.
            return false
        }

        switch self.messageCellType {
        case .unknown, .textOnlyMessage, .audio:
            return false

        case .genericAttachment, .mediaMessage:
            if mediaAlbumItems?.count == 1,
               let item = mediaAlbumItems?.first,
               let stream = item.attachmentStream,
               stream.isValidVisualMedia {
                return true
            }
            return false

        case .oversizeTextDownloading:
            return false

        case .deletedMessage:
            return false
        }
    }
    
    
    func canSaveMedia() -> Bool {
        if self.attachmentPointer != nil {
            // The attachment is still downloading.
            return false
        }

        switch self.messageCellType {
        case .unknown, .textOnlyMessage, .audio, .genericAttachment:
            return false

        case .mediaMessage:
            guard let mediaAlbumItems = mediaAlbumItems, !mediaAlbumItems.isEmpty else {
                assertionFailure("mediaAlbumItems should not be empty")
                return false
            }
            for item in mediaAlbumItems {
                guard let stream = item.attachmentStream else { continue }
                guard stream.isValidVisualMedia else { continue }

                if stream.isImage || stream.isAnimated {
                    return true
                }

                if stream.isVideo {
                    if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(stream.originalFilePath!) {
                        return true
                    }
                }
            }
            return false

        case .oversizeTextDownloading:
            return false

        case .deletedMessage:
            return false
        }
    }
    
    func saveMediaAction() {
        if self.attachmentPointer != nil {
//            OWSFailDebug("Can't save not-yet-downloaded attachment")
            return
        }

        switch self.messageCellType {
        case .unknown, .textOnlyMessage, .audio, .genericAttachment: break
//            OWSFailDebug("Cannot save media data.")

        case .mediaMessage:
            saveMediaAlbumItems()

        case .oversizeTextDownloading: break
//            OWSFailDebug("Can't save not-yet-downloaded attachment")

        case .deletedMessage: break
//            OWSFailDebug("Deleted messages can't be saved.")
        }
    }
    
    func saveMediaAlbumItems() {
        let items = mediaAlbumItems!
        saveMediaAlbumItems(items)
    }
    
    func saveMediaAlbumItems(_ mediaAlbumItems: [ConversationMediaAlbumItem]) {
        var remainingItems = mediaAlbumItems

        guard !remainingItems.isEmpty else {
            return
        }

        let currentItem = remainingItems.removeFirst()

        guard let stream = currentItem.attachmentStream,
              stream.isValidVisualMedia,
              let fileURL = stream.originalMediaURL else {
            // Skip and continue
            saveMediaAlbumItems(remainingItems)
            return
        }

        let photoLibrary = PHPhotoLibrary.shared()

        if stream.isImage || stream.isAnimated {
            photoLibrary.performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
            }, completionHandler: { success, error in
                if let error = error {
//                    OWSFailDebug("Image save failed: \(error.localizedDescription)")
                } else if !success {
//                    OWSFailDebug("Image save failed for unknown reason.")
                }
                self.saveMediaAlbumItems(remainingItems)
            })
            return
        }

        if stream.isVideo {
            photoLibrary.performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            }, completionHandler: { success, error in
                if let error = error {
//                    OWSFailDebug("Video save failed: \(error.localizedDescription)")
                } else if !success {
//                    OWSFailDebug("Video save failed for unknown reason.")
                }
                self.saveMediaAlbumItems(remainingItems)
            })
            return
        }

        // If not image or video, skip and continue
        saveMediaAlbumItems(remainingItems)
    }
    
    func deleteLocallyAction() {
        guard let message = self.interaction as? TSMessage else { return }

        Storage.objc_write { transaction in
            MessageInvalidator.invalidate(message, with: transaction)
            self.interaction.remove(with: transaction)

            if self.interaction.interactionType() == .outgoingMessage {
                Storage.shared.cancelPendingMessageSendJobIfNeeded(
                    for: self.interaction.timestamp,
                    using: transaction
                )
            }
        }
    }
    
    func deleteRemotelyAction() {
        guard let message = self.interaction as? TSMessage else { return }

        if isGroupThread, let groupThread = self.interaction.thread as? TSGroupThread {
            let type = self.interaction.interactionType()

            guard type == .incomingMessage || type == .outgoingMessage else { return }

            if groupThread.isOpenGroup {
                guard message.isOpenGroupMessage else { return }

                guard let openGroup = Storage.shared.getV2OpenGroup(for: groupThread.uniqueId!) else { return }

                if type == .incomingMessage {
                    let userPublicKey = Storage.shared.getUserPublicKey()!
                    guard OpenGroupAPIV2.isUserModerator(userPublicKey, for: openGroup.room, on: openGroup.server) else { return }
                }

                OpenGroupAPIV2
                    .deleteMessage(with: Int64(message.openGroupServerMessageID), from: openGroup.room, on: openGroup.server)
                    .catch { error in
                        self.interaction.save()
                    }
                    .retainUntilComplete()

            } else {
                let groupPublicKey = LKGroupUtilities.getDecodedGroupID(groupThread.groupModel.groupId)
                if let serverHash = message.serverHash {
                    SnodeAPI.deleteMessage(publicKey: groupPublicKey, serverHashes: [serverHash])
                        .catch { error in
                            self.interaction.save()
                        }
                        .retainUntilComplete()
                }
            }

        } else if let contactThread = self.interaction.thread as? TSContactThread {
            if let serverHash = message.serverHash {
                SnodeAPI.deleteMessage(publicKey: contactThread.contactBChatID(), serverHashes: [serverHash])
                    .catch { error in
                        self.interaction.save()
                    }
                    .retainUntilComplete()
            }
            
        }
    }
    
    func deleteAction() {
        Storage.objc_write { transaction in
            self.interaction.remove(with: transaction)

            if self.interaction.interactionType() == .outgoingMessage {
                Storage.shared.cancelPendingMessageSendJobIfNeeded(
                    for: self.interaction.timestamp,
                    using: transaction
                )
            }
        }

        guard isGroupThread, let groupThread = self.interaction.thread as? TSGroupThread else { return }

        let type = self.interaction.interactionType()
        guard type == .incomingMessage || type == .outgoingMessage else { return }

        guard let message = self.interaction as? TSMessage,
              message.isOpenGroupMessage else { return }

        let openGroup = Storage.shared.getV2OpenGroup(for: groupThread.uniqueId!)
        guard openGroup != nil else { return }

        if type == .incomingMessage {
            let userPublicKey = Storage.shared.getUserPublicKey()!
            if let openGroup = openGroup {
                guard OpenGroupAPIV2.isUserModerator(userPublicKey, for: openGroup.room, on: openGroup.server) else { return }
            }
        }

        if let openGroup = openGroup {
            OpenGroupAPIV2
                .deleteMessage(with: Int64(message.openGroupServerMessageID), from: openGroup.room, on: openGroup.server)
                .catch { error in
                    self.interaction.save()
                }
                .retainUntilComplete()
        }
    }
    
    
    var hasBodyTextActionContent: Bool {
        return hasBodyText && (displayableBodyText?.fullText.count ?? 0) > 0
    }
    
    var hasMediaActionContent: Bool {
        guard attachmentPointer == nil else {
            // The attachment is still downloading.
            return false
        }

        switch messageCellType {
        case .unknown, .textOnlyMessage, .audio, .genericAttachment:
            return attachmentStream != nil
        case .mediaMessage:
            return firstValidAlbumAttachment != nil
        case .oversizeTextDownloading:
            return false
        case .deletedMessage:
            return false
        }
    }
    
    func mediaAlbumHasFailedAttachment() -> Bool {
        return mediaAlbumItems?.contains(where: { $0.isFailedDownload }) ?? false
    }
    
    var userCanDeleteGroupMessage: Bool {
        guard isGroupThread,
              let groupThread = interaction.thread as? TSGroupThread else {
            return false
        }
        
        let type = interaction.interactionType()
        guard type == .outgoingMessage || type == .incomingMessage else {
            return false
        }
        
        guard let message = interaction as? TSMessage else {
            return false
        }
        
        if !message.isOpenGroupMessage {
            return true
        }
        
        guard let openGroup = Storage.shared.getV2OpenGroup(for: groupThread.uniqueId!) else {
            return true
        }
        
        if type == .incomingMessage {
            let userPublicKey = GeneralUtilities.getUserPublicKey()
            return OpenGroupAPIV2.isUserModerator(userPublicKey, for: openGroup.room, on: openGroup.server)
        }
        
        return true
    }
    
    var userHasModerationPermission: Bool {
        guard isGroupThread,
              let groupThread = interaction.thread as? TSGroupThread,
              let message = interaction as? TSMessage,
              message.isOpenGroupMessage,
              let openGroup = Storage.shared.getV2OpenGroup(for: groupThread.uniqueId!) else {
            return false
        }
        
        let userPublicKey = GeneralUtilities.getUserPublicKey()
        return OpenGroupAPIV2.isUserModerator(userPublicKey, for: openGroup.room, on: openGroup.server)
    }
    
}

