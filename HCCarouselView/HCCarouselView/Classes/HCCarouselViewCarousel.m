//
//  HCCarouselViewCarousel.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCCarouselViewCarousel.h"


@implementation HCCarouselViewCarouselScrollView

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

@end


@interface HCCarouselViewCarousel ()
//@property (nonatomic, strong) HCCarouselView *superview;

@end

@implementation HCCarouselViewCarousel


- (id)initWithHeader:(UIView *)headerView footer:(UIView *)footerView itemSize:(CGSize)itemSize
{
    self = [super init];
    if (self) {
        self.headerView = headerView;
        if (self.headerView) {
            self.headerHeight = self.headerView.frame.size.height;
        }
        self.footerView = footerView;
        if (self.footerView) {
            self.footerHeight = self.footerView.frame.size.height;
        }
        
        self.itemSize = itemSize;
        
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (CGFloat)carouselHeight
{
    return self.scrollViewHeight + self.headerHeight + self.footerHeight;
}



@end
