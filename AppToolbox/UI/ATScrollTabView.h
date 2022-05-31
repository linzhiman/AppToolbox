//
//  ATScrollTabView.h
//  AppToolbox
//
//  Created by linzhiman on 2022/4/1.
//  Copyright © 2022 AppToolbox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ATScrollTabTitleType) {
    ATScrollTabTitleTypeFit = 0, //自适应宽度
    ATScrollTabTitleTypeFix = 1 //固定宽度，文字居中
};

@interface ATScrollTabStyle : NSObject

@property (nonatomic, assign) ATScrollTabTitleType titleType;

@property (nonatomic, strong) UIColor *normalTitleColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;

@property (nonatomic, strong) UIFont *normalTitleFont;
@property (nonatomic, strong) UIFont *selectedTitleFont;

@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat lineYOffset;

@property (nonatomic, assign) CGFloat leftPadding;
@property (nonatomic, assign) CGFloat rightPadding;
@property (nonatomic, assign) CGFloat titleSpacing;
@property (nonatomic, assign) CGFloat titleWidth;
@property (nonatomic, assign) CGFloat titleHeight;

@end


@class ATScrollTabTitleView;
@protocol ATScrollTabTitleViewDelegate <NSObject>

- (void)onTitleView:(ATScrollTabTitleView *)titleView selectedIndexChangedTo:(NSUInteger)index old:(NSUInteger)old;

@end

@interface ATScrollTabTitleView : UIView

@property (nonatomic, weak) id<ATScrollTabTitleViewDelegate>delegate;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) NSUInteger curIndex;

- (instancetype)initWithFrame:(CGRect)frame tabStyle:(ATScrollTabStyle *)tabStyle;

- (void)setTitles:(NSArray<NSString *> *)titles;
- (void)scrollToIndex:(NSUInteger)index;

@end


@protocol IATScrollTabContent <NSObject>

- (UIScrollView *)scrollTabContentScrollView;

@end

@class ATScrollTabContentView;
@protocol ATScrollTabContentViewDelegate<NSObject>

- (void)onContentView:(ATScrollTabContentView *)contentView scrollToIndex:(NSUInteger)index;

@end

@class ATScrollTabView;

@interface ATScrollTabContentView : UIView

@property (nonatomic, weak) id<ATScrollTabContentViewDelegate>delegate;

@property (nonatomic, weak) ATScrollTabView *scrollTabView;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) NSUInteger curIndex;
@property (nonatomic, strong, readonly) UIViewController *curContent;

- (void)setContents:(NSArray<UIViewController<IATScrollTabContent> *> *)contents;
- (void)scrollToIndex:(NSUInteger)index;

@end


@protocol ATScrollTabViewDelegate <NSObject>

@optional

- (void)onScrollTabView:(ATScrollTabView *)scrollTabView selectedIndexChangedTo:(NSUInteger)index old:(NSUInteger)old;

@end

@interface ATScrollTabView : UIView

@property (nonatomic, weak) id<ATScrollTabViewDelegate> delegate;

@property (nonatomic, strong, readonly) ATScrollTabStyle *tabStyle;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, assign, readonly) NSUInteger curIndex;
@property (nonatomic, strong, readonly) UIViewController *curContent;

@property (nonatomic, strong, nullable) UIView *headerView; // 需指定高度
@property (nonatomic, assign, readonly) CGFloat headerHeight;

- (instancetype)initWithFrame:(CGRect)frame tabStyle:(nullable ATScrollTabStyle *)tabStyle;

- (void)setTitles:(NSArray<NSString *> *)titles contents:(NSArray<UIViewController<IATScrollTabContent> *> *)contents;

- (void)scrollToTop;

@end

NS_ASSUME_NONNULL_END
