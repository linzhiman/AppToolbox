//
//  ATApiStrategy.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATApiStrategy.h"
#import "ATTaskQueue.h"
#import "ATGlobalMacro.h"

#pragma mark - ATApiFluidStrategy

@interface ATApiFluidStrategy ()

@property (nonatomic, strong) NSDate *lastFluid;
@property (nonatomic, assign) BOOL hasPerform;

@end

@implementation ATApiFluidStrategy

- (id)init
{
    self = [super init];
    if (self) {
        _delaySeconds = 5;
        _lastFluid = [NSDate dateWithTimeIntervalSince1970:0];
    }
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)fluid
{
    NSDate *now = [NSDate date];
    NSTimeInterval time = [now timeIntervalSinceDate:self.lastFluid];
    if (time > self.delaySeconds) {
        [self callDoWork];
    }
    else {
        if (!self.hasPerform) {
            self.hasPerform = YES;
            [self performSelector:@selector(callDoWork) withObject:nil afterDelay:self.delaySeconds];
        }
    }
}

- (void)callDoWork
{
    self.hasPerform = NO;
    self.lastFluid = [NSDate date];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    AT_SAFETY_CALL_BLOCK(self.doWork, self);
}

@end

#pragma mark - ATApiSplitStrategy

@interface ATApiSplitStrategyObj()

@property (nonatomic, assign) NSInteger uniqueId;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray *splitArray;

@end

@implementation ATApiSplitStrategyObj

@end

@interface ATApiSplitStrategyData : NSObject

@property (nonatomic, copy) ATApiSplitStrategySplit split;
@property (nonatomic, copy) ATApiSplitStrategyComplete complete;
@property (nonatomic, strong) NSMutableDictionary *indexTaskDic;
@property (nonatomic, strong) id results;
@property (nonatomic, strong) NSMutableArray *failArray;

@end

@implementation ATApiSplitStrategyData

@end

@interface ATApiSplitStrategy ()

@property (nonatomic, assign) NSInteger uniqueId;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, ATApiSplitStrategyData *> *idDataDic;
@property (nonatomic, strong) ATTaskQueue *taskQueue;

@end

@implementation ATApiSplitStrategy

- (instancetype)init
{
    self = [super init];
    if (self) {
        _idDataDic = [NSMutableDictionary new];
        _taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeMainQueue notifyQueue:nil];
    }
    return self;
}

- (void)splitArray:(NSArray *)array
          maxCount:(NSUInteger)maxCount
             split:(ATApiSplitStrategySplit)split
          complete:(ATApiSplitStrategyComplete)complete
{
    if (maxCount == 0) {
        maxCount = 20;
    }
    
    ++self.uniqueId;
    ATApiSplitStrategyData *splitData = [ATApiSplitStrategyData new];
    splitData.split = split;
    splitData.complete = complete;
    splitData.indexTaskDic = [NSMutableDictionary new];
    [self.idDataDic setObject:splitData forKey:@(self.uniqueId)];
    
    NSMutableArray *inner = [NSMutableArray arrayWithArray:array];
    NSInteger index = 0;
    NSInteger total = ceil(inner.count * 1.0 / maxCount);
    while (inner.count > 0) {
        NSArray *splitArray = nil;
        if (inner.count > maxCount) {
            NSRange range = NSMakeRange(0, maxCount);
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
            splitArray = [inner objectsAtIndexes:indexSet];
            [inner removeObjectsInRange:range];
        }
        else {
            splitArray = inner;
            inner = nil;
        }
        
        ATTaskNormal *aTask = [self createTaskIndex:index total:total splitArray:splitArray splitData:splitData];
        [self.taskQueue pushTask:aTask];
        
        [splitData.indexTaskDic setObject:aTask forKey:@(index)];
        ++index;
    }
    [self.taskQueue scheduleAll];
}

- (ATTaskNormal *)createTaskIndex:(NSInteger)index total:(NSInteger)total splitArray:(NSArray *)splitArray splitData:(ATApiSplitStrategyData *)splitData
{
    ATApiSplitStrategyObj *splitObj = [ATApiSplitStrategyObj new];
    splitObj.uniqueId = self.uniqueId;
    splitObj.index = index;
    splitObj.total = total;
    splitObj.splitArray = splitArray;
    
    ATTaskNormal *aTask = [[ATTaskNormal alloc] init];
    aTask.manuallyComplete = YES;
    aTask.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
        AT_SAFETY_CALL_BLOCK(splitData.split, self, splitObj);
        return nil;
    };
    return aTask;
}

- (void)completeSplit:(ATApiSplitStrategyObj *)splitObj
              succeed:(BOOL)succeed
              results:(id _Nullable)results
{
    ATApiSplitStrategyData *splitData = [self.idDataDic objectForKey:@(splitObj.uniqueId)];
    if (splitData != nil) {
        ATTaskNormal *aTask = [splitData.indexTaskDic objectForKey:@(splitObj.index)];
        [splitData.indexTaskDic removeObjectForKey:@(splitObj.index)];
        if (succeed) {
            [self appendResults:results splitData:splitData];
        }
        else {
            [self appendFailArray:splitObj.splitArray splitData:splitData];
        }
        [self.taskQueue completeTask:aTask];
        if (splitData.indexTaskDic.count == 0) {
            AT_SAFETY_CALL_BLOCK(splitData.complete, self, splitData.results, splitData.failArray);
            [self.idDataDic removeObjectForKey:@(splitObj.uniqueId)];
        }
    }
}

- (void)appendResults:(id _Nullable)results splitData:(ATApiSplitStrategyData *)splitData
{
    if (results != nil) {
        if ([results isKindOfClass:[NSArray class]]) {
            if (splitData.results == nil) {
                splitData.results = [NSMutableArray new];
            }
            if ([splitData.results isKindOfClass:[NSMutableArray class]]) {
                [((NSMutableArray *)splitData.results) addObjectsFromArray:results];
            }
        }
        else if ([results isKindOfClass:[NSDictionary class]]) {
            if (splitData.results == nil) {
                splitData.results = [NSMutableDictionary new];
            }
            if ([splitData.results isKindOfClass:[NSMutableDictionary class]]) {
                [((NSMutableDictionary *)splitData.results) addEntriesFromDictionary:results];
            }
        }
    }
}

- (void)appendFailArray:(NSArray *)failArray splitData:(ATApiSplitStrategyData *)splitData
{
    if (splitData.failArray == nil) {
        splitData.failArray = [NSMutableArray new];
    }
    [splitData.failArray addObjectsFromArray:failArray];
}

@end

#pragma mark - ATApiRetryStrategy

@interface ATApiRetryStrategy()

@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, assign) NSInteger uniqueId;

@end

@implementation ATApiRetryStrategy

- (instancetype)init
{
    self = [super init];
    if (self) {
        _retryCount = -1;
    }
    return self;
}

- (void)runRestart:(BOOL)restart;
{
    if (!restart && self.retryCount != -1) {
        return;
    }
    
    self.uniqueId++;
    
    self.retryCount = 0;
    
    AT_SAFETY_CALL_BLOCK(self.doWork, self, self.retryCount);
}

- (void)completeSucceed:(BOOL)succeed
{
    if (succeed) {
        self.retryCount = -1;
        return;
    }
    
    self.retryCount++;
    
    if (self.retryCount > self.maxRetryCount) {
        return;
    }
    
    NSUInteger delaySeconds = [self delaySecondsOfRetryCount:self.retryCount];
    if (delaySeconds == 0) {
        AT_SAFETY_CALL_BLOCK(self.doWork, self, self.retryCount);
    }
    else {
        AT_WEAKIFY_SELF;
        NSInteger uniqueId = self.uniqueId;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AT_ENSURE_WEAKSELF_AND_STRONGIFY_SELF;
            if (uniqueId == weak_self.uniqueId) {
                AT_SAFETY_CALL_BLOCK(self.doWork, self, self.retryCount);
            }
        });
    }
}

- (NSUInteger)delaySecondsOfRetryCount:(NSInteger)retryCount
{
    NSUInteger delaySeconds = 0;
    switch (self.retryPolicy) {
        case ATApiRetryStrategyPolicyPower2:
            delaySeconds = pow(2, retryCount - 1);
            break;
        case ATApiRetryStrategyPolicyPower3:
            delaySeconds = pow(3, retryCount - 1);
            break;
        default:
            delaySeconds = [self fibonacciAtRetryCount:retryCount];
            break;
    }
    return delaySeconds;
}

- (NSUInteger)fibonacciAtRetryCount:(NSInteger)retryCount
{
    NSArray *fibonacciArray = @[@1, @2, @3, @5, @8, @13, @21, @34, @55, @89, @144, @233, @377, @610];
    NSInteger index = retryCount - 1;
    if (index < 0) {
        index = 0;
    }
    else if (index >= fibonacciArray.count) {
        index = fibonacciArray.count - 1;
    }
    return ((NSNumber *)fibonacciArray[index]).unsignedIntegerValue;
}

@end

#pragma mark - ATApiCombineStrategy

@interface ATApiCombineStrategyObj()

@property (nonatomic, assign) NSInteger uniqueId;
@property (nonatomic, strong) id<NSCopying> key;

@end

@implementation ATApiCombineStrategyObj

@end

@interface ATApiCombineStrategyResult()

@property (nonatomic, assign) BOOL succeed;
@property (nonatomic, strong) id _Nullable result;

@end

@implementation ATApiCombineStrategyResult

@end

@interface ATApiCombineStrategyObj2 : NSObject

@property (nonatomic, strong) id<NSCopying> key;
@property (nonatomic, copy) ATApiCombineStrategyDoWork api;

@end

@implementation ATApiCombineStrategyObj2

@end

@interface ATApiCombineStrategyData : NSObject

@property (nonatomic, assign) BOOL serial;
@property (nonatomic, copy) ATApiCombineStrategyComplete complete;
@property (nonatomic, strong) NSMutableDictionary *keyTaskDic;
@property (nonatomic, strong) NSMutableDictionary *results;

@end

@implementation ATApiCombineStrategyData

@end

@interface ATApiCombineStrategy ()

@property (nonatomic, assign) NSInteger uniqueId;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, ATApiCombineStrategyData *> *idDataDic;
@property (nonatomic, strong) ATTaskQueue *taskQueue;
@property (nonatomic, strong) NSMutableArray *apiArray;

@end

@implementation ATApiCombineStrategy

- (instancetype)init
{
    self = [super init];
    if (self) {
        _idDataDic = [NSMutableDictionary new];
        _taskQueue = [[ATTaskQueue alloc] initWithType:ATTaskQueueTypeMainQueue notifyQueue:nil];
    }
    return self;
}

- (void)combineApi:(ATApiCombineStrategyDoWork)api
               key:(id<NSCopying>)key
{
    if (key == nil || api == NULL) {
        return;
    }
    
    if (self.apiArray == nil) {
        self.apiArray = [NSMutableArray new];
    }
    
    ATApiCombineStrategyObj2 *obj2 = [ATApiCombineStrategyObj2 new];
    obj2.key = key;
    obj2.api = api;
    [self.apiArray addObject:obj2];
}

- (void)runSerial:(BOOL)serial
         complete:(ATApiCombineStrategyComplete)complete
{
    ++self.uniqueId;
    
    ATApiCombineStrategyData *data = [ATApiCombineStrategyData new];
    data.serial = serial;
    data.complete = complete;
    data.keyTaskDic = [NSMutableDictionary new];
    [self.idDataDic setObject:data forKey:@(self.uniqueId)];
    
    for (ATApiCombineStrategyObj2 *tmp in self.apiArray) {
        ATTaskNormal *aTask = [self createTaskKey:tmp.key api:tmp.api];
        aTask.manuallyComplete = serial;
        [self.taskQueue pushTask:aTask];
        [data.keyTaskDic setObject:aTask forKey:tmp.key];
    }
    [self.apiArray removeAllObjects];
    [self.taskQueue scheduleAll];
}

- (void)completeCombineObj:(ATApiCombineStrategyObj *)combineObj
                   succeed:(BOOL)succeed
                    result:(id _Nullable)result
{
    ATApiCombineStrategyData *data = [self.idDataDic objectForKey:@(combineObj.uniqueId)];
    if (data != nil) {
        ATTaskNormal *aTask = [data.keyTaskDic objectForKey:combineObj.key];
        [data.keyTaskDic removeObjectForKey:combineObj.key];
        [self saveResultSucceed:succeed result:result key:combineObj.key data:data];
        if (data.serial) {
            [self.taskQueue completeTask:aTask];
        }
        if (data.keyTaskDic.count == 0) {
            AT_SAFETY_CALL_BLOCK(data.complete, self, data.results);
            [self.idDataDic removeObjectForKey:@(combineObj.uniqueId)];
        }
    }
}

- (ATTaskNormal *)createTaskKey:(id<NSCopying>)key api:(ATApiCombineStrategyDoWork)api
{
    ATApiCombineStrategyObj *combineObj = [ATApiCombineStrategyObj new];
    combineObj.uniqueId = self.uniqueId;
    combineObj.key = key;
    
    ATTaskNormal *aTask = [[ATTaskNormal alloc] init];
    aTask.actionBlock = ^id(ATTaskNormal * _Nonnull task, id  _Nullable params) {
        AT_SAFETY_CALL_BLOCK(api, self, combineObj);
        return nil;
    };
    return aTask;
}

- (void)saveResultSucceed:(BOOL)succeed result:(id _Nullable)result key:(id<NSCopying>)key data:(ATApiCombineStrategyData *)data
{
    if (key == nil) {
        return;
    }
    if (data.results == nil) {
        data.results = [NSMutableDictionary new];
    }
    ATApiCombineStrategyResult *tmp = [ATApiCombineStrategyResult new];
    tmp.succeed = succeed;
    tmp.result = result;
    [data.results setObject:tmp forKey:key];
}

@end
