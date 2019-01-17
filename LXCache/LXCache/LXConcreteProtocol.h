//
//  LXConcreteProtocol.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/17.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import "LXRuntimeExtensiions.h"
#import "LXCacheDefine.h"

#define lx_metamacro_stringify(value) \
lx_metamacro_stringify_(value)
#define lx_metamacro_stringify_(value) # value




#define lx_concreteprotocol(ProtocolName)\
    interface ProtocolName##_DEFAULTOBJECT : NSObject <ProtocolName>{} @end\
    @implementation ProtocolName##_DEFAULTOBJECT\
    + (void)load{\
        if (!lx_addContreteProtocol(objc_getProtocol(lx_metamacro_stringify(ProtocolName)), self)) {}\
    }\
    __attribute__((constructor))\
    static void lx_##ProtocolName##_inject (void) {\
        lx_loadConcreteProtocol(objc_getProtocol(lx_metamacro_stringify(ProtocolName)));\
    }

BOOL lx_addContreteProtocol (Protocol *protocol, Class methodContainer);
void lx_loadConcreteProtocol (Protocol *protocol);

