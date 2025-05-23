//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import <BChatUtilitiesKit/TSYapDatabaseObject.h>

NS_ASSUME_NONNULL_BEGIN

BOOL IsNoteToSelfEnabled(void);

@class OWSDisappearingMessagesConfiguration;
@class TSInteraction;

/**
 *  TSThread is the superclass of TSContactThread and TSGroupThread
 */
@interface TSThread : TSYapDatabaseObject

@property (nonatomic) BOOL isPinned;
@property (nonatomic) BOOL shouldBeVisible;
@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly, nullable) NSDate *lastInteractionDate;
@property (nonatomic, readonly) TSInteraction *lastInteraction;
@property (atomic, readonly) BOOL isMuted;
@property (atomic, readonly, nullable) NSDate *mutedUntilDate;
@property (nonatomic) BOOL isArchived;

/**
 *  Whether the object is a group thread or not.
 *
 *  @return YES if is a group thread, NO otherwise.
 */
- (BOOL)isGroupThread;

/**
 *  Returns the name of the thread.
 *
 *  @return The name of the thread.
 */
- (NSString *)name;

- (NSString *)nameWithTransaction:(YapDatabaseReadTransaction *)transaction;

/**
 * @returns recipientId for each recipient in the thread
 */
@property (nonatomic, readonly) NSArray<NSString *> *recipientIdentifiers;

- (BOOL)isNoteToSelf;

/**
 *  Whether the thread is a message request.
 *
 *  @return YES if the combination of thread and contact approval means this thread should appear in the message requests section, NO otherwise.
 */
- (BOOL)isMessageRequest;
- (BOOL)isMessageRequestUsingTransaction:(YapDatabaseReadTransaction *)transaction;

- (BOOL)isBlocked;
- (BOOL)isBlockedUsingTransaction:(YapDatabaseReadTransaction *)transaction;

#pragma mark Interactions

- (void)enumerateInteractionsWithTransaction:(YapDatabaseReadTransaction *)transaction usingBlock:(void (^)(TSInteraction *interaction, BOOL *stop))block;

- (void)enumerateInteractionsUsingBlock:(void (^)(TSInteraction *interaction))block;

/**
 *  @return The number of interactions in this thread.
 */
- (NSUInteger)numberOfInteractions;

- (NSUInteger)numberOfInteractionsWithTransaction:(YapDatabaseReadTransaction *)transaction;

- (NSUInteger)unreadMessageCountWithTransaction:(YapDatabaseReadTransaction *)transaction
    NS_SWIFT_NAME(unreadMessageCount(transaction:));

/**
 *  @return If there is any message mentioning current user in this thread.
 */
- (NSUInteger)unreadMentionMessageCount;

- (NSUInteger)unreadMentionMessageCountWithTransaction:(YapDatabaseReadTransaction *)transaction;

- (void)markAllAsReadWithTransaction:(YapDatabaseReadWriteTransaction *)transaction;

/**
 *  Returns the string that will be displayed typically in a conversations view as a preview of the last message
 *  received in this thread.
 *
 *  @return Thread preview string.
 */
- (NSString *)lastMessageTextWithTransaction:(YapDatabaseReadTransaction *)transaction
    NS_SWIFT_NAME(lastMessageText(transaction:));

- (nullable TSInteraction *)lastInteractionForInboxWithTransaction:(YapDatabaseReadTransaction *)transaction
    NS_SWIFT_NAME(lastInteractionForInbox(transaction:));

/**
 *  Updates the thread's caches of the latest interaction.
 *
 *  @param lastMessage Latest Interaction to take into consideration.
 *  @param transaction Database transaction.
 */
- (void)updateWithLastMessage:(TSInteraction *)lastMessage transaction:(YapDatabaseReadWriteTransaction *)transaction;

- (void)removeAllThreadInteractionsWithTransaction:(YapDatabaseReadWriteTransaction *)transaction;

- (TSInteraction *)getLastInteractionWithTransaction:(YapDatabaseReadTransaction *)transaction;

#pragma mark Disappearing Messages

- (OWSDisappearingMessagesConfiguration *)disappearingMessagesConfigurationWithTransaction:
    (YapDatabaseReadTransaction *)transaction;

- (uint32_t)disappearingMessagesDurationWithTransaction:(YapDatabaseReadTransaction *)transaction;

#pragma mark Drafts

/**
 *  Returns the last known draft for that thread. Always returns a string. Empty string if nil.
 *
 *  @param transaction Database transaction.
 *
 *  @return Last known draft for that thread.
 */
- (NSString *)currentDraftWithTransaction:(YapDatabaseReadTransaction *)transaction;

/**
 *  Sets the draft of a thread. Typically called when leaving a conversation view.
 *
 *  @param draftString Draft string to be saved.
 *  @param transaction Database transaction.
 */
- (void)setDraft:(NSString *)draftString transaction:(YapDatabaseReadWriteTransaction *)transaction;

#pragma mark Muting

- (void)updateWithMutedUntilDate:(NSDate * _Nullable)mutedUntilDate transaction:(YapDatabaseReadWriteTransaction *)transaction;

@end

NS_ASSUME_NONNULL_END
