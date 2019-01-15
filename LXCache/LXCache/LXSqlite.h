//
//  LXSqlite.h
//  LXCache
//
//  Created by 麻小亮 on 2018/12/11.
//  Copyright © 2018 xllpp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXSqlite : NSObject

//设置地址
- (instancetype)initWithPath:(NSString *)path;

//设置账号密码
- (void)setUserName:(NSString *)userName password:(NSString *)password;

//更新账号密码
- (void)updateUserName:(NSString *)userName password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
