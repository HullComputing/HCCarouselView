//
//  HCCarouselViewCarousel.h
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCCarouselView.h"

//#import <HCCarouselView/HCCarouselRowScrollView.h>
@class HCCarouselViewCarousel;

@protocol HCCarouselViewCarouselDelegate <NSObject>

@required
//- (void)addReusableCell:(HCCarouselViewCell *)cell;
- (HCCarouselViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectCell:(HCCarouselViewCell *)cell;
@end

@interface HCCarouselViewCarouselScrollView : UIScrollView
- (void)didSelectCell:(HCCarouselViewCell *)cell;
- (void)removeCell:(HCCarouselViewCell *)cell;
- (id)initWithFrame:(CGRect)frame carouselViewCarousel:(HCCarouselViewCarousel *)carouselViewCarousel;
@end


@interface HCCarouselViewCarousel : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly) CGFloat carouselHeight;
@property (nonatomic, readonly) UIView *headerView;
@property (nonatomic, readonly) UIView *footerView;
@property (nonatomic, readonly) NSInteger numberOfItems;

@property (nonatomic, readonly) HCCarouselViewCarouselScrollView *scrollView;
@property (nonatomic, weak) id<HCCarouselViewCarouselDelegate>delegate;

@property (nonatomic, readonly) NSInteger carouselIndex;
@property (nonatomic, readonly) CGSize itemSize;

@property (nonatomic, readonly) CGFloat scrollViewHeight;
@property (nonatomic, readonly) CGFloat itemPadding;

@property (nonatomic, strong) HCCarouselViewCell *cell;

//- (id)initWithCarouselIndex:(NSInteger)carouselIndex numberOfItems:(NSInteger)numberOfItems itemSize:(CGSize)itemSize scrollViewHeight:(CGFloat)scrollViewHeight viewWidth:(CGFloat)viewWidth itemPadding:(CGFloat)itemPadding;

- (id)initWithCarouselIndex:(NSInteger)carouselIndex headerView:(UIView *)headerView footerView:(UIView *)footerView numberOfItem:(NSInteger)numberOfItems itemSize:(CGSize)itemSize viewWidth:(CGFloat)viewWidth itemPadding:(CGFloat)itemPadding scrollViewHeight:(CGFloat)scrollViewHeight;

//- (void)clearItems;
//
- (void)layoutItems;
//- (void)addCell:(HCCarouselViewCell *)cell;
- (void)removeCell:(HCCarouselViewCell *)cell;
- (void)didSelectCell:(HCCarouselViewCell *)cell;
- (CGRect)visibleRect;
@end