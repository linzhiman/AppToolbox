//
//  ATEventBusDemo.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/7/2.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATEventBusDemo.h"
#import "ATEventBus.h"

AT_EB_DECLARE(kName, int, a);
AT_EB_DEFINE(kName, int, a);

AT_EB_DECLARE(kName2, int, b);
AT_EB_DEFINE(kName2, int, b);

AT_DECLARE_NOTIFICATION(kSysName);
AT_DECLARE_NOTIFICATION(kSysName2);

@interface ATEventBusTest : NSObject

- (void)regEvent;
- (void)unRegEvent;

@property (nonatomic, strong) id<IATEBEventToken> eventToken;
@property (nonatomic, strong) id<IATEBEventToken> eventToken2;

@end

@implementation ATEventBusTest

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"init %@", self);
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc %@", self);
}

- (void)regEvent
{
    [AT_EB_USER_EVENT(kName).observer(self) reg:^(ATEB_EVENT_kName * _Nonnull event) {
        NSLog(@"ATEventBusTest user event %@ %d", event.eventId, event.a);
    }];
    [AT_EB_USER_EVENT(kName2).observer(self) reg:^(ATEB_EVENT_kName2 * _Nonnull event) {
        NSLog(@"ATEventBusTest user event %@ %d", event.eventId, event.b);
    }];
    [AT_EB_SYS_EVENT(kSysName).observer(self) reg:^(ATEBSysEvent * _Nonnull event) {
        NSLog(@"ATEventBusTest sys event %@ %@", event.eventId, event.userInfo);
    }];
    [AT_EB_SYS_EVENT(kSysName2).observer(self) reg:^(ATEBSysEvent * _Nonnull event) {
        NSLog(@"ATEventBusTest sys event %@ %@", event.eventId, event.userInfo);
    }];

    self.eventToken = [AT_EB_USER_EVENT(kName).observer(self) forceReg:^(ATEB_EVENT_kName * _Nonnull event) {
        NSLog(@"ATEventBusTest user force event %@ %d", event.eventId, event.a);
    }];
    self.eventToken2 = [AT_EB_SYS_EVENT(kSysName).observer(self) forceReg:^(ATEBSysEvent * _Nonnull event) {
        NSLog(@"ATEventBusTest sys force event %@ %@", event.eventId, event.userInfo);
    }];
}

- (void)unRegEvent
{
    AT_EB_USER_EVENT(kName).observer(self).unReg();
    AT_EB_USER_EVENT(kName2).observer(self).unReg();
    AT_EB_SYS_EVENT(kSysName).observer(self).unReg();
    AT_EB_SYS_EVENT(kSysName2).observer(self).unReg();
    
    [self.eventToken dispose];
    [self.eventToken2 dispose];
}

@end

@implementation ATEventBusDemo

- (void)demo
{
    {{
        ATEventBusTest *test = [ATEventBusTest new];
        [test regEvent];

        [AT_EB_USER_BUS(kName) post_a:1];
        [AT_EB_USER_BUS(kName2) post_b:1];
        [AT_EB_SYS_BUS() post_name:kSysName userInfo:@{@"data":@(1)}];
        [AT_EB_SYS_BUS() post_name:kSysName2 userInfo:@{@"data":@(1)}];
    }}

    [AT_EB_USER_BUS(kName) post_a:2];
    [AT_EB_USER_BUS(kName2) post_b:2];
    [AT_EB_SYS_BUS() post_name:kSysName userInfo:@{@"data":@(2)}];
    [AT_EB_SYS_BUS() post_name:kSysName2 userInfo:@{@"data":@(2)}];

    {{
        ATEventBusTest *test = [ATEventBusTest new];
        [test regEvent];

        [AT_EB_USER_BUS(kName) post_a:3];
        [AT_EB_USER_BUS(kName2) post_b:3];
        [AT_EB_SYS_BUS() post_name:kSysName userInfo:@{@"data":@(3)}];
        [AT_EB_SYS_BUS() post_name:kSysName2 userInfo:@{@"data":@(3)}];

        [test unRegEvent];

        [AT_EB_USER_BUS(kName) post_a:4];
        [AT_EB_USER_BUS(kName2) post_b:4];
        [AT_EB_SYS_BUS() post_name:kSysName userInfo:@{@"data":@(4)}];
        [AT_EB_SYS_BUS() post_name:kSysName2 userInfo:@{@"data":@(4)}];
    }}
    
    {{
        for (NSInteger i = 0; i < 300; ++i) {
            ATEventBusTest *test = [ATEventBusTest new];
            [test regEvent];
        }
        // 频繁销毁创建，内存地址可能重用
        
        [AT_EB_USER_BUS(kName) post_a:1];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [AT_EB_USER_BUS(kName) post_a:1];
        });
    }}
}

@end
