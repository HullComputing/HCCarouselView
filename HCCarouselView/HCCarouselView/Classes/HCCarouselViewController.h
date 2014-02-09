//
//  HCMultiSlideViewController.h
//  Cobrain
//
//  Created by Aaron Hull on 1/20/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCMultiSlideView.h"

@interface HCMultiSlideViewController : UIViewController <HCMultiSlideViewDataSource, HCMultiSlideViewDelegate>
@property (nonatomic, strong) IBOutlet HCMultiSlideView *multiSlideView;
@property (nonatomic, strong) NSArray *visibleCells;


@end

