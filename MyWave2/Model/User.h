//
//  User.h
//  MyWave
//
//  Created by youngsing on 13-1-14.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GenderUnkown = 0,
    GenderMale,
    GenderFemale
} Gender;

//typedef enum {
//    VerifiedPersonal = 1
//#warning unwrite
//} VerifiedType;

@interface User : NSObject
{
	long long       userId; //用户UID
	NSString        *userStr;
	NSString        *screenName; //微博昵称
    NSString        *createdAt; //创建时间
    
	int             province; //省份编码（参考省份编码表）
	int             city; //城市编码（参考城市编码表）
	NSString        *location; //地址
    
	NSString        *description; //个人描述
	NSString        *url; //用户博客地址
	NSString        *profileImageUrl; //自定义图像
	NSString        *profileLargeImageUrl; //大图像地址
	NSString        *domain; //用户个性化URL
	Gender          gender; //m--男, f--女, n--未知
    
	int             followersCount; //粉丝数
    int             friendsCount; //关注数
    int             statusesCount; //微博数
    int             favoritesCount; //收藏数
    
    BOOL            verified; //加V标示，是否微博认证用户
    NSString        *verifiedReason;
//    VerifiedType    verifiedType; //暂不支持
    
    UIImage         *avatarImage;//头像image
}

@property (nonatomic, assign) long long     userId;
@property (nonatomic, retain) NSString      *userStr;
@property (nonatomic, retain) NSString      *screenName;
@property (nonatomic, retain) NSString      *atScreenName;
@property (nonatomic, assign) NSString      *createdAt;

@property (nonatomic, assign) int           province;
@property (nonatomic, assign) int           city;
@property (nonatomic, retain) NSString      *location;

@property (nonatomic, retain) NSString      *description;
@property (nonatomic, retain) NSString      *url;
@property (nonatomic, retain) NSString      *profileImageUrl;
@property (nonatomic, retain) NSString      *profileLargeImageUrl;
@property (nonatomic, retain) NSString      *domain;
@property (nonatomic, assign) Gender        gender;

@property (nonatomic, assign) int           followersCount;
@property (nonatomic, assign) int           friendsCount;
@property (nonatomic, assign) int           statusesCount;
@property (nonatomic, assign) int           favoritesCount;
@property (nonatomic, assign) int           topicCount;

@property (nonatomic, assign) BOOL          verified;
@property (nonatomic, assign) int           verifiedType;
@property (nonatomic, copy)   NSString      *verifiedReason;
//@property (nonatomic, assign) VerifiedType  verifiedType;

@property (nonatomic, retain) UIImage       *avatarImage;
@property (nonatomic, retain) NSIndexPath   *cellIndexPath;





- (User*)initWithDictionary:(NSDictionary*)dic;
+ (User*)userWithDictionary:(NSDictionary*)dic;

//- (void)updateWithDictionary:(NSDictionary*)dic;

@end
