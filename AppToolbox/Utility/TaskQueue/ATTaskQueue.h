//
//  ATTaskQueue.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 任务队列
 - 支持并发或者串行执行任务
 - 支持触发所有或者只触发一个任务
 - 支持手动结束任务
 - 支持优先级
 */

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ATTaskState) {
    ATTaskStateInit,
    ATTaskStatePending,
    ATTaskStateDoing,
    ATTaskStateDone
};

typedef NS_ENUM(NSUInteger, ATTaskQueueType) {
    ATTaskQueueTypeMainQueue,
    ATTaskQueueTypeSerial,
    ATTaskQueueTypeConcurrent
};

@interface ATTaskBase : NSObject<NSCopying>

@property (nonatomic, assign, readonly) NSUInteger taskId;
@property (nonatomic, assign, readonly) ATTaskState state;
@property (nonatomic, assign) NSUInteger priority; // 默认0，越大优先级越高
@property (nonatomic, strong) id userInfo;

@end

@class ATTaskNormal;

typedef id _Nullable (^ATTaskParamBlock)(ATTaskNormal *task);
typedef id _Nullable (^ATTaskActionBlock)(ATTaskNormal *task, id _Nullable params);
typedef void (^ATTaskCompleteBlock)(ATTaskNormal *task, id _Nullable result);

/// 常规任务
@interface ATTaskNormal : ATTaskBase

@property (nonatomic, copy, nullable) ATTaskParamBlock paramBlock;
@property (nonatomic, copy) ATTaskActionBlock actionBlock;
@property (nonatomic, copy, nullable) ATTaskCompleteBlock completeBlock;
@property (nonatomic, assign) BOOL manuallyComplete;

@end

/// 空白任务
/// 串行队列才能添加，用于延迟执行下一个任务
@interface ATTaskDelay : ATTaskBase

@property (nonatomic, assign) NSTimeInterval ti;

+ (instancetype)task:(NSTimeInterval)ti;

@end

@interface ATTaskQueue : NSObject

/**
 @brief 初始化队列
 @param type 队列类型
 @param notifyQueue 设置completeBlock在哪里执行，为nil则为mainQueue
*/
- (id)initWithType:(ATTaskQueueType)type notifyQueue:(dispatch_queue_t _Nullable)notifyQueue;

/**
 @brief 添加任务
 @param task 任务对象
 如果队列已触发，对于scheduleAll则按scheduleAll逻辑处理，对于scheduleOne则不触发任务
*/
- (void)pushTask:(ATTaskBase *)task;

/**
 @brief 触发所有任务，与scheduleOne互斥
 对于并发队列，触发所有任务，任务并发执行
 对于串行队列，顺序触发所有任务，任务逐一执行
*/
- (void)scheduleAll;

/**
 @brief 触发一个任务，与scheduleAll互斥
 不管队列是并发还是串行，触发第一个任务，任务结束不会自动触发下一个任务
*/
- (void)scheduleOne;

/**
 @brief 手动结束任务
 对于并发队列，不会触发其他任务
 对于串行队列，scheduleAll时触发下一个任务，scheduleOne时则不触发
*/
- (void)completeTask:(ATTaskBase *)task;

@end

NS_ASSUME_NONNULL_END
