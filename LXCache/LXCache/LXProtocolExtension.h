//
//  LXProtocolExtension.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/18.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import "LXCacheDefine.h"
#import <objc/runtime.h>

#define extension_metamacro_stringify(value) \
extension_metamacro_stringify_(value)
#define extension_metamacro_stringify_(value) # value


#define protocolExtension(ProtocolName)\
interface ProtocolName##_DEFAULTOBJECT : NSObject <ProtocolName>{} @end\
@implementation ProtocolName##_DEFAULTOBJECT\
+ (void)load{\
if (!extension_addContreteProtocol(objc_getProtocol(extension_metamacro_stringify(ProtocolName)), self)) {}\
}\
__attribute__((constructor))\
static void extension_##ProtocolName##_inject (void) {\
extension_loadConcreteProtocol(objc_getProtocol(extension_metamacro_stringify(ProtocolName)));\
}


BOOL extension_addContreteProtocol (Protocol *protocol, Class methodContainer);
void extension_loadConcreteProtocol (Protocol *protocol);
