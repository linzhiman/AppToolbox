//
//  ATApiStrategy.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 一套API调用管理工具
 将开发过程中一些常见的API调用的控制逻辑，整理成逻辑组件，避免不必要的重复代码。
 * 1.频率控制 - 将短时间内大量调用转化为间隔一定时间只调用一次
   - 如短时间收到大量消息，每次1秒刷新UI更新消息列表
 * 2.延时调用 - 将调用延迟一定时间后调用，可以重新及时或者取消调用
   - 如切换页面后，5秒内没切回来就销毁部分UI
 * 3.数据集分片 - 将大批量数据按粒度拆分为多个分片
   - 如批量请求100个用户数据，但接口每次请求支持最多50个用户，此时可以拆分为2次请求
 * 4.重试控制 - 调用失败时根据重试策略进行重试
   - 如调用失败，延迟1秒重试，再失败则延迟2秒重试
 * 5.组合调用 - 将多个调用逐一/并发执行，当全部完成时回调
   - 如UI更新需要查询2个接口才能显示
 */

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ATApiFluidStrategy

/**
 频率控制
 将短时间内大量调用转化为间隔一定时间只调用一次
 */

@class ATApiFluidStrategy;

typedef void (^ATApiFluidStrategyDoWork)(ATApiFluidStrategy *apiStrategy);

@interface ATApiFluidStrategy : NSObject

@property (nonatomic, strong) id userInfo;
@property (nonatomic, assign) NSUInteger delayMs;
@property (nonatomic, copy) ATApiFluidStrategyDoWork doWork;

/// 触发计时，调用后延迟delayMs后回调doWork，期间的其他fluid调用会被吃掉
- (void)fluid;

/// 取消正在延迟的调用
- (void)cancel;

@end

#pragma mark - ATApiDelayStrategy

/**
 延时调用
 将调用延迟一定时间后调用，可以重新及时或者取消调用
 */

@class ATApiDelayStrategy;

typedef void (^ATApiDelayStrategyDoWork)(ATApiDelayStrategy *apiStrategy);

@interface ATApiDelayStrategy : NSObject

@property (nonatomic, strong) id userInfo;
@property (nonatomic, assign) NSUInteger delaySeconds;
@property (nonatomic, copy) ATApiDelayStrategyDoWork doWork;

/// 重新开始计时，调用后延迟delaySeconds后回调doWork，之前的调用会取消
- (void)restartDelay;

/// 取消计时，调用后不会再回调doWork
- (void)cancelDelay;

@end

#pragma mark - ATApiSplitStrategy

/**
 数据集分片
 将大批量数据按粒度拆分为多个分片
*/

@interface ATApiSplitStrategyObj : NSObject

@property (nonatomic, assign, readonly) NSInteger uniqueId;     // 数据集唯一ID
@property (nonatomic, assign, readonly) NSInteger index;        // 分片序号
@property (nonatomic, assign, readonly) NSInteger total;        // 分片总数
@property (nonatomic, strong, readonly) NSArray *splitArray;    // 分片数据集

@end

@class ATApiSplitStrategy;

typedef void (^ATApiSplitStrategySplit)(ATApiSplitStrategy *apiStrategy, ATApiSplitStrategyObj *splitObj);
typedef void (^ATApiSplitStrategyComplete)(ATApiSplitStrategy *apiStrategy, id _Nullable results, NSArray * _Nullable failArray);

@interface ATApiSplitStrategy : NSObject

/**
 @brief 拆分数据集
 @param array 数据集
 @param maxCount 拆分粒度
 @param split 分片回调，在回调中用小粒度数据集去执行，执行完成需要调用completeSplit设置分片执行结果
 @param complete 全部完成回调，所有分片执行完成后回调
*/
- (void)splitArray:(NSArray *)array
          maxCount:(NSUInteger)maxCount
             split:(ATApiSplitStrategySplit)split
          complete:(ATApiSplitStrategyComplete)complete;

/**
 @brief 设置分片执行结果
 @param splitObj 分片对象
 @param succeed 分片执行结果
 @param results 分片结果数据，可以是NSArray/NSDictionary，会聚合缓存在complete回调中返回
*/
- (void)completeSplit:(ATApiSplitStrategyObj *)splitObj
              succeed:(BOOL)succeed
              results:(id _Nullable)results;

@end

#pragma mark - ATApiRetryStrategy

/**
 重试控制
 调用失败时根据重试策略进行重试
*/

typedef NS_ENUM(NSUInteger, ATApiRetryStrategyPolicy) {
    ATApiRetryStrategyPolicyFibonacci,    // 1 2 3 5  8  13
    ATApiRetryStrategyPolicyPower2,       // 1 2 4 8  16 32
    ATApiRetryStrategyPolicyPower3        // 1 3 9 27 81 243
};

@class ATApiRetryStrategy;

typedef void (^ATApiRetryStrategyDoWork)(ATApiRetryStrategy *apiStrategy, NSUInteger retryCount);

@interface ATApiRetryStrategy : NSObject

@property (nonatomic, strong) id userInfo;
@property (nonatomic, assign) NSUInteger maxRetryCount;
@property (nonatomic, assign) ATApiRetryStrategyPolicy retryPolicy;
@property (nonatomic, copy) ATApiRetryStrategyDoWork doWork;
@property (nonatomic, copy) ATApiRetryStrategyDoWork finish;

/**
 @brief 开始执行，初始时直接回调doWork，完成时需调用completeSucceed设置执行结果
 @param restart 是否重新开始，YES则清理重试次数并走初始逻辑，NO则检测是否已经在重试中，不在重试中则开始
*/
- (void)runRestart:(BOOL)restart;

/**
 @brief 设置执行结果
 @param succeed 是否成功，YES则停止重试，NO则按重试策略延迟一定时间后回调doWork进行重试
*/
- (void)completeSucceed:(BOOL)succeed;

@end

#pragma mark - ATApiCombineStrategy

/**
 组合调用
 将多个调用逐一/并发执行，当全部完成时回调
*/

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

/// key -> ATApiCombineStrategyResult
typedef void (^ATApiCombineStrategyComplete)(ATApiCombineStrategy *apiStrategy, NSDictionary *results);

@interface ATApiCombineStrategy : NSObject

/**
 @brief 添加调用
 @param api 内部保存api列表，调用runSerial后回调，完成后需调用completeCombineObj设置结果
 @param key api的唯一标示，内部不校验
*/
- (void)combineApi:(ATApiCombineStrategyDoWork)api
               key:(id<NSCopying>)key;

/**
 @brief 开始执行，添加后所有调用后触发执行
 @param serial 是否逐一执行，YES则complete之后才会继续下一个api回调，NO则不需要等待complete
 @param complete 组合调用全部完成后回调
*/
- (void)runSerial:(BOOL)serial
         complete:(ATApiCombineStrategyComplete)complete;

/**
 @brief 设置执行结果
 @param combineObj 组合调用标示
 @param succeed 是否成功
 @param result 结果数据，会缓存在complete回调中返回
*/
- (void)completeCombineObj:(ATApiCombineStrategyObj *)combineObj
                   succeed:(BOOL)succeed
                    result:(id _Nullable)result;

@end

NS_ASSUME_NONNULL_END
