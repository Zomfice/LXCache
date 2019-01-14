//
//  LXKeyCacheProtocol.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/14.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LXKeyCacheProtocol <NSObject>
- (NSString *)getKey;
- (NSString *)getIdentify;
- (NSTimeInterval)getMemoryTime;
- (NSTimeInterval)getDiskTime;
- (BOOL)isClearWhenTimeOut;
@end

NS_ASSUME_NONNULL_END
