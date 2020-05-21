//
//  ATGCDTimerTest.m
//  AppToolboxTests
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ATGCDTimer.h"
#import "ATGlobalMacro.h"

@interface ATGCDTimerTest : XCTestCase

@property (nonatomic, strong) ATGCDTimer *gcdTimer;
@property (nonatomic, strong) XCTestExpectation *exception;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation ATGCDTimerTest

- (void)setUp {
    ;
}

- (void)tearDown {
    self.gcdTimer = nil;
    self.exception = nil;
    self.count = 0;
}

- (void)testExample {
    self.exception = [self expectationWithDescription:@"1"];
    self.gcdTimer = [ATGCDTimer scheduleTimer:2 timeout:^{
        [self.exception fulfill];
    } repeats:NO];
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testExample2 {
    self.exception = [self expectationWithDescription:@"2"];
    AT_WEAKIFY_SELF;
    self.gcdTimer = [ATGCDTimer scheduleTimer:2 timeout:^{
        weak_self.count ++;
        if (weak_self.count == 4) {
            [weak_self.gcdTimer stop];
            weak_self.gcdTimer = nil;
            [self.exception fulfill];
        }
    } repeats:YES];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
