//
//  MainPageBasicCell.h
//  MyWave
//
//  Created by youngsing on 13-1-18.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "MyCellDelegate.h"

@interface MainPageBasicCell : UITableViewCell

@property (assign, nonatomic)   id<MyCellDelegate>  MyCelldelegate;

@property (retain, nonatomic)   UIImageView         *avatarImageView;
@property (retain, nonatomic)   UILabel             *userNameLabel;
@property (retain, nonatomic)   OHAttributedLabel   *textLabel;
@property (retain, nonatomic)   UILabel             *postTimeLabel;
@property (retain, nonatomic)   UILabel             *sourceLabel;
@property (retain, nonatomic)   UILabel             *sourceTipsLabel;

@property (retain, nonatomic)   UIImageView         *verifiedImageView;

@property (retain, nonatomic)   UIImageView         *retweetedCountImageView;
@property (retain, nonatomic)   UILabel             *retweetedCountLabel;
@property (retain, nonatomic)   UIImageView         *commentCountImageView;
@property (retain, nonatomic)   UILabel             *commentCountLabel;

@end
