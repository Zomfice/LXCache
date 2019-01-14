//
//  RHCache.m
//  RHRequestNetWork
//
//  Created by 麻小亮 on 2018/6/6.
//

#import "RHCache.h"
#import "YYCache.h"
#import "RHCacheManager.h"

static NSString * const RHCachePathName = @"com.MrRHorse.net";
static NSString * const RHCacheManagerName = @"com.MrRHorse.cacheManager";

@interface RHCacheManager (rh)
@property (nonatomic, strong, readwrite) NSMutableDictionary <NSString *, RHCacheObject *> * diskData;
@end

@interface RHCache ()<RHCacheManagerDelegate>{
    RHCacheManager *_cacheManager;
    YYMemoryCache *_memoryCache;
    YYDiskCache *_diskCache;
}

@end
static RHCache *_caches = nil;
@implementation RHCache
#pragma mark - 初始化 -
+ (nullable RHCache *)shareCache{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _caches = [RHCache new];
    });
    return _caches;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)setup{
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [cacheFolder stringByAppendingPathComponent:RHCachePathName];
    _diskCache = [[YYDiskCache alloc] initWithPath:path];
    _memoryCache = [YYMemoryCache new];
    _memoryCache.name = RHCachePathName;
    _cacheManager =  [RHCacheManager new];
    id data =  [_diskCache objectForKey:RHCacheManagerName];
    if ([data isKindOfClass:[NSDictionary class]]) {
        _cacheManager.diskData = [NSMutableDictionary dictionaryWithDictionary:data];
    }else{
        [_diskCache removeAllObjects];
    }
    _cacheManager.delegate = self;
    [_cacheManager start];
}

#pragma mark - 缓存 -
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key{
    [self setObject:object forKey:key withCacheType:RHCacheDisk diskTime:0 memoryTime:0 isClear:NO];
}


- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key memoryTime:(NSTimeInterval)memoryTime{
    [self setObject:object forKey:key withCacheType:RHCacheMemory diskTime:0 memoryTime:memoryTime isClear:NO];
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key memoryTime:(NSTimeInterval)memoryTime diskTime:(NSTimeInterval)diskTime{
    [self setObject:object forKey:key withCacheType:RHCacheDisk diskTime:diskTime memoryTime:memoryTime isClear:NO];
}
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key memoryTime:(NSTimeInterval)memoryTime clearDiskTime:(NSTimeInterval)diskTime{
    
    [self setObject:object forKey:key withCacheType:RHCacheDisk diskTime:diskTime memoryTime:memoryTime isClear:YES];
}
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key withCacheType:(RHCacheType)cacheType diskTime:(NSTimeInterval)diskTime memoryTime:(NSTimeInterval)memoryTime isClear:(BOOL)isClear{
    if (!object || (cacheType == RHCacheMemory && memoryTime <= 0)) {
        [_cacheManager removeObjectForKey:key];
    }else{
        RHCacheObject *cacheObject = [RHCacheObject new];
        cacheObject.cacheType = cacheType;
        if (cacheType == RHCacheDisk && diskTime > 0 && (memoryTime > diskTime || memoryTime == 0)) {
            memoryTime = diskTime;
        }
        cacheObject.memoryTime = memoryTime;
        cacheObject.diskTime = diskTime;
        cacheObject.isClearWhenDiskTimeOut = isClear;
        [_cacheManager addObject:cacheObject withKey:key data:object];
    }
}
+ (void)setExtendedData:(NSData *)extendedData toObject:(id)object{
    [YYDiskCache setExtendedData:extendedData toObject:object];
}
+ (NSData *)getExtendedDataFromObject:(id)object{
    return [YYDiskCache getExtendedDataFromObject:object];
}
#pragma mark - 查询 -
- (BOOL)containObjectKey:(NSString *)key{
    return [_cacheManager containObjectKey:key resultStatus:RHCacheResultAll];
}
- (BOOL)containObjectKey:(NSString *)key cacheResult:(RHCacheResultStatus)cacheResult{
    return [_cacheManager containObjectKey:key resultStatus:cacheResult];
}

- (RHDataPosition)containObjectKey:(NSString *)key withNewCacheType:(RHCacheType)cacheType diskTime:(NSTimeInterval)diskTime memoryTime:(NSTimeInterval)memoryTime isClear:(BOOL)isClear cacheResult:(RHCacheResultStatus)reslut result:(void (^)(RHCacheResultStatus status))status{
    RHCacheObject *cacheObject = [RHCacheObject new];
    cacheObject.cacheType = cacheType;
    cacheObject.memoryTime = memoryTime;
    cacheObject.diskTime = diskTime;
    if (cacheType == RHCacheDisk && diskTime > 0 && (memoryTime > diskTime || memoryTime == 0)) {
        cacheObject.memoryTime = cacheObject.diskTime;
    }
    cacheObject.isClearWhenDiskTimeOut = isClear;
    return [_cacheManager objectForKey:key newObject:cacheObject cacheResult:reslut result:status];
}

- (id)objectForKey:(NSString *)key cacheResult:(RHCacheResultStatus)cacheResult{
    NSInteger tag = [_cacheManager objectForKey:key cacheResult:cacheResult];
    return [self objectForKey:key position:tag];
}

- (void)objectForKey:(NSString *)key withBlock:(RHCacheResultBlock)block{
    if (!block) return;
    Weak;
    [_cacheManager objectForKey:key resultBlock:^(RHCacheResultStatus status, NSInteger tag) {
        block(status, [weakSelf objectForKey:key position:tag]);
    }];
}

- (id)objectForKey:(NSString *)key withNewCacheType:(RHCacheType)cacheType diskTime:(NSTimeInterval)diskTime memoryTime:(NSTimeInterval)memoryTime isClear:(BOOL)isClear cacheResult:(RHCacheResultStatus)reslut result:(void (^)(RHCacheResultStatus))status{
    return [self objectForKey:key position:[self containObjectKey:key withNewCacheType:cacheType diskTime:diskTime memoryTime:memoryTime isClear:isClear cacheResult:reslut result:status]];
}


- (id)objectForKey:(NSString *)key{
    return [self objectForKey:key cacheResult:RHCacheResultNormarl];
}
- (id)objectForKey:(NSString *)key position:(RHDataPosition)position{
    id data = nil;
    switch (position) {
        case RHDataMemoryContain:{
            data = [_memoryCache objectForKey:key];
            break;
        }
        case RHDataDiskContain:{
            data = [_diskCache objectForKey:key];
            [_memoryCache setObject:data forKey:key];
            break;
        }
        default:
            break;
    }
    return data;
}
- (NSUInteger)cacheSize{
    return _diskCache.totalCost;
}
#pragma mark - 删除 -
- (void)removeObjectForKey:(NSString *)key{
    [_cacheManager removeObjectForKey:key];
}
#pragma mark - RHCacheManagerDelegate -
- (void)rh_cacheWillRemoveFromDisk:(NSString *)key{
//    if ([key isEqualToString:RHCacheManagerName]) return;
    [_diskCache removeObjectForKey:key];
}

- (void)rh_cacheWillRemoveFromMemory:(NSString *)key{
    [_memoryCache removeObjectForKey:key];
}
- (void)rh_cacheWillSaveMemoryIn:(NSString *)key data:(id)data{
    [_memoryCache setObject:data forKey:key];
}
- (void)rh_cacheWillSaveDiskIn:(NSString *)key data:(id)data{
    [_diskCache setObject:data forKey:key];
}
- (void)rh_cacheUpdata{
    [_diskCache setObject:_cacheManager.diskData.copy forKey:RHCacheManagerName];
}
- (void)rh_cacheRemoveAllDiskCache{
    [_diskCache removeAllObjects];
}
- (void)rh_cacheRemoveAllMemoryCache{
    [_memoryCache removeAllObjects];
}
- (void)removeAllCache{
    [_cacheManager removeAllCache];
}

@end
