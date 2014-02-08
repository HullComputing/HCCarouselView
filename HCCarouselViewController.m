//
//  HCMultiSlideViewController.m
//  Cobrain
//
//  Created by Aaron Hull on 1/20/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import "HCMultiSlideViewController.h"

@interface HCMultiSlideViewController ()
@property (nonatomic, strong) NSArray *carousels;

@end

@implementation HCMultiSlideViewController

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
        self.multiSlideView.delegate = self;
        self.multiSlideView.dataSource = self;
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
    self.multiSlideView.delegate = self;
    self.multiSlideView.dataSource = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (HCMultiSlideViewCell *)multiSlideView:(HCMultiSlideView *)multiSlideView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)multiSlideView:(HCMultiSlideView *)multiSlideView numberOfItemsInCarousel:(NSInteger)carousel
{
    return 0;
}

@end
