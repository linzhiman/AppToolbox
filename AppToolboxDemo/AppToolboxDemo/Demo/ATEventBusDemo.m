//
//  ATEventBusDemo.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/7/2.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATEventBusDemo.h"
#import "ATEventBus.h"

AT_EB_DECLARE(kEBName, int, a);
AT_EB_DEFINE(kEBName, int, a);

AT_EB_DECLARE(kEBName2, int, b);
AT_EB_DEFINE(kEBName2, int, b);

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
//        NSLog(@"init %@", self);
    }
    return self;
}

- (void)dealloc
{
//    NSLog(@"dealloc %@", self);
}

- (void)regEvent
{
    [AT_EB_USER_EVENT(kEBName).observer(self) reg:^(ATEBEvent<ATEB_DATA_kEBName *> * _Nonnull event) {
        NSLog(@"ATEventBusTest user event %@ %@", event.eventId, @(event.data.a));
    }];
    [AT_EB_USER_EVENT(kEBName2).observer(self) reg:^(ATEBEvent<ATEB_DATA_kEBName2 *> * _Nonnull event) {
        NSLog(@"ATEventBusTest user event %@ %@", event.eventId, @(event.data.b));
    }];
    [AT_EB_SYS_EVENT(kSysName).observer(self) reg:^(ATEBEvent<NSDictionary *> * _Nonnull event) {
        NSLog(@"ATEventBusTest sys event %@ %@", event.eventId, event.data);
    }];
    [AT_EB_SYS_EVENT(kSysName2).observer(self) reg:^(ATEBEvent<NSDictionary *> * _Nonnull event) {
        NSLog(@"ATEventBusTest sys event %@ %@", event.eventId, event.data);
    }];

    self.eventToken = [AT_EB_USER_EVENT(kEBName).observer(self) forceReg:^(ATEBEvent<ATEB_DATA_kEBName *> * _Nonnull event) {
        NSLog(@"ATEventBusTest user force event %@ %@", event.eventId, @(event.data.a));
    }];
    self.eventToken2 = [AT_EB_SYS_EVENT(kSysName).observer(self) forceReg:^(ATEBEvent<NSDictionary *> * _Nonnull event) {
        NSLog(@"ATEventBusTest sys force event %@ %@", event.eventId, event.data);
    }];
}

- (void)unRegEvent
{
    AT_EB_USER_EVENT(kEBName).observer(self).unReg();
    AT_EB_USER_EVENT(kEBName2).observer(self).unReg();
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

        [self post:1];
    }}

    [self post:2];

    {{
        ATEventBusTest *test = [ATEventBusTest new];
        [test regEvent];

        [self post:3];

        [test unRegEvent];

        [self post:4];
    }}
}

- (void)post:(int)num
{
    [AT_EB_USER_BUS(kEBName) post_a:num];
    [AT_EB_USER_BUS(kEBName2) post_b:num];
    [AT_EB_SYS_BUS(kSysName) post_data:@{@"data":@(num)}];
    [AT_EB_SYS_BUS(kSysName2) post_data:@{@"data":@(num)}];
}

@end
