//
//  LXCacheProtocol.m
//  LXCache
//
//  Created by 麻小亮 on 2019/1/17.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import "LXCacheProtocol.h"
#import "NSObject+LXCategory.h"
#import "LXProtocolExtension.h"

#define LXMethodInstall(_return_,...)\
if (!self.separateCache) return _return_;\
__VA_ARGS__;

#pragma mark - LXCacheSeparateProtocol默认实现  -
@protocolExtension(LXCacheSeparateProtocol)

@synthesize delegate = _delegate;

- (BOOL)removeSeparaAllCache{
    LXMethodInstall(NO,return [self.separateCache removeSeparaAllCache]);
}

- (void)removeSeparaAllCacheWithBlock:(void (^)(BOOL))block{
    LXMethodInstall(,[self.separateCache removeSeparaAllCacheWithBlock:block]);
}

- (BOOL)containsObjectForKey:(NSString *)key{
    LXMethodInstall(NO,return [self.separateCache containsObjectForKey:key])
}

- (BOOL)containsObjectForKey:(NSString *)key moreInfo:(moreObtainInfo)info{
    LXMethodInstall(NO,return [self.separateCache containsObjectForKey:key moreInfo:info])
}

- (void)containsSynObjectForKey:(NSString *)key
withBlock:(void (^) (BOOL contains, id <LXCacheKeyProtocol> info))block{
    LXMethodInstall(,[self.separateCache containsSynObjectForKey:key withBlock:block])
}

- (void)containsAsynObjectDetailForKey:(NSString *)key
withBlock:(void (^) (BOOL contains, id <LXCacheKeyProtocol> info))block{
    LXMethodInstall(,[self.separateCache containsAsynObjectDetailForKey:key withBlock:block])
}

- (id<NSCoding>)objectForKey:(NSString *)key{
    LXMethodInstall(nil,return [self.separateCache objectForKey:key])
}

- (id<NSCoding>)objectForKey:(NSString *)key moreInfo:(moreObtainInfo)moreInfo{
    LXMethodInstall(nil,return [self.separateCache objectForKey:key moreInfo:moreInfo])
}

- (void)objectSynForKey:(NSString *)key
withBlock:(void (^) (NSString *key, id <NSCoding>object, id <LXCacheKeyProtocol> info))block{
    LXMethodInstall(,[self.separateCache objectSynForKey:key withBlock:block])
}

- (void)objectAsynForKey:(NSString *)key
withBlock:(void (^) (NSString *key, id <NSCoding>object, id <LXCacheKeyProtocol> info))block{
    LXMethodInstall(,[self.separateCache objectAsynForKey:key withBlock:block])
}

- (BOOL)setObject:(id <NSCoding>)object forKey:(NSString *)key{
    LXMethodInstall(NO,return [self.separateCache setObject:object forKey:key])
}

- (BOOL)setObject:(id <NSCoding>)object forKey:(NSString *)key moreInfo:(moreSetInfo)info{
    LXMethodInstall(NO,return [self.separateCache setObject:object forKey:key moreInfo:info])
}
- (void)setObject:(id <NSCoding>)object
forKey:(NSString *)key
withBlock:(void (^) (NSString *key, id <NSCoding>object, BOOL isSuccess))block{
    LXMethodInstall(,[self.separateCache setObject:object forKey:key withBlock:block])
}

- (void)setObject:(id <NSCoding>)object
moreInfo:(moreSetInfo)info
forKey:(NSString *)key
withBlock:(void (^) (NSString *key, id <NSCoding>object, BOOL isSuccess))block{
    LXMethodInstall(,[self.separateCache setObject:object moreInfo:info forKey:key withBlock:block])
}


- (BOOL)removeObjectForKey:(NSString *)key{
    LXMethodInstall(NO, return [self.separateCache removeObjectForKey:key])
}

- (void)removeObjectForKey:(NSString *)key
withBlock:(void (^) (NSString *key, id <NSCoding> object))block{
    LXMethodInstall(, [self.separateCache removeObjectForKey:key withBlock:block])
}

- (void)setDefaultMemoryTime:(NSTimeInterval)memoryTime
diskTime:(NSTimeInterval)diskTime
isClearWhenTimeOut:(BOOL)isClearWhenTimeOut{
    LXMethodInstall(,[self.separateCache setDefaultMemoryTime:memoryTime diskTime:diskTime isClearWhenTimeOut:isClearWhenTimeOut])
}

- (void)setUseDiskTime:(NSTimeInterval)diskTime{
    LXMethodInstall(,[self.separateCache setUseDiskTime:diskTime]);
}

- (CGFloat)cacheSize{
    LXMethodInstall(0, return [self.separateCache cacheSize]);
}

@end
#undef LXMethodInstall
