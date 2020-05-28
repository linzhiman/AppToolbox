//
//  ATWeakObject.m
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ATWeakObject.h"

@implementation ATWeakObject
{
    NSString *_objectKey;
}

+ (instancetype)objectWithTarget:(id)target
{
    return [ATWeakObject objectWithTarget:target userInfo:nil];
}

+ (instancetype)objectWithTarget:(id)target userInfo:(id _Nullable)userInfo
{
    ATWeakObject *tmp = [ATWeakObject new];
    tmp.target = target;
    tmp.userInfo = userInfo;
    return tmp;
}

+ (NSString *)objectKey:(id)target
{
    if (target != nil) {
        return [[NSString alloc] initWithFormat:@"%p", target];
    }
    return @"";
}

- (void)setTarget:(id)target
{
    _target = target;
    
    if (_target != nil) {
        _objectKey = [[NSString alloc] initWithFormat:@"%p", target];
    }
    else {
        _objectKey = @"";
    }
}

- (NSString *)objectKey
{
    return (_objectKey == nil ? @"" : _objectKey);
}

- (BOOL)isEqual:(ATWeakObject *)object
{
    if ([self.objectKey isEqual:object.objectKey]) {
        return YES;
    }
    return [self.target isEqual:object.target];
}

- (NSUInteger)hash
{
    return [self.target hash];
}

@end
