//
//  NSArray+ATKit.h
//  ATKit
//
//  Created by linzhiman on 2019/5/5.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (ATKit)

- (ObjectType)at_objectAtIndex:(NSUInteger)index;
- (NSString *)at_stringAtIndex:(NSUInteger)index;
- (NSNumber *)at_numberAtIndex:(NSUInteger)index;
- (NSArray *)at_arrayAtIndex:(NSUInteger)index;


typedef BOOL (^ATArrayCompareBlock)(id obj1, id obj2);
typedef void (^ATArrayOperationBlock)(ObjectType obj);
typedef BOOL (^ATArrayFilterBlock)(ObjectType obj);

- (BOOL)at_containsObject:(id)object compare:(ATArrayCompareBlock)compare;
- (BOOL)at_containsObject:(id)object property:(NSString *)keyPath;

/*
 * 执行一次后，不会再遍历其它元素
 */
- (void)at_applay:(ATArrayOperationBlock)operation filter:(ATArrayFilterBlock)filter;

/*
 * 全部元素都会遍历一次，符合条件的会执行operation
 */
- (void)at_applayAll:(ATArrayOperationBlock)operation filter:(ATArrayFilterBlock)filter;

/*
 * 过滤重复元素，默认执行 isEqual 函数判断
 * 列表顺序不会改变
 */
- (NSArray *)at_distinctUnionArray;
- (NSArray *)at_distinctUnionArrayWithCompare:(ATArrayCompareBlock)compare;

#pragma mark - JSON

- (NSString *)at_JSONString;

@end

NS_ASSUME_NONNULL_END
