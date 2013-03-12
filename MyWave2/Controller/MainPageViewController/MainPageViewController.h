//
//  MainPageViewController.h
//  MyWave
//
//  Created by youngsing on 13-1-25.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "OHAttributedLabel.h"
#import "MainPageBasicImageCell.h"
#import "MainPageRetweetedImageCell.h"
#import "Reachability.h"
#import "CommentView.h"

@interface MainPageViewController : UIViewController <EGORefreshTableHeaderDelegate, OHAttributedLabelDelegate, MyCellDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *statusesArray;
    EGORefreshTableHeaderView *_refreshTableHeaderView;
    BOOL isLoading;
    UILabel *loadingLabel;
    NetworkStatus nowNewWorkStatus;
//    CommentView *commentView;
}

@property (retain, nonatomic) UITableView *tableView;

@end
