//
//  NSDate+AppToolbox.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/29.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (AppToolbox)

- (NSString *)at_toString; // default: yyyy-MM-dd
- (NSString *)at_toStringWithFormat:(NSString *)format;

+ (NSDate *)at_stringToDate:(NSString *)string;//default: yyyy-MM-dd
+ (NSDate *)at_stringToDateEx:(NSString *)string withFormat:(NSString*)format;

@end

NS_ASSUME_NONNULL_END
