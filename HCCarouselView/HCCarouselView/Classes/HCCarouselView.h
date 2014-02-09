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
- (NSInteger)multiSlideView:(HCCarouselView *)multiSlideView numberOfItemsInCarousel:(NSInteger)carousel;
- (HCCarouselViewCell *)multiSlideView:(HCCarouselView *)multiSlideView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfCarouselsInMultiSlideView:(HCCarouselView *)multiSlideView;
- (NSString *)multiSlideView:(HCCarouselView *)multiSlideView titleForHeaderInCarousel:(NSInteger)carousel;
- (NSString *)multiSlideView:(HCCarouselView *)multiSlideView titleForFooterInCarousel:(NSInteger)carousel;

@end

@protocol HCCarouselViewDelegate <UIScrollViewDelegate>
@optional
- (CGFloat)multiSlideView:(HCCarouselView *)multiSlideView heightForCarousel:(NSInteger)carousel;
- (NSIndexPath *)multiSlideView:(HCCarouselView *)multiSlideView willSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)multiSlideView:(HCCarouselView *)multiSlideView widthForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)paddingBetweenCarouselsInMultiSlideView:(HCCarouselView *)multiSlideView;

- (CGFloat)multiSlideView:(HCCarouselView *)multiSlideView heightForHeaderInCarousel:(NSInteger)carousel;
- (CGFloat)multiSlideView:(HCCarouselView *)multiSlideView heightForFooterInCarousel:(NSInteger)carousel;
- (UIView *)multiSlideView:(HCCarouselView *)multiSlideView viewForHeaderInCarousel:(NSInteger)carousel;
- (UIView *)multiSlideView:(HCCarouselView *)multiSlideView viewForFooterInCarousel:(NSInteger)carousel;
- (CGSize)multiSlideView:(HCCarouselView *)multiSlideView sizeForItemsInCarousel:(NSInteger)carousel;
- (void)multiSlideView:(HCCarouselView *)multiSlideView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
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
    
    struct {
        unsigned heightForCarousel : 1;
        unsigned willSelectItemAtIndexPath : 1;
        unsigned heightForHeaderInCarousel : 1;
        unsigned heightForFooterInCarousel : 1;
        unsigned viewForHeaderInCarousel : 1;
        unsigned viewForFooterInCarousel : 1;
        unsigned widthForItemAtIndexPath : 1;
        unsigned sizeForItemsInCarousel : 1;
        unsigned didSelectItemAtIndexPath : 1;
        unsigned paddingBetweenCarousels : 1;
    } _delegateHas;
    
    struct {
        unsigned numberOfCarouselsInMultiSlideView : 1;
        unsigned titleForHeaderInCarousel : 1;
        unsigned titleForFooterInCarousel : 1;
    } _dataSourceHas;
}

- (id)initWithFrame:(CGRect)frame;
- (void)reloadData;
- (NSInteger)numberOfCarousels;
- (NSInteger)numberOfItemsInCarousel:(NSInteger)section;
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