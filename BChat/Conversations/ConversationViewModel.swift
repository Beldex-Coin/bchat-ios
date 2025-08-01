
import Foundation
import UIKit
import BChatUIKit
import BChatMessagingKit
import PromiseKit
import BChatUtilitiesKit

// MARK: - Enums

enum ConversationUpdateType: Int {
    case minor
    case diff
    case reload
}

enum ConversationUpdateItemType: Int {
    case insert
    case delete
    case update
}

// MARK: - Protocols

protocol ConversationInteraction {
    var uniqueId: String { get }
}

protocol OWSReadTracking {
    var read: Bool { get }
}

// MARK: - ConversationProfileState

class ConversationProfileState {
    var hasLocalProfile: Bool = false
    var isThreadInProfileWhitelist: Bool = false
    var hasUnwhitelistedMember: Bool = false
}

// MARK: - ConversationViewState

class ConversationViewState {
    let viewItems: [ConversationViewItem]
    let interactionIndexMap: [String: NSNumber]
    let interactionIds: [String]
    let unreadIndicatorIndex: NSNumber?

    init(viewItems: [ConversationViewItem]) {
        self.viewItems = viewItems

        var indexMap = [String: NSNumber]()
        var ids = [String]()
        var unreadIndex: NSNumber?

        for (i, item) in viewItems.enumerated() {
            let id = item.interaction.uniqueId
            indexMap[id!] = NSNumber(value: i)
            ids.append(id!)

            if item.unreadIndicator != nil,
               let interaction = item.interaction as? OWSReadTracking,
               !interaction.read {
                unreadIndex = NSNumber(value: i)
            }
        }

        self.interactionIndexMap = indexMap
        self.interactionIds = ids
        self.unreadIndicatorIndex = unreadIndex
    }

    func unreadIndicatorViewItem() -> ConversationViewItem? {
        guard let index = unreadIndicatorIndex?.intValue,
              index < viewItems.count else {
            assertionFailure("Invalid unreadIndicatorIndex")
            return nil
        }
        return viewItems[index]
    }
}

// MARK: - ConversationUpdateItem

class ConversationUpdateItem {
    let updateItemType: ConversationUpdateItemType
    let oldIndex: Int
    let newIndex: Int
    let viewItem: ConversationViewItem?

    init(updateItemType: ConversationUpdateItemType,
         oldIndex: Int,
         newIndex: Int,
         viewItem: ConversationViewItem?) {
        self.updateItemType = updateItemType
        self.oldIndex = oldIndex
        self.newIndex = newIndex
        self.viewItem = viewItem
    }
}

// MARK: - ConversationUpdate

class ConversationUpdate {
    let conversationUpdateType: ConversationUpdateType
    let updateItems: [ConversationUpdateItem]?
    let shouldAnimateUpdates: Bool

    init(conversationUpdateType: ConversationUpdateType,
         updateItems: [ConversationUpdateItem]? = nil,
         shouldAnimateUpdates: Bool = false) {
        self.conversationUpdateType = conversationUpdateType
        self.updateItems = updateItems
        self.shouldAnimateUpdates = shouldAnimateUpdates
    }

    static func minorUpdate() -> ConversationUpdate {
        return ConversationUpdate(conversationUpdateType: .minor)
    }

    static func reloadUpdate() -> ConversationUpdate {
        return ConversationUpdate(conversationUpdateType: .reload)
    }

    static func diffUpdate(updateItems: [ConversationUpdateItem]?,
                           shouldAnimateUpdates: Bool) -> ConversationUpdate {
        return ConversationUpdate(conversationUpdateType: .diff,
                                  updateItems: updateItems,
                                  shouldAnimateUpdates: shouldAnimateUpdates)
    }
}

// MARK: - Delegate

protocol ConversationViewModelDelegate: AnyObject {
    func conversationViewModelWillUpdate()
    func conversationViewModelDidUpdate(_ update: ConversationUpdate)
    func conversationViewModelWillLoadMoreItems()
    func conversationViewModelDidLoadMoreItems()
    func conversationViewModelDidLoadPrevPage()
    func conversationViewModelRangeDidChange()
    func conversationViewModelDidReset()
}

// MARK: - Constants

let kYapDatabasePageSize = 250
let kConversationInitialMaxRangeSize = 250
let kYapDatabaseRangeMaxLength = 250_000

class ConversationViewModel {
    weak var delegate: ConversationViewModelDelegate?

    private(set) var thread: TSThread

    var messageMapping: ConversationMessageMapping?

    var viewState: ConversationViewState
    var viewItemCache: [String: ConversationViewItem]?

    var dynamicInteractions: ThreadDynamicInteractions?
    var hasClearedUnreadMessagesIndicator: Bool = false
    var collapseCutoffDate: Date?

    var conversationProfileState: ConversationProfileState?
    var hasTooManyOutgoingMessagesToBlockCached: Bool = false

    var persistedViewItems: [ConversationViewItem]
    var unsavedOutgoingMessages: [TSOutgoingMessage]

    var hasUiDatabaseUpdatedExternally: Bool = false

    var focusMessageIdOnOpen: String?

    // MARK: - Initialization

    init(thread: TSThread, focusMessageIdOnOpen: String?, delegate: ConversationViewModelDelegate) {
        self.thread = thread
        self.delegate = delegate

        self.persistedViewItems = []
        self.unsavedOutgoingMessages = []

        self.focusMessageIdOnOpen = focusMessageIdOnOpen
        self.viewState = ConversationViewState(viewItems: [])
        self.messageMapping = ConversationMessageMapping(group: thread.uniqueId, desiredLength: initialMessageMappingLength)
        self.viewItemCache = [:]

        configure()
    }

    // MARK: - Dependencies
    
    var primaryStorage: OWSPrimaryStorage {
        assert(SSKEnvironment.shared.primaryStorage != nil, "primaryStorage is nil")
        return SSKEnvironment.shared.primaryStorage
    }

    var uiDatabaseConnection: YapDatabaseConnection {
        primaryStorage.uiDatabaseConnection
    }

    var editingDatabaseConnection: YapDatabaseConnection {
        primaryStorage.dbReadWriteConnection
    }

    var typingIndicators: TypingIndicators {
        SSKEnvironment.shared.typingIndicators
    }
    
    var tsAccountManager: TSAccountManager {
        assert(SSKEnvironment.shared.tsAccountManager != nil, "tsAccountManager is nil")
        return SSKEnvironment.shared.tsAccountManager
    }

    var profileManager: OWSProfileManager {
        OWSProfileManager.shared()
    }

    func addNotificationListeners() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground(_:)),
                                               name: Notification.Name(NSNotification.Name.OWSApplicationDidEnterBackground.rawValue),
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(typingIndicatorStateDidChange(_:)),
                                               name: TypingIndicatorsImpl.typingIndicatorStateDidChange,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(blockListDidChange(_:)),
                                               name: .contactBlockedStateChanged,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(localProfileDidChange(_:)),
                                               name: Notification.Name(kNSNotificationName_LocalProfileDidChange),
                                               object: nil)
    }

    @objc func localProfileDidChange(_ notification: Notification) {
        assert(Thread.isMainThread, "Must be called on main thread")
        conversationProfileState = nil
        updateForTransientItems()
    }

    @objc func blockListDidChange(_ notification: Notification) {
        assert(Thread.isMainThread, "Must be called on main thread")
        updateForTransientItems()
    }

    func configure() {
        print("Configure called")

        // Update the unread indicator before initial range size is determined
        typingIndicatorsSender = typingIndicators.typingRecipientId(forThread: thread)
        collapseCutoffDate = Date()

        ensureDynamicInteractionsAndUpdateIfNecessary()
        primaryStorage.updateUIDatabaseConnectionToLatest()

        createNewMessageMapping()
        guard reloadViewItems() else {
            assertionFailure("Failed to reload view items in configure")
            return
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(uiDatabaseDidUpdateExternally(_:)),
                                               name: Notification.Name(NSNotification.Name.OWSUIDatabaseConnectionDidUpdateExternally.rawValue),
                                               object: primaryStorage.dbNotificationObject)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(uiDatabaseWillUpdate(_:)),
                                               name: Notification.Name(NSNotification.Name.OWSUIDatabaseConnectionWillUpdate.rawValue) ,
                                               object: primaryStorage.dbNotificationObject)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(uiDatabaseDidUpdate(_:)),
                                               name: Notification.Name(NSNotification.Name.OWSUIDatabaseConnectionDidUpdate.rawValue) ,
                                               object: primaryStorage.dbNotificationObject)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground(_:)),
                                               name: Notification.Name(NSNotification.Name.OWSApplicationWillEnterForeground.rawValue) ,
                                               object: nil)

        addNotificationListeners()
    }

    func touchDbAsync() {
        primaryStorage.touchDbAsync()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func canLoadMoreItems() -> Bool {
        if messageMapping!.desiredLength >= kYapDatabaseRangeMaxLength {
            return false
        }
        return messageMapping!.canLoadMore
    }

    @objc func applicationDidEnterBackground(_ notification: Notification) {
        if hasClearedUnreadMessagesIndicator {
            hasClearedUnreadMessagesIndicator = false
            dynamicInteractions?.clearUnreadIndicatorState()
        }
    }

    func viewDidResetContentAndLayout() {
        collapseCutoffDate = Date()
        guard reloadViewItems() else {
            assertionFailure("Failed to reload view items in resetContentAndLayout")
            return
        }
    }
    
    var typingIndicatorsSender: String? {
        didSet {
            guard oldValue != typingIndicatorsSender else { return }

            if viewState.viewItems != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.updateForTransientItems()
                }
            }
        }
    }
   
}

extension ConversationViewModel {

    func loadAnotherPageOfMessages() {
        let hasEarlierUnseenMessages = dynamicInteractions?.unreadIndicator?.hasMoreUnseenMessages ?? false

        loadNMoreMessages(numberOfMessagesToLoad: UInt(kYapDatabasePageSize * 2))
        
        if hasEarlierUnseenMessages && focusMessageIdOnOpen == nil {
            primaryStorage.updateUIDatabaseConnectionToLatest()
            delegate?.conversationViewModelDidLoadPrevPage()
        }
    }

    func loadNMoreMessages(numberOfMessagesToLoad: UInt) {
        delegate?.conversationViewModelWillLoadMoreItems()
        resetMapping(withAdditionalLength: Int(numberOfMessagesToLoad))
        delegate?.conversationViewModelDidLoadMoreItems()
    }

    var initialMessageMappingLength: UInt {
        var rangeLength = kYapDatabasePageSize

        if let focusMessageId = focusMessageIdOnOpen {
            assert(dynamicInteractions?.focusMessagePosition != nil)
            
            if let focusPosition = dynamicInteractions?.focusMessagePosition?.intValue {
                print("Ensuring load of focus message at position: \(focusPosition)")
                rangeLength = max(rangeLength, 1 + focusPosition)
            }
        }

        if let unreadIndicator = dynamicInteractions?.unreadIndicator {
            let unreadPosition = unreadIndicator.unreadIndicatorPosition

            assert(unreadPosition > 0)
            assert(unreadPosition <= kYapDatabaseRangeMaxLength)

            let preferredSeenMessageCount = 1
            rangeLength = max(rangeLength, unreadPosition + preferredSeenMessageCount)
        }

        return UInt(rangeLength)
    }

    func updateMessageMapping(withAdditionalLength additionalLength: UInt) {
        var rangeLength = messageMapping!.desiredLength + additionalLength

        rangeLength = max(rangeLength, UInt(kYapDatabasePageSize))

        rangeLength = min(rangeLength, UInt(kYapDatabaseRangeMaxLength))

        uiDatabaseConnection.read { transaction in
            self.messageMapping!.update(withDesiredLength: rangeLength, transaction: transaction)
        }

        delegate?.conversationViewModelRangeDidChange()
        collapseCutoffDate = Date()
    }

    func ensureDynamicInteractionsAndUpdateIfNecessary() {
        assert(Thread.isMainThread, "Must be on main thread")

        let currentMaxRangeSize = Int(messageMapping!.desiredLength)
        let maxRangeSize = max(kConversationInitialMaxRangeSize, currentMaxRangeSize)

        let dynamicInteractions = ThreadUtil.ensureDynamicInteractions(
            for: thread,
            dbConnection: editingDatabaseConnection,
            hideUnreadMessagesIndicator: hasClearedUnreadMessagesIndicator,
            last: self.dynamicInteractions?.unreadIndicator,
            focusMessageId: focusMessageIdOnOpen,
            maxRangeSize: Int32(maxRangeSize)
        )

        let didChange = !NSObject.isNullableObject(self.dynamicInteractions, equalTo: dynamicInteractions)
        self.dynamicInteractions = dynamicInteractions

        if didChange {
            guard reloadViewItems() else {
                assertionFailure("Failed to reload view items.")
                return
            }

            delegate?.conversationViewModelDidUpdate(.reloadUpdate())
        }
    }

    // MARK: - Storage access notifications

    @objc func uiDatabaseDidUpdateExternally(_ notification: Notification) {
        assert(Thread.isMainThread)
        hasUiDatabaseUpdatedExternally = true
    }

    @objc func uiDatabaseWillUpdate(_ notification: Notification) {
        delegate?.conversationViewModelWillUpdate()
    }
    
    @objc func uiDatabaseDidUpdate(_ notification: Notification) {
        assert(Thread.isMainThread, "Must be on the main thread")

        guard let notifications = notification.userInfo?[OWSUIDatabaseConnectionNotificationsKey] as? [Notification] else {
            assertionFailure("Invalid notification array")
            return
        }

        guard let messageDatabaseView = uiDatabaseConnection.ext(TSMessageDatabaseViewExtensionName) as? YapDatabaseAutoViewConnection else {
            assertionFailure("Invalid message database view")
            return
        }

        if !messageDatabaseView.hasChanges(forGroup: thread.uniqueId!, in: notifications),
           !hasUiDatabaseUpdatedExternally {
            delegate?.conversationViewModelDidUpdate(.minorUpdate())
            return
        }

        hasUiDatabaseUpdatedExternally = false

        var diff: ConversationMessageMapping.ConversationMessageMappingDiff?

        uiDatabaseConnection.read { transaction in
            let nsNotifications = notifications.map { $0 as NSNotification }
            diff = self.messageMapping!.updateAndCalculateDiff(transaction: transaction, notifications: nsNotifications)
        }

        guard let diff = diff else {
            assertionFailure("Could not determine diff")
            resetMapping()
            delegate?.conversationViewModelDidReset()
            return
        }

        if diff.addedItemIds.isEmpty && diff.removedItemIds.isEmpty && diff.updatedItemIds.isEmpty {
            print("Empty diff.")
            delegate?.conversationViewModelDidUpdate(.minorUpdate())
            return
        }

        var diffAddedItemIds = Set(diff.addedItemIds)
        var diffRemovedItemIds = Set(diff.removedItemIds)
        var diffUpdatedItemIds = Set(diff.updatedItemIds)

        for unsavedMessage in unsavedOutgoingMessages {
            let id = unsavedMessage.uniqueId
            let isFound = diffAddedItemIds.contains(id!) || diffRemovedItemIds.contains(id!) || diffUpdatedItemIds.contains(id!)

            if isFound {
                if diffAddedItemIds.contains(id!) {
                    print("Converting insert to update: \(id)")
                    diffAddedItemIds.remove(id!)
                    diffUpdatedItemIds.insert(id!)
                }

                unsavedOutgoingMessages.removeAll { $0.uniqueId == id }
            }
        }

        let oldItemIdList = viewState.interactionIds
        var hasMalformedRowChange = false
        var updatedItemSet = Set<String>()

        for uniqueId in diffUpdatedItemIds {
            if let viewItem = viewItemCache![uniqueId] as? ConversationViewItem {
                reloadInteraction(for: viewItem)
                updatedItemSet.insert(viewItem.itemId())
            } else {
                owsFailDebug("Update is missing view item")
                hasMalformedRowChange = true
            }
        }

        for uniqueId in diffRemovedItemIds {
            viewItemCache!.removeValue(forKey: uniqueId)
        }

        if hasMalformedRowChange {
            assertionFailure("hasMalformedRowChange")
            resetMapping()
            delegate?.conversationViewModelDidReset()
            return
        }

        guard reloadViewItems() else {
            assertionFailure("Could not reload view items; hard resetting message mapping.")
            resetMapping()
            delegate?.conversationViewModelDidReset()
            return
        }

        print("viewItems.count: \(oldItemIdList.count) -> \(viewState.viewItems.count)")

        updateView(oldItemIdList: oldItemIdList, updatedItemSet: updatedItemSet)
    }
    
    func updateForTransientItems() {
        assert(Thread.isMainThread)

        let oldItemIdList = viewState.interactionIds

        guard reloadViewItems() else {
            assertionFailure("Could not reload view items; hard resetting message mapping.")
            resetMapping()
            delegate?.conversationViewModelDidReset()
            return
        }

//        print("viewItems.count: \(oldItemIdList.count) -> \(viewState.viewItems.count)")

        updateView(oldItemIdList: oldItemIdList, updatedItemSet: Set())
    }

    func updateView(oldItemIdList: [String], updatedItemSet: Set<String>) {
        guard oldItemIdList.count == Set(oldItemIdList).count else {
            assertionFailure("Old view item list has duplicates.")
            delegate?.conversationViewModelDidUpdate(.reloadUpdate())
            return
        }

        let newItemIdList = viewState.interactionIds
        var newViewItemMap: [String: ConversationViewItem] = [:]
        for viewItem in viewState.viewItems {
            newViewItemMap[viewItem.itemId()] = viewItem
        }

        guard newItemIdList.count == Set(newItemIdList).count else {
            assertionFailure("New view item list has duplicates.")
            delegate?.conversationViewModelDidUpdate(.reloadUpdate())
            return
        }

        let oldItemIdSet = Set(oldItemIdList)
        let newItemIdSet = Set(newItemIdList)

        var deletedItemIdList = oldItemIdList.filter { !newItemIdSet.contains($0) }
        var insertedItemIdList = newItemIdList.filter { !oldItemIdSet.contains($0) }

        var updateItems: [ConversationUpdateItem] = []
        var transformedItemList = oldItemIdList

        for itemId in deletedItemIdList.reversed() {
            guard let oldIndex = oldItemIdList.firstIndex(of: itemId) else {
                assertionFailure("Can't find index of deleted view item.")
                delegate?.conversationViewModelDidUpdate(.reloadUpdate())
                return
            }
            updateItems.append(
                ConversationUpdateItem(
                    updateItemType: .delete,
                    oldIndex: oldIndex,
                    newIndex: NSNotFound,
                    viewItem: nil
                )
            )
            transformedItemList.removeAll { $0 == itemId }
        }

        for itemId in insertedItemIdList {
            guard let newIndex = newItemIdList.firstIndex(of: itemId),
                  let viewItem = newViewItemMap[itemId] else {
                assertionFailure("Can't find inserted view item.")
                delegate?.conversationViewModelDidUpdate(.reloadUpdate())
                return
            }
            updateItems.append(
                ConversationUpdateItem(
                    updateItemType: .insert,
                    oldIndex: NSNotFound,
                    newIndex: newIndex,
                    viewItem: viewItem
                )
            )
            transformedItemList.insert(itemId, at: newIndex)
        }

        guard newItemIdList == transformedItemList else {
//            print("New and updated view item lists don't match.")
            delegate?.conversationViewModelDidUpdate(.reloadUpdate())
            return
        }

        var finalUpdatedItemSet = updatedItemSet
        var updatedNeighborItemSet = Set<String>()

        for itemId in newItemIdSet where oldItemIdSet.contains(itemId) {
            if insertedItemIdList.contains(itemId) || finalUpdatedItemSet.contains(itemId) {
                continue
            }

            guard let newIndex = newItemIdList.firstIndex(of: itemId),
                  let viewItem = newViewItemMap[itemId] else {
                assertionFailure("Can't find holdover view item.")
                delegate?.conversationViewModelDidUpdate(.reloadUpdate())
                return
            }

            if let message = viewItem.interaction as? TSMessage, MessageInvalidator.isInvalidated(message) {
                finalUpdatedItemSet.insert(itemId)
                updatedNeighborItemSet.insert(itemId)
            }

            for deletedItemId in deletedItemIdList {
                if let oldIndex = oldItemIdList.firstIndex(of: deletedItemId),
                   oldIndex + 1 < oldItemIdList.count {
                    let nextItemId = oldItemIdList[oldIndex + 1]
                    finalUpdatedItemSet.insert(nextItemId)
                    updatedNeighborItemSet.insert(nextItemId)
                }
            }
        }

        for itemId in finalUpdatedItemSet {
            guard let oldIndex = oldItemIdList.firstIndex(of: itemId),
                  let newIndex = newItemIdList.firstIndex(of: itemId),
                  let viewItem = newViewItemMap[itemId] else {
                assertionFailure("Can't find updated view item.")
                delegate?.conversationViewModelDidUpdate(.reloadUpdate())
                return
            }
            updateItems.append(
                ConversationUpdateItem(
                    updateItemType: .update,
                    oldIndex: oldIndex,
                    newIndex: newIndex,
                    viewItem: viewItem
                )
            )
        }

        let shouldAnimate = shouldAnimateUpdateItems(updateItems, oldViewItemCount: oldItemIdList.count, updatedNeighborItemSet: updatedNeighborItemSet)

        for itemId in finalUpdatedItemSet {
            MessageInvalidator.markAsUpdated(itemId)
        }

        delegate?.conversationViewModelDidUpdate(.diffUpdate(updateItems: updateItems, shouldAnimateUpdates: shouldAnimate))
    }

    func shouldAnimateUpdateItems(
        _ updateItems: [ConversationUpdateItem],
        oldViewItemCount: Int,
        updatedNeighborItemSet: Set<String>?
    ) -> Bool {

        var isOnlyModifyingLastMessage = true

        for updateItem in updateItems {
            switch updateItem.updateItemType {
            case .delete:
                isOnlyModifyingLastMessage = false

            case .insert:
                guard let viewItem = updateItem.viewItem else {
                    assertionFailure("Expected viewItem to be non-nil for insert")
                    continue
                }

                switch viewItem.interaction.interactionType() {
                case .incomingMessage, .outgoingMessage, .typingIndicator:
                    if updateItem.newIndex < oldViewItemCount {
                        isOnlyModifyingLastMessage = false
                    }
                default:
                    isOnlyModifyingLastMessage = false
                }

            case .update:
                guard let viewItem = updateItem.viewItem else {
                    assertionFailure("Expected viewItem to be non-nil for update")
                    continue
                }

                if let neighborSet = updatedNeighborItemSet, neighborSet.contains(viewItem.itemId()) {
                    continue
                }

                switch viewItem.interaction.interactionType() {
                case .incomingMessage, .outgoingMessage, .typingIndicator:
                    
                    if updateItem.newIndex + 2 < updateItems.count {
                        isOnlyModifyingLastMessage = false
                    }
                default:
                    isOnlyModifyingLastMessage = false
                }
            }
        }

        return !isOnlyModifyingLastMessage
    }

    func createNewMessageMapping() {
        guard !thread.uniqueId!.isEmpty else {
            assertionFailure("uniqueId unexpectedly empty for thread.")
            return
        }

        messageMapping = ConversationMessageMapping(group: thread.uniqueId, desiredLength: initialMessageMappingLength)

        uiDatabaseConnection.read { transaction in
            self.messageMapping!.update(transaction: transaction)
        }
    }
    
    func resetMapping() {
        resetMapping(withAdditionalLength: 0)
    }

    func resetMapping(withAdditionalLength additionalLength: Int) {
        assert(messageMapping != nil)

        updateMessageMapping(withAdditionalLength: UInt(additionalLength))

        collapseCutoffDate = Date()

        ensureDynamicInteractionsAndUpdateIfNecessary()

        if !reloadViewItems() {
            owsFailDebug("Failed to reload view items in resetMapping.")
        }

        delegate?.conversationViewModelDidUpdate(.reloadUpdate())
    }
    
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        touchDbAsync()
    }
    
    func ensureConversationProfileState() {
        guard conversationProfileState == nil else { return }

        let profileState = ConversationProfileState()
        profileState.hasLocalProfile = true
        profileState.isThreadInProfileWhitelist = true
        profileState.hasUnwhitelistedMember = false

        conversationProfileState = profileState
    }
    
    func firstCallOrMessage(for loadedInteractions: [TSInteraction]) -> TSInteraction? {
        for interaction in loadedInteractions {
            switch interaction.interactionType() {
            case .unknown:
                return nil
            case .incomingMessage, .outgoingMessage:
                return interaction
            case .info, .call, .offer, .typingIndicator:
                continue
            }
        }
        return nil
    }
    
    func reloadViewItems() -> Bool {
        var viewItems = [ConversationViewItem]()
        var viewItemCache = [String: ConversationViewItem]()

        let loadedUniqueIds = messageMapping!.loadedUniqueIds()
        let isGroupThread = thread.isGroupThread

        ensureConversationProfileState()

        var hasError = false

        func tryToAddViewItem(interaction: TSInteraction, transaction: YapDatabaseReadTransaction) -> ConversationViewItem {
            assert(!interaction.uniqueId!.isEmpty)

            if let cached = viewItemCache[interaction.uniqueId!] {
                return cached
            }

            let viewItem = viewItemCache[interaction.uniqueId!] ?? ConversationInteractionViewItem(interaction: interaction, isGroupThread: isGroupThread(), transaction: transaction)

            assert(viewItemCache[interaction.uniqueId!] == nil)
            viewItemCache[interaction.uniqueId!] = viewItem
            viewItems.append(viewItem)

            return viewItem
        }

        var interactionIds = Set<String>()

        uiDatabaseConnection.read { transaction in
            var interactions = [TSInteraction]()

            guard let viewTransaction = transaction.ext(TSMessageDatabaseViewExtensionName) as? YapDatabaseViewTransaction else {
                assertionFailure("Missing view transaction")
                return
            }

            for uniqueId in loadedUniqueIds {
                guard let interaction = TSInteraction.fetch(uniqueId: uniqueId, transaction: transaction) else {
                    print("missing interaction in message mapping: \(uniqueId)")
                    hasError = true
                    continue
                }

                if interaction.uniqueId!.isEmpty {
                    print("invalid interaction in message mapping: \(interaction)")
                    hasError = true
                    continue
                }

                interactions.append(interaction)

                if interactionIds.contains(interaction.uniqueId!) {
                    print("Duplicate interaction: \(interaction.uniqueId)")
                    continue
                }
                interactionIds.insert(interaction.uniqueId!)
            }

            for interaction in interactions {
                _ = tryToAddViewItem(interaction: interaction, transaction: transaction)
            }
        }

        viewItems.sort { left, right in
            left.interaction.compare(forSorting: right.interaction) == .orderedAscending
        }

        if !unsavedOutgoingMessages.isEmpty {
            uiDatabaseConnection.read { transaction in
                for outgoingMessage in self.unsavedOutgoingMessages {
                    if interactionIds.contains(outgoingMessage.uniqueId!) {
                        print("Duplicate interaction: \(outgoingMessage.uniqueId)")
                        continue
                    }
                    _ = tryToAddViewItem(interaction: outgoingMessage, transaction: transaction)
                    interactionIds.insert(outgoingMessage.uniqueId!)
                }
            }
        }

        if let sender = typingIndicatorsSender {
            let typingIndicatorInteraction = TypingIndicatorInteraction(thread: thread, timestamp: NSDate.ows_millisecondTimeStamp(), recipientId: sender)
            uiDatabaseConnection.read { transaction in
                _ = tryToAddViewItem(interaction: typingIndicatorInteraction, transaction: transaction)
            }
        }

        if hasError {
            print("incrementing version of: \(TSMessageDatabaseViewExtensionName)")
            OWSPrimaryStorage.incrementVersion(ofDatabaseExtension: TSMessageDatabaseViewExtensionName)
        }

        var shouldShowDateOnNextViewItem = true
        var previousViewItemTimestamp: UInt64 = 0
        var unreadIndicator = dynamicInteractions?.unreadIndicator
        let collapseCutoffTimestamp = NSDate.ows_millisecondsSince1970(for: collapseCutoffDate!)

        var hasPlacedUnreadIndicator = false

        for viewItem in viewItems {
            let canShowDate: Bool
            switch viewItem.interaction.interactionType() {
            case .unknown, .offer, .typingIndicator:
                canShowDate = false
            case .incomingMessage, .outgoingMessage, .info, .call:
                canShowDate = true
            }

            let viewItemTimestamp = viewItem.interaction.timestamp
            assert(viewItemTimestamp > 0)

            let shouldShowDate: Bool
            if previousViewItemTimestamp == 0 {
                shouldShowDateOnNextViewItem = true
            } else {
                shouldShowDateOnNextViewItem = DateUtil.shouldShowDateBreak(forTimestamp: previousViewItemTimestamp, timestamp: viewItemTimestamp)
            }

            if shouldShowDateOnNextViewItem && canShowDate {
                shouldShowDate = true
                // shouldShowDateOnNextViewItem = false
            } else {
                shouldShowDate = false
            }

            viewItem.shouldShowDate = shouldShowDate

            previousViewItemTimestamp = viewItemTimestamp

            let isItemUnread = (viewItem.interaction as? OWSReadTracking)?.read == false

            if isItemUnread, unreadIndicator == nil, !hasPlacedUnreadIndicator, !hasClearedUnreadMessagesIndicator {
                unreadIndicator = OWSUnreadIndicator(firstUnseenSortId: viewItem.interaction.sortId,
                                                     hasMoreUnseenMessages: false,
                                                     missingUnseenSafetyNumberChangeCount: 0,
                                                     unreadIndicatorPosition: 0)
            }

            if let indicator = unreadIndicator, viewItem.interaction.sortId >= indicator.firstUnseenSortId {
                viewItem.unreadIndicator = indicator
                unreadIndicator = nil
                hasPlacedUnreadIndicator = true
            } else {
                viewItem.unreadIndicator = nil
            }
        }

        if unreadIndicator != nil {
            print("Couldn't find an interaction to hang the unread indicator on.")
        }

        for i in 0..<viewItems.count {
            let viewItem = viewItems[i]
            let previousViewItem = i > 0 ? viewItems[i - 1] : nil
            let nextViewItem = i + 1 < viewItems.count ? viewItems[i + 1] : nil

            var shouldShowSenderProfilePicture = false
            var shouldHideFooter = false
            var isFirstInCluster = true
            var isLastInCluster = true
            var senderName: NSAttributedString? = nil

            let interactionType = viewItem.interaction.interactionType()
            let timestampText = DateUtil.formatTimestampShort(viewItem.interaction.timestamp)

            switch interactionType {
            case .outgoingMessage:
                guard let outgoingMessage = viewItem.interaction as? TSOutgoingMessage else { break }
                let receiptStatus = MessageRecipientStatusUtils.recipientStatus(outgoingMessage: outgoingMessage)
                let isDisappearingMessage = outgoingMessage.isExpiringMessage

                if let next = nextViewItem, next.interaction.interactionType() == interactionType {
                    if let nextOutgoingMessage = next.interaction as? TSOutgoingMessage {
                        let nextReceiptStatus = MessageRecipientStatusUtils.recipientStatus(outgoingMessage: nextOutgoingMessage)
                        let nextTimestampText = DateUtil.formatTimestampShort(next.interaction.timestamp)

                        shouldHideFooter = (timestampText == nextTimestampText
                            && receiptStatus == nextReceiptStatus
                            && outgoingMessage.messageState != .failed
                            && outgoingMessage.messageState != .sending
                            && !next.hasCellHeader
                            && !isDisappearingMessage)
                    }
                }

                isFirstInCluster = previousViewItem == nil || viewItem.hasCellHeader || previousViewItem?.interaction.interactionType() != .outgoingMessage
                isLastInCluster = nextViewItem == nil || nextViewItem!.hasCellHeader || nextViewItem!.interaction.interactionType() != .outgoingMessage

            case .incomingMessage:
                guard let incomingMessage = viewItem.interaction as? TSIncomingMessage else { break }
                let incomingSenderId = incomingMessage.authorId
                assert(!incomingSenderId.isEmpty)
                let isDisappearingMessage = incomingMessage.isExpiringMessage

                var nextIncomingSenderId: String? = nil
                if let next = nextViewItem, next.interaction.interactionType() == interactionType,
                   let nextIncomingMessage = next.interaction as? TSIncomingMessage {
                    nextIncomingSenderId = nextIncomingMessage.authorId
                    assert(!(nextIncomingSenderId?.isEmpty ?? true))
                }

                if let next = nextViewItem, next.interaction.interactionType() == interactionType {
                    let nextTimestampText = DateUtil.formatTimestampShort(next.interaction.timestamp)
                    shouldHideFooter = (timestampText == nextTimestampText
                        && !next.hasCellHeader
                        && nextIncomingSenderId == incomingSenderId
                        && !isDisappearingMessage)
                }

                if previousViewItem == nil || viewItem.hasCellHeader || previousViewItem!.interaction.interactionType() != .incomingMessage {
                    isFirstInCluster = true
                } else if let previousIncomingMessage = previousViewItem!.interaction as? TSIncomingMessage {
                    isFirstInCluster = incomingSenderId != previousIncomingMessage.authorId
                }

                if nextViewItem == nil || nextViewItem!.interaction.interactionType() != .incomingMessage || nextViewItem!.hasCellHeader {
                    isLastInCluster = true
                } else if let nextIncomingMessage = nextViewItem!.interaction as? TSIncomingMessage {
                    isLastInCluster = incomingSenderId != nextIncomingMessage.authorId
                }

                if viewItem.isGroupThread {
                    var shouldShowSenderName = true
                    if let previous = previousViewItem, previous.interaction.interactionType() == interactionType,
                       let previousIncomingMessage = previous.interaction as? TSIncomingMessage {
                        let previousIncomingSenderId = previousIncomingMessage.authorId
                        shouldShowSenderName = (previousIncomingSenderId != incomingSenderId) || viewItem.hasCellHeader
                    }

                    if shouldShowSenderName {
                        let context = Contact.context(for: thread)
                        let displayName = Storage.shared.getContact(with: incomingSenderId)?.displayName(for: context) ?? incomingSenderId
                        senderName = NSAttributedString(string: displayName)
                    }

                    shouldShowSenderProfilePicture = true
                    if let nextSenderId = nextIncomingSenderId {
                        shouldShowSenderProfilePicture = (nextSenderId != incomingSenderId)
                    }
                }

            default:
                break
            }

            if viewItem.interaction.receivedAtTimestamp > collapseCutoffTimestamp {
                shouldHideFooter = false
            }

            viewItem.isFirstInCluster = isFirstInCluster
            viewItem.isLastInCluster = isLastInCluster
            viewItem.shouldShowSenderProfilePicture = shouldShowSenderProfilePicture
            viewItem.shouldHideFooter = shouldHideFooter
            viewItem.senderName = senderName
            viewItem.wasPreviousItemInfoMessage = previousViewItem?.interaction.interactionType() == .info
        }

        viewState = ConversationViewState(viewItems: viewItems)
        self.viewItemCache = viewItemCache

        return !hasError
    }

    
    func appendUnsavedOutgoingTextMessage(_ outgoingMessage: TSOutgoingMessage) {

        var messages = unsavedOutgoingMessages
        messages.append(outgoingMessage)
        unsavedOutgoingMessages = messages

        updateForTransientItems()
    }

    
    func reloadInteraction(for viewItem: ConversationViewItem) {
        assert(Thread.isMainThread)
        
        uiDatabaseConnection.read { transaction in
            guard let updatedInteraction = TSInteraction.fetch(uniqueId: viewItem.interaction.uniqueId!, transaction: transaction) else {
//                print("Could not reload interaction")
                return
            }
            viewItem.replaceInteraction(updatedInteraction, transaction: transaction)
        }
    }
    
    func ensureLoadWindowContainsQuotedReply(_ quotedReply: OWSQuotedReplyModel) -> IndexPath? {
        assert(Thread.isMainThread)
        assert(quotedReply.timestamp > 0)
        assert(!quotedReply.authorId.isEmpty)

        if quotedReply.isRemotelySourced {
            return nil
        }

        var indexPath: IndexPath?

        uiDatabaseConnection.read { transaction in
            guard let quotedInteraction = ThreadUtil.findInteractionInThread(
                byTimestamp: quotedReply.timestamp,
                authorId: quotedReply.authorId,
                threadUniqueId: self.thread.uniqueId!,
                transaction: transaction
            ) else {
                return
            }

            indexPath = self.messageMapping!.ensureLoadWindowContains(
                uniqueId: quotedInteraction.uniqueId!,
                transaction: transaction
            )
        }

        self.collapseCutoffDate = Date()

        self.ensureDynamicInteractionsAndUpdateIfNecessary()

        if !self.reloadViewItems() {
            assertionFailure("Failed to reload view items in resetMapping.")
        }

        self.delegate?.conversationViewModelDidUpdate(.reloadUpdate())
        self.delegate?.conversationViewModelRangeDidChange()

        return indexPath
    }
    
    func ensureLoadWindowContainsInteractionId(_ interactionId: String) -> IndexPath? {
        assert(Thread.isMainThread)
        assert(!interactionId.isEmpty)

        var indexPath: IndexPath?

        uiDatabaseConnection.read { transaction in
            indexPath = self.messageMapping!.ensureLoadWindowContains(uniqueId: interactionId, transaction: transaction)
        }

        collapseCutoffDate = Date()
        ensureDynamicInteractionsAndUpdateIfNecessary()

        if !reloadViewItems() {
//            print("Failed to reload view items in ensureLoadWindowContainsInteractionId.")
        }

        delegate?.conversationViewModelDidUpdate(.reloadUpdate())
        delegate?.conversationViewModelRangeDidChange()

        return indexPath
    }
    
    func findGroupIndex(of interaction: TSInteraction, in transaction: YapDatabaseReadTransaction) -> NSNumber? {
        guard let extensionView = transaction.ext(TSMessageDatabaseViewExtensionName) as? YapDatabaseAutoViewTransaction else {
//            print("Couldn't load view.")
            return nil
        }

        var groupIndex: UInt = 0
        let found = extensionView.getGroup(nil, index: &groupIndex, forKey: interaction.uniqueId!, inCollection: TSInteraction.collection())

        if !found {
            Logger.error("Couldn't find quoted message in group.")
            return nil
        }

        return NSNumber(value: groupIndex)
    }
    
    
    @objc func typingIndicatorStateDidChange(_ notification: Notification) {
        assert(Thread.isMainThread)

        if let notifiedId = notification.object as? String, notifiedId != thread.uniqueId {
            return
        }

        typingIndicatorsSender = typingIndicators.typingRecipientId(forThread: thread)
    }
    
    
    
    
}
