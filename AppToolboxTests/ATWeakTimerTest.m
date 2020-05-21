//
//  ATWeakTimerTest.m
//  AppToolboxTests
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ATWeakTimer.h"

@interface ATWeakTimerTest : XCTestCase

@property (nonatomic, strong) ATWeakTimer *weakTimer;
@property (nonatomic, strong) XCTestExpectation *exception;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation ATWeakTimerTest

- (void)setUp {
    ;
}

- (void)tearDown {
    [self.weakTimer invalidate];
    self.weakTimer = nil;
    self.exception = nil;
    self.count = 0;
}

- (void)testExample {
    self.exception = [self expectationWithDescription:@"1"];
    self.weakTimer = [ATWeakTimer timerWithTimeInterval:2 target:self selector:@selector(timeout:) userInfo:@{@"abc":@(123)} repeats:NO];
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)timeout:(ATWeakTimer *)weakTimer
{
    NSDictionary *dic = weakTimer.userInfo;
    XCTAssert([dic isEqualToDictionary:@{@"abc":@(123)}]);
    [self.exception fulfill];
}

- (void)testExample2 {
    self.exception = [self expectationWithDescription:@"2"];
    self.weakTimer = [ATWeakTimer timerWithTimeInterval:2 target:self selector:@selector(timeout2:) userInfo:nil repeats:YES];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)timeout2:(ATWeakTimer *)weakTimer
{
    XCTAssert(weakTimer.userInfo == nil);
    self.count ++;
    if (self.count == 4) {
        [self.weakTimer invalidate];
        self.weakTimer = nil;
        [self.exception fulfill];
    }
}

- (void)testExample3 {
    self.exception = [self expectationWithDescription:@"3"];
    self.weakTimer = [ATWeakTimer timerWithTimeInterval:2 timeout:^(ATWeakTimer * _Nonnull timer) {
        XCTAssert(timer.userInfo == nil);
        [self.exception fulfill];
    } repeats:NO];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
