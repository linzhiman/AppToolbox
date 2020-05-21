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

@end

@implementation ATComponentService(ComponentA)

+ (NSString *)a_versionWithPrefix:(NSString *)prefix callback:(void(^)(NSString *version))callback
{
    NSDictionary *result = [ATComponentService callTarget:@"A" action:@"version" params:@{@"prefix":prefix} callback:^(NSDictionary * _Nullable params) {
        AT_SAFETY_CALL_BLOCK(callback, params[@"version"]);
    }];
    return result[@"version"];
}

@end

@interface ATComponentDemo()

@end

@implementation ATComponentDemo

static NSString * _Nonnull extracted() {
    return [ATComponentService a_versionWithPrefix:@"abc" callback:^(NSString * _Nonnull version) {
        NSLog(@"ATComponentDemo callback %@", version);
    }];
}

- (void)demo
{
    AT_COMPONENT_REGISTER(A, ATComponentA);
    
    NSString *version = extracted();
    NSLog(@"ATComponentDemo retrun %@", version);
}

@end
