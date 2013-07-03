//
//  SWNotificationBanner.m
//  
//
//  Created by Sam Watson on 4/07/13.
//
//

#import <QuartzCore/QuartzCore.h>

#import "SWNotificationBanner.h"

@implementation SWNotificationBanner

- (id)initWithText:(NSString *)text tintColor:(UIColor *)tintColor {
    self = [super initWithFrame:CGRectMake(10, 0, 300, 40)];
    
    if (self) {
        self.tintColor = tintColor;
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(0, 10);
        self.layer.shadowRadius = 20;
        self.layer.shadowOpacity = 0.8;
        
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.numberOfLines = 0;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        self.textLabel.shadowOffset = CGSizeMake(0, 1);
        
        self.textLabel.text = text;
        self.textLabel.frame = CGRectInset(self.bounds, 5, 5);
        [self.textLabel sizeToFit];
        self.frame = CGRectMake(10, 0, 300, MAX(self.frame.size.height, self.textLabel.frame.size.height + 10));
        self.textLabel.frame = CGRectInset(self.bounds, 5, 5);
        
        [self setupGradient];
        [self addSubview:self.textLabel];
    }
    
    return self;
}

- (void)setupGradient {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.layer.bounds;
    
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[self gradientColorLight].CGColor,
                            (id)[self gradientColorDark].CGColor,
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    
    gradientLayer.cornerRadius = self.layer.cornerRadius;
    [self.layer addSublayer:gradientLayer];
}

- (UIColor *)gradientColorLight {
    return self.tintColor;
}

- (UIColor *)gradientColorDark {
    float multiplier = 0.7;
    float r, g, b, a;
    [self.tintColor getRed:&r green:&g blue:&b alpha:&a];
    
    return [UIColor colorWithRed:(r * multiplier) green:(g * multiplier) blue:(b * multiplier) alpha:a];
}

- (void)present {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    self.frame = CGRectMake((keyWindow.frame.size.width - self.frame.size.width) / 2, keyWindow.frame.size.height + 10, self.frame.size.width, self.frame.size.height);
    self.alpha = 0.0;
    
    [keyWindow addSubview:self];
    
    [[SWNotificationBannerStack shared] addBanner:self];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.frame = CGRectMake((keyWindow.frame.size.width - self.frame.size.width) / 2, keyWindow.frame.size.height - (self.frame.size.height + 10) + self.heightOffest, self.frame.size.width, self.frame.size.height);
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:5];
    }];
}

- (void)dismiss {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    [[SWNotificationBannerStack shared] removeBanner:self];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.frame = CGRectMake((keyWindow.frame.size.width - self.frame.size.width) / 2, keyWindow.frame.size.height + 10, self.frame.size.width, self.frame.size.height);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)moveToHeight:(float)height {
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.frame = CGRectMake(self.frame.origin.x, height, self.frame.size.width, self.frame.size.height);
    } completion:nil];
}

@end

@implementation SWNotificationBannerStack

+ (SWNotificationBannerStack *)shared {
    static SWNotificationBannerStack *shared = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shared = [[SWNotificationBannerStack alloc] init];
    });
    
    return shared;
}

- (id)init {
    self = [super init];
    if (self) {
        self.stack = [NSMutableArray array];
    }
    return self;
}

- (void)addBanner:(SWNotificationBanner *)banner {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    [self.stack addObject:banner];
    
    float cumulativeHeight = keyWindow.frame.size.height - 10;
    for (int i = self.stack.count - 1; i >= 0; i--) {
        SWNotificationBanner *existingBanner = [self.stack objectAtIndex:i];
        cumulativeHeight -= existingBanner.frame.size.height;
        if (i < self.stack.count - 1) {
            [existingBanner moveToHeight:cumulativeHeight + existingBanner.heightOffest];
        }
        cumulativeHeight -= 10;
    }
}

- (void)removeBanner:(SWNotificationBanner *)banner {
    [self.stack removeObject:banner];
}

@end