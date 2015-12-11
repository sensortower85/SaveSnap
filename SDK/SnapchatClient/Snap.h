//
//  Snap.h
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    IMAGE = 0,
    VIDEO,
    VIDEO_NOAUDIO,
    FRIEND_REQUEST,
    FRIEND_REQUEST_IMAGE,
    FRIEND_REQUEST_VIDEO,
    FRIEND_REQUEST_VIDEO_NOAUDIO
}SNAPMEDIATYPE;

typedef enum
{
    NONE = -1,
    SENT = 0,
    DELIVERED = 1,
    VIEWED = 2,
    SCREENSHOT = 3
    
}SNAPMEDIASTATUS;

@protocol LoadDelegate <NSObject>

- (void)completeLoadMedia;

@end


@interface Snap : NSObject

@property NSString *sender;
@property NSDate *timestamp;
@property SNAPMEDIATYPE mediatype;
@property SNAPMEDIASTATUS mediastatus;
@property NSData *data;
@property NSString *mediaID;
@property BOOL existmedia;
@property BOOL buyied;
@property (nonatomic, retain) id<LoadDelegate> loaddelegate;
@property (nonatomic, retain) UIImage* thumbImage;

- (void) loadMedia;
- (void) createThumbnailImage;
@end
