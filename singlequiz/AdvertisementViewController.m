//
//  AdvertisementViewController.m
//  singlequiz
//
//  Created by KHUN NINE on 8/25/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdBuddiz/AdBuddiz.h>
#import <Parse/Parse.h>
#import "AdvertisementViewController.h"
#include <stdlib.h>

@interface AdvertisementViewController () <AdBuddizDelegate>
@end

@implementation AdvertisementViewController : NSObject

CustomAlertView *alertView;
int percentForShowingNSAds;

BOOL enabledAds;
BOOL userClickedShareButton;

// MARK: - Setter methods

+ (void) setDelegate {
    [AdBuddiz setDelegate: [AdvertisementViewController alloc].self];
}

+ (void) setUserClickedShare: (BOOL) flag {
    userClickedShareButton = flag;
}

// MARK: - Getter methods

+ (BOOL) isEnabled {
    return enabledAds;
}

+ (BOOL) isUserClickShareButton {
    return userClickedShareButton;
}
    
// MARK: - Controller methods

// Show the advertisments, it should has a few delays before showing up
+ (void) showAds: (double) timeDelay {
    
    BOOL chance = arc4random_uniform(100) < AdvertismentController.percentForShowingNSAds;
    
    // If the AdBuddiz is not ready to show or the chance of showing are less than expect, show the noonswoon ads
    if (![AdBuddiz isReadyToShowAd] || chance) {
        [self showNoonswoonAds:timeDelay];
    }
    else {
        [self setDelegate];
        [self showAdsBuddiz:timeDelay];
    }

}

+ (void) showNoonswoonAds: (double) timeDelay {
    
    CGFloat delay = timeDelay * NSEC_PER_SEC;
    NSTimeInterval time = dispatch_time(DISPATCH_TIME_NOW, delay);
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        
        [self launchAlertView];
    });
}

+ (void) showAdsBuddiz: (double) timeDelay {
    CGFloat delay = timeDelay * NSEC_PER_SEC;
    NSTimeInterval time = dispatch_time(DISPATCH_TIME_NOW, delay);
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        
        [AdBuddiz showAd];
    });
}

+ (void) enebleAds {
    enabledAds = true;
}

+ (void) disableAds {
    enabledAds = false;
}

// MARK: - AdBuddiz Delegate
    
- (void) didHideAd {
    NSLog(@"did hide ad");
}

- (void) didShowAd {
    // Disable ads after it shows
    [AdvertisementViewController disableAds];
}

- (void) didClick {
    [UserLogged adsClicked];
    [UserLogged trackEvent:@"iOS - Clicked Other Ads"];
}

// MARK: - Create the Noonswoon ads
    
+ (void) launchAlertView {
        
    CustomAlertView *alertView = [CustomAlertView alloc];
    alertView.buttonTitles = [NSArray arrayWithObject: @"Cancel"];
    alertView.containerView = [self createContainerView];
    
    [alertView show];
}
//
//    // Create a custom container view, to show more person information
+ (UIView *) createContainerView {
    
    UIImage *adsImg = [UIImage imageNamed: @"NoonswoonAds"];
    
    double imgFactor   = adsImg.size.height/adsImg.size.width;
    double screenWidth = [UIScreen mainScreen].bounds.size.width * 0.85;
    double adsHeight   = screenWidth * imgFactor;
    CGRect frame       = CGRectMake(0, 0, screenWidth, adsHeight);
    
    UIButton *adsButton = [[UIButton alloc] initWithFrame:frame];
    [adsButton setImage:adsImg forState:UIControlStateNormal];
    [adsButton setImage:adsImg forState: UIControlStateHighlighted];
    [adsButton addTarget:self action:@selector(userClickedNSAds) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *view = [[UIView alloc] initWithFrame: frame];
    [view addSubview: adsButton];
    
    return view;
}
//
+ (void) userClickedNSAds {
    // [AdvertisementViewController.alertView close];
    [UserLogged adsClicked];
    [UserLogged trackEvent: @"iOS - Clicked NS Ads"];
    [self openITunes];
}
//    
+ (void) openITunes {
    NSURL *urlString = [NSURL URLWithString: ITUNES_LINK];
    [[UIApplication sharedApplication] openURL: urlString];
}

@end