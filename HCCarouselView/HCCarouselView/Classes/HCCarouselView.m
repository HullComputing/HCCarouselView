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
#import "UIView+Additions.h"
#import "HCCarouselViewCarouselUpdateOperation.h"

const CGFloat hccv_defaultHeaderFooterHeight = 20.0;
const CGFloat hccv_defaulScrollViewHeight = 44.0;
const CGSize hccv_defaultItemSize = (CGSize){100.0, 44.0};
const CGFloat hccv_defaultItemPadding = 10.0;



@interface HCCarouselView () <HCCarouselViewCarouselDelegate> {
    __weak id<HCCarouselViewDelegate, UIScrollViewDelegate> _delegate;
//    NSMutableDictionary *_cachedCells;
    NSMutableSet *_reusableCells;
    BOOL _needsReload;
//    NSMutableDictionary *_updatingOperations;
//    NSBlockOperation *_updateOperation;
//    NSArray *_previousVisibleCarouselIndices;
}
- (void) hccv_setNeedsReload;

- (CGSize)itemSizeForCarousel:(NSInteger)carouselIndex;
- (CGFloat)heightForHeaderInCarousel:(NSInteger)carouselIndex;
- (CGFloat)heightForFooterInCarousel:(NSInteger)carouselIndex;
- (CGFloat)heightForScrollViewInCarousel:(NSInteger)carouselIndex;
- (CGFloat)horizontalPaddingBetweenItemsInCarousel:(NSInteger)carouselIndex;
- (UIView *)headerViewForCarousel:(NSInteger)carouselIndex;
- (UIView *)footerViewForCarousel:(NSInteger)carouselIndex;


@end

@implementation HCCarouselView
@synthesize delegate = _delegate;

#pragma mark - Object Lifecycle
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
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
//    _cachedCells = [NSMutableDictionary new];
//    _reusableCells = [NSMutableSet new];
//    _updatingOperations = [NSMutableDictionary new];
//    [self hccv_setNeedsReload];
}

#pragma mark - Private Methods
- (void)hccv_updateCarouselCacheIfNeeded
{
    if (!_carouselCache || [_carouselCache count] == 0) {
        [self hccv_updateCarouselCache];
    }
}

- (void)hccv_updateCarouselCache
{
//    if (_updateOperation) {
//        [_updateOperation cancel];
//        _updateOperation = nil;
//    }
//    _updateOperation = [NSBlockOperation blockOperationWithBlock:^{
        const NSInteger numberOfCarousels = [self numberOfCarousels];
        for (HCCarouselView *previousCarouselRecord in _carouselCache.allValues) {
            [previousCarouselRecord removeFromSuperview];
        }
        _carouselCache = [NSMutableDictionary dictionaryWithCapacity:[self numberOfCarousels]];
        
        if (self.delegate) {
            
            for (int carouselIndex = 0; carouselIndex < numberOfCarousels; carouselIndex++) {
                @autoreleasepool {
                    [self hccv_updateCarousel:carouselIndex];
                }
            }
            
        }
//    }];
//    [_updateOperation setQueuePriority:NSOperationQueuePriorityHigh];
//    [[NSOperationQueue mainQueue] addOperation:_updateOperation];
}

- (void)hccv_updateCarousel:(NSInteger)carouselIndex
{
        HCCarouselViewCarousel *carouselRecord = [_carouselCache objectForKey:@(carouselIndex)];
        if (carouselRecord && carouselRecord.superview) {
            [carouselRecord.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [carouselRecord removeFromSuperview];
            carouselRecord = nil;
        }
        NSInteger numberOfItemsInCarousel = [self numberOfItemsInCarousel:carouselIndex];
    carouselRecord = [[HCCarouselViewCarousel alloc] initWithCarouselIndex:carouselIndex headerView:[self headerViewForCarousel:carouselIndex] footerView:[self footerViewForCarousel:carouselIndex] numberOfItem:numberOfItemsInCarousel itemSize:[self itemSizeForCarousel:carouselIndex] viewWidth:self.frame.size.width itemPadding:[self horizontalPaddingBetweenItemsInCarousel:carouselIndex] scrollViewHeight:[self heightForScrollViewInCarousel:carouselIndex]];
        carouselRecord.delegate = self;
//        carouselRecord.scrollView.delegate = self;
        if (carouselRecord.headerView) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:heightForHeaderInCarousel:)]) {
                [carouselRecord.headerView changeFrameHeight:[self.delegate carouselView:self heightForHeaderInCarousel:carouselIndex]];
            }
        }
        if (carouselRecord.footerView) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:heightForFooterInCarousel:)]) {
                [carouselRecord.footerView changeFrameHeight:[self.delegate carouselView:self heightForFooterInCarousel:carouselIndex]];
            }
        }
//    for (UIView *subview in carouselRecord.subviews) {
//        [subview.layer setBorderWidth:0.5];
//        [subview.layer setBorderColor:[[UIColor colorWithRed:(1.0 / carouselIndex) green:.5 blue:.5 alpha:1] CGColor]];
//    }
        [self addSubview:carouselRecord];
        [_carouselCache setObject:carouselRecord forKey:@(carouselIndex)];
}

- (void)hccv_setContentSize
{
    CGFloat height = 0;
    
    for (HCCarouselViewCarousel *carousel in [_carouselCache allValues]) {
        height += [carousel carouselHeight];
    }
    if (self.carouselViewHeaderView) {
        height += self.carouselViewHeaderView.frame.size.height;
    }
    if (self.carouselViewFooterView) {
        height += self.carouselViewFooterView.frame.size.height;
    }
    [self setContentSize:CGSizeMake(0, height)];
}

- (void)hccv_layoutCarouselView
{
    
    if (self.carouselViewHeaderView) {
        [self.carouselViewHeaderView changeFrameOrigin:CGPointZero];
        [self.carouselViewHeaderView changeFrameWidth:self.bounds.size.width];
    }
    
//    NSMutableDictionary *availableCells = [_cachedCells mutableCopy];
    const NSInteger numberOfCarousels = [_carouselCache count];
//    [_cachedCells removeAllObjects];
    
    for (NSInteger carouselIndex = 0; carouselIndex < numberOfCarousels; carouselIndex++) {
        CGRect carouselRect = [self rectForCarousel:carouselIndex];
        HCCarouselViewCarousel *carouselRecord = [_carouselCache objectForKey:@(carouselIndex)];
        carouselRecord.frame = carouselRect;
        
//            [self hccv_layoutCarousel:carouselIndex];
        
        if (CGRectIntersectsRect([self visibleBounds], carouselRect)) {
            
            if (carouselRecord) {
                [carouselRecord layoutItems];
//                const NSInteger numberOfItems = carouselRecord.numberOfItems;
//                
//                for (NSInteger item = 0; item < numberOfItems; item++) {
//                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inCarousel:carouselIndex];
//                    CGRect itemRect = [self rectForItemAtIndexPath:indexPath];
//                    if (CGRectIntersectsRect([carouselRecord visibleRect], itemRect)) {
//                        HCCarouselViewCell *cell = [availableCells objectForKey:indexPath] ?: [self.delegate carouselView:self cellForItemAtIndexPath:indexPath];
//                       
//                        if (cell) {
//                            cell.item = item;
//                            cell.carousel = carouselIndex;
//                            [_cachedCells setObject:cell forKey:indexPath];
//                            [availableCells removeObjectForKey:indexPath];
//                            cell.frame = itemRect;
//                            [carouselRecord.scrollView addSubview:cell];
////                            [carouselRecord addCell:cell];
//                        }
//                    }
//                }
            }
          
        }
    }

//    for (HCCarouselViewCell *cell in [availableCells allValues]) {
//        if (cell.reuseIdentifier) {
//            [_reusableCells addObject:cell];
//        } else {
//            [cell removeFromSuperview];
//        }
//    }
//    availableCells = nil;

//    NSArray *allCachedCells = [_cachedCells allValues];
//    for (HCCarouselViewCell *cell in _reusableCells) {
//        if (CGRectIntersectsRect([cell.superview convertRect:cell.frame toView:self], [self visibleBounds]) && ![allCachedCells containsObject:cell]) {
//            [cell removeFromSuperview];
//        }
//    }
    
    if (_carouselViewFooterView) {
        CGRect carouselFooterFrame = _carouselViewFooterView.frame;
        carouselFooterFrame.origin = CGPointMake(0, CGRectGetMaxY([self rectForCarousel:([_carouselCache count] - 1)]));
        carouselFooterFrame.size.width = self.bounds.size.width;
        _carouselViewFooterView.frame = carouselFooterFrame;
    }
    
}

//- (void)hccv_layoutCarousel:(NSInteger)carouselIndex
//{
//    HCCarouselViewCarousel *carouselRecord = [_carouselCache objectForKey:@(carouselIndex)];
//    
//    if (carouselRecord) {
//        const NSInteger numberOfItems = carouselRecord.numberOfItems;
//        
//        for (NSInteger item = 0; item < numberOfItems; item++) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inCarousel:carouselIndex];
//            CGRect itemRect = [self rectForItemAtIndexPath:indexPath];
//            if (CGRectIntersectsRect([carouselRecord visibleRect], itemRect)) {
//                HCCarouselViewCell *cell = []
//            }
//        }
//    }
//
//}

//- (void)hccv_layoutAllCarouselViews
//{
//    _previousVisibleCarouselIndices = [self indicesForVisibleCarousels];
//    for (int carouselIndex = 0; carouselIndex < _carouselCache.count; carouselIndex++) {
//        [self hccv_layoutCarousel:carouselIndex];
//    }
//}

//- (void)hccv_layoutCarousel:(NSInteger)carouselIndex
//{
//    HCCarouselViewCarousel *carouselRecord = [_carouselCache objectForKey:@(carouselIndex)];
//    if (CGRectIntersectsRect(carouselRecord.frame, [self visibleBounds])) {
//        [carouselRecord setFrame:[self rectForCarousel:carouselIndex]];
//        [carouselRecord layoutItems];
//        //        [self layoutIfNeeded];
//    } else {
//        [carouselRecord clearItems];
//        
//    }
//}


#pragma mark - Custom Getters and Setters
- (void)setDelegate:(id<HCCarouselViewDelegate, UIScrollViewDelegate>)aDelegate
{
    if (aDelegate && [aDelegate conformsToProtocol:@protocol(HCCarouselViewDelegate)]) {
        _delegate = aDelegate;
        [self hccv_setNeedsReload];
    }
}

#pragma mark - Delegate Methods

- (CGFloat)heightForHeaderInCarousel:(NSInteger)carousel
{
    CGFloat height = 0.0;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(carouselView:viewForHeaderInCarousel:)]) {
            height = [[self.delegate carouselView:self viewForHeaderInCarousel:carousel] frame].size.height;
        } else if ([self.delegate respondsToSelector:@selector(carouselView:heightForHeaderInCarousel:)]) {
            height = [self.delegate carouselView:self heightForHeaderInCarousel:carousel];
        }
    }
    return height;
}

- (CGFloat)heightForFooterInCarousel:(NSInteger)carousel
{
    CGFloat height = 0.0;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(carouselView:viewForFooterInCarousel:)]) {
            height = [[self.delegate carouselView:self viewForFooterInCarousel:carousel] frame].size.height;
        } else if ([self.delegate respondsToSelector:@selector(carouselView:heightForFooterInCarousel:)]) {
            height = [self.delegate carouselView:self heightForFooterInCarousel:carousel];
        }
    }
    return height;
}

- (CGFloat)heightForScrollViewInCarousel:(NSInteger)carousel
{
    CGFloat height = hccv_defaulScrollViewHeight;
    if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:heightForScrollViewInCarousel:)]) {
        height = [self.delegate carouselView:self heightForScrollViewInCarousel:carousel];
    }
    return height;
}

- (CGSize)sizeForItemInCarousel:(NSInteger)carousel
{
    CGSize size = hccv_defaultItemSize;
    if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:sizeForItemsInCarousel:)]) {
        size = [self.delegate carouselView:self sizeForItemsInCarousel:carousel];
    }
    return size;
}

- (NSInteger)numberOfCarousels
{
    NSInteger count = 1;
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfCarouselsInCarouselView:)]) {
        count = [self.delegate numberOfCarouselsInCarouselView:self];
    }
    return count;
}

#pragma mark - Frames
- (CGRect)visibleBounds
{
    CGRect rect = self.bounds;
    rect.origin = self.contentOffset;
    return rect;
}



- (NSInteger)numberOfItemsInCarousel:(NSInteger)carousel
{
    if ([self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:numberOfItemsInCarousel:)]) {
        NSInteger numberOfItems = [self.delegate carouselView:self numberOfItemsInCarousel:carousel];
        return numberOfItems;
    }
    return 0;
}

- (CGSize)itemSizeForCarousel:(NSInteger)carousel
{
    if ([self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:sizeForItemsInCarousel:)]) {
        return [self.delegate carouselView:self sizeForItemsInCarousel:carousel];
    }
    return hccv_defaultItemSize;
}

- (CGFloat)horizontalPaddingBetweenItemsInCarousel:(NSInteger)carousel
{
    CGFloat padding = hccv_defaultItemPadding;
    if ([self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:horizontalPaddingBetweenItemsInCarousel:)]) {
        padding = [self.delegate carouselView:self horizontalPaddingBetweenItemsInCarousel:carousel];
    }
    return padding;
}

- (UIView *)headerViewForCarousel:(NSInteger)carousel
{
    UIView *headerView = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:viewForHeaderInCarousel:)]) {
        headerView = [self.delegate carouselView:self viewForHeaderInCarousel:carousel];
    } else if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:titleForHeaderInCarousel:)]) {
        headerView = [HCCarouselViewCarouselLabel carouselLabelWithTitle:[self.delegate carouselView:self titleForHeaderInCarousel:carousel]];
    }
    return headerView;
}

- (UIView *)footerViewForCarousel:(NSInteger)carousel
{
    UIView *footerView = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:viewForFooterInCarousel:)]) {
        footerView = [self.delegate carouselView:self viewForFooterInCarousel:carousel];
    } else if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:titleForFooterInCarousel:)]) {
        footerView = [HCCarouselViewCarouselLabel carouselLabelWithTitle:[self.delegate carouselView:self titleForFooterInCarousel:carousel]];
    }
    return footerView;
}

- (CGFloat)paddingBetweenCarousels
{
    CGFloat padding = [self.delegate respondsToSelector:@selector(verticalPaddingBetweenCarouselsInCarouselView:)] ? [self.delegate verticalPaddingBetweenCarouselsInCarouselView:self] : 10.0;
   
    return padding;
}

- (HCCarouselViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HCCarouselViewCell *cell = nil;
    if ([self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:cellForItemAtIndexPath:)]) {
        cell = [self.delegate carouselView:self cellForItemAtIndexPath:indexPath];
    }
    return cell;
}

- (void)setCarouselViewHeaderView:(UIView *)aCarouselViewHeaderView
{
    if (aCarouselViewHeaderView != _carouselViewHeaderView) {
        if (_carouselViewHeaderView) {
            [_carouselViewHeaderView removeFromSuperview];
            _carouselViewHeaderView = nil;
        }
        _carouselViewHeaderView = aCarouselViewHeaderView;
        [self hccv_setContentSize];
        [self addSubview:_carouselViewHeaderView];
    }
}

- (void)setCarouselViewFooterView:(UIView *)aCarouselViewFooterView
{
    if (aCarouselViewFooterView != _carouselViewFooterView) {
        if (_carouselViewFooterView) {
            [_carouselViewFooterView removeFromSuperview];
            _carouselViewFooterView = nil;
        }
        _carouselViewFooterView = aCarouselViewFooterView;
        [self hccv_setContentSize];
        [self addSubview:_carouselViewFooterView];
    }
}


#pragma mark - Methods for the various frames.
- (CGRect)_CGRectFromVerticalOffset:(CGFloat)offset height:(CGFloat)height
{
    return CGRectMake(0,offset,self.bounds.size.width,height);
}

- (CGFloat)_offsetForCarousel:(NSInteger)index
{
    CGFloat offset = 0;
    if (index == 0) {
        if (self.carouselViewHeaderView) {
            offset += self.carouselViewHeaderView.frame.size.height;
        }
    } else {
        offset = CGRectGetMaxY([self rectForCarousel:index - 1]);
    }
    return offset;
}

- (CGRect)rectForCarousel:(NSInteger)carousel
{
    [self hccv_updateCarouselCacheIfNeeded];
    CGRect rect = CGRectZero;
    CGFloat offset = [self _offsetForCarousel:carousel];
    HCCarouselViewCarousel *carouselRecord =[_carouselCache objectForKey:@(carousel)];
    if (carouselRecord) {
        rect = [self _CGRectFromVerticalOffset:offset height:carouselRecord.carouselHeight];
    }
    return rect;
    
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rect = CGRectZero;
    rect.size = hccv_defaultItemSize;
    [self hccv_updateCarouselCacheIfNeeded];
    HCCarouselViewCarousel *carouselRecord = [_carouselCache objectForKey:@(indexPath.carousel)];
    if (carouselRecord) {
        rect.size = carouselRecord.itemSize;
        rect.origin.y = (carouselRecord.scrollViewHeight - carouselRecord.itemSize.height) / 2.0;
        rect.origin.x = carouselRecord.itemPadding + (indexPath.item * (carouselRecord.itemPadding + carouselRecord.itemSize.width));
    }
    return rect;
}










- (CGRect)_CGRectFromHorizontalOffset:(CGFloat)offset width:(CGFloat)width height:(CGFloat)height
{
    return CGRectMake(offset, 0, width, height);
}







- (NSArray *)visibleCarousels
{
    NSMutableArray *visibleCarousels = [[NSMutableArray alloc] initWithCapacity:_carouselCache.count];
    for (HCCarouselViewCarousel *carouselRecord in _carouselCache.allValues) {
        if (CGRectIntersectsRect(carouselRecord.frame, [self visibleBounds])) {
            [visibleCarousels addObject:visibleCarousels];
        }
    }
    return [visibleCarousels copy];
}

- (NSArray *)indicesForVisibleCarousels
{
    NSMutableArray *indexArray = [[NSMutableArray alloc] initWithCapacity:[self numberOfCarousels]];
    for (int index = 0; index < [self numberOfCarousels]; index++) {
        if (CGRectIntersectsRect([self rectForCarousel:index], [self visibleBounds])) {
            [indexArray addObject:@(index)];
        }
    }
    return indexArray;
}

- (void)reloadCarousel:(NSInteger)carousel
{
//    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    if (carousel < _carouselCache.count) {
//        NSMutableArray *indexPathArray = [[NSMutableArray alloc] initWithCapacity:_cachedCells.count];
//        for (NSIndexPath *indexPath in _cachedCells.allKeys) {
//            if (indexPath.carousel == carousel) {
//                HCCarouselViewCell *cell = [_cachedCells objectForKey:indexPath];
//                if (cell) {
//                    [cell removeFromSuperview];
//                    [indexPathArray addObject:indexPath];
//                    
//                }
//            }
//        }
//        if (indexPathArray.count) {
//            for (NSIndexPath *indexPath in indexPathArray) {
//                [_cachedCells removeObjectForKey:indexPath];
//            }
//        }
        HCCarouselViewCarousel *carouselRecord = [_carouselCache objectForKey:@(carousel)];
        
        
        if (carouselRecord) {
            [[carouselRecord scrollView] removeFromSuperview];
            [carouselRecord removeFromSuperview];
        }
        
        [_carouselCache removeObjectForKey:@(carousel)];
        [self hccv_updateCarousel:carousel];
//        [self hccv_updateCarouselCache];
        [self hccv_layoutCarouselView];
////        [self hccv_layoutCarousel:carousel];
//        HCCarouselViewCarousel *carouselRecord = [_carouselCache objectForKey:@(carousel)];
        
//        if (carouselRecord && carouselRecord.superview) {
////            [carouselRecord layoutItems];
//        }
    }
}

- (void)reloadData
{
//    [[_cachedCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [_reusableCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [_reusableCells removeAllObjects];
//    [_cachedCells removeAllObjects];
    
    [self hccv_updateCarouselCache];
    [self hccv_layoutCarouselView];
    [self hccv_setContentSize];
    _needsReload = NO;
    
}

- (void)hccv_reloadDataIfNeeded
{
    if (_needsReload) {
        _needsReload = NO;
        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
//        [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
//        [self _layoutCarouselView];
    }
}

- (void)hccv_setNeedsReload
{
    _needsReload = YES;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_needsReload) {
         [self hccv_reloadDataIfNeeded];
    } else {
        BOOL updateCarouselCache = NO;
        NSArray *visibleCarousels = [self visibleCarousels];
        for (HCCarouselViewCarousel *carouselRecord in visibleCarousels) {
            @autoreleasepool {
                
            if ([carouselRecord isKindOfClass:[HCCarouselViewCarousel class]] && carouselRecord.numberOfItems != [self numberOfItemsInCarousel:carouselRecord.carouselIndex]) {
                updateCarouselCache = YES;
            }
            }
        }
        if (updateCarouselCache) {
            [self hccv_updateCarouselCache];
        }
    }
        [self hccv_layoutCarouselView];

}

- (void)setFrame:(CGRect)frame
{
    const CGRect oldFrame = self.frame;
    if (!CGRectEqualToRect(oldFrame, frame)) {
        [super setFrame:frame];
        
        if (oldFrame.size.width != frame.size.width) {
            [self hccv_updateCarouselCache];
        }
        
//        [self _setContentSize];
    }
}

- (NSIndexPath *)indexPathForCell:(HCCarouselViewCell *)cell
{
//    for (NSIndexPath *index in [_cachedCells allKeys]) {
//        if ([_cachedCells objectForKey:index] == cell) {
//            return index;
//        }
//    }
    
    return nil;
}

- (HCCarouselViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    HCCarouselViewCell *cell = nil;
//    for (HCCarouselViewCell *reusableCell in self.reusableCells) {
//        if ([reusableCell.reuseIdentifier isEqualToString:identifier]) {
//            cell = reusableCell;
//        }
//    }
//    if (cell) {
//        [self.reusableCells removeObject:cell];
//        [cell prepareForReuse];
//    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isEqual:self]) {
        [self hccv_layoutCarouselView];
    }
}

//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
////    HCCarouselViewCarousel *carouselRecord = [_carouselCache objectAtIndex:scrollView.tag];
//    [self _layoutCarouselView];
//    
//}



- (void)didSelectCell:(HCCarouselViewCell *)cell
{
//    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        if ([self.delegate respondsToSelector:@selector(carouselView:didSelectItemAtIndexPath:)]) {
            [self.delegate carouselView:self didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:cell.item inCarousel:cell.carousel]];
        }
//    }
}

- (void)scrollCarouselToTop:(NSInteger)carousel
{
    HCCarouselViewCarousel *carouselRecord = [_carouselCache objectForKey:@(carousel)];
    [carouselRecord.scrollView setContentOffset:CGPointZero];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
}

- (void)dealloc
{
//    if (_updateOperation) {
//        [_updateOperation cancel];
//    }
//    for (NSOperation *operation in _updatingOperations) {
//        [operation cancel];
//    }
    _needsReload = NO;
    _carouselCache = nil;
    self.delegate = nil;
    self.delegate = nil;
    
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
