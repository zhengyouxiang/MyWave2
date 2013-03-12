//
//  DetailPageCommentCell.m
//  MyWave
//
//  Created by youngsing on 13-1-24.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "DetailPageCommentCell.h"

@implementation DetailPageCommentCell
@synthesize commentDelegate;
@synthesize commentAvatarImageView, commentTextLabel, commentUserNameLabel, commentTimeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        //评论用户头像
        commentAvatarImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)] autorelease];
        UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(imageTappedAction:)] autorelease];
        [commentAvatarImageView addGestureRecognizer:tapGesture];
        commentAvatarImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:commentAvatarImageView];
        
        //评论用户名
        commentUserNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(40, 5, 180, 20)] autorelease];
        commentUserNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        [self.contentView addSubview:commentUserNameLabel];
        
        //评论时间
        commentTimeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(260, 5, 60, 20)] autorelease];
        commentTimeLabel.font = FontOFHelvetica11;
        commentTimeLabel.textAlignment = UITextAlignmentCenter;
        commentTimeLabel.textColor = [UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0];
        [self.contentView addSubview:commentTimeLabel];
        
        //评论内容
        commentTextLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(40, 30, 215, 0)] autorelease];
        commentTextLabel.underlineLinks = NO;
        [self.contentView addSubview:commentTextLabel];
        
        //评论添加按钮
        UIButton *commentReplyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commentReplyButton.frame = CGRectMake(260, 30, 40, 40);
        [self.contentView addSubview:commentReplyButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)imageTappedAction:(UITapGestureRecognizer *)aGesture
{
    if ([commentDelegate respondsToSelector:@selector(imageTappedActionWithStatusCell:)])
    {
        [commentDelegate imageTappedActionWithStatusCell:self];
    }
}

@end
