//
//  ATCountdownObjDemo.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/28.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATCountdownObjDemo.h"
#import "ATGlobalMacro.h"
#import "ATCountdownObj.h"

@interface ATCountdownObjDemo()

@property (nonatomic, strong) dispatch_block_t hold;
@property (nonatomic, strong) ATCountdownObj *obj;

@end

@implementation ATCountdownObjDemo

- (void)demo
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    self.hold = ^{
        [self description];
    };
#pragma clang diagnostic pop
    
    AT_WEAKIFY_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weak_self.hold = nil;
    });
    
    self.obj = [ATCountdownObj new];
    self.obj.cb = ^(BOOL done, NSUInteger countdown) {
        NSLog(@"countdownobj cb done(%@) countdown(%@)", @(done), @(countdown));
    };
    [self.obj updateCountdownMs:8500];
}

@end
