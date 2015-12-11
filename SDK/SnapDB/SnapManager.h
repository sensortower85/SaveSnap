//
//  ScoreManager.h
//  fruitGame
//
//  Created by KCU on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLDatabase.h"

@interface SnapManager : NSObject {
	SQLDatabase*	m_sqlManager;
}

+ (SnapManager*) sharedScoreManager;
+ (void) releaseScoreManager;

- (id) init;

- (NSInteger) addUser: (NSString*) userName;
- (BOOL) addSnap:(NSString*) userName sn:(NSString*)sn m:(int)m st:(int)st ts:(NSTimeInterval)ts mid:(NSString*)mid;
- (BOOL) deleteAllSnap:(NSString*) userName;
- (NSArray*) getSnaps:(NSString*) userName isOnlyAvailable:(BOOL) isAvailable;
- (void) updateSnapStatus:(NSString*) snapId;
- (void) buySnap:(NSString*) snapId;
@end
