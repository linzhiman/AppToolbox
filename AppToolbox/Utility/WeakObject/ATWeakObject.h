//
//  ATWeakObject.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 强引用转为弱引用
 一般用于将对象放入容器，且不希望容器强引用对象的场景
*/

NS_ASSUME_NONNULL_BEGIN

@interface ATWeakObject : NSObject

+ (instancetype)objectWithTarget:(id)target;
+ (instancetype)objectWithTarget:(id)target userInfo:(id _Nullable)userInfo;

+ (NSString *)objectKey:(id)target;

@property (nonatomic, weak) id target;
@property (nonatomic, strong) id userInfo;

- (NSString *)objectKey;

@end

NS_ASSUME_NONNULL_END
