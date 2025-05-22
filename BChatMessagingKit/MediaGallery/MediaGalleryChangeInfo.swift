// Copyright © 2025 Beldex International Limited OU. All rights reserved.

public struct MediaGalleryChangeInfo {
    public var referenceId: AttachmentReferenceId
    public var threadGrdbId: Int64
    public var timestamp: UInt64

    /// A notification for when an attachment stream becomes available (incoming attachment downloaded, or outgoing
    /// attachment loaded).
    ///
    /// The object of the notification is an array of MediaGalleryChangeInfo values.
    /// When registering an observer for this notification, set the observed object to `nil`, meaning no filter.
    public static let newAttachmentsAvailableNotification =
        Notification.Name(rawValue: "SSKMediaGalleryFinderNewResourcesAvailable")

    /// A notification for when a downloaded attachment is removed.
    ///
    /// The object of the notification is an array of MediaGalleryChangeInfo values.
    /// When registering an observer for this notification, set the observed object to `nil`, meaning no filter.
    public static let didRemoveAttachmentsNotification =
        Notification.Name(rawValue: "SSKMediaGalleryFinderDidRemoveResources")
}
