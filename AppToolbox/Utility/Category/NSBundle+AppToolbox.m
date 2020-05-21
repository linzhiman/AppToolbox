//
//  NSBundle+AppToolbox.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "NSBundle+AppToolbox.h"

@implementation NSBundle (AppToolbox)

+ (NSArray *)at_loadNibNamed:(NSString *)name owner:(id)owner withBundleName:(NSString *)bundleName
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return [bundle loadNibNamed:name owner:owner options:nil];
}

+ (NSBundle *)at_bundleNamed:(NSString *)bundleName
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return bundle;
}

@end
