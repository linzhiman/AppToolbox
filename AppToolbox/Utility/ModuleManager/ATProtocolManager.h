//
//  ATProtocolManager.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

// 基于协议的模块管理
// 通过protocol标识模块，支持懒加载，支持分组，线程安全

#define AT_GET_MODULE_PROTOCOL(atManager, atProtocol) \
    ((id<atProtocol>)[atManager module:@protocol(atProtocol)])

#define AT_GET_MODULE_PROTOCOL_VARIABLE(atManager, atProtocol, atVariable) \
    id<atProtocol> atVariable = (id<atProtocol>)[atManager module:@protocol(atProtocol)];

NS_ASSUME_NONNULL_BEGIN

extern const NSInteger kATProtocolManagerDefaultGroup;
extern const NSInteger kATProtocolManagerGroup1;
extern const NSInteger kATProtocolManagerGroup2;

@interface ATProtocolManager : NSObject

- (id)moduleForProtocol:(Protocol *)protocol;

- (void)addModule:(id)module protocol:(Protocol *)protocol;
- (void)addModule:(id)module protocol:(Protocol *)protocol group:(NSInteger)group;

- (void)removeModule:(Protocol *)protocol;

- (Class)classForProtocol:(Protocol *)procotol;

- (void)registerClass:(Class)aClass protocol:(Protocol *)protocol;
- (void)registerClass:(Class)aClass protocol:(Protocol *)protocol group:(NSInteger)group;

- (void)unRegisterClass:(Protocol *)protocol;

/**
 先查module表，再查class表，有则创建对象并addModule添加到module表
 */
- (id)module:(Protocol *)protocol;

/**
 移除module及class
 */
- (void)removeProtocol:(Protocol *)protocol;

- (NSArray *)modulesInGroup:(NSInteger)group createIfNeed:(BOOL)createIfNeed;

@end

NS_ASSUME_NONNULL_END
