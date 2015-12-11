//
//  UpgradeViewController.m
//  SaveSnap
//
//  Created by heliumsoft on 1/8/15.
//  Copyright (c) 2015 quantum. All rights reserved.
//

#import "UpgradeViewController.h"

@interface UpgradeViewController ()

@end

@implementation UpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor * tiledColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"text_blue.jpg"]];
    self.view.backgroundColor = tiledColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) upgradeAction:(id)sender
{
    [[MKStoreManager sharedManager] buyFeature:kUnlimitedPackItem onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
        [self dismissViewControllerAnimated: YES completion:nil];
    } onCancelled:^{
    }];
}

- (IBAction) restoreAction:(id)sender
{
    [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^{
        [self dismissViewControllerAnimated: YES completion:nil];
    } onError:^(NSError *error) {
    }];
}
@end
