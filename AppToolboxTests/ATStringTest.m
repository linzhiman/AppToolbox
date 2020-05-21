//
//  ATStringTest.m
//  AppToolboxTests
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+AppToolbox.h"

@interface ATStringTest : XCTestCase

@end

@implementation ATStringTest

- (void)setUp {
    ;
}

- (void)tearDown {
    ;
}

- (void)testExample {
    NSString *aString = @"😈123😈";
    XCTAssert([aString length] == 7);
    XCTAssert([aString at_composedLength] == 5);
    XCTAssert([aString at_lengthFromComposedLength:1] == 2);
    XCTAssert([aString at_lengthFromComposedLength:3] == 4);
}

- (void)testExample2 {
    NSString *aString = @"😈123😈";
    XCTAssert([[aString at_truncateLength:1] isEqualToString:@"😈"]);
    XCTAssert([[aString at_truncateLength:2] isEqualToString:@"😈"]);
    XCTAssert([[aString at_truncateLength:3] isEqualToString:@"😈1"]);
    XCTAssert([[aString at_truncateEllipsLength:4] isEqualToString:@"😈12..."]);
}

- (void)testExample3 {
    NSString *aString = @"12345678";
    XCTAssert(aString.at_unsignedIntegerValue == 12345678);
    XCTAssert(aString.at_isNumber);
    NSString *aString2 = @"a12345678";
    XCTAssert(!aString2.at_isNumber);
    XCTAssert([[NSString at_stringWithThousandBitSeparatorNumber:12345678] isEqualToString:@"12,345,678"]);
    XCTAssert([[NSString at_stringRomaNumberForNum:0] isEqualToString:@""]);
    XCTAssert([[NSString at_stringRomaNumberForNum:1] isEqualToString:@"I"]);
    XCTAssert([[NSString at_stringRomaNumberForNum:2] isEqualToString:@"II"]);
    XCTAssert([[NSString at_stringRomaNumberForNum:3] isEqualToString:@"III"]);
    XCTAssert([[NSString at_stringRomaNumberForNum:4] isEqualToString:@"IV"]);
    XCTAssert([[NSString at_stringRomaNumberForNum:5] isEqualToString:@"V"]);
    XCTAssert([[NSString at_stringRomaNumberForNum:6] isEqualToString:@"VI"]);
    XCTAssert([[NSString at_stringRomaNumberForNum:7] isEqualToString:@"VII"]);
    XCTAssert([[NSString at_stringRomaNumberForNum:8] isEqualToString:@"VIII"]);
    XCTAssert([[NSString at_stringRomaNumberForNum:9] isEqualToString:@"IX"]);
    XCTAssert([[NSString at_stringRomaNumberForNum:10] isEqualToString:@"X"]);
    XCTAssert([[NSString at_stringRomaNumberForNum:11] isEqualToString:@""]);
    
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage hasPrefix:@"zh-Hans"]) {
        XCTAssert([[NSString at_stringHanNumberForNum:0] isEqualToString:@"〇"]);
        XCTAssert([[NSString at_stringHanNumberForNum:11] isEqualToString:@"十一"]);
    }
    else if ([currentLanguage hasPrefix:@"en"]) {
        XCTAssert([[NSString at_stringHanNumberForNum:0] isEqualToString:@"zero"]);
        XCTAssert([[NSString at_stringHanNumberForNum:11] isEqualToString:@"eleven"]);
    }
}

- (void)testExample4 {
    //size
}

- (void)testExample5 {
    NSString *aString = @"http://www.linzhiman.com/query?text=\"热门\"";
    XCTAssert([aString.at_urlEncode isEqualToString:@"http://www.linzhiman.com/query?text=%22%E7%83%AD%E9%97%A8%22"]);
    NSString *aString2 = @"http://www.linzhiman.com/query?text=abc";
    XCTAssert([aString2.at_getURLParameters isEqualToDictionary:@{@"text":@"abc"}]);
    NSString *aString3 = @"http://www.linzhiman.com/query?text=abc&score=100";
    NSDictionary *dic = @{@"text":@"abc",@"score":@"100"};
    XCTAssert([aString3.at_getURLParameters isEqualToDictionary:dic]);
}

@end
