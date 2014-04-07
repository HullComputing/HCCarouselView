//
//  HCCarouselViewController.m
//  Cobrain
//
//  Created by Aaron Hull on 1/20/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCCarouselViewController.h"

@interface HCCarouselViewController ()
@property (nonatomic, strong) NSArray *carousels;

@end

@implementation HCCarouselViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.carouselView.delegate = self;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.carouselView.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (HCCarouselViewCell *)carouselView:(HCCarouselView *)carouselView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)carouselView:(HCCarouselView *)carouselView numberOfItemsInCarousel:(NSInteger)carousel
{
    return 0;
}

@end
