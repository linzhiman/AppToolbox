//
//  ViewController.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2020/5/21.
//  Copyright © 2020 AppToolbox. All rights reserved.
//

#import "ViewController.h"

typedef NS_ENUM(NSUInteger, ATDemoCellType) {
    ATDemoCellTypeDefault,
    ATDemoCellTypeSwitch
};

typedef NS_ENUM(NSUInteger, ATDemoSectionType) {
    ATDemoSectionTypeUtils,
    ATDemoSectionTypeUI,
    ATDemoSectionTypeEnd
};

typedef void (^ATSwitchChangeCallback)(BOOL isON);


@interface ATDemoConfig : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) ATDemoCellType type;
@property (nonatomic, assign) ATDemoSectionType sectionType;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, copy) dispatch_block_t clickCallback;
@property (nonatomic, copy) ATSwitchChangeCallback switchChangedCallback;

@end

@implementation ATDemoConfig

@end


@interface ATDemoCell : UITableViewCell

@property (nonatomic, strong) ATDemoConfig *model;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UISwitch *switchView;

@end

@implementation ATDemoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_switchView addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_label];
        [self.contentView addSubview:_switchView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _label.frame = CGRectMake(20, 5, self.contentView.bounds.size.width - 100, CGRectGetHeight(self.contentView.bounds));
    _switchView.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - 60, 5, 40, CGRectGetHeight(self.contentView.bounds));
}

- (void)setContent:(ATDemoConfig *)model
{
    _model = model;
    
    _label.text = model.title;
    
    _switchView.hidden = YES;
    if (model.type == ATDemoCellTypeSwitch) {
        _switchView.hidden = NO;
        [_switchView setOn:model.isOn animated:NO];
    }
}

- (void)onSwitchChanged:(UISwitch *)switchView
{
    AT_SAFETY_CALL_BLOCK(self.model.switchChangedCallback, switchView.on);
}

@end

static NSString * const ATDemoCellIdentifier = @"ATDemoCellIdentifier";

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *sectionTitleArray;
@property (nonatomic, strong) NSMutableArray *sectionList;
@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation ViewController

- (void)viewDidLoad
{
#define BEGIN_BIND_SECTION() self.sectionTitleArray = @{
    
#define BIND_SECTION_TITLE(__SECTION_TYPE__, __SECTION_TITLE__) @(__SECTION_TYPE__):__SECTION_TITLE__
    
#define END_BIND_SECTION() };

    [super viewDidLoad];
    
    self.title = @"AppToolbox-Demo";
    
    BEGIN_BIND_SECTION()
    
    BIND_SECTION_TITLE(ATDemoSectionTypeUtils, @"Utils"),
    BIND_SECTION_TITLE(ATDemoSectionTypeUI, @"UI"),
    
    END_BIND_SECTION()
    
    [self initData];
    [self initViews];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (void)initData
{
    _dataList = [NSMutableArray new];
    
    AT_WEAKIFY_SELF;

    NSArray<DemoItem *> *demoArray = [DemoManager defaultManager].demoArray;
    for (DemoItem *item in demoArray) {
        ATDemoSectionType type = ATDemoSectionTypeUtils;
        if ([item.section isEqualToString:@"UI"]) {
            type = ATDemoSectionTypeUI;
        }
        [self addItem:item.title inSectionType:type clickCallback:^{
            if ([item.aClass isSubclassOfClass:UIViewController.class]) {
                [weak_self.navigationController pushViewController:[item.aClass new] animated:YES];
            }
            else {
                ;;
            }
        }];
    }
    
    [self makeSectionList];
}

- (void)initViews
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[ATDemoCell class] forCellReuseIdentifier:ATDemoCellIdentifier];
    self.tableView = tableView;
    [self.view addSubview:tableView];
}

- (ATDemoConfig *)addItem:(NSString *)title inSectionType:(ATDemoSectionType)sectionType clickCallback:(dispatch_block_t)callback
{
    ATDemoConfig *model = [ATDemoConfig new];
    model.title = title;
    model.type = ATDemoCellTypeDefault;
    model.sectionType = sectionType;
    model.clickCallback = callback;
    [_dataList addObject:model];
    return model;
}

- (ATDemoConfig *)addItem:(NSString *)title inSectionType:(ATDemoSectionType)sectionType switchCallback:(ATSwitchChangeCallback)callback
{
    ATDemoConfig *model = [ATDemoConfig new];
    model.title = title;
    model.type = ATDemoCellTypeSwitch;
    model.sectionType = sectionType;
    model.switchChangedCallback = callback;
    [_dataList addObject:model];
    return model;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_sectionList.count > 0) {
        return _sectionList.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_sectionList.count > 0) {
        NSArray *array = _sectionList[section];
        return array.count;
    }
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ATDemoConfig *model = nil;
    if (_sectionList.count > 0) {
        NSArray *array = _sectionList[indexPath.section];
        model = array[indexPath.row];
    }
    else {
        model = _dataList[indexPath.row];
    }
    ATDemoCell *cell = [tableView dequeueReusableCellWithIdentifier:ATDemoCellIdentifier forIndexPath:indexPath];
    [cell setContent:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ATDemoConfig *model = nil;
    if (_sectionList.count > 0) {
        NSArray *array = _sectionList[indexPath.section];
        model = array[indexPath.row];
    }
    else {
        model = _dataList[indexPath.row];
    }
    AT_SAFETY_CALL_BLOCK(model.clickCallback);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_sectionList.count > 0) {
        return 40;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor blueColor];
    UILabel *label = [UILabel new];
    if (section < self.sectionTitleArray.count) {
        label.text = self.sectionTitleArray[@(section)];
    }
    [view addSubview:label];
    label.frame = CGRectMake(20, 0, 200, 40);
    return view;
}

- (void)makeSectionList
{
    _sectionList = [[NSMutableArray alloc] init];
    for (NSUInteger i = ATDemoSectionTypeUtils; i < ATDemoSectionTypeEnd; i++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [_dataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ATDemoConfig *model = obj;
            if (model.sectionType == i) {
                [array addObject:model];
            }
        }];
        [_sectionList addObject:array];
    }
}

@end
