//
//  ATGCDTimer.h
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ATGCDTimerTimeout)(void);

@interface ATGCDTimer : NSObject

+ (ATGCDTimer *)scheduleTimer:(NSTimeInterval)ti
                      timeout:(ATGCDTimerTimeout)timeout
                      repeats:(BOOL)yesOrNo;

+ (ATGCDTimer *)scheduleTimer:(NSTimeInterval)ti
                      timeout:(ATGCDTimerTimeout)timeout
                      repeats:(BOOL)yesOrNo
                dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)start:(NSTimeInterval)ti;

- (void)start;

- (void)stop;

- (void)suspend;

- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
