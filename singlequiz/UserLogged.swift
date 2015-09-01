//
//  UserLogged.swift
//  WhyDoPeopleLikeYou
//
//  Created by KHUN NINE on 7/1/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

import Foundation
import Parse

@objc class UserLogged: NSObject {
    
    // MARK: - Parse user logged object
    static var logObject: PFObject!
    
    class func setLogObject () {
        logObject = PFObject(className: "UserLogged")
        logObject.saveInBackgroundWithBlock(nil)
    }
    
    
    // Save user imformation to Parse
    class func saveUserInformation () {

// NEED TO FIXES
        
// fetching all of the user information
//        for key in DataController.userInfo.keys {
//            
//            logObject[key] = DataController.userInfo[key]
//            //println(DataController.userInfo[key])
//        }
//    
//        logObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//            //println("Object has been saved.")
//        }
    }
    
    class func saveUserImageFile (imageFile: PFFile) {
        
        let objectFile = UserLogged.logObject
        objectFile["imageFile"] = imageFile
        logObject.saveInBackgroundWithBlock( nil )
    }
    
    class func shareButtonClicked () {
        
        logObject["clickedShare"] = true
        logObject.saveInBackgroundWithBlock( nil )
    }
    
    class func adsClicked () {
        logObject["clickedAds"] = true
        logObject.saveInBackgroundWithBlock( nil )
    }
}

// MARK: - Google Analytic tracking user behavior
extension UserLogged {
    
    // Tracking events when user press buttons
    class func trackEvent (eventName: String) {
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("UserAction", action: eventName,
            label: nil,
            value: nil).build()  as [NSObject : AnyObject])
    }
    
    // Tracking screens when whose screens appear to users
    class func trackScreen (screenName: String) {
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: screenName)
        
        var builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
}