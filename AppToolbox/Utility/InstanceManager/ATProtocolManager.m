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

- (BOOL)addInstance:(id)instance protocol:(Protocol *)protocol
{
    return [self addInstance:instance protocol:protocol group:kATProtocolManagerDefaultGroup];
}

- (BOOL)addInstance:(id)instance protocol:(Protocol *)protocol group:(NSInteger)group
{
    if (instance == nil || ![instance conformsToProtocol:protocol]) {
        return NO;
    }
    
    [self.lock lock];
    
    [self.instancesMap setObject:instance forKey:protocol];
    
    ATProtocolManagerMeta *meta = [[ATProtocolManagerMeta alloc] init];
    meta.protocol = protocol;
    meta.instance = instance;
    [self removeMeta:meta];
    [self addMeta:meta group:group];
    
    [self.lock unlock];
    
    return YES;
}

- (BOOL)registerClass:(Class)aClass protocol:(Protocol *)protocol
{
    return [self registerClass:aClass protocol:protocol group:kATProtocolManagerDefaultGroup];
}

- (BOOL)registerClass:(Class)aClass protocol:(Protocol *)protocol group:(NSInteger)group
{
    if (![aClass conformsToProtocol:protocol]) {
        return NO;
    }
    
    [self.lock lock];
    
    [self.instanceClassesMap setObject:aClass forKey:protocol];
    
    ATProtocolManagerMeta *meta = [[ATProtocolManagerMeta alloc] init];
    meta.protocol = protocol;
    meta.aClass = aClass;
    [self removeMeta:meta];
    [self addMeta:meta group:group];
    
    [self.lock unlock];
    
    return YES;
}

- (id _Nullable)instance:(Protocol *)protocol
{
    id instance = [self instanceOnlyForProtocol:protocol];
    if (instance == nil) {
        Class aClass = [self classForProtocol:protocol];
        if (aClass != NULL) {
            instance = [[aClass alloc] init];
            [self addInstance:instance protocol:protocol group:[self groupForProtocol:protocol]];
        }
    }
    return instance;
}

- (BOOL)removeInstance:(Protocol *)protocol
{
    BOOL res = [self removeInstanceOnlyForProtocol:protocol];
    BOOL res2 = [self unRegisterClass:protocol];
    return res || res2;
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

- (id _Nullable)instanceOnlyForProtocol:(Protocol *)protocol
{
    [self.lock lock];
    
    id instance = [self.instancesMap objectForKey:protocol];
    
    [self.lock unlock];
    
    return instance;
}

- (BOOL)removeInstanceOnlyForProtocol:(Protocol *)protocol
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
    
    return instance != nil;
}

- (Class)classForProtocol:(Protocol *)protocol
{
    [self.lock lock];
    
    Class aClass = [self.instanceClassesMap objectForKey:protocol];
    
    [self.lock unlock];
    
    return aClass;
}

- (BOOL)unRegisterClass:(Protocol *)protocol
{
    [self.lock lock];
    
    Class aClass = [self.instanceClassesMap objectForKey:protocol];
    if (aClass != NULL) {
        [self.instanceClassesMap removeObjectForKey:protocol];
        
        ATProtocolManagerMeta *meta = [[ATProtocolManagerMeta alloc] init];
        meta.protocol = protocol;
        meta.aClass = aClass;
        [self removeMeta:meta];
    }
    
    [self.lock unlock];
    
    return aClass != NULL;
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
