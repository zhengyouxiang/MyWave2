//
//  Status.m
//  MyWave
//
//  Created by youngsing on 13-1-14.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "Status.h"
#import "User.h"
#import "MarkupParser.h"
#import "NSAttributedString+Attributes.h"
#import "RegexKitLite.h"

@interface Status ()

//进行各种参数的配置和效果的配置
- (NSAttributedString *)creatAttributedLabel:(NSString *)o_text;
//进行表情的处理
- (NSString *)transformString:(NSString *)originalStr;

@end

@implementation Status

@synthesize type;

@synthesize statusId, statusStr, createdAt, createdAtCal;

@synthesize text, source, sourceStr;

@synthesize favorited, truncated;

//@synthesize inReplyToScreenName, inReplyToStatusId, inReplyToUserId;

@synthesize thumbnailPic, bmiddlePic, originalPic;

@synthesize user;

@synthesize retweetedStatus;

@synthesize attitudesCount, commentsCount, repostsCount;

@synthesize hasImage, hasRetwitter, hasRetwitterImage;

@synthesize avaterImage, statusThumbnailImage;

@synthesize attString, images, textHeight, totalHeight, users, topics, retweetedTextHeight;

@synthesize postImageView, retweetImageView, postOriginImageView, retweetOriginImageView;

@synthesize detailTextHeight, detailRetweetedTextHeight, detailRepostTextHeight, detailTotalHeight;

#pragma mark - Init
- (Status *)initWithDictionary:(NSDictionary*)dic
{
    if (self = [super init])
    {
        statusId    = [[dic objectForKey:@"id"] longLongValue];
        statusStr   = [[dic objectForKey:@"idstr"] retain];
//        createdAt   = [[self timestamp:[dic objectForKey:@"created_at"]] retain];
        createdAt = [[dic objectForKey:@"created_at"] retain];
        createdAtCal = [[self timestamp:createdAt] retain];
        
        text = [[dic objectForKey:@"text"] retain];
        source = [[dic objectForKey:@"source"] retain];
        NSRange range = [source rangeOfString:@">"];
        if (range.location != NSNotFound)
        {
            sourceStr = [source substringFromIndex:range.location + 1];
            sourceStr = [sourceStr substringToIndex:[sourceStr rangeOfString:@"<"].location];
            [sourceStr retain];
        }
        
        favorited = [[dic objectForKey:@"favorited"] boolValue];
        truncated = [[dic objectForKey:@"truncated"] boolValue];
        
//        inReplyToStatusId   = [[dic objectForKey:@"in_reply_to_status_id"] retain];
//        inReplyToUserId     = [[dic objectForKey:@"in_reply_to_user_id"] retain];
//        inReplyToScreenName = [[dic objectForKey:@"in_reply_to_screen_name "] retain];
        
        thumbnailPic    = [[dic objectForKey:@"thumbnail_pic"] retain];
        bmiddlePic      = [[dic objectForKey:@"bmiddle_pic"] retain];
        originalPic     = [[dic objectForKey:@"original_pic"] retain];
        
        NSDictionary *userDict = [dic objectForKey:@"user"];
        if (userDict)
            user = [[User alloc] initWithDictionary:userDict];
        
        NSDictionary *retweetedStatusDict = [dic objectForKey:@"retweeted_status"];
        if (retweetedStatusDict)
            retweetedStatus = [[Status alloc] initWithDictionary:retweetedStatusDict];
        
        attitudesCount  = [[dic objectForKey:@"attitudes_count"] intValue];
        repostsCount    = [[dic objectForKey:@"reposts_count"] intValue];
        commentsCount   = [[dic objectForKey:@"comments_count"] intValue];
        
        if (thumbnailPic.length)
            hasImage = YES;
        else
            hasImage = NO;
        
        if (retweetedStatus.text.length)
            hasRetwitter = YES;
        else
            hasRetwitter = NO;
        
        if (retweetedStatus.thumbnailPic.length)
            hasRetwitterImage = YES;
        else
            hasRetwitterImage = NO;
        
        if (hasImage)
            type = MainPageBasicImageCellType;
        else if(hasRetwitterImage)
            type = MainPageRetweetedImageCellType;
        else if(hasRetwitter)
            type = MainPageRetweetedCellType;
        else
            type = MainPageBasicCellType;
        

        attString = [[self creatAttributedLabel:text] retain];
        users = [[self regexUsers:attString.string] retain];
        topics = [[self regexTopics:attString.string] retain];
        
        postImageView = [[UIImageView alloc] init];
        retweetImageView = [[UIImageView alloc] init];
        postOriginImageView = [[UIImageView alloc] init];
        retweetOriginImageView = [[UIImageView alloc] init];
        
        textHeight = [self calTextHeight:attString];
        retweetedTextHeight = [self calTextHeight:retweetedStatus.attString];
        
        detailTextHeight = [self calDetailTextHeight:attString];
        detailRetweetedTextHeight = [self calDetailTextHeight:retweetedStatus.attString];
        detailRepostTextHeight = [self calRepostTextHeight:attString];
        detailTotalHeight = 5 + 20 + 5 + detailRepostTextHeight + 5;
        detailTotalHeight = detailTotalHeight < 40 ? 40 : detailTotalHeight;
        
        totalHeight = 20 + textHeight + 20;
        if (hasImage)
            totalHeight = totalHeight + 80 + 5*4;
        else if (hasRetwitterImage)
            totalHeight = totalHeight + 20 + retweetedTextHeight + 80 + 5*8;
        else if (hasRetwitter)
            totalHeight = totalHeight + 20 + retweetedTextHeight + 5*7;
        else
            totalHeight = totalHeight + 5*3;
        
    }
    return self;
}

+ (Status*)statusWithDictionary:(NSDictionary*)dic
{
	return [[[Status alloc] initWithDictionary:dic] autorelease];
}

- (void)dealloc
{
    [statusStr release];
    [createdAt release];
    
    [text release];
    [source release];
    [sourceStr release];
    
    //    [inReplyToScreenName release];
    //    [inReplyToStatusId release];
    //    [inReplyToUserId release];
    
    [thumbnailPic release];
    [bmiddlePic release];
    [originalPic release];
    
    [user release];
    
    [retweetedStatus release];
    
    [avaterImage release];
    [statusThumbnailImage release];
    
    [attString release];
    [images release];
    
	[super dealloc];
}

#pragma mark - RichText Methods
-(NSAttributedString *)creatAttributedLabel:(NSString *)o_text
{
    //进行表情的html转化
    NSString *_text = [self transformString:o_text];
    
    
    //设置字体的html格式颜色
    _text = [NSString stringWithFormat:@"<font color='black'>%@",_text];
    
    //进行html样式转化为AttributedString
    MarkupParser* p = [[[MarkupParser alloc] init] autorelease];
    NSMutableAttributedString* _attString = [p attrStringFromMarkup:_text];
    
    //深复制，防止之前的内容变动影响后面的字符串
    _attString = [NSMutableAttributedString attributedStringWithAttributedString:_attString];
    
    images = [[NSMutableArray alloc] initWithArray:p.images];
    
    //把字变细
    //原理就是在字体外围画一圈白色的边框
    //widthValue的绝对值越大越细
    CGFloat widthValue = -2;
    CFNumberRef strokeWidth = CFNumberCreate(NULL,kCFNumberFloatType,&widthValue);
    [_attString addAttribute:(NSString*)(kCTStrokeWidthAttributeName) value:(id)strokeWidth range:NSMakeRange(0,[_attString.string length])];
    [_attString addAttribute:(NSString*)(kCTStrokeColorAttributeName) value:(id)[[UIColor whiteColor]CGColor] range:NSMakeRange(0,[_attString.string length])];
    
    //设置字体字号
    [_attString setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
    return (NSAttributedString *)_attString;
}

- (NSString *)transformString:(NSString *)originalStr
{
    //正则匹配 [**] 表情
    NSString *_text = originalStr;
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSArray *array_emoji = [_text componentsMatchedByRegex:regex_emoji];
    
    //找到表情文字和face文件名之间的转化
    //    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"emotionImage.plist"];
    //    NSDictionary *m_EmojiDic = [[[NSDictionary alloc] initWithContentsOfFile:filePath] autorelease];
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"emoticons.plist"];
    NSArray *m_EmojiArr = [[[NSArray alloc] initWithContentsOfFile:filePath] autorelease];
    
    //进行替换
    if ([array_emoji count])
    {
        for (NSString *str in array_emoji)
        {
            NSRange range = [_text rangeOfString:str];
            //            NSString *i_transCharacter = [m_EmojiDic objectForKey:str];
            NSString *i_transCharacter =nil;
            for (NSDictionary * emo in m_EmojiArr)
            {
                NSString * str_name = [emo valueForKey:@"chs"];
                if ([str isEqualToString:str_name])
                {
                    i_transCharacter = [emo valueForKey:@"png"];
                    break;
                }
            }
            if (i_transCharacter)
            {
                //可调表情大小
                NSString *imageHtml = [NSString stringWithFormat:@"<img src='%@' width='16' height='16'>",i_transCharacter];
                _text = [_text stringByReplacingCharactersInRange:NSMakeRange(range.location, [str length]) withString:imageHtml];
            }
        }
    }
    
    return _text;
}

-(NSArray *)regexUsers:(NSString *)o_text
{
    //@"@[^\\.^\\,^:^;^!^\\?^\\s^#^@^。^，^：^；^！^？]+"
    //正则匹配 @人名
    NSString *_text = o_text;
    NSString *regex_user = @"@[^\\.^\\,^:^;^!^\\?^\\s^#^@^。^，^：^；^！^？]+";
    NSArray *array_user = [_text componentsMatchedByRegex:regex_user];
    return array_user;
}


-(NSArray *)regexTopics:(NSString *)o_text
{
    //@"#([^\#|.]+)\#"
    //正则匹配话题 ##
    NSString *_text = o_text;
    NSString *regex_topic = @"#([^\\#|.]+)\\#";
    NSArray *array_topic = [_text componentsMatchedByRegex:regex_topic];
    return array_topic;
    
}

#pragma mark - Custom Methods
- (NSString *)timestamp : (NSString *)createdAtFromDic
{
    //输入的时间字符串格式为 @"Tue Jan 15 23:45:15 +0800 2013"
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
    NSString *_timestamp;
    
    struct tm createdAtTimeStruct;
    time_t createdAtTM;
    time_t now;
    time(&now);
    
    strptime([createdAtFromDic UTF8String], "%a %b %d %H:%M:%S %z %Y", &createdAtTimeStruct);
    createdAtTM = mktime(&createdAtTimeStruct);
    int distance = (int)difftime(now, createdAtTM);

    if (distance < 0)
        distance = 0;
    
    if (distance < 60)
        _timestamp = [NSString stringWithFormat:@"%d秒前", distance];
    else if (distance < 3600)
        _timestamp = [NSString stringWithFormat:@"%d分钟前", distance/60];
    else
        _timestamp = [NSString stringWithFormat:@"%d月%d日%d:%d",
                      createdAtTimeStruct.tm_mon + 1,   createdAtTimeStruct.tm_mday,
                      createdAtTimeStruct.tm_hour,      createdAtTimeStruct.tm_min];

    return _timestamp;
}

- (int)calTextHeight: (NSAttributedString *)calAttString
{
    int width = 0;
    
    if ([calAttString isEqual:attString])
        width = 255;
    else if ([calAttString isEqual:retweetedStatus.attString])
        width = 250;
    
    CGSize size = [calAttString sizeConstrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
    return size.height;
}

- (int)calDetailTextHeight: (NSAttributedString *)calAttString
{
    CGSize size = [calAttString sizeConstrainedToSize:CGSizeMake(310, CGFLOAT_MAX)];
    return size.height;
}

- (int)calRepostTextHeight: (NSAttributedString *)calAttString
{
    CGSize size = [calAttString sizeConstrainedToSize:CGSizeMake(275, CGFLOAT_MAX)];
    return size.height;
}

@end
