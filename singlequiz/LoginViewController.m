
#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "singlequiz-Swift.h"

@interface LoginViewController () <FBSDKLoginButtonDelegate, UIAlertViewDelegate>
@end

@implementation LoginViewController

#pragma mark - Instance variables

NSArray *permissions;
FBSDKLoginButton *loginButton;

const CGFloat margin = 8;
const CGFloat elementHeight = 44;

#pragma mark - View Life Cycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    permissions = [NSArray arrayWithObjects: @"public_profile", @"email", @"user_birthday", nil];
    
    // Set view elements
    [self setBackgroundImageView: @"LoginViewBackground"];
    [self setQuestionViewController];
    [self setNotificationCenter];
}

- (void) viewWillAppear:(BOOL)animated {
    
    // Google analytics view tracking
    [UserLogged trackScreen:@"iOS Login view"];
}


- (void) viewDidAppear:(BOOL)animated {
    
    // If user has no internet access, then show the alert view
    if (![Reachability isConnectedToNetwork]) {
        [self showAlertMessage];
    }
    
    // If user already logged in, call the main function
    else if ([FBSDKAccessToken currentAccessToken]) {
        [self userLoggedIn];
    }
    
    // If user did not login yet, show the login button
    else {
        [self setLoginButton];
    }
}

#pragma mark - Setter Methods

- (void) setBackgroundImageView: (NSString *) imagePath {
    
    UIImage *backgroundImage = [UIImage imageNamed:imagePath];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage: backgroundImage];
    backgroundImageView.frame = self.view.frame;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
}

// Set the question to user for generating result
- (void) setQuestionViewController {
    [DataController setQuestionAndChoice];
    [QuestionViewController setQuestionViewControllers];
}

- (void) setNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadUserProfileCompleted)
                                                 name:@"LoadUserProfileCompleted"
                                               object:nil];
}

- (void) setLoginButton {
    
    loginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectMake(8, 0, self.view.frame.size.width * 0.9, elementHeight)];
    loginButton.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.view.frame)+ CGRectGetMaxY(loginButton.frame));
    loginButton.layer.cornerRadius = 6;
    loginButton.layer.masksToBounds = TRUE;
    
    loginButton.readPermissions = permissions;
    loginButton.delegate = self;
    
    [self.view addSubview:loginButton];

    // PS. The y position of loginButton needs to animate
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionTransitionNone animations: ^(void){
        loginButton.center = CGPointMake(loginButton.center.x, CGRectGetMaxY(self.view.frame) * 0.65);
    } completion:nil];
}


#pragma mark - Main Method

- (void) userLoggedIn {
    [SwiftSpinner show:@"กำลังโหลด\nข้อมูลผู้ใช้" animated:true];
    [DataController loadUserProfile];
}

#pragma mark - Status Bar Config

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL) prefersStatusBarHidden {
    return TRUE;
}

#pragma mark - Facebook SDKs Methods

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    
    // If there is an error or user clicked cancel, then just return
    if (error || result.isCancelled) {
        return;
    }
    
    // If user logged in, then call the main function
    else {
        [self userLoggedIn];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    // TODO
}

#pragma mark - Controller

- (void) loadUserProfileCompleted {
    
    StartViewController *startViewController = [StartViewController alloc];
    startViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:startViewController animated:true completion:nil];
}

#pragma mark - Alert

// Showing that user have to internet connection as a UIAlertView
- (void) showAlertMessage {
    
    NSString *title    = @"Alert";
    NSString *message  = @"No internet connection";
    NSString *btnTitle = @"Try agian";
    
    UIAlertView *internetIndicator = [[UIAlertView alloc] initWithTitle: title message: message delegate: self cancelButtonTitle:btnTitle otherButtonTitles: nil, nil];
    
    [internetIndicator show];
}

// If you click any button at alert view, application will call viewDidAppear agian to try to get started application flow
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self viewDidAppear:TRUE];
}

@end