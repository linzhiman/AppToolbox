//
//  ATModuleManager.h
//  ATModuleManager
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

// 简单模块管理
// 通过identifier标识模块，支持分组

#define AT_ADD_MODULE_GROUP(atModuleManager, atModuleClass, atGroup) \
    [atModuleManager addModule:[[atModuleClass alloc] init] identifier:@#atModuleClass group:atGroup];

#define AT_ADD_MODULE(atModuleManager, atModuleClass) \
    AT_ADD_MODULE_GROUP(atModuleManager, atModuleClass, kATModuleDefaultGroup);

#define AT_REMOVE_MODULE_GROUP(atModuleManager, atModuleClass, atGroup) \
    [atModuleManager removeModuleWithIdentifier:@#atModuleClass group:atGroup];

#define AT_REMOVE_MODULE(atModuleManager, atModuleClass) \
    AT_REMOVE_MODULE_GROUP(atModuleManager, atModuleClass, kATModuleDefaultGroup);

#define AT_GET_MODULE(atModuleManager, atModuleClass) \
    ((atModuleClass *)[atModuleManager moduleWithIdentifier:@#atModuleClass])

#define AT_GET_MODULE_VARIABLE(atModuleManager, atModuleClass, atVariable) \
    atModuleClass *atVariable = (atModuleClass *)[atModuleManager moduleWithIdentifier:@#atModuleClass];

extern const NSInteger kATModuleDefaultGroup;
extern const NSInteger kATModuleGroup1;
extern const NSInteger kATModuleGroup2;

@interface ATModuleManager : NSObject

- (id)moduleWithIdentifier:(NSString *)identifier;

- (void)addModule:(id)module identifier:(NSString *)identifier;
- (void)addModule:(id)module identifier:(NSString *)identifier group:(NSInteger)group;

- (void)removeModuleWithIdentifier:(NSString *)identifier;
- (void)removeModuleWithIdentifier:(NSString *)identifier group:(NSInteger)group;

- (NSArray *)modulesInGroup:(NSInteger)group;

@end
