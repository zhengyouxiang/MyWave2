//
//  User.m
//  MyWave
//
//  Created by youngsing on 13-1-14.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize userId, userStr, screenName, createdAt, atScreenName;

@synthesize province, city, location;

@synthesize description, url, profileImageUrl, profileLargeImageUrl, domain, gender;

@synthesize followersCount, friendsCount, statusesCount, favoritesCount, topicCount;

@synthesize verified, verifiedType, verifiedReason;

@synthesize cellIndexPath;

@synthesize avatarImage;

- (User*)initWithDictionary:(NSDictionary*)dic
{
    if (self = [super init])
    {
        userId      = [[dic objectForKey:@"id"] longLongValue];
        userStr		= [[dic objectForKey:@"idstr"] retain];
        screenName  = [[dic objectForKey:@"screen_name"] retain];
        atScreenName= [[NSString alloc] initWithFormat:@"@%@", screenName];
        createdAt   = [[self timeStamp:[dic objectForKey:@"created_at"]] retain];
        
        province    = [[dic objectForKey:@"province"] intValue];
        city        = [[dic objectForKey:@"city"] intValue];
        location    = [[dic objectForKey:@"location"] retain];
        
        description             = [[dic objectForKey:@"description"] retain];
        url                     = [[dic objectForKey:@"url"] retain];
        profileImageUrl         = [[dic objectForKey:@"profile_image_url"] retain];
        profileLargeImageUrl    = [[dic objectForKey:@"avatar_large"] retain];
        domain                  = [[dic objectForKey:@"domain"] retain];
        
        NSString *genderInfo = [dic objectForKey:@"gender"];
        if ([genderInfo isEqualToString:@"f"])
            gender = GenderFemale;
        else if ([genderInfo isEqualToString:@"m"])
            gender = GenderMale;
        else
            gender = GenderUnkown;
        
        followersCount  = ([dic objectForKey:@"followers_count"] == nil) ? 0
        : [[dic objectForKey:@"followers_count"] longValue];
        friendsCount    = ([dic objectForKey:@"friends_count"] == nil) ? 0
        : [[dic objectForKey:@"friends_count"] longValue];
        statusesCount   = ([dic objectForKey:@"statuses_count"] == nil) ? 0
        : [[dic objectForKey:@"statuses_count"] longValue];
        favoritesCount  = ([dic objectForKey:@"favourites_count"] == nil) ? 0
        : [[dic objectForKey:@"favourites_count"] longValue];
        
        verified        = [[dic objectForKey:@"verified"] boolValue];
        verifiedType    = [[dic objectForKey:@"verified_type"] intValue];
        verifiedReason  = [[dic objectForKey:@"verified_reason"] retain];
        
        avatarImage = [[UIImage alloc] init];
    }
	
	return self;
}

/*
- (void)updateWithDictionary:(NSDictionary*)dic
{
//    self.avatarImage = nil;
    
	[userStr release];
    [screenName release];
    [createdAt release];
    
    [location release];
    
    [description release];
    [url release];
    [profileImageUrl release];
    [profileLargeImageUrl release];
	[domain release];
    
    [verifiedReason release];
    
    userId      = [[dic objectForKey:@"id"] longLongValue];
    userStr		= [[dic objectForKey:@"idstr"] retain];
	screenName  = [[dic objectForKey:@"screen_name"] retain];
    createdAt   = [[self timeStamp:[dic objectForKey:@"created_at"]] retain];
    
    province    = [[dic objectForKey:@"province"] intValue];
    city        = [[dic objectForKey:@"city"] intValue];
    location    = [[dic objectForKey:@"location"] retain];
    
    description             = [[dic objectForKey:@"description"] retain];
    url                     = [[dic objectForKey:@"url"] retain];
    profileImageUrl         = [[dic objectForKey:@"profile_image_url"] retain];
    profileLargeImageUrl    = [[dic objectForKey:@"avatar_large"] retain];
    domain                  = [[dic objectForKey:@"domain"] retain];
    
    NSString *genderInfo = [dic objectForKey:@"gender"];
    if ([genderInfo isEqualToString:@"f"])
        gender = GenderFemale;
    else if ([genderInfo isEqualToString:@"m"])
        gender = GenderMale;
    else
        gender = GenderUnkown;
    
    followersCount  = ([dic objectForKey:@"followers_count"] == nil) ? 0
    : [[dic objectForKey:@"followers_count"] longValue];
    friendsCount    = ([dic objectForKey:@"friends_count"] == nil) ? 0
    : [[dic objectForKey:@"friends_count"] longValue];
    statusesCount   = ([dic objectForKey:@"statuses_count"] == nil) ? 0
    : [[dic objectForKey:@"statuses_count"] longValue];
    favoritesCount  = ([dic objectForKey:@"favourites_count"] == nil) ? 0
    : [[dic objectForKey:@"favourites_count"] longValue];
    
    verified        = [[dic objectForKey:@"verified"] boolValue];
	verifiedReason  = [[dic objectForKey:@"verified_reason"] retain];
//    verifiedType    = [[dic objectForKey:@"verified_type"] intValue];
}
*/

+ (User*)userWithDictionary:(NSDictionary*)dic
{
    return [[[User alloc] initWithDictionary:dic] autorelease];
}

- (NSString *)timeStamp: (NSString *)createdAtFromDict
{
    //输入的时间字符串格式为 @"Fri Oct 28 13:44:36 +0800 2011"
    /* 转换控制符    说明
     *    %a    星期几的简写形式
     *    %A 	星期几的全称
     *    %b 	月份的简写形式
     *    %B 	月份的全称
     *    %c 	日期和时间
     *    %d 	月份中的日期,0-31
     *    %H 	小时,00-23
     *    %I 	12进制小时钟点,01-12
     *    %j 	年份中的日期,001-366
     *    %m 	年份中的月份,01-12
     *    %M 	分,00-59
     *    %p 	上午或下午
     *    %S 	秒,00-60
     *    %u 	星期几,1-7
     *    %w 	星期几,0-6
     *    %x 	当地格式的日期
     *    %X 	当地格式的时间
     *    %y 	年份中的最后两位数,00-99
     *    %Y 	年
     *    %Z 	地理时区名称
     */
//    NSString *_timeStamp = nil;
    
    struct tm createdAtTimeStruct;
    
    strptime([createdAtFromDict UTF8String], "%a %b %d %H:%M:%S %z %Y", &createdAtTimeStruct);
    
    NSString *_timeStamp = [NSString stringWithFormat:@"%d年%d月%d日",
                  createdAtTimeStruct.tm_year, createdAtTimeStruct.tm_min, createdAtTimeStruct.tm_mday];
    return _timeStamp;
}
- (void)dealloc
{
	[userStr release];
    [screenName release];
    
    [location release];
    
    [description release];
    [url release];
    [profileImageUrl release];
	[profileLargeImageUrl release];
	[domain release];
    
    [verifiedReason release];
    [cellIndexPath release];
    
   	[super dealloc];
}
@end
