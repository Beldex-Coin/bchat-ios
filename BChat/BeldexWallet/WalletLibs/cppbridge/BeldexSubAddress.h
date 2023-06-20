//
//  BeldexSubAddress.h
//  beldex-ios-wallet
//
//  Created by Beldex International Limited OU on 14/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BeldexSubAddress : NSObject

@property (nonatomic, assign, readonly) size_t rowId;
@property (nonatomic, copy, readonly) NSString * address;
@property (nonatomic, copy, readonly) NSString * label;

- (instancetype)initWithRowId:(size_t)rowId address:(NSString *)address label:(NSString *)label;

@end

NS_ASSUME_NONNULL_END
