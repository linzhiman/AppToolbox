//
//  ATNotificationDemo.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATNotificationDemo.h"

AT_DECLARE_NOTIFICATION(kNotificationKey)
AT_DECLARE_NOTIFICATION(kNotification1)
AT_DECLARE_NOTIFICATION(kNotification2)
AT_DECLARE_NOTIFICATION(kNotification3)

AT_BN_DEFINE(kName)
AT_BN_DEFINE(kName1, int, a)
AT_BN_DEFINE(kName2, int, a, NSString *, b)
AT_BN_DEFINE(kName3, int, a, NSString *, b, id, c)
AT_BN_DEFINE(kName4, int, a, NSString *, b, id, c, id, d)
AT_BN_DEFINE(kName5, int, a, NSString *, b, id, c, id, d, id, e)
AT_BN_DEFINE(kName6, int, a, NSString *, b, id, c, id, d, id, e, id, f)
AT_BN_DEFINE(kName7, int, a, NSString *, b, id, c, id, d, id, e, id, f, id, g)
AT_BN_DEFINE(kName8, int, a, NSString *, b, id, c, id, d, id, e, id, f, id, g, id, h)

@implementation ATNotificationTest
@end

#ifdef UseObj
AT_BN_DEFINE(kName9, ATNotificationTest *, test);
#else
AT_BN_DEFINE_NO_OBJ(kName9, ATNotificationTest *, test);
#endif

@implementation ATNotificationDemo

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initNotification];
    }
    return self;
}

- (void)dealloc
{
    [self removeNotification];
}

- (void)initNotification
{
    [self atbn_addNativeName:kNotification1 block:^(NSDictionary * _Nullable userInfo) {
        NSLog(@"kNotification1 %@", userInfo);
    }];
    [self atbn_addNativeName:kNotification2 block:^(NSDictionary * _Nullable userInfo) {
        NSLog(@"kNotification2 %@", userInfo);
    }];
    
    [AT_BN_ADD_OBSERVER_NAMED(kName) block:^(ATBNkNameObj * _Nonnull obj) {
        NSLog(@"kName");
    }];
    [AT_BN_ADD_OBSERVER_NAMED(kName3) block:^(ATBNkName3Obj * _Nonnull obj) {
        NSLog(@"kName3 %d %@ %@", obj.a, obj.b, obj.c);
    }];
    
#ifdef UseObj
    [AT_BN_ADD_OBSERVER_NAMED(kName9) block:^(ATBNkName9Obj * _Nonnull obj) {
        NSLog(@"kName9 %@", @(obj.test.test));
    }];
#else
    [AT_BN_ADD_OBSERVER_NAMED(kName9) block:^(ATNotificationTest * _Nonnull test) {
        NSLog(@"kName9 %@", @(test.test));
    }];
#endif
}

- (void)removeNotification
{
    [self atbn_removeNativeAll];
    [self atbn_removeNativeName:kNotification1];
    
    AT_BN_REMOVE_OBSERVER_NAMED(kName);
    AT_BN_REMOVE_OBSERVER;
}

- (void)demo
{
//    [self removeNotification];
    
    [self atbn_postNativeName:kNotification1 userInfo:@{kNotificationKey:@(1)}];
    [self atbn_postNativeName:kNotification2 userInfo:@{kNotificationKey:@(2)}];
    
    [AT_BN_OBJ_NAMED(kName) post_];
    [AT_BN_OBJ_NAMED(kName3) post_a:1 b:@"ok" c:@(0)];
    
    ATNotificationTest *test = [ATNotificationTest new];
    test.test = YES;
    [AT_BN_OBJ_NAMED(kName9) post_test:test];
}

@end


@interface ATNotificationDemo2 ()

@property (nonatomic, strong) id kNotification2Ob;
@property (nonatomic, strong) id kName3Ob;

@end

@implementation ATNotificationDemo2

- (void)demo2_initNotification
{
    [self atbn_addNativeName:kNotification3 block:^(NSDictionary * _Nullable userInfo) {
        NSLog(@"demo2 kNotification3 %@", userInfo);
    }];
// 分类也订阅了kNotification2，子类再次订阅会触发断言，改为force方式
//    [self atbn_addNativeName:kNotification2 block:^(NSDictionary * _Nullable userInfo) {
//        NSLog(@"demo2 kNotification2 %@", userInfo);
//    }];
    self.kNotification2Ob = [self atbn_forceAddNativeName:kNotification2 block:^(NSDictionary * _Nullable userInfo) {
        NSLog(@"demo2 kNotification2 %@", userInfo);
    }];
    
    [AT_BN_ADD_OBSERVER_NAMED(kName5) block:^(ATBNkName5Obj * _Nonnull obj) {
        NSLog(@"demo2 kName5");
    }];
// 分类也订阅了kName3，子类再次订阅会触发断言，改为force方式
//    [AT_BN_ADD_OBSERVER_NAMED(kName3) block:^(ATBNkName3Obj * _Nonnull obj) {
//        NSLog(@"demo2 kName3");
//    }];
    self.kName3Ob = [AT_BN_ADD_OBSERVER_NAMED(kName3) forceBlock:^(ATBNkName3Obj * _Nonnull obj) {
        NSLog(@"demo2 kName3");
    }];
}

- (void)demo2_removeNotification
{
    [self atbn_removeNativeAll];
    [self atbn_removeNativeName:kNotification1];
    [self atbn_removeNativeForce:self.kNotification2Ob];
    
    AT_BN_REMOVE_OBSERVER_NAMED(kName);
    AT_BN_REMOVE_OBSERVER;
    AT_BN_REMOVE_FORCE_OBSERVER(self.kName3Ob);
}

- (void)demo
{
//    [super demo];
    
    [self demo2_initNotification];
    
    [self atbn_postNativeName:kNotification1 userInfo:@{kNotificationKey:@(1)}];
    [self atbn_postNativeName:kNotification2 userInfo:@{kNotificationKey:@(2)}];
    
    [AT_BN_OBJ_NAMED(kName) post_];
    [AT_BN_OBJ_NAMED(kName3) post_a:1 b:@"ok" c:@(0)];
    
    [self demo2_removeNotification];
    
    [self atbn_postNativeName:kNotification1 userInfo:@{kNotificationKey:@(1)}];
    [self atbn_postNativeName:kNotification2 userInfo:@{kNotificationKey:@(2)}];
    
    [AT_BN_OBJ_NAMED(kName) post_];
    [AT_BN_OBJ_NAMED(kName3) post_a:1 b:@"ok" c:@(0)];
}

@end
