//
//  ATRuntimeDemo.h
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/6/9.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATRuntimeDemo : NSObject

@property (nonatomic, assign) int propertyA;
@property (nonatomic, assign) int propertyB;
@property (nonatomic, strong) NSString *propertyC;

- (void)demo;

@end

NS_ASSUME_NONNULL_END
