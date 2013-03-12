//
//  MyTabBarViewController.h
//  MyWave
//
//  Created by youngsing on 13-1-27.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTabBarViewController : UITabBarController

@property (retain, nonatomic) UIView *customTabBarView;

@property (retain, nonatomic) UIButton *homeTabBarButton;
@property (retain, nonatomic) UIButton *messageTabBarButton;
@property (retain, nonatomic) UIButton *squareTabBarButton;
@property (retain, nonatomic) UIButton *moreTabBarButton;
@property (retain, nonatomic) UIButton *personalTabBarButton;

@property (retain, nonatomic) UILabel *sliderLabel;
@property (retain, nonatomic) UIView *backgroundTabBarButtonView;

@end
