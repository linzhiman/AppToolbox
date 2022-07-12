//
//  ATNotificationDemo.h
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATBlockNotificationCenter.h"

NS_ASSUME_NONNULL_BEGIN

AT_BN_DECLARE(kName)
AT_BN_DECLARE(kName1, int, a)
AT_BN_DECLARE(kName2, int, a, NSString *, b)
AT_BN_DECLARE(kName3, int, a, NSString *, b, id, c)
AT_BN_DECLARE(kName4, int, a, NSString *, b, id, c, id, d)
AT_BN_DECLARE(kName5, int, a, NSString *, b, id, c, id, d, id, e)
AT_BN_DECLARE(kName6, int, a, NSString *, b, id, c, id, d, id, e, id, f)
AT_BN_DECLARE(kName7, int, a, NSString *, b, id, c, id, d, id, e, id, f, id, g)
AT_BN_DECLARE(kName8, int, a, NSString *, b, id, c, id, d, id, e, id, f, id, g, id, h)

@interface ATNotificationTest : NSObject
@property (nonatomic, assign) BOOL test;
@end

#define UseObj
#ifdef UseObj
AT_BN_DECLARE(kName9, ATNotificationTest *, test);
#else
AT_BN_DECLARE_NO_OBJ(kName9, ATNotificationTest *, test);
#endif

@interface ATNotificationDemo : NSObject

- (void)demo;

@end

@interface ATNotificationDemo2 : ATNotificationDemo

- (void)demo;

@end

NS_ASSUME_NONNULL_END
