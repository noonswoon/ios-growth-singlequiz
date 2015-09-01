//
//  QuestionViewController.m
//  singlequiz
//
//  Created by KHUN NINE on 8/21/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

#import "QuestionViewController.h"
#import "ResultViewController.h"
#import "DataController.h"

#import "Extension.h"
#import "singlequiz-Swift.h"

@interface QuestionViewController ()
@end

@implementation QuestionViewController

int questionNo = 0;

UIImageView *resultImageView;

UILabel *question;
NSMutableArray *choicesList;

//    // MARK: - View life cycle
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *screenName = [NSString stringWithFormat: @"iOS Question view no. %d", questionNo];
    [UserLogged trackScreen: screenName];
}

// MARK: - Set and generate choices
- (void) generateChoices: (CGFloat) position {

    const CGFloat buttonWidth = CGRectGetMaxX( self.view.frame ) * 0.75;
    const CGFloat buttonHeight = ([[self iPhoneScreenSize] isEqual: @"3.5"]) ? 60 : 66;

    const CGFloat margin = 8;
    const CGFloat buttonMargin = buttonHeight + margin/3;
//
    for (int i=0 ; i<choicesList.count ; i++) {
        CGFloat yPosition = position + (buttonMargin * i);
        CGRect  frame = CGRectMake(0, yPosition, buttonWidth, buttonHeight);
        
        UIButton *button = [self choiceButtonMake:i withFrame:frame];
        
        [self.view addSubview:button];
    }
}

- (UIButton *) choiceButtonMake:(int) index withFrame:(CGRect) frame {
    
    
    UIButton *button = [[UIButton alloc]initWithFrame:frame];
    button.titleLabel.font = [UIFont fontWithName: @"SukhumvitSet-Medium" size:13.0];
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.center = CGPointMake(self.view.center.x, button.center.y);
    button.layer.cornerRadius = 8;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.borderWidth = 1;
    button.tag = index;
    [button setTitle:choicesList[index] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.2 alpha:1] forState: UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(choiceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void) choiceButtonClick:(UIButton *) sender {

    [DataController sharedInstance].summation = [DataController sharedInstance].summation + (sender.tag + 1);

        if (questionNo == [DataController sharedInstance].questions.count - 1) {
            
            [SwiftSpinner show:@"กำลังประมวลผล" animated:true];
            
            CGFloat delay = 3 * NSEC_PER_SEC;
            NSTimeInterval time = dispatch_time(DISPATCH_TIME_NOW, delay);
            
            dispatch_after(time, dispatch_get_main_queue(), ^{
                
                [SwiftSpinner hideWithCompletion: ^{
                    ResultViewController *viewController = [ResultViewController alloc];
                    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    [self presentViewController:viewController animated:true completion:nil];
                }];
            });
        }
        else {
            
            QuestionViewController *viewController = [DataController sharedInstance].list_questionViewController[questionNo + 1];
            viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:viewController animated:true completion:nil];
        }
}

//    
//    // MARK: - Status bar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

//    // MARK: - Setter methods
- (void) setQuestionNumber: (int) number {
    questionNo = number;
}

- (void) setQuestionPhoto {
    NSString *imageString = [NSString stringWithFormat: @"q%d.jpg", questionNo+1];
    UIImage  *image       = [UIImage imageNamed:imageString];
    
    resultImageView = [[UIImageView alloc] initWithImage:image];
    
    if ([[self iPhoneScreenSize] isEqual: @"3.5"]) {
        resultImageView.frame = CGRectMake(0, 0, CGRectGetMidX(self.view.frame)-30, CGRectGetMidX(self.view.frame)-30);
        resultImageView.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.view.frame) * 0.18);
    }
    else if ([[self iPhoneScreenSize] isEqual: @"4"]) {
        resultImageView.frame = CGRectMake(0, 0, CGRectGetMidX(self.view.frame)-10, CGRectGetMidX(self.view.frame)-10);
        resultImageView.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.view.frame) * 0.18);
    }
    else {
        resultImageView.frame = CGRectMake(0, 0, CGRectGetMidX(self.view.frame)-10, CGRectGetMidX(self.view.frame)-10);
        resultImageView.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.view.frame) * 0.225);
    }
    
    resultImageView.layer.zPosition    = 3;
    resultImageView.layer.borderWidth  = 4;
    resultImageView.layer.borderColor  = [UIColor whiteColor].CGColor;
    resultImageView.layer.cornerRadius = resultImageView.frame.size.width/2;
    resultImageView.contentMode = UIViewContentModeScaleAspectFill;
    resultImageView.clipsToBounds = true;
    
    [self.view addSubview:resultImageView];
}

- (void) setQuestionLabel: (NSString *) questionText {
    
    UILabel *question = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetMaxX( self.view.frame ) * 0.8, 100)];
        question.font = [UIFont fontWithName: @"SukhumvitSet-Medium" size:18.0];
    question.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 0.435);
    question.numberOfLines = 0;
    question.textAlignment = NSTextAlignmentCenter;
    question.text = questionText;
    
    if ([[self iPhoneScreenSize] isEqual: @"3.5"]) {
        question.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 0.39);
    }
    else if ([[self iPhoneScreenSize] isEqual: @"4"]) {
        question.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 0.40);
    }
    
    [self.view addSubview:question];
}

- (void) addChoice: (NSString *) newChoice {
    
    [choicesList addObject:newChoice];
}


- (void) setChoicesLabels {

        
    CGFloat yPositionFirstChoice;
        
    if ([[self iPhoneScreenSize] isEqualToString:@"3.5"]) {
        yPositionFirstChoice = self.view.frame.size.height * 0.45;
    }
    else if ([[self iPhoneScreenSize] isEqualToString:@"3.5"]) {
        yPositionFirstChoice = self.view.frame.size.height * 0.47;
    }
    
    [self generateChoices:yPositionFirstChoice];
}

- (void) setContentBackgroundImageView {
    
    NSString *imageString = [NSString stringWithFormat: @"q%d.jpg", questionNo+1];
    UIImage  *image       = [UIImage imageNamed:imageString];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, self.view.frame.size.width - 16, CGRectGetMaxY(self.view.frame) - 16);
    imageView.layer.cornerRadius = 0;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = true;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = imageView.frame;
    [blurView setTranslatesAutoresizingMaskIntoConstraints:false];
        
        // Set image over layer
    CAGradientLayer *gradient = [[CAGradientLayer alloc] initWithLayer:imageView.layer];
    gradient.frame = imageView.frame;
        
        // Add colors to layer
    UIColor *startColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
    UIColor *endColor   = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    gradient.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
        
        UIImageView *clipper = [[UIImageView alloc]initWithFrame: CGRectMake(0,
                                                                           0,
                                                                           self.view.frame.size.width  - 16,
                                                                           self.view.frame.size.height - 16)];
    [clipper addSubview:imageView];
    [clipper addSubview:blurView];
    [clipper.layer addSublayer:gradient];
    clipper.clipsToBounds = true;
    clipper.layer.cornerRadius = 8;
        
    [self.view addSubview:clipper];
}


+ (void) setQuestionViewControllers {
    
    NSArray *questions   = [DataController sharedInstance].questions;
    NSArray *choicesList = [DataController sharedInstance].choicesList;
    
    NSLog(@"%d", [DataController sharedInstance].choicesList.count);
    
    CGFloat numberOfChoicePerQuestion = [DataController sharedInstance].choicesList.count / [DataController sharedInstance].questions.count;
    CGFloat numberOfQuestion = [DataController sharedInstance].questions.count;
    
    for (int i=0 ; i<numberOfQuestion ; i++) {
        
        QuestionViewController *questionViewController = [QuestionViewController alloc];
        
        for (int j=0 ; j<numberOfChoicePerQuestion ; j++) {
            
            NSString *choice = [choicesList objectAtIndex: (i * numberOfChoicePerQuestion + j)];
            [questionViewController addChoice:choice];
        }
        
        [questionViewController setQuestionNumber:i];
        [questionViewController setContentBackgroundImageView];
        [questionViewController setQuestionLabel:questions[i]];
        [questionViewController setChoicesLabels];
        [questionViewController setQuestionPhoto];
        
        // NEED TO BE FIXED
        // DataController.list_questionViewController. append( questionViewController )
    }

}

// MARK: - Setter methods and controllers
+ (void) getStartedQuestion:(UIViewController *) rootView {

    [DataController sharedInstance].summation = [DataController sharedInstance].result;

    CGFloat delay = 3 * NSEC_PER_SEC;
    NSTimeInterval time = dispatch_time(DISPATCH_TIME_NOW, delay);
    
    dispatch_after(time, dispatch_get_main_queue(), ^{
        
        [self presentFirstQuestion:rootView];
    });
}

+ (void) presentFirstQuestion: (UIViewController*) rootView {

    NSLog(@"%lu",(unsigned long)[DataController sharedInstance].list_questionViewController.count);
    QuestionViewController *firstQuestionView  = [DataController sharedInstance].list_questionViewController[0];
    firstQuestionView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [rootView presentViewController:firstQuestionView animated:true completion:nil];
}

// MARK: - Controller methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event touchesForView:self.view] anyObject];
    CGPoint point  = [touch locationInView:touch.view];
}


@end