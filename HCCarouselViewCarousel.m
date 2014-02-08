//
//  HCMultiSlideViewCarousel.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCMultiSlideViewCarousel.h"

@interface HCMultiSlideViewCarousel ()
//@property (nonatomic, strong) HCMultiSlideView *superview;

@end

@implementation HCMultiSlideViewCarousel

@synthesize itemsWidth, itemWidths, innerCarouselHeight, headerHeight, footerHeight, numberOfItems, headerView, footerView, headerTitle, footerTitle, carousel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (CGFloat)carouselHeight
{
    return innerCarouselHeight + headerHeight + footerHeight;
}

- (void)setNumberOfItems:(NSInteger)items withWidths:(CGFloat *)newItemWidths
{
    itemWidths = realloc(itemWidths, sizeof(CGFloat) * items);
    memcpy(itemWidths, newItemWidths, sizeof(CGFloat) * items);
    numberOfItems = items;
}


- (void)dealloc
{
    if (itemWidths) {
        free(itemWidths);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    HCMultiSlideViewCell *cell;
    UIView *view = [touch view];
    if (![view isKindOfClass:[HCMultiSlideViewCell class]]) {
        UIView *superview = view.superview;
        if ([superview isKindOfClass:[HCMultiSlideViewCell class]]) {
            cell = (HCMultiSlideViewCell *)superview;
        }
    } else {
        cell = (HCMultiSlideViewCell *)view;
    }
    if (cell) {
        [(HCMultiSlideView *)self.superview didSelectCell:cell];
    }
}

//static NSString *cellIdentifier = @"HCMultiSlideCollectionCell";

//- (id)initWithCarousel:(NSInteger)carousel startingY:(CGFloat)yPosition carouselHeight:(CGFloat)carouselHeight headerHeight:(CGFloat)headerHeight footerHeight:(CGFloat)footerHeight width:(CGFloat)width
//{
//    
//    CGRect frame = CGRectMake(0, yPosition, width, carouselHeight + headerHeight + footerHeight);
//    self = [super initWithFrame:frame];
//    if (self) {
//        _carousel = carousel;
//        CGFloat currentY = 0;
//        if (headerHeight) {
//            
//            self.headerView = [[HCMultiSlideHeaderFooterView alloc] initWithFrame:CGRectMake(0, currentY, width, headerHeight)];
//            currentY += headerHeight;
//            [self.headerView setBackgroundColor:[UIColor redColor]];
//            [self addSubview:self.headerView];
//        }
//        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
//        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, currentY, width, carouselHeight) collectionViewLayout:flowLayout];
//        [self.collectionView setScrollEnabled:YES];
//        [self.collectionView setDirectionalLockEnabled:YES];
//        [self.collectionView setBackgroundColor:[UIColor greenColor]];
//        [self addSubview:self.collectionView];
//        [self.collectionView setContentSize:CGSizeMake(10000, self.collectionView.frame.size.height)];
//        //        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//        //        [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
//        //
//        //        swipeGesture.delegate = self;
//        //        [self.collectionView addGestureRecognizer:swipeGesture];
//        self.collectionView.delegate = self;
//        self.collectionView.dataSource = self;
//        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
//        currentY += carouselHeight;
//        
//        if (footerHeight) {
//            self.footerView = [[HCMultiSlideHeaderFooterView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), width, footerHeight)];
//            [self.footerView setBackgroundColor:[UIColor blueColor]];
//            [self addSubview:self.footerView];
//        }
//        
//    }
//    return self;
//}

//- (BOOL)gestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
////    self.parentView.scrollEnabled = NO;
//    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft || gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
//        self.parentView.scrollEnabled = NO;
//        return YES;
//    } else {
//        self.parentView.scrollEnabled = YES;
//        return NO;
//    }
//}
//
//- (void)handleSwipe:(UIGestureRecognizer*)gestureRecognizer
//{
//
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    self.parentView.scrollEnabled = NO;
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (!decelerate)
//    {
//        self.parentView.scrollEnabled = YES;
//    }
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    self.parentView.scrollEnabled = YES;
//}


#pragma mark UICollectionViewDelegate


#pragma mark UICollectionViewDataSource
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//    HCMultiSlideCell *cellView = [self.parentView.dataSource multiSlideView:self.parentView cellForCarouselAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inCarousel:self.carousel]];
//    CGRect frame = cell.frame;
//    frame.size.height = cellView.frame.size.height;
//    frame.size.width = cellView.frame.size.width;
//    cell.frame = frame;
//    cellView.frame = cell.bounds;
//    [cell addSubview:cellView];
//    if (!cell) {
//        //        cell = [[HCMultiSlideCell alloc] initWithFrame:CGRectMake(0, 0, msCell.frame.size.width, msCell.frame.size.height)];
//    }
//    
//    //    [collectionView setContentSize:CGSizeMake(CGRectGetMaxX(cell.frame), collectionView.frame.size.height)];
//    return cell;
//    
//}
//
//
//- (NSInteger)numberOfCarouselsInCollectionView:(UICollectionView *)collectionView
//{
//    return 1;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInCarousel:(NSInteger)carousel
//{
//    if ([self.parentView.dataSource respondsToSelector:@selector(multiSlideView:numberOfItemsInCarousel:)]) {
//        return [self.parentView.dataSource multiSlideView:self.parentView numberOfItemsInCarousel:self.carousel];
//    }
//    return 1;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInCarousel:(NSInteger)carousel
//{
//    return CGSizeZero;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInCarousel:(NSInteger)carousel
//{
//    return CGSizeZero;
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [self.parentView.dataSource multiSlideView:self.parentView sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inCarousel:self.carousel]];
//}
//
@end
