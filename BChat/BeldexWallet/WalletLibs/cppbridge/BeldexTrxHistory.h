//
//  BeldexTrxHistory.h
//  beldex-ios-wallet
//
//  Created by Blockhash on 16/11/22.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TrxDirection) {
    TrxDirection_In,
    TrxDirection_Out,
};

typedef NS_ENUM(NSUInteger, PendingTransactionPriority) {
    PendingTransactionPriority_Default = 5,
    PendingTransactionPriority_Low = 1,
    PendingTransactionPriority_Medium = 2,
    PendingTransactionPriority_High = 3,
    PendingTransactionPriority_Last
};


NS_ASSUME_NONNULL_BEGIN

@interface BeldexTrxHistory : NSObject

@property (nonatomic, assign) TrxDirection direction;
@property (nonatomic, assign) BOOL isPending;
@property (nonatomic, assign) BOOL isFailed;
@property (nonatomic, assign) uint64_t amount;
@property (nonatomic, assign) uint64_t fee;
@property (nonatomic, assign) uint64_t blockHeight;
@property (nonatomic, assign) uint64_t confirmations;
@property (nonatomic, assign) uint64_t unlockTime;
@property (nonatomic, assign) time_t timestamp;
@property (nonatomic, copy) NSString * label;
@property (nonatomic, copy) NSString * hashValue;
@property (nonatomic, copy) NSString * paymentId;
@property (nonatomic, copy) NSString * address;

@end

NS_ASSUME_NONNULL_END
