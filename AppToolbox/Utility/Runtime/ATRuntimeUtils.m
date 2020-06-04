//
//  ATRuntimeUtils.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATRuntimeUtils.h"
#import <objc/runtime.h>

@implementation ATRuntimeUtils

+ (BOOL)fastDetectInstance:(NSObject *)instance protocol:(Protocol *)protocol
{
    return [ATRuntimeUtils detectInstance:instance protocol:protocol unRespondsMethods:nil fast:YES];
}

+ (BOOL)detectInstance:(NSObject *)instance protocol:(Protocol *)protocol
     unRespondsMethods:(NSArray * _Nullable * _Nullable)unRespondsMethods
{
    NSMutableArray *tmp = [NSMutableArray new];
    BOOL rtn = [ATRuntimeUtils detectInstance:instance protocol:protocol unRespondsMethods:tmp fast:NO];
    if (unRespondsMethods) {
        *unRespondsMethods = [NSArray arrayWithArray:tmp];
    }
    return rtn;
}

+ (BOOL)detectInstance:(NSObject *)instance protocol:(Protocol *)protocol unRespondsMethods:(NSMutableArray *)unRespondsMethods fast:(BOOL)fast
{
    struct objc_method_description *methodDescriptions = NULL;
    unsigned int methodCount = 0;
    
    methodDescriptions = protocol_copyMethodDescriptionList(protocol, YES, YES, &methodCount);
    for (unsigned int index = 0; index < methodCount; index++) {
        struct objc_method_description description = methodDescriptions[index];
        if (![instance respondsToSelector:description.name]) {
            [unRespondsMethods addObject:NSStringFromSelector(description.name)];
            if (fast) {
                return NO;
            }
        }
    }
    if (methodDescriptions != NULL) {
        free(methodDescriptions);
    }
//    methodDescriptions = protocol_copyMethodDescriptionList(protocol, NO, YES, &methodCount);
//    for (unsigned int index = 0; index < methodCount; index++) {
//        struct objc_method_description description = methodDescriptions[index];
//        if (![instance respondsToSelector:description.name]) {
//            [unRespondsMethods addObject:NSStringFromSelector(description.name)];
//            if (fast) {
//                return NO;
//            }
//        }
//    }
//    if (methodDescriptions != NULL) {
//        free(methodDescriptions);
//    }
    
    methodDescriptions = protocol_copyMethodDescriptionList(protocol, YES, NO, &methodCount);
    for (unsigned int index = 0; index < methodCount; index++) {
        struct objc_method_description description = methodDescriptions[index];
        if (![instance.class respondsToSelector:description.name]) {
            [unRespondsMethods addObject:NSStringFromSelector(description.name)];
            if (fast) {
                return NO;
            }
        }
    }
    if (methodDescriptions != NULL) {
        free(methodDescriptions);
    }
//    methodDescriptions = protocol_copyMethodDescriptionList(protocol, NO, NO, &methodCount);
//    for (unsigned int index = 0; index < methodCount; index++) {
//        struct objc_method_description description = methodDescriptions[index];
//        if (![instance.class respondsToSelector:description.name]) {
//            [unRespondsMethods addObject:NSStringFromSelector(description.name)];
//            if (fast) {
//                return NO;
//            }
//        }
//    }
//    if (methodDescriptions != NULL) {
//        free(methodDescriptions);
//    }
    
    unsigned int protocolCount = 0;
    Protocol * __unsafe_unretained *protocolList = NULL;
    protocolList = protocol_copyProtocolList(protocol, &protocolCount);
    for (unsigned int index = 0; index < protocolCount; index++) {
        Protocol *aProtocol = protocolList[index];
        if (![NSStringFromProtocol(aProtocol) isEqualToString:@"NSObject"]) {
            BOOL res = [self detectInstance:instance protocol:aProtocol unRespondsMethods:unRespondsMethods fast:fast];
            if (fast && !res) {
                return NO;
            }
        }
    }
    if (protocolList != NULL) {
        free(protocolList);
    }
    
    return unRespondsMethods.count == 0;
}

+ (BOOL)fastDetectClass:(Class)aClass protocol:(Protocol *)protocol
{
    return [ATRuntimeUtils detectClass:aClass protocol:protocol unRespondsMethods:nil fast:YES];
}

+ (BOOL)detectClass:(Class)aClass protocol:(Protocol *)protocol
  unRespondsMethods:(NSArray * _Nullable * _Nullable)unRespondsMethods
{
    NSMutableArray *tmp = [NSMutableArray new];
    BOOL rtn = [ATRuntimeUtils detectClass:aClass protocol:protocol unRespondsMethods:tmp fast:NO];
    if (unRespondsMethods) {
        *unRespondsMethods = [NSArray arrayWithArray:tmp];
    }
    return rtn;
}

+ (BOOL)detectClass:(Class)aClass protocol:(Protocol *)protocol unRespondsMethods:(NSMutableArray *)unRespondsMethods fast:(BOOL)fast
{
    struct objc_method_description *methodDescriptions = NULL;
    unsigned int methodCount = 0;
    
    methodDescriptions = protocol_copyMethodDescriptionList(protocol, YES, YES, &methodCount);
    for (unsigned int index = 0; index < methodCount; index++) {
        struct objc_method_description description = methodDescriptions[index];
        if (![aClass instancesRespondToSelector:description.name]) {
            [unRespondsMethods addObject:NSStringFromSelector(description.name)];
            if (fast) {
                return NO;
            }
        }
    }
    if (methodDescriptions != NULL) {
        free(methodDescriptions);
    }
//    methodDescriptions = protocol_copyMethodDescriptionList(protocol, NO, YES, &methodCount);
//    for (unsigned int index = 0; index < methodCount; index++) {
//        struct objc_method_description description = methodDescriptions[index];
//        if (![aClass instancesRespondToSelector:description.name]) {
//            [unRespondsMethods addObject:NSStringFromSelector(description.name)];
//            if (fast) {
//                return NO;
//            }
//        }
//    }
//    if (methodDescriptions != NULL) {
//        free(methodDescriptions);
//    }
    
    methodDescriptions = protocol_copyMethodDescriptionList(protocol, YES, NO, &methodCount);
    for (unsigned int index = 0; index < methodCount; index++) {
        struct objc_method_description description = methodDescriptions[index];
        if (![aClass respondsToSelector:description.name]) {
            [unRespondsMethods addObject:NSStringFromSelector(description.name)];
            if (fast) {
                return NO;
            }
        }
    }
    if (methodDescriptions != NULL) {
        free(methodDescriptions);
    }
//    methodDescriptions = protocol_copyMethodDescriptionList(protocol, NO, NO, &methodCount);
//    for (unsigned int index = 0; index < methodCount; index++) {
//        struct objc_method_description description = methodDescriptions[index];
//        if (![aClass respondsToSelector:description.name]) {
//            [unRespondsMethods addObject:NSStringFromSelector(description.name)];
//            if (fast) {
//                return NO;
//            }
//        }
//    }
//    if (methodDescriptions != NULL) {
//        free(methodDescriptions);
//    }
    
    unsigned int protocolCount = 0;
    Protocol * __unsafe_unretained *protocolList = NULL;
    protocolList = protocol_copyProtocolList(protocol, &protocolCount);
    for (unsigned int index = 0; index < protocolCount; index++) {
        Protocol *aProtocol = protocolList[index];
        if (![NSStringFromProtocol(aProtocol) isEqualToString:@"NSObject"]) {
            BOOL res = [self detectClass:aClass protocol:aProtocol unRespondsMethods:unRespondsMethods fast:fast];
            if (fast && !res) {
                return NO;
            }
        }
    }
    if (protocolList != NULL) {
        free(protocolList);
    }
    
    return unRespondsMethods.count == 0;
}

@end
