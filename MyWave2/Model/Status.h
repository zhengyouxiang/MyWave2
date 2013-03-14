//
//  Status.h
//  MyWave
//
//  Created by youngsing on 13-1-14.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OHAttributedLabel.h"

typedef enum StatuseType : NSInteger {
    MainPageBasicCellType = 0,
    MainPageBasicImageCellType,
    MainPageRetweetedCellType,
    MainPageRetweetedImageCellType,
}StatuseType;

@class User;

@interface Status : NSObject
{
    StatuseType     type;
    long long		statusId; //微博ID
	NSString		*statusStr;
    NSString        *createdAt;
    
	NSString        *text; //微博信息内容
	NSString        *source; //微博来源
	NSString        *sourceStr; //提取过的微博来源
    
    BOOL            favorited; //是否已收藏，true：是，false：否 暂未启用
    BOOL            truncated; //是否被截断，true：是，false：否
    
//    NSString		*inReplyToStatusId; //回复ID
//    NSString        *inReplyToUserId; //回复人UID
//    NSString        *inReplyToScreenName; //回复人昵称
    
	NSString        *thumbnailPic; //缩略图
	NSString        *bmiddlePic; //中型图片
	NSString        *originalPic; //原始图片
    
//    geo   //地理信息字段
    
    User            *user; //微博作者的用户信息字段信息
    
	Status          *retweetedStatus; //被转发的原微博信息字段，当该微博为转发微博时返回
    
    int             attitudesCount; //表态数
    int				commentsCount; // 评论数
	int				repostsCount; // 转发数
    
    BOOL            hasImage;
    
    BOOL            hasRetwitter;
    BOOL            hasRetwitterImage;
    
    UIImage         *avaterImage;
    UIImage         *statusThumbnailImage;
}

@property (nonatomic, assign) StatuseType   type;
@property (nonatomic, assign) long long     statusId;
@property (nonatomic, retain) NSString      *statusStr;
@property (nonatomic, retain) NSString      *createdAt;
@property (nonatomic, retain) NSString      *createdAtCal;

@property (nonatomic, retain) NSString      *text;
@property (nonatomic, retain) NSString      *source;
@property (nonatomic, retain) NSString      *sourceStr;

@property (nonatomic, assign) BOOL          favorited;
@property (nonatomic, assign) BOOL          truncated;

//@property (nonatomic, retain) NSString      *inReplyToStatusId;
//@property (nonatomic, retain) NSString      *inReplyToUserId;
//@property (nonatomic, retain) NSString      *inReplyToScreenName;

@property (nonatomic, retain) NSString      *thumbnailPic;
@property (nonatomic, retain) NSString      *bmiddlePic;
@property (nonatomic, retain) NSString      *originalPic;

@property (nonatomic, retain) User          *user;

@property (nonatomic, retain) Status        *retweetedStatus;

@property (nonatomic, assign) int           attitudesCount;
@property (nonatomic, assign) int           commentsCount;
@property (nonatomic, assign) int           repostsCount;

@property (nonatomic, assign) BOOL          hasRetwitter;
@property (nonatomic, assign) BOOL          hasRetwitterImage;
@property (nonatomic, assign) BOOL          hasImage;

@property (nonatomic, retain) UIImage       *avaterImage;
@property (nonatomic, retain) UIImage       *statusThumbnailImage;

@property (nonatomic, assign) int           totalHeight;
@property (nonatomic, assign) int           textHeight;
@property (nonatomic, assign) int           retweetedTextHeight;
@property (nonatomic, retain) NSAttributedString *attString;
@property (nonatomic, retain) NSMutableArray  *images;

@property (nonatomic, retain) NSArray       *users;
@property (nonatomic, retain) NSArray       *topics;

@property (nonatomic, retain) UIImageView   *postImageView;
@property (nonatomic, retain) UIImageView   *postOriginImageView;
@property (nonatomic, retain) UIImageView   *retweetImageView;
@property (nonatomic, retain) UIImageView   *retweetOriginImageView;

@property (nonatomic, assign) int           detailTotalHeight;
@property (nonatomic, assign) int           detailTextHeight;
@property (nonatomic, assign) int           detailRetweetedTextHeight;
@property (nonatomic, assign) int           detailRepostTextHeight;

- (Status *) initWithDictionary: (NSDictionary *)dic;
+ (Status *) statusWithDictionary: (NSDictionary *)dic;

@end
