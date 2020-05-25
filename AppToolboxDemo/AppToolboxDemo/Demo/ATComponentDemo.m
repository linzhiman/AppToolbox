//
//  ATComponentDemo.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATComponentDemo.h"

@implementation ATComponentA

AT_COMPONENT_ACTION(version)
{
    NSString *prefix = params[@"prefix"];
    NSString *version = [prefix stringByAppendingString:@"123"];
    NSMutableDictionary *dic = [NSMutableDictionary atcs_resultDic];
    [dic setObject:version forKey:@"version"];
    AT_SAFETY_CALL_BLOCK(callback, dic);
    return dic;
}

AT_COMPONENT_ACTION(fly)
{
    NSNumber *speed = params[@"speed"];
    NSMutableDictionary *dic = [NSMutableDictionary atcs_resultDic];
    [dic setObject:[NSString stringWithFormat:@"fly with speed %@", speed] forKey:@"flyResult"];
    AT_SAFETY_CALL_BLOCK(callback, dic);
    return dic;
}

@end

@implementation ATComponentService(ComponentA)

+ (NSString *)a_versionWithPrefix:(NSString *)prefix callback:(void(^)(NSString *version))callback
{
    NSDictionary *result = [ATComponentService callTarget:@"a" action:@"version" params:@{@"prefix":prefix} callback:^(NSDictionary * _Nullable params) {
        AT_SAFETY_CALL_BLOCK(callback, params[@"version"]);
    }];
    return result[@"version"];
}

+ (NSString *)a_flyWithSpeed:(NSNumber *)speed
{
    NSDictionary *result = [ATComponentService callTarget:@"a" action:@"fly" params:@{@"speed":speed} callback:^(NSDictionary * _Nullable params) {
        ;;
    }];
    return result[@"flyResult"];
}

@end

@interface ATComponentDemo()

@end

@implementation ATComponentDemo

- (void)demo
{
    AT_COMPONENT_REGISTER(A, ATComponentA);
    
    [ATComponentService a_versionWithPrefix:@"abc" callback:^(NSString * _Nonnull version) {
        NSLog(@"ATComponentDemo version %@", version);
    }];
    
    NSString *flyResult = [ATComponentService a_flyWithSpeed:@(99)];
    NSLog(@"ATComponentDemo flyResult %@", flyResult);
    
    NSDictionary *resultDic = [ATComponentService callTargetUrl:[NSURL URLWithString:@"abc://a/fly?speed=100"]];
    if (resultDic.atcs_success) {
        NSLog(@"ATComponentDemo flyResult %@", resultDic[@"flyResult"]);
    }
}

@end
