//
//  MyTabBarViewController.m
//  MyWave
//
//  Created by youngsing on 13-1-27.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "MyTabBarViewController.h"

#import "PPRevealSideViewController.h"
#import "LeftGroupViewController.h"
#import "RightToolViewController.h"

#import "MainPageNavViewController.h"
#import "MainPageViewController.h"
#import "MessagePageNavViewController.h"
#import "MessagePageViewController.h"
#import "SquarePageNavViewController.h"
#import "SquarePageViewController.h"
#import "PersonalPageNavViewController.h"
#import "PersonalPageViewController.h"
#import "MorePageNavViewController.h"
#import "MorePageViewController.h"

@interface MyTabBarViewController ()

@end

@implementation MyTabBarViewController
@synthesize customTabBarView;
@synthesize homeTabBarButton, messageTabBarButton, squareTabBarButton, personalTabBarButton, moreTabBarButton;
@synthesize sliderLabel;
@synthesize backgroundTabBarButtonView;

- (void)loadView
{
    [super loadView];
    [self initBasic];
    
    MainPageViewController* mainPageVC = [[[MainPageViewController alloc] init] autorelease];
    mainPageVC.hidesBottomBarWhenPushed = YES;
    MainPageNavViewController* mainPageNavVC = [[[MainPageNavViewController alloc] initWithRootViewController:mainPageVC] autorelease];
    
    MessagePageViewController* messagePageVC = [[[MessagePageViewController alloc] init] autorelease];
    messagePageVC.hidesBottomBarWhenPushed = YES;
    MessagePageNavViewController* messagePageNavVC = [[[MessagePageNavViewController alloc] initWithRootViewController:messagePageVC] autorelease];
    
    SquarePageViewController* squarePageVC = [[[SquarePageViewController alloc] init] autorelease];
    squarePageVC.hidesBottomBarWhenPushed = YES;
    SquarePageNavViewController* squarePageNavVC = [[[SquarePageNavViewController alloc] initWithRootViewController:squarePageVC] autorelease];
    
    PersonalPageViewController* personalPageVC = [[[PersonalPageViewController alloc] init] autorelease];
    personalPageVC.hidesBottomBarWhenPushed = YES;
    PersonalPageNavViewController* personalPageNavVC = [[[PersonalPageNavViewController alloc] initWithRootViewController:personalPageVC] autorelease];
    
    MorePageViewController* morePageVC = [[[MorePageViewController alloc] init] autorelease];
    morePageVC.hidesBottomBarWhenPushed = YES;
    MorePageNavViewController* morePageNavVC = [[[MorePageNavViewController alloc] initWithRootViewController:morePageVC] autorelease];
    
    self.viewControllers = [NSArray arrayWithObjects:mainPageNavVC,
                            messagePageNavVC,
                            squarePageNavVC,
                            personalPageNavVC,
                            morePageNavVC,
                            nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
- (void)initBasic
{
    customTabBarView = [[[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 20 - 45, 320, 45)] autorelease];
    customTabBarView.tag = 100000;
    customTabBarView.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    [self.view addSubview:customTabBarView];
    
    homeTabBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    homeTabBarButton.showsTouchWhenHighlighted = YES;
    homeTabBarButton.tag = 0;
    homeTabBarButton.frame = CGRectMake(0, 0, 63, 45);
    [homeTabBarButton setImage:[UIImage imageNamed:@"home_tab_icon_1.png"] forState:UIControlStateNormal];
    [homeTabBarButton addTarget:self
                         action:@selector(selectedTab:)
               forControlEvents:UIControlEventTouchUpInside];
    [customTabBarView addSubview:homeTabBarButton];
    
    messageTabBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    messageTabBarButton.showsTouchWhenHighlighted = YES;
    messageTabBarButton.tag = 1;
    messageTabBarButton.frame = CGRectMake(64, 0, 63, 45);
    [messageTabBarButton setImage:[UIImage imageNamed:@"home_tab_icon_2_1.png"] forState:UIControlStateNormal];
    [messageTabBarButton addTarget:self
                            action:@selector(selectedTab:)
                  forControlEvents:UIControlEventTouchUpInside];
    [customTabBarView addSubview:messageTabBarButton];
    
    squareTabBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    squareTabBarButton.showsTouchWhenHighlighted = YES;
    squareTabBarButton.tag = 2;
    squareTabBarButton.frame = CGRectMake(128, 0, 63, 45);
    [squareTabBarButton setImage:[UIImage imageNamed:@"home_tab_icon_3.png"] forState:UIControlStateNormal];
    [squareTabBarButton addTarget:self
                           action:@selector(selectedTab:)
                 forControlEvents:UIControlEventTouchUpInside];
    [customTabBarView addSubview:squareTabBarButton];
    
    personalTabBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    personalTabBarButton.showsTouchWhenHighlighted = YES;
    personalTabBarButton.tag = 3;
    personalTabBarButton.frame = CGRectMake(192, 0, 63, 45);
    [personalTabBarButton setImage:[UIImage imageNamed:@"home_tab_icon_4.png"] forState:UIControlStateNormal];
    [personalTabBarButton addTarget:self
                             action:@selector(selectedTab:)
                   forControlEvents:UIControlEventTouchUpInside];
    [customTabBarView addSubview:personalTabBarButton];
    
    moreTabBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreTabBarButton.showsTouchWhenHighlighted = YES;
    moreTabBarButton.tag = 4;
    moreTabBarButton.frame = CGRectMake(256, 0, 63, 45);
    [moreTabBarButton setImage:[UIImage imageNamed:@"home_tab_icon_5.png"] forState:UIControlStateNormal];
    [moreTabBarButton addTarget:self
                         action:@selector(selectedTab:)
               forControlEvents:UIControlEventTouchUpInside];
    [customTabBarView addSubview:moreTabBarButton];
    
    backgroundTabBarButtonView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 64, 45)] autorelease];
    
    UIImageView *selectedImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 45)] autorelease];
    selectedImageView.image = [UIImage imageNamed:@"home_bottom_tab_arrow.png"];
    [backgroundTabBarButtonView addSubview:selectedImageView];
    [customTabBarView addSubview:backgroundTabBarButtonView];
    
    sliderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 4)] autorelease];
//    sliderLabel.backgroundColor = [UIColor cyanColor];
    sliderLabel.backgroundColor = [UIColor colorWithWhite:145.0f/255 alpha:1.0f];
    [customTabBarView addSubview:sliderLabel];
}

- (void)selectedTab: (UIButton *)sender
{
    if (sender.tag == self.selectedIndex)
        return;
    
    CATransition* animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"cube";
    if (self.selectedIndex < sender.tag)
        animation.subtype = kCATransitionFromRight;
    else
        animation.subtype = kCATransitionFromLeft;
    [self.tabBar exchangeSubviewAtIndex:self.selectedIndex withSubviewAtIndex:sender.tag];
    self.selectedIndex = sender.tag;
    backgroundTabBarButtonView.frame = CGRectMake(64 * sender.tag, 0, 64, 45);
    sliderLabel.frame = CGRectMake(64 * sender.tag, 0, 64, 4);
    [[self.view layer] addAnimation:animation forKey:@"animation"];
}

@end
