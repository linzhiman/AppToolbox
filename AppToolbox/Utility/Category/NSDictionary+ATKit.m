//
//  NSDictionary+ATKit.m
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import "NSDictionary+ATKit.h"

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

@implementation NSDictionary (ATKit)

- (NSString *)at_getString:(id)key
{
    return ATDictionarySafeGet(self, [NSString class], key);
}

- (NSAttributedString *)at_getAttributedString:(id)key
{
    return ATDictionarySafeGet(self, [NSAttributedString class], key);
}

- (NSNumber *)at_getNumber:(id)key
{
    return ATDictionarySafeGet(self, [NSNumber class], key);
}

- (NSArray *)at_getArray:(id)key
{
    return ATDictionarySafeGet(self, [NSArray class], key);
}

- (NSDictionary *)at_getDictionary:(id)key
{
    return ATDictionarySafeGet(self, [NSDictionary class], key);
}

#pragma mark - JSON

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
