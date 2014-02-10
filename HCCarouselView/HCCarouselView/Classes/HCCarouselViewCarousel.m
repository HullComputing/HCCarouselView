//
//  HCCarouselViewCarousel.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCCarouselViewCarousel.h"

@interface HCCarouselViewCarousel ()
//@property (nonatomic, strong) HCCarouselView *superview;

@end

@implementation HCCarouselViewCarousel

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

@end
