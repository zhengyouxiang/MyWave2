//
//  MainPageViewController.m
//  MyWave
//
//  Created by youngsing on 13-1-25.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "MainPageViewController.h"
#import "PPRevealSideViewController.h"
#import "Status.h"
#import "User.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UpdateStatusesController.h"
#import "CustomNavViewController.h"
#import "MainPageBasicCell.h"
#import "MainPageRetweetedCell.h"
#import "ImageView.h"
#import "DetailStatusViewController.h"

@interface MainPageViewController ()

@end

static BOOL isHaveCommentView = NO;

@implementation MainPageViewController

- (void)createHeaderView
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
    headerView.tag = 100;
    headerView.backgroundColor = UIColorWithWhite075100;
    [self.view addSubview:headerView];
    
    UIButton *groupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    groupButton.frame = CGRectMake(5, 0, 40, 40);
    [groupButton setBackgroundImage:[UIImage imageNamed:@"button_icon_group.png"]
                           forState:UIControlStateNormal];
    [groupButton addTarget:self
                    action:@selector(groupButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:groupButton];
    
    UIButton *toolButton = [UIButton buttonWithType:UIButtonTypeCustom];
    toolButton.frame = CGRectMake(275, 5, 30, 30);
    toolButton.tag = 1000;
    [toolButton setBackgroundImage:[UIImage imageNamed:@"button_icon_plus.png"]
                          forState:UIControlStateNormal];
    [toolButton addTarget:self
                   action:@selector(toolButtonAction:)
         forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:toolButton];
}

- (void)loadView
{
    self.navigationController.navigationBarHidden = YES;
    
    [super loadView];
    
    [self createHeaderView];
    
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, [UIScreen mainScreen].bounds.size.height - 20 - 40 - 45)] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //判断网络状况 根据网络是否存在决定是否加载缓存
    //TODO:coming soon
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    nowNewWorkStatus = [r currentReachabilityStatus];
    if (!nowNewWorkStatus)
    {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"LoadCacheSuccess"
                                                          object:[WeiboDataManager share] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                                                              [self refreshData:YES];
                                                              [[NSNotificationCenter defaultCenter] removeObserver:self];
                                                          }];
        [[WeiboDataManager share] loadCacheWeiboDataFromFile];
    }
    
    // 下拉刷新view
    if (_refreshTableHeaderView == nil)
    {
        EGORefreshTableHeaderView *headerView = [[[EGORefreshTableHeaderView alloc] initWithFrame:
                                                  CGRectMake(0,
                                                             0 - self.tableView.bounds.size.height,
                                                             self.view.frame.size.width,
                                                             self.tableView.bounds.size.height)
                                                                                   arrowImageName:@"blackArrow.png"
                                                                                        textColor:[UIColor blackColor]]
                                                 autorelease];
        headerView.delegate = self;
        [self.tableView addSubview:headerView];
        _refreshTableHeaderView = headerView;
    }
    
    //根据网络状况，决定是否显示tableFooterView的提示文字
    if (nowNewWorkStatus)
    {
        self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
        UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loadMoreButton.tag = 2000;
        [loadMoreButton setTitle:@"加载中，请稍候。。。" forState:UIControlStateNormal];
        [loadMoreButton setTitleColor:[UIColor colorWithRed:127.0/255 green:127.0/255 blue:127.0/255 alpha:1.0]
                             forState:UIControlStateNormal];
        loadMoreButton.frame = CGRectMake(0, 0, 320, 44);
        loadMoreButton.titleLabel.textAlignment = UITextAlignmentCenter;
        [loadMoreButton addTarget:self
                           action:@selector(loadMoreButtonAction:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self.tableView.tableFooterView addSubview:loadMoreButton];
        self.tableView.tableFooterView.hidden = YES;
    }
    
    //微博数据加载提示动画Label
    loadingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 180, 320, 30)] autorelease];
    loadingLabel.text = @"......";
    loadingLabel.textColor = [UIColor colorWithRed:127.0/255 green:127.0/255 blue:127.0/255 alpha:1.0];
    loadingLabel.font = [UIFont systemFontOfSize:40];
    if (nowNewWorkStatus) {
        [self.view addSubview:loadingLabel];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [statusesArray release];
    [loadingLabel release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (statusesArray.count == 0)
        return 1;
    
    return [statusesArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (statusesArray.count == 0 && indexPath.row == 0)
        return 400;
    
    return [[statusesArray objectAtIndex:indexPath.row] totalHeight];
}

#if 0
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (statusesArray.count == 0 && indexPath.row == 0)
    {
        static NSString *MainPageLoadingCell = @"MainPageLoadingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainPageLoadingCell];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:MainPageLoadingCell] autorelease];
        }
        cell.textLabel.text = @"加载中，请稍后...";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        
        [[WeiboManager share] getDataFromWeibo:@"statuses/home_timeline.json" WithHttpMethod:@"GET"];
        
        return cell;
    }
    
    static NSString *MainPageCell = @"MainPageCell";
    
    static BOOL isNibsRegistered = NO;
    if (!isNibsRegistered)
    {
        UINib *nib = [UINib nibWithNibName:@"mainPageStatusCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:MainPageCell];
        isNibsRegistered = YES;
    }
    
    mainPageStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:MainPageCell];
    
    Status *statusCell = [statusesArray objectAtIndex:indexPath.row];
    
    cell.avatarImage.image = [UIImage imageNamed:@"login_avarta_weibo.jpg"];
    cell.nameLabel.text = statusCell.user.screenName;
    
    cell.contentText.text = statusCell.text;
    
    CGSize size = [cell.contentText.text sizeWithFont:[UIFont systemFontOfSize:14]
                                    constrainedToSize:CGSizeMake(250, 20000)
                                        lineBreakMode:UILineBreakModeWordWrap];
    CGRect frameOfContentText = cell.contentText.frame;
    frameOfContentText.size.height = frameOfContentText.size.height + size.height + 10;
    [cell.contentText setFrame:frameOfContentText];
    
    cell.retweetedMainView.hidden = YES;
    
    
    cell.postTimeLabel.text = statusCell.createdAt;
    CGRect frameOfPostTime = cell.postTimeLabel.frame;
    frameOfPostTime.origin.y = frameOfContentText.origin.y + frameOfContentText.size.height + 5;
    [cell.postTimeLabel setFrame:frameOfPostTime];
    
    cell.sourceLabel.text = statusCell.sourceStr;
    CGRect frameOfSource = cell.sourceLabel.frame;
    frameOfSource.origin.y = frameOfPostTime.origin.y;
    [cell.sourceLabel setFrame:frameOfSource];
    
    CGRect frameOfSourceTips = cell.sourceTipsLabel.frame;
    frameOfSourceTips.origin.y = frameOfSource.origin.y;
    [cell.sourceTipsLabel setFrame:frameOfSourceTips];
    
    CGRect frameOfCell = cell.frame;
    frameOfCell.size.height = frameOfSource.origin.y + frameOfSource.size.height +5;
    [cell setFrame:frameOfCell];
    
    
    return cell;
}
#elif 1
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (statusesArray.count == 0 && indexPath.row == 0)
    {
        
        [UIView animateWithDuration:2.0f animations:^{
            [loadingLabel sizeToFit];
            CGRect frame = loadingLabel.frame;
            frame.origin.x = 320;
            loadingLabel.frame = frame;
            
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            [UIView setAnimationRepeatAutoreverses:NO];
            [UIView setAnimationRepeatCount:9999];
            
            frame = loadingLabel.frame;
            frame.origin.x = -frame.size.width;
            loadingLabel.frame = frame;
        }];
        
        static NSString *MainPageLoadingCell = @"MainPageLoadingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainPageLoadingCell];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:MainPageLoadingCell] autorelease];
        }
        
        static BOOL firstLoading = YES;
        if (firstLoading)
        {
            WeiboConnectManager *weiboM = [WeiboConnectManager new];
            [weiboM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
                [self refreshData:YES];
                [weiboM release];
                [loadingLabel removeFromSuperview];
            }];
            
            [weiboM getDataFromWeiboWithURL:@"statuses/home_timeline.json"
                                     params:nil
                                 httpMethod:@"GET"];
            firstLoading = NO;;
        }
        
        return cell;
    }
    
    Status *statusCell = [statusesArray objectAtIndex:indexPath.row];
    
    switch (statusCell.type)
    {
        case MainPageBasicCellType:
        {
            static NSString *cellIdtifier1 = @"MainPageBasicCellType";
            MainPageBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdtifier1];
            if (cell == nil)
                cell = [[[MainPageBasicCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:cellIdtifier1] autorelease];
            cell.MyCelldelegate = self;
            
            [cell.avatarImageView setImageWithURL:[NSURL URLWithString:statusCell.user.profileLargeImageUrl]
                                 placeholderImage:[UIImage imageNamed:@"login_avarta_weibo.jpg"]
                                          success:^(UIImage *image, BOOL cached) {
                                              statusCell.user.avatarImage = image;
                                          } failure:^(NSError *error) {
                                              NSLog(@"图片下载有误");
                                          }];
            
            if (statusCell.user.verifiedType < 0)
                cell.verifiedImageView.hidden = YES;
            else if (statusCell.user.verifiedType == 0)
            {
                cell.verifiedImageView.hidden = NO;
                cell.verifiedImageView.image = [UIImage imageNamed:@"avatar_vip.png"];
            }
            else if (statusCell.user.verifiedType > 0)
            {
                cell.verifiedImageView.hidden = NO;
                cell.verifiedImageView.image = [UIImage imageNamed:@"avatar_enterprise_vip.png"];
            }
            
            //用户名
            cell.userNameLabel.text = statusCell.user.screenName;
            
            //转发数 评论数
            cell.retweetedCountLabel.text = [NSString stringWithFormat:@"%d", statusCell.repostsCount];
            cell.commentCountLabel.text = [NSString stringWithFormat:@"%d", statusCell.commentsCount];
            
            [cell.textLabel setAttString:statusCell.attString withImages:statusCell.images];
            cell.textLabel.delegate = self;
            CGRect textFrame = cell.textLabel.frame;
            textFrame.size.height = statusCell.textHeight;
            [cell.textLabel setFrame:textFrame];
            
            [statusCell.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
                [cell.textLabel addCustomLink:[NSURL URLWithString:user]
                                      inRange:[statusCell.attString.string rangeOfString:user]];
            }];
            
            [statusCell.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
                [cell.textLabel addCustomLink:[NSURL URLWithString:topic]
                                      inRange:[statusCell.attString.string rangeOfString:topic]];
            }];
            
            statusCell.createdAtCal = [self timestamp:statusCell.createdAt];
            cell.postTimeLabel.text = statusCell.createdAtCal;
            CGRect postTimeFrame = cell.postTimeLabel.frame;
            postTimeFrame.origin.y = 35 + statusCell.textHeight;
            [cell.postTimeLabel setFrame:postTimeFrame];
            
            CGRect sourceTipsFrame = cell.sourceTipsLabel.frame;
            sourceTipsFrame.origin.y = 35 + statusCell.textHeight;
            [cell.sourceTipsLabel setFrame:sourceTipsFrame];
            
            cell.sourceLabel.text = statusCell.sourceStr;
            CGRect sourceFrame = cell.sourceLabel.frame;
            sourceFrame.origin.y = 35 + statusCell.textHeight;
            [cell.sourceLabel setFrame:sourceFrame];
            
            return cell;
        }
        case MainPageBasicImageCellType:
        {
            static NSString *cellIdtifier2 = @"MainPageBasicImageCellType";
            MainPageBasicImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdtifier2];
            if (cell == nil)
                cell = [[[MainPageBasicImageCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:cellIdtifier2] autorelease];
            
            cell.MyCelldelegate = self;
            
            [cell.avatarImageView setImageWithURL:[NSURL URLWithString:statusCell.user.profileLargeImageUrl]
                                 placeholderImage:[UIImage imageNamed:@"login_avarta_weibo.jpg"]
                                          success:^(UIImage *image, BOOL cached) {
                                              statusCell.user.avatarImage = image;
                                          } failure:^(NSError *error) {
                                              NSLog(@"图片下载有误");
                                          }];
            
            if (statusCell.user.verifiedType < 0)
                cell.verifiedImageView.hidden = YES;
            else if (statusCell.user.verifiedType == 0)
            {
                cell.verifiedImageView.hidden = NO;
                cell.verifiedImageView.image = [UIImage imageNamed:@"avatar_vip.png"];
            }
            else if (statusCell.user.verifiedType > 0)
            {
                cell.verifiedImageView.hidden = NO;
                cell.verifiedImageView.image = [UIImage imageNamed:@"avatar_enterprise_vip.png"];
            }
            
            cell.userNameLabel.text = statusCell.user.screenName;
            
            //转发数 评论数
            cell.retweetedCountLabel.text = [NSString stringWithFormat:@"%d", statusCell.repostsCount];
            cell.commentCountLabel.text = [NSString stringWithFormat:@"%d", statusCell.commentsCount];
            
            [cell.textLabel setAttString:statusCell.attString withImages:statusCell.images];
            cell.textLabel.delegate = self;
            CGRect textFrame = cell.textLabel.frame;
            textFrame.size.height = statusCell.textHeight;
            [cell.textLabel setFrame:textFrame];
            
            [statusCell.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
                [cell.textLabel addCustomLink:[NSURL URLWithString:user]
                                      inRange:[statusCell.attString.string rangeOfString:user]];
            }];
            
            [statusCell.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
                [cell.textLabel addCustomLink:[NSURL URLWithString:topic]
                                      inRange:[statusCell.attString.string rangeOfString:topic]];
            }];
            
            [cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:statusCell.thumbnailPic]
                                    placeholderImage:[UIImage imageNamed:@"group_btn_pic_on_title.png"]
                                             success:^(UIImage *image, BOOL cached) {
                                                 statusCell.postImageView.image = image;
                                             }
                                             failure:^(NSError *error) {
                                                 NSLog(@"图片加载有误");
                                             }];
            CGRect thumbnailImageFrame = cell.thumbnailImageView.frame;
            thumbnailImageFrame.origin.y = 35 + statusCell.textHeight;
            [cell.thumbnailImageView setFrame:thumbnailImageFrame];
            
            statusCell.createdAtCal = [self timestamp:statusCell.createdAt];
            cell.postTimeLabel.text = statusCell.createdAtCal;
            CGRect postTimeFrame = cell.postTimeLabel.frame;
            postTimeFrame.origin.y = 120 + statusCell.textHeight;
            [cell.postTimeLabel setFrame:postTimeFrame];
            
            CGRect sourceTipsFrame = cell.sourceTipsLabel.frame;
            sourceTipsFrame.origin.y = 120 + statusCell.textHeight;
            [cell.sourceTipsLabel setFrame:sourceTipsFrame];
            
            cell.sourceLabel.text = statusCell.sourceStr;
            CGRect sourceFrame = cell.sourceLabel.frame;
            sourceFrame.origin.y = 120 + statusCell.textHeight;
            [cell.sourceLabel setFrame:sourceFrame];
            
            //            CGRect cellFrame = cell.frame;
            //            cellFrame.size.height = sourceFrame.origin.y;
            //            [cell setFrame:cellFrame];
            
            return cell;
        }
        case MainPageRetweetedCellType:
        {
            static NSString *cellIdtifier3 = @"MainPageRetweetedCellType";
            
            MainPageRetweetedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdtifier3];
            if (cell == nil)
                cell = [[[MainPageRetweetedCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:cellIdtifier3] autorelease];
            cell.MyCelldelegate = self;
            
            [cell.avatarImageView setImageWithURL:[NSURL URLWithString:statusCell.user.profileLargeImageUrl]
                                 placeholderImage:[UIImage imageNamed:@"login_avarta_weibo.jpg"]
                                          success:^(UIImage *image, BOOL cached) {
                                              statusCell.user.avatarImage = image;
                                          } failure:^(NSError *error) {
                                              NSLog(@"图片下载有误");
                                          }];
            
            if (statusCell.user.verifiedType < 0)
                cell.verifiedImageView.hidden = YES;
            else if (statusCell.user.verifiedType == 0)
            {
                cell.verifiedImageView.hidden = NO;
                cell.verifiedImageView.image = [UIImage imageNamed:@"avatar_vip.png"];
            }
            else if (statusCell.user.verifiedType > 0)
            {
                cell.verifiedImageView.hidden = NO;
                cell.verifiedImageView.image = [UIImage imageNamed:@"avatar_enterprise_vip.png"];
            }
            
            cell.userNameLabel.text = statusCell.user.screenName;
            
            //转发数 评论数
            cell.retweetedCountLabel.text = [NSString stringWithFormat:@"%d", statusCell.repostsCount];
            cell.commentCountLabel.text = [NSString stringWithFormat:@"%d", statusCell.commentsCount];
            
            [cell.textLabel setAttString:statusCell.attString withImages:statusCell.images];
            cell.textLabel.delegate = self;
            
            CGRect textFrame = cell.textLabel.frame;
            textFrame.size.height = statusCell.textHeight;
            [cell.textLabel setFrame:textFrame];
            
            [statusCell.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
                [cell.textLabel addCustomLink:[NSURL URLWithString:user]
                                      inRange:[statusCell.attString.string rangeOfString:user]];
            }];
            
            [statusCell.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
                [cell.textLabel addCustomLink:[NSURL URLWithString:topic]
                                      inRange:[statusCell.attString.string rangeOfString:topic]];
            }];
            
            cell.retweetedUserNameLabel.text = statusCell.retweetedStatus.user.atScreenName;
            
            [cell.retweetedTextLabel setAttString:statusCell.retweetedStatus.attString
                                       withImages:statusCell.retweetedStatus.images];
            cell.retweetedTextLabel.delegate = self;
            CGRect retweetedTextFrame = cell.retweetedTextLabel.frame;
            retweetedTextFrame.size.height = statusCell.retweetedTextHeight;
            [cell.retweetedTextLabel setFrame:retweetedTextFrame];
            
            [statusCell.retweetedStatus.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
                [cell.retweetedTextLabel addCustomLink:[NSURL URLWithString:user]
                                               inRange:[statusCell.retweetedStatus.attString.string
                                                        rangeOfString:user]];
            }];
            
            [statusCell.retweetedStatus.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
                [cell.retweetedTextLabel addCustomLink:[NSURL URLWithString:topic]
                                               inRange:[statusCell.retweetedStatus.attString.string
                                                        rangeOfString:topic]];
            }];
            
            CGRect retweetedMainFrame = cell.retweetedMainView.frame;
            retweetedMainFrame.origin.y = 35 + statusCell.textHeight;
            retweetedMainFrame.size.height = 35 + statusCell.retweetedTextHeight;
            [cell.retweetedMainView setFrame:retweetedMainFrame];
            
            CGRect resizeImageViewFrame = cell.resizeImageView.frame;
            resizeImageViewFrame.size.height = 120 + statusCell.retweetedTextHeight;
            [cell.resizeImageView setFrame:resizeImageViewFrame];
            
            statusCell.createdAtCal = [self timestamp:statusCell.createdAt];
            cell.postTimeLabel.text = statusCell.createdAtCal;
            CGRect postTimeFrame = cell.postTimeLabel.frame;
            postTimeFrame.origin.y = 75 + statusCell.textHeight + statusCell.retweetedTextHeight;
            [cell.postTimeLabel setFrame:postTimeFrame];
            
            CGRect sourceTipsFrame = cell.sourceTipsLabel.frame;
            sourceTipsFrame.origin.y = 75 + statusCell.textHeight + statusCell.retweetedTextHeight;
            [cell.sourceTipsLabel setFrame:sourceTipsFrame];
            
            cell.sourceLabel.text = statusCell.sourceStr;
            CGRect sourceFrame = cell.sourceLabel.frame;
            sourceFrame.origin.y = 75 + statusCell.textHeight + statusCell.retweetedTextHeight;
            [cell.sourceLabel setFrame:sourceFrame];
            
            return cell;
        }
        case MainPageRetweetedImageCellType:
        {
            static NSString *cellIdtifier4 = @"MainPageRetweetedImageCellType";
            MainPageRetweetedImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdtifier4];
            if (cell == nil)
                cell = [[[MainPageRetweetedImageCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                          reuseIdentifier:cellIdtifier4] autorelease];
            
            cell.MyCelldelegate = self;
            
            [cell.avatarImageView setImageWithURL:[NSURL URLWithString:statusCell.user.profileLargeImageUrl]
                                 placeholderImage:[UIImage imageNamed:@"login_avarta_weibo.jpg"]
                                          success:^(UIImage *image, BOOL cached) {
                                              statusCell.user.avatarImage = image;
                                          } failure:^(NSError *error) {
                                              NSLog(@"图片下载有误");
                                          }];
            
            if (statusCell.user.verifiedType < 0)
                cell.verifiedImageView.hidden = YES;
            else if (statusCell.user.verifiedType == 0)
            {
                cell.verifiedImageView.hidden = NO;
                cell.verifiedImageView.image = [UIImage imageNamed:@"avatar_vip.png"];
            }
            else if (statusCell.user.verifiedType > 0)
            {
                cell.verifiedImageView.hidden = NO;
                cell.verifiedImageView.image = [UIImage imageNamed:@"avatar_enterprise_vip.png"];
            }
            
            cell.userNameLabel.text = statusCell.user.screenName;
            
            //转发数 评论数
            cell.retweetedCountLabel.text = [NSString stringWithFormat:@"%d", statusCell.repostsCount];
            cell.commentCountLabel.text = [NSString stringWithFormat:@"%d", statusCell.commentsCount];
            
            [cell.textLabel setAttString:statusCell.attString withImages:statusCell.images];
            cell.textLabel.delegate = self;
            CGRect textFrame = cell.textLabel.frame;
            textFrame.size.height = statusCell.textHeight;
            [cell.textLabel setFrame:textFrame];
            
            [statusCell.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
                [cell.textLabel addCustomLink:[NSURL URLWithString:user]
                                      inRange:[statusCell.attString.string rangeOfString:user]];
            }];
            
            [statusCell.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
                [cell.textLabel addCustomLink:[NSURL URLWithString:topic]
                                      inRange:[statusCell.attString.string rangeOfString:topic]];
            }];
            
            cell.retweetedUserNameLabel.text = statusCell.retweetedStatus.user.atScreenName;
            
            [cell.retweetedTextLabel setAttString:statusCell.retweetedStatus.attString
                                       withImages:statusCell.retweetedStatus.images];
            cell.retweetedTextLabel.delegate = self;
            CGRect retweetedTextFrame = cell.retweetedTextLabel.frame;
            retweetedTextFrame.size.height = statusCell.retweetedTextHeight;
            [cell.retweetedTextLabel setFrame:retweetedTextFrame];
            
            [statusCell.retweetedStatus.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
                [cell.retweetedTextLabel addCustomLink:[NSURL URLWithString:user]
                                               inRange:[statusCell.retweetedStatus.attString.string
                                                        rangeOfString:user]];
            }];
            
            [statusCell.retweetedStatus.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
                [cell.retweetedTextLabel addCustomLink:[NSURL URLWithString:topic]
                                               inRange:[statusCell.retweetedStatus.attString.string
                                                        rangeOfString:topic]];
            }];
            
            [cell.retweetedThumbnailImageView setImageWithURL:[NSURL URLWithString:statusCell.retweetedStatus.thumbnailPic]
                                             placeholderImage:[UIImage imageNamed:@"group_btn_pic_on_title.png"]
                                                      success:^(UIImage *image, BOOL cached) {
                                                          statusCell.retweetImageView.image = image;
                                                      }
                                                      failure:^(NSError *error) {
                                                          NSLog(@"图片加载错误");
                                                      }];
            
            CGRect retweetedThumbnailImageFrame = cell.retweetedThumbnailImageView.frame;
            retweetedThumbnailImageFrame.origin.y = 35 + statusCell.retweetedTextHeight;
            [cell.retweetedThumbnailImageView setFrame:retweetedThumbnailImageFrame];
            
            CGRect retweetedMainFrame = cell.retweetedMainView.frame;
            retweetedMainFrame.origin.y = 35 + statusCell.textHeight;
            retweetedMainFrame.size.height = 120 + statusCell.retweetedTextHeight;
            [cell.retweetedMainView setFrame:retweetedMainFrame];
            
            CGRect resizeImageViewFrame = cell.resizeImageView.frame;
            resizeImageViewFrame.size.height = 125 + statusCell.retweetedTextHeight;
            [cell.resizeImageView setFrame:resizeImageViewFrame];
            
            statusCell.createdAtCal = [self timestamp:statusCell.createdAt];
            cell.postTimeLabel.text = statusCell.createdAtCal;
            CGRect postTimeFrame = cell.postTimeLabel.frame;
            postTimeFrame.origin.y = 160 + statusCell.textHeight + statusCell.retweetedTextHeight;
            [cell.postTimeLabel setFrame:postTimeFrame];
            
            CGRect sourceTipsFrame = cell.sourceTipsLabel.frame;
            sourceTipsFrame.origin.y = 160 + statusCell.textHeight + statusCell.retweetedTextHeight;
            [cell.sourceTipsLabel setFrame:sourceTipsFrame];
            
            cell.sourceLabel.text = statusCell.sourceStr;
            CGRect sourceFrame = cell.sourceLabel.frame;
            sourceFrame.origin.y = 160 + statusCell.textHeight + statusCell.retweetedTextHeight;
            [cell.sourceLabel setFrame:sourceFrame];
            
            return cell;
        }
    }
}
#endif


#pragma mark - Table view delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //如果存在commentView，则在进入detailStatus页面前将其移除
    UIView *tabBarView = [self.tabBarController.view viewWithTag:100000];
    tabBarView.hidden = NO;
    
    UIView *commentView = [self.view viewWithTag:10000];
    if (commentView != nil)
        [commentView removeFromSuperview];
    isHaveCommentView = NO;
    
    //push detailStatus页面
    DetailStatusViewController *detailStatusVC = [[[DetailStatusViewController alloc] init] autorelease];
    detailStatusVC.detailStatus = [statusesArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailStatusVC animated:YES];
}

#pragma mark - Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource
{
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	isLoading = YES;
}

- (void)doneLoadingTableViewData
{
	//  model should call this when its done loading
	isLoading = NO;
	[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //滑动tableview时，移除commentView
    UIView *tabBarView = [self.tabBarController.view viewWithTag:100000];
    tabBarView.hidden = NO;
    
    UIView *commentView = [self.view viewWithTag:10000];
    if (commentView != nil)
        [commentView removeFromSuperview];
    isHaveCommentView = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    if (nowNewWorkStatus)
    {
        if (statusesArray.count >= 140)
        {
            UIButton *loadMoreButton = (UIButton *)[self.tableView.tableFooterView viewWithTag:2000];
            [loadMoreButton setTitle:@"点我加载更多。。。" forState:UIControlStateNormal];
        }
        else
        {
            CGPoint contentOffsetPoint = scrollView.contentOffset;
            if (contentOffsetPoint.y == (self.tableView.contentSize.height - self.tableView.frame.size.height)
                && self.tableView.tableFooterView.hidden == YES)
            {
                self.tableView.tableFooterView.hidden = NO;
                [self loadMoreButtonAction:nil];
            }
        }
    }
    else
    {
        self.tableView.tableFooterView.hidden = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0f];
    
    WeiboConnectManager *weiboM = [WeiboConnectManager new];
    [weiboM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        [self refreshData:YES];
        [weiboM release];
    }];
    
//    Status *lastStatus = [statusesArray objectAtIndex:0];
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:lastStatus.statusStr, @"since_id", nil];
    [weiboM getDataFromWeiboWithURL:@"statuses/home_timeline.json" params:nil httpMethod:@"GET"];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return isLoading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - OHAttributedLabel Method
//设置链接颜色
-(UIColor *)colorForLink:(NSTextCheckingResult *)linkInfo underlineStyle:(int32_t *)underlineStyle
{
    return [UIColor colorWithRed:(120./255) green:(200./255) blue:(225./255) alpha:1.0];
}

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    //点击的链接的位置
    NSRange range = linkInfo.range;
    //获取整个字符串的信息
    NSString * text = attributedLabel.attributedText.string;
    //用位置信息，找到点击的 文字信息
    NSString * regexString = [text substringWithRange:range];
    
    //根据不同的前缀进行不同的操作
    if ([regexString hasPrefix:@"@"])
    {
        //剔除前面的@
        NSString * user = [regexString substringFromIndex:1];
        NSLog(@"推出用户界面  %@",user);
        //TODO: coming soon
    }
    if ([regexString hasPrefix:@"#"])
    {
        //剔除前后的#号
        NSString * topic = [regexString substringToIndex:[regexString length]-1];
        topic = [topic substringFromIndex:1];
        NSLog(@"推出话题界面  %@",topic);
    }
    if ([regexString hasPrefix:@"http"])
    {
        NSLog(@"推出内置浏览器界面  %@",regexString);
    }
    
    //如果返回yes 打开系统的浏览器
    return YES;
}

#pragma mark - Custom Methods
- (NSString *)timestamp : (NSString *)createdAtFromDic
{
    //输入的时间字符串格式为 @"Tue Jan 15 23:45:15 +0800 2013"
    /* 转换控制符    说明
     *    %a    星期几的简写形式
     *    %A 	星期几的全称
     *    %b 	月份的简写形式
     *    %B 	月份的全称
     *    %c 	日期和时间
     *    %d 	月份中的日期,0-31
     *    %H 	小时,00-23
     *    %I 	12进制小时钟点,01-12
     *    %j 	年份中的日期,001-366
     *    %m 	年份中的月份,01-12
     *    %M 	分,00-59
     *    %p 	上午或下午
     *    %S 	秒,00-60
     *    %u 	星期几,1-7
     *    %w 	星期几,0-6
     *    %x 	当地格式的日期
     *    %X 	当地格式的时间
     *    %y 	年份中的最后两位数,00-99
     *    %Y 	年
     *    %Z 	地理时区名称
     */
    NSString *_timestamp;
    
    struct tm createdAtTimeStruct;
    time_t createdAtTM;
    time_t now;
    time(&now);
    
    strptime([createdAtFromDic UTF8String], "%a %b %d %H:%M:%S %z %Y", &createdAtTimeStruct);
    createdAtTM = mktime(&createdAtTimeStruct);
    int distance = (int)difftime(now, createdAtTM);
    
    if (distance < 0)
        distance = 0;
    
    if (distance < 60)
        _timestamp = [NSString stringWithFormat:@"%d秒前", distance];
    else if (distance < 3600)
        _timestamp = [NSString stringWithFormat:@"%d分钟前", distance/60];
    else
        _timestamp = [NSString stringWithFormat:@"%d月%d日%d:%d",
                      createdAtTimeStruct.tm_mon + 1,   createdAtTimeStruct.tm_mday,
                      createdAtTimeStruct.tm_hour,      createdAtTimeStruct.tm_min];
    
    return _timestamp;
}

- (void)refreshData: (BOOL)isNew
{
    if (statusesArray.count == 0)
    {
        statusesArray = [[NSMutableArray alloc] initWithArray:[[WeiboDataManager share] weiboDataArray]];
    }
    else
    {
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:[[WeiboDataManager share] weiboDataArray]];
        if (isNew)
        {
            if (tmpArray.count != 0)
            {
//                [statusesArray insertObjects:tmpArray
//                                   atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tmpArray.count)]];
                [statusesArray removeAllObjects];
                [statusesArray addObjectsFromArray:tmpArray];
            }
        }
        else
        {
            NSString *originStatusId = [[statusesArray lastObject] statusStr];
            NSString *newStatusId = [[tmpArray objectAtIndex:0] statusStr];
            if ([originStatusId isEqualToString:newStatusId])
            {
                [tmpArray removeObjectAtIndex:0];
            }
            [statusesArray addObjectsFromArray:tmpArray];
            self.tableView.tableFooterView.hidden = YES;
        }
    }
    
    //    if (statusesArray.count > 200)
    //    {
    //        [statusesArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:
    //                                               NSMakeRange(20, statusesArray.count - 20)]];
    //    }
    [self.tableView reloadData];
}

- (void)groupButtonAction: (id)sender
{
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft withOffset:70.0f animated:YES];
}

- (void)toolButtonAction: (id)sender
{
    static BOOL updateButtonTappedAgain = NO;
    
    UIButton *toolButton = (UIButton *)[self.navigationController.view viewWithTag:1000];
    
    if (!updateButtonTappedAgain)
    {
        [UIView animateWithDuration:0.25f animations:^{
            toolButton.transform = CGAffineTransformRotate(toolButton.transform,45 * M_PI / 180);
        } completion:^(BOOL finished) {
            updateButtonTappedAgain = YES;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25f animations:^{
            toolButton.transform = CGAffineTransformRotate(toolButton.transform, -45 * M_PI / 180);
        } completion:^(BOOL finished) {
            updateButtonTappedAgain = NO;
        }];
    }
    
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionRight withOffset:276.0f animated:YES];
}

- (void)imageTappedActionWithStatusCell: (id)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Status *originStatus = [statusesArray objectAtIndex:indexPath.row];
    
    NSString *originImageStr;
    if (originStatus.type == 1)
        originImageStr = originStatus.originalPic;
    else
        originImageStr = originStatus.retweetedStatus.originalPic;
    
    ImageView *imageView = [[[ImageView alloc] init] autorelease];
    
    UIWindow *appWindow = [[UIApplication sharedApplication] keyWindow];
    if (!appWindow )
        appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [appWindow addSubview:imageView];
    
    [imageView.originImageView setImageWithURL:[NSURL URLWithString:originImageStr]
                                       success:^(UIImage *image, BOOL cached) {
                                           [imageView loadImage];
                                       }
                                       failure:^(NSError *error) {
                                           NSLog(@"图片下载错误");
                                       }];
}

- (void)rightSwipToolViewWithCell:(id)cell Position:(CGPoint)position
{
    if (!isHaveCommentView)
    {
        isHaveCommentView = YES;
        
        CGRect cellRect = [self.tableView rectForRowAtIndexPath:[self.tableView indexPathForCell:cell]];
        CGRect rect = [self.view convertRect:cellRect fromView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Status *statusCell = [statusesArray objectAtIndex:indexPath.row];
        CommentView *commentView = [[[CommentView alloc] init] autorelease];
        commentView.tag = 10000;
        commentView.detailStatus = statusCell;
        CGFloat originY = rect.origin.y + position.y;
        commentView.frame = CGRectMake(0, originY, 320, 44);
        [commentView upDateFavArray];
        [self.view addSubview:commentView];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"CommentViewRemoved"
                                                          object:commentView
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          isHaveCommentView = NO;
                                                          UIView *tabBarView = [self.tabBarController.view
                                                                                viewWithTag:100000];
                                                          tabBarView.hidden = NO;
                                                      }];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect commentViewFrame = commentView.frame;
            commentViewFrame.origin.x = -320;
            commentView.frame = commentViewFrame;
            
            commentViewFrame.origin.x = 0;
            commentView.frame = commentViewFrame;
        }];
        
        [commentView setInputViewDidChangedFrameBlock:^(CGFloat changedHeight) {
            UIView *tabBarView = [self.tabBarController.view viewWithTag:100000];
            tabBarView.hidden = YES;
            
            [UIView animateWithDuration:0.3f animations:^{
                CGPoint contentOffPoint = self.tableView.contentOffset;
                contentOffPoint.y = contentOffPoint.y + changedHeight;
                contentOffPoint.y = contentOffPoint.y < 0 ? 0 : contentOffPoint.y;
                self.tableView.contentOffset = contentOffPoint;
            }];
        }];
    }
}

- (void)loadMoreButtonAction: (id)sender
{
    WeiboConnectManager *weiboM = [WeiboConnectManager new];
    
    [weiboM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        [self refreshData: NO];
        [weiboM release];
    }];
    
    Status *firstStatus = [statusesArray lastObject];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:firstStatus.statusStr, @"max_id", @"21", @"count", nil];
    [weiboM getDataFromWeiboWithURL:@"statuses/home_timeline.json"
                             params:dict
                         httpMethod:@"GET"];
}

@end
