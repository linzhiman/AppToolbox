//
//  UIFont+ATKit.h
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
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

@interface UIFont (ATKit)

+ (UIFont *)at_systemFontOfSize:(CGFloat)fontSize weight:(ATFontWeight)weight;

@end

NS_ASSUME_NONNULL_END
