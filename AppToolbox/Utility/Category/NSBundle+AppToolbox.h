//
//  NSBundle+AppToolbox.h
//  AppToolbox
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (AppToolbox)

+ (NSArray *)at_loadNibNamed:(NSString *)name owner:(id)owner withBundleName:(NSString *)bundleName;

+ (NSBundle *)at_bundleNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
