//
//  NSDictionary+AppToolbox.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "NSDictionary+AppToolbox.h"

id ATDictionarySafeGet(NSDictionary *dic, Class cls, id key)
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id val = [dic objectForKey:key];
    if ([val isKindOfClass:cls]) {
        return val;
    }
    return nil;
}

@implementation NSDictionary (AppToolbox)

/// nil able

- (NSString *)at_stringSafeGet:(id)aKey
{
    return ATDictionarySafeGet(self, [NSString class], aKey);
}

- (NSAttributedString *)at_attributedStringSafeGet:(id)aKey
{
    return ATDictionarySafeGet(self, [NSAttributedString class], aKey);
}

- (NSNumber *)at_numberSafeGet:(id)aKey
{
    return ATDictionarySafeGet(self, [NSNumber class], aKey);
}

- (NSArray *)at_arraySafeGet:(id)aKey
{
    return ATDictionarySafeGet(self, [NSArray class], aKey);
}

- (NSDictionary *)at_dictionarySafeGet:(id)aKey;
{
    return ATDictionarySafeGet(self, [NSDictionary class], aKey);
}

/// not nil

- (NSString *)at_notNilStringSafeGet:(id)aKey
{
    return [self at_stringSafeGet:aKey] ?: @"";
}

- (NSAttributedString *)at_notNilAttributedStringSafeGet:(id)aKey
{
    return [self at_attributedStringSafeGet:aKey] ?: [[NSAttributedString alloc] initWithString:@""];
}

- (NSNumber *)at_notNilNumberSafeGet:(id)aKey
{
    return [self at_numberSafeGet:aKey] ?: @(0);
}

- (NSArray *)at_notNilArraySafeGet:(id)aKey
{
    return [self at_arraySafeGet:aKey] ?: @[];
}

- (NSDictionary *)at_notNilDictionarySafeGet:(id)aKey
{
    return [self at_dictionarySafeGet:aKey] ?: @{};
}

/// num

- (int)at_intSafeGet:(id)aKey
{
    NSNumber *value = [self at_numberSafeGet:aKey];
    return [value intValue];
}

- (unsigned int)at_unsignedIntSafeGet:(id)aKey
{
    NSNumber *value = [self at_numberSafeGet:aKey];
    return [value unsignedIntValue];
}

- (long)at_longSafeGet:(id)aKey
{
    NSNumber *value = [self at_numberSafeGet:aKey];
    return [value longValue];
}

- (unsigned long)at_unsignedLongSafeGet:(id)aKey
{
    NSNumber *value = [self at_numberSafeGet:aKey];
    return [value unsignedLongValue];
}

- (long long)at_longLongSafeGet:(id)aKey
{
    NSNumber *value = [self at_numberSafeGet:aKey];
    return [value longLongValue];
}

- (unsigned long long)at_unsignedLongLongSafeGet:(id)aKey
{
    NSNumber *value = [self at_numberSafeGet:aKey];
    return [value unsignedLongLongValue];
}

- (float)at_floatSafeGet:(id)aKey
{
    NSNumber *value = [self at_numberSafeGet:aKey];
    return [value floatValue];
}

- (double)at_doubleSafeGet:(id)aKey
{
    NSNumber *value = [self at_numberSafeGet:aKey];
    return [value doubleValue];
}

- (BOOL)at_boolSafeGet:(id)aKey
{
    NSNumber *value = [self at_numberSafeGet:aKey];
    return [value boolValue];
}

- (NSInteger)at_integerSafeGet:(id)aKey
{
    NSNumber *value = [self at_numberSafeGet:aKey];
    return [value integerValue];
}

- (NSUInteger)at_unsignedIntegerSafeGet:(id)aKey
{
    NSNumber *value = [self at_numberSafeGet:aKey];
    return [value unsignedIntegerValue];
}

/// JSON

- (NSString *)at_JSONString
{
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (data == NULL) {
        return nil;
    }
    
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return json;
}

- (NSString *)at_JSONStringWithQuote
{
    NSMutableString *json = [[NSMutableString alloc] init];
    [self contructJSONString:json withDic:self];
    return json;
    
}

- (void)contructJSONString:(NSMutableString *)jsonString withDic:(NSDictionary *)dic
{
    [jsonString appendString:@"{"];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [jsonString appendString:@"\""];
        [jsonString appendString:key];
        [jsonString appendString:@"\""];
        [jsonString appendString:@":"];
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self contructJSONString:jsonString withDic:obj];
            [jsonString appendString:@"\","];
            
        } else /*if ( [obj isKindOfClass:[NSString class]] ) */ {
            [jsonString appendString:@"\""];
            [jsonString appendString:obj];
            [jsonString appendString:@"\","];
        }
    }];
    
    [jsonString deleteCharactersInRange:NSMakeRange(jsonString.length - 1, 1)];
    [jsonString appendString:@"}"];
}

@end
