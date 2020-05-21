//
//  ATWeakProxy.h
//  AppToolbox
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 用于避免强引用，如NSTimer, CADisplayLink, performselector:afterdelay
//  eg: _timer = [NSTimer timerWithTimeInterval:3 target:[BSWeakProxy proxyWithTarget:self] selector:@selector(test:) userInfo:nil repeats:NO];  ps:userInfo不要传self, 否则也会被强引用

@interface ATWeakProxy : NSObject

@property (nonatomic, weak, readonly) id target;

+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
