//
//  Extension.m
//  singlequiz
//
//  Created by KHUN NINE on 8/25/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

#import "Extension.h"

@implementation UIColor (Extension)

+ (UIColor *) appMainColor {
    return [UIColor colorWithRed:185.0/255.0 green:0.0/255.0 blue:52.0/255.0 alpha:1];
}

+ (UIColor *) appCreamColor {
    return [UIColor colorWithRed: 254.0/255.0 green: 255.0/255.0 blue: 187.0/255.0 alpha: 1];
}

+ (UIColor *) appBrownColor {
    return [UIColor colorWithRed:84.0/255.0 green:32.0/255.0 blue:0 alpha:1];
}

+ (UIColor *) appGreenColor {
    return [UIColor colorWithRed:7.0/255.0 green:89.0/255.0 blue:1.0/255.0 alpha:1];
}

+ (UIColor *) appBlueColor {
    return [UIColor colorWithRed:0 green:0 blue:234.0/255.0 alpha:1];
}

@end

@implementation UIViewController (Extension)

// Get the size of current device
- (NSString *) iPhoneScreenSize {
    
    CGSize result = [UIScreen mainScreen].bounds.size;
    
    if(result.height == 480) {
        return @"3.5";
    }
    else if(result.height == 568) {
        return @"4";
    }
    else if(result.height == 667) {
        return @"4.7";
    }
    else if(result.height == 736) {
        return @"5.5";
    }
    else {
        return @"";
    }
}

// Set backgroud image
- (void) setBackgroundImageView: (UIView *) view imagePath: (NSString *) imagePath {
    
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithImage: [UIImage imageNamed:imagePath]];
    backgroundImageView.frame = view.frame;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [view addSubview:backgroundImageView];
    [view sendSubviewToBack:backgroundImageView];
}

@end