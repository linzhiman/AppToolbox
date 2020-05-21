//
//  NSDateFormatter+ATKit.m
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import "NSDateFormatter+ATKit.h"

@implementation NSDateFormatter (ATKit)

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
