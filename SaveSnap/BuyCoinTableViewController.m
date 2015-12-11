//
//  BuyCoinTableViewController.m
//  SaveSnap
//
//  Created by heliumsoft on 12/28/14.
//  Copyright (c) 2014 quantum. All rights reserved.
//

#import "BuyCoinTableViewController.h"
#import "UIButton+Bootstrap.h"

@interface BuyCoinTableViewController ()

@end

@implementation BuyCoinTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backBtn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
}

- (void) backAction
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if ([indexPath row] == 0)
        height = 200;
    else
        height = 50;
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* TitleCellIdentifier = @"TitleCell";
    static NSString* CoinCellIdentifier = @"CoinCell";
    static NSString* RestoreCellIdentifier = @"RestoreCell";
    
    UITableViewCell *cell;
    NSString* CellIdentifier = @"";
    
    if ([indexPath row] == 0)
        CellIdentifier = TitleCellIdentifier;
    else if ([indexPath row] <= 3)
        CellIdentifier = CoinCellIdentifier;
    else if ([indexPath row] == 4)
        CellIdentifier = RestoreCellIdentifier;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if ([indexPath row] == 0)
    {
        UILabel* titleLabel = (UILabel*)[cell viewWithTag: 1];
        [titleLabel setText: [NSString stringWithFormat:@"You currently have %d coins", [AppSettings coinCount]]];
    }
    else if ([indexPath row] <= 3)
    {
        UILabel* titleLabel = (UILabel*)[cell viewWithTag: 1];
        UIButton* button = (UIButton*)[cell viewWithTag: 2];
        [button successStyle];

        NSString*titles[] = {@"Get +100 coins", @"Get +500 coins", @"Get unlimited coins"};
        NSString*prices[] = {@"$0.99", @"$2.99", @"$9.99"};
        
        [titleLabel setText: titles[indexPath.row-1]];
        [button setTitle:prices[indexPath.row-1] forState:UIControlStateNormal];
    }
    else if ([indexPath row] == 4)
    {
        UIButton* button = (UIButton*)[cell viewWithTag: 1];
        [button successStyle];
        
        [button setTitle:@"Restore purchases" forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch ([indexPath row]) {
        case 1:
        {
            [[MKStoreManager sharedManager] buyFeature:k100PackItem onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
                [AppSettings addCoinCount: 100];
            } onCancelled:^{
            }];
        }
            break;
        case 2:
        {
            [[MKStoreManager sharedManager] buyFeature:k500PackItem onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
                [AppSettings addCoinCount: 500];
            } onCancelled:^{
            }];
        }
            break;
        case 3:
        {
            [[MKStoreManager sharedManager] buyFeature:kUnlimitedPackItem onComplete:^(NSString *purchasedFeature, NSData *purchasedReceipt, NSArray *availableDownloads) {
            } onCancelled:^{
            }];
        }
            break;
        default:
            break;
    }
}

@end
