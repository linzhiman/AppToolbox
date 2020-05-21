//
//  NSArray+AppToolbox.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "NSArray+AppToolbox.h"

id ATArraySafeGet(NSArray *array, Class cls, NSUInteger index)
{
    if (index >= array.count) {
        return nil;
    }
    
    id obj = [array objectAtIndex:index];
    if ([obj isKindOfClass:cls]) {
        return obj;
    }
    
    return nil;
}

@implementation NSArray (AppToolbox)

- (id)at_objectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    return nil;
}

- (NSString *)at_stringAtIndex:(NSUInteger)index
{
    return ATArraySafeGet(self, [NSString class], index);
}

- (NSNumber *)at_numberAtIndex:(NSUInteger)index
{
    return ATArraySafeGet(self, [NSNumber class], index);
}

- (NSArray *)at_arrayAtIndex:(NSUInteger)index
{
    return ATArraySafeGet(self, [NSArray class], index);
}

- (BOOL)at_containsObject:(id)object compare:(ATArrayCompareBlock)compare
{
    if (compare == nil) {
        return [self containsObject:object];
    }
    
    for (id obj in self) {
        if (obj == object) {
            return YES;
        }
        
        if (compare(obj, object)) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)at_containsObject:(id)object property:(NSString *)keyPath
{
    for (id obj in self) {
        if (object == obj) {
            return YES;
        }
        
        if ([[object valueForKeyPath:keyPath] isEqual:[obj valueForKeyPath:keyPath]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)at_applay:(ATArrayOperationBlock)operation filter:(ATArrayFilterBlock)filter
{
    for (id obj in self) {
        if (filter(obj)) {
            operation(obj);
            return;
        }
    }
}

- (void)at_applayAll:(ATArrayOperationBlock)operation filter:(ATArrayFilterBlock)filter
{
    for (id obj in self) {
        if (filter(obj)) {
            operation(obj);
        }
    }
}

- (NSArray *)at_distinctUnionArray
{
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:self.count];
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id obj in self) {
        if (![set containsObject:obj]) {
            [set addObject:obj];
            [resultArray addObject:obj];
        }
    }
    return [NSArray arrayWithArray:resultArray];
}

- (NSArray *)at_distinctUnionArrayWithCompare:(ATArrayCompareBlock)compare
{
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id obj in self) {
        for (id resultObj in resultArray) {
            if (!compare(resultObj, obj)) {
                [resultArray addObject:obj];
            }
            else {
                continue;
            }
        }
    }
    return [NSArray arrayWithArray:resultArray];
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

@end
