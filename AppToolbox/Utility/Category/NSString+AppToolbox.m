//
//  NSString+AppToolbox.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "NSString+AppToolbox.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

static const int kBufferSize = 1024;

@implementation NSFileHandle(Hash)

- (NSString *)at_fileMD5HexString
{
    assert(self != nil);
    CC_MD5_CTX ctx = {0};
    CC_MD5_Init(&ctx);
    NSData* data = [self readDataOfLength:kBufferSize];
    while (data && [data length] > 0) {
        CC_MD5_Update(&ctx, [data bytes], (uint32_t)[data length]);
        data = [self readDataOfLength:kBufferSize];
    }
    unsigned char result[CC_MD5_DIGEST_LENGTH] = {0x00};
    CC_MD5_Final(result, &ctx);
    NSData *temp = [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
    return [NSString at_hexStringFromData:temp];
}

- (NSString *)at_fileSHA1HexString
{
    assert(self != nil);
    CC_SHA1_CTX ctx = {0};;
    CC_SHA1_Init(&ctx);
    NSData* data = [self readDataOfLength:kBufferSize];
    while (data && [data length] > 0) {
        CC_SHA1_Update(&ctx, [data bytes], (uint32_t)[data length]);
        data = [self readDataOfLength:kBufferSize];
    }
    unsigned char result[CC_SHA1_DIGEST_LENGTH] = {0x00};
    CC_SHA1_Final(result, &ctx);
    NSData *temp = [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
    return [NSString at_hexStringFromData:temp];
}

@end

@implementation NSString (AppToolbox)

#pragma mark - Length

- (BOOL)at_empty
{
    return self.length == 0;
}

- (BOOL)at_notEmpty
{
    return self.length > 0 ;
}

- (NSUInteger)at_composedLength
{
    NSUInteger composedLength = 0;
    NSRange range = NSMakeRange(0, 0);
    for (NSUInteger i = 0; i < self.length; i += range.length) {
        range = [self rangeOfComposedCharacterSequenceAtIndex:i];
        composedLength++;
    }
    return composedLength;
}

- (NSUInteger)at_lengthFromComposedLength:(NSUInteger)composedLength
{
    NSUInteger charLen = 0;
    NSUInteger len = 0;
    NSRange range = NSMakeRange(0, 0);
    for (; charLen < self.length; charLen += range.length) {
        range = [self rangeOfComposedCharacterSequenceAtIndex:charLen];
        len++;
        if (len == composedLength) {
            charLen += range.length;
            break;
        }
    }
    return charLen;
}

#pragma mark - Truncate

- (NSString *)at_truncateLength:(NSUInteger)length
{
    NSRange stringRange = {0, MIN(self.length, length)};
    stringRange = [self rangeOfComposedCharacterSequencesForRange:stringRange];
    NSString *shortString = [self substringWithRange:stringRange];
    return shortString;
}

- (NSString *)at_truncateEllipsLength:(NSUInteger)length
{
    NSString *string = [self at_truncateLength:length];
    return [string stringByAppendingString:@"..."];
}

- (NSString *)at_appendingString:(NSString * _Nullable)appendString
{
    if (appendString == nil) {
        return self;
    }
    return [self stringByAppendingString:appendString];
}

#pragma mark - Number

- (NSUInteger)at_unsignedIntegerValue
{
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    return [formatter numberFromString:self].unsignedIntegerValue;
}

- (BOOL)at_isNumber
{
    if (self.length <= 0) {
        return NO;
    }
    NSString *num = [NSString stringWithFormat:@"^[0-9]\\d{%lu}$", (unsigned long)self.length - 1];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", num];
    if ([regextestct evaluateWithObject:self] == YES) {
        return YES;
    }
    return NO;
}

+ (NSString *)at_stringWithThousandBitSeparatorNumber:(NSInteger)num
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter stringFromNumber:@(num)];
}

+ (NSString *)at_stringRomaNumberForNum:(uint8_t)num
{
    if (num == 0 || num > 10) {
        return @"";
    }
    
    NSArray *array = @[@"I", @"II", @"III", @"IV", @"V", @"VI", @"VII", @"VIII", @"IX", @"X"];
    return array[num - 1];
}

+ (NSString *)at_stringHanNumberForNum:(int32_t)num
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterRoundHalfDown;
    return [formatter stringFromNumber:[NSNumber numberWithInteger:num]];
}

#pragma mark - Size

- (CGSize)at_sizeWithFont:(UIFont *)font
{
    CGSize inSize = [self sizeWithAttributes:@{ NSFontAttributeName : font }];
    inSize.width = ceil(inSize.width);
    inSize.height = ceil(inSize.height);
    return inSize;
}

- (CGSize)at_sizeWithFont:(UIFont *)font limitWidth:(CGFloat)limitWidth
{
    return [self at_sizeWithFont:font limitWidth:limitWidth lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)at_sizeWithFont:(UIFont *)font limitWidth:(CGFloat)limitWidth lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize rectSize = CGSizeMake(limitWidth, MAXFLOAT);
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle]mutableCopy];
    textStyle.lineBreakMode = lineBreakMode;
    NSDictionary *attributes = @{ NSFontAttributeName : font,
                                  NSParagraphStyleAttributeName : textStyle };
    CGSize inSize = [self boundingRectWithSize:rectSize
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attributes
                                       context:nil].size;
    inSize.width = ceil(inSize.width);
    inSize.height = ceil(inSize.height);
    return inSize;
}

#pragma mark - Url

- (NSString *)at_urlEncode
{
    NSString *newString = [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return newString != nil ? newString : @"";
}


- (NSString *)at_urlDecode
{
    NSString *decodeString = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return decodeString.stringByRemovingPercentEncoding;
}

- (NSDictionary *)at_getURLParameters
{
    NSRange range = [self rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *parametersString = [self substringFromIndex:range.location + 1];
    
    if ([parametersString containsString:@"&"]) {
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents) {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            if (key == nil || value == nil) {
                continue;
            }
            id existValue = [params valueForKey:key];
            if (existValue != nil) {
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    [params setValue:items forKey:key];
                }
                else {
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                [params setValue:value forKey:key];
            }
        }
    }
    else {
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        if (pairComponents.count == 1) {
            return nil;
        }
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        if (key == nil || value == nil) {
            return nil;
        }
        [params setValue:value forKey:key];
    }
    return [params copy];
}

#pragma mark - Crypto

- (NSString *)at_MD5
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSString at_MD5FromData:data];
}

- (NSString *)at_SHA1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSString at_SHA1FromData:data];
}

+  (NSString *)at_MD5FromData:(NSData *)data
{
    const char *str = [data bytes];
    unsigned char digest[CC_MD5_DIGEST_LENGTH] = {0x00};
    CC_MD5(str, (CC_LONG)[data length], digest);
    NSData *temp = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    return [NSString at_hexStringFromData:temp];
}

+ (NSString *)at_SHA1FromData:(NSData *)data
{
    const unsigned char *buffer = [data bytes];
    unsigned char result[CC_SHA1_DIGEST_LENGTH] = {0x00};
    CC_SHA1(buffer, (CC_LONG)[data length], result);
    NSData *temp = [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH];
    return [NSString at_hexStringFromData:temp];
}

+ (NSString *)at_hexStringFromData:(NSData *)data;
{
    const uint32_t length = (uint32_t)[data length];
    const unsigned char *str = [data bytes];
    NSMutableString *hexStr = [NSMutableString stringWithCapacity:length*2];
    for (int i=0; i<length; i++) {
        [hexStr appendFormat:@"%02x", str[i]];
    }
    return hexStr;
}

+ (NSString *)at_fileMd5HexString:(NSString *)filePath
{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (handle == nil) {
        return nil;
    }
    return [handle at_fileMD5HexString];
}

+ (NSString *)at_fileSha1HexString:(NSString *)filePath
{
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (handle == nil) {
        return nil;
    }
    return [handle at_fileSHA1HexString];
}

+ (NSData *)at_DESEncrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1] = {'\0'};
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

+ (NSData *)at_DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1] = {'\0'};
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

#pragma mark - Filter

- (NSString *)at_trimWhitespaceAndNewline
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)at_trimCompositeString
{
    @autoreleasepool {
        NSString *string = [self stringByTrimmingCharactersInSet:[NSString addExtraFilterCharacterSet]];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decomposableCharacterSet]];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet capitalizedLetterCharacterSet]];
        return string;
    }
}

+ (NSCharacterSet *)addExtraFilterCharacterSet
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet new];
    [characterSet addCharactersInString:@"\u200F\u202B"];
    return characterSet;
}

- (NSString *)at_filterXMLEscapeChar
{
    NSString *temp = [self stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    [temp stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    [temp stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    [temp stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    [temp stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    return temp;
}

#pragma mark - Chinese

+ (BOOL)at_hasChinese:(NSString *)string
{
    for (int i = 0; i < string.length; i++) {
        unichar ch = [string characterAtIndex:i];
        if (ch > 0x4e00 && ch < 0x9fff) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - JSON

- (id)at_JSONObject
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (data == NULL) {
        return nil;
    }
    
    NSError *err = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    return obj;
}

@end
