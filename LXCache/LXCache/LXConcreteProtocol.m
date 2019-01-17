//
//  LXConcreteProtocol.m
//  LXCache
//
//  Created by 麻小亮 on 2019/1/17.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import "LXConcreteProtocol.h"
#import <objc/runtime.h>
#import <stdlib.h>
static void lx_injectConcreteProtocol (Protocol *protocol, Class containerClass, Class class) {
    
    unsigned imethodCount = 0;
    Method * imethodList = class_copyMethodList(containerClass, &imethodCount);
    
    unsigned cmethodCount = 0;
    Method *cmethodList = class_copyMethodList(object_getClass(containerClass), &cmethodCount);
    
    Class metaclass = object_getClass(class);
    
    for (unsigned methodIndex = 0; methodIndex < imethodCount; methodIndex ++) {
        Method method = imethodList[methodIndex];
        SEL selector = method_getName(method);
        if (class_getInstanceMethod(class, selector)) continue;
        IMP imp = method_getImplementation(method);
        if (!class_addMethod(class, selector, imp, method_getTypeEncoding(method))) {
        }
    }
    
    for (unsigned methodIndex = 0;methodIndex < cmethodCount;++methodIndex) {
        Method method = cmethodList[methodIndex];
        SEL selector = method_getName(method);

        if (selector == @selector(initialize)) continue;
        if (class_getInstanceMethod(metaclass, selector)) continue;
        IMP imp = method_getImplementation(method);
        const char *types = method_getTypeEncoding(method);
        if (!class_addMethod(metaclass, selector, imp, types)) {
        }
    }
    free(imethodList); imethodList = NULL;
    free(cmethodList); cmethodList = NULL;
    (void)[containerClass class];
}


BOOL lx_addContreteProtocol (Protocol *protocol, Class methodContainer){
    return lx_loadSpecialProtocol(protocol, ^(__unsafe_unretained Class destinationClass) {
        lx_injectConcreteProtocol(protocol, methodContainer, destinationClass);
    });
}
void lx_loadConcreteProtocol (Protocol *protocol){
    lx_specialProtocolReadyForInjection(protocol);
}



