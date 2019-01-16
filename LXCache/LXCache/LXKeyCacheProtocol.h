//
//  LXKeyCacheProtocol.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/14.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import "LXCacheDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LXKeyCacheProtocol <NSObject>
@property (nonatomic, copy) NSString * key;
@property (nonatomic, copy) NSString * identify;

@end

NS_ASSUME_NONNULL_END
