//
//  LXCache.m
//  LXCache
//
//  Created by 麻小亮 on 2018/12/10.
//  Copyright © 2018年 xllpp. All rights reserved.
//

#import "LXCache.h"
#import "LXSafeDictionary.h"
#import "LXSqlite.h"
#define kLXDefalutCachePath @".kLXDeafultCache"
#define kLXDefalutIdentify @".kLXDeafultCacheIdentify"
#pragma mark - _lxKeyObject -

@interface _lxSetObject : NSObject<LXCacheKeyProtocol>

@end

@implementation _lxSetObject
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

@interface _lxObtainObject : NSObject<LXCacheObtainProtocol>

@end

@implementation _lxObtainObject
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

#pragma mark - LXSeparateCache -


@interface LXSeparateCache : NSObject<LXCacheSeparateDelegate, LXCacheSeparateProtocol>

@property (nonatomic, copy) NSString * identity;


@end

@implementation LXSeparateCache

- (instancetype)initWithIdentity:(NSString *)identity{
    if (self = [super init]) {
        self.identity = identity;
        
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
        _lxObtainObject *object = [_lxObtainObject new];
        info(object);
        status = object.resultStatus;
    }else{
        status = LXCacheResultNormarl;
    }
    NSLog(@"%lu", status);
    if (status == LXCacheResultNever) return NO;
    return YES;
}

- (id<LXCacheSeparateProtocol>)separateCache{
    return self;
}
@end

@interface LXCache ()<LXCacheSeparateProtocol,LXCacheSeparateDelegate>
{
    NSString *_userName;
    NSString *_password;
}
@property (nonatomic, strong) LXSafeDictionary <NSString *, LXSeparateCache *> * separateMap;
@property (nonatomic, strong) LXSafeDictionary <NSString *,id <LXCacheKeyProtocol>>* keyMap;
@property (nonatomic, copy) NSString * path;
@property (nonatomic, strong) id <LXCacheSeparateProtocol> defaultSeparate;
@property (nonatomic, strong) NSArray * blackIdentities;
@property (nonatomic, strong) NSArray * whiteIdentities;
@property (nonatomic, strong) LXSqlite * sqlit;

@end

@implementation LXCache

+ (LXCache *)defaultCache{
    static LXCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        path = [NSString pathWithComponents:@[path,kLXDefalutCachePath]];
        cache = [[self alloc] initWithPath:path];
    });
    return cache;
}

- (instancetype)initWithPath:(NSString *)path{
    if (self = [super init]) {
        self.path = path;
        _sqlit = [[LXSqlite alloc] initWithPath:path];
        _defaultSeparate = self.identity(kLXDefalutIdentify);
        [self open];
    }
    return self;
}
#pragma mark - 设置密码 -
- (void)openWithUserName:(NSString *)userName password:(NSString *)password{
    _userName = userName;
    _password = password;
    [_sqlit setUserName:userName password:password];
    [self open];
}

- (void)updatePassword:(NSString *)password{
    if (_userName.length == 0) return;
    if ([self.sqlit updateUserName:_userName password:password]){
        _password = password;
    }
}

#pragma mark - 打开 -
- (void)open{
    if ([_sqlit open]) {
        [self loadData];
    }
}

- (void)loadData{
    
}

#pragma mark - 数据处理 -



- (LXSafeDictionary<NSString *,LXSeparateCache *> *)separateMap{
    if (!_separateMap) {
        _separateMap = [LXSafeDictionary dictionary];
    }
    return _separateMap;
}

#pragma mark - LXCacheSeparateDelegate -



#pragma mark - 交互逻辑 -
- (id<LXCacheSeparateProtocol>  _Nonnull (^)(NSString * _Nonnull))identity{
    __weak typeof(self)weakSelf = self;
    return ^( NSString *identity){
        __strong typeof(weakSelf)self = weakSelf;
        LXSeparateCache *separate;
        if (!self) return separate;
        if ([identity isKindOfClass:[NSString class]]) {
            if (identity.length > 0) {
                separate = self.separateMap[identity];
                if (!separate) {
                    separate = [[LXSeparateCache alloc] initWithIdentity:identity];
                    separate.delegate = self;
                    [self.separateMap setValue:separate forKey:identity];
                }
            }
        }
        return separate;
    };
}


- (id<LXCacheSeparateProtocol>)separateCache{
    return self.defaultSeparate;
}
#pragma mark - 全局处理 -

- (BOOL)removeSeparaCacheWithIdentity:(NSString *)identity{
    if (identity.length == 0) return YES;
    LXSeparateCache *cache = self.separateMap[identity];
    return [cache removeSeparaAllCache];
}

- (void)removeSeparaCacheWithIdentity:(NSString *)identity withBlock:(void (^)(BOOL))block{
    if (identity.length == 0){
        if (block) {
            block(YES);
        }
        return;
    }
    LXSeparateCache *cache = self.separateMap[identity];
    [cache removeSeparaAllCacheWithBlock:block];   
}

- (BOOL)removeDefaultSeparaCache{
   return [self removeSeparaCacheWithIdentity:kLXDefalutIdentify];
}

- (void)removeDefaultSeparaCacheWithBlock:(void (^) (BOOL success))block{
    [self removeSeparaCacheWithIdentity:kLXDefalutIdentify withBlock:block];
}

- (void)cacheWithBlackIdentities:(NSArray<NSString *> *)identities{
    if ([self.blackIdentities isEqualToArray:identities]) return;
    self.blackIdentities = identities;
    if (self.whiteIdentities.count > 0) return;
}

- (void)cacheWithWhiteIdentities:(NSArray<NSString *> *)identities{
    if ([self.whiteIdentities isEqualToArray:identities]) return;
    self.whiteIdentities = identities;
}


@end
