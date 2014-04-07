//
//  HCCarouselViewCarousel.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCCarouselViewCarousel.h"
#import "HCCarouselViewCarouselLabel.h"
#import "UIView+Additions.h"


@implementation HCCarouselViewCarouselScrollView {
    HCCarouselViewCarousel *carouselView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    carouselView = (HCCarouselViewCarousel *)newSuperview;
    [super willMoveToSuperview:newSuperview];
}

- (void)didSelectCell:(HCCarouselViewCell *)cell
{
    if (cell) {
        [carouselView didSelectCell:cell];
    }
}

@end


@interface HCCarouselViewCarousel ()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic) CGSize itemSize;
@property (nonatomic, strong) NSMutableDictionary *cachedCells;
@property (nonatomic, strong) NSArray *oldVisibleIndices;
@end

@implementation HCCarouselViewCarousel


- (id)initWithFrame:(CGRect)frame carouselIndex:(NSInteger)carouselIndex numberOfItems:(NSInteger)numberOfItems delegate:(id<HCCarouselViewCarouselDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.carouselIndex = carouselIndex;
        [self setClipsToBounds:YES];
        self.numberOfItems = numberOfItems;
        self.cachedCells = [[NSMutableDictionary alloc] initWithCapacity:numberOfItems];
        self.delegate = delegate;
    }
    return self;
}

- (void)setDelegate:(id<HCCarouselViewCarouselDelegate>)delegate
{
    _delegate = delegate;
    if (delegate && [delegate conformsToProtocol:@protocol(HCCarouselViewCarouselDelegate)]) {
        [self _layoutMainViews];
    }
}

- (void)dealloc
{
    [self clearItems];
    if (self.scrollView) {
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    }
    if (self.headerView) {
    [self.headerView removeFromSuperview];
    self.headerView = nil;
    }
    if (self.footerView) {
        [self.footerView removeFromSuperview];
        self.footerView = nil;
    }

    self.cachedCells = nil;
    self.oldVisibleIndices = nil;
}


- (void)_layoutMainViews
{
    if (self.headerView) {
        [self addSubview:self.headerView];
    }
    if (self.footerView) {
        [self addSubview:self.footerView];
    }
    if (self.scrollView) {
        [self addSubview:self.scrollView];
    }
    [self _updateViews];
}

- (void)_updateViews
{
    if (self.headerView != nil) {
        [self.headerView changeFrameOrigin:CGPointZero];
        [self.headerView changeFrameWidth:self.frame.size.width];
    }
    if (self.footerView != nil) {
        CGPoint origin = CGPointMake(0, self.bounds.size.height - self.footerView.frame.size.height);
        [self.footerView changeFrameOrigin:origin];
        [self.footerView changeFrameWidth:self.frame.size.width];
    }
    if (self.scrollView != nil) {
        [self.scrollView setFrame:[self frameForScrollView]];
        [self.scrollView setContentSize:CGSizeMake((self.numberOfItems * ([self itemSize].width + [self paddingBetweenCells])) + [self paddingBetweenCells], 0)];
    }
}

- (UIView *)headerView
{
    if (!_headerView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(headerViewForCarousel:)]) {
            self.headerView = [self.delegate headerViewForCarousel:self.carouselIndex];
        }
    }
    return _headerView;
}

- (UIView *)footerView
{
    if (!_footerView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(footerViewForCarousel:)]) {
            self.footerView = [self.delegate footerViewForCarousel:self.carouselIndex];
        }
    }
    return _footerView;
}

- (HCCarouselViewCarouselScrollView *)scrollView
{
    if (!_scrollView) {
         self.scrollView = [[HCCarouselViewCarouselScrollView alloc] initWithFrame:[self frameForScrollView]];
        self.scrollView.delegate = self;
        [self.scrollView setScrollEnabled:YES];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self.scrollView setBounces:NO];

    }
    return _scrollView;
}

- (CGSize)itemSize
{
    CGSize itemSize = CGSizeZero;
    if (self.delegate && [self.delegate respondsToSelector:@selector(sizeForItemInCarousel:)]) {
        itemSize = [self.delegate sizeForItemInCarousel:self.carouselIndex];
    }
    return itemSize;
}

- (CGRect)frameForScrollView
{
    CGRect frame = self.bounds;
    if (self.delegate && [self.delegate respondsToSelector:@selector(heightForScrollViewInCarousel:)]) {
        frame.origin.y = self.headerView.frame.size.height;
        frame.size.height = [self.delegate heightForScrollViewInCarousel:self.carouselIndex];
    }
    return frame;
}

- (CGFloat)carouselHeight
{
    CGFloat height = 0;
    if (self.headerView) {
        height += self.headerView.frame.size.height;
    }
    if (self.scrollView) {
        height += self.scrollView.frame.size.height;
    }
    if (self.footerView) {
        height += self.footerView.frame.size.height;
    }
    return height;
}

- (void)removeFromSuperview
{
    if (self.headerView) {
        [self.headerView removeFromSuperview];
        self.headerView = nil;
    }
    if (self.footerView) {
        [self.footerView removeFromSuperview];
        self.footerView = nil;
    }
    if (self.scrollView) {
        [self.scrollView removeFromSuperview];
        self.scrollView = nil;
    }
    [super removeFromSuperview];
}

- (void)clearItems
{
    for (UIView *subview in self.scrollView.subviews) {
        if ([subview isKindOfClass:[HCCarouselViewCell class]]) { 
            [subview removeFromSuperview];
        }
    }
}

- (void)layoutItems
{
    if (self.numberOfItems) {
        
        for (UIView *subview in self.scrollView.subviews) {
            if ([subview isKindOfClass:[HCCarouselViewCell class]]) {
                if (!CGRectIntersectsRect(subview.frame, [self visibleRect])) {
                    [subview removeFromSuperview];
                }
            }
        }
        self.oldVisibleIndices = [self indicesForVisibleCells];
        for (NSIndexPath *indexPath in self.oldVisibleIndices) {
            HCCarouselViewCell *cell = [self.cachedCells objectForKey:indexPath];
            if (!cell) {
                cell = [self.delegate cellForItemAtIndexPath:indexPath];
                if (cell) {
                    cell.carousel = self.carouselIndex;
                    cell.item = indexPath.item;
                    cell.frame = [self rectForItem:indexPath.item];
                    [self.cachedCells setObject:cell forKey:indexPath];
                }

            }
            if (cell) {
                cell.frame = [self rectForItem:indexPath.item];
                [self.scrollView addSubview:cell];
            }
        }
    }
}


- (CGFloat)paddingBetweenCells
{
    CGFloat padding = 10.0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(horizontalPaddingBetweenItemsInCarousel:)]) {
        padding = [self.delegate horizontalPaddingBetweenItemsInCarousel:self.carouselIndex];
    }
    return padding;
}

- (CGRect)visibleRect
{
    return (CGRect){self.scrollView.contentOffset, self.scrollView.bounds.size};
}

- (CGRect)rectForItem:(NSInteger)item
{
    CGFloat originX = item * (self.itemSize.width + [self paddingBetweenCells]) + [self paddingBetweenCells];
    CGRect rect = (CGRect){originX, (self.scrollView.bounds.size.height - self.itemSize.height) / 2.0, self.itemSize};
    return rect;
}

- (NSArray *)indicesForVisibleCells
{
    NSMutableArray *indexArray = [[NSMutableArray alloc] initWithCapacity:self.numberOfItems];
    for (int index = 0; index < self.numberOfItems; index++) {
        if (CGRectIntersectsRect([self rectForItem:index], [self visibleRect])) {
            [indexArray addObject:[NSIndexPath indexPathForItem:index inCarousel:self.carouselIndex]];
        }
    }
    return indexArray;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *visibleCellIndices = [self indicesForVisibleCells];
    if (![self.oldVisibleIndices isEqualToArray:visibleCellIndices]) {
        for (NSIndexPath *index in self.oldVisibleIndices) {
            if (![visibleCellIndices containsObject:index]) {
                HCCarouselViewCell *cell = [self.cachedCells objectForKey:index];
                if (cell) {
                    [cell removeFromSuperview];
                }
            }
        }
        
        
        [self layoutItems];
    }
}

- (void)didSelectCell:(HCCarouselViewCell *)cell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCell:)]) {
        [self.delegate didSelectCell:cell];
    }
}

@end
