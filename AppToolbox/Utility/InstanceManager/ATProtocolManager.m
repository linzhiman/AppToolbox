//
//  ATProtocolManager.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATProtocolManager.h"

const NSInteger kATProtocolManagerDefaultGroup = 0;
const NSInteger kATProtocolManagerGroup1 = 1;
const NSInteger kATProtocolManagerGroup2 = 2;

@interface ATProtocolManagerMeta : NSObject

@property (nonatomic, strong) Protocol *protocol;
@property (nonatomic, strong, nullable) Class aClass;
@property (nonatomic, strong, nullable) id instance;

@end

@implementation ATProtocolManagerMeta

@end

@interface ATProtocolManager()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMapTable<Protocol *, id> *instancesMap;
@property (nonatomic, strong) NSMapTable<Protocol *, Class> *instanceClassesMap;
@property (nonatomic, strong) NSMutableDictionary *groups;// <group, NSMutableArray<ATProtocolManagerMeta *>>

@end

@implementation ATProtocolManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _instancesMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        _instanceClassesMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return self;
}

- (void)addInstance:(id)instance protocol:(Protocol *)protocol
{
    [self addInstance:instance protocol:protocol group:kATProtocolManagerDefaultGroup];
}

- (void)addInstance:(id)instance protocol:(Protocol *)protocol group:(NSInteger)group
{
    if (![instance conformsToProtocol:protocol]) {
        return;
    }
    
    [self.lock lock];
    
    [self.instancesMap setObject:instance forKey:protocol];
    
    ATProtocolManagerMeta *meta = [[ATProtocolManagerMeta alloc] init];
    meta.protocol = protocol;
    meta.instance = instance;
    [self removeMeta:meta];
    [self addMeta:meta group:group];
    
    [self.lock unlock];
}

- (void)registerClass:(Class)aClass protocol:(Protocol *)protocol
{
    [self registerClass:aClass protocol:protocol group:kATProtocolManagerDefaultGroup];
}

- (void)registerClass:(Class)aClass protocol:(Protocol *)protocol group:(NSInteger)group
{
    if (![aClass conformsToProtocol:protocol]) {
        return;
    }
    
    [self.lock lock];
    
    [self.instanceClassesMap setObject:aClass forKey:protocol];
    
    ATProtocolManagerMeta *meta = [[ATProtocolManagerMeta alloc] init];
    meta.protocol = protocol;
    meta.aClass = aClass;
    [self removeMeta:meta];
    [self addMeta:meta group:group];
    
    [self.lock unlock];
}

- (id)instance:(Protocol *)protocol
{
    id instance = [self instanceOnlyForProtocol:protocol];
    if (instance == nil) {
        Class class = [self classForProtocol:protocol];
        if (class != NULL) {
            instance = [[class alloc] init];
            [self addInstance:instance protocol:protocol group:[self groupForProtocol:protocol]];
        }
    }
    return instance;
}

- (void)removeInstance:(Protocol *)protocol
{
    [self removeInstanceOnlyForProtocol:protocol];
    [self unRegisterClass:protocol];
}

- (NSArray *)instancesInDefaultGroup
{
    return [self instancesInGroup:kATProtocolManagerDefaultGroup];
}

- (NSArray *)instancesInGroup:(NSInteger)group
{
    [self.lock lock];
    
    NSArray *aArray = [[self.groups objectForKey:@(group)] copy];
    
    [self.lock unlock];
    
    BOOL createIfNeed = YES; // 默认创建实例
    
    NSMutableArray *value = [[NSMutableArray alloc] init];
    for (ATProtocolManagerMeta *curMeta in aArray) {
        if (createIfNeed) {
            [value addObject:[self instance:curMeta.protocol]];
        }
        else {
            id instance = [self instanceOnlyForProtocol:curMeta.protocol];
            if (instance != nil) {
                [value addObject:instance];
            }
        }
    }
    return [value copy];
}

- (id)instanceOnlyForProtocol:(Protocol *)protocol
{
    [self.lock lock];
    
    id tmp = [self.instancesMap objectForKey:protocol];
    
    [self.lock unlock];
    
    return tmp;
}

- (void)removeInstanceOnlyForProtocol:(Protocol *)protocol
{
    [self.lock lock];
    
    id instance = [self.instancesMap objectForKey:protocol];
    if (instance != nil) {
        [self.instancesMap removeObjectForKey:protocol];
        
        ATProtocolManagerMeta *meta = [[ATProtocolManagerMeta alloc] init];
        meta.protocol = protocol;
        meta.instance = instance;
        [self removeMeta:meta];
    }
    
    [self.lock unlock];
}

- (Class)classForProtocol:(Protocol *)protocol
{
    [self.lock lock];
    
    Class tmp = [self.instanceClassesMap objectForKey:protocol];
    
    [self.lock unlock];
    
    return tmp;
}

- (void)unRegisterClass:(Protocol *)protocol
{
    [self.lock lock];
    
    id obj = [self.instanceClassesMap objectForKey:protocol];
    if (obj != nil) {
        [self.instanceClassesMap removeObjectForKey:protocol];
        
        ATProtocolManagerMeta *meta = [[ATProtocolManagerMeta alloc] init];
        meta.protocol = protocol;
        meta.aClass = obj;
        [self removeMeta:meta];
    }
    
    [self.lock unlock];
}

- (void)addMeta:(ATProtocolManagerMeta *)meta group:(NSInteger)group
{
    if (self.groups == nil) {
        self.groups = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *aArray = [self.groups objectForKey:@(group)];
    if (aArray == nil) {
        aArray = [[NSMutableArray alloc] init];
        [self.groups setObject:aArray forKey:@(group)];
    }
    for (ATProtocolManagerMeta *curMeta in aArray) {
        if (curMeta.protocol == meta.protocol) {
            if (meta.aClass != NULL) {
                curMeta.aClass = meta.aClass;
            }
            if (meta.instance != nil) {
                curMeta.instance = meta.instance;
            }
            return;
        }
    }
    [aArray addObject:meta];
}

- (void)removeMeta:(ATProtocolManagerMeta *)meta
{
    for (NSMutableArray *aArray in self.groups.allValues) {
        for (ATProtocolManagerMeta *curMeta in aArray) {
            if (curMeta.protocol == meta.protocol) {
                if (meta.aClass != NULL) {
                    curMeta.aClass = NULL;
                }
                if (meta.instance != nil) {
                    curMeta.instance = nil;
                }
                if (curMeta.aClass == NULL && curMeta.instance == nil) {
                    [aArray removeObject:curMeta];
                    return;
                }
            }
        }
    }
}

- (NSInteger)groupForProtocol:(Protocol *)protocol
{
    NSInteger group = -1;
    
    [self.lock lock];
    
    for (NSUInteger i = 0; i < self.groups.allValues.count; ++i) {
        NSMutableArray *aArray = self.groups.allValues[i];
        for (ATProtocolManagerMeta *curMeta in aArray) {
            if (curMeta.protocol == protocol) {
                group = i;
            }
        }
    }
    
    [self.lock unlock];
    
    return group;
}

@end
