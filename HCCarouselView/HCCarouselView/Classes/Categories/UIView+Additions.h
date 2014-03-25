//
//  UIView+Additions.h
//  Cobrain
//
//  Created by Aaron Hull on 3/25/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

- (void)changeFrameSize:(CGSize)size;
- (void)changeFrameHeight:(CGFloat)height;
- (void)changeFrameWidth:(CGFloat)width;

- (void)changeFrameOrigin:(CGPoint)origin;
- (void)changeFrameOriginX:(CGFloat)originX;
- (void)changeFrameOriginY:(CGFloat)originY;

@end
