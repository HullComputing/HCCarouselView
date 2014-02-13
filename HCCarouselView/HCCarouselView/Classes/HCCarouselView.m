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

const CGFloat _HCCarouselViewDefaultCarouselHeight = 44.0;
const CGFloat _HCCarouselViewDefaultItemWidth = 100.0;

@interface HCCarouselView () {
    NSMutableDictionary *availableCells;
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
    
    _dataSourceHas.numberOfCarouselsInMultiSlideView = [_dataSource respondsToSelector:@selector(numberOfCarouselsInMultiSlideView:)];
    _dataSourceHas.titleForFooterInCarousel = [_dataSource respondsToSelector:@selector(multiSlideView:titleForFooterInCarousel:)];
   
    
    _dataSourceHas.titleForHeaderInCarousel = [_dataSource respondsToSelector:@selector(multiSlideView:titleForHeaderInCarousel:)];
    
    [self _setNeedsReload];

}

- (void)setDelegate:(id<HCCarouselViewDelegate>)newDelegate
{
//    _delegate = newDelegate;
//    super.delegate = newDelegate;
    [super setDelegate:newDelegate];
    
    _delegateHas.heightForCarousel = [newDelegate respondsToSelector:@selector(multiSlideView:heightForCarousel:)];
    _delegateHas.heightForFooterInCarousel = [newDelegate respondsToSelector:@selector(multiSlideView:heightForFooterInCarousel:)];
    _delegateHas.heightForHeaderInCarousel = [newDelegate respondsToSelector:@selector(multiSlideView:heightForHeaderInCarousel:)];
    _delegateHas.viewForFooterInCarousel = [newDelegate respondsToSelector:@selector(multiSlideView:viewForFooterInCarousel:)];
    _delegateHas.viewForHeaderInCarousel = [newDelegate respondsToSelector:@selector(multiSlideView:viewForHeaderInCarousel:)];
    _delegateHas.willSelectItemAtIndexPath = [newDelegate respondsToSelector:@selector(multiSlideView:willSelectItemAtIndexPath:)];
     _delegateHas.didSelectItemAtIndexPath = [newDelegate respondsToSelector:@selector(multiSlideView:didSelectItemAtIndexPath:)];
    _delegateHas.widthForItemAtIndexPath = [newDelegate respondsToSelector:@selector(multiSlideView:widthForItemAtIndexPath:)];
    _delegateHas.sizeForItemsInCarousel = [newDelegate respondsToSelector:@selector(multiSlideView:sizeForItemsInCarousel:)];
    _delegateHas.paddingBetweenCarousels = [newDelegate respondsToSelector:@selector(paddingBetweenCarouselsInMultiSlideView:)];
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
    for (HCCarouselViewCarousel *carousel in _carousels) {
        [carousel.headerView removeFromSuperview];
        [carousel.footerView removeFromSuperview];
//        [carousel.scrollView removeFromSuperview];
        [carousel removeFromSuperview];
    }
    [_carousels removeAllObjects];
    availableCells = [_cachedCells mutableCopy];
    [_cachedCells removeAllObjects];
    if (_dataSource) {
        const CGFloat defaultCarouselHeight = _HCCarouselViewDefaultCarouselHeight;
        const CGFloat defaultItemWidth = _itemWidth ?: _HCCarouselViewDefaultItemWidth;
        const NSInteger numberOfCarousels = [self numberOfCarousels];
        for (int carousel=0; carousel < numberOfCarousels; carousel++) {
            const NSInteger numberOfItemsInCarousel = [self numberOfItemsInCarousel:carousel];
            
//            HCCarouselViewCarousel *carouselRecord = [[HCCarouselViewCarousel alloc] init];
//            _carouselHeight = _delegateHas.heightForCarousel ? [self.delegate multiSlideView:self heightForCarousel:carousel] : defaultCarouselHeight;
            
            HCCarouselViewCarousel *carouselRecord = [[HCCarouselViewCarousel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, defaultCarouselHeight)];
            carouselRecord.itemHeight = _delegateHas.heightForCarousel ? [self.delegate multiSlideView:self heightForCarousel:carousel] : defaultCarouselHeight;
            //[[HCCarouselViewCarousel alloc] initWithFrame:CGRectMake(0, carouselRecord.headerHeight, self.frame.size.width, _carouselHeight)];
            
            carouselRecord.headerView = _delegateHas.viewForHeaderInCarousel ? [self.delegate multiSlideView:self viewForHeaderInCarousel:carousel] : nil;
            carouselRecord.footerView = _delegateHas.viewForFooterInCarousel ? [self.delegate multiSlideView:self viewForFooterInCarousel:carousel] : nil;
            
            carouselRecord.headerTitle = _dataSourceHas.titleForHeaderInCarousel ? [self.dataSource multiSlideView:self titleForHeaderInCarousel:carousel] : nil;
            carouselRecord.footerTitle = _dataSourceHas.titleForFooterInCarousel ? [self.dataSource multiSlideView:self titleForFooterInCarousel:carousel] : nil;
            
            if (!carouselRecord.headerView && carouselRecord.headerTitle) {
                carouselRecord.headerView = [HCCarouselViewCarouselLabel carouselLabelWithTitle:carouselRecord.headerTitle];
            }
            
            if (!carouselRecord.footerView && carouselRecord.footerTitle) {
                carouselRecord.footerView = [HCCarouselViewCarouselLabel carouselLabelWithTitle:carouselRecord.footerTitle];
            }
            
            if (carouselRecord.headerView) {
                
                [self addSubview:carouselRecord.headerView];
                [carouselRecord.headerView setHidden:YES];
                carouselRecord.headerHeight = _delegateHas.heightForHeaderInCarousel ? [self.delegate multiSlideView:self heightForHeaderInCarousel:carousel] : _carouselHeaderHeight;
            } else {
                carouselRecord.headerHeight = 0;
            }
            
            if (carouselRecord.footerView) {
                [self addSubview:carouselRecord.footerView];
                carouselRecord.footerHeight = _delegateHas.heightForFooterInCarousel ? [self.delegate multiSlideView:self heightForFooterInCarousel:carousel] : _carouselFooterHeight;
            } else {
                carouselRecord.footerHeight = 0;
            }
            
            
            
            
//            carouselRecord = [[UIScrollView alloc] initWithFrame:CGRectMake(0, carouselRecord.headerHeight, self.frame.size.width, carouselHeight)];
            
            carouselRecord.carousel = carousel;
            
            
            
            CGFloat *itemWidths = malloc(numberOfItemsInCarousel * sizeof(CGFloat));
            CGFloat totalItemsWidth = 0;

            for (int item = 0; item < numberOfItemsInCarousel; item++) {
                const CGFloat itemWidth = _delegateHas.widthForItemAtIndexPath ? [self.delegate multiSlideView:self widthForItemAtIndexPath:[NSIndexPath indexPathForItem:item inCarousel:carousel]] : defaultItemWidth;
                itemWidths[item] = itemWidth;
                totalItemsWidth += itemWidth + 10;
            }
            totalItemsWidth += 10;
            
            carouselRecord.itemsWidth = totalItemsWidth;
            [carouselRecord setNumberOfItems:numberOfItemsInCarousel withWidths:itemWidths];
            free(itemWidths);
            carouselRecord.contentSize = CGSizeMake(totalItemsWidth, 0);
            
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
    
    for (HCCarouselViewCarousel *carousel in _carousels) {
        height += [carousel carouselHeight];
    }
    
    self.contentSize = CGSizeMake(0, height);
}

- (void)_layoutCarouselView
{
    const CGSize boundsSize = self.bounds.size;
    const CGFloat contentOffset = self.contentOffset.y;
    const CGRect visibleBounds = CGRectMake(0, contentOffset, boundsSize.width, boundsSize.height);
//    CGRect visibleScrollViewBounds;
    CGFloat viewHeight = 0;
    
   
    const NSInteger numberOfCarousels = [_carousels count];

    
    for (int carousel = 0; carousel < numberOfCarousels; carousel++) {
        CGRect carouselRect = [self rectForCarousel:carousel];
        viewHeight += carouselRect.size.height;
        HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:carousel];
        carouselRecord.frame = carouselRect;
       
        if (CGRectIntersectsRect(carouselRect, visibleBounds)) {
            if (carouselRecord && !carouselRecord.superview) {
                
            
            const CGRect headerRect = [self rectForHeaderInCarousel:carousel];
            const CGRect footerRect = [self rectForFooterInCarousel:carousel];
            const CGRect scrollViewRect = [self rectForScrollViewInCarousel:carousel];
            
//            [carouselRecord setFrame:scrollViewRect];
                
                CGSize contentSize = self.contentSize;
                if (contentSize.height < CGRectGetMaxY(carouselRecord.frame)) {
                    contentSize.height = CGRectGetMaxY(carouselRecord.frame);
                    self.contentSize = contentSize;
                }
                
            [carouselRecord setTag:carousel];
            [carouselRecord setDelegate:self];
            [carouselRecord setScrollEnabled:YES];
            [carouselRecord setDirectionalLockEnabled:YES];
            
            
            
//            const NSInteger numberOfItems = carouselRecord.numberOfItems;
            
            if (carouselRecord.headerView) {
                carouselRecord.headerView.frame = headerRect;
                [carouselRecord.headerView setHidden:NO];
                
            }
            
            if (carouselRecord.footerView) {
                carouselRecord.footerView.frame = footerRect;
            }
                [carouselRecord setFrame:scrollViewRect];
                [self addSubview:carouselRecord];
//            visibleScrollViewBounds = CGRectMake(carouselRecord.contentOffset.x, 0, carouselRecord.bounds.size.width, carouselRecord.bounds.size.height);
            [self _layoutCarousel:carouselRecord];
                
            }
        } else {
            if (carouselRecord.superview) {
                [carouselRecord removeFromSuperview];
            }
            for (UIView *subview in carouselRecord.subviews) {
                if ([subview isKindOfClass:[HCCarouselViewCell class]]) {
                    [subview removeFromSuperview];
                }
            }
            
        }
    }
}

- (void)_layoutCarousel:(HCCarouselViewCarousel *)carouselRecord
{
    if (carouselRecord && carouselRecord.numberOfItems) {
//        for (UIView *subview in carouselRecord.subviews) {
//            if ([subview isKindOfClass:[HCCarouselViewCell class]]) {
//                [subview removeFromSuperview];
//            }
//        }
//       
        
        
        for (int item = 0; item < carouselRecord.numberOfItems; item++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inCarousel:carouselRecord.tag];
            CGRect itemRect = [self rectForItemAtIndexPath:indexPath];
            CGRect visibleBounds = CGRectMake(carouselRecord.contentOffset.x, 0, carouselRecord.frame.size.width, carouselRecord.frame.size.height);
            
            if (CGRectIntersectsRect(itemRect, visibleBounds) && itemRect.size.height > 0) {
                HCCarouselViewCell *cell = [availableCells objectForKey:indexPath] ?: [self.dataSource multiSlideView:self cellForItemAtIndexPath:indexPath];
                if (cell) {
                    cell.carousel = indexPath.carousel;
                    cell.item = indexPath.item;
                    [_cachedCells setObject:cell forKey:indexPath];
                    [availableCells removeObjectForKey:indexPath];
                    cell.frame = itemRect;
                    cell.backgroundColor = self.backgroundColor;
                    [carouselRecord addSubview:cell];
                    
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
        offset += [[_carousels objectAtIndex:i] carouselHeight] + (_delegateHas.paddingBetweenCarousels ? [self.delegate paddingBetweenCarouselsInMultiSlideView:self] : 0);
    }
    
    return offset;
}

- (CGRect)rectForCarousel:(NSInteger)carousel
{
    [self _updateCarouselCacheIfNeeded];
    HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:carousel];
    CGFloat offset = [self _offsetForCarousel:carousel];
     offset += carouselRecord.headerHeight;
    return [self _CGRectFromVerticalOffset:offset height:[[_carousels objectAtIndex:carousel] carouselHeight]];
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
    HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:carousel];
    CGFloat offset = [self _offsetForCarousel:carousel];
//    offset += carouselRecord.headerHeight;
    offset += carouselRecord.carouselHeight;
    return [self _CGRectFromVerticalOffset:offset height:carouselRecord.footerHeight];
}

- (CGRect)rectForScrollViewInCarousel:(NSInteger)carousel
{
    [self _updateCarouselCacheIfNeeded];
    HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:carousel];
    CGFloat offset = [self _offsetForCarousel:carousel];
    offset += carouselRecord.headerHeight;
    return [self _CGRectFromVerticalOffset:offset height:carouselRecord.itemHeight];
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self _updateCarouselCacheIfNeeded];
    
    if (indexPath && indexPath.carousel < [_carousels count]) {
        HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:indexPath.carousel];
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
            if (_delegateHas.sizeForItemsInCarousel) {
                size = [self.delegate multiSlideView:self sizeForItemsInCarousel:indexPath.carousel];
                if (size.height > carouselRecord.itemHeight) {
                    size.height = carouselRecord.itemHeight;
                }
            } else {
                size.width = _delegateHas.widthForItemAtIndexPath ? [self.delegate multiSlideView:self widthForItemAtIndexPath:indexPath] : _HCCarouselViewDefaultItemWidth;
                size.height = carouselRecord.itemHeight;
            }
            
            
            CGFloat offset = (item * (size.width + 10.0)) + 10.0;
            //(carouselRecord.carouselHeight - size.height) / 2.0
            return CGRectMake(offset, 5.0, size.width, size.height);
        }
    }
    
    return CGRectZero;
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
    if ([self.dataSource respondsToSelector:@selector(numberOfCarouselsInMultiSlideView:)]) {
        return [self.dataSource numberOfCarouselsInMultiSlideView:self];
    } else {
        return 1;
    }
}

- (NSInteger)numberOfItemsInCarousel:(NSInteger)carousel
{
    if (_dataSourceHas.numberOfCarouselsInMultiSlideView) {
        return [self.dataSource multiSlideView:self numberOfItemsInCarousel:carousel];
    }
    return 0;
}

- (void)reloadData
{
    
    [[_cachedCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_reusableCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_cachedCells removeAllObjects];
    [_reusableCells removeAllObjects];
    
    [self _updateCarouselCache];
    [self _setContentSize];
    
    _needsReload = NO;
    
}

- (void)_reloadDataIfNeeded
{
    if (_needsReload) {
        [self reloadData];
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
    HCCarouselViewCarousel *carouselRecord = [_carousels objectAtIndex:scrollView.tag];
    [self _layoutCarousel:carouselRecord];
    
}


- (void)didSelectCell:(HCCarouselViewCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(multiSlideView:didSelectItemAtIndexPath:)]) {
        [self.delegate multiSlideView:self didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:cell.item inCarousel:cell.carousel]];
    }
}

@end


@implementation NSIndexPath (HCCarouselView)

+ (NSIndexPath *)indexPathForItem:(NSInteger)item inCarousel:(NSInteger)carousel
{
    const unsigned int index[] = {carousel,item};
    return [NSIndexPath indexPathWithIndexes:index length:2];
    
}

- (NSInteger)item {
    return [self indexAtPosition:1];
}

- (NSInteger)carousel {
    return [self indexAtPosition:0];
}

@end
