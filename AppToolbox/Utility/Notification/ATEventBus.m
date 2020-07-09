//
//  ATEventBus.m
//  AppToolbox
//
//  Created by linzhiman on 2020/7/2.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATEventBus.h"
#import "ATWeakObject.h"
#import <pthread.h>

@protocol IATEBEvent;

typedef void (^ATEventBusAction)(id<IATEBEvent> event);

@interface ATEventBus (Private)

- (void)regEvent:(id<IATEBEvent>)event observer:(id)observer action:(ATEventBusAction)action;

- (void)unRegEvent:(id<IATEBEvent>)event observer:(id)observer;

- (void)postEvent:(id<IATEBEvent>)event;

@end

@interface ATEBEvent ()

@property (nonatomic, strong) NSString *name;
@property (nullable, nonatomic, strong) id data;

@end

@implementation ATEBEvent

+ (instancetype)eventWithName:(NSString *)name
{
    ATEBEvent *tmp = [ATEBEvent new];
    tmp.name = name;
    return tmp;
}

+ (instancetype)eventWithName:(NSString *)name data:(nullable id)data
{
    ATEBEvent *tmp = [ATEBEvent new];
    tmp.name = name;
    tmp.data = data;
    return tmp;
}

- (NSString *)eventId
{
    return self.name;
}

- (BOOL)sysEvent
{
    return ![self.name hasPrefix:AT_EB_NAME_PREFIX];
}

- (void)post_data:(id)data
{
    self.data = data;
    [[ATEventBus sharedObject] postEvent:self];
}

@end

@interface ATEBObserverProxy : NSObject<IATEBEventToken>

@end

@implementation ATEBObserverProxy

- (void)dispose
{
    [[ATEventBus sharedObject] unRegAllEvent:self];
}

@end

@interface ATEventNode : NSObject

@property (nonatomic, strong) id userInfo;
@property (nonatomic, strong) ATEventNode *prev;
@property (nonatomic, strong) ATEventNode *next;

+ (instancetype)node:(id)userInfo;

@end

@implementation ATEventNode

+ (instancetype)node:(id)userInfo
{
    ATEventNode *tmp = [ATEventNode new];
    tmp.userInfo = userInfo;
    return tmp;
}

@end

@interface ATEventList : NSObject

@property (nonatomic, strong) ATEventNode *root;

- (void)add:(ATEventNode *)node;
- (void)remove:(ATEventNode *)node;
- (BOOL)isEmpty;

@end

@implementation ATEventList

- (instancetype)init
{
    self = [super init];
    if (self) {
        _root = [ATEventNode node:nil];
        _root.next = _root;
        _root.prev = _root;
    }
    return self;
}

- (void)add:(ATEventNode *)node
{
    ATEventNode *tail = self.root.prev;
    node.next = self.root;
    node.prev = tail;
    tail.next = node;
    self.root.prev = node;
}

- (void)remove:(ATEventNode *)node
{
    node.next.prev = node.prev;
    node.prev.next = node.next;
    node.next = nil;
    node.prev = nil;
}

- (BOOL)isEmpty
{
    return self.root.next == self.root;
}

@end

@interface ATEventMap : NSObject

/// 存储一个事件的所有订阅者, eventId->[WrapObj], WrapObj(observer, action)
@property (nonatomic, strong) NSMutableDictionary<NSString *, ATEventList *> *observers;
/// 存储一个对象订阅的所有事件, ObjKey->[eventId]
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet *> *actions;
@property (nonatomic, assign) pthread_mutex_t lock;

@end

@implementation ATEventMap

- (instancetype)init
{
    self = [super init];
    if (self) {
        _observers = [NSMutableDictionary new];
        _actions = [NSMutableDictionary new];
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_lock);
}

- (void)add:(NSString *)eventId observer:(id)observer action:(ATEventBusAction)action
{
    pthread_mutex_lock(&_lock);
    
    ATEventList *observers = [self.observers objectForKey:eventId];
    if (observers == nil) {
        observers = [ATEventList new];
        [self.observers setObject:observers forKey:eventId];
    }
    
    ATEventNode *head = observers.root.next;
    while (head != observers.root) {
        ATWeakObject *aWrapObj = (ATWeakObject *)head.userInfo;
        if (aWrapObj.target == observer) {
            NSAssert(NO, @"addObserver twice eventId %@ observer %@", eventId, observer);
            return;
        }
        head = head.next;
    }
    
    ATWeakObject *aWrapObj = [ATWeakObject new];
    aWrapObj.target = observer;
    aWrapObj.userInfo = [action copy];
    
    [observers add:[ATEventNode node:aWrapObj]];
    
    NSMutableSet *actions = [self.actions objectForKey:aWrapObj.objectKey];
    if (actions == nil) {
        actions = [NSMutableSet new];
        [self.actions setObject:actions forKey:aWrapObj.objectKey];
    }
    [actions addObject:eventId];
    
    pthread_mutex_unlock(&_lock);
}

- (BOOL)remove:(NSString *)eventId observer:(id)observer
{
    pthread_mutex_lock(&_lock);
    
    ATEventList *observers = [self.observers objectForKey:eventId];
    if (observers != nil) {
        ATEventNode *head = observers.root.next;
        while (head != observers.root) {
            ATWeakObject *aWrapObj = (ATWeakObject *)head.userInfo;
            if (aWrapObj.target == observer) {
                [observers remove:head];
                break;
            }
            head = head.next;
        }
        
        if (observers.isEmpty) {
            [self.observers removeObjectForKey:eventId];
        }
    }
    
    NSString *objectKey = [ATWeakObject objectKey:observer];
    NSMutableSet *actions = [self.actions objectForKey:objectKey];
    if (actions != nil) {
        [actions removeObject:eventId];
        if (actions.count == 0) {
            [self.actions removeObjectForKey:objectKey];
        }
    }
    
    BOOL isEmpty = observers.isEmpty;
    
    pthread_mutex_unlock(&_lock);
    
    return isEmpty;
}

- (void)removeObserver:(id)observer
{
    pthread_mutex_lock(&_lock);
    
    NSString *objectKey = [ATWeakObject objectKey:observer];
    NSMutableSet *actions = [self.actions objectForKey:objectKey];
    
    pthread_mutex_unlock(&_lock);
    
    [actions enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *eventId = obj;
        [self remove:eventId observer:observer];
    }];
}

- (NSArray<ATEventBusAction> *)actions:(NSString *)eventId
{
    NSMutableArray *actions = [NSMutableArray new];
    
    pthread_mutex_lock(&_lock);
    
    ATEventList *observers = [self.observers objectForKey:eventId];
    if (observers != nil) {
        ATEventNode *head = observers.root.next;
        while (head != observers.root) {
            ATWeakObject *aWrapObj = (ATWeakObject *)head.userInfo;
            if (aWrapObj.target != nil && aWrapObj.userInfo != nil) {
                [actions addObject:aWrapObj.userInfo];
            }
            head = head.next;
        }
    }
    
    pthread_mutex_unlock(&_lock);
    
    return actions;
}

- (void)removeDeallocObserver
{
    pthread_mutex_lock(&_lock);
    
    NSMutableSet *objKeySet = [NSMutableSet new];
    for (NSString *eventId in self.observers.allKeys) {
        ATEventList *eventList = self.observers[eventId];
        ATEventNode *head = eventList.root.next;
        while (head != eventList.root) {
            ATWeakObject *aWrapObj = (ATWeakObject *)head.userInfo;
            if (aWrapObj.target == nil) {
                [objKeySet addObject:aWrapObj.objectKey];
                ATEventNode *tmp = head.next;
                [eventList remove:head];
                head = tmp;
                continue;
            }
            head = head.next;
        }
    }
    
    for (NSString *objKey in objKeySet) {
        [self.actions removeObjectForKey:objKey];
    }
    
    pthread_mutex_unlock(&_lock);
}

@end

@interface ATEBObserverBuilder ()

@property (nonatomic, strong) id anObserver;
@property (nonatomic, strong) id<IATEBEvent> anEvent;
@property (nonatomic, strong) dispatch_queue_t aQueue;

@property (nonatomic, copy, readonly) ATEBObserverBuilder *(^event)(id<IATEBEvent>);

@end

@implementation ATEBObserverBuilder

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmismatched-return-types"
- (ATEBObserverBuilder * _Nonnull (^)(id _Nonnull))observer
{
    return ^ATEBObserverBuilder * (id observer) {
        self.anObserver = observer;
        return self;
    };
}

- (ATEBObserverBuilder  * _Nonnull (^)(id<IATEBEvent> _Nonnull))event
{
    return ^ATEBObserverBuilder * (id<IATEBEvent> event) {
        self.anEvent = event;
        return self;
    };
}

- (ATEBObserverBuilder * _Nonnull (^)(dispatch_queue_t _Nonnull))atQueue
{
    return ^ATEBObserverBuilder * (dispatch_queue_t queue) {
        self.aQueue = queue;
        return self;
    };
}
#pragma clang diagnostic pop

- (void (^)(void))unReg
{
    return ^ void (void) {
        if (self.anEvent != nil && self.anObserver != nil) {
            [[ATEventBus sharedObject] unRegEvent:self.anEvent observer:self.anObserver];
        }
    };
}

- (void)reg:(ATEBObserverBuilderBlock)action
{
    if (self.anEvent != nil && self.anObserver != nil) {
        [[ATEventBus sharedObject] regEvent:self.anEvent observer:self.anObserver action:action];
    }
}

- (id<IATEBEventToken>)forceReg:(ATEBObserverBuilderBlock)action
{
    if (self.anEvent != nil) {
        ATEBObserverProxy *proxy = [ATEBObserverProxy new];
        [[ATEventBus sharedObject] regEvent:self.anEvent observer:proxy action:action];
        return proxy;
    }
    return nil;
}

+ (ATEBObserverBuilder *)builderWithEvent:(id<IATEBEvent>)event
{
    ATEBObserverBuilder *builder = [ATEBObserverBuilder new];
    return builder.event(event);
}

@end

@interface ATEventBus ()

@property (nonatomic, strong) ATEventMap *sysEvents;
@property (nonatomic, strong) ATEventMap *userEvents;

@end

@implementation ATEventBus

AT_IMPLEMENT_SINGLETON(ATEventBus);

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sysEvents = [ATEventMap new];
        _userEvents= [ATEventMap new];
        [self removeDeallocObserversRecursively];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)unRegAllEvent:(id)observer
{
    [self.sysEvents removeObserver:observer];
    [self.userEvents removeObserver:observer];
}

- (void)removeDeallocObserversRecursively {
    AT_WEAKIFY_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [weak_self removeDeallocObservers];
        [weak_self removeDeallocObserversRecursively];
    });
}

- (void)removeDeallocObservers
{
    [self.sysEvents removeDeallocObserver];
    [self.userEvents removeDeallocObserver];
}

@end

@implementation ATEventBus (Private)

- (void)regEvent:(id<IATEBEvent>)event observer:(id)observer action:(ATEventBusAction)action
{
    if (event == nil || [event eventId].length == 0 || observer == nil || action == NULL) {
        return;
    }
    
    NSString *eventId = [event eventId];
    if (event.sysEvent) {
        [self.sysEvents add:eventId observer:observer action:action];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:eventId object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:) name:eventId object:nil];
    }
    else {
        [self.userEvents add:eventId observer:observer action:action];
    }
}

- (void)unRegEvent:(id<IATEBEvent>)event observer:(id)observer
{
    if (event == nil || [event eventId].length == 0 || observer == nil) {
        return;
    }
    
    NSString *eventId = [event eventId];
    if (event.sysEvent) {
        BOOL noObserver = [self.sysEvents remove:eventId observer:observer];
        if (noObserver) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer name:eventId object:nil];
        }
    }
    else {
        [self.userEvents remove:eventId observer:observer];
    }
}

- (void)postEvent:(id<IATEBEvent>)event
{
    if (event == nil || [event eventId].length == 0) {
        return;
    }
    
    NSString *eventId = [event eventId];
    if (event.sysEvent) {
        if ([NSThread isMainThread]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:eventId object:self userInfo:event.data];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:eventId object:self userInfo:event.data];
            });
        }
    }
    else {
        for (ATEventBusAction action in [self.userEvents actions:eventId]) {
            AT_SAFETY_CALL_BLOCK(action, event);
        }
    }
}

- (void)onNotification:(NSNotification *)notification
{
    NSString *eventId = notification.name;
    ATEBEvent *event = [ATEBEvent eventWithName:eventId data:notification.userInfo];
    for (ATEventBusAction action in [self.sysEvents actions:eventId]) {
        AT_SAFETY_CALL_BLOCK(action, event);
    }
}

@end
