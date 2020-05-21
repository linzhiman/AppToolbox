//
//  ATComponentService.h
//  ATKit
//
//  Created by linzhiman on 2019/4/28.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATGlobalMacro.h"

NS_ASSUME_NONNULL_BEGIN

AT_STRING_EXTERN(kATComponentServiceCode);
AT_STRING_EXTERN(kATComponentServiceMsg);

#define AT_COMPONENT_REGISTER(atName, atClass) \
    [ATComponentService registerTarget:@#atName aClass:[atClass class]];

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
    ATComponentLaunchTypeOnRegister,
    ATComponentLaunchTypeOnCall
};

@protocol IATComponentLaunch <NSObject>

+ (ATComponentLaunchType)launchType;

@end

@interface ATComponentService : NSObject

/**
 要求注册的目的是解耦类名
 默认懒加载
 需要立即创建实例，实现IATComponentLaunch的launchType方法
 */
+ (BOOL)registerTarget:(NSString *)name aClass:(Class)aClass;
+ (BOOL)unRegisterTarget:(NSString *)name aClass:(Class)aClass;

/**
 target需要响应@selector([action]:callback:)
 - (NSDictionary *)[action]:(NSDictionary *)params callback:(ATComponentCallback _Nullable)callback;
 */

+ (NSDictionary *)callTarget:(NSString *)name action:(NSString *)action params:(NSDictionary * _Nullable)params;
+ (NSDictionary *)callTarget:(NSString *)name action:(NSString *)action params:(NSDictionary * _Nullable)params
                    callback:(ATComponentCallback _Nullable)callback;

/*
 scheme://[name]/[action]?[params]
 */
+ (NSDictionary *)callTargetUrl:(NSURL *)url;
+ (NSDictionary *)callTargetUrl:(NSURL *)url callback:(ATComponentCallback _Nullable)callback;

@end

@interface NSDictionary(ATComponentService)

- (BOOL)atcs_success;//code == 0
- (BOOL)atcs_error;//code != 0
- (NSInteger)atcs_code;
- (NSString *)atcs_msg;

+ (instancetype)atcs_resultDic;
+ (instancetype)atcs_dicWithCode:(NSInteger)code msg:(NSString * _Nullable)msg;

@end

@interface NSMutableDictionary(ATComponentService)

+ (instancetype)atcs_resultDic;

@end

NS_ASSUME_NONNULL_END
