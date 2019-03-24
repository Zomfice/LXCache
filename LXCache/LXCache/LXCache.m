//
//  LXCache.m
//  LXCache
//
//  Created by 麻小亮 on 2018/12/10.
//  Copyright © 2018年 xllpp. All rights reserved.
//

#import "LXCache.h"
#import "LXSeparateCache.h"
#import "LXSqlite.h"
#define kLXDefalutCachePath @".kLXDeafultCache"
#define kLXDefalutIdentify @".kLXDeafultCacheIdentify"

static NSMapTable *_lxcaheGlobalObjects;

static dispatch_semaphore_t _lxcaheGlobalLock;



@interface LXCache ()<LXCacheSeparateDelegate>
{
    NSString *_userName;
    NSString *_password;
    dispatch_semaphore_t _lock;
}
@property (nonatomic, strong) NSMutableDictionary <NSString *, id <LXCacheSeparateProtocol> > * separateMap;
@property (nonatomic, copy) NSString * path;
@property (nonatomic, strong) id <LXCacheSeparateProtocol> defaultSeparate;
@property (nonatomic, strong) NSArray * blackIdentities;
@property (nonatomic, strong) NSArray * whiteIdentities;
@property (nonatomic, strong) LXSqlite * sqlite;

@end
static void _LXCacheCacheInitGlobal(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lxcaheGlobalLock = dispatch_semaphore_create(1);
        _lxcaheGlobalObjects = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    });
}
void _lxSetCacheObject(LXCache *cache){
    if (cache.path.length == 0) return;
    _LXCacheCacheInitGlobal();
    dispatch_semaphore_wait(_lxcaheGlobalLock, DISPATCH_TIME_FOREVER);
    [_lxcaheGlobalObjects setObject:cache forKey:cache.path];
    dispatch_semaphore_signal(_lxcaheGlobalLock);
}

LXCache* _lxGetCacheObject(NSString *path){
    if (path.length == 0) return nil;
    _LXCacheCacheInitGlobal();
    dispatch_semaphore_wait(_lxcaheGlobalLock, DISPATCH_TIME_FOREVER);
    id cache = [_lxcaheGlobalObjects objectForKey:path];
    dispatch_semaphore_signal(_lxcaheGlobalLock);
    return cache;
}

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
    id cache = _lxGetCacheObject(path);
    if (cache) {
        return cache;
    }
    if (self = [super init]) {
        _path = path;
        _lock = dispatch_semaphore_create(1);
        _sqlite = [[LXSqlite alloc] initWithPath:path];
        _defaultSeparate = self.identity(kLXDefalutIdentify);
        _lxSetCacheObject(self);
    }
    return self;
}
#pragma mark - 设置密码 -
- (void)openWithUserName:(NSString *)userName password:(NSString *)password{
    [_sqlite openUserName:userName password:password];
}

- (void)updatePassword:(NSString *)password{
    [_sqlite updatePassword:password];
}

- (NSMutableDictionary<NSString *,id<LXCacheSeparateProtocol>> *)separateMap{
    if (!_separateMap) {
        _separateMap = [NSMutableDictionary dictionary];
    }
    return _separateMap;
}

- (void)lock{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
}

- (void)unlock{
    dispatch_semaphore_signal(_lock);
}
#pragma mark - LXCacheSeparateDelegate -



#pragma mark - 交互逻辑 -
- (id<LXCacheSeparateProtocol>  _Nonnull (^)(NSString * _Nonnull))identity{
    return ^( NSString *identity){
        id <LXCacheSeparateProtocol> separate;
        if (!self) return separate;
        if ([identity isKindOfClass:[NSString class]]) {
            if (identity.length > 0) {
                [self lock];
                separate = self.separateMap[identity];
                [self unlock];
                if (!separate) {
                    separate = (id <LXCacheSeparateProtocol>)[[LXSeparateCache alloc] initWithIdentity:identity sqlite:self.sqlite];
                    separate.delegate = self;
                    [self lock];
                    [self.separateMap setValue:separate forKey:identity];
                    [self unlock];
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
    id <LXCacheSeparateProtocol> cache = self.separateMap[identity];
    return [cache removeSeparaAllCache];
}

- (void)removeSeparaCacheWithIdentity:(NSString *)identity withBlock:(void (^)(BOOL))block{
    if (identity.length == 0){
        if (block) {
            block(YES);
        }
        return;
    }
    id <LXCacheSeparateProtocol> cache = self.separateMap[identity];
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
