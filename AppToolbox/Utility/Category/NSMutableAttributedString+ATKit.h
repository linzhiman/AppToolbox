//
//  NSMutableAttributedString+ATKit.h
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (ATKit)

- (void)at_appendIcon:(UIImage *)icon;
- (void)at_appendIcon:(UIImage *)icon frame:(CGRect)frame;
- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font;
- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font underLine:(BOOL)underline;
- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font lineSpace:(CGFloat)lineSpace;
- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font lineSpace:(CGFloat)lineSpace align:(NSTextAlignment)align;
- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font lineSpace:(CGFloat)lineSpace align:(NSTextAlignment)align baseLine:(CGFloat)baseLine;

@end

NS_ASSUME_NONNULL_END
