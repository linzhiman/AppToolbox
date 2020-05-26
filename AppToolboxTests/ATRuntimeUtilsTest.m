//
//  ATRuntimeUtilsTest.m
//  AppToolboxTests
//
//  Created by linzhiman on 2020/5/26.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ATRuntimeUtils.h"

@protocol IProtocol <NSObject>
@required
- (void)r_i_method:(NSInteger)i;
+ (void)r_c_method:(NSInteger)i;
@optional
- (void)o_i_method:(NSInteger)i;
+ (void)o_c_method:(NSInteger)i;
@end

@protocol IProtocolA <IProtocol>
@required
- (void)r_i_method1:(NSInteger)i;
- (void)r_i_method2:(NSInteger)i;
+ (void)r_c_method1:(NSInteger)i;
+ (void)r_c_method2:(NSInteger)i;
@optional
- (void)o_i_method1:(NSInteger)i;
- (void)o_i_method2:(NSInteger)i;
+ (void)o_c_method1:(NSInteger)i;
+ (void)o_c_method2:(NSInteger)i;
@end

@interface ClassA : NSObject<IProtocolA>
@end
@implementation ClassA
- (void)r_i_method:(NSInteger)i{}
+ (void)r_c_method:(NSInteger)i{}
- (void)o_i_method:(NSInteger)i{}
+ (void)o_c_method:(NSInteger)i{}
- (void)r_i_method1:(NSInteger)i{}
- (void)r_i_method2:(NSInteger)i{}
+ (void)r_c_method1:(NSInteger)i{}
+ (void)r_c_method2:(NSInteger)i{}
- (void)o_i_method1:(NSInteger)i{}
- (void)o_i_method2:(NSInteger)i{}
+ (void)o_c_method1:(NSInteger)i{}
+ (void)o_c_method2:(NSInteger)i{}
@end

@interface ClassB : NSObject<IProtocolA>
@end
@implementation ClassB
- (void)r_i_method:(NSInteger)i{}
+ (void)r_c_method:(NSInteger)i{}
- (void)o_i_method:(NSInteger)i{}
+ (void)o_c_method:(NSInteger)i{}
- (void)r_i_method1:(NSInteger)i{}
//- (void)r_i_method2:(NSInteger)i{}
+ (void)r_c_method1:(NSInteger)i{}
+ (void)r_c_method2:(NSInteger)i{}
- (void)o_i_method1:(NSInteger)i{}
- (void)o_i_method2:(NSInteger)i{}
+ (void)o_c_method1:(NSInteger)i{}
+ (void)o_c_method2:(NSInteger)i{}
@end

@interface ClassC : NSObject<IProtocolA>
@end
@implementation ClassC
- (void)r_i_method:(NSInteger)i{}
+ (void)r_c_method:(NSInteger)i{}
- (void)o_i_method:(NSInteger)i{}
+ (void)o_c_method:(NSInteger)i{}
- (void)r_i_method1:(NSInteger)i{}
- (void)r_i_method2:(NSInteger)i{}
+ (void)r_c_method1:(NSInteger)i{}
//+ (void)r_c_method2:(NSInteger)i{}
- (void)o_i_method1:(NSInteger)i{}
- (void)o_i_method2:(NSInteger)i{}
+ (void)o_c_method1:(NSInteger)i{}
+ (void)o_c_method2:(NSInteger)i{}
@end

@interface ClassD : NSObject<IProtocolA>
@end
@implementation ClassD
- (void)r_i_method:(NSInteger)i{}
+ (void)r_c_method:(NSInteger)i{}
- (void)o_i_method:(NSInteger)i{}
+ (void)o_c_method:(NSInteger)i{}
- (void)r_i_method1:(NSInteger)i{}
- (void)r_i_method2:(NSInteger)i{}
+ (void)r_c_method1:(NSInteger)i{}
+ (void)r_c_method2:(NSInteger)i{}
- (void)o_i_method1:(NSInteger)i{}
//- (void)o_i_method2:(NSInteger)i{}
+ (void)o_c_method1:(NSInteger)i{}
+ (void)o_c_method2:(NSInteger)i{}
@end

@interface ClassE : NSObject<IProtocolA>
@end
@implementation ClassE
- (void)r_i_method:(NSInteger)i{}
+ (void)r_c_method:(NSInteger)i{}
- (void)o_i_method:(NSInteger)i{}
+ (void)o_c_method:(NSInteger)i{}
- (void)r_i_method1:(NSInteger)i{}
- (void)r_i_method2:(NSInteger)i{}
+ (void)r_c_method1:(NSInteger)i{}
+ (void)r_c_method2:(NSInteger)i{}
- (void)o_i_method1:(NSInteger)i{}
- (void)o_i_method2:(NSInteger)i{}
+ (void)o_c_method1:(NSInteger)i{}
//+ (void)o_c_method2:(NSInteger)i{}
@end

@interface ClassF : NSObject<IProtocolA>
@end
@implementation ClassF
//- (void)r_i_method:(NSInteger)i{}
+ (void)r_c_method:(NSInteger)i{}
- (void)o_i_method:(NSInteger)i{}
+ (void)o_c_method:(NSInteger)i{}
- (void)r_i_method1:(NSInteger)i{}
- (void)r_i_method2:(NSInteger)i{}
+ (void)r_c_method1:(NSInteger)i{}
+ (void)r_c_method2:(NSInteger)i{}
- (void)o_i_method1:(NSInteger)i{}
- (void)o_i_method2:(NSInteger)i{}
+ (void)o_c_method1:(NSInteger)i{}
+ (void)o_c_method2:(NSInteger)i{}
@end

@interface ClassG : NSObject<IProtocolA>
@end
@implementation ClassG
- (void)r_i_method:(NSInteger)i{}
//+ (void)r_c_method:(NSInteger)i{}
- (void)o_i_method:(NSInteger)i{}
+ (void)o_c_method:(NSInteger)i{}
- (void)r_i_method1:(NSInteger)i{}
- (void)r_i_method2:(NSInteger)i{}
+ (void)r_c_method1:(NSInteger)i{}
+ (void)r_c_method2:(NSInteger)i{}
- (void)o_i_method1:(NSInteger)i{}
- (void)o_i_method2:(NSInteger)i{}
+ (void)o_c_method1:(NSInteger)i{}
+ (void)o_c_method2:(NSInteger)i{}
@end

@interface ClassH : NSObject<IProtocolA>
@end
@implementation ClassH
- (void)r_i_method:(NSInteger)i{}
+ (void)r_c_method:(NSInteger)i{}
//- (void)o_i_method:(NSInteger)i{}
+ (void)o_c_method:(NSInteger)i{}
- (void)r_i_method1:(NSInteger)i{}
- (void)r_i_method2:(NSInteger)i{}
+ (void)r_c_method1:(NSInteger)i{}
+ (void)r_c_method2:(NSInteger)i{}
- (void)o_i_method1:(NSInteger)i{}
- (void)o_i_method2:(NSInteger)i{}
+ (void)o_c_method1:(NSInteger)i{}
+ (void)o_c_method2:(NSInteger)i{}
@end

@interface ClassI : NSObject<IProtocolA>
@end
@implementation ClassI
- (void)r_i_method:(NSInteger)i{}
+ (void)r_c_method:(NSInteger)i{}
- (void)o_i_method:(NSInteger)i{}
//+ (void)o_c_method:(NSInteger)i{}
- (void)r_i_method1:(NSInteger)i{}
- (void)r_i_method2:(NSInteger)i{}
+ (void)r_c_method1:(NSInteger)i{}
+ (void)r_c_method2:(NSInteger)i{}
- (void)o_i_method1:(NSInteger)i{}
- (void)o_i_method2:(NSInteger)i{}
+ (void)o_c_method1:(NSInteger)i{}
+ (void)o_c_method2:(NSInteger)i{}
@end

@interface ClassJ : NSObject<IProtocolA>
@end
@implementation ClassJ
@end

@interface ATRuntimeUtilsTest : XCTestCase

@end

@implementation ATRuntimeUtilsTest

- (void)setUp {
    ;
}

- (void)tearDown {
    ;
}

- (void)testExample {
    XCTAssert([ATRuntimeUtils fastDetectInstance:[ClassA new] protocol:@protocol(IProtocolA)]);
    XCTAssert(![ATRuntimeUtils fastDetectInstance:[ClassB new] protocol:@protocol(IProtocolA)]);
    XCTAssert(![ATRuntimeUtils fastDetectInstance:[ClassC new] protocol:@protocol(IProtocolA)]);
    XCTAssert([ATRuntimeUtils fastDetectInstance:[ClassD new] protocol:@protocol(IProtocolA)]);
    XCTAssert([ATRuntimeUtils fastDetectInstance:[ClassE new] protocol:@protocol(IProtocolA)]);
    XCTAssert(![ATRuntimeUtils fastDetectInstance:[ClassF new] protocol:@protocol(IProtocolA)]);
    XCTAssert(![ATRuntimeUtils fastDetectInstance:[ClassG new] protocol:@protocol(IProtocolA)]);
    XCTAssert([ATRuntimeUtils fastDetectInstance:[ClassH new] protocol:@protocol(IProtocolA)]);
    XCTAssert([ATRuntimeUtils fastDetectInstance:[ClassI new] protocol:@protocol(IProtocolA)]);
    
    XCTAssert([ATRuntimeUtils fastDetectClass:[ClassA class] protocol:@protocol(IProtocolA)]);
    XCTAssert(![ATRuntimeUtils fastDetectClass:[ClassB class] protocol:@protocol(IProtocolA)]);
    XCTAssert(![ATRuntimeUtils fastDetectClass:[ClassC class] protocol:@protocol(IProtocolA)]);
    XCTAssert([ATRuntimeUtils fastDetectClass:[ClassD class] protocol:@protocol(IProtocolA)]);
    XCTAssert([ATRuntimeUtils fastDetectClass:[ClassE class] protocol:@protocol(IProtocolA)]);
    XCTAssert(![ATRuntimeUtils fastDetectClass:[ClassF class] protocol:@protocol(IProtocolA)]);
    XCTAssert(![ATRuntimeUtils fastDetectClass:[ClassG class] protocol:@protocol(IProtocolA)]);
    XCTAssert([ATRuntimeUtils fastDetectClass:[ClassH class] protocol:@protocol(IProtocolA)]);
    XCTAssert([ATRuntimeUtils fastDetectClass:[ClassI class] protocol:@protocol(IProtocolA)]);
    
    NSArray *tmp = [NSArray new];
    [ATRuntimeUtils detectInstance:[ClassA new] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 0);
    [ATRuntimeUtils detectInstance:[ClassB new] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 1 && [tmp.firstObject isEqualToString:@"r_i_method2:"]);
    [ATRuntimeUtils detectInstance:[ClassC new] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 1 && [tmp.firstObject isEqualToString:@"r_c_method2:"]);
    [ATRuntimeUtils detectInstance:[ClassD new] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 0);
    [ATRuntimeUtils detectInstance:[ClassE new] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 0);
    [ATRuntimeUtils detectInstance:[ClassF new] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 1 && [tmp.firstObject isEqualToString:@"r_i_method:"]);
    [ATRuntimeUtils detectInstance:[ClassG new] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 1 && [tmp.firstObject isEqualToString:@"r_c_method:"]);
    [ATRuntimeUtils detectInstance:[ClassH new] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 0);
    [ATRuntimeUtils detectInstance:[ClassI new] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 0);
    [ATRuntimeUtils detectInstance:[ClassJ new] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 6);
    
    [ATRuntimeUtils detectClass:[ClassA class] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 0);
    [ATRuntimeUtils detectClass:[ClassB class] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 1 && [tmp.firstObject isEqualToString:@"r_i_method2:"]);
    [ATRuntimeUtils detectClass:[ClassC class] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 1 && [tmp.firstObject isEqualToString:@"r_c_method2:"]);
    [ATRuntimeUtils detectClass:[ClassD class] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 0);
    [ATRuntimeUtils detectClass:[ClassE class] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 0);
    [ATRuntimeUtils detectClass:[ClassF class] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 1 && [tmp.firstObject isEqualToString:@"r_i_method:"]);
    [ATRuntimeUtils detectClass:[ClassG class] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 1 && [tmp.firstObject isEqualToString:@"r_c_method:"]);
    [ATRuntimeUtils detectClass:[ClassH class] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 0);
    [ATRuntimeUtils detectClass:[ClassI class] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 0);
    [ATRuntimeUtils detectClass:[ClassJ class] protocol:@protocol(IProtocolA) unRespondsMethods:&tmp];
    XCTAssert(tmp.count == 6);
}

@end
