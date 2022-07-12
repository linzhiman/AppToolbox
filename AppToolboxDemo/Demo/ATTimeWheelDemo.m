//
//  ATTimeWheelDemo.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/6/4.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATTimeWheelDemo.h"
#import "ATTimeWheel.h"
#import "ATGlobalMacro.h"
#import "ATWeakProxy.h"

#define ADD_TASK(atLong) \
{{ \
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970] * 1000; \
    ATTWTimerTask *task = [ATTWTimerTask new]; \
    task.delayMs = atLong; \
    task.action = ^{ \
        NSLog(@"action %@ %@", @(atLong), @(ceil([[NSDate date] timeIntervalSince1970] * 1000 - now))); \
    }; \
    [self.timeWheelTimer addTask:task]; \
}}

@interface ATTimeWheelDemo ()

@property (nonatomic, strong) ATTimeWheelTimer *timeWheelTimer;
@property (nonatomic, strong) dispatch_block_t hold;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation ATTimeWheelDemo

- (void)demo
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    self.hold = ^{
        [self description];
    };
#pragma clang diagnostic pop
    
    AT_WEAKIFY_SELF;
    
//#define ATTW_TEST
#ifndef ATTW_TEST
    
    self.timeWheelTimer = [ATTimeWheelTimer timeWithTickMs:2000 wheelSize:4];
    
    ADD_TASK(500);
    ADD_TASK(1800);
    ADD_TASK(2200);
    ADD_TASK(2500);
    ADD_TASK(7500);
    ADD_TASK(10000);
    ADD_TASK(11000);
    ADD_TASK(11500);
    ADD_TASK(17000);
    ADD_TASK(31000);
    ADD_TASK(40000);
    ADD_TASK(150000);
    ADD_TASK(5500);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(21 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AT_ENSURE_WEAKSELF_AND_STRONGIFY_SELF;
        ADD_TASK(800);
        ADD_TASK(1000);
        ADD_TASK(2500);
        ADD_TASK(23000);
    });
    
#else
    
    self.timeWheelTimer = [ATTimeWheelTimer timeWithTickMs:200 wheelSize:5];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:[ATWeakProxy proxyWithTarget:self] selector:@selector(onDisplayLink)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

#endif
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(180 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weak_self.hold = nil;
    });
}

- (void)onDisplayLink
{
//    [self testA];
    [self testB];
}

- (void)testA
{
    for (int i = 0; i < 10; i++) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970] * 1000;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"dispatch %@ %@", @(5), @(ceil([[NSDate date] timeIntervalSince1970] * 1000 - now)));
        });
    }
}

- (void)testB
{
    for (int i = 0; i < 10; i++) {
        ADD_TASK(5000);
    }
}

@end
