//
//  PersonalPageViewController.h
//  MyWave2
//
//  Created by youngsing on 13-3-7.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "OHAttributedLabel.h"
#import "MainPageBasicImageCell.h"
#import "MainPageRetweetedImageCell.h"
#import "Reachability.h"
#import "User.h"

@interface PersonalPageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, OHAttributedLabelDelegate, MyCellDelegate>
{
    NSMutableArray* statusesArray;
    NSMutableArray* viewInCellArray;
    EGORefreshTableHeaderView* _refreshTableHeaderView;
    BOOL isLoading;
    UIImageView* avatorImageView;
    NetworkStatus nowNewWorkStatus;
}

@property (nonatomic, retain) User* primaryUser;
@property (nonatomic, retain) UITableView* tableView;

@end
