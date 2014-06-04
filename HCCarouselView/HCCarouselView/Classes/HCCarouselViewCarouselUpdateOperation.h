//
//  HCCarouselViewCarouselUpdateOperation.h
//  Pods
//
//  Created by Aaron Hull on 5/12/14.
//
//

#import <Foundation/Foundation.h>

@class HCCarouselView;

@interface HCCarouselViewCarouselUpdateOperation : NSOperation
- (id)initWithCarouselView:(HCCarouselView *)aCarouselView carouselCache:(NSMutableDictionary *)aCarouselCache carouselIndex:(NSInteger)aCarouselIndex;
@end
