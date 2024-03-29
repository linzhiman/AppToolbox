//
//  ATCountdownObj.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/28.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 按秒计时对象
 支持毫秒部分时间对齐，即8500毫秒开始倒计时，会先回调9，500毫秒后回调8
 App切后台后重进前台后会刷新倒计时，避免App挂起时定时器暂停
*/

NS_ASSUME_NONNULL_BEGIN

typedef void (^ATCountdownObjCb)(BOOL done, NSUInteger countdown);

/// 倒计时，每秒回调一次
@interface ATCountdownObj : NSObject

@property (nonatomic, strong) id userInfo;
@property (nonatomic, copy) ATCountdownObjCb cb;

- (void)updateCountdownMs:(NSUInteger)countdownMs;

@end

typedef void (^ATCountingObjCb)(NSUInteger counting);

/// 正计时，每秒回调一次
@interface ATCountingObj : NSObject

@property (nonatomic, copy) ATCountingObjCb cb;

- (void)updateCountingMs:(NSUInteger)countingMs;

@end

NS_ASSUME_NONNULL_END
