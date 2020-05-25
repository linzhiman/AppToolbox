//
//  ATComponentDemo.h
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATComponentService.h"

NS_ASSUME_NONNULL_BEGIN

/**
 ATComponentService(ComponentA)均由组件提供者实现，调用者使用即可。
 */

@interface ATComponentA : NSObject

AT_COMPONENT_ACTION(version);
AT_COMPONENT_ACTION(fly);

@end

@interface ATComponentService(ComponentA)

+ (NSString *)a_versionWithPrefix:(NSString *)prefix callback:(void(^)(NSString *version))callback;
+ (NSString *)a_flyWithSpeed:(NSNumber *)speed;

@end

@interface ATComponentDemo : NSObject

- (void)demo;

@end

NS_ASSUME_NONNULL_END
