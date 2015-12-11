//
//  AppSetting.m
//  fruitGame
//
//  Created by KCU on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppSettings.h"

@implementation AppSettings

+ (void) defineUserDefaults
{
	NSString* userDefaultsValuesPath;
	NSDictionary* userDefaultsValuesDict;
	
	userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"plist"];
	userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile: userDefaultsValuesPath];
	[[NSUserDefaults standardUserDefaults] registerDefaults: userDefaultsValuesDict];
}
+ (void) setAccessToken: (NSString*) tokenString
 {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:tokenString forKey:@"token"];
    [NSUserDefaults resetStandardUserDefaults];
}

+ (NSString*) accessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"token"];
}

+ (void) addOneCoinCount {
    int nCount = [AppSettings coinCount] + 1;
    [AppSettings setCoinCount: nCount];
}

+ (BOOL) subCoinCount: (int) nSubCoinCount
{
    int nCount = [AppSettings coinCount] - nSubCoinCount;
    if (nCount < 0)
        return NO;
    [AppSettings setCoinCount: nCount];
    return YES;
}

+ (void) addCoinCount: (int) nCoinCount
{
    int nCount = [AppSettings coinCount] + nCoinCount;
    [AppSettings setCoinCount: nCount];
}

+ (void) setCoinCount: (int) nCoinCount {
    NSString* authString = [NSString stringWithFormat:@"%d", nCoinCount];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:authString forKey:@"coincount"];
    [NSUserDefaults resetStandardUserDefaults];
}

+ (int) coinCount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int nCoinCount = [[defaults objectForKey:@"coincount"] intValue];
    return nCoinCount;
}

+ (BOOL) isRated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"rated"] boolValue];
}

+ (void) setRated: (BOOL) bRated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:bRated] forKey:@"rated"];
    [NSUserDefaults resetStandardUserDefaults];
}

+ (BOOL) deniedAlert
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"denyalert"] boolValue];
}

+ (void) setDenyAlert: (BOOL) isDenied
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:isDenied] forKey:@"denyalert"];
    [NSUserDefaults resetStandardUserDefaults];
}


+ (void) setUserToken: (NSString*) userToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userToken forKey:@"userToken"];
    [NSUserDefaults resetStandardUserDefaults];
}
+ (NSString*) userToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"userToken"];
}

+ (void) setUserName: (NSString*) name {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:@"username"];
    [NSUserDefaults resetStandardUserDefaults];
}
+ (NSString*) userName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"username"];
}

+ (void) setUserPass: (NSString*) userPass {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userPass forKey:@"password"];
    [NSUserDefaults resetStandardUserDefaults];
}

+ (NSString*) userPass {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"password"];
}

+ (void) setLock:(BOOL) bLock
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:bLock] forKey:@"locked"];
    [NSUserDefaults resetStandardUserDefaults];
}

+ (BOOL) isLocked
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"locked"] boolValue];
}

+ (void) setPasscode:(NSString*) passCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:passCode forKey:@"passcode"];
    [NSUserDefaults resetStandardUserDefaults];
}

+ (NSString*) getPasscode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"passcode"];
}



@end