//
//  HCCarouselViewController.h
//  Cobrain
//
//  Created by Aaron Hull on 1/20/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCCarouselView.h"

@interface HCCarouselViewController : UIViewController <HCCarouselViewDataSource, HCCarouselViewDelegate>
@property (nonatomic, strong) IBOutlet HCCarouselView *multiSlideView;
@property (nonatomic, strong) NSArray *visibleCells;


@end

