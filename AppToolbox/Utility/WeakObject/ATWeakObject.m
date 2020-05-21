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

- (BOOL)isEqual:(ATWeakObject *)object
{
    if ([self.objectKey isEqual:object.objectKey]) {
        return YES;
    }
    return [self.target isEqual:object.target];
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

+ (NSString *)objectKey:(id)targetObj
{
    if (targetObj != nil) {
        return [[NSString alloc] initWithFormat:@"%p", targetObj];
    }
    return @"";
}

- (NSUInteger)hash
{
    return [self.target hash];
}

@end
