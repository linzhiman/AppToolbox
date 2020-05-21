//
//  NSMutableAttributedString+AppToolbox.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (AppToolbox)

- (void)at_appendIcon:(UIImage *)icon;
- (void)at_appendIcon:(UIImage *)icon frame:(CGRect)frame;
- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font;
- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font underLine:(BOOL)underline;
- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font lineSpace:(CGFloat)lineSpace;
- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font lineSpace:(CGFloat)lineSpace align:(NSTextAlignment)align;
- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font lineSpace:(CGFloat)lineSpace align:(NSTextAlignment)align baseLine:(CGFloat)baseLine;

@end

NS_ASSUME_NONNULL_END
