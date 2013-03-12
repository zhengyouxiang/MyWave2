//
//  LeftGroupViewController.h
//  MyWave2
//
//  Created by youngsing on 13-3-7.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftGroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *groupClassifyArray;
}

@property (retain, nonatomic) UITableView* tableView;

@end
