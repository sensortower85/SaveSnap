//
//  MainViewController.h
//  SaveSnap
//
//  Created by heliumsoft on 12/24/14.
//  Copyright (c) 2014 quantum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snap.h"

typedef void (^JSRenderOperationCompletionBlock)(UIImage *strip, NSError *error);

@interface MainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, LoadDelegate>
@property(nonatomic, strong) IBOutlet UITableView* tableView;
@property(nonatomic, strong) IBOutlet UIButton* allTab;
@property(nonatomic, strong) IBOutlet UIButton* availableTab;
@end
