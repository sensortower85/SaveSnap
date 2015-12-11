//
//  AppSetting.h
//  fruitGame
//
//  Created by KCU on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MAX_UPLOAD_COUNT 3

@interface AppSettings : NSObject 
{

}

+ (void) defineUserDefaults;

+ (void) setAccessToken: (NSString*) tokenString;
+ (NSString*) accessToken;

+ (void) addOneCoinCount;
+ (void) addCoinCount: (int) nCoinCount;
+ (void) setCoinCount: (int) nCoinCount;
+ (BOOL) subCoinCount: (int) nSubCoinCount;
+ (int) coinCount;

+ (BOOL) isRated;
+ (void) setRated: (BOOL) bRated;

+ (BOOL) deniedAlert;
+ (void) setDenyAlert: (BOOL) isDenied;

+ (void) setUserName: (NSString*) name;
+ (NSString*) userName;

+ (void) setUserPass: (NSString*) userPass;
+ (NSString*) userPass;

+ (void) setUserToken: (NSString*) userToken;
+ (NSString*) userToken;

+ (void) setLock:(BOOL) bLock;
+ (BOOL) isLocked;

+ (void) setPasscode:(NSString*) passCode;
+ (NSString*) getPasscode;
@end
