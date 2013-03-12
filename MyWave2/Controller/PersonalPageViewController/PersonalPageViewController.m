//
//  PersonalPageViewController.m
//  MyWave2
//
//  Created by youngsing on 13-3-7.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "PersonalPageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SinaWeibo.h"
#import "Status.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MainPageBasicCell.h"
#import "MainPageRetweetedCell.h"
#import "ImageView.h"
#import "DetailStatusViewController.h"

@interface PersonalPageViewController ()

@end

@implementation PersonalPageViewController

- (void)loadView
{
    self.navigationController.navigationBar.hidden = YES;
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    nowNewWorkStatus = [r currentReachabilityStatus];
    
    WeiboConnectManager* weiboCM = [WeiboConnectManager new];
    [weiboCM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        [weiboCM release];
        
        self.primaryUser = [[[User alloc] initWithDictionary:obj] autorelease];
        
        [self createHeaderView];
    }];
    [weiboCM getDataFromWeiboWithURL:@"users/show.json"
                              params:@{@"uid": weiboCM.sinaweibo.userID}
                          httpMethod:@"GET"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    WeiboConnectManager* weiboCM = [WeiboConnectManager new];
    [weiboCM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        statusesArray = [[NSMutableArray alloc] initWithArray:[[WeiboDataManager share] weiboDataArray]];
        viewInCellArray = [[NSMutableArray alloc] init];
        for (Status* status in statusesArray)
        {
            [viewInCellArray addObject:[self createViewIncellWith:status indexPath:nil]];
        }
        
        self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 125, 320, [UIScreen mainScreen].bounds.size.height - 20 - 125 - 45) style:UITableViewStylePlain] autorelease];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];
        
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
    }];
    [weiboCM getDataFromWeiboWithURL:@"statuses/user_timeline.json"
                              params:@{@"uid": weiboCM.sinaweibo.userID}
                          httpMethod:@"GET"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    UIView* view = [viewInCellArray objectAtIndex:indexPath.row];
    return view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* PersonalPageCellIdentifier = @"PersonalPageCellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:PersonalPageCellIdentifier];
    if (nil == cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:PersonalPageCellIdentifier] autorelease];
    }
    
    for (UIView* view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    [cell.contentView addSubview:[viewInCellArray objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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

#pragma mark - UIScrollViewDelegate Methods
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
    
    WeiboConnectManager *weiboCM = [WeiboConnectManager new];
    [weiboCM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        [self refreshData:YES];
        [weiboCM release];
    }];
    
    [weiboCM getDataFromWeiboWithURL:@"statuses/user_timeline.json"
                              params:@{@"uid": weiboCM.sinaweibo.userID}
                          httpMethod:@"GET"];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return isLoading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}



#pragma mark - Custom Methods
- (void)createHeaderView
{
    avatorImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)] autorelease];
    [self.view addSubview:avatorImageView];
    [avatorImageView setImageWithURL:[NSURL URLWithString:self.primaryUser.profileLargeImageUrl]
                    placeholderImage:[UIImage imageNamed:@"login_avarta_weibo.jpg"]
                             success:^(UIImage *image, BOOL cached) {
                                 for (Status* statuse in statusesArray) {
                                     statuse.user.avatarImage = image;
                                 }
                             }
                             failure:^(NSError *error) {
                                 NSLog(@"%@", [error description]);
                             }];
    UILabel* userInfoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60, 5, 100, 40)] autorelease];
    userInfoLabel.numberOfLines = 0;
    userInfoLabel.text = [NSString stringWithFormat:@"%@\n%@", self.primaryUser.screenName, self.primaryUser.location];
    userInfoLabel.backgroundColor = [UIColor clearColor];
    userInfoLabel.font = FontOFHelvetica14;
    [self.view addSubview:userInfoLabel];
    
//    UIImageView* seperatorImageView1 = [[[UIImageView alloc] initWithFrame:CGRectMake(-10, 49, 340, 1)] autorelease];
//    seperatorImageView1.image = [UIImage imageNamed:@"statusdetail_header_separator.png"];
//    [self.view addSubview:seperatorImageView1];
    
    UIButton* friendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    friendBtn.layer.cornerRadius = 8.0f;
    friendBtn.frame = CGRectMake(5, 50, 70, 70);
    [friendBtn setBackgroundImage:[UIImage imageNamed:@"button_title.png"] forState:UIControlStateNormal];
    [friendBtn addTarget:self
                  action:@selector(friendBtnAction:)
        forControlEvents:UIControlEventTouchUpInside];
    UILabel* friendLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70)] autorelease];
    friendLabel.numberOfLines = 0;
    friendLabel.text = [NSString stringWithFormat:@"%d\n关注", self.primaryUser.friendsCount];
    friendLabel.backgroundColor = [UIColor clearColor];
    friendLabel.textAlignment = UITextAlignmentCenter;
    friendLabel.font = FontOFHelvetica12;
    [friendBtn addSubview:friendLabel];
    [self.view addSubview:friendBtn];
    
    UIButton* followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    followBtn.layer.cornerRadius = 8.0f;
    followBtn.frame = CGRectMake(85, 50, 70, 70);
    [followBtn setBackgroundImage:[UIImage imageNamed:@"button_title.png"] forState:UIControlStateNormal];
    [followBtn addTarget:self
                  action:@selector(followBtnAction:)
        forControlEvents:UIControlEventTouchUpInside];
    UILabel* followLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70)] autorelease];
    followLabel.numberOfLines = 0;
    followLabel.text = [NSString stringWithFormat:@"%d\n粉丝", self.primaryUser.followersCount];
    followLabel.backgroundColor = [UIColor clearColor];
    followLabel.textAlignment = UITextAlignmentCenter;
    followLabel.font = FontOFHelvetica12;
    [followBtn addSubview:followLabel];
    [self.view addSubview:followBtn];
    
    UIButton* favBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    favBtn.layer.cornerRadius = 8.0f;
    favBtn.frame = CGRectMake(165, 50, 70, 70);
    [favBtn setBackgroundImage:[UIImage imageNamed:@"button_title.png"] forState:UIControlStateNormal];
    [favBtn addTarget:self
               action:@selector(favBtnAction:)
     forControlEvents:UIControlEventTouchUpInside];
    UILabel* favLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70)] autorelease];
    favLabel.numberOfLines = 0;
    favLabel.text = [NSString stringWithFormat:@"%d\n收藏", self.primaryUser.favoritesCount];
    favLabel.backgroundColor = [UIColor clearColor];
    favLabel.textAlignment = UITextAlignmentCenter;
    favLabel.font = FontOFHelvetica12;
    [favBtn addSubview:favLabel];
    [self.view addSubview:favBtn];
    
    UIButton* statuseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    statuseBtn.layer.cornerRadius = 8.0f;
    statuseBtn.frame = CGRectMake(245, 50, 70, 70);
    [statuseBtn setBackgroundImage:[UIImage imageNamed:@"button_title.png"] forState:UIControlStateNormal];
    [statuseBtn addTarget:self
                   action:@selector(statuseBtnAction:)
         forControlEvents:UIControlEventTouchUpInside];
    UILabel* statuseLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70)] autorelease];
    statuseLabel.numberOfLines = 0;
    statuseLabel.text = [NSString stringWithFormat:@"%d\n微博", self.primaryUser.statusesCount];
    statuseLabel.backgroundColor = [UIColor clearColor];
    statuseLabel.textAlignment = UITextAlignmentCenter;
    statuseLabel.font = FontOFHelvetica12;
    [statuseBtn addSubview:statuseLabel];
    [self.view addSubview:statuseBtn];
    
    UIImageView* seperatorImageView2 = [[[UIImageView alloc] initWithFrame:CGRectMake(-10, 124, 340, 1)] autorelease];
    seperatorImageView2.image = [UIImage imageNamed:@"statusdetail_header_separator.png"];
    [self.view addSubview:seperatorImageView2];
}

- (UIView* )createViewIncellWith: (Status* )status indexPath: (NSIndexPath* )indexPath
{    
    UIView *viewInCell = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)] autorelease];
    CGFloat height = 0;
    
    OHAttributedLabel *detailTextLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(5, 5, 310, 0)] autorelease];
    detailTextLabel.delegate = self;
    detailTextLabel.underlineLinks = NO;
    
    [detailTextLabel setAttString:status.attString withImages:status.images];
    
    CGRect textFrame = detailTextLabel.frame;
    textFrame.size.height = status.detailTextHeight;
    [detailTextLabel setFrame:textFrame];
    
    [status.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
        [detailTextLabel addCustomLink:[NSURL URLWithString:user]
                               inRange:[status.attString.string rangeOfString:user]];
    }];
    
    [status.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
        [detailTextLabel addCustomLink:[NSURL URLWithString:topic]
                               inRange:[status.attString.string rangeOfString:topic]];
    }];
    
    [viewInCell addSubview:detailTextLabel];
    
    height = height + status.detailTextHeight + 5;
    
    switch (status.type)
    {
        case MainPageBasicImageCellType:
        {
            UIImageView *postImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, height, 80, 80)] autorelease];
            postImageView.tag = 30000;
            postImageView.contentMode = UIViewContentModeScaleAspectFit;
            [postImageView setImageWithURL:[NSURL URLWithString:status.thumbnailPic]
                          placeholderImage:[UIImage imageNamed:@"group_btn_pic_on_title.png"]
                                   success:^(UIImage *image, BOOL cached) {
                                       status.postImageView.image = image;
                                   }
                                   failure:^(NSError *error) {
                                       ;
                                   }];
            
            [viewInCell addSubview:postImageView];
            height += 80 + 5;
            
            UITapGestureRecognizer *gestureDetect = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector        (imageTappedAction:)] autorelease];
            [postImageView addGestureRecognizer:gestureDetect];
            postImageView.userInteractionEnabled = YES;
            
            break;
        }
        case MainPageRetweetedCellType:
        {
            //主View背景图片
            UIImageView *resizeImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, height, 310, 0)] autorelease];
            UIImage *resizeImage = [[UIImage imageNamed:@"timeline_rt_border_9.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 30, 10, 10)];
            [resizeImageView setImage:resizeImage];
            resizeImageView.layer.cornerRadius = 8.0f;
            resizeImageView.layer.masksToBounds = YES;
            
            //被转发用户名
            UILabel *retweetedUserNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 5, 160, 20)] autorelease];
            retweetedUserNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
            retweetedUserNameLabel.backgroundColor = [UIColor clearColor];
            retweetedUserNameLabel.text = status.retweetedStatus.user.atScreenName;
            [resizeImageView addSubview:retweetedUserNameLabel];
            
            //被转发博文
            OHAttributedLabel *retweetedTextLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(5, 30, 300, 0)] autorelease];
            retweetedTextLabel.delegate = self;
            retweetedTextLabel.underlineLinks = NO;
            retweetedTextLabel.backgroundColor = [UIColor clearColor];
            [resizeImageView addSubview:retweetedTextLabel];
            
            [retweetedTextLabel setAttString:status.retweetedStatus.attString withImages:status.retweetedStatus.images];
            
            CGRect textFrame = retweetedTextLabel.frame;
            textFrame.size.height = status.detailRetweetedTextHeight;
            [retweetedTextLabel setFrame:textFrame];
            
            [status.retweetedStatus.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
                [retweetedTextLabel addCustomLink:[NSURL URLWithString:user]
                                          inRange:[status.retweetedStatus.attString.string rangeOfString:user]];
            }];
            
            [status.retweetedStatus.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
                [retweetedTextLabel addCustomLink:[NSURL URLWithString:topic]
                                          inRange:[status.retweetedStatus.attString.string rangeOfString:topic]];
            }];
            
            CGRect backImageViewFrame = resizeImageView.frame;
            backImageViewFrame.size.height = 5 + 20 + 5 + status.detailRetweetedTextHeight + 5;
            resizeImageView.frame = backImageViewFrame;
            
            [viewInCell addSubview:resizeImageView];
            
            height = height + backImageViewFrame.size.height;
            break;
        }
        case MainPageRetweetedImageCellType:
        {
            //主View背景图片
            UIImageView *resizeImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, height, 310, 0)] autorelease];
            UIImage *resizeImage = [[UIImage imageNamed:@"timeline_rt_border_9.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 30, 10, 10)];
            [resizeImageView setImage:resizeImage];
            resizeImageView.layer.cornerRadius = 8.0f;
            resizeImageView.layer.masksToBounds = YES;
            
            //被转发用户名
            UILabel *retweetedUserNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 5, 160, 20)] autorelease];
            retweetedUserNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
            retweetedUserNameLabel.backgroundColor = [UIColor clearColor];
            retweetedUserNameLabel.text = [NSString stringWithFormat:@"@%@", status.retweetedStatus.user.screenName];
            [resizeImageView addSubview:retweetedUserNameLabel];
            
            //被转发博文
            OHAttributedLabel *retweetedTextLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(5, 30, 300, 0)] autorelease];
            retweetedTextLabel.underlineLinks = NO;
            retweetedTextLabel.delegate = self;
            retweetedTextLabel.backgroundColor = [UIColor clearColor];
            [resizeImageView addSubview:retweetedTextLabel];
            
            [retweetedTextLabel setAttString:status.retweetedStatus.attString withImages:status.retweetedStatus.images];
            
            CGRect textFrame = retweetedTextLabel.frame;
            textFrame.size.height = status.detailRetweetedTextHeight;
            [retweetedTextLabel setFrame:textFrame];
            
            [status.retweetedStatus.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
                [retweetedTextLabel addCustomLink:[NSURL URLWithString:user]
                                          inRange:[status.retweetedStatus.attString.string rangeOfString:user]];
            }];
            
            [status.retweetedStatus.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
                [retweetedTextLabel addCustomLink:[NSURL URLWithString:topic]
                                          inRange:[status.retweetedStatus.attString.string rangeOfString:topic]];
            }];
            
            //被转发博文的图片
            UIImageView *retweetedPostImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 5 + 20 + 5 + status.detailRetweetedTextHeight + 5, 80, 80)] autorelease];
            retweetedPostImageView.contentMode = UIViewContentModeScaleAspectFit;
            [retweetedPostImageView setImageWithURL:[NSURL URLWithString:status.retweetedStatus.thumbnailPic]
                                   placeholderImage:[UIImage imageNamed:@"group_btn_pic_on_title.png"]
                                            success:^(UIImage *image, BOOL cached) {
                                                status.retweetImageView.image = image;
                                            }
                                            failure:^(NSError *error) {
                                                ;
                                            }];
            
            UITapGestureRecognizer *gestureDetect = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector        (imageTappedAction:)] autorelease];
            [retweetedPostImageView addGestureRecognizer:gestureDetect];
            retweetedPostImageView.userInteractionEnabled = YES;
            resizeImageView.userInteractionEnabled = YES;
            
            [resizeImageView addSubview:retweetedPostImageView];
            
            CGRect backImageViewFrame = resizeImageView.frame;
            backImageViewFrame.size.height = 5 + 20 + 5 + status.detailRetweetedTextHeight + 5 + 80 + 10;
            resizeImageView.frame = backImageViewFrame;
            
            [viewInCell addSubview:resizeImageView];
            
            height = height + backImageViewFrame.size.height;
            break;
        }
        default:
            break;
    }
    
    height += 5;
    
    UILabel *postTimeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, height, 70, 20)] autorelease];
    postTimeLabel.text = status.createdAtCal;
    postTimeLabel.font = FontOFHelvetica11;
    [viewInCell addSubview:postTimeLabel];
    
    UILabel *sourceTipsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(80, height, 25, 20)] autorelease];
    sourceTipsLabel.text = @"来自";
    sourceTipsLabel.font = FontOFHelvetica11;
    [viewInCell addSubview:sourceTipsLabel];
    
    UILabel *sourceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(110, height, 140, 20)] autorelease];
    sourceLabel.text = status.sourceStr;
    sourceLabel.font = FontOFHelvetica11;
    [viewInCell addSubview:sourceLabel];
    
    height += 20;
    
    CGRect viewFrame = viewInCell.frame;
    viewFrame.size.height = height;
    viewInCell.frame = viewFrame;
    
    return viewInCell;
}

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
                [statusesArray removeAllObjects];
                [statusesArray addObjectsFromArray:tmpArray];
                
                [viewInCellArray removeAllObjects];
                for (Status* status in statusesArray)
                {
                    [viewInCellArray addObject:[self createViewIncellWith:status indexPath:nil]];
                }
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
            [viewInCellArray removeAllObjects];
            for (Status* status in statusesArray)
            {
                [viewInCellArray addObject:[self createViewIncellWith:status indexPath:nil]];
            }
            self.tableView.tableFooterView.hidden = YES;
        }
    }
    
    [self.tableView reloadData];
}

- (void)imageTappedAction: (UIGestureRecognizer *)aGesture
{
    UITableViewCell* cell = (UITableViewCell* )[[[[[aGesture view] superview] superview] superview] superview];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    
    Status* statuse = [statusesArray objectAtIndex:indexPath.row];
    UIView* view = [viewInCellArray objectAtIndex:indexPath.row];
    UIImageView *postImageView = (UIImageView *)[view viewWithTag:30000];
    
    NSString *originImageStr;
    if ([aGesture.view isEqual:postImageView])
        originImageStr = statuse.originalPic;
    else
        originImageStr = statuse.retweetedStatus.originalPic;
    
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

- (void)loadMoreButtonAction: (id)sender
{
    WeiboConnectManager *weiboCM = [WeiboConnectManager new];
    
    [weiboCM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        [self refreshData: NO];
        [weiboCM release];
    }];
    
    Status *firstStatus = [statusesArray lastObject];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:firstStatus.statusStr, @"max_id",
                          @"21", @"count",
                          weiboCM.sinaweibo.userID, @"uid",
                          nil];
    [weiboCM getDataFromWeiboWithURL:@"statuses/user_timeline.json"
                              params:dict
                          httpMethod:@"GET"];
}


#pragma mark - Custom Methods
- (void)friendBtnAction: (UIButton* )sender
{
    NSLog(@"friendBtnAction");
}

- (void)followBtnAction: (UIButton* )sender
{
    NSLog(@"followBtnAction");
}

- (void)statuseBtnAction: (UIButton* )sender
{
    NSLog(@"statuseBtnAction");
}

- (void)favBtnAction: (UIButton* )sender
{
    NSLog(@"favBtnAction");
}

@end
