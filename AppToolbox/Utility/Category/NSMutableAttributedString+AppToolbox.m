//
//  NSMutableAttributedString+AppToolbox.m
//  AppToolbox
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "NSMutableAttributedString+AppToolbox.h"

@implementation NSMutableAttributedString (AppToolbox)

- (void)at_appendIcon:(UIImage *)icon
{
    NSTextAttachment *imageAttrib = [[NSTextAttachment alloc] init];
    imageAttrib.image = icon;
    imageAttrib.bounds = CGRectMake(0, 0, icon.size.width, icon.size.height);
    [self appendAttributedString:[NSAttributedString attributedStringWithAttachment:imageAttrib]];
}

- (void)at_appendIcon:(UIImage *)icon frame:(CGRect)frame
{
    NSTextAttachment *imageAttrib = [[NSTextAttachment alloc] init];
    imageAttrib.image = icon;
    imageAttrib.bounds = frame;
    [self appendAttributedString:[NSAttributedString attributedStringWithAttachment:imageAttrib]];
}

- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font
{
    [self at_appendText:text color:color font:font underLine:NO];
}

- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font underLine:(BOOL)underline
{
    NSMutableDictionary *attributeDict = [NSMutableDictionary dictionary];
    if (color) {
        [attributeDict setObject:color forKey:NSForegroundColorAttributeName];
    }
    
    if (font) {
        [attributeDict setObject:font forKey:NSFontAttributeName];
    }
    
    if (underline) {
        [attributeDict setObject:[NSNumber numberWithInteger:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
    }
    
    NSAttributedString *attribString = [[NSAttributedString alloc]initWithString:text attributes:attributeDict];
    
    [self appendAttributedString:attribString];
}

- (void)at_appendText:(NSString *)text color:(UIColor *)color font:(UIFont *)font lineSpace:(CGFloat)lineSpace
{
    [self at_appendText:text color:color font:font lineSpace:lineSpace align:NSTextAlignmentLeft];
}

- (void)at_appendText:(NSString *)text
                color:(UIColor *)color
                 font:(UIFont *)font
            lineSpace:(CGFloat)lineSpace
                align:(NSTextAlignment)align
{
    [self at_appendText:text color:color font:font lineSpace:lineSpace align:align baseLine:0];
}

- (void)at_appendText:(NSString *)text
                color:(UIColor *)color
                 font:(UIFont *)font
            lineSpace:(CGFloat)lineSpace
                align:(NSTextAlignment)align
             baseLine:(CGFloat)baseLine
{
    NSMutableDictionary *attributeDict = [NSMutableDictionary dictionary];
    [attributeDict setObject:color forKey:NSForegroundColorAttributeName];
    [attributeDict setObject:font forKey:NSFontAttributeName];
    [attributeDict setObject:@(baseLine) forKey:NSBaselineOffsetAttributeName];
    
    NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:lineSpace];
    [style setAlignment:align];
    [attributeDict setObject:style forKey:NSParagraphStyleAttributeName];
    
    NSAttributedString *attribString = [[NSAttributedString alloc]initWithString:text attributes:attributeDict];
    
    [self appendAttributedString:attribString];
}

@end
