//
//  UIFont+AppToolbox.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ATFontWeight) {
    ATFontWeightRegular,
    ATFontWeightThin,
    ATFontWeightMedium,
    ATFontWeightUltraLight,
    ATFontWeightLight,
    ATFontWeightSemibold,
    ATFontWeightBold,
    ATFontWeightHeavy,
    ATFontWeightBlack
};

@interface UIFont (AppToolbox)

+ (UIFont *)at_systemFontOfSize:(CGFloat)fontSize weight:(ATFontWeight)weight;

@end

NS_ASSUME_NONNULL_END
