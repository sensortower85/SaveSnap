//
//  MainViewController.m
//  SaveSnap
//
//  Created by heliumsoft on 12/24/14.
//  Copyright (c) 2014 quantum. All rights reserved.
//

#import "MainViewController.h"
#import "SnapchatClient.h"
#import "Snap.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SVProgressHUD.h"
#import "SCBlob.h"
#import "NSDate+TimeAgo.h"
#import "EGORefreshTableHeaderView.h"
#import "MediaViewController.h"
#import "UIBarButtonItem+Badge.h"

@interface MainViewController () <EGORefreshTableHeaderDelegate, UIActionSheetDelegate>
@property(nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;
@property(nonatomic) BOOL reloading;
@property(nonatomic) BOOL isOnlyAvailable;
@property(nonatomic, strong) NSMutableArray* snaps;
@property(nonatomic, strong) NSMutableArray* showSnaps;

@end

@implementation MainViewController

- (void) reloadSnapMedia {
    for (NSInteger i = 0; i < [self.snaps count]; i ++)
    {
        Snap* snap = [self.snaps objectAtIndex: i];
        [snap loadMedia];
    }
}

- (void) fillSnapsInArray:(id) sender
{
    NSArray* snapsForDB = [[SnapManager sharedScoreManager] getSnaps:[AppSettings userName] isOnlyAvailable: NO];
    for (NSInteger i = 0; i < [snapsForDB count]; i ++)
    {
        NSDictionary* dic = [snapsForDB objectAtIndex: i];
        NSString*mediaID = [dic objectForKey: @"mid"];
        BOOL isBuyed = [[dic objectForKey: @"is_buy"] boolValue];

        BOOL needAdd = YES;
        for (NSInteger j = 0; j < [self.snaps count]; j ++) {
            Snap* snapCompare = [self.snaps objectAtIndex: j];
            if ([snapCompare.mediaID isEqualToString: mediaID]) {
                needAdd = NO;
                snapCompare.buyied = isBuyed;
                break;
            }
        }

        if (needAdd)
        {
            int nType = [[dic objectForKey: @"m"] intValue];
            if (!(nType == VIDEO || nType == IMAGE || nType == VIDEO_NOAUDIO))
            {
                needAdd = NO;
                continue;
            }
            
            if ([[dic objectForKey:@"deleted"] intValue] == 1)
            {
                needAdd = NO;
                continue;
            }
            
            Snap* snap = [[Snap alloc] init];
            snap.loaddelegate = sender;
            snap.sender = [dic objectForKey: @"sn"];
            snap.mediastatus = [[dic objectForKey: @"st"] intValue];
            snap.mediatype = [[dic objectForKey: @"m"] intValue];
            snap.mediaID = [dic objectForKey: @"mid"];
            snap.buyied = [[dic objectForKey: @"is_buy"] boolValue];
            snap.timestamp = [NSDate dateWithTimeIntervalSince1970: [[dic objectForKey:@"ts"] doubleValue]];
            [snap createThumbnailImage];
            [self.snaps addObject: snap];
        }
    }
    
    
    //SORT SNAP ARRAY
    NSArray* sortedArray = [self.snaps sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate* a = [((Snap*)obj1) timestamp];
        NSDate* b = [((Snap*)obj2) timestamp];
        
        return [b compare: a];
    }];

    [self.snaps removeAllObjects];
    [self.snaps addObjectsFromArray: sortedArray];
    
    for (NSInteger i = 0; i < [self.snaps count]; i ++)
    {
        Snap* snap = [self.snaps objectAtIndex: i];
        snap.loaddelegate = self;
        [snap createThumbnailImage];
    }
    
    [self.showSnaps removeAllObjects];
    
    if (self.isOnlyAvailable)
    {
        for (NSInteger i = 0; i < [self.snaps count]; i ++)
        {
            Snap* snap = (Snap*)[self.snaps objectAtIndex: i];
            
            if (snap.existmedia)
            {
                [self.showSnaps addObject: snap];
            }
        }
    }
    else
    {
        [self.showSnaps addObjectsFromArray: self.snaps];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    UIImage *image = [UIImage imageNamed:@"topCoin.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,image.size.width, image.size.height);
    [button addTarget:self action:@selector(buyCoins) forControlEvents:UIControlEventTouchDown];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    // Make BarButton Item
    UIBarButtonItem *navLeftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = navLeftButton;
    self.navigationItem.leftBarButtonItem.badgeValue = [NSString stringWithFormat:@"+%d", [AppSettings coinCount]];
    self.navigationItem.leftBarButtonItem.badgeFont = [UIFont systemFontOfSize: 18];
    self.navigationItem.leftBarButtonItem.badgeBGColor = [UIColor clearColor];
    
    [self.navigationController setNavigationBarHidden: NO];
}

- (void) reloadSnaps
{
    __weak __typeof(self)weakSelf = self;
    
    [[SnapchatClient sharedClient] startLoginWithUsername:[AppSettings userName] password:[AppSettings userPass] callback:^(NSError *error){
        if (error == nil) {
            [AppSettings setUserName:[SnapchatClient sharedClient].username];
            [AppSettings setUserToken:[SnapchatClient sharedClient].authToken];
            [[SnapManager sharedScoreManager] addUser:[SnapchatClient sharedClient].username];

            NSArray* arraySnaps = [SnapchatClient sharedClient].snaps;
            for (NSInteger i = 0; i < [arraySnaps count]; i ++) {
                Snap* snap = [arraySnaps objectAtIndex: i];
                [[SnapManager sharedScoreManager] addSnap:[AppSettings userName] sn:snap.sender m:snap.mediatype st:snap.mediastatus ts:[snap.timestamp timeIntervalSince1970]  mid:snap.mediaID];
            }
            
            [weakSelf fillSnapsInArray:self];
            [weakSelf reloadSnapMedia];
            [weakSelf.tableView reloadData];
            [weakSelf performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:NO];
        } else {
            [weakSelf performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:NO];

            if (error.code == -100) {
                [AppSettings setUserName: @""];
                [AppSettings setUserToken: @""];
                [self.navigationController popToRootViewControllerAnimated: YES];
            }
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info.png"] style:UIBarButtonItemStylePlain target:self action:@selector(infoAction)];
    self.title = [AppSettings userName];
    self.isOnlyAvailable = NO;
    self.snaps = [NSMutableArray arrayWithCapacity: 100];
    self.showSnaps = [NSMutableArray arrayWithCapacity: 100];
    [self fillSnapsInArray: self];

    [self.tableView reloadData];
    self.tableView.backgroundColor = [UIColor clearColor];

    if (self.refreshHeaderView == nil) {
        
        self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:self.tableView.frame];
        self.refreshHeaderView.delegate = self;
        [self.view insertSubview:self.refreshHeaderView belowSubview:self.tableView];
    }
    
    [self reloadSnaps];
    
    //  update the last update date
    [self.refreshHeaderView refreshLastUpdatedDate];
    
    [self.allTab setSelected: YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActiveNotify)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) someMethod
{
    [self.tableView setContentOffset:CGPointMake(0, -66) animated:NO];
    [self.refreshHeaderView forceRefreshScrollView: self.tableView];
}

- (void) didBecomeActiveNotify
{
    if ([LTHPasscodeViewController passcodeExistsInKeychain] && [LTHPasscodeViewController didPasscodeTimerEnd]) {
        [[LTHPasscodeViewController sharedUser] showLockscreen];
    }
    
    [self someMethod];
}

- (void) infoAction
{
    UIViewController *vc = (UIViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    [self.navigationController pushViewController:vc animated: YES];
}

- (void) buyCoins
{
    UIViewController *vc = (UIViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"BuyCoinTableViewController"];
    [self.navigationController pushViewController:vc animated: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showSnaps.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"SnapCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSLog(@"Call cellForRowAtIndexPath");
    
    UIImageView* thumbImageV = (UIImageView*)[cell viewWithTag: 100];
    UILabel* titleLabel = (UILabel*)[cell viewWithTag: 1];
    UILabel* statusLabel = (UILabel*)[cell viewWithTag: 2];
    UIImageView* availableImageV = (UIImageView*)[cell viewWithTag: 3];
    UIImageView* iconVideo = (UIImageView*)[cell viewWithTag: 103];
    UIActivityIndicatorView* loadingView = (UIActivityIndicatorView*)[cell viewWithTag: 101];
    
    Snap *snap = self.showSnaps[indexPath.row];

    titleLabel.text = snap.sender;

    [availableImageV setHidden: YES];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;

    [iconVideo setHidden: YES];
    availableImageV.hidden = YES;

    if (snap.mediastatus == DELIVERED) {
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentDir = [paths objectAtIndex: 0];
        NSString* exportURLString = [documentDir stringByAppendingPathComponent:(snap.mediatype==VIDEO)?[NSString stringWithFormat:@"%@.mp4", snap.mediaID]:snap.mediaID];
        BOOL bFileExist = [[NSFileManager defaultManager] fileExistsAtPath:exportURLString];
        if (bFileExist) {
            [loadingView setHidden: YES];
            [thumbImageV setImage: snap.thumbImage];

            availableImageV.hidden = NO;

            if (snap.buyied) {
                [availableImageV setImage: [UIImage imageNamed:@"openForFree.png"]];
            } else {
                [availableImageV setImage: [UIImage imageNamed:@"openForCoin.png"]];
            }

            if (snap.mediatype == IMAGE) {
                [iconVideo setHidden: YES];
                statusLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:snap.timestamp], @"Cached photo"];;
            } else if (snap.mediatype == VIDEO) {
                statusLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:snap.timestamp], @"Cached video"];;
                [iconVideo setHidden: NO];
            }
        } else {
            [thumbImageV setImage: [UIImage imageNamed: @"snapNotAvail.jpg"]];
        }
    } else {
        statusLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:snap.timestamp], @"Unavailable"];
        [loadingView setHidden: YES];
        [iconVideo setHidden: YES];
        [thumbImageV setImage: [UIImage imageNamed: @"snapNotAvail.jpg"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Snap *snap = self.showSnaps[indexPath.row];
    if (!snap.buyied) {
        if (!snap.existmedia) {
            return;
        } else {
            if (([AppSettings coinCount] - 2) < 0)
            {
                UIViewController *vc = (UIViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"UpgradeViewController"];
                [self.navigationController presentViewController:vc animated:YES completion:nil];
                return;
            } else {
                [AppSettings subCoinCount: 2];
                [[SnapManager sharedScoreManager] buySnap: snap.mediaID];
            }
            
            snap.buyied = YES;
        }
    }
    
    [self.tableView reloadData];
    MediaViewController *vc = (MediaViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MediaViewController"];
    [vc setSnap: snap];
    [self.navigationController pushViewController:vc animated: YES];
}

- (void)completeLoadMedia
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    _reloading = YES;
    
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.refreshHeaderView egoRefreshScrollViewWillBeginScroll:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self reloadSnaps];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

- (IBAction) refreshSnaps:(id)sender
{
    [self someMethod];
}

- (IBAction) clearAllSnaps:(id)sender
{
    UIActionSheet* ac = [[UIActionSheet alloc] initWithTitle:@"Clear all media?" delegate:self cancelButtonTitle:@"NO" destructiveButtonTitle:@"YES" otherButtonTitles: nil];
    [ac showInView: self.view];
}

- (IBAction) allSnapsAction:(id)sender
{
    self.isOnlyAvailable = NO;
    [self.availableTab setSelected: NO];
    [self.allTab setSelected: YES];
    
    [self fillSnapsInArray:self];
//    [self reloadSnapMedia];
    [self.tableView reloadData];
}

- (IBAction) availableAction:(id)sender
{
    self.isOnlyAvailable = YES;
    [self.availableTab setSelected: YES];
    [self.allTab setSelected: NO];

    [self fillSnapsInArray:self];
//    [self reloadSnapMedia];
    [self.tableView reloadData];
}

#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    [[SnapManager sharedScoreManager] deleteAllSnap:[AppSettings userName]];
    [self.snaps removeAllObjects];
    [self fillSnapsInArray: self];
    [self.tableView reloadData];
}
@end
