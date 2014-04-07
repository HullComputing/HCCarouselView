//
//  HCCarouselViewCarousel.h
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCCarouselView.h"
//#import "HCCarouselRowScrollView.h"
@class HCCarouselViewCarousel;
@protocol HCCarouselViewCarouselDelegate <NSObject>

@required
- (UIView *)headerViewForCarousel:(NSInteger)carousel;
- (UIView *)footerViewForCarousel:(NSInteger)carousel;

- (CGFloat)heightForScrollViewInCarousel:(NSInteger)carousel;
- (CGFloat)heightForHeaderInCarousel:(NSInteger)carousel;
- (CGFloat)heightForFooterInCarousel:(NSInteger)carousel;

- (HCCarouselViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)horizontalPaddingBetweenItemsInCarousel:(NSInteger)carousel;
- (void)didSelectCell:(HCCarouselViewCell *)cell;
- (CGSize)sizeForItemInCarousel:(NSInteger)carousel;
@end

@interface HCCarouselViewCarouselScrollView : UIScrollView
- (void)didSelectCell:(HCCarouselViewCell *)cell;
@end


@interface HCCarouselViewCarousel : UIView <UIScrollViewDelegate>


///**
// *  Returns the overall height of the carousel including the header and footer heights.
// *
// *  @return The height of the carousel.
// */
//- (CGFloat)carouselHeight;

@property (nonatomic) CGFloat carouselHeight;

@property (nonatomic) NSInteger numberOfItems;

@property (nonatomic, strong) HCCarouselViewCarouselScrollView *scrollView;
@property (nonatomic, assign) id<HCCarouselViewCarouselDelegate>delegate;

@property (nonatomic) NSInteger carouselIndex;

- (id)initWithFrame:(CGRect)frame carouselIndex:(NSInteger)carouselIndex numberOfItems:(NSInteger)numberOfItems delegate:(id<HCCarouselViewCarouselDelegate>)delegate;

- (void)clearItems;

- (void)layoutItems;

- (void)didSelectCell:(HCCarouselViewCell *)cell;

@end