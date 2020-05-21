//
//  NSBundle+ATKit.m
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import "NSBundle+ATKit.h"

@implementation NSBundle (ATKit)

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
