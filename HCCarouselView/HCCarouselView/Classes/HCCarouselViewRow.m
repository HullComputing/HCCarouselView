//
//  HCCarouselViewRow.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCCarouselViewRow.h"


@implementation HCCarouselRowScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    HCCarouselViewCell *cell = nil;
    UIView *view = [touch view];
    if (![view isKindOfClass:[HCCarouselViewCell class]]) {
        UIView *superview = view.superview;
        if ([superview isKindOfClass:[HCCarouselViewCell class]]) {
            cell = (HCCarouselViewCell *)superview;
        }
    } else {
        cell = (HCCarouselViewCell *)view;
    }
    if (cell) {
        [(HCCarouselView *)self.superview didSelectCell:cell];
    }
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end


@interface HCCarouselViewRow ()
//@property (nonatomic, strong) HCCarouselView *superview;

@end

@implementation HCCarouselViewRow

@synthesize itemsWidth, itemHeight, headerHeight, footerHeight, numberOfItems, headerView, footerView, headerTitle, footerTitle, carousel, scrollViewHeight, scrollView;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (CGFloat)carouselHeight
{
    return scrollViewHeight + headerHeight + footerHeight;
}

//
//- (void)setNumberOfItems:(NSInteger)items withWidths:(CGFloat *)newItemWidths
//{
//    itemWidths = realloc(itemWidths, sizeof(CGFloat) * items);
//    memcpy(itemWidths, newItemWidths, sizeof(CGFloat) * items);
//    numberOfItems = items;
//}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    HCCarouselViewCell *cell = nil;
//    UIView *view = [touch view];
//    if (![view isKindOfClass:[HCCarouselViewCell class]]) {
//        UIView *superview = view.superview;
//        if ([superview isKindOfClass:[HCCarouselViewCell class]]) {
//            cell = (HCCarouselViewCell *)superview;
//        }
//    } else {
//        cell = (HCCarouselViewCell *)view;
//    }
//    if (cell) {
//        [(HCCarouselView *)self.superview didSelectCell:cell];
//    }
//}

@end
