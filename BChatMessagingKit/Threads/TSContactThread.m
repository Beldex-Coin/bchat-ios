//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "TSContactThread.h"
#import <YapDatabase/YapDatabase.h>
#import <BChatMessagingKit/BChatMessagingKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

NSString *const TSContactThreadPrefix = @"c";

@implementation TSContactThread

- (instancetype)initWithContactBChatID:(NSString *)contactBChatID {
    NSString *uniqueIdentifier = [[self class] threadIDFromContactBChatID:contactBChatID];

    self = [super initWithUniqueId:uniqueIdentifier];

    return self;
}

+ (instancetype)getOrCreateThreadWithContactBChatID:(NSString *)contactBChatID
                                   transaction:(YapDatabaseReadWriteTransaction *)transaction {
    TSContactThread *thread =
        [self fetchObjectWithUniqueID:[self threadIDFromContactBChatID:contactBChatID] transaction:transaction];

    if (!thread) {
        thread = [[TSContactThread alloc] initWithContactBChatID:contactBChatID];
        [thread saveWithTransaction:transaction];
    }

    return thread;
}

+ (instancetype)getOrCreateThreadWithContactBChatID:(NSString *)contactBChatID
{
    __block TSContactThread *thread;
    [LKStorage writeSyncWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        thread = [self getOrCreateThreadWithContactBChatID:contactBChatID transaction:transaction];
    }];

    return thread;
}

+ (nullable instancetype)getThreadWithContactBChatID:(NSString *)contactBChatID transaction:(YapDatabaseReadTransaction *)transaction;
{
    return [TSContactThread fetchObjectWithUniqueID:[self threadIDFromContactBChatID:contactBChatID] transaction:transaction];
}

- (NSString *)contactBChatID {
    return [[self class] contactBChatIDFromThreadID:self.uniqueId];
}

- (NSArray<NSString *> *)recipientIdentifiers
{
    return @[ self.contactBChatID ];
}

- (BOOL)isMessageRequest {
    NSString *bchatID = self.contactBChatID;
    SNContact *contact = [LKStorage.shared getContactWithBChatID:bchatID];
    
    return (
        self.shouldBeVisible &&
        !self.isNoteToSelf && (
           contact == nil ||
           !contact.isApproved
        )
    );
}

- (BOOL)isMessageRequestUsingTransaction:(YapDatabaseReadTransaction *)transaction {
    NSString *bchatID = self.contactBChatID;
    SNContact *contact = [LKStorage.shared getContactWithBChatID:bchatID using:transaction];
    
    return (
        self.shouldBeVisible &&
        !self.isNoteToSelf && (
           contact == nil ||
           !contact.isApproved
        )
    );
}

- (BOOL)isBlocked {
    NSString *bchatID = self.contactBChatID;
    SNContact *contact = [LKStorage.shared getContactWithBChatID:bchatID];
    
    return (contact.isBlocked == YES);
}

- (BOOL)isBlockedUsingTransaction:(YapDatabaseReadTransaction *)transaction {
    NSString *bchatID = self.contactBChatID;
    SNContact *contact = [LKStorage.shared getContactWithBChatID:bchatID using:transaction];
    
    return (contact.isBlocked == YES);
}

- (BOOL)isGroupThread
{
    return NO;
}

- (NSString *)name
{
    NSString *bchatID = self.contactBChatID;
    SNContact *contact = [LKStorage.shared getContactWithBChatID:bchatID];
    return [contact displayNameFor:SNContactContextRegular] ?: bchatID;
}

- (NSString *)nameWithTransaction:(YapDatabaseReadTransaction *)transaction
{
    NSString *bchatID = self.contactBChatID;
    SNContact *contact = [LKStorage.shared getContactWithBChatID:bchatID using:transaction];
    return [contact displayNameFor:SNContactContextRegular] ?: bchatID;
}

+ (NSString *)threadIDFromContactBChatID:(NSString *)contactBChatID {
    return [TSContactThreadPrefix stringByAppendingString:contactBChatID];
}

+ (NSString *)contactBChatIDFromThreadID:(NSString *)threadId {
    return [threadId substringWithRange:NSMakeRange(1, threadId.length - 1)];
}

@end

NS_ASSUME_NONNULL_END
