//
//  LXCache.m
//  LXCache
//
//  Created by 麻小亮 on 2018/12/10.
//  Copyright © 2018年 xllpp. All rights reserved.
//

#import "LXCache.h"
#import "LXSeparateCache.h"


#define LXDefalutCachePath @".kLXCache"
@interface LXCache ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, LXSeparateCache *> * separateMap;
@property (nonatomic, copy) NSString * path;
@property (nonatomic, strong) LXSeparateCache * defaultSeparate;
@end
@implementation LXCache

+ (LXCache *)defaultCache{
    static LXCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        path = [NSString pathWithComponents:@[path,LXDefalutCachePath]];
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


- (LXSeparateCache * _Nonnull (^)(NSString * _Nonnull))identity{
    __weak typeof(self)weakSelf = self;
    return ^(NSString *identity){
        __strong typeof(weakSelf)self = weakSelf;
        
        LXSeparateCache *separate;
        if ([identity isKindOfClass:[NSString class]]) {
            if (identity.length > 0) {
                
            }
        }
        return separate;
    };
}

- (NSMutableDictionary<NSString *,LXSeparateCache *> *)separateMap{
    if (!_separateMap) {
        _separateMap = [NSMutableDictionary dictionary];
    }
    return _separateMap;
}

@end
