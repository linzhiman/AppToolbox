//
//  ATGCDTimer.m
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import "ATGCDTimer.h"

@interface ATGCDTimer()

@property (nonatomic, strong) dispatch_source_t dispatchTimer;
@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, assign) BOOL suspended;
@property (nonatomic, assign) BOOL repeats;

@end


@implementation ATGCDTimer

+ (ATGCDTimer *)scheduleTimer:(NSTimeInterval)ti
                      timeout:(ATGCDTimerTimeout)timeout
                      repeats:(BOOL)yesOrNo
{
    ATGCDTimer *gcdTimer = [[ATGCDTimer alloc] initWithInterval:ti timeout:timeout repeats:yesOrNo];
    [gcdTimer start];
    return gcdTimer;
}

+ (ATGCDTimer *)scheduleTimer:(NSTimeInterval)ti
                      timeout:(ATGCDTimerTimeout)timeout
                      repeats:(BOOL)yesOrNo
                dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    ATGCDTimer *gcdTimer = [[ATGCDTimer alloc] initWithInterval:ti timeout:timeout repeats:yesOrNo dispatchQueue:dispatchQueue];
    [gcdTimer start];
    return gcdTimer;
}

- (void)start:(NSTimeInterval)ti
{
    if (!self.isValid || !self.suspended) {
        return;
    }
    
    self.interval = ti;
    
    [self start];
}

- (void)start
{
    if (!self.isValid || !self.suspended) {
        return;
    }
    
    self.suspended = NO;
    
    uint64_t anInterval = self.interval * NSEC_PER_SEC;
    dispatch_time_t aStartTime = dispatch_time(DISPATCH_TIME_NOW, anInterval);
    
    if (self.repeats) {
        dispatch_source_set_timer(self.dispatchTimer, aStartTime, anInterval, 0);
    }
    else {
        dispatch_source_set_timer(self.dispatchTimer, aStartTime, DISPATCH_TIME_FOREVER, 0);
    }
    
    dispatch_resume(self.dispatchTimer);
}

- (void)stop
{
    if (self.isValid) {
        dispatch_source_cancel(self.dispatchTimer);
    }
}

- (void)suspend
{
    if (self.isValid && !self.suspended) {
        dispatch_suspend(self.dispatchTimer);
        self.suspended = YES;
    }
}

- (BOOL)isValid
{
    return (self.dispatchTimer != nil && dispatch_source_testcancel(self.dispatchTimer) == 0);
}


#pragma mark - initialization

- (id)init
{
    if (self = [super init]) {
        _dispatchTimer = nil;
        _suspended = NO;
        _repeats = NO;
        _interval = 0;
    }
    return self;
}

- (id)initWithInterval:(NSTimeInterval)ti
               timeout:(ATGCDTimerTimeout)timeout
               repeats:(BOOL)yesOrNo
{
    return [self initWithInterval:ti
                          timeout:timeout
                          repeats:yesOrNo
                    dispatchQueue:dispatch_get_main_queue()];
}

- (id)initWithInterval:(NSTimeInterval)ti
               timeout:(ATGCDTimerTimeout)timeout
               repeats:(BOOL)yesOrNo
         dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    if (self = [super init]) {
        [self initDispatchTimer:timeout
                        repeats:yesOrNo
                  dispatchQueue:dispatchQueue];
        
        _suspended = YES;
        _repeats = yesOrNo;
        _interval = ti;
    }
    return self;
}

- (void)initDispatchTimer:(ATGCDTimerTimeout)timeout
                  repeats:(BOOL)yesOrNo
            dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    _dispatchTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                            0, 0, dispatchQueue);
    
    dispatch_source_t aDispatchTimer = _dispatchTimer;
    dispatch_source_set_timer(aDispatchTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(aDispatchTimer, ^{
        if (!yesOrNo) {
            dispatch_source_cancel(aDispatchTimer);
        }
        
        if (timeout) {
            timeout();
        };
    });
}

- (void)dealloc
{
    [self stop];
}

@end
