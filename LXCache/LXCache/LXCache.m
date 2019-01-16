//
//  LXCache.m
//  LXCache
//
//  Created by 麻小亮 on 2018/12/10.
//  Copyright © 2018年 xllpp. All rights reserved.
//

#import "LXCache.h"
#import "LXSafeDictionary.h"
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

@interface LXSeparateCache : NSObject<LXSeparateCacheProtocol>

- (instancetype)initWithIdentity:(NSString *)identity;

@end


@implementation LXSeparateCache

@end

@interface LXCache ()
@property (nonatomic, strong) LXSafeDictionary <NSString *, LXSeparateCache *> * separateMap;
@property (nonatomic, strong) LXSafeDictionary <NSString *,id <LXKeyCacheProtocol>>* keyMap;
@property (nonatomic, copy) NSString * path;
@property (nonatomic, strong) LXSeparateCache * defaultSeparate;
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
        [self loadData];
    }
    return self;
}

- (void)loadData{
    
}


- (id<LXSeparateCacheProtocol>  _Nonnull (^)(NSString * _Nonnull))identity{
    __weak typeof(self)weakSelf = self;
    return ^(NSString *identity){
        __strong typeof(weakSelf)self = weakSelf;
        LXSeparateCache *separate;
        if ([identity isKindOfClass:[NSString class]]) {
            if (identity.length > 0) {
                separate = self.separateMap[identity];
                if (!separate) {
                    separate = [[LXSeparateCache alloc] initWithIdentity:identity];
                    [self.separateMap setValue:separate forKey:identity];
                }
            }
        }
        return separate;
    };
}

- (LXSafeDictionary<NSString *,LXSeparateCache *> *)separateMap{
    if (!_separateMap) {
        _separateMap = [LXSafeDictionary dictionary];
    }
    return _separateMap;
}

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

@end
