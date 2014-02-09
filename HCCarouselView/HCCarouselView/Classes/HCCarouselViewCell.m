//
//  HCMultiSlideViewCell.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCMultiSlideViewCell.h"

extern CGFloat _HCMultiSlideViewDefaultCarouselHeight;

extern CGFloat _HCMultiSlideViewDefaultItemWidth;

@implementation HCMultiSlideViewCell
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
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
//        [self addSubview:self.contentView];
//        [self addSubview:self.titleLabel];
    }
    return self;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
    }
    if (!_contentView.superview) {
        [self addSubview:_contentView];
        [self layoutIfNeeded];
    }
    return _contentView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGRect bounds = self.bounds;
    _contentView.frame = bounds;
    [_contentView setClipsToBounds:YES];

    
}

- (void)prepareForReuse
{
    for (UIView *subview in _contentView.subviews) {
        [subview removeFromSuperview];
    }
    [_contentView removeFromSuperview];
    
}

@end
