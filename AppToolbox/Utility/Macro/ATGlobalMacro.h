//
//  ATGlobalMacro.h
//  AppToolbox
//
//  Created by linzhiman on 2019/4/24.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AT_STRING_FROM_OBJECT_NAME(atName) @#atName

//NSString

#define AT_STRING_DEFINE(atName) \
    AT_STRING_DEFINE_VALUE(atName, @#atName)

#define AT_STRING_DEFINE_VALUE(atName, atValue) \
    NSString * const atName = atValue;

#define AT_STRING_EXTERN(atName) \
    extern NSString * const atName;

//Notification

#define AT_DECLARE_NOTIFICATION(atName) \
    NSString * const atName = @#atName;
#define AT_EXTERN_NOTIFICATION(atName) \
    extern NSString * const atName;

#define AT_POST_NOTIFICATION(atName) \
    [ATNotificationUtils postNotificationName:atName object:self];
#define AT_POST_NOTIFICATION_USERINFO(atName, atUserInfo) \
    [ATNotificationUtils postNotificationName:atName object:self userInfo:atUserInfo];
#define AT_REMOVE_NOTIFICATION \
    [AT_NOTIFICATION_SIGNALTON removeObserver:self];

//Singleton

#define AT_DECLARE_SINGLETON \
+ (instancetype)sharedObject;

#define AT_IMPLEMENT_SINGLETON(atType) \
+ (instancetype)sharedObject { \
    static dispatch_once_t __once; \
    static atType *__instance = nil; \
    dispatch_once(&__once, ^{ \
        __instance = [[atType alloc] init]; \
    }); \
    return __instance; \
}

#define AT_WEAKIFY_SELF __weak __typeof(self) weak_self = self;
#define AT_STRONGIFY_SELF __strong __typeof(self) self = weak_self;
#define AT_ENSURE_WEAKSELF_AND_STRONGIFY_SELF \
    if (!weak_self) { return; } \
    __strong __typeof(self) self = weak_self;

//Block

#define AT_SAFETY_CALL_BLOCK(atBlock, ...) if((atBlock)) { atBlock(__VA_ARGS__); }

//Parameter

#define metamacro_concat_(A, B) A##B
#define metamacro_concat(A, B) metamacro_concat_(A, B)

#define metamacro_head_(FIRST, ...) FIRST
#define metamacro_head(...) metamacro_head_(__VA_ARGS__, 0)

#define metamacro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) metamacro_head(__VA_ARGS__)

#define metamacro_at(N, ...) \
    metamacro_concat(metamacro_at, N)(__VA_ARGS__)

#define metamacro_argcount(...) \
    metamacro_at(20, ##__VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)

#define AT_MAKE_ARG_0(placeholder, ...) placeholder()
#define AT_MAKE_ARG_2(placeholder, separate, handler, first, second) handler(first, second)
#define AT_MAKE_ARG_4(placeholder, separate, handler, first, second, ...) \
    AT_MAKE_ARG_2(placeholder, separate, handler, first, second) separate() AT_MAKE_ARG_2(placeholder, separate, handler, __VA_ARGS__)
#define AT_MAKE_ARG_6(placeholder, separate, handler, first, second, ...) \
    AT_MAKE_ARG_2(placeholder, separate, handler, first, second) separate() AT_MAKE_ARG_4(placeholder, separate, handler, __VA_ARGS__)
#define AT_MAKE_ARG_8(placeholder, separate, handler, first, second, ...) \
    AT_MAKE_ARG_2(placeholder, separate, handler, first, second) separate() AT_MAKE_ARG_6(placeholder, separate, handler, __VA_ARGS__)
#define AT_MAKE_ARG_10(placeholder, separate, handler, first, second, ...) \
    AT_MAKE_ARG_2(placeholder, separate, handler, first, second) separate() AT_MAKE_ARG_8(placeholder, separate, handler, __VA_ARGS__)
#define AT_MAKE_ARG_12(placeholder, separate, handler, first, second, ...) \
    AT_MAKE_ARG_2(placeholder, separate, handler, first, second) separate() AT_MAKE_ARG_10(placeholder, separate, handler, __VA_ARGS__)
#define AT_MAKE_ARG_14(placeholder, separate, handler, first, second, ...) \
    AT_MAKE_ARG_2(placeholder, separate, handler, first, second) separate() AT_MAKE_ARG_12(placeholder, separate, handler, __VA_ARGS__)
#define AT_MAKE_ARG_16(placeholder, separate, handler, first, second, ...) \
    AT_MAKE_ARG_2(placeholder, separate, handler, first, second) separate() AT_MAKE_ARG_14(placeholder, separate, handler, __VA_ARGS__)

#define AT_MAKE_ARG_VOID() void
#define AT_MAKE_ARG_COMMA() ,
#define AT_MAKE_ARG_SPACE()

// 奇数位参数列表 (a, b, c, d)->(a, c) [int, a, bool, b -> int, bool]
#define AT_ODD_ARGS_HANDLER(first, second) first
#define AT_ODD_ARGS_(...) metamacro_concat(AT_MAKE_ARG_, metamacro_argcount(__VA_ARGS__))(AT_MAKE_ARG_SPACE, AT_MAKE_ARG_COMMA, AT_ODD_ARGS_HANDLER, __VA_ARGS__)
#define AT_ODD_ARGS(...) AT_ODD_ARGS_(__VA_ARGS__)

// 偶数位参数列表 (a, b, c, d)->(b, d) [int, a, bool, b -> a, b]
#define AT_EVEN_ARGS_HANDLER(first, second) second
#define AT_EVEN_ARGS_(...) metamacro_concat(AT_MAKE_ARG_, metamacro_argcount(__VA_ARGS__))(AT_MAKE_ARG_SPACE, AT_MAKE_ARG_COMMA, AT_EVEN_ARGS_HANDLER, __VA_ARGS__)
#define AT_EVEN_ARGS(...) AT_EVEN_ARGS_(__VA_ARGS__)

// 两个一组连接 (a, b, c, d)->(a b, c d) [int, a, bool, b -> int a, bool b]
#define AT_PAIR_CONCAT_ARGS_HANDLER(first, second) first second
#define AT_PAIR_CONCAT_ARGS_(...) metamacro_concat(AT_MAKE_ARG_, metamacro_argcount(__VA_ARGS__))(AT_MAKE_ARG_VOID, AT_MAKE_ARG_COMMA, AT_PAIR_CONCAT_ARGS_HANDLER, __VA_ARGS__)
#define AT_PAIR_CONCAT_ARGS(...) AT_PAIR_CONCAT_ARGS_(__VA_ARGS__)

// selector参数声明 (a, b, c, d)->(b:(a)b d:(c)d) [int, a, bool, b -> a:(int)a b:(bool)b]
#define AT_SELECTOR_ARGS_HANDLER(first, second) second:(first)second
#define AT_SELECTOR_ARGS_(...) metamacro_concat(AT_MAKE_ARG_, metamacro_argcount(__VA_ARGS__))(AT_MAKE_ARG_SPACE, AT_MAKE_ARG_SPACE, AT_SELECTOR_ARGS_HANDLER, __VA_ARGS__)
#define AT_SELECTOR_ARGS(...) AT_SELECTOR_ARGS_(__VA_ARGS__)

// Property定义和赋值 -->
// Property
#define AT_PROPERTY_DECLARE_ASSIGN @property (nonatomic, assign)
#define AT_PROPERTY_DECLARE_STRONG @property (nonatomic, strong)
#define AT_PROPERTY_DECLARE_COPY   @property (nonatomic, copy)
// C Types
#define AT_PROPERTY_DECLARE_HANDLER_bool     AT_PROPERTY_DECLARE_ASSIGN bool
#define AT_PROPERTY_DECLARE_HANDLER_char     AT_PROPERTY_DECLARE_ASSIGN char
#define AT_PROPERTY_DECLARE_HANDLER_short    AT_PROPERTY_DECLARE_ASSIGN short
#define AT_PROPERTY_DECLARE_HANDLER_int      AT_PROPERTY_DECLARE_ASSIGN int
#define AT_PROPERTY_DECLARE_HANDLER_long     AT_PROPERTY_DECLARE_ASSIGN long
#define AT_PROPERTY_DECLARE_HANDLER_float    AT_PROPERTY_DECLARE_ASSIGN float
#define AT_PROPERTY_DECLARE_HANDLER_double   AT_PROPERTY_DECLARE_ASSIGN double
#define AT_PROPERTY_DECLARE_HANDLER_unsigned AT_PROPERTY_DECLARE_ASSIGN unsigned
#define AT_PROPERTY_DECLARE_HANDLER_int8_t   AT_PROPERTY_DECLARE_ASSIGN int8_t
#define AT_PROPERTY_DECLARE_HANDLER_int16_t  AT_PROPERTY_DECLARE_ASSIGN int16_t
#define AT_PROPERTY_DECLARE_HANDLER_int32_t  AT_PROPERTY_DECLARE_ASSIGN int32_t
#define AT_PROPERTY_DECLARE_HANDLER_int64_t  AT_PROPERTY_DECLARE_ASSIGN int64_t
#define AT_PROPERTY_DECLARE_HANDLER_uint8_t  AT_PROPERTY_DECLARE_ASSIGN uint8_t
#define AT_PROPERTY_DECLARE_HANDLER_uint16_t AT_PROPERTY_DECLARE_ASSIGN uint16_t
#define AT_PROPERTY_DECLARE_HANDLER_uint32_t AT_PROPERTY_DECLARE_ASSIGN uint32_t
#define AT_PROPERTY_DECLARE_HANDLER_uint64_t AT_PROPERTY_DECLARE_ASSIGN uint64_t
// NS Types
#define AT_PROPERTY_DECLARE_HANDLER_BOOL             AT_PROPERTY_DECLARE_ASSIGN BOOL
#define AT_PROPERTY_DECLARE_HANDLER_Boolean          AT_PROPERTY_DECLARE_ASSIGN Boolean
#define AT_PROPERTY_DECLARE_HANDLER_NSInteger        AT_PROPERTY_DECLARE_ASSIGN NSInteger
#define AT_PROPERTY_DECLARE_HANDLER_NSUInteger       AT_PROPERTY_DECLARE_ASSIGN NSUInteger
#define AT_PROPERTY_DECLARE_HANDLER_NSTimeInterval   AT_PROPERTY_DECLARE_ASSIGN NSTimeInterval
#define AT_PROPERTY_DECLARE_HANDLER_CGFloat          AT_PROPERTY_DECLARE_ASSIGN CGFloat
#define AT_PROPERTY_DECLARE_HANDLER_CGSize           AT_PROPERTY_DECLARE_ASSIGN CGSize
#define AT_PROPERTY_DECLARE_HANDLER_CGRect           AT_PROPERTY_DECLARE_ASSIGN CGRect
#define AT_PROPERTY_DECLARE_HANDLER_Class            AT_PROPERTY_DECLARE_ASSIGN Class
#define AT_PROPERTY_DECLARE_HANDLER_SEL              AT_PROPERTY_DECLARE_ASSIGN SEL
#define AT_PROPERTY_DECLARE_HANDLER_IMP              AT_PROPERTY_DECLARE_ASSIGN IMP
// NS class
#define AT_PROPERTY_DECLARE_HANDLER_id                   AT_PROPERTY_DECLARE_STRONG id
#define AT_PROPERTY_DECLARE_HANDLER_NSObject             AT_PROPERTY_DECLARE_STRONG NSObject
#define AT_PROPERTY_DECLARE_HANDLER_NSString             AT_PROPERTY_DECLARE_COPY   NSString
#define AT_PROPERTY_DECLARE_HANDLER_NSMutableString      AT_PROPERTY_DECLARE_COPY   NSMutableString
#define AT_PROPERTY_DECLARE_HANDLER_NSValue              AT_PROPERTY_DECLARE_STRONG NSValue
#define AT_PROPERTY_DECLARE_HANDLER_NSNumber             AT_PROPERTY_DECLARE_STRONG NSNumber
#define AT_PROPERTY_DECLARE_HANDLER_NSDecimalNumber      AT_PROPERTY_DECLARE_STRONG NSDecimalNumber
#define AT_PROPERTY_DECLARE_HANDLER_NSData               AT_PROPERTY_DECLARE_COPY   NSData
#define AT_PROPERTY_DECLARE_HANDLER_NSMutableData        AT_PROPERTY_DECLARE_COPY   NSMutableData
#define AT_PROPERTY_DECLARE_HANDLER_NSDate               AT_PROPERTY_DECLARE_STRONG NSDate
#define AT_PROPERTY_DECLARE_HANDLER_NSURL                AT_PROPERTY_DECLARE_STRONG NSURL
#define AT_PROPERTY_DECLARE_HANDLER_NSArray              AT_PROPERTY_DECLARE_COPY   NSArray
#define AT_PROPERTY_DECLARE_HANDLER_MutableArray         AT_PROPERTY_DECLARE_COPY   MutableArray
#define AT_PROPERTY_DECLARE_HANDLER_NSDictionary         AT_PROPERTY_DECLARE_COPY   NSDictionary
#define AT_PROPERTY_DECLARE_HANDLER_NSMutableDictionary  AT_PROPERTY_DECLARE_COPY   NSMutableDictionary
#define AT_PROPERTY_DECLARE_HANDLER_NSSet                AT_PROPERTY_DECLARE_COPY   NSSet
#define AT_PROPERTY_DECLARE_HANDLER_NSMutableSet         AT_PROPERTY_DECLARE_COPY   NSMutableSet
#define AT_PROPERTY_DECLARE_HANDLER_UIColor              AT_PROPERTY_DECLARE_STRONG UIColor
#define AT_PROPERTY_DECLARE_HANDLER_UIView               AT_PROPERTY_DECLARE_STRONG UIView

// 属性声明 (a, b, c, d)->(@property (nonatomic, [assign/strong/copy]) a b;@property (nonatomic, [assign/strong/copy]) a b;)
// [int, a, bool, b -> @property (nonatomic, assign) int b; @property (nonatomic, assign) bool b;]
#define AT_PROPERTY_DECLARE_HANDLER(first, second) metamacro_concat(AT_PROPERTY_DECLARE_HANDLER_, first)second;
#define AT_PROPERTY_DECLARE_(...) metamacro_concat(AT_MAKE_ARG_, metamacro_argcount(__VA_ARGS__))(AT_MAKE_ARG_SPACE, AT_MAKE_ARG_SPACE, AT_PROPERTY_DECLARE_HANDLER, __VA_ARGS__)
#define AT_PROPERTY_DECLARE(...) AT_PROPERTY_DECLARE_(__VA_ARGS__)

// 给obj的属性赋值 (a, b, c, d)->(obj.b = b; obj.d = d;) [int, a, bool, b -> obj.a = a; obj.b = b;]
#define AT_PROPERTY_SET_VALUE_HANDLER(first, second) obj.second = second;
#define AT_PROPERTY_SET_VALUE_(...) metamacro_concat(AT_MAKE_ARG_, metamacro_argcount(__VA_ARGS__))(AT_MAKE_ARG_SPACE, AT_MAKE_ARG_SPACE, AT_PROPERTY_SET_VALUE_HANDLER, __VA_ARGS__)
#define AT_PROPERTY_SET_VALUE(...) AT_PROPERTY_SET_VALUE_(__VA_ARGS__)

// Property定义和赋值 <--
