//
//  ATGlobalMacro.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
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

// 属性声明 (a, b, c, d)->(@property (nonatomic) a b;@property (nonatomic) a b;)
// [int, a, bool, b -> @property (nonatomic) int a; @property (nonatomic) bool b;]
#define AT_PROPERTY_DECLARE_HANDLER(first, second) @property (nonatomic, assign) first second;
#define AT_PROPERTY_DECLARE_(...) metamacro_concat(AT_MAKE_ARG_, metamacro_argcount(__VA_ARGS__))(AT_MAKE_ARG_SPACE, AT_MAKE_ARG_SPACE, AT_PROPERTY_DECLARE_HANDLER, __VA_ARGS__)
#define AT_PROPERTY_DECLARE(...) AT_PROPERTY_DECLARE_(__VA_ARGS__)

// 给obj的属性赋值 (a, b, c, d)->(obj.b = b; obj.d = d;) [int, a, bool, b -> obj.a = a; obj.b = b;]
#define AT_PROPERTY_SET_VALUE_HANDLER(first, second) obj.second = second;
#define AT_PROPERTY_SET_VALUE_(...) metamacro_concat(AT_MAKE_ARG_, metamacro_argcount(__VA_ARGS__))(AT_MAKE_ARG_SPACE, AT_MAKE_ARG_SPACE, AT_PROPERTY_SET_VALUE_HANDLER, __VA_ARGS__)
#define AT_PROPERTY_SET_VALUE(...) AT_PROPERTY_SET_VALUE_(__VA_ARGS__)

// Property定义和赋值 <--
