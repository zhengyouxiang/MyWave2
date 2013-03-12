//
//  DetailStatusViewController.m
//  MyWave
//
//  Created by youngsing on 13-1-25.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "DetailStatusViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "User.h"
#import "Comment.h"
#import "ImageView.h"
#import "HMSegmentedControl.h"
#import "DetailPageCommentCell.h"
#import "FeedbackTipsView.h"

@interface DetailStatusViewController ()

@end

static BOOL isCommentSelected = YES;

@implementation DetailStatusViewController
@synthesize detailStatus;

- (void)loadView
{
    [super loadView];
    
    UIView *tabBarView = [self.tabBarController.view viewWithTag:100000];
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = tabBarView.frame;
        NSLog(@"%@", NSStringFromCGRect(frame));
        frame.origin.x = - 320;
        tabBarView.frame =frame;
    }];
    
    [self createdHeaderView];
    
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 60, 320, [UIScreen mainScreen].bounds.size.height - 20 - 60 - 40) style:UITableViewStylePlain] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.tableView.tableHeaderView = [self createTableHeaderView];
    
    [self createCommentToolView];
    
    isCommentSelected = YES;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self keyboardHeightDidChanged:note];
                                                  }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    WeiboConnectManager *weiboM = [WeiboConnectManager new];
    [weiboM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        [self refreshData];
        [weiboM release];
    }];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:detailStatus.statusStr, @"id", nil];
    [weiboM getDataFromWeiboWithURL:@"comments/show.json" params:dict httpMethod:@"GET"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIView *tabBarView = [self.tabBarController.view viewWithTag:100000];
    tabBarView.hidden = YES;
}

-(void)dealloc
{
    [commentDataArray release];
    [super dealloc];
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
    if (commentDataArray.count == 0)
        return 1;
    
    return commentDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *postTimeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 5, 70, 20)] autorelease];
    postTimeLabel.text = detailStatus.createdAtCal;
    postTimeLabel.font = FontOFHelvetica11;
    [headerView addSubview:postTimeLabel];
    
    UILabel *sourceTipsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(80, 5, 25, 20)] autorelease];
    sourceTipsLabel.text = @"来自";
    sourceTipsLabel.font = FontOFHelvetica11;
    [headerView addSubview:sourceTipsLabel];
    
    UILabel *sourceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(110, 5, 140, 20)] autorelease];
    sourceLabel.text = detailStatus.sourceStr;
    sourceLabel.font = FontOFHelvetica11;
    [headerView addSubview:sourceLabel];
    
    repostAndCommentSegCtrl = [[[HMSegmentedControl alloc] initWithSectionTitles:
                                                    @[[NSString stringWithFormat:@"转发:%d", detailStatus.repostsCount],
                                                    [NSString stringWithFormat:@"评论:%d", detailStatus.commentsCount]]] autorelease];
    
    [repostAndCommentSegCtrl setHeight:20];
    [repostAndCommentSegCtrl setFont:[UIFont fontWithName:@"Helvetica" size:13]];
    [repostAndCommentSegCtrl setSelectionIndicatorHeight:4.0f];
    [repostAndCommentSegCtrl setBackgroundColor:[UIColor clearColor]];
    [repostAndCommentSegCtrl setTextColor:[UIColor blackColor]];
    [repostAndCommentSegCtrl setSelectionIndicatorColor:[UIColor colorWithRed:0.5 green:0.8 blue:1 alpha:1]];
    [repostAndCommentSegCtrl setSelectionIndicatorStyle:HMSelectionIndicatorResizesToStringWidth];
    [repostAndCommentSegCtrl setSelectedSegmentIndex:isCommentSelected];
    [repostAndCommentSegCtrl setSegmentEdgeInset:UIEdgeInsetsMake(0, 5, 0, 5)];
    [repostAndCommentSegCtrl setCenter:CGPointMake(250, 15)];
    [repostAndCommentSegCtrl addTarget:self
                                action:@selector(segCtrlValueChangedAction:)
                      forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:repostAndCommentSegCtrl];
    
    UIImageView *separatorImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(-10, 29, 340, 1)] autorelease];
    separatorImageView.image = [UIImage imageNamed:@"statusdetail_header_separator.png"];
    [headerView addSubview:separatorImageView];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && commentDataArray.count == 0)
    {
        static NSString *noDataCellIdentifier = @"NoDataCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noDataCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:noDataCellIdentifier] autorelease];
        }
        
        cell.textLabel.text = @"暂无回应";
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        
        return cell;
    }
    
    if (isCommentSelected)
    {
        static NSString *CommentCellIdentifier = @"CommentCellIdentifier";
        DetailPageCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[DetailPageCommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:CommentCellIdentifier] autorelease];
        }
        
        Comment *commentCell = [commentDataArray objectAtIndex:indexPath.row];
        
        [cell.commentAvatarImageView setImageWithURL:[NSURL URLWithString:commentCell.user.profileImageUrl]
                                    placeholderImage:[UIImage imageNamed:@"login_avarta_weibo.jpg"]];
        
        cell.commentUserNameLabel.text = [NSString stringWithFormat:@"@%@", commentCell.user.screenName];
        
        cell.commentTextLabel.delegate = self;
        [cell.commentTextLabel setAttString:commentCell.commentAttString withImages:commentCell.images];
        
        CGRect textFrame = cell.commentTextLabel.frame;
        textFrame.size.height = commentCell.commentTextHeight;
        [cell.commentTextLabel setFrame:textFrame];
        
        [commentCell.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
            [cell.commentTextLabel addCustomLink:[NSURL URLWithString:user]
                                         inRange:[commentCell.commentAttString.string rangeOfString:user]];
        }];
        
        [commentCell.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
            [cell.commentTextLabel addCustomLink:[NSURL URLWithString:topic]
                                         inRange:[commentCell.commentAttString.string rangeOfString:topic]];
        }];
        
        cell.commentTimeLabel.text = commentCell.createdAtCal;
        
        return cell;
    }
    else
    {
        static NSString *repostCellIdentifier = @"RepostCellIdentifier";
        DetailPageCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:repostCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[[DetailPageCommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:repostCellIdentifier] autorelease];
        }
        
        Status *repostStatusCell = [commentDataArray objectAtIndex:indexPath.row];
        
        [cell.commentAvatarImageView setImageWithURL:[NSURL URLWithString:repostStatusCell.user.profileImageUrl]
                                    placeholderImage:[UIImage imageNamed:@"login_avarta_weibo.jpg"]];
        
        cell.commentUserNameLabel.text = [NSString stringWithFormat:@"@%@", repostStatusCell.user.screenName];
        
        [cell.commentTextLabel setAttString:repostStatusCell.attString withImages:repostStatusCell.images];
        cell.commentTextLabel.delegate = self;
        
        CGRect textFrame = cell.commentTextLabel.frame;
        textFrame.size.height = repostStatusCell.detailRepostTextHeight;
        [cell.commentTextLabel setFrame:textFrame];
        
        [repostStatusCell.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
            [cell.commentTextLabel addCustomLink:[NSURL URLWithString:user]
                                         inRange:[repostStatusCell.attString.string rangeOfString:user]];
        }];
        
        [repostStatusCell.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
            [cell.commentTextLabel addCustomLink:[NSURL URLWithString:topic]
                                         inRange:[repostStatusCell.attString.string rangeOfString:topic]];
        }];
        
        cell.commentTimeLabel.text = repostStatusCell.createdAtCal;
        
        return cell;
    }
}

#pragma mark - Table view delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (commentDataArray.count == 0 && indexPath.row == 0)
    {
        int height = [UIScreen mainScreen].bounds.size.height - 20 - 60 - self.tableView.tableHeaderView.frame.size.height - 30 - 40;
        height = height > 44 ? height : 44;
        return height;
    }
    
    if (isCommentSelected)
        return [[commentDataArray objectAtIndex:indexPath.row] totalHeight];
    else
    {
        return [[commentDataArray objectAtIndex:indexPath.row] detailTotalHeight];
    }
}

#pragma mark - Scroll view delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3f animations:^{
        commentInputView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 20 - 45, 320, 45);
        
        placeHolderInTextViewLabel.hidden = NO;
        atButton.hidden = YES;
        faceButton.hidden = YES;
        updateButton.hidden = YES;
        inputTextView.text = @"";
        
        inputBackgroundView.frame = CGRectMake(5, 5, 310, 35);
    }];
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

#pragma mark - TextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.3f animations:^{
        placeHolderInTextViewLabel.hidden = YES;
        atButton.hidden = NO;
        faceButton.hidden = NO;
        updateButton.hidden = NO;
        
        inputBackgroundView.frame = CGRectMake(5, 5, 275, 30);
        
        atButton.frame = CGRectMake(275 - 36 - 36, inputBackgroundView.frame.size.height - 30, 36, 30);
        faceButton.frame = CGRectMake(275 - 36, inputBackgroundView.frame.size.height - 30, 36, 30);;
        
        inputTextView.frame = CGRectMake(0, 0, 275 - 36 - 36, 30);
    }];

    isFaceLoad = NO;
    [emoticonsScrollView removeFromSuperview];
}

-(void)textViewDidChange:(UITextView *)textView
{
    float sumLength = 0.0;
    for(int i = 0; i<[textView.text length]; ++i)
    {
        NSString *character = [textView.text substringWithRange:NSMakeRange(i, 1)];
        if([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
            ++sumLength;
        else
            sumLength += 0.5;
    }
    
    if (sumLength > 0 && sumLength <= 140)
        updateButton.enabled = YES;
    else
         updateButton.enabled = NO;
    
    CGFloat changedHeight = 0;
    if (priorHeight == 0)
        priorHeight = textView.contentSize.height;
    
    if (priorHeight != textView.contentSize.height)
    {
        changedHeight = textView.contentSize.height - priorHeight;
        priorHeight = textView.contentSize.height;
    }

    CGRect commentInputFrame = commentInputView.frame;
    commentInputFrame.origin.y = commentInputFrame.origin.y - changedHeight;
    commentInputFrame.size.height = commentInputFrame.size.height + changedHeight;
    commentInputFrame.size.height = commentInputFrame.size.height < 40 ? 40 : commentInputFrame.size.height;
    commentInputView.frame = commentInputFrame;
    
    CGRect commentBackgroundFrame = inputBackgroundView.frame;
    commentBackgroundFrame.size.height = commentBackgroundFrame.size.height + changedHeight;
    commentBackgroundFrame.size.height = commentBackgroundFrame.size.height < 30 ? 30 : commentBackgroundFrame.size.height;
    inputBackgroundView.frame = commentBackgroundFrame;
    
    atButton.frame = CGRectMake(275 - 36 - 36, inputBackgroundView.frame.size.height - 30, 36, 30);
    faceButton.frame = CGRectMake(275 - 36, inputBackgroundView.frame.size.height - 30, 36, 30);
    updateButton.frame = CGRectMake(285, inputBackgroundView.frame.origin.y + inputBackgroundView.frame.size.height - 30, 30, 30);
    
    if (inputBackgroundView.frame.size.height > 30)
    {
        numLabel.hidden = NO;
        numLabel.text = [NSString stringWithFormat:@"%d", 140 - (int)ceil(sumLength)];
    }
    else
        numLabel.hidden = YES;
}

#pragma mark - Custom Methods
- (void)createdHeaderView
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)] autorelease];
    headerView.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    [self.view addSubview:headerView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, 5, 50, 50);
    [backButton setBackgroundImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(popViewController:)
         forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backButton];
    
    UIImageView *avatarImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(65, 5, 50, 50)] autorelease];
    [avatarImageView setImageWithURL:[NSURL URLWithString:detailStatus.user.profileLargeImageUrl]
                    placeholderImage:[UIImage imageNamed:@"login_avarta_weibo.jpg"]];
    [headerView addSubview:avatarImageView];
    
    UILabel *userNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(125, 5, 140, 20)] autorelease];
    userNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    userNameLabel.backgroundColor = [UIColor clearColor];

    userNameLabel.text = detailStatus.user.screenName;
    [headerView addSubview:userNameLabel];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(130, 25, 40, 40);
    [moreButton setBackgroundImage:[UIImage imageNamed:@"detail_button_more.png"]
                          forState:UIControlStateNormal];
    [headerView addSubview:moreButton];
    
    UIButton *favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    favButton.frame = CGRectMake(180, 25, 40, 40);
    [favButton setBackgroundImage:[UIImage imageNamed:@"detail_button_fav.png"]
                         forState:UIControlStateNormal];
    [headerView addSubview:favButton];
    
    UIButton *forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardButton.frame = CGRectMake(230, 25, 40, 40);
    [forwardButton setBackgroundImage:[UIImage imageNamed:@"detail_button_forward.png"]
                             forState:UIControlStateNormal];
    [headerView addSubview:forwardButton];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commentButton.frame = CGRectMake(280, 25, 40, 40);
    [commentButton setBackgroundImage:[UIImage imageNamed:@"detail_button_comment.png"]
                             forState:UIControlStateNormal];
    //    [commentButton addTarget:self
    //                   action:@selector(popViewController:)
    //         forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:commentButton];
}

- (UIView *)createTableHeaderView
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)] autorelease];
    headerView.layer.cornerRadius = 8.0f;
    headerView.layer.masksToBounds = YES;
    CGRect tableHeaderFrame = headerView.frame;
    CGFloat height = 0;
    
    OHAttributedLabel *detailTextLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(5, 5, 310, 0)] autorelease];
    detailTextLabel.delegate = self;
    detailTextLabel.underlineLinks = NO;
    
    [detailTextLabel setAttString:detailStatus.attString withImages:detailStatus.images];
    
    CGRect textFrame = detailTextLabel.frame;
    textFrame.size.height = detailStatus.detailTextHeight;
    [detailTextLabel setFrame:textFrame];
    
    [detailStatus.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
        [detailTextLabel addCustomLink:[NSURL URLWithString:user]
                               inRange:[detailStatus.attString.string rangeOfString:user]];
    }];
    
    [detailStatus.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
        [detailTextLabel addCustomLink:[NSURL URLWithString:topic]
                               inRange:[detailStatus.attString.string rangeOfString:topic]];
    }];
    
    [headerView addSubview:detailTextLabel];
    
    height = height + detailStatus.detailTextHeight + 5;
    
    switch (detailStatus.type)
    {
        case MainPageBasicImageCellType:
        {
            UIImage *image = detailStatus.postImageView.image;
            UIImageView *postImageView = [[[UIImageView alloc] initWithImage:image] autorelease];
            postImageView.tag = 1000;
            postImageView.frame = CGRectMake(160 - image.size.width / 2, height, image.size.width, image.size.height);
            
            [headerView addSubview:postImageView];
            height = height + image.size.height + 5;
            
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
            retweetedUserNameLabel.text = detailStatus.retweetedStatus.user.atScreenName;
            [resizeImageView addSubview:retweetedUserNameLabel];
            
            //被转发博文
            OHAttributedLabel *retweetedTextLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(5, 30, 300, 0)] autorelease];
            retweetedTextLabel.delegate = self;
            retweetedTextLabel.underlineLinks = NO;
            retweetedTextLabel.backgroundColor = [UIColor clearColor];
            [resizeImageView addSubview:retweetedTextLabel];
            
            [retweetedTextLabel setAttString:detailStatus.retweetedStatus.attString withImages:detailStatus.retweetedStatus.images];
            
            CGRect textFrame = retweetedTextLabel.frame;
            textFrame.size.height = detailStatus.detailRetweetedTextHeight;
            [retweetedTextLabel setFrame:textFrame];
            
            [detailStatus.retweetedStatus.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
                [retweetedTextLabel addCustomLink:[NSURL URLWithString:user]
                                          inRange:[detailStatus.retweetedStatus.attString.string rangeOfString:user]];
            }];
            
            [detailStatus.retweetedStatus.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
                [retweetedTextLabel addCustomLink:[NSURL URLWithString:topic]
                                          inRange:[detailStatus.retweetedStatus.attString.string rangeOfString:topic]];
            }];
            
            CGRect backImageViewFrame = resizeImageView.frame;
            backImageViewFrame.size.height = 5 + 20 + 5 + detailStatus.detailRetweetedTextHeight + 5;
            resizeImageView.frame = backImageViewFrame;
            
            [headerView addSubview:resizeImageView];
            
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
            retweetedUserNameLabel.text = [NSString stringWithFormat:@"@%@", detailStatus.retweetedStatus.user.screenName];
            [resizeImageView addSubview:retweetedUserNameLabel];
            
            //被转发博文
            OHAttributedLabel *retweetedTextLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(5, 30, 300, 0)] autorelease];
            retweetedTextLabel.underlineLinks = NO;
            retweetedTextLabel.delegate = self;
            retweetedTextLabel.backgroundColor = [UIColor clearColor];
            [resizeImageView addSubview:retweetedTextLabel];
            
            [retweetedTextLabel setAttString:detailStatus.retweetedStatus.attString withImages:detailStatus.retweetedStatus.images];
            
            CGRect textFrame = retweetedTextLabel.frame;
            textFrame.size.height = detailStatus.detailRetweetedTextHeight;
            [retweetedTextLabel setFrame:textFrame];
            
            [detailStatus.retweetedStatus.users enumerateObjectsUsingBlock:^(NSString *user, NSUInteger idx, BOOL *stop) {
                [retweetedTextLabel addCustomLink:[NSURL URLWithString:user]
                                          inRange:[detailStatus.retweetedStatus.attString.string rangeOfString:user]];
            }];
            
            [detailStatus.retweetedStatus.topics enumerateObjectsUsingBlock:^(NSString *topic, NSUInteger idx, BOOL *stop) {
                [retweetedTextLabel addCustomLink:[NSURL URLWithString:topic]
                                          inRange:[detailStatus.retweetedStatus.attString.string rangeOfString:topic]];
            }];
            
            //被转发博文的图片
            UIImage *image = detailStatus.retweetImageView.image;
            UIImageView *retweetedPostImageView = [[[UIImageView alloc] initWithImage:image] autorelease];
            retweetedPostImageView.tag = 2000;
            
            UITapGestureRecognizer *gestureDetect = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                             action:@selector        (imageTappedAction:)] autorelease];
            [retweetedPostImageView addGestureRecognizer:gestureDetect];
            retweetedPostImageView.userInteractionEnabled = YES;
            resizeImageView.userInteractionEnabled = YES;
            
            retweetedPostImageView.frame = CGRectMake(160 - image.size.width / 2, 5 + 20 + 5 + detailStatus.detailRetweetedTextHeight + 5, image.size.width, image.size.height);
            [resizeImageView addSubview:retweetedPostImageView];
            
            CGRect backImageViewFrame = resizeImageView.frame;
            backImageViewFrame.size.height = 5 + 20 + 5 + detailStatus.detailRetweetedTextHeight + 5 + image.size.height + 10;
            resizeImageView.frame = backImageViewFrame;
            
            [headerView addSubview:resizeImageView];
            
            height = height + backImageViewFrame.size.height;
            break;
        }
        default:
            break;
    }
    
    tableHeaderFrame.size.height = height;
    headerView.frame = tableHeaderFrame;
    
    return headerView;
}

- (void)createCommentToolView
{
    commentInputView = [[[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 20 - 40, 320, 40)] autorelease];
    commentInputView.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    [self.view addSubview:commentInputView];
    
    inputBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(5, 5, 310, 30)] autorelease];
    inputBackgroundView.backgroundColor = [UIColor whiteColor];
    inputBackgroundView.layer.cornerRadius = 8.0f;
    inputBackgroundView.layer.masksToBounds = YES;
    [commentInputView addSubview:inputBackgroundView];
    
    inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 310, 30)];
    inputTextView.delegate = self;
    inputTextView.font = FontOFHelvetica12;
    inputTextView.backgroundColor = [UIColor clearColor];
    inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [inputBackgroundView addSubview:inputTextView];
    
    placeHolderInTextViewLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 140, 30)] autorelease];
    placeHolderInTextViewLabel.text = @"添加评论...";
    placeHolderInTextViewLabel.font = FontOFHelvetica14;    
    placeHolderInTextViewLabel.textColor = UIColorWithWhite075100;
    [inputTextView addSubview:placeHolderInTextViewLabel];
    
    atButton = [UIButton buttonWithType:UIButtonTypeCustom];
    atButton.frame = CGRectMake(inputBackgroundView.frame.size.width - 20 - 20, 1, 20, 20);
    atButton.hidden = YES;
    [atButton setBackgroundImage:[UIImage imageNamed:@"compose_toolbar_3.png"] forState:UIControlStateNormal];
    [atButton addTarget:self
                 action:@selector(atButtonAction:)
       forControlEvents:UIControlEventTouchUpInside];
    [inputBackgroundView addSubview:atButton];
    
    faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    faceButton.hidden = YES;
    faceButton.frame = CGRectMake(inputBackgroundView.frame.size.width - 20, 1, 20, 20);
    [faceButton setBackgroundImage:[UIImage imageNamed:@"compose_toolbar_6.png"] forState:UIControlStateNormal];
    [faceButton addTarget:self
                   action:@selector(faceButtonAction:)
         forControlEvents:UIControlEventTouchUpInside];
    [inputBackgroundView addSubview:faceButton];
    
    updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    updateButton.hidden = YES;
    updateButton.enabled = NO;
    updateButton.frame = CGRectMake(320 - 30 - 5, 5, 30, 30);
    [updateButton setBackgroundImage:[UIImage imageNamed:@"updateButton.png"] forState:UIControlStateNormal];
    [updateButton addTarget:self
                     action:@selector(updateCommentButtonAction:)
           forControlEvents:UIControlEventTouchUpInside];
    updateButton.enabled = NO;
    [commentInputView addSubview:updateButton];
    
    numLabel = [[UILabel alloc] initWithFrame:CGRectMake(285, 0, 30, 15)];
    numLabel.font = FontOFHelvetica11;
    numLabel.backgroundColor = [UIColor clearColor];
    numLabel.textColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    numLabel.textAlignment = UITextAlignmentCenter;
    numLabel.hidden = YES;
    [commentInputView addSubview:numLabel];
}

- (void)keyboardHeightDidChanged: (NSNotification *)note
{
    NSDictionary *dict = [note userInfo];
    keyBoardHeight = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        
    [UIView animateWithDuration:0.3 animations:^{
        CGRect changeToFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 20 - keyBoardHeight - 44,
                                          320, 44);
        commentInputView.frame = changeToFrame;
    }];
}

- (void)refreshData
{
    if (commentDataArray.count == 0)
        commentDataArray = [[NSMutableArray alloc] initWithArray:[[WeiboDataManager share] weiboDataArray]];
    else
    {
        [commentDataArray removeAllObjects];
        [commentDataArray addObjectsFromArray:[[WeiboDataManager share] weiboDataArray]];
    }
    [self.tableView reloadData];
}

- (void)imageTappedAction: (UIGestureRecognizer *)aGesture
{
    UIImageView *postImageView = (UIImageView *)[self.tableView.tableHeaderView viewWithTag:1000];
    
    NSString *originImageStr;
    if ([aGesture.view isEqual:postImageView])
        originImageStr = detailStatus.originalPic;
    else
        originImageStr = detailStatus.retweetedStatus.originalPic;
    
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

- (void)segCtrlValueChangedAction: (id)segCtrl
{
    isCommentSelected = !isCommentSelected;
    
    WeiboConnectManager *weiboM = [WeiboConnectManager new];
    if (isCommentSelected)
    {
        [weiboM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
            [self refreshData];
            [weiboM release];
        }];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:detailStatus.statusStr, @"id", nil];
        [weiboM getDataFromWeiboWithURL:@"comments/show.json" params:dict httpMethod:@"GET"];
    }
    else
    {
        [weiboM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
            [self refreshData];
            [weiboM release];
        }];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:detailStatus.statusStr, @"id", nil];
        [weiboM getDataFromWeiboWithURL:@"statuses/repost_timeline.json"
                                 params:dict
                             httpMethod:@"GET"];
    }
}

- (void)popViewController: (id)sender
{
    UIView *tabBarView = [self.tabBarController.view viewWithTag:100000];
    tabBarView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 20 - 45, 320, 45);
    tabBarView.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)faceButtonAction: (id)sender
{
    [self.view endEditing:YES];
    if (!isFaceLoad)
    {
        emoticonsScrollView = [[[EmoticonsScrollView alloc] init] autorelease];
        emoticonsScrollView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320, [UIScreen mainScreen].bounds.size.height - 20 - commentInputView.frame.origin.y - commentInputView.frame.size.height);
        emoticonsScrollView.backgroundColor = [UIColor whiteColor];
        [commentInputView addSubview:emoticonsScrollView];
        
        [emoticonsScrollView setFaceImageTappedBlock:^(NSString *face) {
            inputTextView.text = [inputTextView.text stringByAppendingString:face];
            [self textViewDidChange:inputTextView];
            
            CGRect emoticonsFrame = emoticonsScrollView.frame;
            emoticonsFrame.origin.y = inputBackgroundView.frame.size.height + 10;
            emoticonsFrame.size.height = keyBoardHeight;
            emoticonsScrollView.frame = emoticonsFrame;
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect emoticonsFrame = emoticonsScrollView.frame;
            emoticonsFrame.origin.y = inputBackgroundView.frame.size.height + 10;
            emoticonsFrame.size.height = keyBoardHeight;
            emoticonsScrollView.frame = emoticonsFrame;
            
            CGRect commentInputViewFrame = commentInputView.frame;
            commentInputViewFrame.size.height = emoticonsScrollView.frame.size.height + 44;
            commentInputView.frame = commentInputViewFrame;
        } completion:^(BOOL finished) {
            isFaceLoad = YES;
        }];
    }
    else
    {
        [inputTextView becomeFirstResponder];
        isFaceLoad = NO;
    }
}

- (void)atButtonAction: (id)sender
{
    NSLog(@"coming soon");
}

- (void)updateCommentButtonAction: (id)sender
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          inputTextView.text, @"comment",
                          detailStatus.statusStr, @"id",
                          nil];
    
    WeiboConnectManager *weiboCM = [WeiboConnectManager new];
    [weiboCM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        [self.view endEditing:YES];
        [UIView animateWithDuration:0.3 animations:^{
            placeHolderInTextViewLabel.hidden = NO;
            atButton.hidden = YES;
            faceButton.hidden = YES;
            updateButton.hidden = YES;
            numLabel.hidden = YES;
            inputTextView.text = @"";
            
            commentInputView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 20 - 40, 320, 40);
            inputBackgroundView.frame = CGRectMake(5, 5, 310, 30);
        }];
        
        FeedbackTipsView *feedbackView = [[[FeedbackTipsView alloc] init] autorelease];
        UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
        if (!appWindow)
            appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        [appWindow addSubview:feedbackView];
        [feedbackView showTipsViewWithText:@"评论成功"];
        
        [weiboCM release];
    }];
    
    [weiboCM setFailCallbackBlock:^(SinaWeiboRequest *request, NSError *error) {
        [self.view endEditing:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentViewRemoved" object:self];
        
        FeedbackTipsView *feedbackView = [[[FeedbackTipsView alloc] init] autorelease];
        UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
        if (!appWindow)
            appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        [appWindow addSubview:feedbackView];
        [feedbackView showTipsViewWithText:@"评论失败"];
        NSLog(@"转发评论错误 %@", [error description]);
        
        [weiboCM release];
    }];
    
    [weiboCM getDataFromWeiboWithURL:@"comments/create.json" params:dict httpMethod:@"POST"];
}

@end
