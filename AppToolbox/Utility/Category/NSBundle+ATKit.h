//
//  NSBundle+ATKit.h
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (ATKit)

+ (NSArray *)at_loadNibNamed:(NSString *)name owner:(id)owner withBundleName:(NSString *)bundleName;

+ (NSBundle *)at_bundleNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
