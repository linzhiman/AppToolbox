//
//  ATProtocolManagerDemo.h
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATProtocolManager.h"
#import "ATGlobalMacro.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ATProtocolManagerProtocolBase <NSObject>

- (void)base;

@end

@protocol ATProtocolManagerProtocolA <ATProtocolManagerProtocolBase>

- (void)methodA;

@end

@protocol ATProtocolManagerProtocolB <ATProtocolManagerProtocolBase>

- (void)methodB;

@end

@protocol ATProtocolManagerProtocolC <ATProtocolManagerProtocolBase>

- (void)methodC;

@end

@protocol ATProtocolManagerProtocolD <ATProtocolManagerProtocolBase>

- (void)methodD;

@end

@interface ATProtocolManagerClassA : NSObject<ATProtocolManagerProtocolA>

@end

@interface ATProtocolManagerClassB : NSObject<ATProtocolManagerProtocolB>

@end

@interface ATProtocolManagerClassC : NSObject<ATProtocolManagerProtocolC>

@end

@interface ATProtocolManagerClassD : NSObject<ATProtocolManagerProtocolD>

@end

#define ATDEMO_GET_MODULE_PROTOCOL(atProtocol) \
    AT_GET_MODULE_PROTOCOL([ATProtocolManagerEx sharedObject].protocolManager, atProtocol)
#define ATDEMO_GET_MODULE_PROTOCOL_VARIABLE(atProtocol, atVariable) \
    AT_GET_MODULE_PROTOCOL_VARIABLE([ATProtocolManagerEx sharedObject].protocolManager, atProtocol, atVariable)

@interface ATProtocolManagerEx : NSObject

AT_DECLARE_SINGLETON;

@property (nonatomic, strong) ATProtocolManager *protocolManager;

@end

@interface ATProtocolManagerDemo : NSObject

- (void)demo;

@end

NS_ASSUME_NONNULL_END
