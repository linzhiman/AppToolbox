//
//  DemoBaseViewController.m
//  Demo
//
//  Created by linzhiman on 2022/5/20.
//

#import "DemoBaseViewController.h"
#import "DemoActionView.h"
#import "DemoLogView.h"

#define DEMOLOG_FORMAT_LOG(LOG_NAME) \
va_list args = {0}; \
va_start(args, format); \
NSString *LOG_NAME = [[NSString alloc] initWithFormat:format arguments:args]; \
va_end(args);

@interface DemoBtnAction : NSObject

@property (nonatomic, weak) UIButton *btn;
@property (nonatomic, copy) dispatch_block_t action;

+ (instancetype)actionWithBtn:(UIButton *)btn action:(dispatch_block_t)action;

@end

@implementation DemoBtnAction

+ (instancetype)actionWithBtn:(UIButton *)btn action:(dispatch_block_t)action
{
    DemoBtnAction *tmp = [DemoBtnAction new];
    tmp.btn = btn;
    tmp.action = action;
    return tmp;
}

@end

@interface DemoBaseViewController ()

@property (nonatomic, strong) NSMutableArray<DemoBtnAction *> *btnActions;
@property (nonatomic, weak) DemoActionView *actionView;
@property (nonatomic, weak) DemoLogView *logView;

@end

@implementation DemoBaseViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _btnActions = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self createActionViewHeight:300];
    [self createLogViewHeight:500];
}

- (void)createBtnTitle:(NSString *)title action:(dispatch_block_t)action
{
    NSUInteger count = self.btnActions.count;
    CGFloat hSpace = 30;
    CGFloat vSpace = 30;
    CGFloat width = SCREEN_WIDTH / 2 - hSpace * 2;
    CGFloat height = 30;
    CGFloat left = count % 2 == 0 ? hSpace : width + hSpace * 2;
    CGFloat top = count / 2 * (height + vSpace) + 100;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(left, top, width, height)];
    btn.backgroundColor = UIColor.blueColor;
    btn.layer.cornerRadius = 8;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self.btnActions addObject:[DemoBtnAction actionWithBtn:btn action:action]];
}

- (void)createActionViewHeight:(CGFloat)height;
{
    DemoActionView *actionView = [[DemoActionView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, height)];
    [self.view addSubview:actionView];
    self.actionView = actionView;
}

- (void)addAction:(NSString *)title action:(dispatch_block_t)action
{
    [self.actionView addActionTitle:title action:action];
}

- (void)createLogViewHeight:(CGFloat)height
{
    DemoLogView *logView = [[DemoLogView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - height, SCREEN_WIDTH, height)];
    logView.backgroundColor = UIColor.grayColor;
    [self.view addSubview:logView];
    self.logView = logView;
}

- (void)log:(NSString *)format, ...NS_FORMAT_FUNCTION(1,2)
{
    DEMOLOG_FORMAT_LOG(log);
    [self.logView appendLog:log];
}

- (void)clearLog
{
    [self.logView clearLog];
}

- (void)onBtnClicked:(UIButton *)sender
{
    for (DemoBtnAction *tmp in self.btnActions) {
        if (tmp.btn == sender) {
            AT_SAFETY_CALL_BLOCK(tmp.action);
        }
    }
}

@end
