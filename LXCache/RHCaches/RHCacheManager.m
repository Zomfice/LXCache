//
//  RHCacheManager.m
//  RHRequestNetWork
//
//  Created by 麻小亮 on 2018/6/6.
//

#import "RHCacheManager.h"
#import <time.h>
#import <pthread.h>
#import <UIKit/UIKit.h>
#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)
@interface RHCacheObject ()<NSCoding>
@property (nonatomic, assign) NSTimeInterval  saveTime;
@property (nonatomic, assign) NSTimeInterval  memoryUseTime;
@property (nonatomic, assign) RHCacheResultStatus  cacheResultStatus;
@end
@implementation RHCacheObject
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(self.cacheResultStatus) forKey:@"cacheResultStatus"];
    [aCoder encodeObject:@(self.cacheType) forKey:@"cacheType"];
    [aCoder encodeObject:@(self.saveTime) forKey:@"saveTime"];
    [aCoder encodeObject:@(self.memoryTime) forKey:@"memoryTime"];
    [aCoder encodeObject:@(self.diskTime) forKey:@"diskTime"];
    [aCoder encodeObject:@(self.isClearWhenDiskTimeOut) forKey:@"isClearWhenDiskTimeOut"];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self.cacheResultStatus = [[aDecoder decodeObjectForKey:@"cacheResultStatus"] integerValue];
    _memoryUseTime = time(NULL);
    self.saveTime = [[aDecoder decodeObjectForKey:@"saveTime"] floatValue];
    self.cacheType = [[aDecoder decodeObjectForKey:@"cacheType"] integerValue];
    self.diskTime = [[aDecoder decodeObjectForKey:@"diskTime"] floatValue];
    self.memoryTime = [[aDecoder decodeObjectForKey:@"memoryTime"] floatValue];
    self.isClearWhenDiskTimeOut = [[aDecoder decodeObjectForKey:@"isClearWhenDiskTimeOut"] boolValue];
    return self;
}

@end
@interface RHCacheManager (){
    pthread_mutex_t _lock;
}
@property (nonatomic, strong) dispatch_queue_t  queue;
@property (nonatomic, strong) NSMutableDictionary <NSString *, RHCacheObject *>* memoryData;
@property (nonatomic, strong) NSMutableDictionary <NSString *, RHCacheObject *> * diskData;
/**
 如果内存缓存超过memoryTimeOut时间也没有使用则清除
 */
@property (nonatomic, assign) NSTimeInterval  memoryTimeOut;

/**
 如果磁盘缓存超过disTimeOut时间也没有使用则清除
 */
@property (nonatomic, assign) NSTimeInterval  diskTimeOut;
@end
@implementation RHCacheManager

//初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}
- (void)_appDidReceiveMemoryWarningNotification {
    [self.memoryData removeAllObjects];
    if ([self.delegate respondsToSelector:@selector(rh_cacheRemoveAllMemoryCache)]) {
        [self.delegate rh_cacheRemoveAllMemoryCache];
    }
    
}
- (void)_appDidEnterBackgroundNotification {
    [self.memoryData removeAllObjects];
    if ([self.delegate respondsToSelector:@selector(rh_cacheRemoveAllMemoryCache)]) {
        [self.delegate rh_cacheRemoveAllMemoryCache];
    }
}
- (void)setup{
    pthread_mutex_init(&_lock, NULL);
    _queue = dispatch_queue_create("com.MrRHorse.c_cacheManager", DISPATCH_QUEUE_SERIAL);

    self.memoryTimeOut = 4 * 60;
    self.diskTimeOut = 7 * 60 * 60 * 24;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}
- (NSMutableDictionary<NSString *,RHCacheObject *> *)memoryData{
    if (!_memoryData) {
        _memoryData = [NSMutableDictionary dictionary];
    }
    return _memoryData;
}
- (NSMutableDictionary<NSString *,RHCacheObject *> *)diskData{
    if (!_diskData) {
        _diskData = [NSMutableDictionary dictionary];
    }
    return _diskData;
}
#pragma mark - 数据处理 -
- (void)addObject:(RHCacheObject *)object withKey:(NSString *)key data:(id<NSCoding>)data{
    NSTimeInterval current = time(NULL);
    object.saveTime = current;
    RHCacheType type = object.cacheType;
    switch (type) {
        case RHCacheMemory:{
            
            [self setMemoryDataObject:object key:key];
            [self setMemoryObject:data forKey:key];
            [self removeDiskDataForKey:key];
        }
            break;
        case RHCacheDisk:{
            
            [self setDiskDataObject:object key:key];
            [self setMemoryDataObject:object key:key];
            [self setDiskObject:data forKey:key];
            [self setMemoryObject:data forKey:key];
        }
            break;
        default:
            break;
    }
}
- (void)removeObjectForKey:(NSString *)key{
    [self removeMemoryDataForKey:key];
    [self removeDiskDataForKey:key];
}

- (RHDataPosition)objectForKey:(NSString *)key cacheResult:(RHCacheResultStatus)cacheResult{
    NSDictionary *dic = [self getObjectWithObjectForkey:key newObject:nil];
    RHCacheResultStatus resultType = [dic[@"resultType"] integerValue];
    NSInteger tag = [dic[@"tag"] integerValue];
    if (!(cacheResult & resultType)) {
        tag = RHDataNonContain;
    }
    //    NSLog(@"realStatus::::::::::::%@ \nscreenStatus:::::::::::%@",[RHCacheManager statusStringWithStatus:resultType],[RHCacheManager statusStringWithStatus:cacheResult]);
    return tag;
}
- (RHDataPosition)objectForKey:(NSString *)key newObject:(RHCacheObject *)object cacheResult:(RHCacheResultStatus)cacheResult result:(void (^)(RHCacheResultStatus))status{
    NSDictionary *dic = [self getObjectWithObjectForkey:key newObject:object];
    RHDataPosition tag = [dic[@"tag"] integerValue];
    RHCacheResultStatus resultType = [dic[@"resultType"] integerValue];
    if (!(cacheResult & resultType)) {
        tag = RHDataNonContain;
    }
    status(resultType);
//        NSLog(@"%@ realStatus::::::::::::%@ \nscreenStatus:::::::::::%@", key,[RHCacheManager statusStringWithStatus:resultType],[RHCacheManager statusStringWithStatus:cacheResult]);
    return tag;
}

- (void)objectForKey:(NSString *)key resultBlock:(RHCacheManagerResultBlock)block{
    NSDictionary *dic = [self getObjectWithObjectForkey:key newObject:nil];
    RHCacheResultStatus resultType = [dic[@"resultType"] integerValue];
    NSInteger tag = [dic[@"tag"] integerValue];
    block(resultType, tag);
}

- (NSDictionary *)getObjectWithObjectForkey:(NSString *)key newObject:(RHCacheObject *)newObject{
    NSTimeInterval currentTime = time(NULL);
    
    NSInteger tag = RHDataNonContain;
    RHCacheResultStatus resultType;
    Lock();
    RHCacheObject *object = [self.memoryData objectForKey:key];
    Unlock();
    if (object) {
        tag = RHDataMemoryContain;
        if (newObject) {
            newObject.saveTime = object.saveTime;
            if (object.cacheType == RHCacheMemory) {
                newObject.cacheType = RHCacheMemory;
            }
            [self statusWithMemoryObject:newObject time:currentTime];
        }
        if ([self isShouldUpdateCacheReult:object]) {
            [self statusWithMemoryObject:object time:currentTime];
        }
    }else if(newObject && newObject.cacheType == RHCacheMemory){
        newObject.cacheResultStatus = RHCacheResultNever;
    }else{
        Lock();
        object = [self.diskData objectForKey:key];
        Unlock();
        if (object) {
            tag = RHDataDiskContain;
            if (newObject) {
                newObject.saveTime = object.saveTime;
                [self statusWithDiskObject:newObject time:currentTime];
            }
            if ([self isShouldUpdateCacheReult:object]) {
                [self statusWithDiskObject:object time:currentTime];
            }
            [self setMemoryDataObject:object key:key];
            
        }else{
            object.cacheResultStatus = RHCacheResultNever;
            if (newObject) {
                newObject.cacheResultStatus = RHCacheResultNever;
            }
        }
    }
    switch (tag) {
        case RHDataMemoryContain:
        {
            object.memoryUseTime = currentTime;
        }
            break;
        default:
            break;
    }
    
    resultType = newObject?newObject.cacheResultStatus:object.cacheResultStatus;
    return @{@"tag":@(tag), @"resultType" : @(resultType)};
}

- (void)statusWithMemoryObject:(RHCacheObject *)object time:(NSTimeInterval)currentTime{
    RHCacheResultStatus status;
    switch (object.cacheType) {
        case RHCacheDisk:{
            if (object.memoryTime + object.saveTime >= currentTime || object.memoryTime == 0) {
                status = RHCacheResultNormarl;
            }else if (object.saveTime + object.diskTime >= currentTime || object.diskTime == 0){
                status = RHCacheResultMemoryTimeOut;
            }else{
                status = RHCacheResultDiskTimeOut;
            }
        }
            break;
        case RHCacheMemory:{
            if (object.memoryTime + object.saveTime >= currentTime) {
                status = RHCacheResultNormarl;
            }else{
                status = RHCacheResultMemoryTimeOut;
            }
        }
            break;
        default:
            break;
    }
    object.cacheResultStatus = status;
}
- (void)statusWithDiskObject:(RHCacheObject *)object time:(NSTimeInterval)currentTime{
    RHCacheResultStatus status;
    if (object.saveTime + object.diskTime >= currentTime || object.diskTime == 0) {
        if (object.saveTime + object.memoryTime >= currentTime || object.memoryTime == 0) {
            status = RHCacheResultNormarl;
        }else{
            status = RHCacheResultMemoryTimeOut;
        }
    }else{
        status = RHCacheResultDiskTimeOut;
    }
    object.cacheResultStatus = status;
}
- (BOOL)isShouldUpdateCacheReult:(RHCacheObject *)object{
    if (!object.cacheResultStatus) return YES;
    
    switch (object.cacheType) {
        case RHCacheMemory:{
            if (object.cacheResultStatus & RHCacheResultNormarl) {
                return YES;
            }
        }
            break;
        case RHCacheDisk:{
            if (object.cacheResultStatus & (RHCacheResultMemoryTimeOut | RHCacheResultNormarl)) {
                if (object.diskTime != 0) {
                    return YES;
                }
            }
        }
        default:
            break;
    }
    return NO;
}
- (BOOL)cacheObject:(RHCacheObject *)object1 isEqualToObject:(RHCacheObject *)object2{
    if (!object1 || !object2) {
        return YES;
    }
    if (object2.cacheType != object1.cacheType) {
        return NO;
    }
    if (object1.cacheType == object2.cacheType && object2.cacheType == RHCacheMemory) {
        return object1.memoryTime == object2.memoryTime;
    }
    return object1.memoryTime == object2.memoryTime && object1.diskTime == object2.diskTime && object1.isClearWhenDiskTimeOut == object1.isClearWhenDiskTimeOut;
}
- (BOOL)containObjectKey:(NSString *)key resultStatus:(RHCacheResultStatus)status{
    BOOL isContains = NO;
    if (status & RHCacheResultAll) {
        Lock();
        NSArray *diskKeys = _diskData.allKeys.copy;
        NSArray *memoryKeys = _memoryData.allKeys.copy;
        Unlock();
        isContains = [diskKeys containsObject:key] || [memoryKeys containsObject:key];
    }else{
        NSInteger number = [self objectForKey:key cacheResult:status];
        isContains = number == 0;
    }
    return isContains;
}
#pragma mark - 定时器，定期清除过期缓存 -
- (void)start{
    [self trimCache];
}
- (void)trimCache{
    __weak typeof(self)_self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self)self = _self;
        if (!self) return;
        [self trimTime];
        [self trimCache];
    });
}
- (void)trimTime{
    __weak typeof(self)_self = self;
    dispatch_async(_queue, ^{
        __strong typeof(_self)self = _self;
        if (!self) return;
         [self checkDiskTimeOut];
         [self checkMemoryTimeOut];
    });
}
- (void)checkDiskTimeOut{
    Lock();
    NSArray *allKeys = self.diskData.allKeys.copy;
    Unlock();
//    NSLog(@"diskkeysCount === %ld， %@", allKeys.count, allKeys);
    NSTimeInterval currentTime = time(NULL);
    for (NSString *key in allKeys) {
        Lock();
        RHCacheObject *object = [self.diskData objectForKey:key];
        Unlock();
        if(object.saveTime + self.diskTimeOut < currentTime && self.diskTimeOut > 0) {
            [self removeDiskDataForKey:key];
            [self removeMemoryDataForKey:key];
            continue;
        }
        if (object.diskTime == 0) {
            continue;
        }else if(object.saveTime + object.diskTime < currentTime){
            if (object.isClearWhenDiskTimeOut) {
                [self removeDiskDataForKey:key];
                [self removeMemoryDataForKey:key];
            }
        }
    }
}

- (void)checkMemoryTimeOut{
    Lock();
    NSArray *allKeys = self.memoryData.allKeys.copy;
    Unlock();
//        NSLog(@"memorykeysCount === %ld， %@", allKeys.count, allKeys);
    NSTimeInterval currentTime = time(NULL);
    for (NSString *key in allKeys) {
        Lock();
        RHCacheObject *object = [self.memoryData objectForKey:key];
        Unlock();
        BOOL canMemoryClear = NO;
        switch (object.cacheType) {
            case RHCacheDisk:
            {
                canMemoryClear =  object.saveTime + object.diskTime < currentTime && object.diskTime != 0 && object.isClearWhenDiskTimeOut;
            }
                break;
            case RHCacheMemory:{
                canMemoryClear = object.saveTime + object.memoryTime < currentTime;
            }
                break;
            default:
                break;
        }
        if (!canMemoryClear) {
            canMemoryClear = object.memoryUseTime + self.memoryTimeOut < currentTime;
        }
        if(canMemoryClear){
            [self removeMemoryDataForKey:key];
        }
    }
}
#pragma mark - 数据更新 -
- (void)removeDiskDataForKey:(NSString *)key{
    if ([self.delegate respondsToSelector:@selector(rh_cacheWillRemoveFromDisk:)]) {
        [self.delegate rh_cacheWillRemoveFromDisk:key];
    }
    Lock();
    [self.diskData removeObjectForKey:key];
    Unlock();
    if ([self.delegate respondsToSelector:@selector(rh_cacheUpdata)]) {
        [self.delegate rh_cacheUpdata];
    }
}

- (void)removeMemoryDataForKey:(NSString *)key{
    if ([self.delegate respondsToSelector:@selector(rh_cacheWillRemoveFromMemory:)]) {
        [self.delegate rh_cacheWillRemoveFromMemory:key];
    }
    Lock();
    [self.memoryData removeObjectForKey:key];
    Unlock();
}
- (void)setDiskDataObject:(RHCacheObject *)object key:(NSString *)key{
    Lock();
    [self.diskData setObject:object forKey:key];
    Unlock();
    if ([self.delegate respondsToSelector:@selector(rh_cacheUpdata)]) {
        [self.delegate rh_cacheUpdata];
    }
}
- (void)setDiskObject:(id <NSCoding>)object forKey:(NSString *)key{
    if ([self.delegate respondsToSelector:@selector(rh_cacheWillSaveDiskIn:data:)]) {
        [self.delegate rh_cacheWillSaveDiskIn:key data:object];
    }
}
- (void)setMemoryDataObject:(RHCacheObject *)object key:(NSString *)key{
    object.memoryUseTime = time(NULL);
    Lock();
    [self.memoryData setObject:object forKey:key];
    Unlock();
}
- (void)setMemoryObject:(id <NSCoding>)object forKey:(NSString *)key{
    if ([self.delegate respondsToSelector:@selector(rh_cacheWillSaveMemoryIn:data:)]) {
        [self.delegate rh_cacheWillSaveMemoryIn:key data:object];
    }
}
+ (nullable NSArray<NSString *> *)modelPropertyWhitelist{
    return @[@"diskData"];
}

+ (NSString *)statusStringWithStatus:(RHCacheResultStatus)statu{
    NSMutableString *resultString = [NSMutableString string];
    
    if (statu & RHCacheResultNormarl) {
        [resultString appendString:@"RHCacheResultNormarl |"];
    }
    if (statu & RHCacheResultDiskTimeOut) {
        [resultString appendString:@"RHCacheResultDiskTimeOut |"];
    }
    if (statu & RHCacheResultMemoryTimeOut) {
        [resultString appendString:@"RHCacheResultMemoryTimeOut |"];
    }
    
    if (statu == RHCacheResultNever) {
        [resultString replaceCharactersInRange:NSMakeRange(0, resultString.length) withString:@"RHCacheResultNever |"];
    }
    if (statu == RHCacheResultAll) {
        [resultString replaceCharactersInRange:NSMakeRange(0, resultString.length) withString:@"RHCacheResultAll |"];
    }
    [resultString deleteCharactersInRange:NSMakeRange(resultString.length - 1, 1)];
    return resultString;
}
- (void)removeAllCache{
    Lock();
    [_memoryData removeAllObjects];
    [_diskData removeAllObjects];
    Unlock();
    if ([self.delegate respondsToSelector:@selector(rh_cacheRemoveAllMemoryCache)]) {
        [self.delegate rh_cacheRemoveAllMemoryCache];
    }
    if ([self.delegate respondsToSelector:@selector(rh_cacheRemoveAllDiskCache)]) {
        [self.delegate rh_cacheRemoveAllDiskCache];
    }
    if ([self.delegate respondsToSelector:@selector(rh_cacheUpdata)]) {
        [self.delegate rh_cacheUpdata];
    }
}
@end
