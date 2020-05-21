//
//  ATTaskQueueTest.m
//  AppToolboxTests
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ATTaskQueue.h"
#import "ATGlobalMacro.h"

@interface ATTaskQueueTest : XCTestCase

@property (nonatomic, strong) ATTaskQueue *taskQueue;
@property (nonatomic, strong) XCTestExpectation *exception;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, strong) NSMutableArray *finisheds;
@property (nonatomic, strong) dispatch_queue_t notifyQueue;

@end

@implementation ATTaskQueueTest

- (void)setUp {
    self.actions = [[NSMutableArray alloc] init];
    self.finisheds = [[NSMutableArray alloc] init];
}

- (void)tearDown {
    [self.actions removeAllObjects];
    [self.finisheds removeAllObjects];
}

- (void)testExample {
    self.exception = [self expectationWithDescription:@"1"];
    self.notifyQueue = nil;
    self.taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeMainQueue notifyQueue:self.notifyQueue];
    AT_WEAKIFY_SELF;
    for (NSUInteger i = 0; i < 10; ++i) {
        ATTaskNormal *task = [[ATTaskNormal alloc] init];
        task.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
            NSLog(@"ATTaskQueueTest action %@ params %@ thread %@", @(task.taskId), params, [NSThread currentThread]);
            [weak_self.actions addObject:@(task.taskId)];
            return nil;
        };
        task.completeBlock = ^(ATTaskNormal * _Nonnull task, id  _Nullable result) {
            NSLog(@"ATTaskQueueTest finished %@ result %@ thread %@", @(task.taskId), result, [NSThread currentThread]);
            [weak_self.finisheds addObject:@(task.taskId)];
            if (weak_self.finisheds.count == 10) {
                [self.exception fulfill];
            }
        };
        [self.taskQueue pushTask:task];
    }
    [self.taskQueue scheduleAll];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testExample2 {
    self.exception = [self expectationWithDescription:@"2"];
    self.notifyQueue = dispatch_queue_create("ATTaskQueueTestQueue", DISPATCH_QUEUE_SERIAL);
    self.taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeSerial notifyQueue:self.notifyQueue];
    AT_WEAKIFY_SELF;
    for (NSUInteger i = 0; i < 10; ++i) {
        ATTaskNormal *task = [[ATTaskNormal alloc] init];
        task.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
            NSLog(@"ATTaskQueueTest action %@ params %@ thread %@", @(task.taskId), params, [NSThread currentThread]);
            [weak_self.actions addObject:@(task.taskId)];
            return nil;
        };
        task.completeBlock = ^(ATTaskNormal * _Nonnull task, id  _Nullable result) {
            NSLog(@"ATTaskQueueTest finished %@ result %@ thread %@", @(task.taskId), result, [NSThread currentThread]);
            [weak_self.finisheds addObject:@(task.taskId)];
            if (weak_self.finisheds.count == 10) {
                [self.exception fulfill];
            }
        };
        [self.taskQueue pushTask:task];
    }
    [self.taskQueue scheduleAll];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testExample3 {
    self.exception = [self expectationWithDescription:@"3"];
    self.notifyQueue = dispatch_queue_create("ATTaskQueueTestQueue", DISPATCH_QUEUE_SERIAL);
    self.taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeConcurrent notifyQueue:self.notifyQueue];
    AT_WEAKIFY_SELF;
    for (NSUInteger i = 0; i < 10; ++i) {
        ATTaskNormal *task = [[ATTaskNormal alloc] init];
        task.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
            NSLog(@"ATTaskQueueTest action %@ params %@ thread %@", @(task.taskId), params, [NSThread currentThread]);
            return nil;
        };
        task.completeBlock = ^(ATTaskNormal * _Nonnull task, id  _Nullable result) {
            NSLog(@"ATTaskQueueTest finished %@ result %@ thread %@", @(task.taskId), result, [NSThread currentThread]);
            [weak_self.finisheds addObject:@(task.taskId)];
            if (weak_self.finisheds.count == 10) {
                [self.exception fulfill];
            }
        };
        [self.taskQueue pushTask:task];
    }
    [self.taskQueue scheduleAll];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testExample4 {
    self.exception = [self expectationWithDescription:@"4"];
    self.notifyQueue = dispatch_queue_create("ATTaskQueueTestQueue", DISPATCH_QUEUE_SERIAL);
    self.taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeConcurrent notifyQueue:self.notifyQueue];
    AT_WEAKIFY_SELF;
    for (NSUInteger i = 0; i < 11; ++i) {
        ATTaskNormal *task = [[ATTaskNormal alloc] init];
        task.paramBlock = ^id(ATTaskNormal * _Nonnull task) {
            return @(100 + i);
        };
        task.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
            NSLog(@"ATTaskQueueTest action %@ params %@ thread %@", @(task.taskId), params, [NSThread currentThread]);
            return params;
        };
        task.completeBlock = ^(ATTaskNormal * _Nonnull task, id  _Nullable result) {
            NSLog(@"ATTaskQueueTest finished %@ result %@ thread %@", @(task.taskId), result, [NSThread currentThread]);
            [weak_self.finisheds addObject:@(task.taskId)];
            if (weak_self.finisheds.count == 10) {
                [self.exception fulfill];
            }
        };
        [self.taskQueue pushTask:task];
        if (i == 10) {
            [self.taskQueue scheduleAll];
        }
    }
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testExample5 {
    self.exception = [self expectationWithDescription:@"5"];
    self.notifyQueue = nil;
    self.taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeSerial notifyQueue:self.notifyQueue];
    AT_WEAKIFY_SELF;
    for (NSUInteger i = 0; i < 10; ++i) {
        ATTaskNormal *task = [[ATTaskNormal alloc] init];
        task.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
            NSLog(@"ATTaskQueueTest action %@ params %@ thread %@", @(task.taskId), params, [NSThread currentThread]);
            [weak_self.actions addObject:@(task.taskId)];
            return nil;
        };
        task.completeBlock = ^(ATTaskNormal * _Nonnull task, id  _Nullable result) {
            NSLog(@"ATTaskQueueTest finished %@ result %@ thread %@", @(task.taskId), result, [NSThread currentThread]);
            [weak_self.finisheds addObject:@(task.taskId)];
            if (weak_self.finisheds.count == 10) {
                [self.exception fulfill];
            }
        };
        [self.taskQueue pushTask:task];
        if (i % 3 == 0) {
            [self.taskQueue pushTask:[ATTaskDelay task:2.5]];
        }
    }
    [self.taskQueue scheduleAll];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testExample6 {
    self.exception = [self expectationWithDescription:@"6"];
    self.notifyQueue = dispatch_queue_create("ATTaskQueueTestQueue", DISPATCH_QUEUE_SERIAL);
    self.taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeSerial notifyQueue:self.notifyQueue];
    AT_WEAKIFY_SELF;
    for (NSUInteger i = 0; i < 10; ++i) {
        ATTaskNormal *task = [[ATTaskNormal alloc] init];
        task.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
            NSLog(@"ATTaskQueueTest action %@ params %@ thread %@", @(task.taskId), params, [NSThread currentThread]);
            [weak_self.actions addObject:@(task.taskId)];
            return nil;
        };
        task.completeBlock = ^(ATTaskNormal * _Nonnull task, id  _Nullable result) {
            NSLog(@"ATTaskQueueTest finished %@ result %@ thread %@", @(task.taskId), result, [NSThread currentThread]);
            [weak_self.finisheds addObject:@(task.taskId)];
            if (weak_self.finisheds.count == 13) {
                [self.exception fulfill];
            }
        };
        [self.taskQueue pushTask:task];
        if (i % 3 == 2) {
            task.manuallyComplete = YES;
            [self.taskQueue pushTask:task];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"ATTaskQueueTest complete %@", @(task.taskId));
                [weak_self.taskQueue completeTask:task];
            });
        }
    }
    [self.taskQueue scheduleAll];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testExample7 {
    self.exception = [self expectationWithDescription:@"7"];
    self.notifyQueue = dispatch_queue_create("ATTaskQueueTestQueue", DISPATCH_QUEUE_SERIAL);
    self.taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeSerial notifyQueue:self.notifyQueue];
    AT_WEAKIFY_SELF;
    for (NSUInteger i = 0; i < 10; ++i) {
        ATTaskNormal *task = [[ATTaskNormal alloc] init];
        task.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
            NSLog(@"ATTaskQueueTest action %@ params %@ thread %@", @(task.taskId), params, [NSThread currentThread]);
            [weak_self.actions addObject:@(task.taskId)];
            return nil;
        };
        task.completeBlock = ^(ATTaskNormal * _Nonnull task, id  _Nullable result) {
            NSLog(@"ATTaskQueueTest finished %@ result %@ thread %@", @(task.taskId), result, [NSThread currentThread]);
            [weak_self.finisheds addObject:@(task.taskId)];
            if (weak_self.finisheds.count == 10) {
                [self.exception fulfill];
            }
            [weak_self.taskQueue scheduleOne];
        };
        if (i % 2 == 1) {
            task.manuallyComplete = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"ATTaskQueueTest complete %@", @(task.taskId));
                [weak_self.taskQueue completeTask:task];
            });
        }
        [self.taskQueue pushTask:task];
    }
    [self.taskQueue scheduleOne];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testExample8 {
    self.exception = [self expectationWithDescription:@"8"];
    self.notifyQueue = dispatch_queue_create("ATTaskQueueTestQueue", DISPATCH_QUEUE_SERIAL);
    self.taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeSerial notifyQueue:self.notifyQueue];
    AT_WEAKIFY_SELF;
    for (NSUInteger i = 0; i < 10; ++i) {
        ATTaskNormal *task = [[ATTaskNormal alloc] init];
        task.userInfo = @(i);
        task.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
            NSLog(@"ATTaskQueueTest action %@ params %@ thread %@ userInfo %@", @(task.taskId), params, [NSThread currentThread], task.userInfo);
            [weak_self.actions addObject:@(task.taskId)];
            return nil;
        };
        task.completeBlock = ^(ATTaskNormal * _Nonnull task, id  _Nullable result) {
            NSLog(@"ATTaskQueueTest finished %@ result %@ thread %@", @(task.taskId), result, [NSThread currentThread]);
            [weak_self.finisheds addObject:@(task.taskId)];
            if (weak_self.finisheds.count == 10) {
                [self.exception fulfill];
            }
            [weak_self.taskQueue scheduleOne];
        };
        if (i % 2 == 1) {
            if (i == 3) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weak_self.taskQueue pushTask:task];
                });
                continue;
            }
            else {
                task.manuallyComplete = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"ATTaskQueueTest complete %@", @(task.taskId));
                    [weak_self.taskQueue completeTask:task];
                });
            }
        }
        [self.taskQueue pushTask:task];
    }
    [self.taskQueue scheduleOne];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testExample9 {
    self.exception = [self expectationWithDescription:@"9"];
    self.notifyQueue = dispatch_queue_create("ATTaskQueueTestQueue", DISPATCH_QUEUE_SERIAL);
    self.taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeSerial notifyQueue:self.notifyQueue];
    AT_WEAKIFY_SELF;
    for (NSUInteger i = 0; i < 10; ++i) {
        ATTaskNormal *task = [[ATTaskNormal alloc] init];
        task.userInfo = @(i);
        task.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
            NSLog(@"ATTaskQueueTest action %@ params %@ thread %@ userInfo %@", @(task.taskId), params, [NSThread currentThread], task.userInfo);
            [weak_self.actions addObject:@(task.taskId)];
            return nil;
        };
        task.completeBlock = ^(ATTaskNormal * _Nonnull task, id  _Nullable result) {
            NSLog(@"ATTaskQueueTest finished %@ result %@ thread %@", @(task.taskId), result, [NSThread currentThread]);
            [weak_self.finisheds addObject:@(task.taskId)];
            if (weak_self.finisheds.count == 10) {
                [self.exception fulfill];
            }
        };
        if (i % 2 == 1) {
            if (i == 3) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weak_self.taskQueue pushTask:task];
                });
                continue;
            }
            else {
                task.manuallyComplete = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"ATTaskQueueTest complete %@", @(task.taskId));
                    [weak_self.taskQueue completeTask:task];
                });
            }
        }
        [self.taskQueue pushTask:task];
    }
    [self.taskQueue scheduleAll];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testExample10 {
    self.exception = [self expectationWithDescription:@"10"];
    self.notifyQueue = dispatch_queue_create("ATTaskQueueTestQueue", DISPATCH_QUEUE_SERIAL);
    self.taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeConcurrent notifyQueue:self.notifyQueue];
    AT_WEAKIFY_SELF;
    for (NSUInteger i = 0; i < 10; ++i) {
        ATTaskNormal *task = [[ATTaskNormal alloc] init];
        task.userInfo = @(i);
        task.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
            NSLog(@"ATTaskQueueTest action %@ params %@ thread %@ userInfo %@", @(task.taskId), params, [NSThread currentThread], task.userInfo);
            [weak_self.actions addObject:@(task.taskId)];
            return nil;
        };
        task.completeBlock = ^(ATTaskNormal * _Nonnull task, id  _Nullable result) {
            NSLog(@"ATTaskQueueTest finished %@ result %@ thread %@", @(task.taskId), result, [NSThread currentThread]);
            [weak_self.finisheds addObject:@(task.taskId)];
            if (weak_self.finisheds.count == 10) {
                [self.exception fulfill];
            }
        };
        if (i % 2 == 1) {
            if (i == 3) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weak_self.taskQueue pushTask:task];
                });
                continue;
            }
            else {
                task.manuallyComplete = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"ATTaskQueueTest complete %@", @(task.taskId));
                    [weak_self.taskQueue completeTask:task];
                });
            }
        }
        [self.taskQueue pushTask:task];
    }
    [self.taskQueue scheduleAll];
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testExample11 {
    self.exception = [self expectationWithDescription:@"11"];
    self.notifyQueue = nil;
    self.taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeMainQueue notifyQueue:self.notifyQueue];
    AT_WEAKIFY_SELF;
    for (NSUInteger i = 0; i < 10; ++i) {
        ATTaskNormal *task = [[ATTaskNormal alloc] init];
        task.priority = i % 5;
        task.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
            NSLog(@"ATTaskQueueTest action %@ params %@ thread %@", @(task.taskId), params, [NSThread currentThread]);
            [weak_self.actions addObject:@(task.taskId)];
            return nil;
        };
        task.completeBlock = ^(ATTaskNormal * _Nonnull task, id  _Nullable result) {
            NSLog(@"ATTaskQueueTest finished %@ result %@ thread %@", @(task.taskId), result, [NSThread currentThread]);
            [weak_self.finisheds addObject:@(task.taskId)];
            if (weak_self.finisheds.count == 10) {
                [self.exception fulfill];
            }
        };
        [self.taskQueue pushTask:task];
    }
    [self.taskQueue scheduleAll];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
