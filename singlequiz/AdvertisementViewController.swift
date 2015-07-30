//
//  AdvertisementViewController.swift
//  WhyDoPeopleLikeYou
//
//  Created by KHUN NINE on 6/24/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

import Foundation
import Parse


class AdvertismentController: NSObject, AdBuddizDelegate{
    
    static var NSituneLink = "itunes.apple.com/th/app/noonswoon-top-dating-app-to/id605218289?mt=8"
    
    static var alertView: CustomAlertView!
    static var percentForShowingNSAds = 50
    
    static var eneabledAds: Bool = false
    static var userClickedShareButton: Bool = true

    // MARK: - Setter methods
    
    class func setDelegate () {
        AdBuddiz.setDelegate(AdvertismentController.self())
    }
    
    class func setUserClickedShare (flag: Bool) {
        self.userClickedShareButton = flag
    }
    
    // MARK: - Getter methods
    
    class func isEnabled () -> Bool {
        return eneabledAds
    }
    
    class func isUserClickShareButton () -> Bool {
        return userClickedShareButton
    }
    
    // MARK: - Controller methods
    
    // Show the advertisments, it should has a few delays before showing up
    class func showAds (timeDelay: Double) {
        
        let chance: Bool = arc4random_uniform(100).hashValue < AdvertismentController.percentForShowingNSAds
        
        if (AdBuddiz.isReadyToShowAd() == false || chance) {
            showNoonswoonAds(timeDelay)
        }
        else {
            setDelegate()
            showAdsBuddiz(timeDelay)
        }
    }
    
    class func showNoonswoonAds (timeDelay: Double) {
        let delay = timeDelay * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.launchAlertView()
        }
    }
    
    class func showAdsBuddiz (timeDelay: Double) {
        let delay = timeDelay * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            AdBuddiz.showAd()
        }
    }
    
    class func enebleAds () {
        self.eneabledAds = true
    }
    
    class func disableAds () {
        self.eneabledAds = false
    }

    // MARK: - AdBuddiz Delegate
    
    func didHideAd() {
        println("didHideAd !!!!!!!!!!!")
    }
    
    func didShowAd() {
        // Disable ads after it shows
        AdvertismentController.disableAds()
    }
    
    func didClick() {
        UserLogged.adsClicked()
        UserLogged.trackEvent("User clicked ads")
    }
    
    // MARK: - Create the Noonswoon ads
    
    class func launchAlertView() {
        
        alertView = CustomAlertView()
        alertView.buttonTitles = ["Cancel"]
        alertView.containerView = createContainerView()
        alertView.onButtonTouchUpInside = { (alertView: CustomAlertView, buttonIndex: Int) -> Void in
            AdvertismentController.alertView.close()
        }
        
        alertView.show()

    }
    
    // Create a custom container view, to show more person information
    class func createContainerView() -> UIView {

        let adsImg = UIImage(named: "NoonswoonAds")!
        
        let imgFactor: CGFloat = adsImg.size.height / adsImg.size.width
        let screenWidth = UIScreen.mainScreen().bounds.width * 0.85
        let adsHeight: CGFloat = screenWidth * imgFactor
        let frame = CGRectMake(0, 0, screenWidth, adsHeight)
        
        let adsButton = UIButton(frame: frame)
        adsButton.setImage(adsImg, forState: .Normal)
        adsButton.setImage(adsImg, forState: .Highlighted)
        adsButton.addTarget(self, action: "userClickedNSAds", forControlEvents: UIControlEvents.TouchUpInside)
        
        let view = UIView(frame: frame)
        view.addSubview(adsButton)
        
        return view
    }
    
    class func userClickedNSAds () {
        AdvertismentController.alertView.close()
        UserLogged.trackEvent("User Clicked Noonswoon ads")
        openiTunes(NSituneLink)
    }
    
    class func openiTunes (link: String) {
        UIApplication.sharedApplication().openURL(NSURL(string: "itms://" + link)!)
    }
}
