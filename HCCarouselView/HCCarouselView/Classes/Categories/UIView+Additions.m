//
//  UIView+Additions.m
//  Cobrain
//
//  Created by Aaron Hull on 3/25/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (void)changeFrameSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}
- (void)changeFrameHeight:(CGFloat)height
{
    CGSize size = self.frame.size;
    size.height = height;
    [self changeFrameSize:size];
}
- (void)changeFrameWidth:(CGFloat)width
{
    CGSize size = self.frame.size;
    size.width = width;
    [self changeFrameSize:size];
}

- (void)changeFrameOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}
- (void)changeFrameOriginX:(CGFloat)originX
{
    CGPoint origin = self.frame.origin;
    origin.x = originX;
    [self changeFrameOrigin:origin];
}
- (void)changeFrameOriginY:(CGFloat)originY
{
    CGPoint origin = self.frame.origin;
    origin.y = originY;
    [self changeFrameOrigin:origin];
}

@end
