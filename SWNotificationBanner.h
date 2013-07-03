//
//  SWNotificationBanner.h
//  
//
//  Created by Sam Watson on 4/07/13.
//
//

#import <UIKit/UIKit.h>

@interface SWNotificationBanner : UIView

@property (strong, nonatomic)   UIColor     *tintColor;
@property (strong, nonatomic)   UILabel     *textLabel;
@property (nonatomic)           float       heightOffest;

- (id)initWithText:(NSString *)text tintColor:(UIColor *)tintColor;

- (void)present;

@end

@interface SWNotificationBannerStack : NSObject

@property (strong, nonatomic)   NSMutableArray  *stack;

+ (SWNotificationBannerStack *)shared;

- (void)addBanner:(SWNotificationBanner *)banner;
- (void)removeBanner:(SWNotificationBanner *)banner;

@end