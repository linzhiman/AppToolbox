//
//  NSObject+AppToolbox.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (AppToolbox)

- (void)at_performSelector:(SEL)selector withObject:(id)object afterDelay:(NSTimeInterval)delay;
+ (void)at_cancelPreviousPerformRequestsWithTarget:(id)target selector:(SEL)selector;

- (id)at_getProperty:(NSString *)name;
- (void)at_setProperty:(id)property withName:(NSString *)name;
- (void)at_removeProperty:(NSString *)name;

- (id)at_associatedObject:(NSString *)key;
- (void)at_setAssociatedObject:(id)object key:(NSString *)key;
- (void)at_removeAssociatedObject:(NSString *)key;

- (void)at_addDelegate:(id)delegate;
- (void)at_removeDelegate:(id)delegate;
- (void)at_checkSelector:(SEL)selector callback:(void (^)(id delegate))callback;

@end

#define DEFINE_CATEGORY_PROPERTY_NUM(PType, PName, PSetter, PNumFun) \
- (PType)PName \
{ \
    NSNumber *tmp = [self at_associatedObject:@#PName]; \
    if (tmp != nil) { \
        return tmp.PNumFun; \
    } \
    return 0; \
} \
- (void)PSetter:(PType)PName \
{ \
    [self at_setAssociatedObject:@(PName) key:@#PName]; \
}

#define DEFINE_CATEGORY_PROPERTY_OBJ(PType, PName, PSetter) \
- (PType *)PName \
{ \
    return [self at_associatedObject:@#PName];; \
} \
- (void)PSetter:(PType *)PName \
{ \
    if (PName != nil) { \
        [self at_setAssociatedObject:PName key:@#PName]; \
    } \
}

NS_ASSUME_NONNULL_END
