//
//  RightToolViewController.m
//  MyWave2
//
//  Created by youngsing on 13-3-7.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "RightToolViewController.h"
#import "PPRevealSideViewController.h"
#import "UpdateStatusesController.h"
#import "CustomNavViewController.h"

@interface RightToolViewController ()

@end

@implementation RightToolViewController

- (void)loadView
{
    [super loadView];
    
    UIImage* resizeImage = [[UIImage imageNamed:@"mask_bg.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImageView* imageView = [[[UIImageView alloc] initWithImage:resizeImage] autorelease];
    imageView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:imageView];
    
    UIButton *updateStatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    updateStatusButton.frame = CGRectMake(276, 0, 44, 44);
    [updateStatusButton setBackgroundImage:[UIImage imageNamed:@"newbar_icon_1.png"]
                                  forState:UIControlStateNormal];
    [updateStatusButton addTarget:self
                           action:@selector(updateStatusButtonAction:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:updateStatusButton];    
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

#pragma mark - Custom Methods
- (void)updateStatusButtonAction: (id)sender
{
    UpdateStatusesController *newController = [[[UpdateStatusesController alloc] init] autorelease];
    CustomNavViewController *newNavController = [[[CustomNavViewController alloc] initWithRootViewController:newController] autorelease];
    [self presentModalViewController:newNavController animated:YES];
    [self.revealSideViewController popViewControllerAnimated:YES];
}

@end
