//
//  ATModuleManagerDemo.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATModuleManagerDemo.h"

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
    self.moduleManager = [[ATModuleManager alloc] init];
    
    AT_ADD_MODULE(self.moduleManager, ATModuleManagerClassA);
    AT_ADD_MODULE_GROUP(self.moduleManager, ATModuleManagerClassB , kATModuleGroup1);
    
    {{
        NSArray *modules = [self.moduleManager modulesInGroup:kATModuleDefaultGroup];
        for (id<ATModuleProtocol> tmp in modules) {
            if ([tmp respondsToSelector:@selector(initModule)]) {
                [tmp initModule];
            }
        }
    }}
    
    {{
        NSArray *modules = [self.moduleManager modulesInGroup:kATModuleGroup1];
        for (id<ATModuleProtocol> tmp in modules) {
            if ([tmp respondsToSelector:@selector(initModule)]) {
                [tmp initModule];
            }
        }
    }}
}

- (void)uninitModule
{
    AT_REMOVE_MODULE(self.moduleManager, ATModuleManagerClassA);
    AT_REMOVE_MODULE_GROUP(self.moduleManager, ATModuleManagerClassB , kATModuleGroup1);
    
    {{
        NSArray *modules = [self.moduleManager modulesInGroup:kATModuleDefaultGroup];
        for (id<ATModuleProtocol> tmp in modules) {
            if ([tmp respondsToSelector:@selector(initModule)]) {
                [tmp uninitModule];
            }
        }
    }}
    
    {{
        NSArray *modules = [self.moduleManager modulesInGroup:kATModuleGroup1];
        for (id<ATModuleProtocol> tmp in modules) {
            if ([tmp respondsToSelector:@selector(initModule)]) {
                [tmp uninitModule];
            }
        }
    }}
}

@end

@implementation ATModuleManagerDemo

- (void)demo
{
    [ATDEMO_GET_MODULE(ATModuleManagerClassA) methodA];
    ATDEMO_GET_MODULE_VARIABLE(ATModuleManagerClassB, moduleB);
    [moduleB methodB];
}

@end
