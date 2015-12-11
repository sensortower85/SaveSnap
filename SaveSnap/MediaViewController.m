//
//  MediaViewController.m
//  SaveSnap
//
//  Created by heliumsoft on 12/27/14.
//  Copyright (c) 2014 quantum. All rights reserved.
//

#import "MediaViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MediaViewController () <UIActionSheetDelegate>
@property(nonatomic) BOOL isImage;
@property(nonatomic, retain) AVPlayer* player;
@property(nonatomic, retain) AVPlayerItem* playerItem;
@property(nonatomic) BOOL playingVideo;
@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor * tiledColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"text_blue.jpg"]];
    self.view.backgroundColor = tiledColor;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(saveMedia)];

    self.isImage = (self.snap.mediatype == IMAGE)?YES:NO;
    
    self.title = self.snap.sender;

    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDir = [paths objectAtIndex: 0];
    NSString* exportURLString = [documentDir stringByAppendingPathComponent:(self.snap.mediatype==VIDEO)?[NSString stringWithFormat:@"%@.mp4", self.snap.mediaID]:self.snap.mediaID];

    if (self.isImage)
    {
        [self.imageView setHidden: NO];
        [self.videoView setHidden: YES];
        
        UIImage* image = [UIImage imageWithContentsOfFile: exportURLString];
        [self.imageView setImage:image];
        
        CGSize winSize = self.view.frame.size;
        CGSize imageSize = image.size;

        float fRatio = imageSize.width / imageSize.height;
        float fixW, fixH;
        
        if (fRatio > 0)
        {
            fixW = winSize.width;
            fixH = fixW/fRatio;
        } else {
            fixH = winSize.height - 100;
            fixW = fixW*fRatio;
        }
        
        [self.imageView setFrame: CGRectMake(0, 0, fixW, fixH)];
        [self.imageView setCenter: CGPointMake(winSize.width/2.0f, winSize.height/2.0f)];
    }
    else
    {
        [self.imageView setHidden: YES];
        [self.videoView setHidden: NO];
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:exportURLString] options:nil];
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        self.player = [[AVPlayer alloc] initWithPlayerItem: self.playerItem];
        [self.videoView setPlayer: self.player];
        [_player play];
        self.playingVideo = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.playerItem];
        
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
}

- (void) backAction
{
    [self.navigationController popViewControllerAnimated: YES];
}


/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* After the movie has played to its end time, seek back to time zero
     to play it again. */
    [self.player seekToTime:kCMTimeZero];
    self.playingVideo = NO;
//    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.playingVideo = !self.playingVideo;
    
    if (self.playingVideo)
        [self.player play];
    else
        [self.player pause];
}

- (void) shareMedia:(id) sender
{
    UIBarButtonItem* btnShare = (UIBarButtonItem*)sender;
    UIActivityViewController* ac;
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDir = [paths objectAtIndex: 0];
    NSString* exportURLString = [documentDir stringByAppendingPathComponent:(self.snap.mediatype==VIDEO)?[NSString stringWithFormat:@"%@.mp4", self.snap.mediaID]:self.snap.mediaID];

    if (self.isImage)
    {
        UIImage* image = [UIImage imageWithContentsOfFile: exportURLString];
        ac = [[UIActivityViewController alloc] initWithActivityItems:@[@"@snapsaveapp #snapsaveapp", image] applicationActivities:nil];
    }
    else
    {
        ac = [[UIActivityViewController alloc] initWithActivityItems:@[@"@snapsaveapp #snapsaveapp", [NSURL fileURLWithPath:exportURLString]] applicationActivities:nil];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:ac];
        [pop presentPopoverFromBarButtonItem:btnShare permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self.navigationController presentViewController:ac animated:YES completion:^{
        }];
    }
}

- (void) saveMedia
{
    if ([AppSettings deniedAlert] == NO)
    {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"You have no rights to save or share this snap.\n Saving or sharing it, you violate sender's privacy." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Do not show  this alert again." otherButtonTitles:@"Save anyway", nil];
        [ac showInView: self.view];
        return;
    }
    
    [self shareMedia: self.navigationItem.rightBarButtonItem];
}

#pragma mark UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        [AppSettings setDenyAlert: YES];
    }
    
    [self shareMedia:self.navigationItem.rightBarButtonItem];
}
@end
