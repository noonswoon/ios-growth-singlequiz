//
//  DataController.h
//  singlequiz
//
//  Created by KHUN NINE on 8/31/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataController : UIViewController

@property int result;
@property int summation;

@property NSMutableArray *questions;
@property NSMutableArray *choicesList;
@property NSMutableArray *list_questionViewController;

@property NSDictionary *userInfo;

@property UIImage  *userProfileImage;
@property NSString *userFirstNameText;

@property NSString *contentURL;
@property NSString *contentTitle;
@property NSString *contentDescription;

@property NSMutableArray *singleLevelResults;

+ (id) sharedInstance;
- (NSString *) getUserId;
- (UIImage *)  getResultImage;
- (UIImage *)  getResultImageForShare;
- (NSString *) getSingleLevelResults;
- (UIImage *)  getResultDescImage;
- (void) loadUserProfile;
- (void) setQuestionAndChoice;

@end
