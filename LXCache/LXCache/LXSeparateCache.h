//
//  LXSeparateCache.h
//  LXCache
//
//  Created by 麻小亮 on 2018/12/10.
//  Copyright © 2018年 xllpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXSeparateCacheProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface LXSeparateCache : NSObject<LXSeparateCacheProtocol>
- (instancetype)initWithIdentity:(NSString *)identity;
@end

NS_ASSUME_NONNULL_END
