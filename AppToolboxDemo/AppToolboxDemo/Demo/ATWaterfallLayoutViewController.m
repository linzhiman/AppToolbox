//
//  ATWaterfallLayoutViewController.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2022/3/31.
//  Copyright © 2022 AppToolbox. All rights reserved.
//

#import "ATWaterfallLayoutViewController.h"
#import "ATCollectionViewWaterfallLayout.h"
#import "ATGlobalMacro.h"

AT_STRING_DEFINE(WaterfallCell)
AT_STRING_DEFINE(WaterfallHeader)
AT_STRING_DEFINE(WaterfallFooter)

@interface ATWaterfallFooter : UICollectionReusableView

@end

@implementation ATWaterfallFooter

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

@end

@interface ATWaterfallHeader : UICollectionReusableView

@end

@implementation ATWaterfallHeader

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

@end

@interface ATWaterfallCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *labelView;

@end

@implementation ATWaterfallCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.labelView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.labelView = [[UILabel alloc] initWithFrame:self.contentView.bounds];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)labelView
{
    if (!_labelView) {
        _labelView = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _labelView.textColor = UIColor.redColor;
    }
    return _labelView;
}

@end

@interface ATWaterfallLayoutViewController ()<UICollectionViewDataSource, ATCollectionViewWaterfallLayoutDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *cellSizes;
@property (nonatomic, strong) NSArray *city;

@end

@implementation ATWaterfallLayoutViewController

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"WaterfallLayout";
    
    ATCollectionViewWaterfallLayout *layout = [[ATCollectionViewWaterfallLayout alloc] init];

    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 30;
    layout.headerHeight = 20;
    layout.footerHeight = 20;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerClass:[ATWaterfallCell class] forCellWithReuseIdentifier:WaterfallCell];
    [collectionView registerClass:[ATWaterfallHeader class] forSupplementaryViewOfKind:ATCollectionViewElementKindHeader withReuseIdentifier:WaterfallHeader];
    [collectionView registerClass:[ATWaterfallFooter class] forSupplementaryViewOfKind:ATCollectionViewElementKindFooter withReuseIdentifier:WaterfallFooter];

    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
}

- (NSArray *)cellSizes
{
    if (!_cellSizes) {
        _cellSizes = @[
            [NSValue valueWithCGSize:CGSizeMake(1200, 800)],
            [NSValue valueWithCGSize:CGSizeMake(800, 1200)],
            [NSValue valueWithCGSize:CGSizeMake(1100, 1100)],
            [NSValue valueWithCGSize:CGSizeMake(1200, 900)]
        ];
    }
    return _cellSizes;
}

- (NSArray *)city
{
    if (!_city) {
        _city = @[@"city1.jpg", @"city2.jpg", @"city3.jpg", @"city4.jpg"];
    }
    return _city;
}

- (UIScrollView *)scrollTabContentScrollView
{
    return self.collectionView;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 30;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WaterfallCell forIndexPath:indexPath];
    ((ATWaterfallCell *)cell).imageView.image = [UIImage imageNamed:self.city[indexPath.item % 4]];
    ((ATWaterfallCell *)cell).labelView.text = @(indexPath.item).stringValue;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    if ([kind isEqualToString:ATCollectionViewElementKindHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:WaterfallHeader forIndexPath:indexPath];
    }
    else if ([kind isEqualToString:ATCollectionViewElementKindFooter]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:WaterfallFooter forIndexPath:indexPath];
    }
    return reusableView;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cellSizes[indexPath.item % 4] CGSizeValue];
}

@end
