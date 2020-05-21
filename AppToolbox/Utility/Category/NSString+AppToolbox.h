//
//  NSString+AppToolbox.h
//  AppToolbox
//
//  Created by linzhiman on 2019/4/30.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AppToolbox)

#pragma mark - Length

- (BOOL)at_empty;
- (BOOL)at_notEmpty;

- (NSUInteger)at_composedLength;
- (NSUInteger)at_lengthFromComposedLength:(NSUInteger)composedLength;

#pragma mark -Truncate

- (NSString *)at_truncateLength:(NSUInteger)length;
- (NSString *)at_truncateEllipsLength:(NSUInteger)length;

- (NSString *)at_appendingString:(NSString * _Nullable)appendString;

#pragma mark - Number

- (NSUInteger)at_unsignedIntegerValue;

// 利用正则表达式判断是否全数字
- (BOOL)at_isNumber;

// 将形如1234567的数字格式化为1,234,567
+ (NSString *)at_stringWithThousandBitSeparatorNumber:(NSInteger)num;

// 转换为罗马数字，仅支持1~10
+ (NSString *)at_stringRomaNumberForNum:(uint8_t)num;

// 转换为当前语言文字描述
+ (NSString *)at_stringHanNumberForNum:(int32_t)num;

#pragma mark - Size

- (CGSize)at_sizeWithFont:(UIFont *)font;
- (CGSize)at_sizeWithFont:(UIFont *)font limitWidth:(CGFloat)limitWidth;
- (CGSize)at_sizeWithFont:(UIFont *)font limitWidth:(CGFloat)limitWidth lineBreakMode:(NSLineBreakMode)lineBreakMode;

#pragma mark - Url

- (NSString *)at_urlEncode;
- (NSDictionary *)at_getURLParameters;

#pragma mark - Crypto

- (NSString *)at_MD5;
- (NSString *)at_SHA1;
+ (NSString *)at_MD5FromData:(NSData *)data;
+ (NSString *)at_SHA1FromData:(NSData *)data;
+ (NSString *)at_hexStringFromData:(NSData *)data;
+ (NSString *)at_fileMd5HexString:(NSString *)filePath;
+ (NSString *)at_fileSha1HexString:(NSString *)filePath;
+ (NSData *)at_DESEncrypt:(NSData *)data WithKey:(NSString *)key;
+ (NSData *)at_DESDecrypt:(NSData *)data WithKey:(NSString *)key;

#pragma mark - Filter

- (NSString *)at_trimWhitespaceAndNewline;
- (NSString *)at_trimCompositeString;

// XML转义符号反转
- (NSString *)at_filterXMLEscapeChar;

#pragma mark - Chinese

+ (BOOL)at_hasChinese:(NSString *)string;

#pragma mark - JSON

- (id)at_JSONObject;

@end

NS_ASSUME_NONNULL_END
