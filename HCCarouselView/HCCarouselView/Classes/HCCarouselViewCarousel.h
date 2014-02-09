//
//  HCCarouselViewCarousel.h
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCCarouselView.h"

@interface HCCarouselViewCarousel : UIScrollView {
    CGFloat itemsWidth;
    CGFloat innerCarouselHeight;
    CGFloat headerHeight;
    CGFloat footerHeight;
    NSInteger numberOfItems;
    UIView *headerView;
    UIView *footerView;
    NSString *headerTitle;
    NSString *footerTitle;
    BOOL isVisible;
}

- (CGFloat)carouselHeight;
- (void)setNumberOfItems:(NSInteger)items withWidths:(CGFloat *)newItemWidths;
- (id)initWithFrame:(CGRect)frame;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign) CGFloat innerCarouselHeight;
@property (nonatomic, readonly) CGFloat *itemWidths;
@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, copy) NSString *headerTitle;
@property (nonatomic, copy) NSString *footerTitle;
@property (nonatomic, assign) CGFloat itemsWidth;
@property (nonatomic) NSInteger carousel;
//@property (nonatomic, strong) HCCarouselView *parentView;
//@property (nonatomic, strong) UIView *headerView;
//@property (nonatomic, strong) UIView *footerView;
//@property (nonatomic, strong) NSString *headerTitle;
//@property (nonatomic, strong) NSString *footerTitle;
//
//@property (nonatomic, strong) UICollectionView *collectionView;
//@property (nonatomic) NSInteger carousel;
//- (id)initWithCarousel:(NSInteger)carousel startingY:(CGFloat)yPosition carouselHeight:(CGFloat)height headerHeight:(CGFloat)headerHeight footerHeight:(CGFloat)footerHeight width:(CGFloat)width;

@end