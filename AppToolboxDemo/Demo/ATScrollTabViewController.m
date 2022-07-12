//
//  ATScrollTabViewController.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2022/4/2.
//  Copyright © 2022 AppToolbox. All rights reserved.
//

#import "ATScrollTabViewController.h"
#import "ATScrollTabView.h"
#import "ATWaterfallLayoutViewController.h"

@interface ATScrollTabViewController ()<ATScrollTabViewDelegate>

@property (nonatomic, strong) ATScrollTabView *scrollTabView;

@end

@implementation ATScrollTabViewController

+ (void)load
{
    REGISTER_UI_DEMO(@"ScrollTab", 400);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"ScrollTabView";
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    ATScrollTabStyle *style = [ATScrollTabStyle new];
    style.titleType = ATScrollTabTitleTypeFix;
    style.leftPadding = 12;
    style.rightPadding = 12;
    style.titleSpacing = 10;
    style.titleWidth = 50;
    style.titleHeight = 50;
    
    ATScrollTabView *scrollTabView = [[ATScrollTabView alloc] initWithFrame:CGRectZero tabStyle:style];
    scrollTabView.delegate = self;
    [self.view addSubview:scrollTabView];
    self.scrollTabView =  scrollTabView;
    
    NSArray *titles = @[@"社会主义核心价值观", @"富强", @"民主文明", @"和谐自由平等", @"公正法治爱国敬业", @"诚信友善"];
    UIViewController *content1 = [ATWaterfallLayoutViewController new];
    content1.view.backgroundColor = UIColor.redColor;
    UIViewController *content2 = [ATWaterfallLayoutViewController new];
    content2.view.backgroundColor = UIColor.blueColor;
    UIViewController *content3 = [ATWaterfallLayoutViewController new];
    content3.view.backgroundColor = UIColor.greenColor;
    UIViewController *content4 = [ATWaterfallLayoutViewController new];
    content4.view.backgroundColor = UIColor.grayColor;
    UIViewController *content5 = [ATWaterfallLayoutViewController new];
    content5.view.backgroundColor = UIColor.yellowColor;
    UIViewController *content6 = [ATWaterfallLayoutViewController new];
    content6.view.backgroundColor = UIColor.brownColor;
    NSArray *contents = @[content1, content2, content3, content4, content5, content6];
    [scrollTabView setTitles:titles contents:contents];
    
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 150)];
    headerView.image = [UIImage imageNamed:@"banner"];
    scrollTabView.headerView = headerView;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.scrollTabView.frame = self.view.bounds;
}

- (void)onScrollTabView:(ATScrollTabView *)scrollTabView selectedIndexChangedTo:(NSUInteger)index old:(NSUInteger)old
{
    NSLog(@"ATScrollTabViewController onScrollTabView index(%lu) old(%lu)", (unsigned long)index, (unsigned long)old);
}

@end
