//
//  HCCarouselViewCarouselLabel.m
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCCarouselViewCarouselLabel.h"

@implementation HCCarouselViewCarouselLabel

+ (HCCarouselViewCarouselLabel *)carouselLabelWithTitle:(NSString *)title
{
    HCCarouselViewCarouselLabel *label = [[self alloc] init];
    label.text = [NSString stringWithFormat:@"    %@", title];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.5];
    label.textColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.backgroundColor = [UIColor clearColor];
    return label;
}

@end
