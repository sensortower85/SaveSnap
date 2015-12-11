//
//  ViewController.m
//  SaveSnap
//
//  Created by heliumsoft on 12/24/14.
//  Copyright (c) 2014 quantum. All rights reserved.
//

#import "ViewController.h"
#import "SnapchatClient.h"
#import "Snap.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SVProgressHUD.h"

@interface ViewController ()<UITextFieldDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIColor * tiledColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"text_blue.jpg"]];
    self.view.backgroundColor = tiledColor;

    NSString* userToken = [AppSettings userToken];
    if (userToken != nil && userToken.length > 0) {
        [[SnapchatClient sharedClient] setUsername: [AppSettings userName]];
        [[SnapchatClient sharedClient] setAuthToken: [AppSettings userToken]];

        [self.navigationController setNavigationBarHidden: NO];

        UIViewController *vc = (UIViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        [self.navigationController pushViewController:vc animated: NO];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) loginAction:(id)sender
{
    NSString* userName = [userNameField text];
    NSString* password = [passwordField text];
    
    if ([userName length] <= 0 || [password length] <= 0)
        return;
    
    [SVProgressHUD showWithStatus:@"Logging in..."];
    
    [[SnapchatClient sharedClient] startLoginWithUsername:userName password:password callback:^(NSError *error){
        if (error == nil)
        {
            [AppSettings setUserName:[SnapchatClient sharedClient].username];
            [AppSettings setUserPass: password];
            [AppSettings setUserToken:[SnapchatClient sharedClient].authToken];
            [[SnapManager sharedScoreManager] addUser:[SnapchatClient sharedClient].username];
            
            [SVProgressHUD dismiss];
            
            [self.navigationController setNavigationBarHidden: NO];
            UIViewController *vc = (UIViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
            [self.navigationController pushViewController:vc animated: YES];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Login failed.\n Please try again."];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == userNameField) {
        [passwordField becomeFirstResponder];
    } else if (textField == passwordField) {
        [passwordField resignFirstResponder];
    }
    return YES;
}

@end
