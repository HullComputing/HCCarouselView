//
//  HCCarouselView.h
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCCarouselViewCell.h"

@class HCCarouselView;

@protocol HCCarouselViewDataSource <NSObject>
@required
- (NSInteger)carouselView:(HCCarouselView *)carouselView numberOfItemsInCarousel:(NSInteger)carousel;
- (HCCarouselViewCell *)carouselView:(HCCarouselView *)carouselView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfCarouselsInCarouselView:(HCCarouselView *)carouselView;
- (NSString *)carouselView:(HCCarouselView *)carouselView titleForHeaderInCarousel:(NSInteger)carousel;
- (NSString *)carouselView:(HCCarouselView *)carouselView titleForFooterInCarousel:(NSInteger)carousel;

@end

@protocol HCCarouselViewDelegate <UIScrollViewDelegate>
@optional
- (CGFloat)carouselView:(HCCarouselView *)carouselView heightForCarousel:(NSInteger)carousel;
- (NSIndexPath *)carouselView:(HCCarouselView *)carouselView willSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)carouselView:(HCCarouselView *)carouselView widthForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)carouselView:(HCCarouselView *)carouselView heightForScrollViewInCarousel:(NSInteger)carousel;
- (CGFloat)paddingBetweenCarouselsInCarouselView:(HCCarouselView *)carouselView;
- (CGFloat)carouselView:(HCCarouselView *)carouselView paddingBetweenItemsInCarousel:(NSInteger)carousel;
- (CGFloat)carouselView:(HCCarouselView *)carouselView heightForHeaderInCarousel:(NSInteger)carousel;
- (CGFloat)carouselView:(HCCarouselView *)carouselView heightForFooterInCarousel:(NSInteger)carousel;
- (UIView *)carouselView:(HCCarouselView *)carouselView viewForHeaderInCarousel:(NSInteger)carousel;
- (UIView *)carouselView:(HCCarouselView *)carouselView viewForFooterInCarousel:(NSInteger)carousel;
- (CGSize)carouselView:(HCCarouselView *)carouselView sizeForItemsInCarousel:(NSInteger)carousel;
- (void)carouselView:(HCCarouselView *)carouselView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface HCCarouselView : UIScrollView <UIScrollViewDelegate> {
@private
    __unsafe_unretained id<HCCarouselViewDataSource> _dataSource;
    //    CGFloat _carouselHeight;
    BOOL _needsReload;
    //    NSIndexPath *_selectedRow;
    NSMutableDictionary *_cachedCells;
    NSMutableSet *_reusableCells;
    NSMutableArray *_carousels;
    CGFloat _carouselHeaderHeight;
    CGFloat _carouselFooterHeight;
    CGFloat _itemWidth;
}

- (id)initWithFrame:(CGRect)frame;
- (void)reloadData;
- (NSInteger)numberOfCarousels;
- (NSInteger)numberOfItemsInCarousel:(NSInteger)section;
- (void)scrollCarouselToTop:(NSInteger)carousel;
//- (NSArray *)indexPathsForItemsInRect:(CGRect)rect;
//- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;
- (NSIndexPath *)indexPathForCell:(HCCarouselViewCell *)cell;
//- (NSArray *)indexPathsForVisibleItems;
//- (NSArray *)visibleCells;
- (HCCarouselViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (HCCarouselViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGRect)rectForCarousel:(NSInteger)carousel;
- (CGRect)rectForHeaderInCarousel:(NSInteger)carousel;
- (CGRect)rectForFooterInCarousel:(NSInteger)carousel;
- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)didSelectCell:(HCCarouselViewCell *)cell;

- (void)beginUpdates;
- (void)endUpdates;

//- (void)insertCarousels:(NSIndexSet *)carousels withRowAnimation:(UITableViewRowAnimation)animation;
//- (void)deleteCarousel:(NSIndexSet *)carousels withRowAnimation:(UITableViewRowAnimation)animation;

//- (NSIndexPath *)indexPathForSelectedItem;


@property (nonatomic, assign) id<HCCarouselViewDelegate> delegate;
@property (nonatomic, assign) id<HCCarouselViewDataSource> dataSource;
//@property (nonatomic) CGFloat carouselHeight;
@property (nonatomic) CGFloat carouselHeaderHeight;
@property (nonatomic) CGFloat carouselFooterHeight;
@property (nonatomic) CGFloat itemWidth;

@end

@interface NSIndexPath (HCCarouselView)

+ (NSIndexPath *)indexPathForItem:(NSInteger)item inCarousel:(NSInteger)carousel;

@property(nonatomic,readonly) NSInteger item;
@property(nonatomic,readonly) NSInteger carousel;

@end