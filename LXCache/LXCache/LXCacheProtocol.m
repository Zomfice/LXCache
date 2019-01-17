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

#pragma mark - LXSeparateCacheProtocol默认实现  -
@protocolExtension(LXSeparateCacheProtocol)
 

@synthesize delegate = _delegate;


- (BOOL)removeSeparaAllCache{
    
    return YES;
}

- (void)removeSeparaAllCacheWithBlock:(void (^)(BOOL))block{
    NSLog(@"11111111");
}

- (BOOL)containsObjectForKey:(NSString *)key,...{
    if(self.separateCache){
        NSMethodSignature *sig = [self methodSignatureForSelector:_cmd];
        if (!sig){[self doesNotRecognizeSelector:_cmd]; return NO;}
        NSInvocation *invoctation = [NSInvocation invocationWithMethodSignature:sig];
        invoctation.target = self.separateCache;
        invoctation.selector = _cmd;
        va_list args;
        va_start(args, key);
        [NSObject setInv:invoctation withSig:sig andArgs:args];
        va_end(args);
        [invoctation invoke];
        return [[self getInvocationFromInv:invoctation sig:sig] boolValue];
    }
    
    return YES;
}

- (void)containsObjectForKey:(NSString *)key
withBlock:(void (^) (NSString *key, BOOL contains))block,...{
    
}

- (void)containsSynObjectForKey:(NSString *)key
withBlock:(void (^) (BOOL contains, id <LXKeyCacheProtocol> info))block,...{
    
}

- (void)containsAsynObjectDetailForKey:(NSString *)key
withBlock:(void (^) (BOOL contains, id <LXKeyCacheProtocol> info))block,...{
    
}

- (id <NSCoding>)objectForKey:(NSString *)key,...{
    return nil;
}

- (void)objectSynForKey:(NSString *)key
withBlock:(void (^) (NSString *key, id <NSCoding>object, id <LXKeyCacheProtocol> info))block, ...{
    
}

- (void)objectForKey:(NSString *)key
withBlock:(void (^) (NSString *key, id <NSCoding>object))block,...{
    
}


- (void)objectAsynForKey:(NSString *)key
withBlock:(void (^) (NSString *key, id <NSCoding>object, id <LXKeyCacheProtocol> info))block,...{
    
}

- (BOOL)setObject:(id <NSCoding>)object forKey:(NSString *)key, ...{
    return YES;
}

- (void)setObject:(id <NSCoding>)object
forKey:(NSString *)key
withBlock:(void (^) (NSString *key, id <NSCoding>object, BOOL isSuccess))block,...{
    
}

- (BOOL)removeObjectForKey:(NSString *)key{
    return YES;
}

- (void)removeObjectForKey:(NSString *)key
withBlock:(void (^) (NSString *key, id <NSCoding> object))block{
    
}

- (void)setDefaultMemoryTime:(NSTimeInterval)memoryTime
diskTime:(NSTimeInterval)diskTime
isClearWhenTimeOut:(BOOL)isClearWhenTimeOut{
    
}

- (void)setSaveMemoryTime:(NSTimeInterval)memoryTime
diskTime:(NSTimeInterval)diskTime
isClearWhenTimeOut:(BOOL)isClearWhenTimeOut{
    
}

- (CGFloat)cacheSize{
    
    return 0;
}
@end
