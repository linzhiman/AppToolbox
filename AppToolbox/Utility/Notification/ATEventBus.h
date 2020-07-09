//
//  ATEventBus.h
//  AppToolbox
//
//  Created by linzhiman on 2020/7/2.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATGlobalMacro.h"

/**
类型安全的事件总线
- 假设需要定义一个名字为kName的事件，具有2个参数，第一个参数类型int，第二个参数类型为NSString*
- 头文件添加申明
        AT_EB_DECLARE(kName, int, a, NSString *, b)
- 实现文件添加定义
        AT_EB_DEFINE(kName, int, a, NSString *, b)
- 订阅事件
        [AT_EB_EVENT(kName).observer(self) reg:^(ATEBEvent<ATEB_DATA_kName *> * _Nonnull event) {}];
- 取消订阅
        AT_EB_EVENT(kName).observer(self).unReg();
- 取消所有订阅，注意不会取消强力订阅，一般不需要调用，内部弱引用observer
        [[ATEventBus sharedObject] unRegAllEvent:self];
- 强力订阅和取消
        self.eventToken = [AT_EB_EVENT(kName).observer(self) forceReg:^(ATEBEvent<ATEB_DATA_kName *> * _Nonnull event) {}];
        [self.eventToken dispose];
- 触发事件
        [AT_EB_BUS(kName) post_a:123 b:@"abc"];
 
兼容NSNotification：
- 声明系统事件
        AT_EXTERN_NOTIFICATION(kSysName);
- 定义系统事件
        AT_DECLARE_NOTIFICATION(kSysName);
- 订阅事件
        [AT_EB_EVENT_SYS(kSysName).observer(self) reg:^(ATEBEvent<NSDictionary *> * _Nonnull event) {}];
- 取消订阅
        AT_EB_EVENT_SYS(kSysName).observer(self).unReg();
 - 取消所有订阅，注意不会取消强力订阅，一般不需要调用，内部弱引用observer
        [[ATEventBus sharedObject] unRegAllEvent:self];
- 强力订阅和取消
        self.eventToken = [AT_EB_EVENT_SYS(kSysName).observer(self) forceReg:^(ATEBEvent<NSDictionary *> * _Nonnull event) {}];
        [self.eventToken dispose];
- 触发事件
        [AT_EB_BUS_SYS(kSysName) post_data:@{}];
 */

NS_ASSUME_NONNULL_BEGIN

#define AT_EB_NAME_PREFIX @"ATEB_"
#define AT_EB_DATA_TYPE(atName) metamacro_concat(ATEB_DATA_, atName)

/// 声明自定义事件
/// AT_EB_DECLARE(kName, int, a);
#define AT_EB_DECLARE(atName, ...) \
    AT_STRING_EXTERN(atName); \
    @class AT_EB_DATA_TYPE(atName); \
    AT_EB_DECLARE_INTERFACE(atName, AT_PROPERTY_DECLARE(__VA_ARGS__), __VA_ARGS__) \

#define AT_EB_DECLARE_INTERFACE(atName, atPropertys, ...) \
    @interface AT_EB_DATA_TYPE(atName) : NSObject \
    atPropertys \
    + (void)metamacro_concat(post##_, AT_SELECTOR_ARGS(__VA_ARGS__)); \
    @end \

/// 定义自定义事件
/// AT_EB_DEFINE(kName, int, a);
#define AT_EB_DEFINE(atName, ...) \
    AT_STRING_DEFINE_VALUE(atName, AT_EB_NAME_PREFIX#atName); \
    AT_EB_DEFINE_IMPLEMENTATION(atName, __VA_ARGS__) \
    { \
        AT_EB_DATA_TYPE(atName) *obj = [AT_EB_DATA_TYPE(atName) new]; \
        AT_PROPERTY_SET_VALUE(__VA_ARGS__) \
        ATEBEvent *event = [ATEBEvent eventWithName:atName]; \
        [event post_data:obj]; \
    } \
    @end \

#define AT_EB_DEFINE_IMPLEMENTATION(atName, ...) \
    @implementation AT_EB_DATA_TYPE(atName) \
    + (void)metamacro_concat(post##_, AT_SELECTOR_ARGS(__VA_ARGS__))

/// 订阅/取消订阅自定义事件
/// [AT_EB_EVENT(kName).observer(self) reg:^(ATEBEvent<ATEB_DATA_kName *> * _Nonnull event) {}];
/// AT_EB_EVENT(kName).observer(self).unReg();
#define AT_EB_EVENT(atName) \
    [ATEBObserverBuilder<AT_EB_DATA_TYPE(atName) *> builderWithEvent:[ATEBEvent eventWithName:atName]]

/// 触发自定义事件
/// [AT_EB_BUS(kName) post_a:0];
#define AT_EB_BUS(atName) \
    AT_EB_DATA_TYPE(atName)

/// 兼容NSNotification：

/// 声明系统事件
/// AT_EXTERN_NOTIFICATION(kSysName);

/// 定义系统事件
/// AT_DECLARE_NOTIFICATION(kSysName);

/// 订阅/取消订阅系统事件
/// [AT_EB_EVENT_SYS(kSysName).observer(self) reg:^(ATEBEvent<NSDictionary *> * _Nonnull event) {}];
/// AT_EB_EVENT_SYS(kSysName).observer(self).unReg();
#define AT_EB_EVENT_SYS(atName) \
    [ATEBObserverBuilder<NSDictionary *> builderWithEvent:[ATEBEvent eventWithName:atName]]

/// 触发系统事件
/// [AT_EB_BUS_SYS(kSysName) post_data:@{}];
#define AT_EB_BUS_SYS(atName) \
    [ATEBEvent<NSDictionary *> eventWithName:atName]

/// 取消所有订阅，一般不需要使用，内部弱引用observer
/// [[ATEventBus sharedObject] unRegAllEvent:self];

@protocol IATEBEvent <NSObject>

- (NSString *)eventId;
- (BOOL)sysEvent;
- (id)data;

@end

@protocol IATEBEventToken <NSObject>

- (void)dispose;

@end

@interface ATEBEvent<T> : NSObject<IATEBEvent>

+ (instancetype)eventWithName:(NSString *)name;
+ (instancetype)eventWithName:(NSString *)name data:(nullable T)data;

@property (nonatomic, strong, readonly) T data;

- (void)post_data:(T)data;

@end

/// 订阅/取消订阅参数构造器，支持点语法，链式调用
@interface ATEBObserverBuilder<T> : NSObject

typedef void (^ATEBObserverBuilderBlock)(ATEBEvent<T> *event);

@property (nonatomic, copy, readonly) ATEBObserverBuilder<T> *(^observer)(id);
@property (nonatomic, copy, readonly) ATEBObserverBuilder<T> *(^atQueue)(dispatch_queue_t); // 暂不支持
@property (nonatomic, copy, readonly) void (^unReg)(void);

/// 订阅，重复订阅会触发断言
- (void)reg:(ATEBObserverBuilderBlock)action; // 按上面的方式T不会替换为实际类型，怎么支持点语法呢？

/// 强力订阅，可重复订阅，解决父子类同时订阅的问题
- (id<IATEBEventToken>)forceReg:(ATEBObserverBuilderBlock)action; // 同上

+ (ATEBObserverBuilder<T> *)builderWithEvent:(id<IATEBEvent>)event;

@end

/// 事件总线
@interface ATEventBus : NSObject

AT_DECLARE_SINGLETON;

/// 取消所有订阅
- (void)unRegAllEvent:(id)observer;

@end

NS_ASSUME_NONNULL_END

