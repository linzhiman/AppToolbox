//
//  DemoManager.h
//  Demo
//
//  Created by linzhiman on 2022/7/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *section;
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, strong) Class aClass;

@end

@interface DemoManager : NSObject

+ (instancetype)defaultManager;

- (void)addDemoTitle:(NSString *)title section:(NSString *)section priority:(NSInteger)priority aClass:(Class)aClass;

- (NSArray<DemoItem *> *)demoArray;

@end

#define REGISTER_DEMO(_title_, _section_, _priority_) \
[[DemoManager defaultManager] addDemoTitle:_title_ section:_section_ priority:_priority_ aClass:self.class];

#define REGISTER_UI_DEMO(_title_, _priority_) \
REGISTER_DEMO(_title_, @"UI", _priority_)

#define REGISTER_Utils_DEMO(_title_, _priority_) \
REGISTER_DEMO(_title_, @"Utils", _priority_)

NS_ASSUME_NONNULL_END
