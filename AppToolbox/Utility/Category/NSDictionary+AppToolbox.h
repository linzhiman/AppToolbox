//
//  NSDictionary+AppToolbox.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (AppToolbox)

/// nil able

- (NSString *)at_stringSafeGet:(id)aKey;
- (NSAttributedString *)at_attributedStringSafeGet:(id)aKey;

- (NSNumber *)at_numberSafeGet:(id)aKey;

- (NSArray *)at_arraySafeGet:(id)aKey;
- (NSDictionary *)at_dictionarySafeGet:(id)aKey;

/// not nil

- (NSString *)at_notNilStringSafeGet:(id)aKey; // nil -> @""
- (NSAttributedString *)at_notNilAttributedStringSafeGet:(id)aKey; // nil -> @""

- (NSNumber *)at_notNilNumberSafeGet:(id)aKey; // nil -> @(0)

- (NSArray *)at_notNilArraySafeGet:(id)aKey; // nil -> @[]
- (NSDictionary *)at_notNilDictionarySafeGet:(id)aKey; // nil -> @{};

/// num

- (int)at_intSafeGet:(id)aKey;
- (unsigned int)at_unsignedIntSafeGet:(id)aKey;
- (long)at_longSafeGet:(id)aKey;
- (unsigned long)at_unsignedLongSafeGet:(id)aKey;
- (long long)at_longLongSafeGet:(id)aKey;
- (unsigned long long)at_unsignedLongLongSafeGet:(id)aKey;
- (float)at_floatSafeGet:(id)aKey;
- (double)at_doubleSafeGet:(id)aKey;
- (BOOL)at_boolSafeGet:(id)aKey;
- (NSInteger)at_integerSafeGet:(id)aKey;
- (NSUInteger)at_unsignedIntegerSafeGet:(id)aKey;

/// JSON

- (NSString *)at_JSONString;
- (NSString *)at_JSONStringWithQuote; // 生成带双引号转义符的字符串

@end

NS_ASSUME_NONNULL_END
