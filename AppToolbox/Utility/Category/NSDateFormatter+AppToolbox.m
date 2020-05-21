//
//  NSDateFormatter+AppToolbox.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "NSDateFormatter+AppToolbox.h"

@implementation NSDateFormatter (AppToolbox)

+ (instancetype)at_sharedObject
{
    static NSDateFormatter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSDateFormatter alloc] init];
    });
    
    return instance;
}

@end
