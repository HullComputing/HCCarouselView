//
//  HCCarouselViewCarousel.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <HCCarouselView/HCCarouselViewCarousel.h>
#import <HCCarouselView/HCCarouselViewCarouselLabel.h>
#import "UIView+Additions.h"
#import <execinfo.h>

@interface HCCarouselViewCarouselScrollView ()
@property (nonatomic, unsafe_unretained) HCCarouselViewCarousel *parentView;
@end

@implementation HCCarouselViewCarouselScrollView

- (id)initWithFrame:(CGRect)frame carouselViewCarousel:(HCCarouselViewCarousel *)carouselViewCarousel
{
    self = [super initWithFrame:frame];
    if (self) {
        self.parentView = carouselViewCarousel;
    }
    return self;
}

- (void)didSelectCell:(HCCarouselViewCell *)cell
{
    if (cell) {
        [self.parentView didSelectCell:cell];
    }
}

- (void)removeFromSuperview
{
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[HCCarouselViewCell class]]) {
            [subview removeFromSuperview];
        }
    }
    [super removeFromSuperview];
}

- (void)removeCell:(HCCarouselViewCell *)cell
{
    [self.parentView removeCell:cell];
    [self layoutIfNeeded];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

@end


@interface HCCarouselViewCarousel () {
        NSMutableDictionary *_cachedCells;
}

@property (nonatomic, strong, readwrite) HCCarouselViewCarouselScrollView *scrollView;
@property (nonatomic, copy) NSArray *oldVisibleIndices;
@property (nonatomic, strong) NSMutableArray *cells;

@property (nonatomic, readwrite) UIView *headerView;
@property (nonatomic, readwrite) UIView *footerView;
@end

@implementation HCCarouselViewCarousel


//- (id)initWithCarouselIndex:(NSInteger)carouselIndex numberOfItems:(NSInteger)numberOfItems itemSize:(CGSize)itemSize scrollViewHeight:(CGFloat)scrollViewHeight viewWidth:(CGFloat)viewWidth itemPadding:(CGFloat)itemPadding
//{
//    self = [super init];
//    if (self) {
//        self.cells = [[NSMutableArray alloc] initWithCapacity:numberOfItems];
//        _carouselIndex = carouselIndex;
//        _numberOfItems = numberOfItems;
//        _itemPadding = itemPadding;
//        _itemSize = itemSize;
//        _scrollViewHeight = scrollViewHeight;
//        if (scrollViewHeight < itemSize.height) {
//            _scrollViewHeight = itemSize.height;
//        }
//        self.scrollView = [[HCCarouselViewCarouselScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, scrollViewHeight) carouselViewCarousel:self];
////        self.scrollView.delegate = self;
//        [self.scrollView setScrollEnabled:YES];
//        [self.scrollView setShowsHorizontalScrollIndicator:NO];
//        [self.scrollView setShowsVerticalScrollIndicator:NO];
//        [self.scrollView setBounces:NO];
//        [self.scrollView setContentSize:CGSizeMake(itemPadding + (numberOfItems * (itemSize.width + itemPadding)), 0)];
//        [self addSubview:self.scrollView];
//        
//    }
//    return self;
//}

- (id)initWithCarouselIndex:(NSInteger)carouselIndex headerView:(UIView *)headerView footerView:(UIView *)footerView numberOfItem:(NSInteger)numberOfItems itemSize:(CGSize)itemSize viewWidth:(CGFloat)viewWidth itemPadding:(CGFloat)itemPadding scrollViewHeight:(CGFloat)scrollViewHeight
{
    self = [super init];
    if (self) {
        _cachedCells = [NSMutableDictionary dictionaryWithCapacity:numberOfItems];
        _carouselIndex = carouselIndex;
        
        if (headerView) {
            self.headerView = headerView;
            [self addSubview:self.headerView];
        }
        if (footerView) {
            self.footerView = footerView;
            [self addSubview:footerView];
        }
        _numberOfItems = numberOfItems;
        _itemSize = itemSize;
        _itemPadding = itemPadding;
        if (scrollViewHeight < itemSize.height + 2) {
            _scrollViewHeight = itemSize.height + 2;
        } else {
            _scrollViewHeight = scrollViewHeight;
        }
        self.frame = CGRectMake(0, 0, viewWidth?: 320.0, [self carouselHeight]);
        self.scrollView = [[HCCarouselViewCarouselScrollView alloc] initWithFrame:CGRectMake(0, self.headerView ? self.headerView.frame.size.height : 0.0, viewWidth, scrollViewHeight) carouselViewCarousel:self];
       
        [self.scrollView setContentSize:CGSizeMake(itemPadding + (numberOfItems * (itemSize.width + itemPadding)), 0)];
        [self.scrollView setClipsToBounds:YES];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self.scrollView setDelegate:self];
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

//    if (self.scrollView.frame.origin.y != self.headerView.frame.size.height) {
//        [self.scrollView changeFrameOriginY:self.headerView.frame.size.height];
//    }
}

- (void)layoutItems
{
    if (self.delegate) {
        NSMutableDictionary *availableCells = [_cachedCells mutableCopy];
        [_cachedCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_cachedCells removeAllObjects];
        self.oldVisibleIndices = [self indexPathsOfVisibleItems];
        for (NSIndexPath *indexPath in self.oldVisibleIndices) {
            HCCarouselViewCell *cell = [availableCells objectForKey:indexPath] ?: [self.delegate cellForItemAtIndexPath:indexPath];
            if (cell) {
                cell.item = indexPath.item;
                cell.carousel = indexPath.carousel;
                [_cachedCells setObject:cell forKey:indexPath];
                [availableCells removeObjectForKey:indexPath];
                cell.frame = [self rectForItem:indexPath.item];
                [self.scrollView addSubview:cell];
            }
        }
        
        for (HCCarouselViewCell *cell in [availableCells allValues]) {
//            if (cell.reuseIdentifier) {
//                [self.delegate addReusableCell:cell];
//            } else {
                [cell removeFromSuperview];
//            }
        }
        [availableCells removeAllObjects];
        
    }
}

- (NSArray *)indexPathsOfVisibleItems
{
    NSMutableArray *indices = [[NSMutableArray alloc] initWithCapacity:self.numberOfItems];
    for(NSInteger index = 0; index < self.numberOfItems; index++)
    {
        if (CGRectIntersectsRect(self.visibleRect, [self rectForItem:index])) {
            [indices addObject:[NSIndexPath indexPathForItem:index inCarousel:self.carouselIndex]];
        }
    }
    return [indices copy];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL layoutItems = NO;
    for (NSIndexPath *indexPath in self.oldVisibleIndices) {
        if (![[self indexPathsOfVisibleItems] containsObject:indexPath]) {
            layoutItems = YES;
        }
    }
    if (!layoutItems) {
        for (NSIndexPath *indexPath in [self indexPathsOfVisibleItems]) {
            if (![self.oldVisibleIndices containsObject:indexPath]) {
                layoutItems = YES;
            }
        }
    }
    if (layoutItems) {
        [self layoutItems];
    }
}

//- (void)setHeaderView:(UIView *)headerView
//{
//    if (_headerView && ![_headerView isEqual:headerView]) {
//        [_headerView removeFromSuperview];
//        _headerView = nil;
//    }
//    if (!_headerView) {
//        _headerView = headerView;
//        if (_headerView) {
//            [self addSubview:_headerView];
//            [self.scrollView changeFrameOriginY:_headerView.frame.size.height];
//        }
//    }
//}
//
//- (void)setFooterView:(UIView *)footerView
//{
//    if (_footerView && ![_footerView isEqual:footerView]) {
//        [_footerView removeFromSuperview];
//        _footerView = nil;
//    }
//    if (!_footerView) {
//        _footerView = footerView;
//        if (_footerView) {
//            [self addSubview:_footerView];
//        }
//    }
//}

- (CGFloat)carouselHeight
{
    CGFloat height = self.scrollViewHeight;
//    for (UIView *subview in self.subviews) {
//        if (CGRectGetMaxY(subview.frame) > height) {
//            height = CGRectGetMaxY(subview.frame);
//        }
//    }
    if ([self.headerView isKindOfClass:[UIView class]]) {
        height += self.headerView.frame.size.height;
    }
    if ([self.footerView isKindOfClass:[UIView class]]) {
        height += self.footerView.frame.size.height;
    }
    return height;
}

- (void)removeCell:(HCCarouselViewCell *)cell
{
    [self.cells removeObject:cell];
    [self.scrollView layoutIfNeeded];
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

- (void)didSelectCell:(HCCarouselViewCell *)cell
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCell:)]) {
        [self.delegate didSelectCell:cell];
    }
}

- (CGRect)visibleRect
{
    CGRect rect = CGRectZero;
    if (self.scrollView) {
        rect.size = self.scrollView.bounds.size;
        rect.origin = self.scrollView.contentOffset;
    }
    return rect;
}

- (CGRect)rectForItem:(NSInteger)itemIndex
{
    CGRect rect = CGRectZero;
    rect.origin.y = (self.scrollViewHeight - self.itemSize.height) / 2.0;
    rect.size = self.itemSize;
    rect.origin.x = self.itemPadding + (itemIndex * (self.itemSize.width + self.itemPadding));
    return rect;
}

@end
