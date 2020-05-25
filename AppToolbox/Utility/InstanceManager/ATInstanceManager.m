//
//  ATInstanceManager.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATInstanceManager.h"

const NSInteger kATInstanceDefaultGroup = 0;
const NSInteger kATInstanceGroup1 = 1;
const NSInteger kATInstanceGroup2 = 2;

@interface ATInstanceManager()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableDictionary *instances;// <identifier, id>
@property (nonatomic, strong) NSMutableDictionary *groups;// <group, NSMutableArray<id>>

@end

@implementation ATInstanceManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _instances = [[NSMutableDictionary alloc] init];
        _groups = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id _Nullable)instanceWithIdentifier:(NSString *)identifier
{
    if (identifier.length == 0) {
        return nil;
    }
    
    [self.lock lock];
    
    id instance = [self.instances objectForKey:identifier];
    
    [self.lock unlock];
    
    return instance;
}

- (void)addInstance:(id)instance identifier:(NSString *)identifier
{
    [self addInstance:instance identifier:identifier group:kATInstanceDefaultGroup];
}

- (void)addInstance:(id)instance identifier:(NSString *)identifier group:(NSInteger)group
{
    if (identifier.length == 0) {
        return;
    }
    
    [self.lock lock];
    
    [self.instances setObject:instance forKey:identifier];
    
    NSMutableArray *aArray = [self.groups objectForKey:@(group)];
    if (aArray == nil) {
        aArray = [[NSMutableArray alloc] init];
        [self.groups setObject:aArray forKey:@(group)];
    }
    [aArray addObject:instance];
    
    [self.lock unlock];
}

- (void)removeInstanceWithIdentifier:(NSString *)identifier
{
    [self removeInstanceWithIdentifier:identifier group:kATInstanceDefaultGroup];
}

- (void)removeInstanceWithIdentifier:(NSString *)identifier group:(NSInteger)group
{
    if (identifier.length == 0) {
        return;
    }
    
    id instance = [self instanceWithIdentifier:identifier];
    if (instance == nil) {
        return;
    }
    
    [self.lock lock];
    
    [self.instances removeObjectForKey:identifier];
    
    NSMutableArray *aArray = [self.groups objectForKey:@(group)];
    [aArray removeObject:instance];
    
    [self.lock unlock];
}

- (NSArray * _Nullable)instancesInGroup:(NSInteger)group
{
    [self.lock lock];
    
    NSMutableArray *aArray = [self.groups objectForKey:@(group)];
    
    [self.lock unlock];
    
    return [NSArray arrayWithArray:aArray];
}

@end
