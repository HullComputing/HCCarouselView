//
//  HCMultiSlideView.h
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCMultiSlideViewCell.h"

@class HCMultiSlideView;

@protocol HCMultiSlideViewDataSource <NSObject>
@required
- (NSInteger)multiSlideView:(HCMultiSlideView *)multiSlideView numberOfItemsInCarousel:(NSInteger)carousel;
- (HCMultiSlideViewCell *)multiSlideView:(HCMultiSlideView *)multiSlideView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfCarouselsInMultiSlideView:(HCMultiSlideView *)multiSlideView;
- (NSString *)multiSlideView:(HCMultiSlideView *)multiSlideView titleForHeaderInCarousel:(NSInteger)carousel;
- (NSString *)multiSlideView:(HCMultiSlideView *)multiSlideView titleForFooterInCarousel:(NSInteger)carousel;

@end

@protocol HCMultiSlideViewDelegate <UIScrollViewDelegate>
@optional
- (CGFloat)multiSlideView:(HCMultiSlideView *)multiSlideView heightForCarousel:(NSInteger)carousel;
- (NSIndexPath *)multiSlideView:(HCMultiSlideView *)multiSlideView willSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)multiSlideView:(HCMultiSlideView *)multiSlideView widthForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)paddingBetweenCarouselsInMultiSlideView:(HCMultiSlideView *)multiSlideView;

- (CGFloat)multiSlideView:(HCMultiSlideView *)multiSlideView heightForHeaderInCarousel:(NSInteger)carousel;
- (CGFloat)multiSlideView:(HCMultiSlideView *)multiSlideView heightForFooterInCarousel:(NSInteger)carousel;
- (UIView *)multiSlideView:(HCMultiSlideView *)multiSlideView viewForHeaderInCarousel:(NSInteger)carousel;
- (UIView *)multiSlideView:(HCMultiSlideView *)multiSlideView viewForFooterInCarousel:(NSInteger)carousel;
- (CGSize)multiSlideView:(HCMultiSlideView *)multiSlideView sizeForItemsInCarousel:(NSInteger)carousel;
- (void)multiSlideView:(HCMultiSlideView *)multiSlideView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface HCMultiSlideView : UIScrollView <UIScrollViewDelegate> {
    @private
    __unsafe_unretained id<HCMultiSlideViewDataSource> _dataSource;
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
- (NSIndexPath *)indexPathForCell:(HCMultiSlideViewCell *)cell;
//- (NSArray *)indexPathsForVisibleItems;
//- (NSArray *)visibleCells;
- (HCMultiSlideViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (HCMultiSlideViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGRect)rectForCarousel:(NSInteger)carousel;
- (CGRect)rectForHeaderInCarousel:(NSInteger)carousel;
- (CGRect)rectForFooterInCarousel:(NSInteger)carousel;
- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)didSelectCell:(HCMultiSlideViewCell *)cell;

- (void)beginUpdates;
- (void)endUpdates;

//- (void)insertCarousels:(NSIndexSet *)carousels withRowAnimation:(UITableViewRowAnimation)animation;
//- (void)deleteCarousel:(NSIndexSet *)carousels withRowAnimation:(UITableViewRowAnimation)animation;

//- (NSIndexPath *)indexPathForSelectedItem;


@property (nonatomic, assign) id<HCMultiSlideViewDelegate> delegate;
@property (nonatomic, assign) id<HCMultiSlideViewDataSource> dataSource;
//@property (nonatomic) CGFloat carouselHeight;
@property (nonatomic) CGFloat carouselHeaderHeight;
@property (nonatomic) CGFloat carouselFooterHeight;
@property (nonatomic) CGFloat itemWidth;

@end

@interface NSIndexPath (HCMultiSlideView)

+ (NSIndexPath *)indexPathForItem:(NSInteger)item inCarousel:(NSInteger)carousel;

@property(nonatomic,readonly) NSInteger item;
@property(nonatomic,readonly) NSInteger carousel;

@end