//
//  ATModuleManager.m
//  ATModuleManager
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATModuleManager.h"

const NSInteger kATModuleDefaultGroup = 0;
const NSInteger kATModuleGroup1 = 1;
const NSInteger kATModuleGroup2 = 2;

@interface ATModuleManager()

@property (nonatomic, strong) NSMutableDictionary *modules;// <identifier, id>
@property (nonatomic, strong) NSMutableDictionary *groups;// <group, NSMutableArray<id>>

@end

@implementation ATModuleManager

- (id)moduleWithIdentifier:(NSString *)identifier
{
    if (_modules == nil) {
        return nil;
    }
    else {
        return [_modules objectForKey:identifier];
    }
}

- (void)addModule:(id)module identifier:(NSString *)identifier
{
    [self addModule:module identifier:identifier group:kATModuleDefaultGroup];
}

- (void)addModule:(id)module identifier:(NSString *)identifier group:(NSInteger)group
{
    if (_modules == nil) {
        _modules = [[NSMutableDictionary alloc] init];
    }
    [_modules setObject:module forKey:identifier];
    
    if (_groups == nil) {
        _groups = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray *aArray = [_groups objectForKey:@(group)];
    if (aArray == nil) {
        aArray = [[NSMutableArray alloc] init];
        [_groups setObject:aArray forKey:@(group)];
    }
    [aArray addObject:module];
}

- (void)removeModuleWithIdentifier:(NSString *)identifier
{
    [self removeModuleWithIdentifier:identifier group:kATModuleDefaultGroup];
}

- (void)removeModuleWithIdentifier:(NSString *)identifier group:(NSInteger)group
{
    id module = [self moduleWithIdentifier:identifier];
    
    [_modules removeObjectForKey:identifier];
    
    NSMutableArray *aArray = [_groups objectForKey:@(group)];
    [aArray removeObject:module];
}

- (NSArray *)modulesInGroup:(NSInteger)group
{
    return [NSArray arrayWithArray:[_groups objectForKey:@(group)]];
}

@end
