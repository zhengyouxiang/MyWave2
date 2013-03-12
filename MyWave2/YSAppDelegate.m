//
//  YSAppDelegate.m
//  MyWave2
//
//  Created by youngsing on 13-3-7.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "YSAppDelegate.h"
#import "MyTabBarViewController.h"
#import "LoginModalViewController.h"

@implementation YSAppDelegate

- (void)dealloc
{
    [_revealSideViewController release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.sinaweibo = [[SinaWeibo alloc] initWithAppKey:myAppKey appSecret:myAppSecret appRedirectURI:myAppRedirectURI andDelegate:self];
    
    NSDictionary* sinaweiboInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"SinaWeiboAuthData"];
    if ([sinaweiboInfo objectForKey:@"AccessTokenKey"]
        && [sinaweiboInfo objectForKey:@"ExpirationDateKey"]
        && [sinaweiboInfo objectForKey:@"UserIDKey"])
    {
        self.sinaweibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
        self.sinaweibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
        self.sinaweibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
    }
    
    if (!self.sinaweibo.isAuthValid)
    {
        LoginModalViewController* loginVC = [[[LoginModalViewController alloc] init] autorelease];
        self.window.rootViewController = loginVC;
    }
    else
    {
        MyTabBarViewController* myTabBarVC = [[[MyTabBarViewController alloc] init] autorelease];
        self.revealSideViewController = [[[PPRevealSideViewController alloc] initWithRootViewController:myTabBarVC] autorelease];
        self.revealSideViewController.delegate = self;
        
        self.window.rootViewController = self.revealSideViewController;
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark SinaWeibo Delegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    for (UIView* view in self.window.subviews)
    {
        [view removeFromSuperview];
    }
    
    MyTabBarViewController* myTabBarVC = [[[MyTabBarViewController alloc] init] autorelease];
    self.revealSideViewController = [[[PPRevealSideViewController alloc] initWithRootViewController:myTabBarVC] autorelease];
    self.revealSideViewController.delegate = self;
    
    self.window.rootViewController = self.revealSideViewController;
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] setObject:sinaweibo.userID forKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uid"];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"%s:::::sinaweiboLogInDidCancel", __func__);
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"%s:::::logInDidFailWithError:::::%@", __func__, [error description]);
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uid"];
    NSLog(@"%s:::::accessTokenInvalidOrExpired:::::%@", __func__, [error description]);
}

@end
