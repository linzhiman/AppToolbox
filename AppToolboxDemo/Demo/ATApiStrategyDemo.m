//
//  ATApiStrategyDemo.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATApiStrategyDemo.h"
#import "ATApiStrategy.h"
#import "ATGlobalMacro.h"

@interface ATApiStrategyDemo()

@property (nonatomic, strong) dispatch_block_t hold;
@property (nonatomic, strong) ATApiFluidStrategy *fluid;
@property (nonatomic, strong) ATApiSplitStrategy *split;
@property (nonatomic, strong) ATApiRetryStrategy *retry;
@property (nonatomic, strong) ATApiCombineStrategy *combine;

@end

@implementation ATApiStrategyDemo

- (void)demo
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    self.hold = ^{
        [self description];
    };
#pragma clang diagnostic pop
    
    [self fluidDemo];
    
    NSInteger delay = 5;
    
    AT_WEAKIFY_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weak_self splitDemo];
    });
    
    delay += 5;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weak_self retryDemo];
    });
    
    delay += 20;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weak_self combineDemo];
        weak_self.hold = nil;
    });
}

- (void)fluidDemo
{
    if (self.fluid == nil) {
        self.fluid = [ATApiFluidStrategy new];
        self.fluid.delayMs = 3000;
        self.fluid.doWork = ^(ATApiFluidStrategy * _Nonnull apiStrategy) {
            NSLog(@"fluid doWork");
        };
    }
    [self.fluid fluid];
    [self.fluid fluid];
    [self.fluid fluid];
}

- (void)splitDemo
{
    if (self.split == nil) {
        self.split = [ATApiSplitStrategy new];
    }
    [self.split splitArray:@[@1, @2, @3, @4, @5] maxCount:2 split:^(ATApiSplitStrategy * _Nonnull apiStrategy, ATApiSplitStrategyObj * _Nonnull splitObj) {
        NSLog(@"split split %@", splitObj.splitArray);
        NSMutableArray *res = [NSMutableArray new];
        for (NSNumber *tmp in splitObj.splitArray) {
            [res addObject:@(tmp.intValue + 100)];
        }
        [apiStrategy completeSplit:splitObj succeed:YES results:res];
    } complete:^(ATApiSplitStrategy * _Nonnull apiStrategy, id  _Nullable results, NSArray * _Nullable failArray) {
        NSLog(@"split complete %@", results);
    }];
}

- (void)retryDemo
{
    if (self.retry == nil) {
        self.retry = [ATApiRetryStrategy new];
        self.retry.maxRetryCount = 5;
        self.retry.retryPolicy = ATApiRetryStrategyPolicyFibonacci;
        self.retry.doWork = ^(ATApiRetryStrategy * _Nonnull apiStrategy, NSUInteger retryCount) {
            NSLog(@"retry doWork %@", @(retryCount));
            [apiStrategy completeSucceed:retryCount == 4];
        };
    }
    [self.retry runRestart:YES];
}

- (void)combineDemo
{
    if (self.combine == nil) {
        self.combine = [ATApiCombineStrategy new];
    }
    [self.combine combineApi:^(ATApiCombineStrategy * _Nonnull apiStrategy, ATApiCombineStrategyObj * _Nonnull combineObj) {
        NSLog(@"combine api %@", combineObj.key);
        [apiStrategy completeCombineObj:combineObj succeed:YES result:@"a"];
    } key:@(1)];
    [self.combine combineApi:^(ATApiCombineStrategy * _Nonnull apiStrategy, ATApiCombineStrategyObj * _Nonnull combineObj) {
        NSLog(@"combine api %@", combineObj.key);
        [apiStrategy completeCombineObj:combineObj succeed:YES result:@"b"];
    } key:@(2)];
    [self.combine combineApi:^(ATApiCombineStrategy * _Nonnull apiStrategy, ATApiCombineStrategyObj * _Nonnull combineObj) {
        NSLog(@"combine api %@", combineObj.key);
        [apiStrategy completeCombineObj:combineObj succeed:YES result:@"c"];
    } key:@(3)];
    [self.combine runSerial:YES complete:^(ATApiCombineStrategy * _Nonnull apiStrategy, NSDictionary * _Nonnull results) {
        NSLog(@"combine res %@", results);
        NSLog(@"combine res %@", ((ATApiCombineStrategyResult *)results[@(1)]).result);
        NSLog(@"combine res %@", ((ATApiCombineStrategyResult *)results[@(2)]).result);
        NSLog(@"combine res %@", ((ATApiCombineStrategyResult *)results[@(3)]).result);
    }];
}

@end
