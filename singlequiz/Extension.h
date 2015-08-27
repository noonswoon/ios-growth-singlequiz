//
//  Extension.h
//  singlequiz
//
//  Created by KHUN NINE on 8/25/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (Extension)

+ (UIColor *) appMainColor;
+ (UIColor *) appCreamColor;
+ (UIColor *) appBrownColor;
+ (UIColor *) appGreenColor;
+ (UIColor *) appBlueColor;

@end

@interface UIViewController (Extension)

- (NSString *) iPhoneScreenSize;
- (void) setBackgroundImageView: (UIView *) view imagePath: (NSString *) imagePath;

@end