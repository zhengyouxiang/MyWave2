//
//  LoginModalViewController.m
//  MyWave
//
//  Created by youngsing on 13-1-12.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "LoginModalViewController.h"
#import "WeiboConnectManager.h"
#import "MyTabBarViewController.h"
#import "YSAppDelegate.h"

@interface LoginModalViewController ()

@end

@implementation LoginModalViewController

- (void)loadView
{
    [super loadView];
    
    UIImageView *backgroudImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg0.png"]] autorelease];
    backgroudImageView.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:backgroudImageView];
    
    UIButton *logInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logInButton.frame = CGRectMake(163, 80, 120, 150);
    logInButton.backgroundColor = [UIColor clearColor];
    [logInButton setBackgroundImage:[UIImage imageNamed:@"my_login.png"] forState:UIControlStateNormal];
    [logInButton addTarget:self
                    action:@selector(gotoOAuth:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logInButton];
    
    UILabel *tipsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(260, 80, 25, 100)] autorelease];
    tipsLabel.text = @"点我登陆";
    tipsLabel.numberOfLines = 0;
    tipsLabel.font = [UIFont fontWithName:@"GillSans-Italic" size:20];
    tipsLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipsLabel];
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

- (void)gotoOAuth: (id)sender
{
    YSAppDelegate *appDelegate = (YSAppDelegate *)[UIApplication sharedApplication].delegate;
    SinaWeibo* sinaweibo = appDelegate.sinaweibo;
    [sinaweibo logIn];
}


@end
