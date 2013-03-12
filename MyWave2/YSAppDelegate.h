//
//  YSAppDelegate.h
//  MyWave2
//
//  Created by youngsing on 13-3-7.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPRevealSideViewController.h"
#import "SinaWeibo.h"

#define myAppKey             @"980205732"
#define myAppSecret          @"4acd14d8b72b9c29bead0aaabc8c0c46"
#define myAppRedirectURI     @"https://api.weibo.com/oauth2/default.html"

@interface YSAppDelegate : UIResponder <UIApplicationDelegate, SinaWeiboDelegate, PPRevealSideViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) PPRevealSideViewController* revealSideViewController;

@property (retain, nonatomic) SinaWeibo* sinaweibo;

@end
