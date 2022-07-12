//
//  DemoLogView.m
//  Demo
//
//  Created by linzhiman on 2022/5/20.
//

#import "DemoLogView.h"
#import <pthread.h>

NSDateFormatter *DemoLogSharedFormater(void)
{
    static NSDateFormatter *formater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formater = [[NSDateFormatter alloc] init];
        [formater setFormatterBehavior:NSDateFormatterBehavior10_4];
        [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
        [formater setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return formater;
}

NSString *DemoLogFormatMessage(NSString *text)
{
    NSString *threadId;
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        __uint64_t tid = 0;
        pthread_threadid_np(NULL, &tid);
        threadId = [[NSString alloc] initWithFormat:@"%llu", tid];
    }
    else {
        threadId = [[NSString alloc] initWithFormat:@"%x", pthread_mach_thread_np(pthread_self())];
    }
    
    NSString *timestamp = [DemoLogSharedFormater() stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%@ [%@] %@\n", timestamp, threadId, text];
}

@interface DemoLogViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *lineLabel;

@end

@implementation DemoLogViewCell

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
    self.lineLabel.frame = self.contentView.frame;
}

- (void)updateWithLine:(NSString *)line
{
    self.lineLabel.text = line;
}

@end

@interface DemoLogView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextView *detailView;

@property (nonatomic, strong) NSMutableArray<NSString *> *logLineArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *logCacheArray;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation DemoLogView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        _logLineArray = [NSMutableArray new];
        _logCacheArray = [NSMutableArray new];
        _queue = dispatch_queue_create("demo.log", DISPATCH_QUEUE_SERIAL);
        [self loadCacheLogRecursively];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    bounds.size.height -= 160;
    self.contentView.frame = bounds;
    bounds.size.width = SCREEN_WIDTH * 3;
    self.tableView.frame = bounds;
    self.detailView.frame = CGRectMake(0, CGRectGetMaxY(bounds), SCREEN_WIDTH, 160);
    
    self.contentView.contentSize = bounds.size;
}

- (void)addSubviews
{
    UIScrollView *contentView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    contentView.showsVerticalScrollIndicator = NO;
    contentView.showsHorizontalScrollIndicator = YES;
    contentView.bounces = NO;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [tableView registerClass:[DemoLogViewCell class] forCellReuseIdentifier:@"DemoLogViewCell"];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = UIColor.grayColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [contentView addSubview:tableView];
    self.tableView = tableView;
    
    UITextView *outputView = [[UITextView alloc] initWithFrame:CGRectZero];
    outputView.backgroundColor = [UIColor blackColor];
    outputView.textColor = [UIColor whiteColor];
    outputView.font = [UIFont systemFontOfSize:12];
    outputView.userInteractionEnabled = NO;
    [self addSubview:outputView];
    self.detailView = outputView;
    
    [tableView reloadData];
}

- (void)updateOutputText:(NSString *)text
{
    self.detailView.text = text;
}

- (void)appendLog:(NSString *)log
{
    NSString *text = DemoLogFormatMessage(log);
    
    AT_WEAKIFY_SELF;
    dispatch_async(_queue, ^{
        [weak_self.logCacheArray addObject:text];
    });
}

- (void)clearLog
{
    AT_WEAKIFY_SELF;
    dispatch_async(_queue, ^{
        [weak_self.logCacheArray removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weak_self.logLineArray removeAllObjects];
            [weak_self.tableView reloadData];
        });
    });
}

- (void)loadCacheLog
{
    AT_WEAKIFY_SELF;
    dispatch_async(_queue, ^{
        if (weak_self.logCacheArray.count > 0) {
            NSMutableArray *logCacheArray = weak_self.logCacheArray;
            weak_self.logCacheArray = [NSMutableArray new];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weak_self.logLineArray addObjectsFromArray:logCacheArray];
                [weak_self.tableView reloadData];
                [weak_self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weak_self.logLineArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            });
        }
    });
}

- (void)loadCacheLogRecursively
{
    AT_WEAKIFY_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [weak_self loadCacheLog];
        [weak_self loadCacheLogRecursively];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logLineArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *line = self.logLineArray[indexPath.row];
    DemoLogViewCell *cell = (DemoLogViewCell *)[tableView dequeueReusableCellWithIdentifier:@"DemoLogViewCell"];
    [cell updateWithLine:line];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *line = self.logLineArray[indexPath.row];
    [self updateOutputText:line];
}

@end
