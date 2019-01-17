//
//  LXRuntimeExtensiions.m
//  LXCache
//
//  Created by 麻小亮 on 2019/1/17.
//  Copyright © 2019 xllpp. All rights reserved.
//

#import "LXRuntimeExtensiions.h"
#import <pthread.h>


typedef void (^lx_specialProtocolInjectionBlock)(Class);

typedef struct {
    __unsafe_unretained Protocol *protocol;
    void *injectionBlock;
    BOOL ready;
} LXSpecialProtocol;




static LXSpecialProtocol * restrict specialProtocols = NULL;
//锁
static pthread_mutex_t specialProtocolsLock = PTHREAD_MUTEX_INITIALIZER;
//协议个数
static size_t specialProtocolCount = 0;
//协议的缓存大小
static size_t specialProtocolCapacity = 0;
//将要注入的协议
static size_t specialProtocolsReady = 0;


static void lx_injectSpecialProtocols (void){
    qsort_b(specialProtocols, specialProtocolCount, sizeof(LXSpecialProtocol), ^ (const void * a, const void *b){
        if (a == b) return 0;
        const LXSpecialProtocol *protocolA = a;
        const LXSpecialProtocol *protocolB = b;
        
        int (^ protocolInjectionPriority) (const LXSpecialProtocol *) = ^ (const LXSpecialProtocol *specialProtocol){
            int runningTotal = 0;
            for (size_t i = 0; i < specialProtocolCount; i++) {
                if (specialProtocol == specialProtocols + i) continue;
                if (protocol_conformsToProtocol(specialProtocol -> protocol, specialProtocols[i].protocol)) {
                    runningTotal++;
                }
            }
            return runningTotal;
        };
        return protocolInjectionPriority(protocolB) - protocolInjectionPriority(protocolA);
    });
    
    unsigned classCount = objc_getClassList(NULL, 0);
    
    if (!classCount) return;
    Class *allClasses = (Class *)malloc(sizeof(Class) * (classCount + 1));
    if (!allClasses) return;
    classCount = objc_getClassList(allClasses, classCount);
    
    @autoreleasepool {
        for (size_t i = 0; i < specialProtocolCount; i++) {
           Protocol *protocol = specialProtocols[i].protocol;
            lx_specialProtocolInjectionBlock block = (__bridge_transfer id)specialProtocols[i].injectionBlock;
            specialProtocols[i].injectionBlock = NULL;
            for (unsigned classIndex = 0; classIndex < classCount; classIndex++) {
                Class class = allClasses[classIndex];
                if (!class_conformsToProtocol(class, protocol)) continue;
                block(class);
            }
        }
    }
    free(allClasses);
    free(specialProtocols); specialProtocols = NULL;
    specialProtocolCount = 0;
    specialProtocolCapacity = 0;
    specialProtocolsReady = 0;
}


/**
 添加协议

 */
BOOL lx_loadSpecialProtocol (Protocol *protocol, void (^injectionBehavior)(Class destinationClass)){
    @autoreleasepool {
        NSCParameterAssert(protocol!=nil);
        NSCParameterAssert(injectionBehavior!=nil);
        
        if (pthread_mutex_lock(&specialProtocolsLock) != 0) {
            return NO;
        }
        
        if (specialProtocolCount == SIZE_MAX) {
            pthread_mutex_unlock(&specialProtocolsLock);
            return NO;
        }
        
        if (specialProtocolCount >=  specialProtocolCapacity) {
            size_t newCapacity;
            if (specialProtocolCapacity == 0) {
                newCapacity = 1;
            }else{
                newCapacity = specialProtocolCapacity << 1;
                
                if (newCapacity < specialProtocolCapacity) {
                    newCapacity = SIZE_MAX;
                    if (newCapacity <= specialProtocolCapacity) {
                        pthread_mutex_unlock(&specialProtocolsLock);
                    }
                }
            }
            void * restrict ptr = realloc(specialProtocols, newCapacity * sizeof(*specialProtocols));
            if (!ptr) {
                pthread_mutex_unlock(&specialProtocolsLock);
                return NO;
            }
            specialProtocols = ptr;
            specialProtocolCapacity = newCapacity;
            
        }
        
        assert(specialProtocolCount < specialProtocolCapacity);
        
        #ifndef __clang_analyzer__
        lx_specialProtocolInjectionBlock copiedBlock = [injectionBehavior copy];
        specialProtocols[specialProtocolCount] = (LXSpecialProtocol){
            .protocol = protocol,
            .injectionBlock = (__bridge_retained void *)copiedBlock,
            .ready = NO
        };
        #endif
        
        ++specialProtocolCount;
        pthread_mutex_unlock(&specialProtocolsLock);
        
    }
    return YES;
}


void lx_specialProtocolReadyForInjection (Protocol *protocol) {
    @autoreleasepool {
        NSCParameterAssert(protocol != nil);
        if (pthread_mutex_lock(&specialProtocolsLock) != 0) return;
        
        for (size_t i = 0; i < specialProtocolCount; ++i) {
            if (specialProtocols[i].protocol == protocol) {
                if (!specialProtocols[i].ready) {
                    specialProtocols[i].ready = YES;
                    assert(specialProtocolsReady < specialProtocolCount);
                    
                    if (++ specialProtocolsReady == specialProtocolCount)lx_injectSpecialProtocols();
                    
                }
                break;
            }
        }
         pthread_mutex_unlock(&specialProtocolsLock);
    }
}
