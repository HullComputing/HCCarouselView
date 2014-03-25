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

@interface HCCarouselViewCarouselScrollView : UIScrollView

@end


@interface HCCarouselViewCarousel : NSObject

@property (nonatomic, strong) HCCarouselViewCarouselScrollView *scrollView;

/**
 *  Returns the overall height of the carousel including the header and footer heights.
 *
 *  @return The height of the carousel.
 */
- (CGFloat)carouselHeight;

@property (nonatomic, assign) CGFloat scrollViewHeight;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign) CGSize itemSize;

@property (nonatomic) NSInteger numberOfItems;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, copy) NSString *headerTitle;
@property (nonatomic, copy) NSString *footerTitle;

@property (nonatomic) NSInteger carousel;

- (id)initWithHeader:(UIView *)headerView footer:(UIView *)footerView itemSize:(CGSize)itemSize;

//- (id)initWithCarousel:(NSInteger)carousel startingY:(CGFloat)yPosition carouselHeight:(CGFloat)height headerHeight:(CGFloat)headerHeight footerHeight:(CGFloat)footerHeight width:(CGFloat)width;

@end