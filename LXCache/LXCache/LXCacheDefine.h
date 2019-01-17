
//
//  LXCacheDefine.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/15.
//  Copyright © 2019 xllpp. All rights reserved.
//

#ifndef LXCacheDefine_h
#define LXCacheDefine_h
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, LXCacheType) {
    LXCacheDisk = 1,
    RHCacheMemory
};

typedef NS_OPTIONS(NSUInteger, LXCacheResultStatus) {
    LXCacheResultNever         = 0,
    LXCacheResultNormarl       = 1 << 0,
    LXCacheResultMemoryTimeOut = 1 << 1,
    LXCacheResultDiskTimeOut   = 1 << 2,
    LXCacheResultAll           = ~0UL
};

typedef NS_ENUM(NSUInteger, LXCachePosition) {
    LXDataNonContain = 0,
    LXDataMemoryContain,
    LXDataDiskContain
};

#define lx_concrete \
optional



#endif /* LXCacheDefine_h */
