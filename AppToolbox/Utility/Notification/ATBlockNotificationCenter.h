//
//  ATBlockNotificationCenter.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATGlobalMacro.h"

/**
 类型安全的基于Block的通知中心
 1.自定义通知
    i.说明
        - 支持两个方式的定义，一般用第一种
            (1)将所有回调参数打包成一个obj，使用方直接访问obj的属性来访问对应参数
            (2)不会打包obj，所有参数原样作为block参数列表，一般用于自定义obj类型
        - 最大支持8个参数，如需调整，修改ATGlobalMacro.h
        - 同一个对象重复订阅同一个通知，会触发断言(如父子类同时订阅)，需改用forceBlock接口
    ii.使用举例
        - 假设需要定义一个名字为kName的通知，具有2个参数，第一个参数类型int，第二个参数类型为NSString*
        - 头文件添加申明
            - AT_BN_DECLARE(kName, int, a, NSString *, b)
            - AT_BN_DECLARE_NO_OBJ(kName, int, a, NSString *, b)
        - 实现文件添加定义
            - AT_BN_DEFINE(kName, int, a, NSString *, b)
            - AT_BN_DEFINE_NO_OBJ(kName, int, a, NSString *, b)
        - 订阅通知
            - [AT_BN_ADD_OBSERVER_NAMED(kName) block:^(ATBNkNameObj * _Nonnull obj) {}];
            - [AT_BN_ADD_OBSERVER_NAMED(kName) block:^(int a, NSString *b) {}];
        - 取消订阅
            - AT_BN_REMOVE_OBSERVER_NAMED(kName);
        - 取消所有订阅，注意不会取消force的订阅
            - AT_BN_REMOVE_OBSERVER;
        - 强制订阅和取消
            - self.cbObj = [AT_BN_ADD_OBSERVER_NAMED(kName) forceBlock:^(ATBNkNameObj * _Nonnull obj) {}];
            - self.cbObj = [AT_BN_ADD_OBSERVER_NAMED(kName) forceBlock:^(int a, NSString *b) {}];
            - AT_BN_REMOVE_FORCE_OBSERVER(self.cbObj);
        - 发送通知
            - [AT_BN_OBJ_NAMED(kName) post_a:123 b:@"abc"];
 2.系统通知
    i.提供便利接口，实现订阅、取消订阅、发送消息
        - (void)atbn_addNativeName:(NSString *)name block:(ATBNNativeBlock)block;
        - (id)atbn_forceAddNativeName:(NSString *)name block:(ATBNNativeBlock)block;

        - (void)atbn_removeNativeName:(NSString *)name;
        - (void)atbn_removeNativeAll;
        - (void)atbn_removeNativeForce:(id)cbObj;

        - (void)atbn_postNativeName:(NSString *)name;
        - (void)atbn_postNativeName:(NSString *)name userInfo:(NSDictionary *)userInfo;
 */


NS_ASSUME_NONNULL_BEGIN

/// AT_BN_CENTER 单例
#define AT_BN_CENTER [ATBlockNotificationCenter sharedObject]

/// AT_BN_ADD_OBSERVER_NAMED 订阅通知，注意引用了self
#define AT_BN_ADD_OBSERVER_NAMED(atName) [ATBN##atName##Obj fromObserver:self]

/// AT_BN_ADD_OBSERVER_NAMED 取消订阅，注意引用了self
#define AT_BN_REMOVE_OBSERVER_NAMED(atName) [self atbn_removeName:atName];

/// AT_BN_REMOVE_OBSERVER 取消所有订阅，注意不会取消force的订阅，注意引用了self
#define AT_BN_REMOVE_OBSERVER [self atbn_removeALL];

/// AT_BN_REMOVE_FORCE_OBSERVER 取消force的订阅
#define AT_BN_REMOVE_FORCE_OBSERVER(atIns) [self atbn_removeForce:atIns];

/// AT_BN_OBJ_NAMED 发送通知
#define AT_BN_OBJ_NAMED(atName) ATBN##atName##Obj

#define AT_BN_BLOCK_TYPE(atName) metamacro_concat(ATBN_, atName)

#define AT_BN_DECLARE_BASE(atName, atPropertys, ...) \
    extern NSString * const atName; \
    @interface ATBN##atName##Obj : NSObject \
    atPropertys \
    @property (nonatomic, strong) id observer; \
    + (ATBN##atName##Obj *)fromObserver:(id)observer; \
    + (void)metamacro_concat(post##_, AT_SELECTOR_ARGS(__VA_ARGS__)); \
    - (void)block:(AT_BN_BLOCK_TYPE(atName))block; \
    - (id)forceBlock:(AT_BN_BLOCK_TYPE(atName))block; \
    @end \

#define AT_BN_DEFINE_BASE(atName, ...) \
    NSString * const atName = @"ATBN_"#atName; \
    @implementation ATBN##atName##Obj \
    + (ATBN##atName##Obj *)fromObserver:(id)observer { \
        ATBN##atName##Obj *tmp = [ATBN##atName##Obj new];tmp.observer = observer;return tmp; \
    } \
    - (void)block:(AT_BN_BLOCK_TYPE(atName))block { \
        [AT_BN_CENTER addObserver:self.observer name:atName block:block]; \
    } \
    - (id)forceBlock:(AT_BN_BLOCK_TYPE(atName))block { \
        return [AT_BN_CENTER forceAddObserver:self.observer name:atName block:block]; \
    } \
    + (void)metamacro_concat(post##_, AT_SELECTOR_ARGS(__VA_ARGS__))

#define AT_BN_DEFINE_CALL_BLOCK(atName, atArg) \
    NSArray *blocksNamed = [AT_BN_CENTER blocksNamed:atName]; \
    if ([NSThread isMainThread]) { \
        for (id block in blocksNamed) { \
            ((AT_BN_BLOCK_TYPE(atName))block)(atArg); \
        } \
    } \
    else { \
        dispatch_async(dispatch_get_main_queue(), ^{ \
            for (id block in blocksNamed) { \
                ((AT_BN_BLOCK_TYPE(atName))block)(atArg); \
            } \
        }); \
    }

/// 头文件添加申明（AT_BN_DECLARE or AT_BN_DECLARE_NO_OBJ）

/// AT_BN_DECLARE(kName, int, a, NSString *, b)
/// Block类型为^(ATBNkNameObj * _Nonnull obj) {}
#define AT_BN_DECLARE(atName, ...) \
    @class ATBN##atName##Obj; \
    typedef void(^AT_BN_BLOCK_TYPE(atName))(ATBN##atName##Obj *obj); \
    AT_BN_DECLARE_BASE(atName, AT_PROPERTY_DECLARE(__VA_ARGS__), __VA_ARGS__)

/// AT_BN_DECLARE_NO_OBJ(kName, int, a, NSString *, b)
/// Block类型为^(int a, NSString * b) {}
#define AT_BN_DECLARE_NO_OBJ(atName, ...) \
    typedef void(^AT_BN_BLOCK_TYPE(atName))(AT_PAIR_CONCAT_ARGS(__VA_ARGS__)); \
    AT_BN_DECLARE_BASE(atName, , __VA_ARGS__)

/// 实现文件添加定义（AT_BN_DEFINE or AT_BN_DEFINE_NO_OBJ）

/// AT_BN_DEFINE(kName, int, a, NSString *, b)
#define AT_BN_DEFINE(atName, ...) \
    AT_BN_DEFINE_BASE(atName, __VA_ARGS__) \
    { \
        ATBN##atName##Obj *obj = [ATBN##atName##Obj new]; \
        AT_PROPERTY_SET_VALUE(__VA_ARGS__) \
        AT_BN_DEFINE_CALL_BLOCK(atName, obj) \
    } \
    @end \
    

/// AT_BN_DEFINE_NO_OBJ(kName, int, a, NSString *, b)
#define AT_BN_DEFINE_NO_OBJ(atName, ...) \
    AT_BN_DEFINE_BASE(atName, __VA_ARGS__) \
    { \
        AT_BN_DEFINE_CALL_BLOCK(atName, AT_EVEN_ARGS(__VA_ARGS__)) \
    } \
    @end

typedef void (^ATBNNativeBlock)(NSDictionary * _Nullable userInfo);

@interface ATBlockNotificationCenter : NSObject

AT_DECLARE_SINGLETON;

/// 建议使用上面描述的方式调用

- (void)addObserver:(id)observer name:(NSString *)name block:(id)block;

/// 必须持有返回值cbObj，取消订阅时调用@selector(removeObserver:)，参数为返回值cbObj
- (id)forceAddObserver:(id)observer name:(NSString *)name block:(id)block;

- (void)removeObserver:(id)observer name:(NSString *)name;
- (void)removeObserver:(id)observer;

- (NSArray *)blocksNamed:(NSString *)name;

#pragma mark - Native Notification

/// 建议使用NSObject (ATBN)中的方法调用

- (void)addNativeObserver:(id)observer name:(NSString *)name block:(ATBNNativeBlock)block;

/// 必须持有返回值id，取消订阅时调用@selector(removeNativeObserver:)，参数为返回值id
- (id)forceAddNativeObserver:(id)observer name:(NSString *)name block:(ATBNNativeBlock)block;

- (void)removeNativeObserver:(id)observer name:(NSString *)name;
- (void)removeNativeObserver:(id)observer;

@end


@interface NSObject (ATBN)

- (void)atbn_removeALL;
- (void)atbn_removeName:(NSString *)name;
- (void)atbn_removeForce:(id)cbObj;

#pragma mark - Native Notification

- (void)atbn_addNativeName:(NSString *)name block:(ATBNNativeBlock)block;
- (id)atbn_forceAddNativeName:(NSString *)name block:(ATBNNativeBlock)block;

- (void)atbn_removeNativeName:(NSString *)name;
- (void)atbn_removeNativeAll;
- (void)atbn_removeNativeForce:(id)cbObj;

- (void)atbn_postNativeName:(NSString *)name;
- (void)atbn_postNativeName:(NSString *)name userInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
