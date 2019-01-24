//
//  LXCache.h
//  LXCache
//
//  Created by 麻小亮 on 2018/12/10.
//  Copyright © 2018年 xllpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXCacheProtocol.h"
@interface LXCache : NSObject<LXCacheSeparateProtocol,LXGlobalCacheProtocol>

//单例
+ (LXCache *)defaultCache;

/**
 根据路径和账号密码来初始化缓存库，如果库不存在，则创建;
 如果没有设置账号密码则设置账号密码，如果有，则验证;
 验证密码成功打开数据，验证失败，返回nil
 */
- (LXCache *)initWithPath:(NSString *)path;

/**
 通过账号密码进入数据库
 如果没有设置，则为创建账号密码
 */
- (void)openWithUserName:(NSString *)userName password:(NSString *)password;

/**
 更新密码
 没有设置密码则不会更新
 */
- (void)updatePassword:(NSString *)password;


/**
 创建一个自定义缓存管理分区
 
 @param identity 分区标识
 @return 返回一个可操作的缓存分区
 */
@property (nonatomic, copy, readonly, nullable) id <LXCacheSeparateProtocol>  (^ identity) (NSString * identity);


#pragma mark - 移除缓存 -

/**
 移除某个缓存分区，会清除此分区
 @param identity 标识
 @return 是否成功
 */
- (BOOL)removeSeparaCacheWithIdentity:(NSString *)identity;

- (void)removeSeparaCacheWithIdentity:(NSString *)identity withBlock:(void (^) (BOOL success))block;

/**
 移除默认缓存分区，只会清除数据

 @return 是否成功
 */
- (BOOL)removeDefaultSeparaCache;

- (void)removeDefaultSeparaCacheWithBlock:(void (^) (BOOL success))block;


/**
 移除所有分区，默认分区会清除数据，不会移除数据库
 */
- (BOOL)removeAllSeparaCache;

- (void)removeAllSeparaCacheWithBlock:(void (^) (NSProgress *progress))block complete:(void (^) (BOOL success))complete;

/**
 删除数据库
 */
- (BOOL)deleteCache;

- (void)deleteCacheWithBlock:(void (^) (NSProgress *progress))block complete:(void (^) (BOOL success))complete;

/**
 内存总大小
 */
- (CGFloat)totalCacheSize;

/**
 黑名单: 统计全局数据时这些标识不会处理
 白名单：统计数据时只处理这些数据
 
 优先级：黑名单大于白名单
 */
- (void)cacheWithBlackIdentities:(NSArray <NSString *>*)identities;

- (void)cacheWithWhiteIdentities:(NSArray <NSString *>*)identities;

@end

