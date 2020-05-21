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
@property (nonatomic, strong, nullable) id module;

@end

@implementation ATProtocolManagerMeta

@end

@interface ATProtocolManager()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMapTable<Protocol *, id> *modulesMap;
@property (nonatomic, strong) NSMapTable<Protocol *, Class> *moduleClassesMap;
@property (nonatomic, strong) NSMutableDictionary *groups;// <group, NSMutableArray<ATProtocolManagerMeta *>>

@end

@implementation ATProtocolManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _modulesMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        _moduleClassesMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return self;
}

- (id)moduleForProtocol:(Protocol *)protocol
{
    [self.lock lock];
    
    id tmp = [self.modulesMap objectForKey:protocol];
    
    [self.lock unlock];
    
    return tmp;
}

- (void)addModule:(id)module protocol:(Protocol *)protocol
{
    [self addModule:module protocol:protocol group:kATProtocolManagerDefaultGroup];
}

- (void)addModule:(id)module protocol:(Protocol *)protocol group:(NSInteger)group
{
    if (![module conformsToProtocol:protocol]) {
        return;
    }
    
    [self.lock lock];
    
    [self.modulesMap setObject:module forKey:protocol];
    
    ATProtocolManagerMeta *meta = [[ATProtocolManagerMeta alloc] init];
    meta.protocol = protocol;
    meta.module = module;
    [self removeMeta:meta];
    [self addMeta:meta group:group];
    
    [self.lock unlock];
}

- (void)removeModule:(Protocol *)protocol
{
    [self.lock lock];
    
    id obj = [self.modulesMap objectForKey:protocol];
    if (obj != nil) {
        [self.modulesMap removeObjectForKey:protocol];
        
        ATProtocolManagerMeta *meta = [[ATProtocolManagerMeta alloc] init];
        meta.protocol = protocol;
        meta.module = obj;
        [self removeMeta:meta];
    }
    
    [self.lock unlock];
}

- (Class)classForProtocol:(Protocol *)protocol
{
    [self.lock lock];
    
    Class tmp = [self.moduleClassesMap objectForKey:protocol];
    
    [self.lock unlock];
    
    return tmp;
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
    
    [self.moduleClassesMap setObject:aClass forKey:protocol];
    
    ATProtocolManagerMeta *meta = [[ATProtocolManagerMeta alloc] init];
    meta.protocol = protocol;
    meta.aClass = aClass;
    [self removeMeta:meta];
    [self addMeta:meta group:group];
    
    [self.lock unlock];
}

- (void)unRegisterClass:(Protocol *)protocol
{
    [self.lock lock];
    
    id obj = [self.moduleClassesMap objectForKey:protocol];
    if (obj != nil) {
        [self.moduleClassesMap removeObjectForKey:protocol];
        
        ATProtocolManagerMeta *meta = [[ATProtocolManagerMeta alloc] init];
        meta.protocol = protocol;
        meta.aClass = obj;
        [self removeMeta:meta];
    }
    
    [self.lock unlock];
}

- (id)module:(Protocol *)protocol
{
    id obj = [self moduleForProtocol:protocol];
    if (obj == nil) {
        Class class = [self classForProtocol:protocol];
        if (class != NULL) {
            obj = [[class alloc] init];
            [self addModule:obj protocol:protocol group:[self groupForProtocol:protocol]];
        }
    }
    return obj;
}

- (void)removeProtocol:(Protocol *)protocol
{
    [self removeModule:protocol];
    [self unRegisterClass:protocol];
}

- (NSArray *)modulesInGroup:(NSInteger)group createIfNeed:(BOOL)createIfNeed
{
    [self.lock lock];
    
    NSArray *aArray = [[self.groups objectForKey:@(group)] copy];
    
    [self.lock unlock];
    
    NSMutableArray *value = [[NSMutableArray alloc] init];
    for (ATProtocolManagerMeta *curMeta in aArray) {
        if (createIfNeed) {
            [value addObject:[self module:curMeta.protocol]];
        }
        else {
            id obj = [self moduleForProtocol:curMeta.protocol];
            if (obj != nil) {
                [value addObject:obj];
            }
        }
    }
    return [value copy];
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
            if (meta.module != nil) {
                curMeta.module = meta.module;
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
                if (meta.module != nil) {
                    curMeta.module = nil;
                }
                if (curMeta.aClass == NULL && curMeta.module == nil) {
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
