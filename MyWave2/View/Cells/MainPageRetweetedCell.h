//
//  MainPageRetweetedCell.h
//  MyWave
//
//  Created by youngsing on 13-1-19.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "MyCellDelegate.h"

@interface MainPageRetweetedCell : UITableViewCell

@property (assign, nonatomic)   id<MyCellDelegate>  MyCelldelegate;

@property (retain, nonatomic)   UIImageView         *avatarImageView;
@property (retain, nonatomic)   UILabel             *userNameLabel;
@property (retain, nonatomic)   OHAttributedLabel   *textLabel;

@property (retain, nonatomic)   UIView              *retweetedMainView;
@property (retain, nonatomic)   UILabel             *retweetedUserNameLabel;
@property (retain, nonatomic)   OHAttributedLabel   *retweetedTextLabel;
@property (retain, nonatomic)   UIImageView         *resizeImageView;

@property (retain, nonatomic)   UILabel             *postTimeLabel;
@property (retain, nonatomic)   UILabel             *sourceLabel;
@property (retain, nonatomic)   UILabel             *sourceTipsLabel;

@property (retain, nonatomic)   UIImageView         *verifiedImageView;

@property (retain, nonatomic)   UIImageView         *retweetedCountImageView;
@property (retain, nonatomic)   UILabel             *retweetedCountLabel;
@property (retain, nonatomic)   UIImageView         *commentCountImageView;
@property (retain, nonatomic)   UILabel             *commentCountLabel;

@end
