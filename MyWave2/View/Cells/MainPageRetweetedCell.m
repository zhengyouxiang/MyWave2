//
//  MainPageRetweetedCell.m
//  MyWave
//
//  Created by youngsing on 13-1-19.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "MainPageRetweetedCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainPageRetweetedCell
@synthesize avatarImageView, userNameLabel, textLabel;

@synthesize retweetedMainView, retweetedUserNameLabel, retweetedTextLabel, resizeImageView;

@synthesize postTimeLabel, sourceTipsLabel, sourceLabel;

@synthesize verifiedImageView;

@synthesize retweetedCountImageView, retweetedCountLabel, commentCountImageView, commentCountLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //用户头像
        avatarImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)] autorelease];
        [self.contentView addSubview:avatarImageView];
        
        verifiedImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(43, 46.5, 17, 17)] autorelease];
        [self.contentView addSubview:verifiedImageView];
        
        //用户名
        userNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60, 5, 140, 20)] autorelease];
        userNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        [self.contentView addSubview:userNameLabel];
        
        //转发数
        retweetedCountImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(220, 10, 12, 12)] autorelease];
        retweetedCountImageView.image = [UIImage imageNamed:@"timeline_retweet_count_icon.png"];
        [self.contentView addSubview:retweetedCountImageView];
        
        retweetedCountLabel = [[[UILabel alloc] initWithFrame:CGRectMake(235, 6, 30, 20)] autorelease];
        retweetedCountLabel.font = FontOFHelvetica9;
        [self.contentView addSubview:retweetedCountLabel];
        
        //评论数
        commentCountImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(270, 10, 12, 12)] autorelease];
        commentCountImageView.image = [UIImage imageNamed:@"timeline_comment_count_icon.png"];
        [self.contentView addSubview:commentCountImageView];
        
        commentCountLabel = [[[UILabel alloc] initWithFrame:CGRectMake(285, 6, 30, 20)] autorelease];
        commentCountLabel.font = FontOFHelvetica9;
        [self.contentView addSubview:commentCountLabel];
        
        //博文
        textLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(60, 30, 255, 0)] autorelease];
        textLabel.underlineLinks = NO;
        [self.contentView addSubview:textLabel];
                
        retweetedMainView = [[[UIView alloc] initWithFrame:CGRectMake(60, 35, 260, 35)] autorelease];
        retweetedMainView.layer.cornerRadius = 8.0f;
        retweetedMainView.layer.masksToBounds = YES;
//        retweetedMainView.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:0.4] CGColor];
//        retweetedMainView.layer.borderWidth = 1.0f;
        
        resizeImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(-5, 0, 260, 125)] autorelease];
        UIImage *resizeImage = [[UIImage imageNamed:@"timeline_rt_border_9.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 30, 10, 10)];
        [resizeImageView setImage:resizeImage];
        [retweetedMainView addSubview:resizeImageView];
        [retweetedMainView sendSubviewToBack:resizeImageView];

        retweetedUserNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 5, 180, 20)] autorelease];
        retweetedUserNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        retweetedUserNameLabel.backgroundColor = [UIColor clearColor];
        [retweetedMainView addSubview:retweetedUserNameLabel];
                
        retweetedTextLabel = [[[OHAttributedLabel alloc] initWithFrame:CGRectMake(5, 30, 250, 0)] autorelease];
        retweetedTextLabel.underlineLinks = NO;
        retweetedTextLabel.backgroundColor = [UIColor clearColor];
        [retweetedMainView addSubview:retweetedTextLabel];
        
        [self.contentView addSubview:retweetedMainView];
                
        postTimeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60, 75, 80, 20)] autorelease];
        postTimeLabel.textColor = [UIColor colorWithRed:(120./255) green:(200./255) blue:(225./255) alpha:1.0];
        postTimeLabel.font = FontOFHelvetica11;
        [self.contentView addSubview:postTimeLabel];
        
        sourceTipsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(145, 75, 25, 20)] autorelease];
        sourceTipsLabel.text = @"来自";
        sourceTipsLabel.font = FontOFHelvetica11;
        [self.contentView addSubview:sourceTipsLabel];
        
        sourceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(175, 75, 140, 20)] autorelease];
        sourceLabel.textColor = [UIColor colorWithRed:(120./255) green:(200./255) blue:(225./255) alpha:1.0];
        sourceLabel.font = FontOFHelvetica11;
        [self.contentView addSubview:sourceLabel];
        
        UISwipeGestureRecognizer *rightCommentSwipGesture = [[[UISwipeGestureRecognizer alloc]
                                                              initWithTarget:self
                                                              action:@selector(swipAction:)] autorelease];
        [self.contentView addGestureRecognizer:rightCommentSwipGesture];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)swipAction: (UISwipeGestureRecognizer *)aGesture
{
    CGPoint swipPosition = [aGesture locationInView:self];
    if ([_MyCelldelegate respondsToSelector:@selector(rightSwipToolViewWithCell:Position:)])
    {
        [_MyCelldelegate rightSwipToolViewWithCell:self Position:swipPosition];
    }
}

@end
