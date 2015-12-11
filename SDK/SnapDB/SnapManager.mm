//
//  ScoreManager.m
//  fruitGame
//
//  Created by KCU on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SnapManager.h"

#define kDataBaseName	@"savesnap.SQLite"

@implementation SnapManager

static SnapManager *_sharedScore = nil;

+ (SnapManager*) sharedScoreManager
{
	if (!_sharedScore) 
	{
		_sharedScore = [[SnapManager alloc] init];
	}
	
	return _sharedScore;
}

+ (void) releaseScoreManager 
{
	if (_sharedScore) 
	{
		[_sharedScore release];
		_sharedScore = nil;
	}
}

- (id) init
{
	if ( (self=[super init]) )
	{
		m_sqlManager = [[SQLDatabase alloc] init];
		[m_sqlManager initWithDynamicFile: kDataBaseName];
	}
	
	return self;
}

- (NSInteger) addUser: (NSString*) userName
{
    NSArray* arrayUsers = [m_sqlManager lookupAllForSQL: [NSString stringWithFormat:@"select * from tbl_users where name='%@'", userName]];
    
    if ([arrayUsers count] > 0)
    {
        NSDictionary* userDic = [arrayUsers objectAtIndex: 0];
        return [[userDic objectForKey:@"id"] integerValue];
    }
    
	int nMaxId = [m_sqlManager lookupMax:@"id" Where:@"id!=-1" forTable:@"tbl_users"]+1;
    
	NSMutableString* strSQL = [[NSMutableString alloc] init];
	[strSQL appendFormat: @"insert into '%@'('id', 'name') values(", @"tbl_users"];
	[strSQL appendFormat: @"'%d',", nMaxId];
	[strSQL appendFormat: @"'%@')", userName];
	
	[m_sqlManager runDynamicSQL: strSQL forTable: @"tbl_users"];
	[strSQL release];
    
    return nMaxId;
}

- (BOOL) addSnap:(NSString*) userName sn:(NSString*)sn m:(int)m st:(int)st ts:(NSTimeInterval)ts mid:(NSString*)mid
{
    NSArray* arrayUsers = [m_sqlManager lookupAllForSQL: [NSString stringWithFormat:@"select * from tbl_users where name='%@'", userName]];
    
    if ([arrayUsers count] <= 0)
    {
        return NO;
    }

    NSDictionary* userDic = [arrayUsers objectAtIndex: 0];
    NSInteger userId = [[userDic objectForKey:@"id"] integerValue];
    
    NSArray* arrayFollowers = [m_sqlManager lookupAllForSQL: [NSString stringWithFormat:@"select * from tbl_snaps where mid='%@'", mid]];
    
    if ([arrayFollowers count] > 0)
        return NO;
    
	int nMaxId = [m_sqlManager lookupMax:@"id" Where:@"id!=-1" forTable:@"tbl_snaps"]+1;
    
	NSMutableString* strSQL = [[NSMutableString alloc] init];
	[strSQL appendFormat: @"insert into '%@'('id', 'user_id', 'sn', 'm', 'st', 'ts', 'mid', 'available', 'is_buy', 'deleted') values(", @"tbl_snaps"];
	[strSQL appendFormat: @"'%d',", nMaxId];
	[strSQL appendFormat: @"'%ld',", userId];
    [strSQL appendFormat: @"'%@',", sn];
    [strSQL appendFormat: @"'%d',", m];
    [strSQL appendFormat: @"'%d',", st];
    [strSQL appendFormat: @"'%f',", ts];
    [strSQL appendFormat: @"'%@',", mid];
    [strSQL appendFormat: @"'%d',", 0];
    [strSQL appendFormat: @"'%d',", 0];
    [strSQL appendFormat: @"'%d')", 0];
	
	[m_sqlManager runDynamicSQL: strSQL forTable: @"tbl_snaps"];
	[strSQL release];
    
    return YES;
}

- (BOOL) deleteAllSnap:(NSString*) userName
{
    NSArray* arrayUsers = [m_sqlManager lookupAllForSQL: [NSString stringWithFormat:@"select * from tbl_users where name='%@'", userName]];
    
    if ([arrayUsers count] <= 0)
    {
        return NO;
    }
    
    NSDictionary* userDic = [arrayUsers objectAtIndex: 0];
    NSInteger userId = [[userDic objectForKey:@"id"] integerValue];

    [m_sqlManager updateSQL:[NSString stringWithFormat:@"update tbl_snaps set deleted='1' where user_id=%ld", userId] forTable:@"tbl_snaps"];
    return YES;
}

- (NSArray*) getSnaps:(NSString*) userName isOnlyAvailable:(BOOL) isOnlyAvailable
{
    NSArray* arrayUsers = arrayUsers = [m_sqlManager lookupAllForSQL: [NSString stringWithFormat:@"select * from tbl_users where name='%@'", userName]];
    
    if ([arrayUsers count] <= 0)
    {
        return [NSArray array];
    }
    
    NSDictionary* userDic = [arrayUsers objectAtIndex: 0];
    NSInteger userId = [[userDic objectForKey:@"id"] integerValue];

    if (isOnlyAvailable)
        return [m_sqlManager lookupAllForSQL: [NSString stringWithFormat:@"select * from tbl_snaps where user_id='%ld' and available='1' and deleted ='0'", userId]];
    
    return [m_sqlManager lookupAllForSQL: [NSString stringWithFormat:@"select * from tbl_snaps where user_id='%ld' and deleted ='0'", userId]];
}

- (void) updateSnapStatus:(NSString*) snapId
{
    [m_sqlManager updateSQL:[NSString stringWithFormat:@"update tbl_snaps set available='1' where mid='%@'", snapId] forTable:@"tbl_snaps"];
}

- (void) buySnap:(NSString*) snapId
{
    [m_sqlManager updateSQL:[NSString stringWithFormat:@"update tbl_snaps set is_buy='1' where mid='%@'", snapId] forTable:@"tbl_snaps"];
}

- (void) dealloc
{
	[m_sqlManager release];
	[super dealloc];
}
@end
