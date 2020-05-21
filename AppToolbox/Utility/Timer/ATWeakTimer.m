//
//  ATWeakTimer.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATWeakTimer.h"
#import "ATGlobalMacro.h"

@interface ATWeakTimerWrapper : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) ATWeakTimer *weakTimer;

- (void)timeout:(id)timer;

@end

@implementation ATWeakTimerWrapper

- (void)timeout:(NSTimer *)timer
{
    if (self.target != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:self.weakTimer];
#pragma clang diagnostic pop
    }
}
@end

@interface ATWeakTimer()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) ATWeakTimerTimeout timeout;

@end

@implementation ATWeakTimer

+ (ATWeakTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                                target:(id)target
                              selector:(SEL)selector
                              userInfo:(id _Nullable)userInfo
                               repeats:(BOOL)yesOrNo
{
    ATWeakTimer *weakTimer = [[ATWeakTimer alloc] init];
    weakTimer.userInfo = userInfo;
    
    ATWeakTimerWrapper *wrapper = [[ATWeakTimerWrapper alloc] init];
    wrapper.target = target;
    wrapper.selector = selector;
    wrapper.weakTimer = weakTimer;
    
    weakTimer.timer = [NSTimer timerWithTimeInterval:ti
                                              target:wrapper
                                            selector:@selector(timeout:)
                                            userInfo:userInfo
                                             repeats:yesOrNo];
    [[NSRunLoop currentRunLoop] addTimer:weakTimer.timer forMode:NSRunLoopCommonModes];
    return weakTimer;
}

+ (ATWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                         target:(id)target
                                       selector:(SEL)selector
                                       userInfo:(id _Nullable)userInfo
                                        repeats:(BOOL)yesOrNo
                                    commonModes:(BOOL)isCommonModes
{
    ATWeakTimer *weakTimer = [[ATWeakTimer alloc] init];
    weakTimer.userInfo = userInfo;
    
    ATWeakTimerWrapper *wrapper = [[ATWeakTimerWrapper alloc] init];
    wrapper.target = target;
    wrapper.selector = selector;
    wrapper.weakTimer = weakTimer;
    
    weakTimer.timer = [NSTimer scheduledTimerWithTimeInterval:ti
                                                       target:wrapper
                                                     selector:@selector(timeout:)
                                                     userInfo:userInfo
                                                      repeats:yesOrNo];
    if (isCommonModes) {
        [[NSRunLoop currentRunLoop] addTimer:weakTimer.timer forMode:NSRunLoopCommonModes];
    }
    return weakTimer;
}

+ (ATWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                         target:(id)target
                                       selector:(SEL)selector
                                       userInfo:(id _Nullable)userInfo
                                        repeats:(BOOL)yesOrNo
{
    return [ATWeakTimer scheduledTimerWithTimeInterval:ti target:target selector:selector
                                              userInfo:userInfo repeats:yesOrNo commonModes:NO];
}

+ (ATWeakTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                               timeout:(ATWeakTimerTimeout)timeout repeats:(BOOL)yesOrNo
{
    ATWeakTimer *weakTimer = [ATWeakTimer timerWithTimeInterval:ti target:self selector:@selector(timeoutBlock:)
                                     userInfo:nil repeats:yesOrNo];
    weakTimer.timeout = timeout;
    return weakTimer;
}

+ (ATWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                        timeout:(ATWeakTimerTimeout)timeout repeats:(BOOL)yesOrNo
{
    ATWeakTimer *weakTimer = [ATWeakTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(timeoutBlock:)
                                                                userInfo:nil repeats:yesOrNo];
    weakTimer.timeout = timeout;
    return weakTimer;
}

+ (void)timeoutBlock:(id)weakTimer
{
    ATWeakTimer *timer = weakTimer;
    AT_SAFETY_CALL_BLOCK(timer.timeout, timer);
}

- (void)fire
{
    [self.timer fire];
}

- (void)invalidate
{
    [self.timer invalidate];
}

- (BOOL)isValid
{
    return [self.timer isValid];
}

@end
