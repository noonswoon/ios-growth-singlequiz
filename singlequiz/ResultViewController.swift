//
//  ResultViewController.swift
//  WhyDoPeopleLikeYou
//
//  Created by KHUN NINE on 6/30/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

import Foundation
import UIKit
import Parse

class ResultViewController: UIViewController {

    // MARK: - Variables
    
    var shareButton: FBSDKShareButton!

    // uploading indicator for Parse file
    var spinner: UIActivityIndicatorView!
    
    var contentBackgroundImageShape: CAShapeLayer!
    var backgroundImageView: UIImageView!
    
    let margin: CGFloat = 8
    let elementHeight: CGFloat = 44

    // MARK: - View lief cycle
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.clearColor()
        
        setBackgroundImageView(self.view, imagePath: "main_background2")
        setUserDisplayPhoto()
        setResultDescImage()
        setResultImage()
        setSpinner()
        setLabels()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // The ads should be disabled when this will is presented
        if ( !AdvertismentController.isEnabled() ) {
            
            // Show the buttons up by animation
            self.setShareButton()
            self.setRetryButton()
            
            self.uploadResultImageToS3()
            
            // Set the varible for sharing ads
            AdvertismentController.setUserClickedShare(false)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        UserLogged.trackScreen("iOS - Result viewed")
    }
    
    // MARK: - Sharing Content
    
    func uploadResultImageToS3 () {
        let imageForShare = drawUIImageResult()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let timestamp = formatter.stringFromDate(NSDate())
        
        let fileName = DataController.getUserId() + "_" + timestamp + ".png"
        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent(fileName)
        let imageData = UIImagePNGRepresentation(imageForShare)
        imageData.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.key = fileName
        uploadRequest.bucket = S3_BUCKET_NAME
        uploadRequest.body = NSURL(fileURLWithPath: filePath)
        
        self.upload(uploadRequest)
    }
    
    func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if task.result != nil {
                println("Upload to AmazonS3 done !")
                let imgURL = "https://s3-ap-southeast-1.amazonaws.com/\(uploadRequest.bucket)/\(uploadRequest.key)"
                self.setContentToShare(imgURL)
                self.didFinishedUploadImage()
            } else {
                if let error = task.error {
                    if error.domain == AWSS3TransferManagerErrorDomain as String {
                        if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                            switch (errorCode) {
                                case .Cancelled, .Paused:
                                    break;
                                default:
                                    //println("upload() failed: [\(error)]")
                                    break;
                            }
                        } else {
                            //println("upload() failed: [\(error)]")
                        }
                    } else {
                        //println("upload() failed: [\(error)]")
                    }
                } else if let exception = task.exception {
                    //println("upload() failed: [\(exception)]")
                }
                self.didFinishedUploadImage()
            }
            return nil
        }
    }
    
    // Draw UIImage for sharing
    func drawUIImageResult () -> UIImage {
        
        // Create at rectangle size
        let rectSize: CGSize = CGSizeMake(470, 246)
        
        // Because it is an UIImage, we cannot use alpha method, we have to use image outside
        var background: UIImage = DataController.getResultImageForShare()
        
        // There are some problems I cannot solve when the user display image is not squre
        // I just fix that by snap the image from ResultViewController

        let displaySize: CGSize = CGSizeMake(53, 53)
        var display: UIImage = DataController.userProfileImage
        display = circleImageFromImage(display, size: displaySize)
        
        UIGraphicsBeginImageContext(rectSize);
        
        // Draw those image to recatangle
        background.drawInRect(CGRectMake(0, 0, rectSize.width, rectSize.height))
        display.drawInRect(CGRectMake(rectSize.width * 0.037, rectSize.height * 0.03, displaySize.width, displaySize.height))
        
        // finalImage in the image after we draw every images
        var finalImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        // Drawing text into image
        let textName = "ระดับความโสดของ " + DataController.userFirstNameText
        finalImage   = setText(textName, fontSize: 25, inImage: finalImage, atPoint: CGPoint(x:rectSize.width*0.17, y:15))
        
        // Save image into album, use this method if you don't want to check it on Parse or Facebook
        // saveImageToAlbum( finalImage )
        
        return finalImage
    }

    // MARK: - Setter methods
    // Set contents to share
    func setContentToShare (imageURLStr: String) {
        
        //println(contentURLImage)
        
        let contentURLStr = DataController.contentURL
        let contentTitle = DataController.contentTitle + ": " + DataController.getSingleLevelResults()
        let contentDescription = DataController.contentDescription
        
        let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.imageURL = NSURL(string: imageURLStr)
        content.contentURL = NSURL(string: contentURLStr)
        content.contentTitle = contentTitle
        content.contentDescription = contentDescription
        
        shareButton.shareContent = content
    }
    
    // Loading indicator while uploading an result image (while the Facebook share button is disable)
    func setSpinner() {
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.frame = CGRectMake(self.view.frame.width/2 + 4, 0, self.view.frame.width/2 - 12, elementHeight)
        spinner.center.y = CGRectGetMaxY( self.view.frame ) - self.elementHeight/2 - self.margin
        spinner.layer.zPosition = 10
        
        self.view.addSubview(spinner)
    }
    
    // Set the labels and its positions
    func setLabels () {
        
        let title       = "ระดับความโสดของ"
        let firstName   = DataController.userFirstNameText
        let frameHeight = CGRectGetMaxY(self.view.frame)
        
        // Set the position for any screen size
        if (iPhoneScreenSize() == "3.5") {
            setLabel(title,         yPosition: frameHeight * 0.05, size: 23)
            setLabel(firstName,     yPosition: frameHeight * 0.10,  size: 21)
        }
        else {
            setLabel(title,         yPosition: frameHeight * 0.07, size: 24)
            setLabel(firstName,     yPosition: frameHeight * 0.12,  size: 22)
        }
    }
    
    func setLabel (title: String, yPosition: CGFloat, size: CGFloat) {
        
        let label = UILabel(frame: CGRectMake(self.view.frame.width * 0.37, 0, self.view.frame.width, 200))
        label.numberOfLines = 1
        label.font = UIFont(name: "SukhumvitSet-Medium", size: size)
        label.textAlignment = NSTextAlignment.Left
        label.textColor = UIColor.appBrownColor()
        label.text = title
        label.sizeToFit()
        label.center.y = yPosition
        
        self.view.addSubview( label )
    }
    
    func setUserDisplayPhoto () {
        
        var userDisplayPhotoView = UIImageView(image: DataController.userProfileImage)
        
        // Because I calculate the y position from the screen width, and iPhone 3.5" has the screen width the same with iPhone 4"
        // So, we have to identify the 3.5" and 4"

        if (iPhoneScreenSize() == "3.5") {
            userDisplayPhotoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/5, height: self.view.frame.width/5)
            userDisplayPhotoView.center.x = CGRectGetMidX(self.view.frame) * 0.455
            userDisplayPhotoView.center.y = CGRectGetMaxY(self.view.frame) * 0.074
            userDisplayPhotoView.layer.borderWidth = 1.5
        }
        else {
            userDisplayPhotoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/4, height: self.view.frame.width/4)
            userDisplayPhotoView.center.x = CGRectGetMidX(self.view.frame) * 0.455
            userDisplayPhotoView.center.y = CGRectGetMaxY(self.view.frame) * 0.093
            userDisplayPhotoView.layer.borderWidth = 2
        }
        
        userDisplayPhotoView.contentMode = UIViewContentMode.ScaleAspectFill
        userDisplayPhotoView.layer.cornerRadius = userDisplayPhotoView.frame.width/2
        userDisplayPhotoView.layer.borderColor = UIColor.appBrownColor().CGColor
        userDisplayPhotoView.clipsToBounds = true
        
        self.view.addSubview(userDisplayPhotoView)
    }
    
    func setResultImage () {
        
        var image = DataController.getResultImage()
        
        var resultImageView = UIImageView(image: image)
        resultImageView.frame = CGRect(x: 0, y: 0, width: CGRectGetMidX(self.view.frame)*1.15*1.28, height: CGRectGetMidX(self.view.frame)*1.15)
        resultImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resultImageView.center.x = CGRectGetMidX(self.view.frame)
        if (iPhoneScreenSize() == "3.5") {
            resultImageView.center.y = CGRectGetMaxY(self.view.frame) * 1/3
        } else {
            resultImageView.center.y = CGRectGetMaxY(self.view.frame) * 0.35
        }
        resultImageView.layer.cornerRadius = 8
        resultImageView.layer.borderColor = UIColor.appBrownColor().CGColor
        resultImageView.layer.borderWidth = 3
        resultImageView.clipsToBounds = true
        
        self.view.addSubview(resultImageView)
    }
    
    func setResultDescImage () {
        
        var image = DataController.getResultDescImage()
        
        var resultDescImageView = UIImageView(image: image)
        resultDescImageView.frame = CGRect(x: 0, y: 0, width: CGRectGetMidX(self.view.frame)*1.15*1.28, height: CGRectGetMidX(self.view.frame)*1.15)
        resultDescImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resultDescImageView.center.x = CGRectGetMidX(self.view.frame)
        resultDescImageView.center.y = CGRectGetMaxY(self.view.frame) * 7/10
        resultDescImageView.layer.cornerRadius = 8
        resultDescImageView.clipsToBounds = true
        
        self.view.addSubview(resultDescImageView)
    }
    
    func setContentBackgroundTemplate () {
        
        let margin: CGFloat = self.margin + 6
        let statusBarHeight: CGFloat = 20
        let topMargin: CGFloat = statusBarHeight + self.margin + 3
        
        var imageString = "tempContentBackground"
        var image = UIImage(named: imageString)
        
        //        let frameHeight = self.view.frame.height - (topMargin) - elementHeight - margin - 6
        var frameWidth  = self.view.frame.width - (margin * 2)
        //        let frameWidth  = frameHeight * 0.7
        var frameHeight = frameWidth * 1.4
        
        if (iPhoneScreenSize() == "3.5") {
            frameWidth = frameWidth * 0.95
            frameHeight = frameHeight * 0.95
        }
        
        backgroundImageView = UIImageView(image: image)
        backgroundImageView.frame = CGRect(x: margin, y: topMargin, width: frameWidth, height: frameHeight)
        backgroundImageView.center = CGPoint(x: CGRectGetMidX(contentBackgroundImageShape.frame), y: CGRectGetMidY(contentBackgroundImageShape.frame))
        
        self.view.addSubview(backgroundImageView)
    }
    
    func setContentBackgroundImageView () {
        
        // defind the top margin
        
        let statusBarHeight: CGFloat = 20
        let topMargin: CGFloat = statusBarHeight + margin
        
        // Create a shape
        
        contentBackgroundImageShape = CAShapeLayer()
        contentBackgroundImageShape.frame = CGRect(x: margin, y: topMargin, width: self.view.frame.width - margin * 2, height: self.view.frame.height - ( margin * 2 + topMargin) - elementHeight)
        contentBackgroundImageShape.path = UIBezierPath(roundedRect: contentBackgroundImageShape.bounds, cornerRadius: 6).CGPath
        contentBackgroundImageShape.fillColor = UIColor.appCreamColor().CGColor
        contentBackgroundImageShape.strokeColor = UIColor.grayColor().CGColor
        contentBackgroundImageShape.lineWidth = 0.3;
        
        self.view.layer.addSublayer( contentBackgroundImageShape )
        
        var yPosition: CGFloat = topMargin + 30
        var line = CAShapeLayer()
        line.frame = CGRect(x: margin, y: yPosition, width: self.view.frame.width - margin * 2, height: 1)
        line.path = UIBezierPath(roundedRect: line.bounds, cornerRadius: 6).CGPath
        line.strokeColor = UIColor.lightGrayColor().CGColor
        line.lineWidth = 0.3;
        
        while (yPosition < contentBackgroundImageShape.frame.height) {
            var line = CAShapeLayer()
            line.frame = CGRect(x: margin - 16, y: yPosition, width: contentBackgroundImageShape.frame.width * 0.9, height: 1)
            line.position.x = contentBackgroundImageShape.position.x
            line.path = UIBezierPath(roundedRect: line.bounds, cornerRadius: 6).CGPath
            line.fillColor = UIColor.clearColor().CGColor
            line.strokeColor = UIColor(white: 0, alpha: 0.5).CGColor
            line.lineWidth = 0.3;
            
            self.view.layer.addSublayer(line)
            yPosition = yPosition + 30
        }
    }
    
    func setShareButton () {
        
        shareButton = FBSDKShareButton()
        shareButton.titleLabel?.text = "test"
        shareButton.frame = CGRectMake(self.view.frame.width/2 + 4, 0, self.view.frame.width/2 - 12, elementHeight)
        shareButton.enabled = false
        // The y position should be animated
        shareButton.center.y = CGRectGetMaxY( self.view.frame ) + elementHeight/2 + self.margin
        shareButton.addTarget(self, action: "shareButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        shareButton.layer.cornerRadius = 6
        shareButton.layer.masksToBounds = true
        
        // Add button into subview
        if (shareButton.superview == nil) {
            self.view.addSubview(shareButton)
        }
        
        // Show button up with animation
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.shareButton.center.y = CGRectGetMaxY( self.view.frame ) - self.elementHeight/2 - self.margin
            self.spinner.startAnimating()
            
            }, completion: nil)
    }
    
    func setRetryButton () {
        
        var retryButton = UIButton(frame: CGRectMake(8, 0, self.view.frame.width/2 - 12, elementHeight))
        retryButton.setTitle("เล่นใหม่", forState: .Normal)
        retryButton.titleLabel?.font = UIFont(name: "SukhumvitSet-Medium", size: 18)
        retryButton.enabled = true
        // The y position should be animated
        retryButton.center.y = CGRectGetMaxY( self.view.frame ) + elementHeight/2 + self.margin
        retryButton.addTarget(self, action: "retryButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        retryButton.backgroundColor = UIColor.appGreenColor()
        retryButton.layer.cornerRadius = 6
        retryButton.layer.masksToBounds = true
        
        // Add button into subview
        self.view.addSubview(retryButton)
        
        // Show up animation
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            retryButton.center.y = CGRectGetMaxY( self.view.frame ) - self.elementHeight/2 - self.margin
            
            }, completion: nil)
    }
    
    // MARK: - Drawing UIImage methods
    
    // Draw a text into rectangle method
    func setText (drawText: NSString, fontSize: CGFloat, inImage: UIImage, atPoint:CGPoint) -> UIImage{
        
        // Setup the font specific variables
        var textColor: UIColor = UIColor.whiteColor()
        var textFont:  UIFont  = UIFont(name: "SukhumvitSet-Medium", size: fontSize)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        var rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    
    func circleImageFromImage (image: UIImage, size: CGSize) -> UIImage {
        
        let imageView = UIImageView(image: image)
        
        imageView.frame = CGRectMake(0, 0, size.width, size.height)
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.appBrownColor().CGColor
        imageView.layer.borderWidth = 1.4
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.renderInContext(UIGraphicsGetCurrentContext())
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }

    
    func rectImageWithBorder (image: UIImage) -> UIImage {
        
        var imageResult = image
        
        let borderWidth: CGFloat = 5.0
        var imageViewer = UIImageView(frame: CGRectMake(0, 0, image.size.width, image.size.height))
        
        UIGraphicsBeginImageContextWithOptions(imageViewer.frame.size, false, 0)
        
        let path = UIBezierPath(roundedRect: CGRectInset(imageViewer.bounds, borderWidth / 2, borderWidth / 2), cornerRadius: 0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSaveGState(context)
        // Clip the drawing area to the path
        path.addClip()
        
        // Draw the image into the context
        imageResult.drawInRect(imageViewer.bounds)
        CGContextRestoreGState(context)
        
        // Configure the stroke
        UIColor.appCreamColor().setStroke()
        path.lineWidth = borderWidth
        
        // Stroke the border
        path.stroke()
        
        imageResult = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return imageResult
    }
    
    func saveImageToAlbum (image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    // MARK: - Controller methods    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch
        var point = touch.locationInView(self.view)
    }
    
    func shareButtonClicked () {
        
        // Log user activities
        UserLogged.shareButtonClicked()
        UserLogged.trackEvent("iOS - Share Btn Clicked")
        
        // Enable the advertisment alert
        AdvertismentController.enebleAds()
        AdvertismentController.setUserClickedShare(true)
    }
    
    func retryButtonClicked () {
        
        // Post a notification to Retry
        NSNotificationCenter.defaultCenter().postNotificationName("RetryButtonClicked", object: nil)
        
        // Track user event
        UserLogged.trackEvent("iOS - Retry Btn Clicked")
    }
    
    func didFinishedUploadImage () {
        dispatch_async(dispatch_get_main_queue(), {
            self.shareButton.enabled = true
            self.spinner.stopAnimating()
        })
    }

    // MARK: - Status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}