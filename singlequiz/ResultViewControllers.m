

#import "ResultViewControllers.h"
#import "singlequiz-Swift.h"
#import <Parse/Parse.h>

@interface ResultViewControllers ()
@end

@implementation ResultViewControllers
    
    // MARK: - Variables
    
    FBSDKShareButton *shareButton;

    // uploading indicator for Parse file
    UIActivityIndicatorView *spinner;

    CAShapeLayer *contentBackgroundImageShape;
    UIImageView *backgroundImageView;

    CGFloat margin = 8;
    CGFloat elementHeight = 44;

    // MARK: - View lief cycle

- (void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [[UIViewController alloc] setBackgroundImageView:self.view imagePath: @"main)background2"];

    [self setUserDisplayPhoto];;
    [self setResultDescImage];
    [self setResultImage];
    [self setSpinner];
    [self setLabels];
    
    }

- (void)viewDidAppear:(BOOL)animated {
        
    // The ads should be disabled when this will is presented
    if ([AdvertismentController isEnabled]) {
            
        // Show the buttons up by animation
        [self setShareButton];
        [self setRetryButton];
        [self uploadResultImageToS3];
        
        // Set the varible for sharing ads
        [AdvertismentController setUserClickedShare:false];
    }
}


- (void)viewWillAppear:(BOOL)animated {

    [UserLogged trackEvent:@"iOS - Result viewed"];
}
    
// MARK: - Sharing Content
    
- (void) uploadResultImageToS3 {
    UIImage *imageForShare = [self drawUIImageResult];
    
    NSDateFormatter *formatter = [NSDateFormatter alloc];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT: 0];
    NSString *timestamp = [formatter stringFromDate: [NSDate alloc]];
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.png", [DataController getUserId], timestamp];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingString: fileName];
    NSData *imageData  = UIImagePNGRepresentation(imageForShare);
    [imageData writeToFile:filePath atomically:true];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest alloc];
    uploadRequest.key = fileName;
    uploadRequest.bucket = S3_BUCKET_NAME;
    uploadRequest.body = [NSURL fileURLWithPath: filePath];
    
    [self upload:uploadRequest];
}

- (void) upload: (AWSS3TransferManagerUploadRequest *) uploadRequest {
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.result) {
            NSString *imgURL = @"https://s3-ap-southeast-1.amazonaws.com/\(uploadRequest.bucket)/\(uploadRequest.key)";
            [self setContentToShare:imgURL];
            [self didFinishUploadImage];
        }
        else {
            if (task.error) {
                if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                    switch (task.error.code) {
                        case AWSS3TransferManagerErrorCancelled:
                        default:
                            NSLog(@"Upload failed: [%@]", task.error);
                            break;
                    }
                } else {
                    NSLog(@"Upload failed: [%@]", task.error);
                }
            }
            [self didFinishUploadImage];
        }
        return nil;
    }];
}

// Draw UIImage for sharing

- (UIImage *) drawUIImageResult {
    
    // Create at rectangle size
    CGSize rectSize = CGSizeMake(470, 246);
    
    // Because it is an UIImage, we cannot use alpha method, we have to use image outside
    UIImage *background = [DataController getResultImageForShare];
    
    // There are some problems I cannot solve when the user display image is not squre
    // I just fix that by snap the image from ResultViewController
    
    CGSize displaySize = CGSizeMake(53, 53);
    UIImage *display = DataController.userProfileImage;
    display = [self circleImageFromImage: display size: displaySize];
    
    UIGraphicsBeginImageContext(rectSize);
    
    // Draw those image to recatangle
    [background drawInRect:CGRectMake(0, 0, rectSize.width, rectSize.height)];
    [display drawInRect:CGRectMake(rectSize.width * 0.037, rectSize.height * 0.03, displaySize.width, displaySize.height)];
    
    // finalImage in the image after we draw every images
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Drawing text into image
    NSString *textName = [NSString stringWithFormat:@"ระดับความโสดของ %@", DataController.userFirstNameText];
    finalImage = [self setText:textName fontSize:25 inImage:finalImage atPoint:CGPointMake(rectSize.width*0.17, 15)];
    
    // Save image into album, use this method if you don't want to check it on Parse or Facebook
    // saveImageToAlbum( finalImage )
    
    return finalImage;
}

// MARK: - Setter methods
// Set contents to share
- (void) setContentToShare: (NSString *) imageURLStr {
    
    //println(contentURLImage)
    
    NSString *contentURLStr = DataController.contentURL;
    NSString *contentTitle = [NSString stringWithFormat:@"%@: %@", DataController.contentTitle, [DataController getSingleLevelResults]];
    NSString *contentDescription = DataController.contentDescription;
    
    FBSDKShareLinkContent *content = [FBSDKShareLinkContent alloc];
    content.imageURL           = [[NSURL alloc] initWithString:imageURLStr];
    content.contentURL         = [[NSURL alloc] initWithString:contentURLStr];
    content.contentTitle       = contentTitle;
    content.contentDescription = contentDescription;
    
    shareButton.shareContent = content;
}

// Loading indicator while uploading an result image (while the Facebook share button is disable)
- (void) setSpinner {
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(self.view.frame.size.width/2 + 4, 0, self.view.frame.size.width/2 - 12, elementHeight);
    spinner.center = CGPointMake(spinner.center.x, CGRectGetMaxY( self.view.frame ) - elementHeight/2 - margin);
    spinner.layer.zPosition = 10;
    
    [self.view addSubview: spinner];
}

// Set the labels and its positions

- (void) setLabels {
    
    NSString *title     = @"ระดับความโสดของ";
    NSString *firstName = DataController.userFirstNameText;
    CGFloat frameHeight = CGRectGetMaxY(self.view.frame);
    
    // Set the position for any screen size
    if ([[[UIViewController alloc] iPhoneScreenSize] isEqual: @"3.5"]) {
        [self setLabel:title     yPosition: frameHeight * 0.05 size: 23];
        [self setLabel:firstName yPosition:frameHeight * 0.10 size: 21];
    }
    else {
        
        [self setLabel:title     yPosition: frameHeight * 0.07 size: 24];
        [self setLabel:firstName yPosition:frameHeight * 0.12 size: 22];
    }
}

- (void) setLabel: (NSString*) title yPosition: (CGFloat) yPosition size: (CGFloat) size {
    
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(self.view.frame.size.width * 0.37, 0, self.view.frame.size.width, 200)];
    label.numberOfLines = 1;
    label.font =  [UIFont fontWithName: @"SukhumvitSet-Medium" size: size];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor appBrownColor];
    label.text = title;
    label.center = CGPointMake(label.center.x, yPosition);
    [label sizeToFit];
    
    [self.view addSubview: label];
}

- (void) setUserDisplayPhoto {
    
    UIImageView *userDisplayPhotoView = [[UIImageView alloc] initWithImage:DataController.userProfileImage];
    
    // Because I calculate the y position from the screen width, and iPhone 3.5" has the screen width the same with iPhone 4"
    // So, we have to identify the 3.5" and 4"
    
    if ([[[UIViewController alloc] iPhoneScreenSize] isEqual: @"3.5"]) {
        userDisplayPhotoView.frame  = CGRectMake(0, 0, self.view.frame.size.width/5, self.view.frame.size.width/5);
        userDisplayPhotoView.center = CGPointMake(CGRectGetMidX(self.view.frame) * 0.455, CGRectGetMaxY(self.view.frame) * 0.074);
        userDisplayPhotoView.layer.borderWidth = 1.5;
    }
    else {
        userDisplayPhotoView.frame  = CGRectMake(0, 0, self.view.frame.size.width/4, self.view.frame.size.width/4);
        userDisplayPhotoView.center = CGPointMake(CGRectGetMidX(self.view.frame) * 0.455, CGRectGetMaxY(self.view.frame) * 0.093);
        userDisplayPhotoView.layer.borderWidth = 2;
    }
    
    userDisplayPhotoView.contentMode        = UIViewContentModeScaleAspectFill;
    userDisplayPhotoView.layer.cornerRadius = userDisplayPhotoView.frame.size.width/2;
    userDisplayPhotoView.layer.borderColor  = [UIColor appBrownColor].CGColor;
    userDisplayPhotoView.clipsToBounds      = true;
    
    [self.view addSubview:userDisplayPhotoView];
}

- (void) setResultImage {
    
    UIImage *image = [DataController getResultImage];
    
    UIImageView *resultImageView       = [[UIImageView alloc] initWithImage:image];
    resultImageView.frame              = CGRectMake(0, 0, CGRectGetMidX(self.view.frame)*1.15*1.28,
                                                    CGRectGetMidX(self.view.frame)*1.15);
    resultImageView.contentMode        = UIViewContentModeScaleAspectFill;
    resultImageView.layer.cornerRadius = 8;
    resultImageView.layer.borderColor  = [UIColor appBrownColor].CGColor;
    resultImageView.layer.borderWidth  = 3;
    resultImageView.clipsToBounds      = true;

    
    if ([[[UIViewController alloc] iPhoneScreenSize] isEqual: @"3.5"]) {
        resultImageView.center       = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.view.frame) * 1/3);
    } else {
        resultImageView.center       = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.view.frame) * 0.35);
    }
    
    [self.view addSubview:resultImageView];
}

- (void) setResultDescImage {
    
    UIImage *image = [DataController getResultDescImage];
    UIImageView *resultDescImageView = [[UIImageView alloc]initWithImage: image];
    
    resultDescImageView.frame = CGRectMake(0, 0, CGRectGetMidX(self.view.frame)*1.15*1.28, CGRectGetMidX(self.view.frame)*1.15);
    resultDescImageView.contentMode = UIViewContentModeScaleAspectFill;
    resultDescImageView.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.view.frame) * 7/10);
    resultDescImageView.layer.cornerRadius = 8;
    resultDescImageView.clipsToBounds = true;
    
    [self.view addSubview:resultDescImageView];
}

- (void) setContentBackgroundTemplate {
    
    CGFloat templateMargin = margin + 6;
    CGFloat statusBarHeight = 20;
    CGFloat topMargin = statusBarHeight + templateMargin + 3;
    
    NSString *imageString = @"tempContentBackground";
    UIImage *image = [UIImage imageNamed: imageString];
    
    CGFloat frameWidth  = self.view.frame.size.width - (templateMargin * 2);
    CGFloat frameHeight = frameWidth * 1.4;
    
    if ([[[UIViewController alloc] iPhoneScreenSize] isEqual: @"3.5"]) {
        frameWidth = frameWidth * 0.95;
        frameHeight = frameHeight * 0.95;
    }
    
    backgroundImageView = [[UIImageView alloc] initWithImage: image];
    backgroundImageView.frame = CGRectMake(templateMargin, topMargin, frameWidth, frameHeight);
    backgroundImageView.center = CGPointMake(CGRectGetMidX(contentBackgroundImageShape.frame), CGRectGetMidY(contentBackgroundImageShape.frame));
    
    [self.view addSubview:backgroundImageView];
}

- (void) setContentBackgroundImageView{
    
    // defind the top margin
    
    CGFloat statusBarHeight = 20;
    CGFloat topMargin = statusBarHeight + margin;
    
    // Create a shape
    
    CAShapeLayer *contentBackgroundImageShape = [CAShapeLayer alloc];
    contentBackgroundImageShape.frame = CGRectMake(margin, topMargin, self.view.frame.size.width - margin * 2, self.view.frame.size.height - ( margin * 2 + topMargin) - elementHeight);
    contentBackgroundImageShape.path = [UIBezierPath bezierPathWithRoundedRect: contentBackgroundImageShape.bounds cornerRadius: 6 ].CGPath;
    contentBackgroundImageShape.fillColor = [UIColor appCreamColor].CGColor;
    contentBackgroundImageShape.strokeColor = [UIColor grayColor].CGColor;
    contentBackgroundImageShape.lineWidth = 0.3;
    
    [self.view.layer addSublayer:contentBackgroundImageShape];
    
    CGFloat yPosition = topMargin + 30;
    CAShapeLayer *line = [CAShapeLayer alloc];
    line.frame = CGRectMake(margin, yPosition, self.view.frame.size.width - margin * 2, 1);
    line.path = [UIBezierPath bezierPathWithRoundedRect: line.bounds cornerRadius: 6 ].CGPath;
    line.strokeColor = [UIColor lightGrayColor].CGColor;
    line.lineWidth = 0.3;
    
    while (yPosition < contentBackgroundImageShape.frame.size.height) {
        CAShapeLayer *line = [CAShapeLayer alloc];
        line.frame = CGRectMake(margin - 16, yPosition, contentBackgroundImageShape.frame.size.width * 0.9, 1);
        line.position = CGPointMake(contentBackgroundImageShape.position.x, line.position.y);
        line.path = [UIBezierPath bezierPathWithRoundedRect: line.bounds cornerRadius: 6 ].CGPath;
        line.fillColor = [UIColor clearColor].CGColor;
        line.strokeColor = [UIColor colorWithWhite: 0 alpha: 0.5].CGColor;
        line.lineWidth = 0.3;
        
        [self.view.layer addSublayer:line];
        yPosition = yPosition + 30;
    }
}

- (void) setShareButton {
    
    shareButton = [[FBSDKShareButton alloc] initWithFrame: CGRectMake(self.view.frame.size.width/2 + 4, 0, self.view.frame.size.width/2 - 12, elementHeight)];
    shareButton.enabled = false;
    // The y position should be animated
    shareButton.center = CGPointMake(shareButton.center.x, CGRectGetMaxY(self.view.frame) + elementHeight/2 + margin);
    shareButton.layer.cornerRadius = 6;
    shareButton.layer.masksToBounds = true;
    [shareButton addTarget:self action:@selector(shareButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    // Add button into subview
    if (shareButton.superview == nil) {
        [self.view addSubview:shareButton];
    }
    
    // Show button up with animation
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^(void){
        shareButton.center = CGPointMake(shareButton.center.x, CGRectGetMaxY(self.view.frame) - elementHeight/2 - margin);
        [spinner startAnimating];
    } completion:nil];
}

- (void) setRetryButton {
    
    UIButton *retryButton = [[UIButton alloc] initWithFrame: CGRectMake(8, 0, self.view.frame.size.width/2 - 12, elementHeight)];
    [retryButton setTitle:@"เล่นใหม่" forState: UIControlStateNormal];
    retryButton.titleLabel.font = [UIFont fontWithName:@"SukhumvitSet-Medium" size: 18];
    retryButton.enabled = true;
    // The y position should be animated
    retryButton.center = CGPointMake(retryButton.center.x, CGRectGetMaxY( self.view.frame ) + elementHeight/2 + margin);
    [retryButton addTarget:self action: @selector(retryButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    retryButton.backgroundColor = [UIColor appGreenColor];
    retryButton.layer.cornerRadius = 6;
    retryButton.layer.masksToBounds = true;
    
    // Add button into subview
    [self.view addSubview:retryButton];
    
    // Show up animation
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionTransitionNone animations: ^(void){
        retryButton.center = CGPointMake(retryButton.center.x, CGRectGetMaxY( self.view.frame ) - elementHeight/2 - margin);
    } completion:nil];
}

// MARK: - Drawing UIImage methods

// Draw a text into rectangle method

-(UIImage *) setText: (NSString*) drawText fontSize: (CGFloat) fontSize inImage: (UIImage*) inImage atPoint: (CGPoint) atPoint {
    
    // Setup the font specific variables
    UIColor *textColor = [UIColor whiteColor];
    UIFont *textFont   =  [UIFont fontWithName:@"SukhumvitSet-Medium" size:fontSize];
    
    //Setup the image context using the passed image.
    UIGraphicsBeginImageContext(inImage.size);
    
    // Setups up the font attributes that will be later used to dictate how the text should be drawn
    // NSDictionary *textFontAttributes = [ NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor, ];
    
    //Put the image into a rectangle as large as the original image.
    [inImage drawInRect:CGRectMake(0, 0, inImage.size.width, inImage.size.height)];
    
    // Creating a point within the space that is as bit as the image.
    CGRect rect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height);
    
    //Now Draw the text into an image.
    [drawText drawInRect:rect withAttributes:nil];
    //drawInRect(rect, withAttributes: textFontAttributes)
    
    // Create a new image out of the images we have created
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context now that we have the image we need
    UIGraphicsEndImageContext();
    
    //And pass it back up to the caller.
    return newImage;
    
}

- (UIImage *) circleImageFromImage: (UIImage*) image size: (CGSize) size {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
    imageView.frame = CGRectMake(0, 0, size.width, size.height);
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    imageView.layer.masksToBounds = true;
    imageView.layer.borderColor = [UIColor appBrownColor].CGColor;
    imageView.layer.borderWidth = 1.4;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIGraphicsBeginImageContext(imageView.bounds.size);
    
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *) rectImageWithBorder: (UIImage *) image {
    
    UIImage *imageResult = image;
    
    CGFloat borderWidth = 5.0;
    UIImageView *imageViewer = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, image.size.width, image.size.height)];

    UIGraphicsBeginImageContextWithOptions(imageViewer.frame.size, false, 0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(imageViewer.bounds, borderWidth / 2, borderWidth / 2) cornerRadius:0];
                                                                  
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    // Clip the drawing area to the path
    [path addClip];
    
    // Draw the image into the context
    [imageResult drawInRect:imageViewer.bounds];
    CGContextRestoreGState(context);
    
    // Configure the stroke
    [[UIColor appCreamColor] setStroke];
    path.lineWidth = borderWidth;
    
    // Stroke the border
    [path stroke];
    
    imageResult = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageResult;
}

// Needs for testing application !!
- (void) saveImageToAlbum: (UIImage*) image {
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}
    
// MARK: - Controller methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    UITouch *touch = [[event touchesForView:self.view] anyObject];
//    CGPoint point  = [touch locationInView:touch.view];
}

- (void) shareButtonClicked {
        
    // Log user activities
    [UserLogged shareButtonClicked];
    [UserLogged trackEvent:@"iOS - Share Btn Clicked"];
        
    // Enable the advertisment alert
    [AdvertismentController enabledAds];
    [AdvertismentController setUserClickedShare:true];
}

- (void) retryButtonClicked {
        
    // Post a notification to Retry
    [[NSNotificationCenter defaultCenter] postNotificationName: @"RetryButtonClicked" object:nil];

    // Track user event
    [UserLogged trackEvent: @"iOS - Retry Btn Clicked"];
}
//
- (void) didFinishUploadImage {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        shareButton.enabled = true;
        [spinner stopAnimating];
    });
}

// MARK: - Status bar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

@end