//
//  Comment.h
//  MyWave
//
//  Created by youngsing on 13-1-24.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Status;
@class User;

@interface Comment : NSObject
{
    long long		commentId; //评论ID int64
	NSString		*commentStr; //评论ID NSString
    NSString        *createdAt;
    
	NSString        *commentText; //评论信息内容
	NSString        *commentSource; //评论来源
	NSString        *commentSourceStr; //提取过的评论来源
    
    User            *user; //评论作者的用户信息字段信息
    
	Status          *replyStatus; //评论的微博信息字段
    
    int             commentTextHeight; //富文本 评论内容的高度
}

@property (nonatomic, assign) long long     commentId;
@property (nonatomic, retain) NSString      *commentStr;
@property (nonatomic, retain) NSString      *createdAt;
@property (nonatomic, retain) NSString      *createdAtCal;

@property (nonatomic, retain) NSString      *commentText;
@property (nonatomic, retain) NSString      *commentSource;
@property (nonatomic, retain) NSString      *commentSourceStr;

@property (nonatomic, retain) User          *user;

@property (nonatomic, retain) Status        *replyStatus;

@property (nonatomic, assign) int           totalHeight;
@property (nonatomic, assign) int           commentTextHeight;
//@property (nonatomic, assign) int           retweetedTextHeight;
@property (nonatomic, retain) NSAttributedString *commentAttString;
@property (nonatomic, retain) NSMutableArray  *images;

@property (nonatomic, retain) NSArray       *users;
@property (nonatomic, retain) NSArray       *topics;

- (Comment *) initWithDictionary: (NSDictionary *)dic;
+ (Comment *) commentWithDictionary: (NSDictionary *)dic;

@end