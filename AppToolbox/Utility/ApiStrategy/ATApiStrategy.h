//
//  ATApiStrategy.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ATApiFluidStrategy

@class ATApiFluidStrategy;

typedef void (^ATApiFluidStrategyDoWork)(ATApiFluidStrategy *apiStrategy);

// 流量控制，保证delaySeconds时间内只有一次doWork回调
// 延迟delaySeconds时间后触发操作，并吃掉延时内的流量

@interface ATApiFluidStrategy : NSObject

@property (nonatomic, assign) NSUInteger delaySeconds;
@property (nonatomic, strong) id userInfo;
@property (nonatomic, copy) ATApiFluidStrategyDoWork doWork;

- (void)fluid;

@end

#pragma mark - ATApiSplitStrategy

// 分片模型

@interface ATApiSplitStrategyObj : NSObject

@property (nonatomic, assign, readonly) NSInteger uniqueId;
@property (nonatomic, assign, readonly) NSInteger index;
@property (nonatomic, assign, readonly) NSInteger total;
@property (nonatomic, strong, readonly) NSArray *splitArray;

@end

@class ATApiSplitStrategy;

typedef void (^ATApiSplitStrategySplit)(ATApiSplitStrategy *apiStrategy, ATApiSplitStrategyObj *splitObj);
typedef void (^ATApiSplitStrategyComplete)(ATApiSplitStrategy *apiStrategy, id _Nullable results, NSArray * _Nullable failArray);

// 数据集分片，将大批量数据按粒度拆分为多个分片
// 使用场景举例：批量请求100个用户数据，但接口每次请求支持最多50个用户，此时可以拆分为2次请求

@interface ATApiSplitStrategy : NSObject

// maxCount 拆分粒度
// split 分片回调
// complete 全部完成回调
- (void)splitArray:(NSArray *)array
          maxCount:(NSUInteger)maxCount
             split:(ATApiSplitStrategySplit)split
          complete:(ATApiSplitStrategyComplete)complete;

// 分片操作完成时调用，results可用于保持结果数据
- (void)completeSplit:(ATApiSplitStrategyObj *)splitObj
              succeed:(BOOL)succeed
              results:(id _Nullable)results;

@end

#pragma mark - ATApiRetryStrategy

typedef NS_ENUM(NSUInteger, ATApiRetryStrategyPolicy) {
    ATApiRetryStrategyPolicyFibonacci,    // 1 2 3 5  8  13
    ATApiRetryStrategyPolicyPower2,       // 1 2 4 8  16 32
    ATApiRetryStrategyPolicyPower3        // 1 3 9 27 81 243
};

@class ATApiRetryStrategy;

typedef void (^ATApiRetryStrategyDoWork)(ATApiRetryStrategy *apiStrategy, NSUInteger retryCount);

// 重试控制，支持多种重试策略

@interface ATApiRetryStrategy : NSObject

@property (nonatomic, assign) NSUInteger maxRetryCount;
@property (nonatomic, assign) ATApiRetryStrategyPolicy retryPolicy;
@property (nonatomic, strong) id userInfo;
@property (nonatomic, copy) ATApiRetryStrategyDoWork doWork;

- (void)runRestart:(BOOL)restart;
- (void)completeSucceed:(BOOL)succeed;

@end

#pragma mark - ATApiCombineStrategy

@interface ATApiCombineStrategyObj : NSObject

@property (nonatomic, assign, readonly) NSInteger uniqueId;
@property (nonatomic, strong, readonly) id<NSCopying> key;

@end

@interface ATApiCombineStrategyResult : NSObject

@property (nonatomic, assign, readonly) BOOL succeed;
@property (nonatomic, strong, readonly) id _Nullable result;

@end

@class ATApiCombineStrategy;

typedef void (^ATApiCombineStrategyDoWork)(ATApiCombineStrategy *apiStrategy, ATApiCombineStrategyObj *combineObj);
// key -> ATApiCombineStrategyResult
typedef void (^ATApiCombineStrategyComplete)(ATApiCombineStrategy *apiStrategy, NSDictionary *results);

// api组合，将多个api逐一或全部执行，当全部完成时回调

@interface ATApiCombineStrategy : NSObject

- (void)combineApi:(ATApiCombineStrategyDoWork)api
               key:(id<NSCopying>)key;

- (void)runSerial:(BOOL)serial
         complete:(ATApiCombineStrategyComplete)complete;

- (void)completeCombineObj:(ATApiCombineStrategyObj *)combineObj
                   succeed:(BOOL)succeed
                    result:(id _Nullable)result;

@end

NS_ASSUME_NONNULL_END
