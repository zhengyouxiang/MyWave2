//
//  DetailPageCommentCell.h
//  MyWave
//
//  Created by youngsing on 13-1-24.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "MyCellDelegate.h"

@interface DetailPageCommentCell : UITableViewCell

@property (nonatomic, assign) id<MyCellDelegate> commentDelegate;
@property (nonatomic, retain) UIImageView *commentAvatarImageView;
@property (nonatomic, retain) OHAttributedLabel *commentTextLabel;
@property (nonatomic, retain) UILabel *commentUserNameLabel;
@property (nonatomic, retain) UILabel *commentTimeLabel;

@end
