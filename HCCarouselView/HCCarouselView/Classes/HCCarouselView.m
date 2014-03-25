//
//  HCCarouselView.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCCarouselView.h"
#import "HCCarouselViewCarousel.h"
#import "HCCarouselViewCarouselLabel.h"
//#import "HCCarouselRowScrollView.h"

const CGFloat _HCCarouselViewDefaultScrollViewHeight = 44.0;
const CGSize _HCCarouselViewDefaultItemSize = (CGSize){100.0, 44.0};
const CGFloat _HCCarouselViewDefaultHeaderFooterHeight = 20.0;

@interface HCCarouselView () {
    NSMutableDictionary *availableCells;
//    __unsafe_unretained id<HCCarouselViewDataSource> _dataSource;
//    __unsafe_unretained id<HCCarouselViewDelegate, UIScrollViewDelegate> _delegate;
    BOOL _needsReload;
    //    NSIndexPath *_selectedRow;
    NSMutableDictionary *_cachedCells;
    NSMutableSet *_reusableCells;
    NSMutableArray *_carousels;
    CGFloat _carouselHeaderHeight;
    CGFloat _carouselFooterHeight;
}
- (void) _setNeedsReload;
@end

@implementation HCCarouselView
//@synthesize dataSource=_dataSource, delegate = _delegate;
@synthesize carouselFooterHeight=_carouselFooterHeight, carouselHeaderHeight =_carouselHeaderHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _cachedCells = [[NSMutableDictionary alloc] init];
    _carousels = [[NSMutableArray alloc] init];
    _reusableCells = [[NSMutableSet alloc] init];
    
    self.carouselFooterHeight = self.carouselHeaderHeight = 30.0;
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    [self _setNeedsReload];
}

#pragma mark - Custom Getters and Setters

- (void)setDataSource:(id<HCCarouselViewDataSource>)aDataSource
{
    _dataSource = aDataSource;
    [self _setNeedsReload];
    
}

- (void)setDelegate:(id<HCCarouselViewDelegate, UIScrollViewDelegate>)aDelegate
{
    [super setDelegate:aDelegate];
    [self _setNeedsReload];
}

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

- (CGSize)itemSizeForCarousel:(NSInteger)carousel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:sizeForItemsInCarousel:)]) {
        return [self.delegate carouselView:self sizeForItemsInCarousel:carousel];
    }
    return _HCCarouselViewDefaultItemSize;
}

- (CGFloat)headerHeightForCarousel:(NSInteger)carousel
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(carouselView:heightForHeaderInCarousel:)]) {
            return [self.delegate carouselView:self heightForHeaderInCarousel:carousel];
        }
        if ([self.delegate respondsToSelector:@selector(carouselView:viewForHeaderInCarousel:)]) {
            UIView *headerView = [self.delegate carouselView:self viewForHeaderInCarousel:carousel];
            return headerView.frame.size.height;
        }
    }
    return 0;
}

- (CGFloat)footerHeightForCarousel:(NSInteger)carousel
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(carouselView:heightForFooterInCarousel:)]) {
            return [self.delegate carouselView:self heightForFooterInCarousel:carousel];
        }
        if ([self.delegate respondsToSelector:@selector(carouselView:viewForFooterInCarousel:)]) {
            UIView *footerView = [self.delegate carouselView:self viewForFooterInCarousel:carousel];
            return footerView.frame.size.height;
        }
    }
    return 0;
}

- (UIView *)headerViewForCarousel:(NSInteger)carousel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:viewForHeaderInCarousel:)]) {
        return [self.delegate carouselView:self viewForHeaderInCarousel:carousel];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(carouselView:titleForHeaderInCarousel:)]) {
        return [HCCarouselViewCarouselLabel carouselLabelWithTitle:[self.dataSource carouselView:self titleForHeaderInCarousel:carousel]];
    }
    return nil;
}

- (UIView *)footerViewForCarousel:(NSInteger)carousel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:viewForFooterInCarousel:)]) {
        return [self.delegate carouselView:self viewForFooterInCarousel:carousel];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(carouselView:titleForFooterInCarousel:)]) {
        UIView *footerView = [HCCarouselViewCarouselLabel carouselLabelWithTitle:[self.dataSource carouselView:self titleForFooterInCarousel:carousel]];
        CGFloat footerHeight = [self footerHeightForCarousel:carousel];
        if (!footerHeight) {
            footerHeight = _HCCarouselViewDefaultHeaderFooterHeight;
        }
        CGRect footerFrame = footerView.frame;
        footerFrame.size.height = footerHeight;
        footerView.frame = footerFrame;
        return footerView;
    }
    return nil;
}

- (void)_updateCarouselCache
{
    for (HCCarouselViewCarousel *carousel in _carousels) {
        [carousel.headerView removeFromSuperview];
        [carousel.footerView removeFromSuperview];
        [carousel.scrollView removeFromSuperview];
    }
    [_carousels removeAllObjects];
    
    if (_dataSource) {
        const CGFloat defaultCarouselScrollViewHeight = _HCCarouselViewDefaultScrollViewHeight;
        const CGSize defaultItemSize = _HCCarouselViewDefaultItemSize;
        const NSInteger numberOfCarousels = [self numberOfCarousels];
        for (int carouselIndex = 0; carouselIndex < numberOfCarousels; carouselIndex++) {
            const NSInteger numberOfItemsInCarousel = [self numberOfItemsInCarousel:carouselIndex];
            
            
            CGSize itemSize = [self itemSizeForCarousel:carouselIndex];
            UIView *headerView = [self headerViewForCarousel:carouselIndex];
            
            UIView *footerView = [self footerViewForCarousel:carouselIndex];
            
            HCCarouselViewCarousel *carouselRecord = [[HCCarouselViewCarousel alloc] init];
            
            if (carouselRecord.headerView) {
                
                [self addSubview:carouselRecord.headerView];
                [carouselRecord.headerView setHidden:YES];
                carouselRecord.headerHeight = [self.delegate respondsToSelector:@selector(carouselView:heightForHeaderInCarousel:)] ? [self.delegate carouselView:self heightForHeaderInCarousel:carouselIndex] : _carouselHeaderHeight;
            } else {
                carouselRecord.headerHeight = 0;
            }
            
            if (carouselRecord.footerView) {
                [self addSubview:carouselRecord.footerView];
                carouselRecord.footerHeight = [self.delegate respondsToSelector:@selector(carouselView:heightForFooterInCarousel:)] ? [self.delegate carouselView:self heightForFooterInCarousel:carouselIndex] : _carouselFooterHeight;
            } else {
                carouselRecord.footerHeight = 0;
            }
            
            
            carouselRecord.scrollViewHeight = [self.delegate respondsToSelector:@selector(carouselView:heightForScrollViewInCarousel:)] ? [self.delegate carouselView:self heightForScrollViewInCarousel:carouselIndex] : defaultCarouselScrollViewHeight;
            
            carouselRecord.scrollView = [[HCCarouselViewCarouselScrollView alloc] initWithFrame:CGRectMake(0, carouselRecord.headerHeight, self.frame.size.width, carouselRecord.scrollViewHeight)];
            [carouselRecord.scrollView setShowsHorizontalScrollIndicator:NO];
            [carouselRecord.scrollView setShowsVerticalScrollIndicator:NO];
//            NSLog(@"%d", self.subviews.count);
            [self addSubview:carouselRecord.scrollView];
//               NSLog(@"%d", self.subviews.count);
            [carouselRecord.scrollView setTag:carouselIndex];
            [carouselRecord.scrollView setDelegate:self];
            [carouselRecord.scrollView setScrollEnabled:YES];
            [carouselRecord.scrollView setDirectionalLockEnabled:YES];
            
            carouselRecord.carousel = carouselIndex;
            
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
        [self _layoutCarouselView];
        
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
//    if ([_carousels count] == 0) {
//    [self _updateCarouselCacheIfNeeded];
//    } else {
//        
    CGFloat height = 0;
    
    for (HCCarouselViewCarousel *carousel in _carousels) {
        height += [carousel carouselHeight];
    }
    
    self.contentSize = CGSizeMake(0, height);
//    }
}

- (void)_layoutCarouselView
{
   
    
    availableCells = [_cachedCells mutableCopy];
    [_cachedCells removeAllObjects];
//    const CGSize boundsSize = self.bounds.size;
//    const CGFloat contentOffset = self.contentOffset.y;
//    const CGRect visibleBounds = CGRectMake(0, contentOffset, boundsSize.width, boundsSize.height);

    CGFloat viewHeight = 0;
    
    
    const NSInteger numberOfCarousels = [_carousels count];
    
    
    for (NSInteger carousel = 0; carousel < numberOfCarousels; carousel++) {
        CGRect carouselRect = [self rectForCarousel:carousel];
        viewHeight += carouselRect.size.height;
        HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:carousel];

        
//        if (CGRectIntersectsRect(carouselRect, visibleBounds)) {
            if (carouselRecord) {
                
                const CGRect headerRect = [self rectForHeaderInCarousel:carousel];
                const CGRect footerRect = [self rectForFooterInCarousel:carousel];
                const CGRect scrollViewRect = [self rectForScrollViewInCarousel:carousel];
                
                
                CGSize contentSize = self.contentSize;
                if (contentSize.height < CGRectGetMaxY(carouselRecord.scrollView.frame)) {
                    contentSize.height = CGRectGetMaxY(carouselRecord.scrollView.frame);
                    self.contentSize = contentSize;
                }
                

                if (carouselRecord.headerView) {
                    carouselRecord.headerView.frame = headerRect;
                    [carouselRecord.headerView setHidden:NO];
                    
                }
                
                if (carouselRecord.footerView) {
                    carouselRecord.footerView.frame = footerRect;
                }
                [carouselRecord.scrollView setFrame:scrollViewRect];
                
                
//                CGRect visibleScrollViewBounds = CGRectMake(carouselRecord.scrollView.contentOffset.x, 0, carouselRecord.scrollView.bounds.size.width, carouselRecord.scrollView.bounds.size.height);
//                [self _layoutCarousel:carouselRecord];

                
//                if (carouselRecord.numberOfItems) {
//                    for (UIView *subview in carouselRecord.scrollView.subviews) {
//                        if ([subview isKindOfClass:[HCCarouselViewCell class]]) {
//                            [subview removeFromSuperview];
//                        }
//                    }
//                NSLog(@"Cached Cells: %d, AvailableCells: %d\n Subviews: %d", _cachedCells.count, availableCells.count, carouselRecord.scrollView.subviews.count);
                
                    for (NSInteger item = 0; item < carouselRecord.numberOfItems; item++) {
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inCarousel:carouselRecord.scrollView.tag];
                        CGRect itemRect = [self rectForItemAtIndexPath:indexPath];
//                        NSLog(@"%@, %@", NSStringFromCGRect(itemRect), NSStringFromCGRect(visibleScrollViewBounds));
                       
//                        if (CGRectIntersectsRect(itemRect, visibleScrollViewBounds) && itemRect.size.height > 0) {
                        
                            HCCarouselViewCell *cell = [availableCells objectForKey:indexPath] ?: [self.dataSource carouselView:self cellForItemAtIndexPath:indexPath];

                            if (cell) {
                                cell.carousel = indexPath.carousel;
                                cell.item = indexPath.item;
                                [_cachedCells setObject:cell forKey:indexPath];
                                [availableCells removeObjectForKey:indexPath];
                                cell.frame = itemRect;
                                [carouselRecord.scrollView addSubview:cell];
                            }
//                        }
                    }
//                NSLog(@"%d", carouselRecord.scrollView.subviews.count);
//                if (carousel > 1) {
//                    NSLog(@"%@", carouselRecord.scrollView.subviews);
//                }
                
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
                
                
                
                
//                NSString *offsetString = [contentOffsetForReload objectForKey:@(carousel)];
//                if (offsetString) {
//                    CGPoint offset = CGPointFromString(offsetString);
//                    [carouselRecord.scrollView setContentOffset:offset];
//                }
            
//        } else {
//            for (UIView *subview in carouselRecord.scrollView.subviews) {
//                if ([subview isKindOfClass:[HCCarouselViewCell class]]) {
//                    [subview removeFromSuperview];
//                }
//            }
//            
//        }
//        [contentOffsetForReload removeObjectForKey:@(carousel)];
    }
    [self _setContentSize];
}

//- (void)_layoutCarousel:(HCCarouselViewCarousel *)carouselRecord
//{
// 
//}


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
    
    for (NSInteger i=0; i < index; i++) {
        offset += [[_carousels objectAtIndex:i] carouselHeight] + ([self.delegate respondsToSelector:@selector(paddingBetweenCarouselsInCarouselView:)] ? [self.delegate paddingBetweenCarouselsInCarouselView:self] : 0);
    }
    
    return offset;
}

- (CGRect)rectForCarousel:(NSInteger)carousel
{
    if ([_carousels count] == 0) {
        [self _updateCarouselCacheIfNeeded];
        return CGRectZero;
    } else {
    
    HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:carousel];
    CGFloat offset = [self _offsetForCarousel:carousel];
    offset += carouselRecord.headerHeight;
    return [self _CGRectFromVerticalOffset:offset height:[[_carousels objectAtIndex:carousel] itemHeight]];
    }
    
}

- (CGRect)rectForHeaderInCarousel:(NSInteger)carousel
{
    if ([_carousels count] == 0) {
        [self _updateCarouselCacheIfNeeded];
        return CGRectZero;
    } else {
    CGFloat offset = [self _offsetForCarousel:carousel];
    return [self _CGRectFromVerticalOffset:offset height:[[_carousels objectAtIndex:carousel] headerHeight]];
    }
}

- (CGRect)rectForFooterInCarousel:(NSInteger)carousel
{
    if ([_carousels count] == 0) {
        [self _updateCarouselCacheIfNeeded];
        return CGRectZero;
    } else {
    HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:carousel];
    CGFloat offset = [self _offsetForCarousel:carousel];
    //    offset += carouselRecord.headerHeight;
    offset += carouselRecord.carouselHeight;
    return [self _CGRectFromVerticalOffset:offset height:carouselRecord.footerHeight];
    }
}

- (CGRect)rectForScrollViewInCarousel:(NSInteger)carousel
{
    if ([_carousels count] == 0) {
        [self _updateCarouselCacheIfNeeded];
        return CGRectZero;
    } else {
    HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:carousel];
    CGFloat offset = [self _offsetForCarousel:carousel];
    offset += carouselRecord.headerHeight;
    return [self _CGRectFromVerticalOffset:offset height:carouselRecord.itemHeight];
    }
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_carousels count] == 0) {
        [self _updateCarouselCacheIfNeeded];
        return CGRectZero;
    } else {
    
    if (indexPath && indexPath.carousel < [_carousels count]) {
        HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:indexPath.carousel];
        const NSInteger item = indexPath.item;
        
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
            
            return CGRectMake(offset, 0.0, size.width, size.height);
        }
    }
    
    return CGRectZero;
    }
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


- (void)reloadData
{
    
    [[_cachedCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reusableCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_cachedCells removeAllObjects];
    [_reusableCells removeAllObjects];
    
//    contentOffsetForReload = [[NSMutableDictionary alloc] initWithCapacity:_carousels.count]
    ;
//    for (HCCarouselViewCarousel *carousel in _carousels) {
    
//        [contentOffsetForReload setObject:NSStringFromCGPoint(carousel.scrollView.contentOffset) forKey:@(carousel.carousel)];
//    }
    
    [self _updateCarouselCache];
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
    if (_needsReload) {
         [self _reloadDataIfNeeded];
    } else {
   
//    [self _layoutCarouselView];

    [super layoutSubviews];
    }
}

- (void)setFrame:(CGRect)frame
{
    const CGRect oldFrame = self.frame;
    if (!CGRectEqualToRect(oldFrame, frame)) {
        [super setFrame:frame];
        
        if (oldFrame.size.width != frame.size.width) {
            [self _updateCarouselCache];
        }
        
//        [self _setContentSize];
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
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
////    HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:scrollView.tag];
//    [self _layoutCarouselView];
//    
//}


- (void)didSelectCell:(HCCarouselViewCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(carouselView:didSelectItemAtIndexPath:)]) {
        [self.delegate carouselView:self didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:cell.item inCarousel:cell.carousel]];
    }
}

- (void)scrollCarouselToTop:(NSInteger)carousel
{
    HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:carousel];
    [carouselRecord.scrollView setContentOffset:CGPointZero];
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    for (UIView *subview in self.subviews) {
//        if ([subview isKindOfClass:[UIScrollView class]]) {
//            [(UIScrollView *)subview setScrollEnabled:NO];
//        }
//    }
//}
//
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    for (UIView *subview in self.subviews) {
//        if ([subview isKindOfClass:[UIScrollView class]]) {
//            [(UIScrollView *)subview setScrollEnabled:YES];
//        }
//    }
//}

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
