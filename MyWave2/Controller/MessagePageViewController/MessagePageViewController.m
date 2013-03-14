//
//  MessagePageViewController.m
//  MyWave2
//
//  Created by youngsing on 13-3-12.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "MessagePageViewController.h"
#import "LeftGroupViewController.h"

@interface MessagePageViewController ()

@end

@implementation MessagePageViewController

- (void)createHeaderView
{
    UIView* headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    headerView.tag = 200;
    headerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:headerView];
    
    {
        groupButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        groupButton.frame = CGRectMake(0, 0, 44, 44);
        [groupButton setBackgroundImage:[UIImage imageNamed:@"button_m.png"]
                               forState:UIControlStateNormal];
        [groupButton addTarget:self
                        action:@selector(groupButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:groupButton];
        
        UIImageView* groupBtnImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)] autorelease];
        groupBtnImageView.image = [UIImage imageNamed:@"button_icon_group.png"];
        [groupButton addSubview:groupBtnImageView];
    }
    
    {
        UIImage* resizableImage = [[UIImage imageNamed:@"button_title.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
        UIImageView* selectImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(44, 0, 232, 44)] autorelease];
        selectImageView.image = resizableImage;
        selectImageView.userInteractionEnabled = YES;
        [headerView addSubview:selectImageView];
        
        UIButton* atButton = [UIButton buttonWithType:UIButtonTypeCustom];
        atButton.tag = 20000;
        atButton.frame = CGRectMake(0, 0, 77, 44);
        atButton.showsTouchWhenHighlighted = YES;
        atButton.titleLabel.font = FontOFHelvetica14;
        [atButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [atButton setTitle:@"@我" forState:UIControlStateNormal];
        [atButton addTarget:self
                     action:@selector(selectBtnAction:)
           forControlEvents:UIControlEventTouchUpInside];
        [selectImageView addSubview:atButton];
        
        UIButton* commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commentButton.tag = 20001;
        commentButton.frame = CGRectMake(77, 0, 77, 44);
        commentButton.showsTouchWhenHighlighted = YES;
        commentButton.titleLabel.font = FontOFHelvetica14;
        [commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [commentButton setTitle:@"评论" forState:UIControlStateNormal];
        [commentButton addTarget:self
                          action:@selector(selectBtnAction:)
                forControlEvents:UIControlEventTouchUpInside];
        [selectImageView addSubview:commentButton];
        
        UIButton* pmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        pmButton.tag = 20002;
        pmButton.frame = CGRectMake(154, 0, 78, 44);
        pmButton.showsTouchWhenHighlighted = YES;
        pmButton.titleLabel.font = FontOFHelvetica14;
        [pmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pmButton setTitle:@"私信" forState:UIControlStateNormal];
        [pmButton addTarget:self
                     action:@selector(selectBtnAction:)
           forControlEvents:UIControlEventTouchUpInside];
        [selectImageView addSubview:pmButton];
    }
    
    {
        toolButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        toolButton.frame = CGRectMake(276, 0, 44, 44);
        toolButton.hidden = YES;
        [toolButton setBackgroundImage:[UIImage imageNamed:@"button_m.png"]
                              forState:UIControlStateNormal];
        [toolButton addTarget:self
                       action:@selector(toolButtonAction:)
             forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:toolButton];
        
        UIImageView* toolBtnImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 30, 30)] autorelease];
        toolBtnImageView.image = [UIImage imageNamed:@"button_icon_plus.png"];
        [toolButton addSubview:toolBtnImageView];
    }
    
    currentIntFlag = 0;
}

- (void)loadView
{
    [super loadView];
    requestURL = @"statuses/mentions.json";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectBtnAction: (UIButton* )sender
{
    if (sender.tag - 20000 == currentIntFlag)
        return;
    
    switch (sender.tag - 20000)
    {
        case 0:
        {
            currentIntFlag = 0;
            groupButton.hidden = NO, toolButton.hidden = YES;
            
            requestURL = @"statuses/mentions.json";
            WeiboConnectManager* weiboCM = [WeiboConnectManager new];
            [weiboCM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
                [self refreshData:YES];
                [weiboCM release];
            }];
            [weiboCM getDataFromWeiboWithURL:requestURL
                                      params:nil
                                  httpMethod:@"GET"];
            break;
        }
        case 1:
        {
            currentIntFlag = 1;
            groupButton.hidden = NO, toolButton.hidden = YES;
            
            requestURL = @"comments/to_me.json";
            WeiboConnectManager* weiboCM = [WeiboConnectManager new];
            [weiboCM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
                [self refreshData:YES];
                [weiboCM release];
            }];
//            [weiboCM getDataFromWeiboWithURL:requestURL
//                                      params:nil
//                                  httpMethod:@"GET"];
            break;
        }
        case 2:
        {
            currentIntFlag = 2;
            groupButton.hidden = YES, toolButton.hidden = NO;
            
            requestURL = @"direct_messages.json";
            WeiboConnectManager* weiboCM = [WeiboConnectManager new];
            [weiboCM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
                [self refreshData:YES];
                [weiboCM release];
            }];
            [weiboCM getDataFromWeiboWithURL:requestURL
                                      params:nil
                                  httpMethod:@"GET"];
            break;
        }
        default:
            break;
    }
}

- (void)groupButtonAction: (UIButton* )sender
{
    NSLog(@"123");
    LeftGroupViewController* messageLeftGroupVC = [[[LeftGroupViewController alloc] init] autorelease];
    messageLeftGroupVC.dataSourceFlag = 1;
    [self.revealSideViewController pushViewController:messageLeftGroupVC
                                          onDirection:PPRevealSideDirectionLeft
                                           withOffset:70.0f
                                             animated:YES
                                           completion:^{
                                               ;
                                           }];    
}

@end
