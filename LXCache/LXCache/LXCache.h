//
//  LXCache.h
//  LXCache
//
//  Created by 麻小亮 on 2018/12/10.
//  Copyright © 2018年 xllpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXSeparateCache.h"
NS_ASSUME_NONNULL_BEGIN

@interface LXCache : NSObject

//单例
+ (LXCache *)defaultCache;

//创建一个缓存管理工具
- (instancetype)initWithPath:(NSString *)path;


//默认缓存实例
@property (nonatomic, strong, readonly) LXSeparateCache * defaultSeparate;

//分区缓存实例
@property (nonatomic, copy, readonly) LXSeparateCache *(^ identity) (NSString * identity);

- (void)removeSeparaCacheWithIdentity:(NSString *)identity;

- (CGFloat)totalSize;

@end

NS_ASSUME_NONNULL_END