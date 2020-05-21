//
//  UIColor+AppToolbox.m
//  AppToolbox
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "UIColor+AppToolbox.h"

@implementation UIColor (AppToolbox)

+ (UIColor *)at_colorWithHexString:(NSString *)hexString
{
    return [[self class] at_colorWithHexString:hexString alpha:1.0];
}

+ (UIColor *)at_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
    if ('#' != [hexString characterAtIndex:0]) {
        hexString = [NSString stringWithFormat:@"#%@", hexString];
    }
    
    hexString = [[self class] hexStringTransformFromThreeCharacters:hexString];
    
    NSString *redHex = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(1, 2)]];
    unsigned redInt = [[self class] hexValueToUnsigned:redHex];
    
    NSString *greenHex = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(3, 2)]];
    unsigned greenInt = [[self class] hexValueToUnsigned:greenHex];
    
    NSString *blueHex = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(5, 2)]];
    unsigned blueInt = [[self class] hexValueToUnsigned:blueHex];
    
    UIColor *color = [UIColor at_colorWith8BitRed:redInt green:greenInt blue:blueInt alpha:alpha];
    return color;
}

+ (UIColor *)at_colorWithARGB:(NSString *)argbString
{
    if (argbString.length == 8) {
        
        NSString *aplhaString = [argbString substringWithRange:NSMakeRange(0, 2)];
        NSString *colorString = [argbString substringWithRange:NSMakeRange(2, 6)];
        
        NSString *aplhaHex  = [NSString stringWithFormat:@"0x%@", aplhaString];
        unsigned aplhaInt   = [[self class] hexValueToUnsigned:aplhaHex];
        
        CGFloat aplha = aplhaInt / 255.0;
        return [UIColor at_colorWithHexString:colorString alpha:aplha];
    }
    
    return [UIColor at_colorWithHexString:argbString];
}

+ (UIColor *)at_colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue
{
    return [[self class] at_colorWith8BitRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *)at_colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha
{
    UIColor *color = [UIColor colorWithRed:(float)red/255 green:(float)green/255 blue:(float)blue/255 alpha:alpha];
    return color;
}

+ (NSString *)hexStringTransformFromThreeCharacters:(NSString *)hexString
{
    if (hexString.length == 4) {
        hexString = [NSString stringWithFormat:@"#%@%@%@%@%@%@",
                     [hexString substringWithRange:NSMakeRange(1, 1)],[hexString substringWithRange:NSMakeRange(1, 1)],
                     [hexString substringWithRange:NSMakeRange(2, 1)],[hexString substringWithRange:NSMakeRange(2, 1)],
                     [hexString substringWithRange:NSMakeRange(3, 1)],[hexString substringWithRange:NSMakeRange(3, 1)]];
    }
    
    return hexString;
}

+ (unsigned)hexValueToUnsigned:(NSString *)hexValue
{
    unsigned value = 0;
    
    NSScanner *hexValueScanner = [NSScanner scannerWithString:hexValue];
    [hexValueScanner scanHexInt:&value];
    
    return value;
}

+ (UIColor *) at_colorWithValue:(UInt32)value
{
    return [UIColor at_colorWithValue:value alpha:1.0f];
}

+ (UIColor *)at_colorWithValue:(UInt32)value alpha:(CGFloat)alpha
{
    UInt8 *val = (UInt8 *)&value;
    return [UIColor colorWithRed:*(val+2)/ 255.0 green:*(val+1)/255.0 blue:*(val)/255.0 alpha:alpha];
}

- (UInt32) at_toValue
{
    const CGFloat* reds = CGColorGetComponents(self.CGColor);
    if (CGColorGetNumberOfComponents(self.CGColor) >= 4) {
        UInt8 red = reds[0] * 255;
        UInt8 green = reds[1] * 255;
        UInt8 blue = reds[2] * 255;
        UInt8 alpha = reds[3] * 255;
        
        UInt32 value = 0;
        UInt8 *val = (UInt8*)&value;
        *val = blue;
        *(val+1) = green;
        *(val+2) = red;
        *(val+3) = alpha;
        return value;
    }
    return 0;
}

+ (UIColor *)at_colorWithNumber:(NSNumber *)value
{
    long blue = value.unsignedIntValue % 256;
    long green = value.unsignedIntValue / 256 % 256;
    long red = value.unsignedIntValue / 256 / 256 % 256;
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

@end
