//
//  ATComponentService.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATComponentService.h"

AT_STRING_DEFINE_VALUE(kATComponentServiceCode, @"ATCSCode")
AT_STRING_DEFINE_VALUE(kATComponentServiceMsg, @"ATCSMsg")

@interface ATComponentServiceInner : NSObject

AT_DECLARE_SINGLETON;

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMapTable<NSString *, id> *componentMap;
@property (nonatomic, strong) NSMapTable<NSString *, Class> *componentClassMap;

- (BOOL)registerTarget:(NSString *)name aClass:(Class)aClass;
- (BOOL)unRegisterTarget:(NSString *)name aClass:(Class)aClass;
- (id)componentNamed:(NSString *)name;

@end

@implementation ATComponentServiceInner

AT_IMPLEMENT_SINGLETON(ATComponentServiceInner);

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _componentMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        _componentClassMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return self;
}

- (BOOL)registerTarget:(NSString *)name aClass:(Class)aClass
{
    ATComponentLaunchType launchType = ATComponentLaunchTypeOnCall;
    if ([aClass respondsToSelector:@selector(launchType)]) {
        launchType = [aClass launchType];
    }
    
    BOOL res = NO;
    
    [self.lock lock];
    if ([self.componentMap objectForKey:name] == nil && [self.componentClassMap objectForKey:name] == nil) {
        if (launchType == ATComponentLaunchTypeOnRegister) {
            [self.componentMap setObject:[[aClass alloc] init] forKey:name];
        }
        else {
            [self.componentClassMap setObject:aClass forKey:name];
        }
        res = YES;
    }
    [self.lock unlock];
    
    return res;
}

- (BOOL)unRegisterTarget:(NSString *)name aClass:(Class)aClass
{
    BOOL res = NO;
    
    [self.lock lock];
    id oldObject = [self.componentMap objectForKey:name];
    if (oldObject != nil && [oldObject isKindOfClass:aClass]) {
        [self.componentMap removeObjectForKey:name];
        res = YES;
    }
    Class oldClass = [self.componentClassMap objectForKey:name];
    if (oldClass != NULL && oldClass == aClass) {
        [self.componentClassMap removeObjectForKey:name];
        res = YES;
    }
    [self.lock unlock];
    
    return res;
}

- (id)componentNamed:(NSString *)name
{
    id res = nil;
    
    [self.lock lock];
    id anObject = [self.componentMap objectForKey:name];
    if (anObject != nil) {
        res = anObject;
    }
    else {
        Class aClass = [self.componentClassMap objectForKey:name];
        anObject = [[aClass alloc] init];
        [self.componentMap setObject:anObject forKey:name];
        res = anObject;
    }
    [self.lock unlock];
    
    return res;
}

@end

@implementation ATComponentService

+ (BOOL)registerTarget:(NSString *)name aClass:(Class)aClass
{
    return [[ATComponentServiceInner sharedObject] registerTarget:name aClass:aClass];
}

+ (BOOL)unRegisterTarget:(NSString *)name aClass:(Class)aClass
{
    return [[ATComponentServiceInner sharedObject] unRegisterTarget:name aClass:aClass];
}

+ (NSDictionary *)callTarget:(NSString *)name action:(NSString *)action params:(NSDictionary * _Nullable)params
{
    return [self callTarget:name action:action params:params callback:nil];
}

+ (NSDictionary *)callTarget:(NSString *)name action:(NSString *)action params:(NSDictionary * _Nullable)params
                    callback:(ATComponentCallback _Nullable)callback
{
    NSDictionary *aDictionary = nil;
    
    if (name.length == 0 || action.length == 0) {
        aDictionary = [NSDictionary atcs_dicWithCode:ATComponentServiceCodeArgErr msg:@"Argument error"];
    }
    else {
        id anObject = [[ATComponentServiceInner sharedObject] componentNamed:name];
        if (anObject == nil) {
            aDictionary = [NSDictionary atcs_dicWithCode:ATComponentServiceCodeNoTarget msg:[NSString stringWithFormat:@"No target named %@", name]];
        }
        else {
            NSString *actionString = [NSString stringWithFormat:@"%@:callback:", action];
            SEL selector = NSSelectorFromString(actionString);
            
            if ([anObject respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                id value = [anObject performSelector:selector withObject:params withObject:callback];
#pragma clang diagnostic pop
                if (value == nil || ![value isKindOfClass:[NSDictionary class]]) {
                    aDictionary = [NSDictionary atcs_dicWithCode:ATComponentServiceCodeResultError msg:[NSString stringWithFormat:@"Result error action %@ in %@", action, name]];
                }
                else {
                    aDictionary = value;
                }
            }
            else {
                aDictionary = [NSDictionary atcs_dicWithCode:ATComponentServiceCodeNoAction msg:[NSString stringWithFormat:@"Unsupported action %@ in %@", action, name]];
            }
        }
    }
    
    return aDictionary;
}

+ (NSDictionary *)callTargetUrl:(NSURL *)url
{
    return [ATComponentService callTargetUrl:url callback:nil];
}

+ (NSDictionary *)callTargetUrl:(NSURL *)url callback:(ATComponentCallback _Nullable)callback
{
    NSString *target = [ATComponentService nameFromUrl:url];
    NSString *action = [ATComponentService actionFromUrl:url];
    NSDictionary *params = [ATComponentService paramsFromUrl:url];
    
    return [ATComponentService callTarget:target action:action params:params callback:callback];
}

+ (NSString *)nameFromUrl:(NSURL *)url
{
    return url.host;
}

+ (NSString *)actionFromUrl:(NSURL *)url
{
    return [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
}

+ (NSDictionary *)paramsFromUrl:(NSURL *)url
{
    NSMutableDictionary *argument = [[NSMutableDictionary alloc] init];
    NSString *urlString = [url query];
    for (NSString *param in [urlString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if (elts.count < 2) {
            continue;
        }
        [argument setObject:[elts lastObject] forKey:[elts firstObject]];
    }
    return [NSDictionary dictionaryWithDictionary:argument];
}

@end


@implementation NSDictionary(ATComponentService)

- (BOOL)atcs_success
{
    return self.atcs_code == 0;
}

- (BOOL)atcs_error
{
    return self.atcs_code != 0;
}

- (NSInteger)atcs_code
{
    id value = self[kATComponentServiceCode];
    if (value != nil && [value isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)value).integerValue;
    }
    return -1;
}

- (NSString *)atcs_msg
{
    return self[kATComponentServiceMsg];
}

+ (instancetype)atcs_resultDic
{
    return [NSDictionary atcs_dicWithCode:ATComponentServiceCodeOK msg:nil];
}

+ (instancetype)atcs_dicWithCode:(NSInteger)code msg:(NSString * _Nullable)msg
{
    return @{ kATComponentServiceCode : @(code),
              kATComponentServiceMsg : msg ?: @""
              };
}

@end


@implementation NSMutableDictionary(ATComponentService)

+ (instancetype)atcs_resultDic
{
    return [[NSDictionary atcs_resultDic] mutableCopy];
}

@end
