//
//  ATProtocolManagerDemo.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATProtocolManagerDemo.h"

@implementation ATProtocolManagerClassA

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"ATProtocolManagerClassA init");
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"ATProtocolManagerClassA dealloc");
}

- (void)base
{
    NSLog(@"ATProtocolManagerClassA base");
}

- (void)methodA
{
    NSLog(@"ATProtocolManagerClassA methodA");
}

@end

@implementation ATProtocolManagerClassB

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"ATProtocolManagerClassB init");
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"ATProtocolManagerClassB dealloc");
}

- (void)base
{
    NSLog(@"ATProtocolManagerClassB base");
}

- (void)methodB
{
    NSLog(@"ATProtocolManagerClassB methodB");
}

@end

@implementation ATProtocolManagerClassC

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"ATProtocolManagerClassC init");
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"ATProtocolManagerClassC dealloc");
}

- (void)base
{
    NSLog(@"ATProtocolManagerClassC base");
}

- (void)methodC
{
    NSLog(@"ATProtocolManagerClassC methodC");
}

@end

@implementation ATProtocolManagerClassD

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"ATProtocolManagerClassD init");
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"ATProtocolManagerClassD dealloc");
}

- (void)base
{
    NSLog(@"ATProtocolManagerClassD base");
}

- (void)methodD
{
    NSLog(@"ATProtocolManagerClassD methodD");
}

@end

@implementation ATProtocolManagerEx

AT_IMPLEMENT_SINGLETON(ATProtocolManagerEx)

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
    self.protocolManager = [[ATProtocolManager alloc] init];
    
    [self.protocolManager addModule:[[ATProtocolManagerClassA alloc] init] protocol:@protocol(ATProtocolManagerProtocolA)];
    [self.protocolManager addModule:[[ATProtocolManagerClassB alloc] init] protocol:@protocol(ATProtocolManagerProtocolB) group:1];
    [self.protocolManager registerClass:[ATProtocolManagerClassC class] protocol:@protocol(ATProtocolManagerProtocolC)];
    [self.protocolManager registerClass:[ATProtocolManagerClassD class] protocol:@protocol(ATProtocolManagerProtocolD) group:1];
}

- (void)uninitModule
{
    [self.protocolManager removeProtocol:@protocol(ATProtocolManagerProtocolA)];
    [self.protocolManager removeProtocol:@protocol(ATProtocolManagerProtocolB)];
    [self.protocolManager removeProtocol:@protocol(ATProtocolManagerProtocolC)];
    [self.protocolManager removeProtocol:@protocol(ATProtocolManagerProtocolD)];
}

- (void)callModulesInGroup1
{
    NSArray *aArray = [self.protocolManager modulesInGroup:1 createIfNeed:YES];
    [aArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<ATProtocolManagerProtocolBase> module = obj;
        [module base];
    }];
}

@end

@implementation ATProtocolManagerDemo

- (void)demo
{
    {{
        [ATDEMO_GET_MODULE_PROTOCOL(ATProtocolManagerProtocolA) methodA];
        [ATDEMO_GET_MODULE_PROTOCOL(ATProtocolManagerProtocolB) methodB];
        ATDEMO_GET_MODULE_PROTOCOL_VARIABLE(ATProtocolManagerProtocolC, protocolC);
        [protocolC methodC];
        ATDEMO_GET_MODULE_PROTOCOL_VARIABLE(ATProtocolManagerProtocolD, protocolD);
        [protocolD methodD];
    }}
    
    [[ATProtocolManagerEx sharedObject] callModulesInGroup1];
    
    [[ATProtocolManagerEx sharedObject] uninitModule];
    
    [ATDEMO_GET_MODULE_PROTOCOL(ATProtocolManagerProtocolA) methodA];
    ATDEMO_GET_MODULE_PROTOCOL_VARIABLE(ATProtocolManagerProtocolC, protocolC);
    [protocolC methodC];
}

@end
