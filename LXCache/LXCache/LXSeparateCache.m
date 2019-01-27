//
//  LXSeparateCache.m
//  LXCache
//
//  Created by 麻小亮 on 2019/1/27.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import "LXSeparateCache.h"


@interface LXSeparateSetObject : NSObject<LXCacheKeyProtocol>

@end

@interface LXSeparateObtainObject : NSObject<LXCacheObtainProtocol>

@end
@implementation LXSeparateSetObject
@synthesize cacheType = _cacheType, memoryTime = _memoryTime, diskTime = _diskTime, cacheStatus = _cacheStatus, isClearWhenTimeOut = _isClearWhenTimeOut, key = _key,identify = _identify, saveTime = _saveTime;
- (instancetype)init
{
    self = [super init];
    if (self) {
        _memoryTime = -1;
        _diskTime = -1;
    }
    return self;
}


@end

@implementation LXSeparateObtainObject
@synthesize resultStatus = _resultStatus, memoryTime = _memoryTime, diskTime = _diskTime;
- (instancetype)init
{
    self = [super init];
    if (self) {
        _resultStatus = LXCacheResultNormarl;
    }
    return self;
}
@end
@interface LXSeparateCache ()<LXCacheSeparateProtocol>{
    NSString *_identity;
    LXSqlite *_sqlite;
    CGFloat _totoSize;
    NSTimeInterval _useDiskTimeOut;
    NSTimeInterval _useMemoryTimeOut;
    NSTimeInterval _defaultDiskTimeOut;
    NSTimeInterval _defaultMemeryTimeOut;
    NSTimeInterval _defaltIsClear;
    
}
@end
@implementation LXSeparateCache

- (instancetype)initWithIdentity:(NSString *)identity sqlite:(nonnull LXSqlite *)sqlite{
    if (self = [super init]) {
        _identity = identity;
        _sqlite = sqlite;
    }
    return self;
}

- (BOOL)containsObjectForKey:(NSString *)key{
    return [self containsObjectForKey:key moreInfo:^(id<LXCacheObtainProtocol> info) {
        info.resultStatus = LXCacheResultNormarl;
    }];
}

- (BOOL)containsObjectForKey:(NSString *)key moreInfo:(moreObtainInfo)info{
    LXCacheResultStatus status;
    if (info) {
        LXSeparateObtainObject *object = [LXSeparateObtainObject new];
        info(object);
        status = object.resultStatus;
    }else{
        status = LXCacheResultNormarl;
    }
    
    if (status == LXCacheResultNever) return NO;
    return YES;
}

- (id<LXCacheSeparateProtocol>)separateCache{
    return self;
}



- (CGFloat)cacheSize{
    return _totoSize;
}

@end
