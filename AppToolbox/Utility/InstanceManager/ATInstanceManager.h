//
//  ATInstanceManager.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 对象管理类
 通过identifier标识和缓存对象，支持分组，不关心对象类型
 提供便利使用的宏，将identifier限定为对象的类名，使用者可以不关心identifier
 */

/// Add
#define AT_ADD_INSTANCE(atInstanceManager, atInstanceClass) \
    AT_ADD_INSTANCE_GROUP(atInstanceManager, atInstanceClass, kATInstanceDefaultGroup);

/// Remove
#define AT_REMOVE_INSTANCE(atInstanceManager, atInstanceClass) \
    AT_REMOVE_INSTANCE_GROUP(atInstanceManager, atInstanceClass, kATInstanceDefaultGroup);

/// Get
#define AT_GET_INSTANCE(atInstanceManager, atInstanceClass) \
    ((atInstanceClass *)[atInstanceManager instanceWithIdentifier:@#atInstanceClass])

/// Get with variable
#define AT_GET_INSTANCE_VARIABLE(atInstanceManager, atInstanceClass, atVariable) \
    atInstanceClass *atVariable = (atInstanceClass *)[atInstanceManager instanceWithIdentifier:@#atInstanceClass];

/// Add with group
#define AT_ADD_INSTANCE_GROUP(atInstanceManager, atInstanceClass, atGroup) \
    [atInstanceManager addInstance:[[atInstanceClass alloc] init] identifier:@#atInstanceClass group:atGroup];

/// Remove with group
#define AT_REMOVE_INSTANCE_GROUP(atInstanceManager, atInstanceClass, atGroup) \
    [atInstanceManager removeInstanceWithIdentifier:@#atInstanceClass group:atGroup];

NS_ASSUME_NONNULL_BEGIN

extern const NSInteger kATInstanceDefaultGroup;
extern const NSInteger kATInstanceGroup1;
extern const NSInteger kATInstanceGroup2;

@interface ATInstanceManager : NSObject

- (id _Nullable)instanceWithIdentifier:(NSString *)identifier;

- (void)addInstance:(id)instance identifier:(NSString *)identifier;
- (void)addInstance:(id)instance identifier:(NSString *)identifier group:(NSInteger)group;

- (void)removeInstanceWithIdentifier:(NSString *)identifier;
- (void)removeInstanceWithIdentifier:(NSString *)identifier group:(NSInteger)group;

- (NSArray * _Nullable)instancesInGroup:(NSInteger)group;

@end

NS_ASSUME_NONNULL_END
