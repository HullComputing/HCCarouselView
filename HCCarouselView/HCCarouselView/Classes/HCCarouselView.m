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

const CGFloat _HCCarouselViewDefaultHeaderFooterHeight = 20.0;
const CGFloat _HCCarouselViewDefaultScrollViewHeight = 44.0;
const CGSize _HCCarouselViewDefaultItemSize = (CGSize){100.0, 44.0};
const CGFloat _HCCarouselViewDefaultItemPadding = 10.0;

@interface HCCarouselView () <HCCarouselViewCarouselDelegate> {
    NSMutableDictionary *_carousels;
    BOOL _needsReload;
//    NSArray *_carousels;
    CGFloat _carouselHeaderHeight;
    CGFloat _carouselFooterHeight;
    NSArray *_previousVisibleCarouselIndices;
}
- (void) _setNeedsReload;

@end

@implementation HCCarouselView
//@synthesize delegate=_delegate, delegate = _delegate;
@synthesize carouselFooterHeight=_carouselFooterHeight, carouselHeaderHeight =_carouselHeaderHeight;

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
//    _cachedCells = [[NSMutableDictionary alloc] init];
//    self.reusableCells = [[NSMutableSet alloc] init];
    self.carouselFooterHeight = self.carouselHeaderHeight = 30.0;
    [self setShowsVerticalScrollIndicator:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    [self _setNeedsReload];
}

#pragma mark - Custom Getters and Setters
- (void)setDelegate:(id<HCCarouselViewDelegate, UIScrollViewDelegate>)aDelegate
{
    [super setDelegate:aDelegate];
    CGRect rect = [self rectForCarousel:[self numberOfCarousels]];
    self.contentSize = CGSizeMake(0,CGRectGetMaxY(rect));
    [self _setNeedsReload];
}


- (CGRect)visibleBounds
{
    return (CGRect){self.contentOffset, self.bounds.size};
}

- (NSInteger)numberOfCarousels
{
    if ([self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(numberOfCarouselsInCarouselView:)]) {
        return [self.delegate numberOfCarouselsInCarouselView:self];
    } else {
        return 1;
    }
}

- (NSInteger)numberOfItemsInCarousel:(NSInteger)carousel
{
    if ([self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:numberOfItemsInCarousel:)]) {
        return [self.delegate carouselView:self numberOfItemsInCarousel:carousel];
    }
    return 0;
}

- (CGSize)itemSizeForCarousel:(NSInteger)carousel
{
    if ([self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:sizeForItemsInCarousel:)]) {
        return [self.delegate carouselView:self sizeForItemsInCarousel:carousel];
    }
    return _HCCarouselViewDefaultItemSize;
}

- (CGFloat)heightForHeaderInCarousel:(NSInteger)carousel
{
    CGFloat height = 0;
    if ([self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(carouselView:heightForHeaderInCarousel:)]) {
            height = [self.delegate carouselView:self heightForHeaderInCarousel:carousel];
        }
        if ([self.delegate respondsToSelector:@selector(carouselView:viewForHeaderInCarousel:)]) {
            UIView *headerView = [self.delegate carouselView:self viewForHeaderInCarousel:carousel];
            height = headerView.frame.size.height;
        }
    }
    return height;
}

- (CGFloat)heightForFooterInCarousel:(NSInteger)carousel
{
    CGFloat height = 0;
    if ([self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(carouselView:heightForFooterInCarousel:)]) {
            height = [self.delegate carouselView:self heightForFooterInCarousel:carousel];
        }
        if ([self.delegate respondsToSelector:@selector(carouselView:viewForFooterInCarousel:)]) {
            UIView *footerView = [self.delegate carouselView:self viewForFooterInCarousel:carousel];
            height = footerView.frame.size.height;
        }
    }
    return height;
}

- (CGFloat)horizontalPaddingBetweenItemsInCarousel:(NSInteger)carousel
{
    if ([self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:horizontalPaddingBetweenItemsInCarousel:)]) {
        return [self.delegate carouselView:self horizontalPaddingBetweenItemsInCarousel:carousel];
    }
    return _HCCarouselViewDefaultItemPadding;
}

- (CGSize)sizeForItemInCarousel:(NSInteger)carousel
{
    CGSize size = _HCCarouselViewDefaultItemSize;
    if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:sizeForItemsInCarousel:)]) {
        size = [self.delegate carouselView:self sizeForItemsInCarousel:carousel];
    }
    return size;
}

- (UIView *)headerViewForCarousel:(NSInteger)carousel
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:viewForHeaderInCarousel:)]) {
        return [self.delegate carouselView:self viewForHeaderInCarousel:carousel];
    }
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:titleForHeaderInCarousel:)]) {
        UIView *headerView = [HCCarouselViewCarouselLabel carouselLabelWithTitle:[self.delegate carouselView:self titleForHeaderInCarousel:carousel]];
        CGFloat headerHeight = [self heightForHeaderInCarousel:carousel];
        if (!headerHeight) {
            headerHeight = _HCCarouselViewDefaultHeaderFooterHeight;
        }
        [headerView changeFrameHeight:headerHeight];
        return headerView;
    }
    return nil;
}

- (UIView *)footerViewForCarousel:(NSInteger)carousel
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:viewForFooterInCarousel:)]) {
        UIView *footerView = [self.delegate carouselView:self viewForFooterInCarousel:carousel];
        return footerView;
    }
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:titleForFooterInCarousel:)]) {
        UIView *footerView = [HCCarouselViewCarouselLabel carouselLabelWithTitle:[self.delegate carouselView:self titleForFooterInCarousel:carousel]];
        CGFloat footerHeight = [self heightForFooterInCarousel:carousel];
        if (!footerHeight) {
            footerHeight = _HCCarouselViewDefaultHeaderFooterHeight;
        }
        [footerView changeFrameHeight:footerHeight];
        return footerView;
    }
    return nil;
}

- (CGFloat)heightForScrollViewInCarousel:(NSInteger)carousel
{
    CGFloat height = _HCCarouselViewDefaultScrollViewHeight;
    if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:heightForScrollViewInCarousel:)]) {
        height = [self.delegate carouselView:self heightForScrollViewInCarousel:carousel];
    }
    return height;
}

- (void)_updateCarouselCache
{
    const NSInteger numberOfCarousels = [self numberOfCarousels];
    for (HCCarouselView *carouselRecord in _carousels.allValues) {
        [carouselRecord removeFromSuperview];
    }
    _carousels = [NSMutableDictionary dictionaryWithCapacity:[self numberOfCarousels]];
    
    if (self.delegate) {
        
        for (int carouselIndex = 0; carouselIndex < numberOfCarousels; carouselIndex++) {
            [self _updateCarousel:carouselIndex];
        }
    }
}

- (void)_updateCarousel:(NSInteger)carouselIndex
{
    HCCarouselViewCarousel *carouselRecord = [_carousels objectForKey:@(carouselIndex)];
    if (carouselRecord) {
        [carouselRecord removeFromSuperview];
        carouselRecord = nil;
    }
    NSInteger numberOfItemsInCarousel = [self numberOfItemsInCarousel:carouselIndex];
    
    carouselRecord = [[HCCarouselViewCarousel alloc] initWithFrame:[self rectForCarousel:carouselIndex] carouselIndex:carouselIndex numberOfItems:numberOfItemsInCarousel delegate:self];
    [self addSubview:carouselRecord];
    [_carousels setObject:carouselRecord forKey:@(carouselIndex)];
    
}


- (void)_updateCarouselCacheIfNeeded
{
    if ([_carousels count] == 0) {
        [self _updateCarouselCache];
    }
}


//- (CGSize)contentSize
//{
//    CGFloat height = 0;
//    
//    for (HCCarouselViewCarousel *carousel in _carousels) {
//        height += [carousel carouselHeight];
//    }
//    return CGSizeMake(0, height);
//}

- (void)_layoutAllCarouselViews
{
    [self _updateCarouselCacheIfNeeded];
    _previousVisibleCarouselIndices = [self indicesForVisibleCarousels];
    for (int carouselIndex = 0; carouselIndex < _carousels.count; carouselIndex++) {
        [self _layoutCarousel:carouselIndex];
    }
}

- (void)_layoutCarousel:(NSInteger)carouselIndex
{
    HCCarouselViewCarousel *carouselRecord = [_carousels objectForKey:@(carouselIndex)];
    if (CGRectIntersectsRect(carouselRecord.frame, [self visibleBounds])) {
        [carouselRecord setFrame:[self rectForCarousel:carouselIndex]];
        [carouselRecord layoutItems];
        [self layoutIfNeeded];
    } else {
        [carouselRecord clearItems];
        
    }
}

- (HCCarouselViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HCCarouselViewCell *cell = nil;
    if ([self.delegate conformsToProtocol:@protocol(HCCarouselViewDelegate)] && [self.delegate respondsToSelector:@selector(carouselView:cellForItemAtIndexPath:)]) {
        cell = [self.delegate carouselView:self cellForItemAtIndexPath:indexPath];
    }
    return cell;
}


#pragma mark - Methods for the various frames.
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
    for (NSInteger i = 0; i < index; i++) {
        offset += ([self heightForFooterInCarousel:i] + [self heightForHeaderInCarousel:i] + [self heightForScrollViewInCarousel:i] + [self paddingBetweenCarousels]);
        
    }
    return offset;
}

- (CGFloat)paddingBetweenCarousels
{
    return [self.delegate respondsToSelector:@selector(verticalPaddingBetweenCarouselsInCarouselView:)] ? [self.delegate verticalPaddingBetweenCarouselsInCarouselView:self] : 10.0;
}

//- (CGRect)rectForScrollViewInCarousel:(NSInteger)carousel
//{
//    CGRect rect = CGRectZero;
////    if ([_carousels count] == 0) {
////        [self _updateCarouselCacheIfNeeded];
////    } else {
//        HCCarouselViewCarousel *carouselRecord = [_carousels objectForKey:@(carousel)];
//        CGFloat offset = [self _offsetForCarousel:carousel];
//        offset += carouselRecord.headerHeight;
//        rect = [self _CGRectFromVerticalOffset:offset height:carouselRecord.scrollViewHeight];
////    }
//    return rect;
//}

- (CGRect)rectForCarousel:(NSInteger)carousel
{
    CGRect rect = CGRectZero;
//    if ([_carousels count] == 0) {
//        [self _updateCarouselCacheIfNeeded];
//    } else {
//    CGFloat offset = 0;
//    if (carousel < _carousels.count) {
        CGFloat offset = [self _offsetForCarousel:carousel];
//    }
    rect = [self _CGRectFromVerticalOffset:offset height:([self heightForHeaderInCarousel:carousel] + [self heightForScrollViewInCarousel:carousel] + [self heightForFooterInCarousel:carousel])];
//    }
    if (CGRectGetMaxY(rect) > self.contentSize.height) {
        self.contentSize = CGSizeMake(0, self.contentSize.height + [self carouselFooterHeight]);
    }
    return rect;
    
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
    if (carousel < _carousels.count) {
        [self _updateCarousel:carousel];
        [self _layoutCarousel:carousel];
        HCCarouselViewCarousel *carouselRecord = [_carousels objectForKey:@(carousel)];
        if (carouselRecord && carouselRecord.superview) {
            [carouselRecord layoutItems];
        }
    }
}

- (void)reloadData
{
    
//    [[_cachedCells allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [self.reusableCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [_cachedCells removeAllObjects];
//    [self.reusableCells removeAllObjects];
    
//    contentOffsetForReload = [[NSMutableDictionary alloc] initWithCapacity:_carousels.count]
    ;
//    for (HCCarouselViewCarousel *carousel in _carousels) {
    
//        [contentOffsetForReload setObject:NSStringFromCGPoint(carousel.scrollView.contentOffset) forKey:@(carousel.carousel)];
//    }
    
    [self _updateCarouselCache];
    [self _layoutAllCarouselViews];
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
   
//    [self _layoutAllCarouselViews];
    
        if (!_previousVisibleCarouselIndices || ![_previousVisibleCarouselIndices isEqualToArray:[self indicesForVisibleCarousels]]) {
            [self _layoutAllCarouselViews];
        } else {
            
        }
        
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
    HCCarouselViewCarousel *carouselRecord = [_carousels objectForKey:@(carousel)];
    [carouselRecord.scrollView setContentOffset:CGPointZero];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
}

- (void)dealloc
{
    _needsReload = NO;
    _carousels = nil;
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
