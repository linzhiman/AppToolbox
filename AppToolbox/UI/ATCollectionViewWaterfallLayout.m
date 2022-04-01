//
//  ATCollectionViewWaterfallLayout.m
//  AppToolbox
//
//  Created by linzhiman on 2022/3/28.
//  Copyright © 2022 AppToolbox. All rights reserved.
//

#import "ATCollectionViewWaterfallLayout.h"

#define ATWaterfallLayoutSetter(Property) \
    if (_##Property != Property) { \
        _##Property = Property; \
        [self invalidateLayout]; \
    }

#define ATWaterfallLayoutInsetSetter(Property) \
    if (!UIEdgeInsetsEqualToEdgeInsets(_##Property, Property)) { \
        _##Property = Property; \
        [self invalidateLayout]; \
    }

AT_STRING_DEFINE(ATCollectionViewElementKindHeader)
AT_STRING_DEFINE(ATCollectionViewElementKindFooter)

static const NSInteger sUnionRectCount = 10;

static CGFloat ATFloorCGFloat(CGFloat value)
{
    CGFloat scale = [UIScreen mainScreen].scale;
    return floor(value * scale) / scale;
}

@interface ATCollectionViewWaterfallLayout ()

@property (nonatomic, weak) id<ATCollectionViewWaterfallLayoutDelegate> delegate;

/// 每个section中每一列的高度
@property (nonatomic, strong) NSMutableArray *columnHeights;
/// 每个header的layoutAttributes
@property (nonatomic, strong) NSMutableDictionary *headersAttribute;
/// 每个footer的layoutAttributes
@property (nonatomic, strong) NSMutableDictionary *footersAttribute;
/// 每个section中每一item的layoutAttributes
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
/// 所有的layoutAttributes
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
/// 每sUnionRectCount个矩形的并集，加快layoutAttributesForElementsInRect的查找
@property (nonatomic, strong) NSMutableArray *unionRects;

@end

@implementation ATCollectionViewWaterfallLayout

- (void)setColumnCount:(NSInteger)columnCount
{
    ATWaterfallLayoutSetter(columnCount)
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    ATWaterfallLayoutSetter(minimumLineSpacing)
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing
{
    ATWaterfallLayoutSetter(minimumInteritemSpacing)
}

- (void)setHeaderHeight:(CGFloat)headerHeight
{
    ATWaterfallLayoutSetter(headerHeight)
}

- (void)setFooterHeight:(CGFloat)footerHeight
{
    ATWaterfallLayoutSetter(footerHeight)
}

- (void)setHeaderInset:(UIEdgeInsets)headerInset
{
    ATWaterfallLayoutInsetSetter(headerInset)
}

- (void)setFooterInset:(UIEdgeInsets)footerInset
{
    ATWaterfallLayoutInsetSetter(footerInset)
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset
{
    ATWaterfallLayoutInsetSetter(sectionInset)
}

- (void)setType:(ATCollectionViewWaterfallLayoutType)type
{
    ATWaterfallLayoutSetter(type)
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = ATCollectionViewWaterfallLayoutTypeShortestFirst;
        _columnCount = 2;
        _minimumLineSpacing = 10;
        _minimumInteritemSpacing = 10;
        _headerHeight = 0;
        _footerHeight = 0;
        _sectionInset = UIEdgeInsetsZero;
        _headerInset  = UIEdgeInsetsZero;
        _footerInset  = UIEdgeInsetsZero;
        
        _columnHeights = [NSMutableArray array];
        _headersAttribute = [NSMutableDictionary dictionary];
        _footersAttribute = [NSMutableDictionary dictionary];
        _sectionItemAttributes = [NSMutableArray array];
        _allItemAttributes = [NSMutableArray array];
        _unionRects = [NSMutableArray array];
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }

    [self.columnHeights removeAllObjects];
    [self.headersAttribute removeAllObjects];
    [self.footersAttribute removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];
    [self.allItemAttributes removeAllObjects];
    [self.unionRects removeAllObjects];

    /// 先将所有列的高度初始化为 0，后续直接修改
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSInteger columnCount = [self columnCountForSection:section];
        NSMutableArray *sectionColumnHeights = [NSMutableArray arrayWithCapacity:columnCount];
        for (NSInteger idx = 0; idx < columnCount; idx++) {
            [sectionColumnHeights addObject:@(0)];
        }
        [self.columnHeights addObject:sectionColumnHeights];
    }
    
    CGFloat collectionViewWidth = self.collectionView.bounds.size.width;
    UICollectionViewLayoutAttributes *attributes = nil;

    CGFloat top = 0;
    for (NSInteger section = 0; section < numberOfSections; ++section) {
        NSInteger columnCount = [self columnCountForSection:section];
        CGFloat minimumInteritemSpacing = [self minimumInteritemSpacingInSection:section];
        CGFloat minimumLineSpacing = [self minimumLineSpacingInSection:section];
        CGFloat headerHeight = [self headerHeightInSection:section];
        CGFloat footerHeight = [self footerHeightInSection:section];
        UIEdgeInsets headerInset = [self headerInsetInSection:section];
        UIEdgeInsets footerInset = [self footerInsetInSection:section];
        UIEdgeInsets sectionInset = [self sectionInsetInSection:section];

        CGFloat contentWidth = collectionViewWidth - sectionInset.left - sectionInset.right;
        CGFloat columnWidth = ATFloorCGFloat((contentWidth - (columnCount - 1) * minimumLineSpacing) / columnCount);

        if (headerHeight > 0) {
            top += headerInset.top;
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ATCollectionViewElementKindHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(headerInset.left, top, collectionViewWidth - headerInset.left - headerInset.right, headerHeight);
            self.headersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            top = CGRectGetMaxY(attributes.frame) + headerInset.bottom;
        }

        top += sectionInset.top;
        for (NSInteger idx = 0; idx < columnCount; idx++) {
            self.columnHeights[section][idx] = @(top);
        }
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        for (NSInteger idx = 0; idx < itemCount; idx++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            NSUInteger columnIndex = [self nextColumnIndexForItem:idx inSection:section];
            CGFloat xOffset = sectionInset.left + (columnWidth + minimumLineSpacing) * columnIndex;
            CGFloat yOffset = [self.columnHeights[section][columnIndex] floatValue];
            CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
            CGFloat itemHeight = 0;
            if (itemSize.height > 0 && itemSize.width > 0) {
                itemHeight = ATFloorCGFloat(itemSize.height * columnWidth / itemSize.width);
            }

            attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(xOffset, yOffset, columnWidth, itemHeight);
            [itemAttributes addObject:attributes];
            [self.allItemAttributes addObject:attributes];
            self.columnHeights[section][columnIndex] = @(CGRectGetMaxY(attributes.frame) + minimumInteritemSpacing);
        }
        [self.sectionItemAttributes addObject:itemAttributes];
        
        NSUInteger columnIndex = [self longestColumnIndexInSection:section];
        if (((NSArray *)self.columnHeights[section]).count > 0) {
            top = [self.columnHeights[section][columnIndex] floatValue] - minimumInteritemSpacing + sectionInset.bottom;
        }
        else {
            top = 0;
        }
        
        if (footerHeight > 0) {
            top += footerInset.top;
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:ATCollectionViewElementKindFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(footerInset.left, top, collectionViewWidth - footerInset.left - footerInset.right, footerHeight);
            self.footersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            top = CGRectGetMaxY(attributes.frame) + footerInset.bottom;
        }

        for (NSInteger idx = 0; idx < columnCount; idx++) {
            self.columnHeights[section][idx] = @(top);
        }
    }

    NSInteger idx = 0;
    NSInteger itemCounts = [self.allItemAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + sUnionRectCount, itemCounts);

        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.allItemAttributes[i]).frame);
        }

        idx = rectEndIndex;

        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}

- (CGSize)collectionViewContentSize
{
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return CGSizeZero;
    }

    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height = [[[self.columnHeights lastObject] firstObject] floatValue];

    if (contentSize.height < self.minimumContentHeight) {
        contentSize.height = self.minimumContentHeight;
    }

    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= [self.sectionItemAttributes count]) {
        return nil;
    }
    if (indexPath.item >= [self.sectionItemAttributes[indexPath.section] count]) {
        return nil;
    }
    return (self.sectionItemAttributes[indexPath.section])[indexPath.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([elementKind isEqualToString:ATCollectionViewElementKindHeader]) {
        attribute = self.headersAttribute[@(indexPath.section)];
    }
    else if ([elementKind isEqualToString:ATCollectionViewElementKindFooter]) {
        attribute = self.footersAttribute[@(indexPath.section)];
    }
    return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSInteger begin = 0;
    NSInteger end = self.unionRects.count;
    NSMutableDictionary *cellAttrDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *headerAttrDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *footerAttrDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *decorAttrDict = [NSMutableDictionary dictionary];

    for (NSInteger i = 0; i < self.unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            begin = i * sUnionRectCount;
            break;
        }
    }
    for (NSInteger i = self.unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            end = MIN((i + 1) * sUnionRectCount, self.allItemAttributes.count);
            break;
        }
    }
    for (NSInteger i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            switch (attr.representedElementCategory) {
            case UICollectionElementCategorySupplementaryView:
                if ([attr.representedElementKind isEqualToString:ATCollectionViewElementKindHeader]) {
                    headerAttrDict[attr.indexPath] = attr;
                }
                else if ([attr.representedElementKind isEqualToString:ATCollectionViewElementKindFooter]) {
                    footerAttrDict[attr.indexPath] = attr;
                }
                break;
            case UICollectionElementCategoryDecorationView:
                decorAttrDict[attr.indexPath] = attr;
                break;
            case UICollectionElementCategoryCell:
                cellAttrDict[attr.indexPath] = attr;
                break;
            }
        }
    }

    NSArray *result = [cellAttrDict.allValues arrayByAddingObjectsFromArray:headerAttrDict.allValues];
    result = [result arrayByAddingObjectsFromArray:footerAttrDict.allValues];
    result = [result arrayByAddingObjectsFromArray:decorAttrDict.allValues];
    return result;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    return CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds);
}

- (NSInteger)columnCountForSection:(NSInteger)section
{
    NSInteger columnCount = self.columnCount;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:columnCountForSection:)]) {
        return [self.delegate collectionView:self.collectionView layout:self columnCountForSection:section];
    }
    return columnCount;
}

- (CGFloat)minimumInteritemSpacingInSection:(NSInteger)section
{
    CGFloat minimumInteritemSpacing = self.minimumInteritemSpacing;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
      minimumInteritemSpacing = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    return minimumInteritemSpacing;
}

- (CGFloat)minimumLineSpacingInSection:(NSInteger)section
{
    CGFloat minimumLineSpacing = self.minimumLineSpacing;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        minimumLineSpacing = [self.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    return minimumLineSpacing;
}

- (CGFloat)headerHeightInSection:(NSInteger)section
{
    CGFloat headerHeight = self.headerHeight;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderInSection:)]) {
        headerHeight = [self.delegate collectionView:self.collectionView layout:self heightForHeaderInSection:section];
    }
    return headerHeight;
}

- (CGFloat)footerHeightInSection:(NSInteger)section
{
    CGFloat footerHeight = self.footerHeight;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)]) {
        footerHeight = [self.delegate collectionView:self.collectionView layout:self heightForFooterInSection:section];
    }
    return footerHeight;
}

- (UIEdgeInsets)headerInsetInSection:(NSInteger)section
{
    UIEdgeInsets headerInset = self.headerInset;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForHeaderInSection:)]) {
        headerInset = [self.delegate collectionView:self.collectionView layout:self insetForHeaderInSection:section];
    }
    return headerInset;
}

- (UIEdgeInsets)footerInsetInSection:(NSInteger)section
{
    UIEdgeInsets footerInset = self.footerInset;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForFooterInSection:)]) {
        footerInset = [self.delegate collectionView:self.collectionView layout:self insetForFooterInSection:section];
    }
    return footerInset;
}

- (UIEdgeInsets)sectionInsetInSection:(NSInteger)section
{
    UIEdgeInsets sectionInset = self.sectionInset;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    return sectionInset;
}

- (id <ATCollectionViewWaterfallLayoutDelegate> )delegate
{
    return (id <ATCollectionViewWaterfallLayoutDelegate> )self.collectionView.delegate;
}

- (NSUInteger)shortestColumnIndexInSection:(NSInteger)section
{
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;

    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }];

    return index;
}

- (NSUInteger)longestColumnIndexInSection:(NSInteger)section
{
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;

    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }];

    return index;
}

- (NSUInteger)nextColumnIndexForItem:(NSInteger)item inSection:(NSInteger)section
{
    NSUInteger index = 0;
    NSInteger columnCount = [self columnCountForSection:section];
    switch (self.type) {
    case ATCollectionViewWaterfallLayoutTypeShortestFirst:
        index = [self shortestColumnIndexInSection:section];
        break;
    case ATCollectionViewWaterfallLayoutTypeLeftRightInOrder:
        index = (item % columnCount);
        break;
    case ATCollectionViewWaterfallLayoutTypeRightLeftInOrder:
        index = (columnCount - 1) - (item % columnCount);
        break;
    default:
        index = [self shortestColumnIndexInSection:section];
        break;
    }
    return index;
}

@end
