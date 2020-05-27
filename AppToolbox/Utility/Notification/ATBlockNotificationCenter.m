//
//  ATBlockNotificationCenter.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATBlockNotificationCenter.h"
#import "ATWeakObject.h"

@interface ATBlockNotificationForce : NSObject

@end

@implementation ATBlockNotificationForce

@end

@interface ATBlockNotificationCenter()

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *observers;//name->[WrapObj]
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet *> *notifications;//ObjKey->[name]

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *nativeObservers;//name->[WrapObj]
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet *> *nativeNotifications;//ObjKey->[name]

@end

@implementation ATBlockNotificationCenter

AT_IMPLEMENT_SINGLETON(ATBlockNotificationCenter);

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        
        _observers = [NSMutableDictionary<NSString *, NSMutableArray *> new];
        _notifications = [NSMutableDictionary<NSString *, NSMutableSet *> new];
        
        _nativeObservers = [NSMutableDictionary<NSString *, NSMutableArray *> new];
        _nativeNotifications = [NSMutableDictionary<NSString *, NSMutableSet *> new];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)addObserver:(id)observer name:(NSString *)name block:(nonnull id)block
{
    [self.lock lock];
    
    NSMutableArray *observers = [self.observers objectForKey:name];
    if (observers == nil) {
        observers = [NSMutableArray new];
        [self.observers setObject:observers forKey:name];
    }
    
    ATWeakObject *aWrapObj = [[ATWeakObject alloc] init];
    aWrapObj.target = observer;
    aWrapObj.extension = [block copy];
    
    for (NSUInteger i = 0; i < observers.count; ++i) {
        ATWeakObject *aWrapObj = observers[i];
        if (aWrapObj.target == observer || [aWrapObj.objectKey isEqualToString:[ATWeakObject objectKey:observer]]) {
            NSAssert(NO, @"addObserver twice name %@ observer %@", name, observer);
            return;
        }
    }
    
    [observers addObject:aWrapObj];
    
    NSMutableSet *notifications = [self.notifications objectForKey:aWrapObj.objectKey];
    if (notifications == nil) {
        notifications = [NSMutableSet new];
        [self.notifications setObject:notifications forKey:aWrapObj.objectKey];
    }
    [notifications addObject:name];
    
    [self.lock unlock];
}

- (id)forceAddObserver:(id)observer name:(NSString *)name block:(id)block
{
    ATBlockNotificationForce *force = [ATBlockNotificationForce new];
    [self addObserver:force name:name block:block];
    return force;
}

- (void)removeObserver:(id)observer name:(NSString *)name
{
    [self.lock lock];
    
    NSMutableArray *observers = [self.observers objectForKey:name];
    if (observers != nil) {
        for (NSUInteger i = 0; i < observers.count; ++i) {
            ATWeakObject *aWrapObj = observers[i];
            if (aWrapObj.target == observer || [aWrapObj.objectKey isEqualToString:[ATWeakObject objectKey:observer]]) {
                [observers removeObjectAtIndex:i];
                break;
            }
        }
        if (observers.count == 0) {
            [self.observers removeObjectForKey:name];
        }
    }
    
    NSString *objectKey = [ATWeakObject objectKey:observer];
    NSMutableSet *notifications = [self.notifications objectForKey:objectKey];
    if (notifications != nil) {
        [notifications removeObject:name];
        if (notifications.count == 0) {
            [self.notifications removeObjectForKey:objectKey];
        }
    }
    
    [self.lock unlock];
}

- (void)removeObserver:(id)observer
{
    [self.lock lock];
    
    NSString *objectKey = [ATWeakObject objectKey:observer];
    NSMutableSet *notifications = [self.notifications objectForKey:objectKey];
    [notifications enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *name = obj;
        [self removeObserver:observer name:name];
    }];
    
    [self.lock unlock];
}

- (NSArray *)blocksNamed:(NSString *)name
{
    NSMutableArray *callbacks = [NSMutableArray new];
    
    [self.lock lock];
    
    NSMutableArray *observers = [self.observers objectForKey:name];
    if (observers != nil) {
        NSMutableArray *invalidatedObservers = [NSMutableArray new];
        
        for (ATWeakObject *aWrapObj in observers) {
            if (aWrapObj.target != nil) {
                [callbacks addObject:aWrapObj.extension];
            }
            else {
                [invalidatedObservers addObject:aWrapObj];
            }
        }
        
        for (ATWeakObject *aWrapObj in invalidatedObservers) {
            NSString *objectKey = aWrapObj.objectKey;
            NSMutableSet *notifications = [self.notifications objectForKey:objectKey];
            [notifications enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSString *name = obj;
                NSMutableArray *array = [self.observers objectForKey:name];
                if (array != nil) {
                    [array removeObject:aWrapObj];
                }
            }];
            [self.notifications removeObjectForKey:objectKey];
        }
    }
    
    [self.lock unlock];
    
    return callbacks;
}

#pragma mark - Native Notification

- (void)addNativeObserver:(id)observer name:(NSString *)name block:(ATBNNativeBlock)block
{
    [self.lock lock];
    
    NSMutableArray *observers = [self.nativeObservers objectForKey:name];
    if (observers == nil) {
        observers = [NSMutableArray new];
        [self.nativeObservers setObject:observers forKey:name];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:name object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:) name:name object:nil];
    }
    
    ATWeakObject *aWrapObj = [[ATWeakObject alloc] init];
    aWrapObj.target = observer;
    aWrapObj.extension = [block copy];
    
    for (NSUInteger i = 0; i < observers.count; ++i) {
        ATWeakObject *aWrapObj = observers[i];
        if (aWrapObj.target == observer || [aWrapObj.objectKey isEqualToString:[ATWeakObject objectKey:observer]]) {
            NSAssert(NO, @"addNativeObserver twice name %@ observer %@", name, observer);
            return;
        }
    }
    
    [observers addObject:aWrapObj];
    
    NSMutableSet *notifications = [self.nativeNotifications objectForKey:aWrapObj.objectKey];
    if (notifications == nil) {
        notifications = [NSMutableSet new];
        [self.nativeNotifications setObject:notifications forKey:aWrapObj.objectKey];
    }
    [notifications addObject:name];
    
    [self.lock unlock];
}

- (id)forceAddNativeObserver:(id)observer name:(NSString *)name block:(ATBNNativeBlock)block
{
    ATBlockNotificationForce *force = [ATBlockNotificationForce new];
    [self addNativeObserver:force name:name block:block];
    return force;
}

- (void)removeNativeObserver:(id)observer name:(NSString *)name
{
    [self.lock lock];
    
    NSMutableArray *observers = [self.nativeObservers objectForKey:name];
    if (observers != nil) {
        for (NSUInteger i = 0; i < observers.count; ++i) {
            ATWeakObject *aWrapObj = observers[i];
            if (aWrapObj.target == observer || [aWrapObj.objectKey isEqualToString:[ATWeakObject objectKey:observer]]) {
                [observers removeObjectAtIndex:i];
                break;
            }
        }
        if (observers.count == 0) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:nil];
            [self.nativeObservers removeObjectForKey:name];
        }
    }
    
    NSString *objectKey = [ATWeakObject objectKey:observer];
    NSMutableSet *notifications = [self.nativeNotifications objectForKey:objectKey];
    if (notifications != nil) {
        [notifications removeObject:name];
        if (notifications.count == 0) {
            [self.nativeNotifications removeObjectForKey:objectKey];
        }
    }
    
    [self.lock unlock];
}

- (void)removeNativeObserver:(id)observer
{
    [self.lock lock];
    
    NSString *objectKey = [ATWeakObject objectKey:observer];
    NSMutableSet *notifications = [self.nativeNotifications objectForKey:objectKey];
    [notifications enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *name = obj;
        [self removeNativeObserver:observer name:name];
    }];
    
    [self.lock unlock];
}

- (void)onNotification:(NSNotification *)notification
{
    NSMutableArray *callbacks = [NSMutableArray new];
    
    [self.lock lock];
    
    NSMutableArray *observers = [self.nativeObservers objectForKey:notification.name];
    if (observers != nil) {
        NSMutableArray *invalidatedObservers = [NSMutableArray new];
        
        for (ATWeakObject *aWrapObj in observers) {
            if (aWrapObj.target != nil) {
                [callbacks addObject:aWrapObj.extension];
            }
            else {
                [invalidatedObservers addObject:aWrapObj];
            }
        }
        
        for (ATWeakObject *aWrapObj in invalidatedObservers) {
            NSString *objectKey = aWrapObj.objectKey;
            NSMutableSet *notifications = [self.nativeNotifications objectForKey:objectKey];
            [notifications enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSString *name = obj;
                NSMutableArray *array = [self.nativeObservers objectForKey:name];
                if (array != nil) {
                    [array removeObject:aWrapObj];
                }
            }];
            [self.nativeNotifications removeObjectForKey:objectKey];
        }
    }
    
    [self.lock unlock];
    
    for (ATBNNativeBlock callback in callbacks) {
        AT_SAFETY_CALL_BLOCK(callback, notification.userInfo);
    }
}

@end


@implementation NSObject (ATBN)

- (void)atbn_removeALL
{
    [AT_BN_CENTER removeObserver:self];
}

- (void)atbn_removeName:(NSString *)name
{
    [AT_BN_CENTER removeObserver:self name:name];
}

- (void)atbn_removeForce:(id)cbObj
{
    [AT_BN_CENTER removeObserver:cbObj];
}

#pragma mark - Native Notification

- (void)atbn_addNativeName:(NSString *)name block:(ATBNNativeBlock)block
{
    [AT_BN_CENTER addNativeObserver:self name:name block:block];
}

- (id)atbn_forceAddNativeName:(NSString *)name block:(ATBNNativeBlock)block
{
    return [AT_BN_CENTER forceAddNativeObserver:self name:name block:block];
}

- (void)atbn_removeNativeName:(NSString *)name
{
    [AT_BN_CENTER removeNativeObserver:self name:name];
}

- (void)atbn_removeNativeAll
{
    [AT_BN_CENTER removeNativeObserver:self];
}

- (void)atbn_removeNativeForce:(id)cbObj
{
    [AT_BN_CENTER removeNativeObserver:cbObj];
}

- (void)atbn_postNativeName:(NSString *)name
{
    if ([NSThread isMainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:self];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:self];
        });
    }
}

- (void)atbn_postNativeName:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    if ([NSThread isMainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:userInfo];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:userInfo];
        });
    }
}

@end
