//
//  QuestionViewController.m
//  singlequiz
//
//  Created by KHUN NINE on 8/21/15.
//  Copyright (c) 2015 KHUN NINE. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import "DataController.h"
#import "Extension.h"
#import "settings.h"
#import "singlequiz-Swift.h"

@interface DataController ()
@end

static DataController *gInstance = nil;

@implementation DataController

int result = 0;
int summation = 0;

NSMutableArray *questions;
NSMutableArray *choices;
NSMutableArray *list_questionViewController;

NSDictionary *userInfo;

UIImage  *userProfileImage;
NSString *userFirstNameText;

NSString *contentURL         = REDIRECT_URL;
NSString *contentTitle       = @"คุณโสดระดับไหน?";
NSString *contentDescription = @"คุณเป็นคนโสดรึเปล่า? จริงๆแล้วคุณนั้นโสดแค่ไหน แอพของเราจะบอกระดับความโสดของคุณ ดาวน์โหลด 'โสดแค่ไหน' เพื่อค้นหาระดับความโสดของคุณ และพบกับคำตอบสุดฮาของคุณ อย่าลืมแชร์บอกต่อระดับความโสดของคุณด้วยนะ!";

NSMutableArray *singleLevelResults;

+ (id) sharedInstance {
    @synchronized(self) {
        if (gInstance == nil) {
            gInstance = [[self alloc] init];
        }
    }
    
    return gInstance;
}

- (id) init {
    if (!(self = [super init])) {
        return nil;
    }
    
    singleLevelResults = [NSMutableArray new];
    [singleLevelResults addObject:@"คุณไม่โสดนี่นา (ยินดีด้วย คุณเป็นคนโชคดีคนหนึ่งที่มีใครให้คิดถึง)"];
    [singleLevelResults addObject:@"คุณไม่โสดนี่นา (ยินดีด้วย คุณเป็นคนโชคดีคนหนึ่งที่มีใครให้คิดถึง)"];
    [singleLevelResults addObject:@"โสดชิว กลับบ้านคนเดียว (ลองหาเพื่อนร่วมทางกลับนะ แชร์ค่าน้ำมัน ประหยัดดี)"];
    [singleLevelResults addObject:@"โสดติ๊ส เดินห้างคนเดียว (คราวหลังหาเพื่อนมาสักคน จะได้ช่วยกันถือของ)"];
    [singleLevelResults addObject:@"โสดสู้ฟัด หม่ำข้าวนอกบ้านคนเดียว (ลองชวนเพื่อนสักคนมาด้วย เผื่อได้ส่วนลดค่าอาหาร)"];
    [singleLevelResults addObject:@"โสดจิต ดูหนังเก้าอี้สวีทคนเดียว (คราวหลังซื้อบัตรธรรมดาก็พอนะ)"];
    [singleLevelResults addObject:@"โสดบันเทิง ร้องคาราโอเกะคนเดียว (หาใครมาฟังบ้าง จะได้รู้ว่าควรไปประกวดร้องเพลงรึเปล่า)"];
    [singleLevelResults addObject:@"โสดมโน สามารถพูดคนเดียว (ลองหาแอพเพื่อรู้จักและแชทกับคนใหม่ๆดีไหม)"];
    [singleLevelResults addObject:@"โสดหลอน เที่ยวสวนสนุกคนเดียว (ลองหาใครสักคนจะได้มีคนคอยลูบหลัง ให้ยาดม)"];
    [singleLevelResults addObject:@"โสดสาหัส พายเรือคนเดียว (คิดซะว่าเป็นการออกกำลังกายก็แล้วกัน)"];
    [singleLevelResults addObject:@"โสดโ*ตรพ่อ ฉลองวาเลนไทน์คนเดียว (ลองให้โอกาสตัวคุณเองสิ ขอให้เจอคนพิเศษเร็วๆนะ)"];
    
    gInstance.list_questionViewController = [NSMutableArray new]; // = [QuestionViewController]()
    
    return self;
}

//// MARK: Setter methods
- (void) setUserProfileImg: (NSString *) userID {
    
    NSString *urlString = [NSString stringWithFormat: @"https://graph.facebook.com/%@/picture?type=large", userID];
    NSURL *nsURL = [[NSURL alloc] initWithString: urlString];
    NSData *nsData = [[NSData alloc] initWithContentsOfURL: nsURL];
    
    userProfileImage = [[UIImage alloc] initWithData:nsData];
    
    [self closeLoadingIndicator];
}

- (void) setQuestionAndChoice {
    
    questions   = [NSMutableArray new];
    choices = [NSMutableArray new];
    
    [questions addObject:@"คุณออกไปเจอเพื่อนคุณบ่อยแค่ไหน"];
    [choices addObject:@"ทุกวัน จนสนิทกับแม่เขาแล้ว"];
    [choices addObject:@"2-3 ครั้ง ต่ออาทิตย์"];
    [choices addObject:@"อาทิตย์ละครั้ง"];
    [choices addObject:@"ครั้งสุดท้ายตอนรับปริญญา"];
    
    NSLog(@"%lu", (unsigned long)questions.count);
    NSLog(@"%lu", (unsigned long)choices.count);
    
    [questions addObject:@"สำหรับเพื่อนในกลุ่มของคุณ\nพวกเขามีแฟนแล้วกี่คน"];
    [choices addObject:@"มีแฟนแค่คนเดียว ให้เพื่อนอิจฉา"];
    [choices addObject:@"ยังพอมีหลอมแหลม ชวนไปกินข้าวพอได้"];
    [choices addObject:@"ไม่มีเลยสักคน โสดหมด"];
    [choices addObject:@"มีแฟนกันหมดทุกคนยกเว้นคุณ"];
    
    [questions addObject:@"ถ้าคุณต้องออกไปกินข้าวนอกบ้าน\nคุณอยากพาใครไป"];
    [choices addObject:@"พาแฟนไป จะได้สวีทกัน"];
    [choices addObject:@"ชวนเพื่อนจากเฟซบุ๊ก\nลองเปิดโอกาสคุยกัน"];
    [choices addObject:@"พาครอบครัวไป กินกับที่บ้านแหละดีที่สุด"];
    [choices addObject:@"ไม่พาไปสักคน กินคนเดียวได้ ประหยัดดี"];
    
    [questions addObject:@"ถ้าคุณกำลังจะกลับจากที่ทำงาน\nคุณอยากให้ใครมารับคุณมากที่สุด"];
    [choices addObject:@"แฟน เพราะจะได้เจอหน้ากันบ่อยขึ้น"];
    [choices addObject:@"เพื่อนสนิท\nเผื่อได้ไปกินไปเที่ยวกันต่อ สนุกๆ"];
    [choices addObject:@"พ่อหรือแม่ สบายใจดี กลับสบายๆ"];
    [choices addObject:@"ไม่ต้องมารับหรอก กลับเองได้ โตแล้ว"];
    
    [questions addObject:@"ถ้าคุณอยุ่ที่โรงหนัง หนังแบบใดที่คุณอยากจะดู"];
    [choices addObject:@"โรแมนติก ถ้ามีแฟนหรือ\nคนที่ชอบไปดูด้วยนะ อย่างฟิน"];
    [choices addObject:@"คอมเมดี้ ขบขัน ทำงานก็เครียดมากแล้ว\nผ่อนคลายซะหน่อย"];
    [choices addObject:@"สยองขวัญสิ ยิ่งไปกับคนที่ชอบนะ\nจะได้พอมีโอกาส"];
    [choices addObject:@"แอคชั่นบู๊ล้างผลาญ\nไปดูหนังแนวอื่นกลัวกรนกวนคนอื่น"];
    
    [questions addObject:@"ถ้าคุณไปสวนสนุก\nคุณอยากเล่นเครื่องเล่นอะไร"];
    [choices addObject:@"ม้าหมุน ยิ่งถ้าไปกับแฟนนะ คงสวีทน่าดู"];
    [choices addObject:@"บ้านผีสิง จะได้กระตุ้นต่อมเร้าใจในตัวคุณ"];
    [choices addObject:@"รถไฟเหาะ ยิ่งเล่นคนเดียว ยิ่งเสียว"];
    [choices addObject:@"ไปทำไมสวนสนุก อยู่บ้านยังสนุกกว่า"];
    
    [questions addObject:@"ถ้าคุณไปถีบเรือเป็ดเล่น\nกับเพื่อน 3 คน คุณจะ..."];
    [choices addObject:@"ปล่อยเพื่อนอีกคนให้ถีบคนเดียว"];
    [choices addObject:@"ไม่เล่นเลย หาอย่างอื่นทำ"];
    [choices addObject:@"เรือใครเรือมันแยกกันถีบเลย"];
    [choices addObject:@"ให้เพื่อนถีบกัน2คน แล้วถีบคนเดียว"];
    
    [questions addObject:@"ความคิดของคุณ วันวาเลนไทน์คือ..."];
    [choices addObject:@"วันที่จะได้สวีทกับแฟน กระหนุงกระหนิง"];
    [choices addObject:@"วันที่จะได้กินช็อคโกแลตเยอะๆ"];
    [choices addObject:@"วันที่จะได้บอกชอบคนที่เราชอบ\nแต่เค้าจะชอบเราหรือไม่อีกเรื่องนึง"];
    [choices addObject:@"วันธรรมดาวันนึง\nอยู่คนเดียวสไตล์คนโสด"];
    
    [questions addObject:@"ถ้าคุณอยากร้องคาราโอเกะ\nคุณจะไปที่ไหนกับใคร"];
    [choices addObject:@"ห้องคาราโอเกะตามห้างกับเพื่อนเยอะๆ"];
    [choices addObject:@"ตู้คาราโอเกะหยอดเหรียญ\nร้องคนเดียวพอ"];
    [choices addObject:@"ต่อไมค์ร้องเองที่บ้านกับหลาน และแมว"];
    [choices addObject:@"ร้องกับ Youtube ก็พอแล้ว\nไมค์ไม่ต้อง แมวไม่ต้อง"];
    
    [questions addObject:@"กิจกรรมที่คุณจะทำ\nถ้าคุณอยู่ในห้างคนเดียวคือ..."];
    [choices addObject:@"อยู่ร้านหนังสือ ยืนอ่านฟรีสักหน่อย"];
    [choices addObject:@"ลองเครื่องสำอาง\nรอวันลดราคา ค่อยมาซื้อ"];
    [choices addObject:@"เดินดูเลือกเสื้อผ้า\nตั้งหน้าตั้งตารอวันที่เงินเดือนออก"];
    [choices addObject:@"เข้าร้านบุฟเฟ่ต์ปิ้งย่างแบบไม่แคร์"];
    
    NSLog(@"%lu", (unsigned long)questions.count);
    NSLog(@"%lu", (unsigned long)choices.count);
}

// MARK: Generating result
- (void) loadUserProfile {

    NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
    NSString *graphPath = @"me?fields=gender,id,email,first_name,last_name,birthday";
    FBSDKGraphRequest *graphRequest = [[FBSDKGraphRequest alloc] initWithGraphPath: graphPath parameters:nil tokenString:token version:@"v2.3" HTTPMethod:@"GET"];

    [graphRequest startWithCompletionHandler: ^(FBSDKGraphRequestConnection *connection, id reseult, NSError *error) {
        if (!error) {
            NSLog(@"fetched user:%d", result);
        }
//        if (error) {
//            NSLog(@"Error: %@", error);
//        }
//        else {
//            [self setUserInformation: result];
//        }
    }];
}

- (void) setUserInformation: (NSObject *) result {

    NSString *fbId = ([result valueForKey:@"id"]) ? [result valueForKey:@"id"] : @"";
    NSString *firstname= ([result valueForKey:@"first_name"]) ? [result valueForKey:@"first_name"] : @"";
    NSString *lastname = ([result valueForKey:@"last_name"]) ? [result valueForKey:@"last_name"] : @"";
    NSString *email = ([result valueForKey:@"email"]) ? [result valueForKey:@"email"] : [NSString stringWithFormat: @"%@.%@@facebook.com", firstname, lastname];
    NSString *birthday = ([result valueForKey:@"birthday"]) ? [result valueForKey:@"birthday"] : @"";
    NSString *gender = ([result valueForKey:@"gender"]) ? [result valueForKey:@"gender"] : @"male";
    
    userInfo = @{
      @"userId"     : fbId,
      @"first_name" : firstname,
      @"last_name"  : lastname,
      @"email"      : email,
      @"birthday"   : birthday,
      @"gender"     : gender
    };
    
    [self setUserProfileImg: fbId];
    [self setUserFirstName: firstname];
    [self subscribePushNotificationChannel:fbId gender:gender];
}

- (void) setUserFirstName: (NSString *) fname {

    userFirstNameText = fname;
    [self closeLoadingIndicator];
}

- (void) closeLoadingIndicator {
    
    if (userProfileImage && userFirstNameText) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadUserProfileCompleted" object:nil];
        [SwiftSpinner hideWithCompletion:nil];
    }
}

- (void) subscribePushNotificationChannel: (NSString *) fbId gender: (NSString *) gender {

    NSString *userChannel = [NSString stringWithFormat: @"%@%@", PARSE_CHANNEL_PREFIX, fbId];
    
    // When users indicate they are Giants fans, we subscribe them to that channel.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:userChannel forKey:@"channels"];
    [currentInstallation addUniqueObject:gender      forKey:@"channels"];
    [currentInstallation saveInBackground];
}

// MARK: Getter methods
- (NSString *) getUserId {
    return [userInfo objectForKey:@"userId"];
}

- (UIImage *) getResultImageForShare {
    int imageNo = [self generateResultNumber: [self getSummation]];
    NSString *userGender = [self getUserGender];
    NSString *imageName = [NSString stringWithFormat: @"A%d%@", imageNo, userGender];
    return  [UIImage imageNamed:imageName];
}

- (UIImage *) getResultImage {
    int imageNo = [self generateResultNumber: [self getSummation]];
    NSString *userGender = [self getUserGender];
    NSString *imageName = [NSString stringWithFormat: @"%d%@.jpg", imageNo, userGender];
    return [UIImage imageNamed:imageName];
}

- (UIImage *) getResultDescImage {
    int imageNo = [self generateResultNumber: [self getSummation]];
    NSString *imageName = [NSString stringWithFormat: @"A%d", imageNo];
    return [UIImage imageNamed: imageName];
}

- (int) getSummation {
    
    if (summation < 10) {
        return 10;
    }
    else if (summation > 40) {
        return 40;
    }
    else {
        return summation;
    }
}

- (NSString *) getUserGender {
    
    NSString *userGender = [userInfo objectForKey:@"gender"];
    
    if ([userGender isEqualToString: @"male"]) {
        return @"m";
    }
    else if ([userGender isEqualToString: @"female"]) {
        return @"f";
    }
    else {
        return @"m";
    }
}

- (NSString *) getSingleLevelResults {
    int summationNum = [self getSummation] - 1;
    int randomNumber = [self generateResultNumber:summationNum];
    return singleLevelResults[randomNumber];
}

- (int) generateResultNumber: (int) num {
    if (num == 40) {
        return 10;
    }
    
    if (num < 7 || num > 40) {
        return 1;
    }
    
    // Expected result
    return (num-7) / 3;
}

@end