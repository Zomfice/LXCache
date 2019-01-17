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
@interface _lxKeyObject : NSObject<LXKeyCacheProtocol>{
    @package
    NSString *_key;
    NSString * _identity;
    NSTimeInterval _memoryTime, _diskTime, _saveTime;
    LXCacheType _cacheType;
    BOOL _isClearWhenCache;
}

@end

@implementation _lxKeyObject

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
#pragma mark - LXSeparateCache -


@interface LXSeparateCache : NSObject<LXSeparateCacheDelegate, LXSeparateCacheProtocol>

@end

@implementation LXSeparateCache

//@synthesize delegate = _delegate;

- (instancetype)initWithIdentity:(NSString *)identity{
    
    return [self init];
}

- (BOOL)containsObjectForKey:(NSString *)key, ...{
    NSLog(@"maxiaoliang%@", self);
    return YES;
}

- (id<LXSeparateCacheProtocol>)separateCache{
    return self;
}
@end

@interface LXCache ()<LXSeparateCacheProtocol,LXSeparateCacheDelegate>
{
    NSString *_userName;
    NSString *_password;
}
@property (nonatomic, strong) LXSafeDictionary <NSString *, LXSeparateCache *> * separateMap;
@property (nonatomic, strong) LXSafeDictionary <NSString *,id <LXKeyCacheProtocol>>* keyMap;
@property (nonatomic, copy) NSString * path;
@property (nonatomic, strong) id <LXSeparateCacheProtocol> defaultSeparate;
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

#pragma mark - LXSeparateCacheDelegate -



#pragma mark - 交互逻辑 -
- (id<LXSeparateCacheProtocol>  _Nonnull (^)(NSString * _Nonnull))identity{
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


- (id<LXSeparateCacheProtocol>)separateCache{
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
