//
//  LXRuntimeExtensiions.h
//  LXCache
//
//  Created by 麻小亮 on 2019/1/17.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>


typedef void (* lx_failedMethodCallBack) (Class, Method);


typedef NS_OPTIONS(NSUInteger, lx_methodInjectionBehavior) {
    lx_methodInjectionReplace = 0x00,
    lx_methodInjectionFailOnExisting = 0x01,
    lx_methodInjectionFailOnSuperclassExisting = 0x02,
    lx_methodInjectionFailOnAnyExisting        = 0x03,
    lx_methodInjectionIgnoreLoad = 1U << 2,
    lx_methodInjectionIgnoreInitialize = 1U << 3
};

static const lx_methodInjectionBehavior lx_methodInjectionOverwriteBehaviorMask = 0x03;

typedef NS_ENUM(NSUInteger, lx_propertyMemoryPolicy) {
    lx_propertyMemoryPolicyAssign,
    lx_propertyMemoryPolicyRetain,
    lx_propertyMemoryPolicyCopy
};

typedef struct {
    BOOL readonly;
    BOOL nonatomic;
    BOOL weak;
    BOOL canBeCollected;
    BOOL dynamic;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpadded"
    lx_propertyMemoryPolicy propertyMemoryPolicy;
    SEL getter;
    SEL setter;
#pragma clang diagnostic pop
    const char *ivar;
    Class objectClass;
    char type[];
} lx_propertyAttributes;

unsigned lx_addMehods (Class aClass, Method *methods, unsigned count, BOOL checkSuperClasses, lx_failedMethodCallBack failCallBack);

BOOL lx_addMethodsFormClass (Class srcClass, Class dstClass, BOOL checkSuperClasses, lx_failedMethodCallBack failClalBack);

Class lx_classBeforeSuperClass (Class receiver, Class superClass);

BOOL lx_classIsKindOfClass (Class receiver, Class aClass);

Class *lx_copyClassList (unsigned *count);


#pragma mark - 协议 -

/**
 从协议中获取方法
 */
Class *lx_copyClassListConformingToProtocol (Protocol *protocol, unsigned *count);


/**
 添加协议
 */
BOOL lx_loadSpecialProtocol (Protocol *protocol, void (^injectionBehavior)(Class destinationClass));

void lx_specialProtocolReadyForInjection (Protocol *protocol);

NSString *lx_stringForTypedBytes (const void *bytes, const char * encoding);



#pragma mark - Runtime -




