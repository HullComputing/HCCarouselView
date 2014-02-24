//
//  HCCarouselViewCell.h
//  Cobrain
//
//  Created by Aaron Hull on 1/22/14.
//  Copyright (c) 2014 Cobrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCCarouselViewCell : UIView {
@private
//    UIView *_contentView;
    NSString *_reuseIdentifier;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size;
- (void)prepareForReuse;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, readonly, copy) NSString *reuseIdentifier;
//@property (nonatomic,  strong) UILabel *titleLabel;
@property (nonatomic) NSInteger carousel;
@property (nonatomic) NSInteger item;
@end
