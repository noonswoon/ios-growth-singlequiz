//
//  Extension.swift
//  singlelevel
//
//  Created by KHUN NINE on 7/27/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

// Extension for UIColor

extension UIColor {
    
    class func appMainColor () -> UIColor {
        return UIColor(red: 185/255, green: 0/255, blue: 52/255, alpha: 1)
    }
    
    class func appCreamColor () -> UIColor {
        return UIColor(red: 254/255, green: 255/255, blue: 187/255, alpha: 1)
    }
    
    class func appBrownColor () -> UIColor {
        return UIColor(red: 84/255, green: 32/255, blue: 0, alpha: 1)
    }
    
    class func appGreenColor () -> UIColor {
        return UIColor(red: 7/255, green: 89/255, blue: 1/255, alpha: 1)
    }
    
    class func appBlueColor () -> UIColor {
        return UIColor(red: 0, green: 0, blue: 234/255, alpha: 1)
    }
}

extension UIViewController {
    
    // Get the size of current device
    func iPhoneScreenSize () -> String {
        
        var result: CGSize = UIScreen.mainScreen().bounds.size
        
        if(result.height == 480) {
            return "3.5"
        }
        else if(result.height == 568) {
            return "4"
        }
        else if(result.height == 667) {
            return "4.7"
        }
        else if(result.height == 736) {
            return "5.5"
        }
        else {
            return ""
        }
    }

    // Set backgroud image
    func setBackgroundImageView (view: UIView, imagePath: String) {
        
        var backgroundImageView = UIImageView(image: UIImage(named: imagePath))
        backgroundImageView.frame = view.frame
        backgroundImageView.contentMode = .ScaleAspectFill
        
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
}