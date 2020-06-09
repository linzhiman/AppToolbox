//
//  ATTimeWheel.h
//  AppToolbox
//
//  Created by linzhiman on 2020/6/1.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 多层时间轮
 ！经测试，直接使用dispatch_after性能更优。
*/

NS_ASSUME_NONNULL_BEGIN

@interface ATTWTimerTask : NSObject

@property (nonatomic, assign) long delayMs;
@property (nonatomic, copy) dispatch_block_t action;

@end

@interface ATTimeWheelTimer : NSObject

+ (instancetype)timeWithTickMs:(long)tickMs wheelSize:(int)wheelSize;

- (void)addTask:(ATTWTimerTask *)task;
- (void)shutdown;

@end

NS_ASSUME_NONNULL_END
