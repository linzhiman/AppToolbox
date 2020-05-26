//
//  ATRuntimeUtils.h
//  AppToolbox
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATRuntimeUtils : NSObject

+ (BOOL)fastDetectInstance:(NSObject *)instance protocol:(Protocol *)protocol;
+ (BOOL)detectInstance:(NSObject *)instance protocol:(Protocol *)protocol
     unRespondsMethods:(NSArray * _Nullable * _Nullable)unRespondsMethods;

+ (BOOL)fastDetectClass:(Class)aClass protocol:(Protocol *)protocol;
+ (BOOL)detectClass:(Class)aClass protocol:(Protocol *)protocol
  unRespondsMethods:(NSArray * _Nullable * _Nullable)unRespondsMethods;

@end

NS_ASSUME_NONNULL_END
