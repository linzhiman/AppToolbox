//
//  DemoManager.m
//  Demo
//
//  Created by linzhiman on 2022/7/12.
//

#import "DemoManager.h"

@implementation DemoItem

@end

@interface DemoManager ()

@property (nonatomic, strong) NSMutableArray *demos;

@end

@implementation DemoManager

+ (instancetype)defaultManager
{
    static DemoManager *aDemoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aDemoManager = [[DemoManager alloc] init];
    });
    return aDemoManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _demos = [NSMutableArray new];
    }
    return self;
}

- (void)addDemoTitle:(NSString *)title section:(NSString *)section priority:(NSInteger)priority aClass:(Class)aClass;
{
    DemoItem *item = [DemoItem new];
    item.title = title;
    item.section = section;
    item.priority = priority;
    item.aClass = aClass;
    [self.demos addObject:item];
}

- (NSArray<DemoItem *> *)demoArray
{
    [self.demos sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        DemoItem *base1 = (DemoItem *)obj1;
        DemoItem *base2 = (DemoItem *)obj2;
        return base1.priority > base2.priority;
    }];
    return self.demos;
}

@end
