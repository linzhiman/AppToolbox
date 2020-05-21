//
//  UIColor+ATKit.h
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ATKit)

/**
 *  使用十六进制创建颜色值
 *  @param hexString 十六进制字符串  for example @"#F1F1F1" OR @"F1F1F1" OR @"000" OR @"#000"
 *  @return 颜色
 */
+ (UIColor *)at_colorWithHexString:(NSString *)hexString;
/**
 *  使用十六进制创建颜色值
 *  @param hexString 十六进制字符串  for example @"#F1F1F1"
 *  @param alpha alpha
 *  @return 颜色
 */
+ (UIColor *)at_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

+ (UIColor *)at_colorWithARGB:(NSString *)argbString;

/**
 *  使用0-255之间的数字创建 可以使用 RGBACOLOR 宏
 *  @param red   0-255
 *  @param green 0-255
 *  @param blue  0-255
 *  @return 颜色
 */
+ (UIColor *)at_colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
+ (UIColor *)at_colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha;

+ (UIColor *)at_colorWithValue:(UInt32)value;
+ (UIColor *)at_colorWithValue:(UInt32)value alpha:(CGFloat)alpha;
- (UInt32) at_toValue;

+ (UIColor *)at_colorWithNumber:(NSNumber *)value;

@end

NS_ASSUME_NONNULL_END
