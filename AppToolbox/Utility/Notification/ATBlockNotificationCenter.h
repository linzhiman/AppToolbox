//
//  ATBlockNotificationCenter.h
//  AppToolbox
//
//  Created by linzhiman on 2019/8/22.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATGlobalMacro.h"

// 通知中心
// 使用block订阅系统通知及自定义通知，类型安全

// 支持两个类型的定义，一般用第一种
// 其一，将所有回调参数打包成一个obj，使用方直接访问obj的属性来访问对应参数
// 其二，不会打包obj，所有参数原样作为block参数列表，一般用于自定义obj类型
// 最大支持8个参数，如需调整，修改ATGlobalMacro.h

// 同一个对象重复订阅同一个通知，会触发断言(如父子类同时订阅)
// 如必须添加请调用forceBlock接口，保留返回值cbObj，取消这个通知时调用下面方法
// AT_BN_REMOVE_FORCE_OBSERVER(cbObj);

NS_ASSUME_NONNULL_BEGIN

#define AT_BN_CENTER [ATBlockNotificationCenter sharedObject]

#define AT_BN_ADD_OBSERVER_NAMED(atName) [ATBN##atName##Obj fromObserver:self]

#define AT_BN_REMOVE_OBSERVER_NAMED(atName) [self atbn_removeName:atName];

#define AT_BN_REMOVE_OBSERVER [self atbn_removeALL];

#define AT_BN_REMOVE_FORCE_OBSERVER(atIns) [self atbn_removeForce:atIns];

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

// 头文件添加申明（AT_BN_DECLARE or AT_BN_DECLARE_NO_OBJ）

// AT_BN_DECLARE(kName, int, a, NSString *, b)
// Block类型为^(ATBNkNameObj * _Nonnull obj) {}
// 参数支持内置类型添加到obj属性，自定义类型需定义HANDLER宏，否则编译失败
// 编译失败提示：Unknown type name 'AT_PROPERTY_DECLARE_HANDLER_xxx'
// HANDLER宏：#define AT_PROPERTY_DECLARE_HANDLER_xxx AT_PROPERTY_DECLARE_STRONG xxx
// 通用系统类型在ATGlobalMacro.h添加，自定义类型在app工程中添加，建议添加一个公用文件并加入预编译便于使用
#define AT_BN_DECLARE(atName, ...) \
    @class ATBN##atName##Obj; \
    typedef void(^AT_BN_BLOCK_TYPE(atName))(ATBN##atName##Obj *obj); \
    AT_BN_DECLARE_BASE(atName, AT_PROPERTY_DECLARE(__VA_ARGS__), __VA_ARGS__)

// AT_BN_DECLARE_NO_OBJ(kName, int, a, NSString *, b)
// Block类型为^(int a, NSString * b) {}
// 参数支持所有类型，参数列表改动将导致所有订阅代码需要改动，一般用于自定义obj类型
#define AT_BN_DECLARE_NO_OBJ(atName, ...) \
    typedef void(^AT_BN_BLOCK_TYPE(atName))(AT_PAIR_CONCAT_ARGS(__VA_ARGS__)); \
    AT_BN_DECLARE_BASE(atName, , __VA_ARGS__)

// 实现文件添加定义（AT_BN_DEFINE or AT_BN_DEFINE_NO_OBJ）

// AT_BN_DEFINE(kName, int, a, NSString *, b)
#define AT_BN_DEFINE(atName, ...) \
    AT_BN_DEFINE_BASE(atName, __VA_ARGS__) \
    { \
        ATBN##atName##Obj *obj = [ATBN##atName##Obj new]; \
        AT_PROPERTY_SET_VALUE(__VA_ARGS__) \
        AT_BN_DEFINE_CALL_BLOCK(atName, obj) \
    } \
    @end \
    

// AT_BN_DEFINE_NO_OBJ(kName, int, a, NSString *, b)
#define AT_BN_DEFINE_NO_OBJ(atName, ...) \
    AT_BN_DEFINE_BASE(atName, __VA_ARGS__) \
    { \
        AT_BN_DEFINE_CALL_BLOCK(atName, AT_EVEN_ARGS(__VA_ARGS__)) \
    } \
    @end

// 订阅
// [AT_BN_ADD_OBSERVER_NAMED(kName) block:^(ATBNkNameObj * _Nonnull obj) {}];
// [AT_BN_ADD_OBSERVER_NAMED(kName) block:^(int a, NSString *b) {}];

// 取消订阅
// AT_BN_REMOVE_OBSERVER_NAMED(kName);

// 取消所有订阅，注意不会取消force的订阅
// AT_BN_REMOVE_OBSERVER;

// 强制订阅和取消
// self.cbObj = [AT_BN_ADD_OBSERVER_NAMED(kName) forceBlock:^(ATBNkNameObj * _Nonnull obj) {}];
// AT_BN_REMOVE_FORCE_OBSERVER(self.cbObj);

// 发送通知
// [AT_BN_OBJ_NAMED(kName) post_];
// [AT_BN_OBJ_NAMED(kName) post_a:123 b:@"abc"];

typedef void (^ATBNNativeBlock)(NSDictionary * _Nullable userInfo);

@interface ATBlockNotificationCenter : NSObject

AT_DECLARE_SINGLETON;

// 建议使用上面描述的方式调用

- (void)addObserver:(id)observer name:(NSString *)name block:(id)block;

// 必须持有返回值cbObj，取消订阅时调用@selector(removeObserver:)，参数为返回值cbObj
- (id)forceAddObserver:(id)observer name:(NSString *)name block:(id)block;

- (void)removeObserver:(id)observer name:(NSString *)name;
- (void)removeObserver:(id)observer;

- (NSArray *)blocksNamed:(NSString *)name;

#pragma mark - Native Notification

// 建议使用NSObject (ATBN)中的方法调用

- (void)addNativeObserver:(id)observer name:(NSString *)name block:(ATBNNativeBlock)block;

// 必须持有返回值id，取消订阅时调用@selector(removeNativeObserver:)，参数为返回值id
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
