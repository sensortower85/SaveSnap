//
//  InfoViewController.m
//  SaveSnap
//
//  Created by heliumsoft on 12/28/14.
//  Copyright (c) 2014 quantum. All rights reserved.
//

#import "InfoViewController.h"
#import "SVProgressHUD.h"
#import "DeviceHardware.h"
@interface InfoViewController () <UIActionSheetDelegate, LTHPasscodeViewControllerDelegate, UIAlertViewDelegate>

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor * tiledColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"text_blue.jpg"]];
    self.view.backgroundColor = tiledColor;
    [LTHPasscodeViewController sharedUser].delegate = self;
    
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

- (IBAction)  logoutAction
{
    [SVProgressHUD showWithStatus:@"Logout..."];

    [[SnapchatClient sharedClient] logout:[AppSettings userName] token:[AppSettings userToken] callback:^(NSError *error) {
        [AppSettings setUserName: @""];
        [AppSettings setUserToken: @""];
        
        [self.navigationController popToRootViewControllerAnimated: YES];
        [SVProgressHUD dismiss];
    }];
}

- (IBAction) PasscodeAction:(id)sender
{
    if ([LTHPasscodeViewController passcodeExistsInKeychain])
    {
        UIActionSheet*ac = [[UIActionSheet alloc] initWithTitle:@"Turn Passcode off" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Turn Passcode off" otherButtonTitles:@"Change Passcode", nil];
        [ac showInView: self.view];
    }
    else
    {
        UIActionSheet*ac = [[UIActionSheet alloc] initWithTitle:@"Set Passcode" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Turn Passcode on" otherButtonTitles: nil];
        [ac showInView: self.view];
    }
}

- (IBAction) shareWithFriends:(id)sender
{
    UIButton* btnMore = (UIButton*)sender;
    UIActivityViewController* ac = [[UIActivityViewController alloc] initWithActivityItems:@[@"Now with SaveSnap I can save all the Snapchat photos and vidos to the album of my device! Try it too!"]applicationActivities:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:ac];
        [pop presentPopoverFromRect:btnMore.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self.navigationController presentViewController:ac animated:YES completion:^{
        }];
    }
}

- (IBAction) troubleAction:(id)sender
{
    UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Attention" message:@"If you cannot save Snapchat snaps, please go to Settings - Privacy - Photos, choose SnapSave from the list and allow it to access your photos." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [av show];
}

- (IBAction) howtoUseAction:(id)sender
{
    UIViewController *vc = (UIViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
    [self.navigationController pushViewController:vc animated: YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultFailed) {
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) contactUsAction:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"To support team from SaveSnap"];
        NSString *emailBody = [DeviceHardware totalApplicationInfo];
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}


#pragma mark UIActionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex == buttonIndex)
        return;
    
    if ([LTHPasscodeViewController passcodeExistsInKeychain])
    {
        if (buttonIndex == actionSheet.destructiveButtonIndex)
        {
            [[LTHPasscodeViewController sharedUser] showForTurningOffPasscodeInViewController: self];
        }
        else
        {
            [[LTHPasscodeViewController sharedUser] showForChangingPasscodeInViewController: self];
        }
    }
    else
    {
        [[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController: self];
    }
}


@end
