//
//  UIFont+ATKit.m
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import "UIFont+ATKit.h"

@implementation UIFont (ATKit)

+ (UIFont *)at_systemFontOfSize:(CGFloat)fontSize weight:(ATFontWeight)weight
{
    if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        CGFloat fontWeight = [self at_convertWeight:weight];
        return [UIFont systemFontOfSize:fontSize weight:fontWeight];
    }
    return (weight == ATFontWeightBold || weight == ATFontWeightMedium || weight ==  ATFontWeightHeavy ||
            weight == ATFontWeightSemibold) ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
}

+ (CGFloat)at_convertWeight:(ATFontWeight)weight
{
    CGFloat fontWeight = UIFontWeightRegular;
    switch (weight) {
        case ATFontWeightRegular:
            fontWeight = UIFontWeightRegular;
            break;
        case ATFontWeightBold:
            fontWeight = UIFontWeightBold;
            break;
        case ATFontWeightThin:
            fontWeight = UIFontWeightThin;
            break;
        case ATFontWeightBlack:
            fontWeight = UIFontWeightBlack;
            break;
        case ATFontWeightHeavy:
            fontWeight = UIFontWeightHeavy;
            break;
        case ATFontWeightLight:
            fontWeight = UIFontWeightLight;
            break;
        case ATFontWeightMedium:
            fontWeight = UIFontWeightMedium;
            break;
        case ATFontWeightSemibold:
            fontWeight = UIFontWeightSemibold;
            break;
        case ATFontWeightUltraLight:
            fontWeight = UIFontWeightUltraLight;
            break;
    }
    return fontWeight;
}

@end
