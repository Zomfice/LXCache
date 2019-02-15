//
//  LXSqlite.h
//  LXCache
//
//  Created by 麻小亮 on 2018/12/11.
//  Copyright © 2018 xllpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXCacheProtocol.h"
NS_ASSUME_NONNULL_BEGIN
@class LXSqlite;

@interface LXSqlite : NSObject

//设置地址
- (instancetype)initWithPath:(NSString *)path;

//设置账号密码
- (void)openUserName:(NSString *)userName password:(NSString *)password;

//更新账号密码
- (BOOL)updatePassword:(NSString *)password;


/**
 获取键值对应数值的数量
 */
- (int)getItemCoutWithKey:(NSString *)key withTable:(NSString *)tableName;

/**
 查询数据库的大小
 */
- (int)getTotalItemSizeWithTable:(NSString *)tableName;

/**
 获取数据库总大小
 */
- (int)getTotalSize;
/**
 获取表中一个键值的总个数
 */
- (int)getTotalItemCoutWithTable:(NSString *)tableName;

/**
 根据key值获取文件地址
 */
- (NSMutableArray *)getFileNameWithKeys:(NSArray *)keys withTable:(NSString *)tableName;

/**
 移除key
 */
- (BOOL)removeItemForKey:(NSString *)key withTable:(NSString *)tableName;

- (BOOL)removeItemForKeys:(NSString *)keys withTable:(NSString *)tableName;


/**
 缓存数据
 */

- (BOOL)setObject:(NSData *)data withKey:(id <LXCacheKeyProtocol>)key extendedData:(NSData *)data withTable:(NSString *)tableName;


@end

NS_ASSUME_NONNULL_END
