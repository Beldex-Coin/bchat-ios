//
//  BeldexSubAddress.m
//  beldex-ios-wallet
//
//  Created by Blockhash on 14/11/22.
//

#import "BeldexSubAddress.h"

@implementation BeldexSubAddress

- (instancetype)initWithRowId:(size_t)rowId address:(NSString *)address label:(NSString *)label {
    if (self = [super init]) {
        _rowId = rowId;
        _address = address;
        _label = label;
    }
    return self;
}

@end
