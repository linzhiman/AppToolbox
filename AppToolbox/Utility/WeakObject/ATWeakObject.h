//
//  ATWeakObject.h
//  ATKit
//
//  Created by linzhiman on 2019/4/24.
//  Copyright © 2019 linzhiman. All rights reserved.
//

#import <Foundation/Foundation.h>

// 强引用转为弱引用，一般用于将对象放入容器，且不希望容器强引用对象的场景

NS_ASSUME_NONNULL_BEGIN

@interface ATWeakObject : NSObject

- (NSString *)objectKey;

+ (NSString *)objectKey:(id)targetObj;

@property (nonatomic, weak) id target;

@property (nonatomic, strong) id extension;

@end

NS_ASSUME_NONNULL_END
