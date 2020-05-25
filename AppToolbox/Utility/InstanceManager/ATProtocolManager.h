//
//  ATProtocolManager.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 基于协议的模块管理类
 通过protocol标识对象，支持懒加载、分组，线程安全。
*/

#define AT_GET_INSTANCE_PROTOCOL(atManager, atProtocol) \
    ((id<atProtocol>)[atManager instance:@protocol(atProtocol)])

#define AT_GET_INSTANCE_PROTOCOL_VARIABLE(atManager, atProtocol, atVariable) \
    id<atProtocol> atVariable = (id<atProtocol>)[atManager instance:@protocol(atProtocol)];

NS_ASSUME_NONNULL_BEGIN

extern const NSInteger kATProtocolManagerDefaultGroup;
extern const NSInteger kATProtocolManagerGroup1;
extern const NSInteger kATProtocolManagerGroup2;

@interface ATProtocolManager : NSObject

/**
 在默认组添加实例，添加到instance表
 */
- (BOOL)addInstance:(id)instance protocol:(Protocol *)protocol;

/**
 在指定组添加实例，添加到instance表
 */
- (BOOL)addInstance:(id)instance protocol:(Protocol *)protocol group:(NSInteger)group;

/**
 在默认组注册实例类名，添加到class表
 */
- (BOOL)registerClass:(Class)aClass protocol:(Protocol *)protocol;

/**
 在指定组注册实例类名，添加到class表
 */
- (BOOL)registerClass:(Class)aClass protocol:(Protocol *)protocol group:(NSInteger)group;

/**
 获取实例
 先查instance表，再查class表，有则创建实例并调用@selector(addInstance:protocol:group:)
 */
- (id _Nullable)instance:(Protocol *)protocol;

/**
 移除instance及反注册class
 */
- (BOOL)removeInstance:(Protocol *)protocol;

/**
 获取默认组的所有实例
 */
- (NSArray *)instancesInDefaultGroup;

/**
 获取指定组的所有实例
 */
- (NSArray *)instancesInGroup:(NSInteger)group;

@end

NS_ASSUME_NONNULL_END
