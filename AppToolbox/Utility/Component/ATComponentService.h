//
//  ATComponentService.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATGlobalMacro.h"

/**
业务级组件化中间件
 1、定义组件的概念
 - 一般是指较大粒度的业务组件，高内聚低耦合，组件间相互调用关系相对简单。
 2、组件化目标
 - 业务拆分，组件独立编译。
 3、基本原理
 - 基于字符串的弱类型调用。ComponentName[NSString]定位组件，Command[NSString]指定方法，Argument[NSDictionary]指定参数，Callback[Block]指定回调方法。
 4、设计思路
 - 以组件名字唯一标识一个组件，组件管理器支持组件的接入及作为统一的调用入口，以Command+Argument+Callback的方式调用组件方法，组件通过其中的Callback回调调用方。
 - 为了避免字典参数的调用复杂度，由组件提供Category，以强类型方式包装弱类型接口，调用方使用Category即可。
 - 弱类型面向组件开发者，目标是解耦和容错。强类型面向组件使用者，方便调用且避免出错。
*/

NS_ASSUME_NONNULL_BEGIN

AT_STRING_EXTERN(kATComponentServiceCode);
AT_STRING_EXTERN(kATComponentServiceMsg);

/// 用于注册组件
#define AT_COMPONENT_REGISTER(atName, atClass) \
    [ATComponentService registerTarget:@#atName aClass:[atClass class]];

/// 用于提供组件方法
#define AT_COMPONENT_ACTION(atAction) \
    - (NSDictionary *)atAction:(NSDictionary *)params callback:(ATComponentCallback _Nullable)callback

typedef NS_ENUM(NSInteger, ATComponentServiceCode) {
    ATComponentServiceCodeUnknown = -1,
    ATComponentServiceCodeOK = 0,
    ATComponentServiceCodeArgErr = 1,
    ATComponentServiceCodeNoTarget = 2,
    ATComponentServiceCodeNoAction = 3,
    ATComponentServiceCodeResultError = 4
};

typedef void (^ATComponentCallback)(NSDictionary * _Nullable params);

typedef NS_ENUM(NSInteger, ATComponentLaunchType) {
    ATComponentLaunchTypeOnRegister, // 注册时立即创建对象
    ATComponentLaunchTypeOnCall      // 首次调用时创建对象
};

@protocol IATComponentLaunch <NSObject>

+ (ATComponentLaunchType)launchType;

@end

@interface ATComponentService : NSObject

/**
 注册组件
 目的是解耦类名，默认懒加载，可以实现IATComponentLaunch的launchType方法选择加载方式
 name不区分大小写
 */
+ (BOOL)registerTarget:(NSString *)name aClass:(Class)aClass;

/**
 反注册组件
*/
+ (BOOL)unRegisterTarget:(NSString *)name aClass:(Class)aClass;

/**
 调用组件方法
 内部以callback为nil调用@selector(callTarget:action:params:callback)
*/
+ (NSDictionary *)callTarget:(NSString *)name action:(NSString *)action params:(NSDictionary * _Nullable)params;

/**
 调用组件方法
 target即组件需响应@selector([action]:callback:)，使用AT_COMPONENT_ACTION宏定义方法
 方法签名如下：
    - (NSDictionary *)[action]:(NSDictionary *)params callback:(ATComponentCallback _Nullable)callback;
*/
+ (NSDictionary *)callTarget:(NSString *)name action:(NSString *)action params:(NSDictionary * _Nullable)params
                    callback:(ATComponentCallback _Nullable)callback;

/**
 以scheme方式调用组件方法
 内部以callback为nil调用@selector(callTargetUrl:callback)
*/
+ (NSDictionary *)callTargetUrl:(NSURL *)url;

/**
 以scheme方式调用组件方法
 内部解析url取出参数调用@selector(callTarget:action:params:callback)
 url格式如下：scheme://[name]/[action]?[params]
 scheme取值不限定
 */
+ (NSDictionary *)callTargetUrl:(NSURL *)url callback:(ATComponentCallback _Nullable)callback;

@end

@interface NSDictionary(ATComponentService)

- (BOOL)atcs_success;    // code == 0
- (BOOL)atcs_error;      // code != 0
- (NSInteger)atcs_code;
- (NSString *)atcs_msg;

+ (instancetype)atcs_resultDic;
+ (instancetype)atcs_resultDicWithCode:(NSInteger)code msg:(NSString * _Nullable)msg;

@end

@interface NSMutableDictionary(ATComponentService)

+ (instancetype)atcs_resultDic;

@end

NS_ASSUME_NONNULL_END
