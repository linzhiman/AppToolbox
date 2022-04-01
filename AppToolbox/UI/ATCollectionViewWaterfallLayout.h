//
//  ATCollectionViewWaterfallLayout.h
//  AppToolbox
//
//  Created by linzhiman on 2022/3/28.
//  Copyright © 2022 AppToolbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATGlobalMacro.h"

typedef NS_ENUM (NSUInteger, ATCollectionViewWaterfallLayoutType) {
    ATCollectionViewWaterfallLayoutTypeShortestFirst,
    ATCollectionViewWaterfallLayoutTypeLeftRightInOrder,
    ATCollectionViewWaterfallLayoutTypeRightLeftInOrder
};

AT_STRING_EXTERN(ATCollectionViewElementKindHeader)
AT_STRING_EXTERN(ATCollectionViewElementKindFooter)

@class ATCollectionViewWaterfallLayout;

@protocol ATCollectionViewWaterfallLayoutDelegate <UICollectionViewDelegate>
@required

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForHeaderInSection:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForFooterInSection:(NSInteger)section;

@end


@interface ATCollectionViewWaterfallLayout : UICollectionViewLayout

/// 默认为 ATCollectionViewWaterfallLayoutTypeShortestFirst
@property (nonatomic, assign) ATCollectionViewWaterfallLayoutType type;

/// 默认为 2
@property (nonatomic, assign) NSInteger columnCount;

/// 默认为 10
@property (nonatomic, assign) CGFloat minimumLineSpacing;

/// 默认为 10
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

/// 默认为 0
@property (nonatomic, assign) CGFloat headerHeight;

/// 默认为 0
@property (nonatomic, assign) CGFloat footerHeight;

/// 默认为 UIEdgeInsetsZero
@property (nonatomic, assign) UIEdgeInsets headerInset;

/// 默认为 UIEdgeInsetsZero
@property (nonatomic, assign) UIEdgeInsets footerInset;

/// 默认为 UIEdgeInsetsZero
@property (nonatomic, assign) UIEdgeInsets sectionInset;

/// 默认为 0
@property (nonatomic, assign) CGFloat minimumContentHeight;

@end
