//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import <BChatMessagingKit/TSThread.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const TSContactThreadPrefix;

@interface TSContactThread : TSThread

- (instancetype)initWithContactBChatID:(NSString *)contactBChatID;

+ (instancetype)getOrCreateThreadWithContactBChatID:(NSString *)contactBChatID NS_SWIFT_NAME(getOrCreateThread(contactBChatID:));

+ (instancetype)getOrCreateThreadWithContactBChatID:(NSString *)contactBChatID
                                          transaction:(YapDatabaseReadWriteTransaction *)transaction;

// Unlike getOrCreateThreadWithContactBChatID, this will _NOT_ create a thread if one does not already exist.
+ (nullable instancetype)getThreadWithContactBChatID:(NSString *)contactBChatID transaction:(YapDatabaseReadTransaction *)transaction NS_SWIFT_NAME(fetch(for:using:));

- (NSString *)contactBChatID;

+ (NSString *)contactBChatIDFromThreadID:(NSString *)threadId;

+ (NSString *)threadIDFromContactBChatID:(NSString *)contactBChatID;

@end

NS_ASSUME_NONNULL_END
