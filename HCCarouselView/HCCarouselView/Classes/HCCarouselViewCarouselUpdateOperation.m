//
//  HCCarouselViewCarouselUpdateOperation.m
//  Pods
//
//  Created by Aaron Hull on 5/12/14.
//
//

#import "HCCarouselViewCarouselUpdateOperation.h"
#import "HCCarouselView.h"
#import "HCCarouselViewCarousel.h"
#import "UIView+Additions.h"

@interface HCCarouselView () <HCCarouselViewCarouselDelegate> {
    @protected
    __weak id<HCCarouselViewDelegate, UIScrollViewDelegate> _delegate;
    NSMutableDictionary *_carouselCache;
    NSMutableDictionary *_cachedCells;
    NSMutableSet *_reusableCells;
    BOOL _needsReload;
    NSMutableDictionary *_updatingOperations;
    NSBlockOperation *_updateOperation;
}
- (void) hccv_setNeedsReload;


- (CGSize)itemSizeForCarousel:(NSInteger)carouselIndex;
- (CGFloat)heightForHeaderInCarousel:(NSInteger)carouselIndex;
- (CGFloat)heightForFooterInCarousel:(NSInteger)carouselIndex;
- (CGFloat)heightForScrollViewInCarousel:(NSInteger)carouselIndex;
- (CGFloat)horizontalPaddingBetweenItemsInCarousel:(NSInteger)carouselIndex;
- (UIView *)headerViewForCarousel:(NSInteger)carouselIndex;
- (UIView *)footerViewForCarousel:(NSInteger)carouselIndex;

@end


@interface HCCarouselViewCarouselUpdateOperation () {
    NSInteger carouselIndex;
    BOOL currentlyExecuting;
    BOOL hasFinished;
}
@property (nonatomic, weak) HCCarouselView *carouselView;
@property (nonatomic, weak) NSMutableDictionary *_carouselCache;
@end

@implementation HCCarouselViewCarouselUpdateOperation
@synthesize carouselView, _carouselCache;

- (id)initWithCarouselView:(HCCarouselView *)aCarouselView carouselCache:(NSMutableDictionary *)aCarouselCache carouselIndex:(NSInteger)aCarouselIndex
{
    self = [super init];
    if (self) {
        carouselView = aCarouselView;
        _carouselCache = aCarouselCache;
        carouselIndex = aCarouselIndex;
    }
    return self;
}

- (void)start
{
    NSLog(@"Carousel Update Operation Running: %ld", (long)carouselIndex);
//    currentlyExecuting = YES;
//    HCCarouselViewCarousel *carouselRecord = [_carouselCache objectForKey:@(carouselIndex)];
//    if (carouselRecord && carouselRecord.superview) {
//        [carouselRecord.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//        [carouselRecord removeFromSuperview];
//        carouselRecord = nil;
//    }
//    NSInteger numberOfItemsInCarousel = [carouselView numberOfItemsInCarousel:carouselIndex];
//    
//    carouselRecord = [[HCCarouselViewCarousel alloc] initWithCarouselIndex:carouselIndex numberOfItems:numberOfItemsInCarousel itemSize:[carouselView itemSizeForCarousel:carouselIndex] scrollViewHeight:[carouselView heightForScrollViewInCarousel:carouselIndex] viewWidth:carouselView.frame.size.width itemPadding:[carouselView horizontalPaddingBetweenItemsInCarousel:carouselIndex]];
//    carouselRecord.delegate = carouselView;
//    carouselRecord.scrollView.delegate = carouselView;
//    carouselRecord.headerView = [carouselView headerViewForCarousel:carouselIndex];
//    carouselRecord.footerView = [carouselView footerViewForCarousel:carouselIndex];
//    
//    if (carouselRecord.headerView) {
//        if (carouselView.delegate && [carouselView.delegate respondsToSelector:@selector(carouselView:heightForHeaderInCarousel:)]) {
//            [carouselRecord.headerView changeFrameHeight:[carouselView.delegate carouselView:carouselView heightForHeaderInCarousel:carouselIndex]];
//        }
//    }
//    if (carouselRecord.footerView) {
//        if (carouselView.delegate && [carouselView.delegate respondsToSelector:@selector(carouselView:heightForFooterInCarousel:)]) {
//            [carouselRecord.footerView changeFrameHeight:[carouselView.delegate carouselView:carouselView heightForFooterInCarousel:carouselIndex]];
//        }
//    }
//    if (!self.isCancelled) {
//        [carouselView addSubview:carouselRecord];
//        [_carouselCache setObject:carouselRecord forKey:@(carouselIndex)];
//        hasFinished = YES;
//    }
}

- (BOOL)isFinished
{
    return hasFinished;
}


- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return currentlyExecuting;
}

- (void)cancel
{
    NSLog(@"Canceling operation: %ld", (long)carouselIndex);
    [super cancel];
    _carouselCache = nil;
    carouselView = nil;
}

@end
