//
//  ATWeakProxy.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATWeakProxy.h"

@implementation ATWeakProxy

+ (instancetype)proxyWithTarget:(id)target
{
    return [[ATWeakProxy alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(id)target
{
    _target = target;
    return self;
}

- (id)forwardingTargetForSelector:(SEL)selector
{
    return self.target;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [self.target methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [self.target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object
{
    return [self.target isEqual:object];
}

- (NSUInteger)hash
{
    return [self.target hash];
}

- (Class)superclass
{
    return [self.target superclass];
}

- (Class)class
{
    return [self.target class];
}

- (BOOL)isKindOfClass:(Class)aClass
{
    return [self.target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass
{
    return [self.target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return [self.target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy
{
    return YES;
}

- (NSString *)description
{
    return [self.target description];
}

- (NSString *)debugDescription
{
    return [self.target debugDescription];
}

@end
