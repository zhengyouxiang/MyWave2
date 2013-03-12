//
//  CustomNavViewController.m
//  MyWave
//
//  Created by youngsing on 13-1-10.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "CustomNavViewController.h"

@interface CustomNavViewController ()

@end

@implementation CustomNavViewController

- (void)loadView
{
    [super loadView];
    self.navigationBar.tintColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    UIImageView* shadowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow_compose.png"]] autorelease];
    shadowView.frame = CGRectMake(0, 44, 320, 10);
    [self.navigationBar addSubview:shadowView];
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

@end
