//
//  HCCarouselViewCell.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCCarouselViewCell.h"

extern CGFloat _HCCarouselViewDefaultCarouselHeight;

extern CGFloat _HCCarouselViewDefaultItemWidth;

@implementation HCCarouselViewCell
@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size;
{
    self = [self initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        _reuseIdentifier = [reuseIdentifier copy];
//        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.contentView];
//        [self addSubview:self.titleLabel];
    }
    return self;
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    const CGRect bounds = self.bounds;
//    _contentView.frame = bounds;
//    [_contentView setClipsToBounds:YES];
//
//    
//}

- (void)prepareForReuse
{

}

@end
