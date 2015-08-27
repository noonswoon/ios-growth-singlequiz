//
//  StartViewController.m
//  singlequiz
//
//  Created by KHUN NINE on 8/20/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

#import "StartViewController.h"
#import "singlequiz-Swift.h"

@interface StartViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation StartViewController

    UILabel *photoLabel;
    UILabel *nameLabel;
    UIButton *startButton;
    UIImageView *profileImageView;
    UIImageView *profileImageViewMark;
    UITextField *userFirstNameTextField;

    UIImagePickerController *imagePicker;

    BOOL firstTimes = true;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imagePicker = [[UIImagePickerController alloc] init];
    
    [self setUserDisplayPhoto];
    [self setUserDisplayMark];
    [self setNameLabel];
    [self setUserFirstName];
    [self setBackgroundImageView:self.view imagePath: @"main_background2"];
    [self setObserver];
    [self setPhotoLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [UserLogged trackScreen: @"iOS start view"];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setStartButton];
    
    [UserLogged setLogObject];
    [UserLogged saveUserInformation];
    
    if (firstTimes) {
        firstTimes = false;
    }
    
    // Should show only after click retry, should not show when user click share and retry
    if (![AdvertismentController isUserClickShareButton]) {
        [AdvertismentController showAds:0];
        [AdvertismentController setUserClickedShare:TRUE];
    }
    else {
        [userFirstNameTextField becomeFirstResponder];
    }
}

// MARK: - Status bar configuaration
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

// MARK: - Setter methods
- (void) setObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
}


- (void) setUserDisplayPhoto {

    profileImageView = [[UIImageView alloc] initWithImage: DataController.userProfileImage];
    profileImageView.frame = CGRectMake(0, 0, 150, 150);
    profileImageView.center = CGPointMake( self.view.center.x, self.view.frame.size.height * 0.3);
    profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2;
    profileImageView.layer.borderWidth = 3;
    profileImageView.layer.borderColor = [UIColor appCreamColor].CGColor;
    profileImageView.clipsToBounds = true;
    
    [self.view addSubview:profileImageView];
}


- (void) setUserDisplayMark {

    UIImage *profileImageMark = [UIImage imageNamed: @"userProfileImageMark.png"];
    profileImageViewMark = [[UIImageView alloc] initWithImage: profileImageMark];

    profileImageViewMark.frame = CGRectMake(0, 0, 150, 150);
    profileImageViewMark.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 0.3);
    
    profileImageViewMark.layer.cornerRadius = profileImageView.frame.size.width/2;
    profileImageViewMark.clipsToBounds = true;
    profileImageViewMark.alpha = 0.5;

    [self.view addSubview:profileImageViewMark];
}

- (void) setPhotoLabel {
    
    photoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 44, 44)];
    photoLabel.font = [UIFont fontWithName:@"SukhumvitSet-Medium" size:13.0];
    
    photoLabel.text = @"เปลี่ยนรูป";
    photoLabel.textAlignment = NSTextAlignmentCenter;
    photoLabel.textColor = [UIColor whiteColor];

    CGFloat frameHeight = self.view.frame.size.height;
    
    if ([[self iPhoneScreenSize]  isEqual: @"3.5"]) {
        photoLabel.center = CGPointMake(self.view.center.x, frameHeight * 0.4125);
    }
    else if ([[self iPhoneScreenSize]  isEqual: @"4"]) {
        photoLabel.center = CGPointMake(self.view.center.x, frameHeight * 0.395);
    }
    else if ([[self iPhoneScreenSize]  isEqual: @"4.7"]) {
        photoLabel.center = CGPointMake(self.view.center.x, frameHeight * 0.38);
    }
    else if ([[self iPhoneScreenSize]  isEqual: @"5.5"]) {
        photoLabel.center = CGPointMake(self.view.center.x, frameHeight * 0.37);
    }
    
    [self.view addSubview:photoLabel];
}

- (void) setNameLabel {
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 44, 44)];
    nameLabel.text = @"คุณชื่อไร ?";
    nameLabel.font = [UIFont fontWithName: @"SukhumvitSet-Medium" size:13.0];
    nameLabel.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 0.53);
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:nameLabel];
}

- (void) setUserFirstName {

    userFirstNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 44, 44)];
    userFirstNameTextField.delegate = self;
    userFirstNameTextField.text = DataController.userFirstNameText;
    userFirstNameTextField.font = [UIFont fontWithName: @"SukhumvitSet-Medium" size:18.0];
    userFirstNameTextField.textAlignment = NSTextAlignmentCenter;
    userFirstNameTextField.textColor = [UIColor whiteColor];
    userFirstNameTextField.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    userFirstNameTextField.layer.cornerRadius = 6;
    userFirstNameTextField.layer.borderColor = [UIColor appBrownColor].CGColor;
    userFirstNameTextField.layer.borderWidth = 1;
    userFirstNameTextField.returnKeyType = UIReturnKeyDone;
    userFirstNameTextField.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 0.62);
    
    [self.view addSubview:userFirstNameTextField];
}


- (void) setStartButton {

    if (!startButton) {
        startButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width - 44, 44)];
        startButton.titleLabel.font = [UIFont fontWithName: @"SukhumvitSet-Medium" size:18.0];
        startButton.center = CGPointMake(self.view.center.x, CGRectGetMaxY(self.view.frame) + 44);
        startButton.backgroundColor = [UIColor whiteColor];
        startButton.layer.cornerRadius = 6;
        startButton.layer.borderColor = [UIColor blackColor ].CGColor;
        startButton.layer.borderWidth = 1;
        [startButton setTitle:@"เริ่มเลยสิ !" forState: UIControlStateNormal];
        [startButton setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        [startButton setTitleColor:[UIColor grayColor]  forState: UIControlStateHighlighted];
        [startButton addTarget:self action:@selector(getStarted) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:startButton];
        
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionTransitionNone animations: ^(void){
            startButton.center = CGPointMake(self.view.center.x , CGRectGetMaxY(self.view.frame) - 22/2 - 8*2);
        } completion:nil];
    }
}

// MARK: - Controller methods
- (void) getStarted {

    firstTimes = true;
    [self.view endEditing:true];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionTransitionNone animations: ^(void){
        startButton.center = CGPointMake(self.view.center.x, self.view.frame.size.height + 44);
        startButton = nil;
    } completion: ^(BOOL success) {
        [QuestionViewController getStartedQuestion:self];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.returnKeyType == UIReturnKeyDone) {
        [self.view endEditing: true];
        return true;
    }
    else {
        return false;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [[event touchesForView:self.view] anyObject];
    CGPoint point  = [touch locationInView:touch.view];

    
    if (CGRectContainsPoint(profileImageView.frame, point)) {
        [self changeDisplayPhotoBtnClicked];
    }
    else {
        [self.view endEditing: true];
    }
}


- (void) changeDisplayPhotoBtnClicked {
    [self.view endEditing:true];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"เปลี่ยนรูปภาพ"
                                                                             message: @"ต้องการเลือกรูปภาพจากฦ"
                                                                      preferredStyle: UIAlertControllerStyleActionSheet];

    UIAlertAction *selectPictureAction = [UIAlertAction actionWithTitle:@"อัลบั้ม"
                                                                  style: UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action) {
                                                                    [self getPictureFromSource:false];
                                                                }];
    UIAlertAction *takingPictureAction = [UIAlertAction actionWithTitle:@"ถ่ายภาพใหม่"
                                                                  style: UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action) {
                                                                    [self getPictureFromSource:true];
                                                                }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"ยกเลิก"
                                                                  style: UIAlertActionStyleCancel
                                                                handler: NULL];
    
    [alertController addAction:selectPictureAction];
    [alertController addAction:takingPictureAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:true completion:nil];
}


- (void) getPictureFromSource: (BOOL)takingNewPhoto {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        imagePicker.delegate = self;
        imagePicker.sourceType = (takingNewPhoto) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.allowsEditing = false;
        
        [self presentViewController:imagePicker animated:true completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    // Show the image we picked to profile image view
    DataController.userProfileImage = info[UIImagePickerControllerOriginalImage];
    profileImageView.image = DataController.userProfileImage;
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void) keyboardWillShow: (NSNotification*) notification {
        
        CGFloat frameHeight = self.view.frame.size.height;
        
        if ([[self iPhoneScreenSize] isEqual: @"3.5"]) {
            profileImageView.center       = CGPointMake(self.view.center.x, frameHeight * 0.2);
            profileImageViewMark.center   = CGPointMake(self.view.center.x, frameHeight * 0.2);
            photoLabel.center             = CGPointMake(self.view.center.x, frameHeight * 0.3125);
            nameLabel.center              = CGPointMake(self.view.center.x, frameHeight * 0.39);
            userFirstNameTextField.center = CGPointMake(self.view.center.x, frameHeight * 0.45);
        }
        else if ([[self iPhoneScreenSize]  isEqual: @"4"]) {
            profileImageView.center       = CGPointMake(self.view.center.x, frameHeight * 0.2);
            profileImageViewMark.center   = CGPointMake(self.view.center.x, frameHeight * 0.2);
            photoLabel.center             = CGPointMake(self.view.center.x, frameHeight * 0.295);
            nameLabel.center              = CGPointMake(self.view.center.x, frameHeight * 0.39);
            userFirstNameTextField.center = CGPointMake(self.view.center.x, frameHeight * 0.45);
        }
        else if ([[self iPhoneScreenSize]  isEqual: @"4.7"]) {
            profileImageView.center       = CGPointMake(self.view.center.x, frameHeight * 0.28);
            profileImageViewMark.center   = CGPointMake(self.view.center.x, frameHeight * 0.28);
            photoLabel.center             = CGPointMake(self.view.center.x, frameHeight * 0.36);
            nameLabel.center              = CGPointMake(self.view.center.x, frameHeight * 0.44);
            userFirstNameTextField.center = CGPointMake(self.view.center.x, frameHeight * 0.49);

        }
        else if ([[self iPhoneScreenSize]  isEqual: @"5.5"]) {
            profileImageView.center       = CGPointMake(self.view.center.x, frameHeight * 0.28);
            profileImageViewMark.center   = CGPointMake(self.view.center.x, frameHeight * 0.28);
            photoLabel.center             = CGPointMake(self.view.center.x, frameHeight * 0.36);
            nameLabel.center              = CGPointMake(self.view.center.x, frameHeight * 0.44);
            userFirstNameTextField.center = CGPointMake(self.view.center.x, frameHeight * 0.49);
            
        }
        
        nameLabel.alpha = 0;
}


- (void) keyboardWillHide: (NSNotification*) notification {
    
        CGFloat frameHeight = self.view.frame.size.height;
        
        if ([[self iPhoneScreenSize]  isEqual: @"3.5"]) {
            profileImageView.center       = CGPointMake(self.view.center.x, frameHeight * 0.3);
            profileImageViewMark.center   = CGPointMake(self.view.center.x, frameHeight * 0.3);
            userFirstNameTextField.center = CGPointMake(self.view.center.x, frameHeight * 0.62);
            nameLabel.center              = CGPointMake(self.view.center.x, frameHeight * 0.53);
            photoLabel.center             = CGPointMake(self.view.center.x, frameHeight * 0.4125);
        }
        else if ([[self iPhoneScreenSize]  isEqual: @"4"]) {
            profileImageView.center       = CGPointMake(self.view.center.x, frameHeight * 0.3);
            profileImageViewMark.center   = CGPointMake(self.view.center.x, frameHeight * 0.3);
            userFirstNameTextField.center = CGPointMake(self.view.center.x, frameHeight * 0.62);
            nameLabel.center              = CGPointMake(self.view.center.x, frameHeight * 0.53);
            photoLabel.center             = CGPointMake(self.view.center.x, frameHeight * 0.395);
        }
        else if ([[self iPhoneScreenSize]  isEqual: @"4.7"]) {
            profileImageView.center       = CGPointMake(self.view.center.x, frameHeight * 0.3);
            profileImageViewMark.center   = CGPointMake(self.view.center.x, frameHeight * 0.3);
            userFirstNameTextField.center = CGPointMake(self.view.center.x, frameHeight * 0.62);
            nameLabel.center              = CGPointMake(self.view.center.x, frameHeight * 0.53);
            photoLabel.center             = CGPointMake(self.view.center.x, frameHeight * 0.38);
        }
        else if ([[self iPhoneScreenSize]  isEqual: @"5.5"]) {
            profileImageView.center       = CGPointMake(self.view.center.x, frameHeight * 0.3);
            profileImageViewMark.center   = CGPointMake(self.view.center.x, frameHeight * 0.3);
            userFirstNameTextField.center = CGPointMake(self.view.center.x, frameHeight * 0.62);
            nameLabel.center              = CGPointMake(self.view.center.x, frameHeight * 0.53);
            photoLabel.center             = CGPointMake(self.view.center.x, frameHeight * 0.37);
        }
        
    nameLabel.alpha = 1;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    DataController.userFirstNameText = userFirstNameTextField.text;
}

@end