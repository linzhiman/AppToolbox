//
//  ATCountdownObj.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/28.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATCountdownObj.h"
#import "ATGCDTimer.h"
#import "ATGlobalMacro.h"

@interface ATCountdownObj()

@property (nonatomic, assign) NSInteger countdown;
@property (nonatomic, strong) ATGCDTimer *timer;

@property (nonatomic, assign) NSUInteger countdownMs;
@property (nonatomic, assign) NSTimeInterval timestamp;

@property (nonatomic, assign) BOOL delayStart;

@end

@implementation ATCountdownObj

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateCountdownMs:(NSUInteger)countdownMs
{
    self.delayStart = NO;
    
    self.countdownMs = countdownMs;
    self.timestamp = [[NSDate date] timeIntervalSince1970];
    
    double delay = countdownMs % 1000 / 1000.0;
    NSUInteger second = ceil(countdownMs / 1000.0);
    
    if (second > 0) {
        if (delay == 0) {
            [self startCountdown:second];
        }
        else {
            AT_SAFETY_CALL_BLOCK(self.cb, NO, second);
            [self stopCountdown];
            
            self.delayStart = YES;
            AT_WEAKIFY_SELF;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (weak_self.delayStart) {
                    [weak_self startCountdown:second - 1];//ceil
                }
            });
        }
    }
    else {
        [self stopCountdown];
        AT_SAFETY_CALL_BLOCK(self.cb, YES, 0);
    }
}

- (void)startCountdown:(NSUInteger)countdown
{
    self.countdown = countdown;
    AT_WEAKIFY_SELF;
    self.timer = [ATGCDTimer scheduleTimer:1 timeout:^{
        [weak_self onTimeout];
    } repeats:YES];
    [self onTimeout];
}

- (void)stopCountdown
{
    if (self.timer) {
        self.timer = nil;
    }
}

- (void)onTimeout
{
    if (self.countdown > 0) {
        AT_SAFETY_CALL_BLOCK(self.cb, NO, self.countdown);
        self.countdown--;
    }
    else {
        [self stopCountdown];
        AT_SAFETY_CALL_BLOCK(self.cb, YES, self.countdown);
    }
}

- (void)onNotification:(NSNotification *)notification
{
    [self updateCountdownMs:[self refreshCountdownMs]];
}

- (NSUInteger)refreshCountdownMs
{
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - self.timestamp;
    if (duration < 0.1) {
        duration = 0;
    }
    NSUInteger durationMs = duration * 1000;
    if (self.countdownMs > durationMs) {
        return self.countdownMs - durationMs;
    }
    return 0;
}

@end
