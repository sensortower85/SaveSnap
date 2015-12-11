//
//  Snap.m
//  Yefchat
//
//  Created by Ishaan Gulrajani on 11/15/13.
//  Copyright (c) 2013 Watchsend. All rights reserved.
//

#import "Snap.h"
#import "SnapchatClient.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+resizedImage.h"

@implementation Snap

- (void) loadMedia
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDir = [paths objectAtIndex: 0];
    NSString* exportURLString = [documentDir stringByAppendingPathComponent:(self.mediatype==VIDEO)?[NSString stringWithFormat:@"%@.mp4", self.mediaID]:self.mediaID];

    BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:exportURLString];
    if (success)
    {
        self.existmedia = YES;
        [self.loaddelegate completeLoadMedia];
        return;
    }
    
    if (self.mediastatus == DELIVERED)
    {
        [[SnapchatClient sharedClient] getMediaForSnap:self callback:^(NSData *data) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (data != nil) {
                    [data writeToFile:exportURLString atomically:NO];
                    self.existmedia = YES;
                    [self.loaddelegate completeLoadMedia];
                    [[SnapManager sharedScoreManager] updateSnapStatus:self.mediaID];
                    [self createThumbnailImage];
                }
            });
        }];
    }
}

- (UIImage *)imageByCroppingImage:(UIImage *)image
{
    float sizeW = image.size.width;
    if (image.size.width > image.size.height)
        sizeW = image.size.height;
    
    CGSize size = CGSizeMake(sizeW, sizeW);
    
    double x = (image.size.width - size.width) / 2.0;
    double y = (image.size.height - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return [cropped resizedImageWithSize: CGSizeMake(128, 128)];
}

-(void)generateImage:(NSURL*) fileURL
{
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:fileURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }
        
        self.thumbImage = [self imageByCroppingImage:[UIImage imageWithCGImage:im]];
        if ([self.loaddelegate respondsToSelector: @selector(completeLoadMedia)]) {
            [self.loaddelegate completeLoadMedia];
        }

        NSLog(@"Complete ThumbImage Gen");
    };
    
    CGSize maxSize = CGSizeMake(640, 640);
    generator.maximumSize = maxSize;
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
}

- (void) createThumbnailImage
{
    if (self.mediastatus == DELIVERED) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* documentDir = [paths objectAtIndex: 0];
            NSString* exportURLString = [documentDir stringByAppendingPathComponent:(self.mediatype==VIDEO)?[NSString stringWithFormat:@"%@.mp4", self.mediaID]:self.mediaID];
            BOOL bFileExist = [[NSFileManager defaultManager] fileExistsAtPath:exportURLString];
            if (bFileExist) {
                if (self.mediatype == IMAGE) {
                    self.thumbImage = [self imageByCroppingImage:[UIImage imageWithContentsOfFile:exportURLString]];
                    [self.loaddelegate completeLoadMedia];
                } else if (self.mediatype == VIDEO) {
                    [self generateImage:[NSURL fileURLWithPath: exportURLString]];
                }
            }
        });
    }
}
@end
