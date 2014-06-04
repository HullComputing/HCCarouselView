//
//  HCCarouselView.h
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <Availability.h>
#import "HCCarouselViewCell.h"

@class HCCarouselView;

/**
 The `HCCarouselViewDelegate` protocol is adopted by an object that will serve as the
 delegate for the carouselView.
 */
@protocol HCCarouselViewDelegate <UIScrollViewDelegate>
@optional

/**
 *  (Optional) Requests a title for the header for the  from the delegate.
 *  The carouselView will display a header in a fixed font.
 *
 *  @param carouselView The carouselView to which the carousel belongs.
 *  @param carousel     The index number of the carousel to which the header belongs.
 *
 *  @return An NSString with the desired header for the carousel referenced.
 */
- (NSString *)carouselView:(HCCarouselView *)carouselView titleForHeaderInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;

/**
 *  (Optional) Requests a title for the footer for the specified carousel from the delegate.
 *  The carouselView will display a footer in a fixed font.
 *
 *  @param carouselView The carouselView to which the carousel belongs.
 *  @param carousel     The index number of the carousel to which the footer belongs.
 *
 *  @return An NSString with the desired footer for the carousel referenced.
 */
- (NSString *)carouselView:(HCCarouselView *)carouselView titleForFooterInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;

/**
 *  (Optional) Requests a height for the header for the specified carousel from the delegate.
 *
 *  @param carouselView The carouselView to which the carousel belongs.
 *  @param carousel     The index number of the carousel to which header belongs.
 *
 *  @return A CGFloat for the height of the header.
 */
- (CGFloat)carouselView:(HCCarouselView *)carouselView heightForScrollViewInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (CGFloat)verticalPaddingBetweenCarouselsInCarouselView:(HCCarouselView *)carouselView __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (CGFloat)carouselView:(HCCarouselView *)carouselView horizontalPaddingBetweenItemsInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (CGFloat)carouselView:(HCCarouselView *)carouselView heightForHeaderInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (CGFloat)carouselView:(HCCarouselView *)carouselView heightForFooterInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (UIView *)carouselView:(HCCarouselView *)carouselView viewForHeaderInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (UIView *)carouselView:(HCCarouselView *)carouselView viewForFooterInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (CGSize)carouselView:(HCCarouselView *)carouselView sizeForItemsInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (void)carouselView:(HCCarouselView *)carouselView didSelectItemAtIndexPath:(NSIndexPath *)indexPath __AVAILABILITY_INTERNAL__IPHONE_6_1;

@required

- (NSInteger)numberOfCarouselsInCarouselView:(HCCarouselView *)carouselView __AVAILABILITY_INTERNAL__IPHONE_6_1;


/*!
 Tells the data source to return the number of items in a given carousel of the carousel view. (required)
 
 @param carouselView
        The carousel-view object requesting the information.
 @param carousel
        The index number identifying the carousel in @p carouselView.
 
 @returns The number of items in @p carousel.
 
 */
- (NSInteger)carouselView:(HCCarouselView *)carouselView numberOfItemsInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;

/**
 *  Tells the data source to return the cell at the given index path.
 *
 *  @param carouselView The carousel-view object requesting the information
 *  @param indexPath    The index path identifying the carousel and item number in @p courselView.
 *
 *  @return An @p HCCarouselView object.
 */
- (HCCarouselViewCell *)carouselView:(HCCarouselView *)carouselView cellForItemAtIndexPath:(NSIndexPath *)indexPath __AVAILABILITY_INTERNAL__IPHONE_6_1;

@end

/**
 `HCCarouselView` is a subclass of `UIScrollView` functioning similar to a `UITableView`
 with multiple horizontal UIScrollViews inside of a vertical UIScrollView.
 */

NS_CLASS_AVAILABLE_IOS(6_1) @interface HCCarouselView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *carouselCache;
- (void)reloadData __AVAILABILITY_INTERNAL__IPHONE_6_1;
- (NSInteger)numberOfCarousels __AVAILABILITY_INTERNAL__IPHONE_6_1;
- (NSInteger)numberOfItemsInCarousel:(NSInteger)section __AVAILABILITY_INTERNAL__IPHONE_6_1;
- (void)scrollCarouselToTop:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;
//- (NSArray *)indexPathsForItemsInRect:(CGRect)rect __AVAILABILITY_INTERNAL__IPHONE_6_1;
//- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point __AVAILABILITY_INTERNAL__IPHONE_6_1;
- (NSIndexPath *)indexPathForCell:(HCCarouselViewCell *)cell __AVAILABILITY_INTERNAL__IPHONE_6_1;
//- (NSArray *)indexPathsForVisibleItems __AVAILABILITY_INTERNAL__IPHONE_6_1;
//- (NSArray *)visibleCells __AVAILABILITY_INTERNAL__IPHONE_6_1;
- (HCCarouselViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier __AVAILABILITY_INTERNAL__IPHONE_6_1;
- (HCCarouselViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (CGRect)rectForCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;
//- (CGRect)rectForHeaderInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;
//- (CGRect)rectForFooterInCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;
//- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (void)didSelectCell:(HCCarouselViewCell *)cell __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (void)beginUpdates __AVAILABILITY_INTERNAL__IPHONE_6_1;
- (void)endUpdates __AVAILABILITY_INTERNAL__IPHONE_6_1;

/**
 *  Reloads a single carousel in the carousel view.
 *
 *  @param carousel The index number of the carousel to be reloaded.
 */
- (void)reloadCarousel:(NSInteger)carousel  __AVAILABILITY_INTERNAL__IPHONE_6_1;

//- (void)insertCarousels:(NSIndexSet *)carousels withRowAnimation:(UITableViewRowAnimation)animation __AVAILABILITY_INTERNAL__IPHONE_6_1;
//- (void)deleteCarousel:(NSIndexSet *)carousels withRowAnimation:(UITableViewRowAnimation)animation __AVAILABILITY_INTERNAL__IPHONE_6_1;

//- (NSIndexPath *)indexPathForSelectedItem __AVAILABILITY_INTERNAL__IPHONE_6_1;

- (NSArray *)visibleCarousels __AVAILABILITY_INTERNAL__IPHONE_6_1;

@property (nonatomic, weak) id<HCCarouselViewDelegate, UIScrollViewDelegate> delegate __AVAILABILITY_INTERNAL__IPHONE_6_1;
//@property (nonatomic) CGFloat carouselHeight;
//@property (nonatomic) CGFloat carouselHeaderHeight;
//@property (nonatomic) CGFloat carouselFooterHeight;
@property (nonatomic, strong) UIView *carouselViewHeaderView;
@property (nonatomic, strong) UIView *carouselViewFooterView;

@end

@interface NSIndexPath (HCCarouselView)


+ (NSIndexPath *)indexPathForItem:(NSInteger)item inCarousel:(NSInteger)carousel __AVAILABILITY_INTERNAL__IPHONE_6_1;
//@property (nonatomic, readonly) CGSize contentSize;
@property(nonatomic,readonly) NSInteger item;
@property(nonatomic,readonly) NSInteger carousel;

@end