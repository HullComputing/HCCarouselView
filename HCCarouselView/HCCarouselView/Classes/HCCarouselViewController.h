//
//  HCCarouselViewController.h
//  Cobrain
//
//  Created by Aaron Hull on 1/20/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HCCarouselView/HCCarouselView.h>

@interface HCCarouselViewController : UIViewController <HCCarouselViewDelegate>
@property (nonatomic, strong) IBOutlet HCCarouselView *carouselView;
@property (nonatomic, copy) NSArray *visibleCells;


@end

