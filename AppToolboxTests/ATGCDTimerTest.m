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
    AT_WEAKIFY_SELF;
    self.gcdTimer = [ATGCDTimer scheduleTimer:2 timeout:^{
        weak_self.count++;
    } repeats:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(weak_self.count == 4);
        [self.exception fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testExample2 {
    self.exception = [self expectationWithDescription:@"2"];
    AT_WEAKIFY_SELF;
    self.gcdTimer = [ATGCDTimer scheduleTimer:1 timeout:^{
        weak_self.count++;
    } repeats:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(weak_self.count == 1);
        [self.exception fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testExample3 {
    self.exception = [self expectationWithDescription:@"3"];
    AT_WEAKIFY_SELF;
    self.gcdTimer = [ATGCDTimer scheduleTimer:0 timeout:^{
        weak_self.count++;
    } repeats:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(weak_self.count == 0);
        [self.exception fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testExample4 {
    self.exception = [self expectationWithDescription:@"4"];
    AT_WEAKIFY_SELF;
    self.gcdTimer = [ATGCDTimer scheduleTimer:0 timeout:^{
        weak_self.count++;
    } repeats:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(weak_self.count == 0);
        [self.exception fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testExample5 {
    self.exception = [self expectationWithDescription:@"5"];
    AT_WEAKIFY_SELF;
    self.gcdTimer = [ATGCDTimer scheduleTimer:1 timeout:^{
        weak_self.count++;
    } repeats:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weak_self.gcdTimer stop];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weak_self.gcdTimer start];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(weak_self.count == 7);
        [self.exception fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testExample6 {
    self.exception = [self expectationWithDescription:@"6"];
    AT_WEAKIFY_SELF;
    self.gcdTimer = [ATGCDTimer scheduleTimer:0.5 timeout:^{
        weak_self.count++;
    } repeats:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssert(weak_self.count == 9);
        [self.exception fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
