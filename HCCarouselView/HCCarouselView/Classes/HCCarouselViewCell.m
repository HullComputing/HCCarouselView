//
//  HCCarouselViewCell.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <HCCarouselView/HCCarouselViewCell.h>
#import <HCCarouselView/HCCarouselViewCarousel.h>

extern CGFloat _HCCarouselViewDefaultCarouselHeight;

extern CGFloat _HCCarouselViewDefaultItemWidth;

@interface HCCarouselViewCell ()
@property (nonatomic, unsafe_unretained) HCCarouselViewCarouselScrollView *carouselScrollView;
@end

@implementation HCCarouselViewCell

@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _reuseIdentifier = [reuseIdentifier copy];
        //        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.contentView];
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

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    self.carouselScrollView = (HCCarouselViewCarouselScrollView *)newSuperview;
    [self sendSubviewToBack:self.contentView];
    [super willMoveToSuperview:newSuperview];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self.carouselScrollView removeCell:self];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
//    NSLog(@"%@, %@", [self hitTest:[touch locationInView:self] withEvent:event], self.subviews);
    if (touch) {
        [self.carouselScrollView didSelectCell:self];
    }
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UIView *view = [super hitTest:point withEvent:event];
//    NSLog(@"%@", [view class]);
//    return view;
//}

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

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    UIView *view = [super hitTest:point withEvent:event];
//    NSSet* touches = [event allTouches];
//    NSLog(@"%@", view);
//    return view;
//}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"%@", event);
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"%@", event);
//}

- (void)prepareForReuse
{

}



@end
