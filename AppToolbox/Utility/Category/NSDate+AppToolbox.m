//
//  NSDate+AppToolbox.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/29.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "NSDate+AppToolbox.h"
#import "NSDateFormatter+AppToolbox.h"

@implementation NSDate (AppToolbox)

- (NSString *)at_toString
{
    return [self at_toStringWithFormat:@"yyyy-MM-dd"];
}

- (NSString *)at_toStringWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [NSDateFormatter at_sharedObject];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:self];
}

+ (NSDate *)at_stringToDate:(NSString *)string
{
    return [self at_stringToDateEx:string withFormat:@"yyyy-MM-dd"];
}

+ (NSDate *)at_stringToDateEx:(NSString *)string withFormat:(NSString*)format
{
    NSDateFormatter *dateFormatter = [NSDateFormatter at_sharedObject];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:string];
}

@end
