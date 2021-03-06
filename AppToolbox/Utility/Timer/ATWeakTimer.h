//
//  ATWeakTimer.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ATWeakTimer;

typedef void (^ATWeakTimerTimeout)(ATWeakTimer *timer);

@interface ATWeakTimer : NSObject

+ (ATWeakTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                                target:(id)target
                              selector:(SEL)selector
                              userInfo:(id _Nullable)userInfo
                               repeats:(BOOL)yesOrNo;

+ (ATWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                         target:(id)target
                                       selector:(SEL)selector
                                       userInfo:(id _Nullable)userInfo
                                        repeats:(BOOL)yesOrNo;

+ (ATWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                         target:(id)target
                                       selector:(SEL)selector
                                       userInfo:(id _Nullable)userInfo
                                        repeats:(BOOL)yesOrNo
                                    commonModes:(BOOL)isCommonModes;

+ (ATWeakTimer *)timerWithTimeInterval:(NSTimeInterval)ti
                               timeout:(ATWeakTimerTimeout)timeout
                               repeats:(BOOL)yesOrNo;

+ (ATWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                        timeout:(ATWeakTimerTimeout)timeout
                                        repeats:(BOOL)yesOrNo;

@property (nonatomic, strong) id userInfo;

- (void)fire;
- (void)invalidate;
- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
