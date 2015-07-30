//
//  LoadUserInformationViewController.swift
//  WhyDoPeopleLikeYou
//
//  Created by KHUN NINE on 7/6/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

import Foundation
import UIKit

class StartViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate {
    
    // MARK: - Variables
    
    var photoLabel: UILabel!
    var nameLabel: UILabel!
    var startButton: UIButton!
    var profileImageView: UIImageView!
    var profileImageViewMark : UIImageView!
    var userFirstNameTextField: UITextField!
    
    var imagePicker = UIImagePickerController()
    
    var firstTimes = true

    // MARK: - View life cycle
    
    override func viewDidLoad() {
        setUserDisplayPhoto()
        setUserDisplayMark()
        setNameLabel()
        setUserFirstName()
        setBackgroundImageView(self.view, imagePath: "main_background2")
        setObservers()
        setPhotoLabel()
    }
    
    override func viewWillAppear(animated: Bool) {
        UserLogged.trackScreen("Start view")
    }
    
    override func viewDidAppear(animated: Bool) {
        setStartButton()
        UserLogged.setLogObject()
        
        if (firstTimes) {
            userFirstNameTextField.becomeFirstResponder()
            firstTimes = false
        }
        
        // Should show only after click retry, should not show when user click share and retry
        if (!AdvertismentController.isUserClickShareButton()) {
            self.view.endEditing(true)
            AdvertismentController.showAds(0)
            AdvertismentController.setUserClickedShare(true)
        }
    }

    // MARK: - Status bar configuaration
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // MARK: - Setter methods
    
    func setObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func setUserDisplayPhoto () {
        profileImageView = UIImageView(image: DataController.userProfileImage)
        
        profileImageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        profileImageView.center.x = self.view.center.x
        profileImageView.center.y = self.view.frame.height * 0.3
        profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.appCreamColor().CGColor
        profileImageView.clipsToBounds = true
        
        self.view.addSubview(profileImageView)
    }
    
    func setUserDisplayMark () {
        profileImageViewMark = UIImageView(image: UIImage(named: "userProfileImageMark.png"))
        
        profileImageViewMark.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        profileImageViewMark.center.x = self.view.center.x
        profileImageViewMark.center.y = self.view.frame.height * 0.3
        
        profileImageViewMark.layer.cornerRadius = profileImageView.frame.width/2
        profileImageViewMark.clipsToBounds = true
        profileImageViewMark.alpha = 0.5
        
        self.view.addSubview(profileImageViewMark)
    }
    
    func setPhotoLabel () {
        photoLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - 44, 44))
        photoLabel.font = UIFont(name: "SukhumvitSet-Medium", size: 13)
        photoLabel.text = "เปลี่ยนรูป"
        photoLabel.textAlignment = NSTextAlignment.Center
        photoLabel.textColor = UIColor.whiteColor()
        photoLabel.center.x = self.view.center.x
        
        let frameHeight = self.view.frame.height
        
        if (iPhoneScreenSize() == "3.5") {
            photoLabel.center.y = frameHeight * 0.4125
        }
        else if (iPhoneScreenSize() == "4") {
            photoLabel.center.y = frameHeight * 0.395
        }
        else if (iPhoneScreenSize() == "4.7") {
            photoLabel.center.y = frameHeight * 0.38
        }
        else if (iPhoneScreenSize() == "5.5") {
            photoLabel.center.y = frameHeight * 0.37
        }
        
        self.view.addSubview(photoLabel)
    }
    
    func setNameLabel () {
        nameLabel = UILabel(frame: CGRectMake(0, 0, self.view.frame.width - 44, 44))
        nameLabel.text = "คุณชื่อไร ?"
        nameLabel.font = UIFont(name: "SukhumvitSet-Medium", size: 13)
        nameLabel.center.x = self.view.center.x
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.center.y = self.view.frame.height * 0.53
        
        self.view.addSubview(nameLabel)
    }
    
    func setUserFirstName () {
        userFirstNameTextField = UITextField(frame: CGRectMake(0, 0, self.view.frame.width - 44, 44))
        userFirstNameTextField.delegate = self
        userFirstNameTextField.text = DataController.userFirstNameText
        userFirstNameTextField.font = UIFont(name: "SukhumvitSet-Medium", size: 18)
        userFirstNameTextField.textAlignment = NSTextAlignment.Center
        userFirstNameTextField.textColor = UIColor.whiteColor()
        userFirstNameTextField.backgroundColor = UIColor(white: 0, alpha: 0.2)
        userFirstNameTextField.layer.cornerRadius = 6
        userFirstNameTextField.layer.borderColor = UIColor.appBrownColor().CGColor
        userFirstNameTextField.layer.borderWidth = 1
        userFirstNameTextField.returnKeyType = UIReturnKeyType.Done
        userFirstNameTextField.center.x = self.view.center.x
        userFirstNameTextField.center.y = self.view.frame.height * 0.62
        
        self.view.addSubview(userFirstNameTextField)
    }
    
    func setStartButton () {
        if (startButton == nil) {
            startButton = UIButton(frame: CGRectMake(0, 0, self.view.frame.width - 44, 44))
            startButton.titleLabel?.font = UIFont(name: "SukhumvitSet-Medium", size: 18)
            startButton.setTitle("เริ่มเลยสิ !", forState: .Normal)
            startButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            startButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
            startButton.center.x = self.view.center.x
            startButton.center.y = CGRectGetMaxY(self.view.frame) + CGRectGetMaxY(self.startButton.frame)
            startButton.backgroundColor = UIColor.whiteColor()
            startButton.layer.cornerRadius = 6
            startButton.layer.borderColor = UIColor.blackColor().CGColor
            startButton.layer.borderWidth = 1
            startButton.addTarget(self, action: "getStarted", forControlEvents: UIControlEvents.TouchUpInside)
            
            view.addSubview(startButton)
            
            UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
                self.startButton.center.y = CGRectGetMaxY(self.view.frame) - self.startButton.frame.height/2 - 8
                }, completion: nil)
        }
    }

    // MARK: - Controller methods

    func getStarted () {
        self.firstTimes = true
        self.view.endEditing(true)
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: {
            
            self.startButton.center.y = self.view.frame.height + 44
            self.startButton = nil
            }, completion: { (finished: Bool) in
                QuestionViewController.getStartedQuestion(self)
        })
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField.returnKeyType == UIReturnKeyType.Done) {
            self.view.endEditing(true)
            return true
        }
        else {
            return false
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch
        var point = touch.locationInView(self.view)
        
        if (CGRectContainsPoint(profileImageView.frame, point)) {
            changeDisplayPhotoBtnClicked()
        }
        else {
            self.view.endEditing(true)
        }
    }
    
    func changeDisplayPhotoBtnClicked(){
        self.view.endEditing(true)
        
        let alertController = UIAlertController(
            title: "เปลี่ยนรูปภาพ",
            message: "ต้องการเลือกรูปภาพจาก",
            preferredStyle: .ActionSheet)
        
        let selectPictureAction = UIAlertAction(
            title: "อัลบั้ม",
            style: .Default) { (action) -> Void in
                self.getPictureFromSource(takingNewPhoto: false)
        }
        
        let takingPictureAction = UIAlertAction(
            title: "ถ่ายภาพใหม่",
            style: .Default) { (action) -> Void in
                self.getPictureFromSource(takingNewPhoto: true)
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .Cancel) { (action) -> Void in }
        
        alertController.addAction(selectPictureAction)
        alertController.addAction(takingPictureAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(
            alertController,
            animated: true) { () -> Void in }
        
    }
    
    func getPictureFromSource (#takingNewPhoto: Bool) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = (takingNewPhoto) ? .Camera : .SavedPhotosAlbum
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {

        // Show the image we picked to profile image view
        DataController.userProfileImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.profileImageView.image = DataController.userProfileImage
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    internal func keyboardWillShow(notification: NSNotification) {
        
        let frameHeight = self.view.frame.height
        
        if (iPhoneScreenSize() == "3.5") {
            profileImageView.center.y = frameHeight * 0.2
            profileImageViewMark.center.y = frameHeight * 0.2
            photoLabel.center.y = frameHeight * 0.3125
            nameLabel.center.y = frameHeight * 0.39
            userFirstNameTextField.center.y = frameHeight * 0.45
        }
        else if (iPhoneScreenSize() == "4") {
            profileImageView.center.y = frameHeight * 0.2
            profileImageViewMark.center.y = frameHeight * 0.2
            photoLabel.center.y = frameHeight * 0.295
            nameLabel.center.y = frameHeight * 0.39
            userFirstNameTextField.center.y = frameHeight * 0.45
        }
        else if (iPhoneScreenSize() == "4.7") {
            profileImageView.center.y = frameHeight * 0.28
            profileImageViewMark.center.y = frameHeight * 0.28
            photoLabel.center.y = frameHeight * 0.36
            nameLabel.center.y = frameHeight * 0.44
            userFirstNameTextField.center.y = frameHeight * 0.49
            
        }
        else if (iPhoneScreenSize() == "5.5") {
            profileImageView.center.y = frameHeight * 0.28
            profileImageViewMark.center.y = frameHeight * 0.28
            photoLabel.center.y = frameHeight * 0.35
            nameLabel.center.y = frameHeight * 0.44
            userFirstNameTextField.center.y = frameHeight * 0.49
            
        }
        
        nameLabel.alpha = 0
    }
    
    // Handle keyboard hide changes
    internal func keyboardWillHide(notification: NSNotification) {
        
        let frameHeight = self.view.frame.height
        
        if (iPhoneScreenSize() == "3.5") {
            profileImageView.center.y = frameHeight * 0.3
            profileImageViewMark.center.y = frameHeight * 0.3
            userFirstNameTextField.center.y = frameHeight * 0.62
            nameLabel.center.y = frameHeight * 0.53
            photoLabel.center.y = frameHeight * 0.4125
        }
        else if (iPhoneScreenSize() == "4") {
            profileImageView.center.y = frameHeight * 0.3
            profileImageViewMark.center.y = frameHeight * 0.3
            userFirstNameTextField.center.y = frameHeight * 0.62
            nameLabel.center.y = frameHeight * 0.53
            photoLabel.center.y = frameHeight * 0.395
        }
        else if (iPhoneScreenSize() == "4.7") {
            profileImageView.center.y = frameHeight * 0.3
            profileImageViewMark.center.y = frameHeight * 0.3
            userFirstNameTextField.center.y = frameHeight * 0.62
            nameLabel.center.y = frameHeight * 0.53
            photoLabel.center.y = frameHeight * 0.38
        }
        else if (iPhoneScreenSize() == "5.5") {
            profileImageView.center.y = frameHeight * 0.3
            profileImageViewMark.center.y = frameHeight * 0.3
            userFirstNameTextField.center.y = frameHeight * 0.62
            nameLabel.center.y = frameHeight * 0.53
            photoLabel.center.y = frameHeight * 0.37
        }
        
        nameLabel.alpha = 1
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        DataController.userFirstNameText = userFirstNameTextField.text
    }
}