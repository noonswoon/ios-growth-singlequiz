//
//  DataController.swift
//  WhyDoPeopleLikeYou
//
//  Created by KHUN NINE on 6/23/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

import Foundation
import Parse

@objc public class DataController {
    
    static var result = 0
    static var summation = 0
    
    static var questions = [String]()
    static var choices = [String]()
    static var list_questionViewController = [QuestionViewController]()
    
    static var userInfo = Dictionary<String, String>()
    
    static var userProfileImage: UIImage!
    static var userFirstNameText: String!
    
    static let contentURL = REDIRECT_URL
    static let contentTitle = "คุณโสดระดับไหน?"
    static let contentDescription = "คุณเป็นคนโสดรึเปล่า? จริงๆแล้วคุณนั้นโสดแค่ไหน แอพของเราจะบอกระดับความโสดของคุณ ดาวน์โหลด 'โสดแค่ไหน' เพื่อค้นหาระดับความโสดของคุณ และพบกับคำตอบสุดฮาของคุณ อย่าลืมแชร์บอกต่อระดับความโสดของคุณด้วยนะ!"

    static let singleLevelResults = [
        "คุณไม่โสดนี่นา (ยินดีด้วย คุณเป็นคนโชคดีคนหนึ่งที่มีใครให้คิดถึง)",
        "โสดชิว กลับบ้านคนเดียว (ลองหาเพื่อนร่วมทางกลับนะ แชร์ค่าน้ำมัน ประหยัดดี)",
        "โสดติ๊ส เดินห้างคนเดียว (คราวหลังหาเพื่อนมาสักคน จะได้ช่วยกันถือของ)",
        "โสดสู้ฟัด หม่ำข้าวนอกบ้านคนเดียว (ลองชวนเพื่อนสักคนมาด้วย เผื่อได้ส่วนลดค่าอาหาร)",
        "โสดจิต ดูหนังเก้าอี้สวีทคนเดียว (คราวหลังซื้อบัตรธรรมดาก็พอนะ)",
        "โสดบันเทิง ร้องคาราโอเกะคนเดียว (หาใครมาฟังบ้าง จะได้รู้ว่าควรไปประกวดร้องเพลงรึเปล่า)",
        "โสดมโน สามารถพูดคนเดียว (ลองหาแอพเพื่อรู้จักและแชทกับคนใหม่ๆดีไหม)",
        "โสดหลอน เที่ยวสวนสนุกคนเดียว (ลองหาใครสักคนจะได้มีคนคอยลูบหลัง ให้ยาดม)",
        "โสดสาหัส พายเรือคนเดียว (คิดซะว่าเป็นการออกกำลังกายก็แล้วกัน)",
        "โสดโ*ตรพ่อ ฉลองวาเลนไทน์คนเดียว (ลองให้โอกาสตัวคุณเองสิ ขอให้เจอคนพิเศษเร็วๆนะ)"]
    
    // MARK: Setter methods
    class func setUserProfileImg (userID: String) {
        
        let urlString = "https://graph.facebook.com/\(userID)/picture?type=large"
        let nsURL = NSURL(string:  urlString)
        let nsData = NSData(contentsOfURL: nsURL!)
        
        self.userProfileImage = UIImage(data: nsData!)
        
        closeLoadingIndicator()
    }
    
    class func setQuestionAndChoice () {
        
        questions.append("คุณออกไปเจอเพื่อนคุณบ่อยแค่ไหน")
        choices.append("ทุกวัน จนสนิทกับแม่เขาแล้ว")
        choices.append("2-3 ครั้ง ต่ออาทิตย์")
        choices.append("อาทิตย์ละครั้ง")
        choices.append("ครั้งสุดท้ายตอนรับปริญญา")
        
        questions.append("สำหรับเพื่อนในกลุ่มของคุณ\nพวกเขามีแฟนแล้วกี่คน")
        choices.append("มีแฟนแค่คนเดียว ให้เพื่อนอิจฉา")
        choices.append("ยังพอมีหลอมแหลม ชวนไปกินข้าวพอได้")
        choices.append("ไม่มีเลยสักคน โสดหมด")
        choices.append("มีแฟนกันหมดทุกคนยกเว้นคุณ")
        
        questions.append("ถ้าคุณต้องออกไปกินข้าวนอกบ้าน\nคุณอยากพาใครไป")
        choices.append("พาแฟนไป จะได้สวีทกัน")
        choices.append("ชวนเพื่อนจากเฟซบุ๊ก\nลองเปิดโอกาสคุยกัน")
        choices.append("พาครอบครัวไป กินกับที่บ้านแหละดีที่สุด")
        choices.append("ไม่พาไปสักคน กินคนเดียวได้ ประหยัดดี")
        
        questions.append("ถ้าคุณกำลังจะกลับจากที่ทำงาน\nคุณอยากให้ใครมารับคุณมากที่สุด")
        choices.append("แฟน เพราะจะได้เจอหน้ากันบ่อยขึ้น")
        choices.append("เพื่อนสนิท\nเผื่อได้ไปกินไปเที่ยวกันต่อ สนุกๆ")
        choices.append("พ่อหรือแม่ สบายใจดี กลับสบายๆ")
        choices.append("ไม่ต้องมารับหรอก กลับเองได้ โตแล้ว")
        
        questions.append("ถ้าคุณอยุ่ที่โรงหนัง หนังแบบใดที่คุณอยากจะดู")
        choices.append("โรแมนติก ถ้ามีแฟนหรือ\nคนที่ชอบไปดูด้วยนะ อย่างฟิน")
        choices.append("คอมเมดี้ ขบขัน ทำงานก็เครียดมากแล้ว\nผ่อนคลายซะหน่อย")
        choices.append("สยองขวัญสิ ยิ่งไปกับคนที่ชอบนะ\nจะได้พอมีโอกาส")
        choices.append("แอคชั่นบู๊ล้างผลาญ\nไปดูหนังแนวอื่นกลัวกรนกวนคนอื่น")
        
        questions.append("ถ้าคุณไปสวนสนุก\nคุณอยากเล่นเครื่องเล่นอะไร")
        choices.append("ม้าหมุน ยิ่งถ้าไปกับแฟนนะ คงสวีทน่าดู")
        choices.append("บ้านผีสิง จะได้กระตุ้นต่อมเร้าใจในตัวคุณ")
        choices.append("รถไฟเหาะ ยิ่งเล่นคนเดียว ยิ่งเสียว")
        choices.append("ไปทำไมสวนสนุก อยู่บ้านยังสนุกกว่า")
        
        questions.append("ถ้าคุณไปถีบเรือเป็ดเล่น\nกับเพื่อน 3 คน คุณจะ...")
        choices.append("ปล่อยเพื่อนอีกคนให้ถีบคนเดียว")
        choices.append("ไม่เล่นเลย หาอย่างอื่นทำ")
        choices.append("เรือใครเรือมันแยกกันถีบเลย")
        choices.append("ให้เพื่อนถีบกัน2คน แล้วถีบคนเดียว")
        
        questions.append("ความคิดของคุณ วันวาเลนไทน์คือ...")
        choices.append("วันที่จะได้สวีทกับแฟน กระหนุงกระหนิง")
        choices.append("วันที่จะได้กินช็อคโกแลตเยอะๆ")
        choices.append("วันที่จะได้บอกชอบคนที่เราชอบ\nแต่เค้าจะชอบเราหรือไม่อีกเรื่องนึง")
        choices.append("วันธรรมดาวันนึง\nอยู่คนเดียวสไตล์คนโสด")
        
        questions.append("ถ้าคุณอยากร้องคาราโอเกะ\nคุณจะไปที่ไหนกับใคร")
        choices.append("ห้องคาราโอเกะตามห้างกับเพื่อนเยอะๆ")
        choices.append("ตู้คาราโอเกะหยอดเหรียญ\nร้องคนเดียวพอ")
        choices.append("ต่อไมค์ร้องเองที่บ้านกับหลาน และแมว")
        choices.append("ร้องกับ Youtube ก็พอแล้ว\nไมค์ไม่ต้อง แมวไม่ต้อง")
        
        questions.append("กิจกรรมที่คุณจะทำ\nถ้าคุณอยู่ในห้างคนเดียวคือ...")
        choices.append("อยู่ร้านหนังสือ ยืนอ่านฟรีสักหน่อย")
        choices.append("ลองเครื่องสำอาง\nรอวันลดราคา ค่อยมาซื้อ")
        choices.append("เดินดูเลือกเสื้อผ้า\nตั้งหน้าตั้งตารอวันที่เงินเดือนออก")
        choices.append("เข้าร้านบุฟเฟ่ต์ปิ้งย่างแบบไม่แคร์")
    }
    
    // MARK: Generating result
    class func loadUserProfile() {

        let graphPath = "me?fields=gender,id,email,first_name,last_name,birthday"
        var graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: graphPath, parameters: nil, tokenString: FBSDKAccessToken.currentAccessToken().tokenString, version: "v2.3", HTTPMethod: "GET")
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                //println("Error: \(error)")
            }
            else {
                //println("fetched user: \(result)")
                self.setUserInformation(result)
            }
        })
    }
    
    class func setUserInformation (result: AnyObject) {
        
        let fbId      : String = (result.valueForKey("id")         != nil) ? result.valueForKey("id")          as! String : ""
        let firstname : String = (result.valueForKey("first_name") != nil) ? result.valueForKey("first_name")  as! String : ""
        let lastname  : String = (result.valueForKey("last_name")  != nil) ? result.valueForKey("last_name")   as! String : ""
        let email     : String = (result.valueForKey("email")      != nil) ? result.valueForKey("email")       as! String : firstname + "." + lastname + "@facebook.com"
        let birthday  : String = (result.valueForKey("birthday")   != nil) ? result.valueForKey("birthday")    as! String : ""
        let gender    : String = (result.valueForKey("gender")     != nil) ? result.valueForKey("gender")      as! String : "male"
        
        self.userInfo["userId"]     = fbId
        self.userInfo["first_name"] = firstname
        self.userInfo["last_name"]  = lastname
        self.userInfo["email"]      = email
        self.userInfo["birthday"]   = birthday
        self.userInfo["gender"]     = gender
        
        self.setUserProfileImg(fbId)
        self.setUserFirstName(firstname)
        self.subscribePushNotificationChannel(fbId, gender: gender)
    }
    
    class func setUserFirstName (fname: String) {
        
        self.userFirstNameText = fname
        closeLoadingIndicator()
    }
    
    class func closeLoadingIndicator () {
        
        if (userProfileImage != nil && userFirstNameText != nil) {
            
            NSNotificationCenter.defaultCenter().postNotificationName("LoadUserProfileCompleted", object: nil)
            SwiftSpinner.hide()
        }
    }
    
    class func subscribePushNotificationChannel (fbId:String, gender: String) {
        
        var currentInstallation = PFInstallation.currentInstallation()
        var userChannel = PARSE_CHANNEL_PREFIX + fbId
        
        currentInstallation.addUniqueObject(userChannel, forKey: "channels")
        currentInstallation.addUniqueObject(gender, forKey: "channels")
        currentInstallation.saveInBackgroundWithBlock(nil)
    }
    
    // MARK: Getter methods
    class func getUserId () -> String{
        return DataController.userInfo["userId"]!
    }
    
    class func getResultImageForShare () -> UIImage {
        let imgNo = "A" + String(generateResultNumber(getSummation())) + getUserGender()
        return UIImage(named: imgNo)!
    }
    
    class func getResultImage () -> UIImage {
        
        let imgNo = String(generateResultNumber(getSummation())) + getUserGender() + ".jpg"
        return UIImage(named: imgNo)!
    }
    
    class func getResultDescImage () -> UIImage {
        
        let imgNo = "A" + String(generateResultNumber(getSummation()))
        return UIImage(named: imgNo)!
    }
    
    class func getSummation () -> Int {
        
        if (summation < 10) {
            return 10
        }
        else if (summation > 40) {
            return 40
        }
        else {
            return summation
        }
    }
    
    class func getUserGender () -> String{
        var userGender = DataController.userInfo["gender"]
        
        if (userGender == "male") {
            return "m"
        }
        else if (userGender == "female") {
            return "f"
        }
        else {
            return "m"
        }
    }
    
    class func getSingleLevelResults () -> String {
        return singleLevelResults[generateResultNumber(getSummation()) - 1]
    }
    
    class func generateResultNumber (num: Int) -> Int {
        if (num == 40) {
            return 10
        }
        
        if (num < 7 || num > 40) {
            return 1
        }
        
        // Expected result
        return (num-7) / 3
    }
}
