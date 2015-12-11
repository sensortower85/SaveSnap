//
//  SnapchatClient.h
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Snap;
@interface SnapchatClient : NSObject{
  NSString *_username;
  NSString *_authToken;
}

@property(readonly) NSArray *snaps;
@property(readonly) NSArray *friends;
@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSString *authToken;

+(SnapchatClient *)sharedClient;

-(void)startLoginWithUsername:(NSString *)username password:(NSString *)password callback:(void (^)(NSError* error))callback;
-(void)logout:(NSString *)username token:(NSString*)token callback:(void (^)(NSError* error))callback;
-(void)startRefreshWithCallback:(void (^)(NSError* error))callback;
-(void)sendData:(NSData *)data toRecipients:(NSArray *)recipients isVideo:(BOOL)video callback:(void (^)(void))callback;

-(void)getMediaForSnap:(Snap *)snap callback:(void(^)(NSData *))callback;

@end
