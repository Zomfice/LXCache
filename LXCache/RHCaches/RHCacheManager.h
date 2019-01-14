//
//  RHCacheManager.h
//  RHRequestNetWork
//
//  Created by 麻小亮 on 2018/6/6.
//

#import <Foundation/Foundation.h>
#define Weak  __weak __typeof(self) weakSelf = self
typedef NS_ENUM(NSUInteger, RHCacheType) {
    RHCacheDisk = 1,
    RHCacheMemory
};

typedef NS_OPTIONS(NSUInteger,RHCacheResultStatus) {
    RHCacheResultNever         = 0,
    RHCacheResultNormarl       = 1 << 0,
    RHCacheResultMemoryTimeOut = 1 << 1,
    RHCacheResultDiskTimeOut   = 1 << 2,
    RHCacheResultAll           = ~0UL
};

typedef NS_ENUM(NSInteger,RHDataPosition) {
    RHDataNonContain = 0,
    RHDataMemoryContain,
    RHDataDiskContain
};
typedef void(^RHCacheResultBlock)(RHCacheResultStatus status, id data);
typedef void(^RHCacheManagerResultBlock)(RHCacheResultStatus status, NSInteger tag);
@interface RHCacheObject : NSObject<NSCoding>
@property (nonatomic, assign) RHCacheType  cacheType;
@property (nonatomic, assign) BOOL  isClearWhenDiskTimeOut;
@property (nonatomic, assign) NSTimeInterval  memoryTime;
@property (nonatomic, assign) NSTimeInterval  diskTime;
@end
@protocol RHCacheManagerDelegate <NSObject>
- (void)rh_cacheWillRemoveFromMemory:(NSString *)key;
- (void)rh_cacheWillRemoveFromDisk:(NSString *)key;
- (void)rh_cacheWillSaveMemoryIn:(NSString *)key data:(id)data;
- (void)rh_cacheWillSaveDiskIn:(NSString *)key data:(id)data;
- (void)rh_cacheUpdata;
- (void)rh_cacheRemoveAllDiskCache;
- (void)rh_cacheRemoveAllMemoryCache;
@end

@interface RHCacheManager : NSObject

@property (nonatomic, weak) id <RHCacheManagerDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableDictionary <NSString *, RHCacheObject *> * diskData;
- (void)start;
- (void)addObject:(RHCacheObject *)object withKey:(NSString *)key data:(id <NSCoding>)data;
- (void)removeObjectForKey:(NSString *)key;

/**
 返回状态

 @param key 键值
 @param cacheResult 查询的状态
 @return 0：都不包含 1.从memory取  2.从disk取并添加至memory
 */
- (RHDataPosition)objectForKey:(NSString *)key cacheResult:(RHCacheResultStatus)cacheResult;

- (void)objectForKey:(NSString *)key resultBlock:(RHCacheManagerResultBlock)block;

- (RHDataPosition)objectForKey:(NSString *)key newObject:(RHCacheObject *)object cacheResult:(RHCacheResultStatus)cacheResult result:(void (^)(RHCacheResultStatus))status;

- (BOOL)containObjectKey:(NSString *)key resultStatus:(RHCacheResultStatus)status;

- (void)removeAllCache;
@end
