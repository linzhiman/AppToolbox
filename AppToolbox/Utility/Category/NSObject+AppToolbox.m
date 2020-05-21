//
//  NSObject+AppToolbox.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "NSObject+AppToolbox.h"
#import <objc/runtime.h>
#import "ATGlobalMacro.h"
#import "ATWeakObject.h"

AT_STRING_DEFINE(kATObjectAssociatedPropertys);

@interface ATWeakPerformSelectorObject : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) id object;

@end

@implementation ATWeakPerformSelectorObject

- (void)action
{
    if (self.target != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:self.object];
#pragma clang diagnostic pop
    }
}

@end

@implementation NSObject (AppToolbox)

- (void)at_performSelector:(SEL)selector withObject:(id)object afterDelay:(NSTimeInterval)delay
{
    ATWeakPerformSelectorObject *selectorObject = [[ATWeakPerformSelectorObject alloc] init];
    selectorObject.target = self;
    selectorObject.selector = selector;
    selectorObject.object = object;
    [selectorObject performSelector:@selector(action) withObject:nil afterDelay:delay];
    
    objc_setAssociatedObject(self, selector, selectorObject, OBJC_ASSOCIATION_RETAIN);
}

+ (void)at_cancelPreviousPerformRequestsWithTarget:(id)target selector:(SEL)selector
{
    ATWeakPerformSelectorObject *selectorObject = objc_getAssociatedObject(target, selector);
    if (selectorObject && selectorObject.target == target) {
        [NSObject cancelPreviousPerformRequestsWithTarget:selectorObject selector:@selector(action) object:nil];
    }
}

- (NSMutableDictionary *)propertys
{
    id props = [self at_associatedObject:kATObjectAssociatedPropertys];
    if (props == nil) {
        props = [[NSMutableDictionary alloc] init];
        [self at_setAssociatedObject:props key:kATObjectAssociatedPropertys];
    }
    return props;
}

- (id)at_getProperty:(NSString *)name
{
    return [[self propertys] objectForKey:name];
}

- (void)at_setProperty:(id)property withName:(NSString *)name
{
    @synchronized (self) {
        [[self propertys] setObject:property forKey:name];
    }
}

- (void)at_removeProperty:(NSString *)name
{
    id props = [self at_associatedObject:kATObjectAssociatedPropertys];
    if (props != nil) {
        NSMutableDictionary *propDic = props;
        [propDic removeObjectForKey:name];
        if (propDic.count == 0) {
            [self at_removeAssociatedObject:kATObjectAssociatedPropertys];
        }
    }
}

- (id)at_associatedObject:(NSString *)key
{
    return objc_getAssociatedObject(self, (__bridge const void *)(key));
}

- (void)at_setAssociatedObject:(id)object key:(NSString *)key
{
    objc_setAssociatedObject(self, (__bridge const void *)(key), object, OBJC_ASSOCIATION_RETAIN);
}

- (void)at_removeAssociatedObject:(NSString *)key
{
    objc_setAssociatedObject(self, (__bridge const void *)(key), nil, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)at_delegates
{
    NSMutableArray *delegates = objc_getAssociatedObject(self, _cmd);
    if (delegates == nil) {
        delegates = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, delegates, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegates;
}

- (void)at_addDelegate:(id)delegate
{
    ATWeakObject *weakObject = [[ATWeakObject alloc] init];
    weakObject.target = delegate;
    [[self at_delegates] addObject:weakObject];
}

- (void)at_removeDelegate:(id)delegate
{
    ATWeakObject *weakObject = [ATWeakObject new];
    weakObject.target = delegate;
    [[self at_delegates] removeObject:weakObject];
}

- (void)at_checkSelector:(SEL)selector callback:(void (^)(id delegate))callback
{
    for (ATWeakObject *weakObject in [self at_delegates]) {
        if ([weakObject.target respondsToSelector:selector]) {
            callback(weakObject.target);
        }
    }
}

@end
