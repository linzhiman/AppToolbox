//
//  NSDictionary+ATKit.h
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (ATKit)

- (NSString *)at_getString:(id)key;
- (NSAttributedString *)at_getAttributedString:(id)key;
- (NSNumber *)at_getNumber:(id)key;
- (NSArray *)at_getArray:(id)key;
- (NSDictionary *)at_getDictionary:(id)key;

#pragma mark - JSON

- (NSString *)at_JSONString;

// 生成带双引号转义符的字符串
- (NSString *)at_JSONStringWithQuote;

@end

NS_ASSUME_NONNULL_END
