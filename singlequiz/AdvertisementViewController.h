//
//  AdvertisementViewController.h
//  singlequiz
//
//  Created by KHUN NINE on 8/25/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <singlequiz-Swift.h>

@interface AdvertisementViewController : NSObject

    @property CustomAlertView *alertView;
    @property int percentForShowingNSAds;

    @property BOOL enabledAds;
    @property BOOL userClickedShareButton;

+ (AdvertisementViewController *) sharedInstance;
- (void) setDelegate;
- (void) setUserClickedShare: (BOOL) flag;
- (BOOL) isEnabled;
- (BOOL) isUserClickShareButton;
- (void) showAds: (double) timeDelay;
- (void) showNoonswoonAds: (double) timeDelay;
- (void) showAdsBuddiz: (double) timeDelay;
- (void) enebleAds;
- (void) disableAds;
- (void) didHideAd;
- (void) didShowAd;
- (void) didClick;
- (void) launchAlertView;
- (UIView *) createContainerView;
- (void) userClickedNSAds;
- (void) openITunes;

@end

