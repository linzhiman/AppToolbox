//
//  ATScrollTabView.m
//  AppToolbox
//
//  Created by linzhiman on 2022/4/1.
//  Copyright © 2022 AppToolbox. All rights reserved.
//

#import "ATScrollTabView.h"
#import "UIView+ATFrame.h"
#import "NSString+AppToolbox.h"
#import "NSObject+AppToolbox.h"
#import "ATWeakObject.h"
#import <objc/runtime.h>

NSMutableDictionary<NSString *, ATWeakObject *> *at_scrollTabViewData(void)
{
    static NSMutableDictionary<NSString *, ATWeakObject *> *sData;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sData = [NSMutableDictionary new];
    });
    return sData;
}

@implementation ATScrollTabStyle

- (instancetype)init
{
    if (self = [super init]) {
        [self initStyle];
    }
    return self;
}

- (void)initStyle
{
    self.titleType = ATScrollTabTitleTypeFit;
    
    self.normalTitleColor = UIColor.grayColor;
    self.selectedTitleColor = UIColor.blackColor;
    
    self.normalTitleFont = [UIFont systemFontOfSize:11];
    self.selectedTitleFont = [UIFont systemFontOfSize:12];
    
    self.lineColor = UIColor.blueColor;
    
    self.lineWidth = 10;
    self.lineHeight = 3;
    self.lineYOffset = 3;
    
    self.titleSpacing = 10;
    self.titleHeight = 50;
}

@end


@interface ATScrollTabTitleView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray<UIButton *> *titleBtns;
@property (nonatomic, strong) UIView *selectedLine;

@property (nonatomic, strong) ATScrollTabStyle *tabStyle;
@property (nonatomic, assign) NSUInteger curIndex;
@property (nonatomic, strong) NSArray<NSString *> *titles;

@end

@implementation ATScrollTabTitleView

- (instancetype)initWithFrame:(CGRect)frame tabStyle:(ATScrollTabStyle *)tabStyle
{
    if (self = [super initWithFrame:frame]) {
        _tabStyle = tabStyle ?: [ATScrollTabStyle new];
        _curIndex = 0;
        [self addSubviews];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    
    if (self.titleBtns.count) {
        for (UIButton *titleBtn in self.titleBtns) {
            titleBtn.at_height = CGRectGetHeight(self.bounds);
        }
        [self updateLineFrame];
    }
}

- (void)addSubviews
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)setTitles:(NSArray<NSString *> *)titles
{
    _titles = titles;
    
    CGFloat left = self.tabStyle.leftPadding;
    CGFloat minWidth = self.tabStyle.titleType == ATScrollTabTitleTypeFit ? 0 : self.tabStyle.titleWidth;
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < titles.count; ++i) {
        NSString *title = titles[i];
        CGFloat titleBtnWidth = MAX(minWidth, [title at_sizeWithFont:self.tabStyle.selectedTitleFont].width);
        
        UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(left, 0, titleBtnWidth, self.at_height)];
        titleBtn.tag = i;
        titleBtn.titleLabel.font = self.tabStyle.normalTitleFont;
        [titleBtn setTitleColor:self.tabStyle.normalTitleColor forState:UIControlStateNormal];
        [titleBtn setTitleColor:self.tabStyle.selectedTitleColor forState:UIControlStateSelected];
        [titleBtn setTitle:title forState:UIControlStateNormal];
        [titleBtn addTarget:self action:@selector(onClickTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:titleBtn];
        [array addObject:titleBtn];

        left += titleBtnWidth + self.tabStyle.titleSpacing;
    }
    
    if (titles.count > 0) {
        left -= self.tabStyle.titleSpacing;
    }
    
    self.scrollView.contentSize = CGSizeMake(left + self.tabStyle.rightPadding, self.at_height);
    
    [self.titleBtns makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.titleBtns = array;

    UIView *selectLine = [UIView new];
    selectLine.backgroundColor = self.tabStyle.lineColor;
    selectLine.layer.cornerRadius = self.tabStyle.lineHeight / 2;
    [self.scrollView addSubview:selectLine];
    self.selectedLine = selectLine;
    
    self.curIndex = 0;
}

- (void)setCurIndex:(NSUInteger)curIndex
{
    if (curIndex >= self.titleBtns.count) {
        return;
    }
    if (_curIndex == curIndex) {
        return;
    }
    NSInteger last = _curIndex;
    _curIndex = curIndex;

    [self selectIndex:curIndex lastIndex:last];
    
    if ([self.delegate respondsToSelector:@selector(onTitleView:selectedIndexChangedTo:old:)]) {
        [self.delegate onTitleView:self selectedIndexChangedTo:curIndex old:last];
    }
}

- (void)selectIndex:(NSUInteger)index lastIndex:(NSUInteger)lastIndex
{
    if (lastIndex < self.titleBtns.count) {
        UIButton *lastSelectButton = [self.titleBtns objectAtIndex:lastIndex];
        lastSelectButton.selected = NO;
        lastSelectButton.titleLabel.font = self.tabStyle.normalTitleFont;
    }

    if (index < self.titleBtns.count) {
        UIButton *titleBtn = [self.titleBtns objectAtIndex:index];
        titleBtn.selected = YES;
        titleBtn.titleLabel.font = self.tabStyle.selectedTitleFont;
    }
    
    [self updateLineFrame];
    
    [self scrollIfNeed];
}

- (void)scrollIfNeed
{
    NSUInteger index = self.curIndex;
    NSUInteger count = self.titleBtns.count;
    
    UIButton *curBtn = self.titleBtns[index];
    CGFloat adjust = 10;
    
    CGFloat offsetX = -1;
    
    NSUInteger next = index + 1;
    if (next < count) {
        UIButton *nextBtn = self.titleBtns[next];
        if (nextBtn.at_left + adjust > self.scrollView.contentOffset.x + self.scrollView.at_width) { //下一个看不见
            offsetX = nextBtn.center.x - self.scrollView.at_width;
        }
    }
    else if (curBtn.at_right > self.scrollView.contentOffset.x + self.scrollView.at_width) { //显示完整
        offsetX = self.scrollView.contentSize.width - self.scrollView.at_width;
    }
    
    if (offsetX == -1) {
        NSUInteger previous = index - 1;
        if (previous < count) {
            UIButton *previousBtn = self.titleBtns[previous];
            if (previousBtn.at_right - adjust < self.scrollView.contentOffset.x) { //上一个看不见
                offsetX = previousBtn.center.x;
            }
        }
        else if (curBtn.at_left < self.scrollView.contentOffset.x) { //显示完整
            offsetX = 0;
        }
    }
    
    if (offsetX != -1) {
        [self.scrollView setContentOffset:CGPointMake(offsetX, 0)];
    }
}

- (void)onClickTitleButton:(UIButton *)sender
{
    self.curIndex = sender.tag;
}

- (void)scrollToIndex:(NSUInteger)index
{
    self.curIndex = index;
}
    
- (void)updateLineFrame
{
    if (self.curIndex < self.titleBtns.count) {
        UIButton *titleBtn = [self.titleBtns objectAtIndex:self.curIndex];
        CGFloat lineWidth = self.tabStyle.lineWidth;
        CGFloat lineHeight = self.tabStyle.lineHeight;
        self.selectedLine.frame = CGRectMake(titleBtn.at_left + (titleBtn.at_width - lineWidth) / 2, titleBtn.at_height - lineHeight - self.tabStyle.lineYOffset, lineWidth, lineHeight);
    }
}

@end

@interface ATScrollTabContentView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *loadedViewIndexes;

@property (nonatomic, strong) NSArray<UIViewController<IATScrollTabContent> *> *contents;
@property (nonatomic, assign) NSUInteger curIndex;

@end

@implementation ATScrollTabContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _loadedViewIndexes = [NSMutableSet new];
        [self addSubviews];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.at_width;
    CGFloat height = self.at_height;
    
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.contents.count * width, height);
    
    for (NSUInteger i = 0; i < self.contents.count; i++) {
        self.contents[i].view.frame = CGRectMake(i * width, 0, width, height);
    }
}

- (void)addSubviews
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)setContents:(NSArray<UIViewController<IATScrollTabContent> *> *)contents
{
    for (NSNumber *index in self.loadedViewIndexes.allObjects) {
        [_contents[index.unsignedIntValue].view removeFromSuperview];
    }
    [self.loadedViewIndexes removeAllObjects];
    
    _contents = contents;
    
    self.scrollView.contentSize = CGSizeMake(contents.count * self.at_width, self.at_height);
    
    self.curIndex = 0;
}

- (void)scrollToIndex:(NSUInteger)index
{
    self.curIndex = index;
}

- (void)setCurIndex:(NSUInteger)curIndex
{
    if (_curIndex == curIndex && self.loadedViewIndexes.count > 0) {
        return;
    }
    _curIndex = curIndex;
    
    NSUInteger previous = curIndex - 1;
    NSUInteger next = curIndex + 1;
    
    for (NSNumber *indexNum in self.loadedViewIndexes.allObjects) {
        NSUInteger index = indexNum.unsignedIntValue;
        if (index == curIndex || index == previous || index == next) {
            continue;
        }
        [self removeViewIfNeedIndex:index];
    }
    
    [self addViewIfNeedIndex:previous];
    [self addViewIfNeedIndex:curIndex];
    [self addViewIfNeedIndex:next];
    
    [self.scrollView setContentOffset:CGPointMake(curIndex * self.at_width, 0) animated:NO];
    
    if ([self.delegate respondsToSelector:@selector(onContentView:scrollToIndex:)]) {
        [self.delegate onContentView:self scrollToIndex:curIndex];
    }
}

- (UIViewController *)curContent
{
    return self.contents[self.curIndex];
}

- (void)addViewIfNeedIndex:(NSUInteger)index
{
    if (index >= self.contents.count) {
        return;
    }
    
    if ([self.loadedViewIndexes containsObject:@(index)]) {
        return;
    }
    
    CGFloat width = self.at_width;
    CGFloat height = self.at_height;
    
    UIViewController<IATScrollTabContent> *curContent = self.contents[index];
    if (curContent.view.superview != self.scrollView) {
        curContent.view.frame = CGRectMake(index * width, 0, width, height);
        [self.scrollView addSubview:curContent.view];
        
        UIScrollView *contentScrollView = nil;
        if ([curContent respondsToSelector:@selector(scrollTabContentScrollView)]) {
            contentScrollView = [curContent scrollTabContentScrollView];
        }
        if (contentScrollView != nil) {
            [at_scrollTabViewData() setObject:[ATWeakObject objectWithTarget:self.scrollTabView] forKey:[ATWeakObject objectKey:contentScrollView]];
        }
    }
    
    [self.loadedViewIndexes addObject:@(index)];
}

- (void)removeViewIfNeedIndex:(NSUInteger)index
{
    if (![self.loadedViewIndexes containsObject:@(index)]) {
        return;
    }
    
    if (index < self.contents.count) {
        if (self.contents[index].isViewLoaded) {
            [self.contents[index].view removeFromSuperview];
        }
    }
    
    [self.loadedViewIndexes removeObject:@(index)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = scrollView.at_width;
    if (width == 0) {
        return;
    }
    CGFloat offset = scrollView.contentOffset.x;
    if ((int)offset % (int)width == 0) {
        self.curIndex = scrollView.contentOffset.x / width;
    }
}

@end


@interface UIScrollView (ATScrollTabView)

@end

@implementation UIScrollView (ATScrollTabView)

- (void)hook_notifyDidScroll
{
    [self hook_notifyDidScroll];
    
    ATWeakObject *tmp = [at_scrollTabViewData() objectForKey:[ATWeakObject objectKey:self]];
    if (tmp != nil && tmp.target != nil) {
        ATScrollTabView *scrollTabView = (ATScrollTabView *)tmp.target;
        CGPoint contentOffset = scrollTabView.scrollView.contentOffset;
        if (contentOffset.y < scrollTabView.headerHeight) {
            CGPoint myOffset = self.contentOffset;
            myOffset.y = 0;
            self.contentOffset = myOffset;
        }
    }
}

@end


@interface ATScrollTabScrollView : UIScrollView<UIGestureRecognizerDelegate>

@end

@implementation ATScrollTabScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end

@interface ATScrollTabView ()<UIScrollViewDelegate, ATScrollTabTitleViewDelegate, ATScrollTabContentViewDelegate>

@property (nonatomic, strong) ATScrollTabStyle *tabStyle;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) ATScrollTabTitleView *titleView;
@property (nonatomic, strong) ATScrollTabContentView *contentView;
@property (nonatomic, assign) CGFloat headerHeight;

@end

@implementation ATScrollTabView

+ (void)load
{
    Class aClass = UIScrollView.class;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL hookSEL = @selector(_notifyDidScroll);
#pragma clang diagnostic pop
    
    SEL newSEL = @selector(hook_notifyDidScroll);
    
    Method hookMethod = class_getInstanceMethod(aClass, hookSEL);
    Method newMethod = class_getInstanceMethod(aClass, newSEL);
    
    IMP hookImp = method_getImplementation(hookMethod);
    IMP newImp = method_getImplementation(newMethod);
    
    const char *typeEncoding = method_getTypeEncoding(newMethod);
    
    if (class_addMethod(aClass, hookSEL, newImp, typeEncoding)) {
        class_replaceMethod(aClass, newSEL, hookImp, typeEncoding);
    }
    else {
        method_exchangeImplementations(hookMethod, newMethod);
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _tabStyle = [ATScrollTabStyle new];
        [self addSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame tabStyle:(nullable ATScrollTabStyle *)tabStyle
{
    if (self = [super initWithFrame:frame]) {
        _tabStyle = tabStyle ?: [ATScrollTabStyle new];
        [self addSubviews];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    
    CGFloat width = self.at_width;
    
    CGFloat headerHeight = 0;
    if (self.headerView != nil) {
        headerHeight = self.headerView.at_height;
        self.headerView.frame = CGRectMake(0, 0, width, headerHeight);
        
        CGSize contentSize = self.bounds.size;
        contentSize.height += headerHeight;
        self.scrollView.contentSize = contentSize;
    }
    else {
        self.scrollView.contentSize = self.bounds.size;
    }
    
    self.titleView.frame = CGRectMake(0, headerHeight, width, self.tabStyle.titleHeight);
    
    self.contentView.frame = CGRectMake(0, self.titleView.at_bottom, width, self.at_height - self.tabStyle.titleHeight);
}

- (void)addSubviews
{
    UIScrollView *scrollView = [ATScrollTabScrollView new];
    scrollView.delegate = self;
    scrollView.bounces = YES;
    scrollView.alwaysBounceVertical = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    self.titleView = [[ATScrollTabTitleView alloc] initWithFrame:CGRectZero tabStyle:self.tabStyle];
    self.titleView.delegate = self;
    [self.scrollView addSubview:self.titleView];
    
    self.contentView = [ATScrollTabContentView new];
    self.contentView.delegate = self;
    self.contentView.scrollTabView = self;
    [self.scrollView addSubview:self.contentView];
}

- (NSUInteger)curIndex
{
    return [self.titleView curIndex];
}

- (UIViewController *)curContent
{
    return self.contentView.curContent;
}

- (void)setTitles:(NSArray<NSString *> *)titles contents:(NSArray<UIViewController<IATScrollTabContent> *> *)contents
{
    NSAssert(titles.count == contents.count, @"tab数量要和content数量一致");
    for (UIViewController<IATScrollTabContent> *tmp in contents) {
        NSAssert([tmp respondsToSelector:@selector(scrollTabContentScrollView)], @"content未实现IATScrollTabContent协议");
    }
    
    self.titleView.titles = titles;
    self.contentView.contents = contents;
}

- (void)scrollToTop
{
    ;;
}

- (void)setHeaderView:(UIView *)headerView
{
    if (_headerView != nil) {
        [_headerView removeFromSuperview];
    }
    _headerView = headerView;
    if (headerView != nil) {
        [self.scrollView addSubview:headerView];
    }
    self.scrollView.scrollEnabled = headerView != nil;
    
    self.headerHeight = headerView.at_height;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    ;;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.headerView == nil) {
        return;
    }
    UIScrollView *target = nil;
    if ([self.curContent respondsToSelector:@selector(scrollTabContentScrollView)]) {
         target = [(UIViewController<IATScrollTabContent> *)self.curContent scrollTabContentScrollView];
    }
    CGPoint contentOffset = target.contentOffset;
    if (contentOffset.y > 0) {
        CGPoint myOffset = scrollView.contentOffset;
        myOffset.y = _headerHeight;
        scrollView.contentOffset = myOffset;
    }
}

#pragma mark - ATScrollTabTitleViewDelegate

- (void)onTitleView:(ATScrollTabTitleView *)titleView selectedIndexChangedTo:(NSUInteger)index old:(NSUInteger)old
{
    [self.contentView scrollToIndex:index];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onScrollTabView:selectedIndexChangedTo:old:)]) {
        [self.delegate onScrollTabView:self selectedIndexChangedTo:index old:old];
    }
}

#pragma mark - ATScrollTabContentViewDelegate

- (void)onContentView:(ATScrollTabContentView *)contentView scrollToIndex:(NSUInteger)index
{
    [self.titleView scrollToIndex:index];
}

@end
