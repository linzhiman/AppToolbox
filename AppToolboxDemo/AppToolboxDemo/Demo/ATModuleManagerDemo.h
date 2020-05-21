//
//  ATModuleManagerDemo.h
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATModuleManager.h"
#import "ATGlobalMacro.h"

@protocol ATModuleProtocol <NSObject>

- (void)initModule;
- (void)uninitModule;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ATModuleManagerClassA : NSObject<ATModuleProtocol>

- (void)methodA;

@end

@interface ATModuleManagerClassB : NSObject<ATModuleProtocol>

- (void)methodB;

@end

#define ATDEMO_GET_MODULE(atModuleClass) \
    AT_GET_MODULE([ATModuleManagerEx sharedObject].moduleManager, atModuleClass)
#define ATDEMO_GET_MODULE_VARIABLE(atModuleClass, atVariable) \
    AT_GET_MODULE_VARIABLE([ATModuleManagerEx sharedObject].moduleManager, atModuleClass, atVariable)

@interface ATModuleManagerEx : NSObject

AT_DECLARE_SINGLETON;

@property (nonatomic, strong) ATModuleManager *moduleManager;

@end

@interface ATModuleManagerDemo : NSObject

- (void)demo;

@end

NS_ASSUME_NONNULL_END
