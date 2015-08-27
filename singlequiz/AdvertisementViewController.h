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

@end

