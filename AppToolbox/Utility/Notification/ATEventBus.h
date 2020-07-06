//
//  ATEventBus.h
//  AppToolbox
//
//  Created by linzhiman on 2020/7/2.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATGlobalMacro.h"

NS_ASSUME_NONNULL_BEGIN

/// 单例对象
#define AT_EVENT_BUS [ATEventBus sharedObject]

#define AT_EB_EVENT_TYPE(atName) metamacro_concat(ATEB_EVENT_, atName)
#define AT_EB_ACTION_TYPE(atName) metamacro_concat(ATEB_ACTION_, atName)

/// 声明自定义事件
/// AT_EB_DECLARE(kName, int, a);
#define AT_EB_DECLARE(atName, ...) \
    @class AT_EB_EVENT_TYPE(atName); \
    typedef void(^AT_EB_ACTION_TYPE(atName))(AT_EB_EVENT_TYPE(atName) *event); \
    AT_EB_DECLARE_INTERFACE(atName, AT_PROPERTY_DECLARE(__VA_ARGS__), __VA_ARGS__) \
    typedef AT_EB_EVENT_TYPE(atName) atName;

#define AT_EB_DECLARE_INTERFACE(atName, atPropertys, ...) \
    @interface AT_EB_EVENT_TYPE(atName) : ATEBUserEvent \
    atPropertys \
    + (void)metamacro_concat(post##_, AT_SELECTOR_ARGS(__VA_ARGS__)); \
    @end \

/// 定义自定义事件
/// AT_EB_DEFINE(kName, int, a);
#define AT_EB_DEFINE(atName, ...) \
    AT_EB_DEFINE_IMPLEMENTATION(atName, __VA_ARGS__) \
    { \
        AT_EB_EVENT_TYPE(atName) *obj = [AT_EB_EVENT_TYPE(atName) new]; \
        AT_PROPERTY_SET_VALUE(__VA_ARGS__) \
        [ATEventBusUserAdapter postEvent:obj]; \
    } \
    @end \

#define AT_EB_DEFINE_IMPLEMENTATION(atName, ...) \
    @implementation AT_EB_EVENT_TYPE(atName) \
    + (void)metamacro_concat(post##_, AT_SELECTOR_ARGS(__VA_ARGS__))

/// 订阅/取消订阅自定义事件
/// [AT_EB_USER_EVENT(kName).observer(self) reg:^(ATEB_EVENT_kName * _Nonnull event) {}];
/// AT_EB_USER_EVENT(kName).observer(self).unReg();
#define AT_EB_USER_EVENT(atName) \
    _AT_EB_USER_EVENT(AT_EB_EVENT_TYPE(atName))
#define _AT_EB_USER_EVENT(atClass) \
    [ATEBObserverBuilder<atClass *> builderWithEvent:[atClass new]]

/// 声明系统事件（NSNotification）
/// AT_EXTERN_NOTIFICATION(kSysName);

/// 定义系统事件（NSNotification）
/// AT_DECLARE_NOTIFICATION(kSysName);

/// 订阅/取消订阅系统事件（NSNotification）
/// [AT_EB_SYS_EVENT(kSysName).observer(self) reg:^(ATEBSysEvent * _Nonnull event) {}];
/// AT_EB_SYS_EVENT(kSysName).observer(self).unReg();
#define AT_EB_SYS_EVENT(atName) \
    _AT_EB_SYS_EVENT(atName)
#define _AT_EB_SYS_EVENT(atName) \
    [ATEBObserverBuilder<ATEBSysEvent *> builderWithEvent:[ATEBSysEvent eventWithName:atName]]

/// 取消所有订阅，一般不需要使用，内部弱引用observer
/// [AT_EVENT_BUS unRegAllEvent:self];

/// 触发自定义事件
/// [AT_EB_USER_BUS(kName) post_a:0];
#define AT_EB_USER_BUS(atName) \
    AT_EB_EVENT_TYPE(atName)

/// 触发系统事件
/// [AT_EB_SYS_BUS() post_name:kSysName userInfo:@{@"data":@(0)}];
#define AT_EB_SYS_BUS() \
    ATEventBusSysAdapter

@protocol IATEBEvent <NSObject>

- (NSString *)eventId;

@end

@protocol IATEBEventToken <NSObject>

- (void)dispose;

@end

/// 自定义事件
@interface ATEBUserEvent : NSObject<IATEBEvent>

@end

/// 系统事件（NSNotification）
@interface ATEBSysEvent : NSObject<IATEBEvent>

@property (nullable, nonatomic, strong, readonly) NSDictionary *userInfo;

+ (instancetype)eventWithName:(NSString *)name;
+ (instancetype)eventWithName:(NSString *)name userInfo:(nullable NSDictionary *)userInfo;

@end

/// 订阅/取消订阅参数构造器，支持点语法，链式调用
@interface ATEBObserverBuilder<T> : NSObject

typedef void (^ATEBObserverBuilderBlock)(T event);

@property (nonatomic, copy, readonly) ATEBObserverBuilder<T> *(^observer)(id);
@property (nonatomic, copy, readonly) ATEBObserverBuilder<T> *(^atQueue)(dispatch_queue_t); // 暂不支持
@property (nonatomic, copy, readonly) void (^unReg)(void);

/// 订阅，重复订阅会触发断言
- (void)reg:(ATEBObserverBuilderBlock)action; // 按上面的方式T不会替换为实际类型，怎么支持点语法呢？

/// 强力订阅，可重复订阅，解决父子类同时订阅的问题
- (id<IATEBEventToken>)forceReg:(ATEBObserverBuilderBlock)action; // 同上

+ (ATEBObserverBuilder<T> *)builderWithEvent:(id<IATEBEvent>)event;

@end

/// 触发自定义事件桥接器，内部使用，触发事件请使用AT_EB_USER_BUS
@interface ATEventBusUserAdapter : NSObject

+ (void)postEvent:(id<IATEBEvent>)event;

@end

/// 触发系统事件（NSNotification）桥接器，内部使用，触发事件请使用AT_EB_SYS_BUS
@interface ATEventBusSysAdapter : NSObject

+ (void)post_name:(NSString *)name userInfo:(nullable NSDictionary *)userInfo;

@end

/// 事件总线
@interface ATEventBus : NSObject

AT_DECLARE_SINGLETON;

/// 取消所有订阅
- (void)unRegAllEvent:(id)observer;

@end

NS_ASSUME_NONNULL_END

