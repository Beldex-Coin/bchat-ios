//
//  BeldexWalletListener.h
//  beldex-ios-wallet
//
//  Created by Beldex International Limited OU on 16/11/22.
//

#import <Foundation/Foundation.h>

typedef void (^BeldexWalletRefreshHandler)(void);
typedef void (^BeldexWalletNewBlockHandler)(uint64_t curreneight);

NS_ASSUME_NONNULL_BEGIN

@interface BeldexWalletListener : NSObject

@property (nonatomic, strong) BeldexWalletRefreshHandler refreshHandler;
@property (nonatomic, strong) BeldexWalletNewBlockHandler newBlockHandler;

@end

NS_ASSUME_NONNULL_END
