//
//  HCCarouselView.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCCarouselView.h"
#import "HCCarouselViewRow.h"
#import "HCCarouselViewCarouselLabel.h"

const CGFloat _HCCarouselViewDefaultScrollViewHeight = 44.0;
const CGFloat _HCCarouselViewDefaultItemWidth = 100.0;

@interface HCCarouselView () {
    NSMutableDictionary *availableCells;
    NSMutableDictionary *contentOffsetForReload;
}
- (void) _setNeedsReload;
@end

@implementation HCCarouselView
@synthesize dataSource=_dataSource;
@synthesize carouselFooterHeight=_carouselFooterHeight, carouselHeaderHeight =_carouselHeaderHeight, itemWidth=_itemWidth;

@dynamic delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self init];
}

- (id)init
{
    self = [super init];
    if (self) {
        _cachedCells = [[NSMutableDictionary alloc] init];
        _carousels = [[NSMutableArray alloc] init];
        _reusableCells = [[NSMutableSet alloc] init];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        self.carouselFooterHeight = self.carouselHeaderHeight = 30.0;
        [self _setNeedsReload];
    }
    return self;
}

- (void)setDataSource:(id<HCCarouselViewDataSource>)newDataSource
{
    _dataSource = newDataSource;
    [self _setNeedsReload];
    
}

- (void)setDelegate:(id<HCCarouselViewDelegate>)newDelegate
{
    [super setDelegate:newDelegate];
}

//- (void)setCarouselHeight:(CGFloat)newCarouselHeight
//{
//    _carouselHeight = newCarouselHeight;
//    [self setNeedsLayout];
//}



- (void)setItemWidth:(CGFloat)newItemWidth
{
    _itemWidth = newItemWidth;
    [self setNeedsLayout];
}

- (void)_updateCarouselCache
{
    for (HCCarouselViewRow *carousel in _carousels) {
        [carousel.headerView removeFromSuperview];
        [carousel.footerView removeFromSuperview];
        [carousel.scrollView removeFromSuperview];
    }
    [_carousels removeAllObjects];
    availableCells = [_cachedCells mutableCopy];
    [_cachedCells removeAllObjects];
    if (_dataSource) {
        const CGFloat defaultCarouselScrollViewHeight = _HCCarouselViewDefaultScrollViewHeight;
        const CGFloat defaultItemWidth = _itemWidth ?: _HCCarouselViewDefaultItemWidth;
        const NSInteger numberOfCarousels = [self numberOfCarousels];
        for (int carousel=0; carousel < numberOfCarousels; carousel++) {
            const NSInteger numberOfItemsInCarousel = [self numberOfItemsInCarousel:carousel];
            
            HCCarouselViewRow *carouselRecord = [[HCCarouselViewRow alloc] init];
            carouselRecord.itemHeight = [self.delegate respondsToSelector:@selector(carouselView:heightForCarousel:)] ? [self.delegate carouselView:self heightForCarousel:carousel] : defaultCarouselScrollViewHeight;
            
            carouselRecord.headerView = [self.delegate respondsToSelector:@selector(carouselView:viewForHeaderInCarousel:)] ? [self.delegate carouselView:self viewForHeaderInCarousel:carousel] : nil;
            carouselRecord.footerView = [self.delegate respondsToSelector:@selector(carouselView:viewForFooterInCarousel:)] ? [self.delegate carouselView:self viewForFooterInCarousel:carousel] : nil;
            
            carouselRecord.headerTitle = [self.dataSource respondsToSelector:@selector(carouselView:titleForHeaderInCarousel:)] ? [self.dataSource carouselView:self titleForHeaderInCarousel:carousel] : nil;
            carouselRecord.footerTitle = [self.dataSource respondsToSelector:@selector(carouselView:titleForFooterInCarousel:)] ? [self.dataSource carouselView:self titleForFooterInCarousel:carousel] : nil;
            
            if (!carouselRecord.headerView && carouselRecord.headerTitle) {
                carouselRecord.headerView = [HCCarouselViewCarouselLabel carouselLabelWithTitle:carouselRecord.headerTitle];
            }
            
            if (!carouselRecord.footerView && carouselRecord.footerTitle) {
                carouselRecord.footerView = [HCCarouselViewCarouselLabel carouselLabelWithTitle:carouselRecord.footerTitle];
            }
            
            if (carouselRecord.headerView) {
                
                [self addSubview:carouselRecord.headerView];
                [carouselRecord.headerView setHidden:YES];
                carouselRecord.headerHeight = [self.delegate respondsToSelector:@selector(carouselView:heightForHeaderInCarousel:)] ? [self.delegate carouselView:self heightForHeaderInCarousel:carousel] : _carouselHeaderHeight;
            } else {
                carouselRecord.headerHeight = 0;
            }
            
            if (carouselRecord.footerView) {
                [self addSubview:carouselRecord.footerView];
                carouselRecord.footerHeight = [self.delegate respondsToSelector:@selector(carouselView:heightForFooterInCarousel:)] ? [self.delegate carouselView:self heightForFooterInCarousel:carousel] : _carouselFooterHeight;
            } else {
                carouselRecord.footerHeight = 0;
            }
            
            
            carouselRecord.scrollViewHeight = [self.delegate respondsToSelector:@selector(carouselView:heightForScrollViewInCarousel:)] ? [self.delegate carouselView:self heightForScrollViewInCarousel:carousel] : defaultCarouselScrollViewHeight;
            
            carouselRecord.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, carouselRecord.headerHeight, self.frame.size.width, carouselRecord.scrollViewHeight)];
            
            [self addSubview:carouselRecord.scrollView];
            [carouselRecord.scrollView setTag:carousel];
            [carouselRecord.scrollView setDelegate:self];
            [carouselRecord.scrollView setScrollEnabled:YES];
            [carouselRecord.scrollView setDirectionalLockEnabled:YES];
            
            carouselRecord.carousel = carousel;
            
            CGFloat totalItemsWidth = 0;
            
            for (int item = 0; item < numberOfItemsInCarousel; item++) {
                const CGFloat itemWidth = [self.delegate respondsToSelector:@selector(carouselView:widthForItemAtIndexPath:)] ? [self.delegate carouselView:self widthForItemAtIndexPath:[NSIndexPath indexPathForItem:item inCarousel:carousel]] : defaultItemWidth;
                //                itemWidths[item] = itemWidth;
                totalItemsWidth += itemWidth + 10;
            }
            totalItemsWidth += 10;
            
            carouselRecord.itemsWidth = totalItemsWidth;
            [carouselRecord setNumberOfItems:numberOfItemsInCarousel];
            //            free(itemWidths);
            carouselRecord.scrollView.contentSize = CGSizeMake(totalItemsWidth, 0);
            
            [_carousels addObject:carouselRecord];
            
        }
        
    }
}

- (void)_updateCarouselCacheIfNeeded
{
    if ([_carousels count] == 0) {
        [self _updateCarouselCache];
    }
}

- (void)_setContentSize
{
    [self _updateCarouselCacheIfNeeded];
    
    CGFloat height = 0;
    
    for (HCCarouselViewRow *carousel in _carousels) {
        height += [carousel carouselHeight];
    }
    
    self.contentSize = CGSizeMake(0, height);
}

- (void)_layoutCarouselView
{
    const CGSize boundsSize = self.bounds.size;
    const CGFloat contentOffset = self.contentOffset.y;
    const CGRect visibleBounds = CGRectMake(0, contentOffset, boundsSize.width, boundsSize.height);

    CGFloat viewHeight = 0;
    
    
    const NSInteger numberOfCarousels = [_carousels count];
    
    
    for (int carousel = 0; carousel < numberOfCarousels; carousel++) {
        CGRect carouselRect = [self rectForCarousel:carousel];
        viewHeight += carouselRect.size.height;
        HCCarouselViewRow *carouselRecord = [_carousels objectAtIndex:carousel];
        
        if (CGRectIntersectsRect(carouselRect, visibleBounds)) {
            if (carouselRecord) {
                
                
                const CGRect headerRect = [self rectForHeaderInCarousel:carousel];
                const CGRect footerRect = [self rectForFooterInCarousel:carousel];
                const CGRect scrollViewRect = [self rectForScrollViewInCarousel:carousel];
                
                
                CGSize contentSize = self.contentSize;
                if (contentSize.height < CGRectGetMaxY(carouselRecord.scrollView.frame)) {
                    contentSize.height = CGRectGetMaxY(carouselRecord.scrollView.frame);
                    self.contentSize = contentSize;
                }
                

                
                
                //            const NSInteger numberOfItems = carouselRecord.numberOfItems;
                
                if (carouselRecord.headerView) {
                    carouselRecord.headerView.frame = headerRect;
                    [carouselRecord.headerView setHidden:NO];
                    
                }
                
                if (carouselRecord.footerView) {
                    carouselRecord.footerView.frame = footerRect;
                }
                [carouselRecord.scrollView setFrame:scrollViewRect];
                
                
                CGRect visibleScrollViewBounds = CGRectMake(carouselRecord.scrollView.contentOffset.x, 0, carouselRecord.scrollView.bounds.size.width, carouselRecord.scrollView.bounds.size.height);
//                [self _layoutCarousel:carouselRecord];

                
//                if (carouselRecord.numberOfItems) {
//                    for (UIView *subview in carouselRecord.scrollView.subviews) {
//                        if ([subview isKindOfClass:[HCCarouselViewCell class]]) {
//                            [subview removeFromSuperview];
//                        }
//                    }
                
                    
                    
                    for (int item = 0; item < carouselRecord.numberOfItems; item++) {
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inCarousel:carouselRecord.scrollView.tag];
                        CGRect itemRect = [self rectForItemAtIndexPath:indexPath];
                        
                        if (CGRectIntersectsRect(itemRect, visibleScrollViewBounds) && itemRect.size.height > 0) {
                            HCCarouselViewCell *cell = [availableCells objectForKey:indexPath] ?: [self.dataSource carouselView:self cellForItemAtIndexPath:indexPath];
                            if (cell) {
                                cell.carousel = indexPath.carousel;
                                cell.item = indexPath.item;
                                [_cachedCells setObject:cell forKey:indexPath];
                                [availableCells removeObjectForKey:indexPath];
                                cell.frame = itemRect;
                                cell.backgroundColor = self.backgroundColor;
                                [carouselRecord.scrollView addSubview:cell];
                            }
                        }
                    }
                    
                    for (HCCarouselViewCell *cell in [availableCells allValues]) {
                        if (cell.reuseIdentifier) {
                            [_reusableCells addObject:cell];
                        } else {
                            [cell removeFromSuperview];
                        }
                    }
                    
                    availableCells = nil;
                    NSArray *allCachedCells = [_cachedCells allValues];
                    for (HCCarouselViewCell *cell in _reusableCells) {
                        UIScrollView *scrollView = (UIScrollView *)cell.superview;
                        CGRect visibleBounds = CGRectMake(0, self.contentOffset.y, self.bounds.size.width, self.bounds.size.height);
                        if (CGRectIntersectsRect(scrollView.frame, visibleBounds)) {
                            CGPoint offset = [(UIScrollView *)cell.superview contentOffset];
                            CGRect scrollVisibleBounds = CGRectMake(offset.x, 0, cell.superview.frame.size.width, cell.superview.frame.size.height);
                            if (CGRectIntersectsRect(cell.frame , scrollVisibleBounds) && ![allCachedCells containsObject:cell]) {
                                [cell prepareForReuse];
                                [cell removeFromSuperview];
                            }
                            
                        }
                        
                    }
                    
                }
                
                
                
                
                NSString *offsetString = [contentOffsetForReload objectForKey:@(carousel)];
                if (offsetString) {
                    CGPoint offset = CGPointFromString(offsetString);
                    [carouselRecord.scrollView setContentOffset:offset];
                }
            
        } else {
            if (carouselRecord.scrollView.superview) {
                [carouselRecord.scrollView removeFromSuperview];
                
            }
            for (UIView *subview in carouselRecord.scrollView.subviews) {
                if ([subview isKindOfClass:[HCCarouselViewCell class]]) {
                    [subview removeFromSuperview];
                }
            }
            
        }
        [contentOffsetForReload removeObjectForKey:@(carousel)];
    }
}

- (void)_layoutCarousel:(HCCarouselViewRow *)carouselRecord
{
 
}


- (CGRect)_CGRectFromVerticalOffset:(CGFloat)offset height:(CGFloat)height
{
    return CGRectMake(0,offset,self.bounds.size.width,height);
}

- (CGRect)_CGRectFromHorizontalOffset:(CGFloat)offset width:(CGFloat)width height:(CGFloat)height
{
    return CGRectMake(offset, 0, width, height);
}

- (CGFloat)_offsetForCarousel:(NSInteger)index
{
    CGFloat offset = 0;
    
    for (int i=0; i < index; i++) {
        offset += [[_carousels objectAtIndex:i] carouselHeight] + ([self.delegate respondsToSelector:@selector(paddingBetweenCarouselsInCarouselView:)] ? [self.delegate paddingBetweenCarouselsInCarouselView:self] : 0);
    }
    
    return offset;
}

- (CGRect)rectForCarousel:(NSInteger)carousel
{
    [self _updateCarouselCacheIfNeeded];
    HCCarouselViewRow *carouselRecord = [_carousels objectAtIndex:carousel];
    CGFloat offset = [self _offsetForCarousel:carousel];
    offset += carouselRecord.headerHeight;
    return [self _CGRectFromVerticalOffset:offset height:[[_carousels objectAtIndex:carousel] itemHeight]];
    
}

- (CGRect)rectForHeaderInCarousel:(NSInteger)carousel
{
    [self _updateCarouselCacheIfNeeded];
    CGFloat offset = [self _offsetForCarousel:carousel];
    return [self _CGRectFromVerticalOffset:offset height:[[_carousels objectAtIndex:carousel] headerHeight]];
}

- (CGRect)rectForFooterInCarousel:(NSInteger)carousel
{
    [self _updateCarouselCacheIfNeeded];
    HCCarouselViewRow *carouselRecord = [_carousels objectAtIndex:carousel];
    CGFloat offset = [self _offsetForCarousel:carousel];
    //    offset += carouselRecord.headerHeight;
    offset += carouselRecord.carouselHeight;
    return [self _CGRectFromVerticalOffset:offset height:carouselRecord.footerHeight];
}

- (CGRect)rectForScrollViewInCarousel:(NSInteger)carousel
{
    [self _updateCarouselCacheIfNeeded];
    HCCarouselViewRow *carouselRecord = [_carousels objectAtIndex:carousel];
    CGFloat offset = [self _offsetForCarousel:carousel];
    offset += carouselRecord.headerHeight;
    return [self _CGRectFromVerticalOffset:offset height:carouselRecord.itemHeight];
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self _updateCarouselCacheIfNeeded];
    
    if (indexPath && indexPath.carousel < [_carousels count]) {
        HCCarouselViewRow *carouselRecord = [_carousels objectAtIndex:indexPath.carousel];
        const NSUInteger item = indexPath.item;
        
        if (item < carouselRecord.numberOfItems) {
            
            //            CGFloat offset = 10;
            //
            //            if (carouselRecord.subviews.count > 0) {
            //                offset = CGRectGetMaxX([[carouselRecord.subviews lastObject] frame]) + 5;
            //            } else {
            //                offset = 5;
            //            }
            CGSize size;
            if ([self.delegate respondsToSelector:@selector(carouselView:sizeForItemsInCarousel:)]) {
                size = [self.delegate carouselView:self sizeForItemsInCarousel:indexPath.carousel];
                if (size.height > carouselRecord.itemHeight) {
                    size.height = carouselRecord.itemHeight;
                }
            } else {
                size.width = [self.delegate respondsToSelector:@selector(carouselView:widthForItemAtIndexPath:)] ? [self.delegate carouselView:self widthForItemAtIndexPath:indexPath] : _HCCarouselViewDefaultItemWidth;
                size.height = carouselRecord.itemHeight;
            }
            CGFloat padding = 10.0;
            if ([self.delegate respondsToSelector:@selector(carouselView:paddingBetweenItemsInCarousel:)]) {
                padding = [self.delegate carouselView:self paddingBetweenItemsInCarousel:indexPath.carousel];
            }
            CGFloat offset = (item * (size.width + padding)) + padding;
            //(carouselRecord.carouselHeight - size.height) / 2.0
            return CGRectMake(offset, 0.0, size.width, size.height);
        }
    }
    
    return CGRectZero;
}

- (NSArray *)carouselsInView
{
    NSMutableArray *carouselsInView = [[NSMutableArray alloc] initWithCapacity:_carousels.count];
    for (HCCarouselView *carouselView in _carousels) {
        if (CGRectIntersectsRect(carouselView.frame, self.frame)) {
            [carouselsInView addObject:carouselView];
        }
    }
    return carouselsInView;
}

- (void)beginUpdates
{
    
}

- (void)endUpdates
{
    
}

- (HCCarouselViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_cachedCells objectForKey:indexPath];
}

// MUST MAKE THIS WORK FOR HORIZONTAL CELLS AND VISIBLE CAROUSELS
//- (NSArray *)indexPathsForItemsInRect:(CGRect)rect
//{
//    [self _updateCarouselCacheIfNeeded];
//
//    NSMutableArray *indexes = [[NSMutableArray alloc] init];
//    const NSInteger numberOfCarousels = [_carousels count];
//    CGFloat offset = 0;
//
//    for (int carousel=0; carousel < numberOfCarousels; carousel++) {
//        HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:carousel];
//        const NSInteger numberOfItems = carouselRecord.numberOfItems;
//
//        offset += carouselRecord.headerHeight;
//
//        if (offset + carouselRecord.innerCarouselHeight >= rect.origin.y) {
//            <#statements#>
//        }
//    }
//}

//- (NSArray *)indexPathsForVisibleItems
//{
//    [self _layoutCarouselView];
//
//    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:[_cachedCells count]];
//    const CGRect bounds = self.bounds;
//
//    for (NSIndexPath *indexPath in [[_cachedCells allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
//        if (CGRectIntersectsRect(bounds, [self rectForItemAtIndexPath:indexPath])) {
//            [indexes addObject:indexPath];
//        }
//    }
//    return indexes;
//}
//
//- (NSArray *)visibleCells
//{
//    NSMutableArray *cells = [[NSMutableArray alloc] init];
//    for (NSIndexPath *index in [self indexPathsForVisibleItems]) {
//        HCCarouselViewCell *cell = [self cellForItemAtIndexPath:index];
//        if (cell) {
//            [cells addObject:cell];
//        }
//    }
//    return cells;
//}

- (NSInteger)numberOfCarousels
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfCarouselsInCarouselView:)]) {
        return [self.dataSource numberOfCarouselsInCarouselView:self];
    } else {
        return 1;
    }
}

- (NSInteger)numberOfItemsInCarousel:(NSInteger)carousel
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(carouselView:numberOfItemsInCarousel:)]) {
        return [self.dataSource carouselView:self numberOfItemsInCarousel:carousel];
    }
    return 0;
}

- (void)reloadData
{
    
    [[_cachedCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reusableCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_cachedCells removeAllObjects];
    [_reusableCells removeAllObjects];
    
    contentOffsetForReload = [[NSMutableDictionary alloc] initWithCapacity:_carousels.count]
    ;
    for (HCCarouselViewRow *carousel in _carousels) {
        
        [contentOffsetForReload setObject:NSStringFromCGPoint(carousel.scrollView.contentOffset) forKey:@(carousel.carousel)];
    }
    
    [self _updateCarouselCache];
    [self _layoutCarouselView];
    //    [self _setContentSize];
    
    _needsReload = NO;
    
}

- (void)_reloadDataIfNeeded
{
    if (_needsReload) {
        [self reloadData];
//        [self _layoutCarouselView];
    }
}

- (void)_setNeedsReload
{
    _needsReload = YES;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [self _reloadDataIfNeeded];
    [self _layoutCarouselView];

    [super layoutSubviews];
}

- (void)setFrame:(CGRect)frame
{
    const CGRect oldFrame = self.frame;
    if (!CGRectEqualToRect(oldFrame, frame)) {
        [super setFrame:frame];
        
        if (oldFrame.size.width != frame.size.width) {
            [self _updateCarouselCache];
        }
        
        [self _setContentSize];
    }
}

- (NSIndexPath *)indexPathForCell:(HCCarouselViewCell *)cell
{
    for (NSIndexPath *index in [_cachedCells allKeys]) {
        if ([_cachedCells objectForKey:index] == cell) {
            return index;
        }
    }
    
    return nil;
}

- (HCCarouselViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    HCCarouselViewCell *cell = nil;
    for (HCCarouselViewCell *reusableCell in _reusableCells) {
        if ([reusableCell.reuseIdentifier isEqualToString:identifier]) {
            cell = reusableCell;
        }
    }
    if (cell) {
        [_reusableCells removeObject:cell];
        [cell prepareForReuse];
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    HCCarouselViewRow *carouselRecord = [_carousels objectAtIndex:scrollView.tag];
    [self _layoutCarousel:carouselRecord];
    
}


- (void)didSelectCell:(HCCarouselViewCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(carouselView:didSelectItemAtIndexPath:)]) {
        [self.delegate carouselView:self didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:cell.item inCarousel:cell.carousel]];
    }
}

- (void)scrollCarouselToTop:(NSInteger)carousel
{
    HCCarouselViewRow *carouselRecord = [_carousels objectAtIndex:carousel];
    [carouselRecord.scrollView setContentOffset:CGPointZero];
}

@end


@implementation NSIndexPath (HCCarouselView)

+ (NSIndexPath *)indexPathForItem:(NSInteger)item inCarousel:(NSInteger)carousel
{
    const NSUInteger index[] = {carousel, item};
    return [NSIndexPath indexPathWithIndexes:index length:2];
    
}

- (NSInteger)item {
    return [self indexAtPosition:1];
}

- (NSInteger)carousel {
    return [self indexAtPosition:0];
}

@end
