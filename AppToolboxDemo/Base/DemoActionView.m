//
//  DemoActionView.m
//  Demo
//
//  Created by linzhiman on 2022/5/20.
//

#import "DemoActionView.h"

@interface DemoAction : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) dispatch_block_t action;

+ (instancetype)actionWithTitle:(NSString *)title action:(dispatch_block_t)action;

@end

@implementation DemoAction

+ (instancetype)actionWithTitle:(NSString *)title action:(dispatch_block_t)action
{
    DemoAction *tmp = [DemoAction new];
    tmp.title = title;
    tmp.action = action;
    return tmp;
}

@end

@interface DemoActionViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *lineLabel;

@end

@implementation DemoActionViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _lineLabel = [[UILabel alloc] init];
        _lineLabel.font = [UIFont systemFontOfSize:12];
        _lineLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_lineLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect frame = self.contentView.bounds;
    frame.origin.x = 20;
    frame.size.width -= 40;
    self.lineLabel.frame = frame;
}

- (void)updateWithLine:(NSString *)line
{
    self.lineLabel.text = line;
}

@end

@interface DemoActionView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<DemoAction *> *actions;

@end

@implementation DemoActionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        _actions = [NSMutableArray new];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

- (void)addSubviews
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [tableView registerClass:[DemoActionViewCell class] forCellReuseIdentifier:@"DemoActionViewCell"];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:tableView];
    self.tableView = tableView;
    
    [tableView reloadData];
}

- (void)addActionTitle:(NSString *)title action:(dispatch_block_t)action
{
    [self.actions addObject:[DemoAction actionWithTitle:title action:action]];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DemoAction *tmp = self.actions[indexPath.row];
    DemoActionViewCell *cell = (DemoActionViewCell *)[tableView dequeueReusableCellWithIdentifier:@"DemoActionViewCell"];
    [cell updateWithLine:tmp.title];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DemoAction *tmp = self.actions[indexPath.row];
    AT_SAFETY_CALL_BLOCK(tmp.action);
}

@end
