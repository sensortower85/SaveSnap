//
//  MediaViewController.h
//  SaveSnap
//
//  Created by heliumsoft on 12/27/14.
//  Copyright (c) 2014 quantum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVPlayerPlaybackView.h"
#import "Snap.h"

@interface MediaViewController : UIViewController
@property(nonatomic, strong) IBOutlet UIImageView* imageView;
@property(nonatomic, strong) IBOutlet UIImageView* playStatusImageView;
@property(nonatomic, strong) IBOutlet AVPlayerPlaybackView* videoView;
@property(nonatomic, retain) Snap* snap;
@end
