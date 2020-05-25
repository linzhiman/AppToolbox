//
//  ATInstanceManagerDemo.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATInstanceManagerDemo.h"

@implementation ATModuleManagerClassA

- (void)initModule
{
    NSLog(@"ATModuleManagerClassA initModule");
}

- (void)uninitModule
{
    NSLog(@"ATModuleManagerClassA uninitModule");
}

- (void)methodA
{
    NSLog(@"ATModuleManagerClassA methodA");
}

@end

@implementation ATModuleManagerClassB

- (void)initModule
{
    NSLog(@"ATModuleManagerClassB initModule");
}

- (void)uninitModule
{
    NSLog(@"ATModuleManagerClassB uninitModule");
}

- (void)methodB
{
    NSLog(@"ATModuleManagerClassB methodB");
}

@end

@implementation ATModuleManagerEx

AT_IMPLEMENT_SINGLETON(ATModuleManagerEx)

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initModule];
    }
    return self;
}

- (void)dealloc
{
    [self uninitModule];
}

- (void)initModule
{
    self.insManager = [[ATInstanceManager alloc] init];
    
    AT_ADD_INSTANCE(self.insManager, ATModuleManagerClassA);
    AT_ADD_INSTANCE_GROUP(self.insManager, ATModuleManagerClassB , kATInstanceGroup1);
    
    {{
        NSArray *modules = [self.insManager instancesInGroup:kATInstanceDefaultGroup];
        for (id<ATModuleProtocol> tmp in modules) {
            if ([tmp respondsToSelector:@selector(initModule)]) {
                [tmp initModule];
            }
        }
    }}
    
    {{
        NSArray *modules = [self.insManager instancesInGroup:kATInstanceGroup1];
        for (id<ATModuleProtocol> tmp in modules) {
            if ([tmp respondsToSelector:@selector(initModule)]) {
                [tmp initModule];
            }
        }
    }}
}

- (void)uninitModule
{
    AT_REMOVE_INSTANCE(self.insManager, ATModuleManagerClassA);
    AT_REMOVE_INSTANCE_GROUP(self.insManager, ATModuleManagerClassB , kATInstanceGroup1);
    
    {{
        NSArray *modules = [self.insManager instancesInGroup:kATInstanceDefaultGroup];
        for (id<ATModuleProtocol> tmp in modules) {
            if ([tmp respondsToSelector:@selector(initModule)]) {
                [tmp uninitModule];
            }
        }
    }}
    
    {{
        NSArray *modules = [self.insManager instancesInGroup:kATInstanceGroup1];
        for (id<ATModuleProtocol> tmp in modules) {
            if ([tmp respondsToSelector:@selector(initModule)]) {
                [tmp uninitModule];
            }
        }
    }}
}

@end

@implementation ATInstanceManagerDemo

- (void)demo
{
    [ATDEMO_GET_MODULE(ATModuleManagerClassA) methodA];
    ATDEMO_GET_MODULE_VARIABLE(ATModuleManagerClassB, moduleB);
    [moduleB methodB];
}

@end
