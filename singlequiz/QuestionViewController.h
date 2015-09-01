//
//  QuestionViewController.h
//  singlequiz
//
//  Created by KHUN NINE on 8/21/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionViewController : UIViewController

@property int questionNo;

@property UIImageView *resultImageView;

@property UILabel *question;
@property NSMutableArray *choicesList;


+ (void) getStartedQuestion:(UIViewController *) rootView;
+ (void) presentFirstQuestion: (UIViewController *) rootView;
+ (void) setQuestionViewControllers;
- (void) setQuestionNumber: (int) number;
- (void) setContentBackgroundImageView;
- (void) setQuestionLabel: (NSString *) questionText;
- (void) setChoicesLabels;
- (void) setQuestionPhoto;
- (void) addChoice: (NSString *) newChoice;

@end

