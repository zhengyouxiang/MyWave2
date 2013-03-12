//
//  WeiboDataManager.m
//  MyWave
//
//  Created by youngsing on 13-1-12.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "WeiboDataManager.h"
#import "SinaWeiboRequest.h"
#import "Status.h"
#import "User.h"
#import "Comment.h"

@interface WeiboDataManager ()

@end

@implementation WeiboDataManager

static WeiboDataManager *weiboDataManager = nil;

+ (id)share
{
    if (weiboDataManager == nil)
    {
        weiboDataManager = [[WeiboDataManager alloc] init];
    }
    return weiboDataManager;
}

-(void)dealloc
{
    [cacheWeiboDataArray release];
    [weiboDataManager release];
    [requestMatchingArray release];
    [_weiboDataArray release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        self.weiboDataArray = [NSMutableArray array];
        cacheWeiboDataArray = [[NSMutableArray alloc] init];
        requestMatchingArray = [[NSMutableArray alloc] initWithObjects:
                                @"https://open.weibo.cn/2/statuses/home_timeline.json",     //0
                                @"https://open.weibo.cn/2/comments/show.json",              //1
                                @"https://open.weibo.cn/2/statuses/repost_timeline.json",   //2
                                @"https://open.weibo.cn/2/statuses/user_timeline.json",     //3
                                nil];
    }
    return self;
}

- (void)handleBackRequest:(SinaWeiboRequest *)request withData:(id)data
{
    int index = [requestMatchingArray indexOfObject:request.url];
    switch (index)
    {
        case 0:
        {
            [self handleHome_TimeLineWithRequest:request Data:(NSDictionary *)data];
            break;
        }
        case 1:
        {
            [self handleCommentWithRequest:request Data:data];
            break;
        }
        case 2:
        {
            [self handleRepostWithRequest:request Data:data];
            break;
        }
        case 3:
        {
            [self handleUserTimelineWithRequset:request Data:data];
            break;
        }
        default:
            break;
    }

}

#pragma mark - Archiver Methods
- (void)writeCacheWeiboDataToFile
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"cacheWeiboData"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        [fm createFileAtPath:path contents:nil attributes:nil];
    }
    NSMutableData *cacheWeiboMutableData = [[[NSMutableData alloc] init] autorelease];
    NSKeyedArchiver *arch = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:cacheWeiboMutableData] autorelease];
    [arch encodeObject:cacheWeiboDataArray forKey:@"cacheWeiboDataArray"];
    [arch finishEncoding];
    [cacheWeiboMutableData writeToFile:path atomically:YES];
}

- (void)loadCacheWeiboDataFromFile
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"cacheWeiboData"];
    NSData *cacheWeiboData = [[[NSData alloc] initWithContentsOfFile:path] autorelease];
    NSKeyedUnarchiver *unarch = [[[NSKeyedUnarchiver alloc] initForReadingWithData:cacheWeiboData] autorelease];
    cacheWeiboDataArray = [unarch decodeObjectForKey:@"cacheWeiboDataArray"];
    [unarch finishDecoding];
    for (NSDictionary *dict in cacheWeiboDataArray)
    {
        Status *statusCell = [[[Status alloc] initWithDictionary:dict] autorelease];
        [self.weiboDataArray addObject:statusCell];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadCacheSuccess" object:self];
}

#pragma mark - Custom Methods
- (void)handleHome_TimeLineWithRequest:(SinaWeiboRequest *)request Data: (NSDictionary *)aDict
{
    if (aDict)
    {
        NSArray *receiveDataArray = [aDict objectForKey:@"statuses"];
        
        [self.weiboDataArray removeAllObjects];
        for (NSDictionary *dict in receiveDataArray)
        {
            Status *statusCell = [[[Status alloc] initWithDictionary:dict] autorelease];
            [self.weiboDataArray addObject:statusCell];
        }
        
        if ([request.params objectForKey:@"max_id"])
        {
            
            NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:receiveDataArray];
            NSString *originId = [[cacheWeiboDataArray lastObject] valueForKey:@"idstr"];
            NSString *newId = [[tmpArray objectAtIndex:0] valueForKey:@"idstr"];
            if ([originId isEqualToString:newId])
            {
                [tmpArray removeObjectAtIndex:0];
            }
            [cacheWeiboDataArray addObjectsFromArray:tmpArray];
        }
        else if ([request.params objectForKey:@"since_id"])
        {
            [cacheWeiboDataArray insertObjects:receiveDataArray
                                     atIndexes:[NSIndexSet indexSetWithIndexesInRange:
                                                NSMakeRange(0, receiveDataArray.count)]];
        }
        else
        {
            [cacheWeiboDataArray addObjectsFromArray:receiveDataArray];
        }
        
        [self writeCacheWeiboDataToFile];
    }
    else
    {
        NSLog(@"数据请求有误");
    }
}

- (void)handleCommentWithRequest:(SinaWeiboRequest *)request Data: (NSDictionary *)aDict
{
    if (aDict)
    {
        NSArray *receiveDataArray = [aDict objectForKey:@"comments"];
        
        if (receiveDataArray.count)
        {
            [self.weiboDataArray removeAllObjects];
            for (NSDictionary *dict in receiveDataArray)
            {
                Comment *commentCell = [[[Comment alloc] initWithDictionary:dict] autorelease];
                [self.weiboDataArray addObject:commentCell];
            }
        }
        else
        {
            [self.weiboDataArray removeAllObjects];
        }
    }
}

- (void)handleRepostWithRequest:(SinaWeiboRequest *)request Data: (NSDictionary *)aDict
{
    if (aDict)
    {
        NSArray *receiveDataArray = [aDict objectForKey:@"reposts"];
        
        if (receiveDataArray.count)
        {
            [self.weiboDataArray removeAllObjects];
            for (NSDictionary *dict in receiveDataArray)
            {
                Status *repostStatusCell = [[[Status alloc] initWithDictionary:dict] autorelease];
                [self.weiboDataArray addObject:repostStatusCell];
            }
        }
        else
        {
            [self.weiboDataArray removeAllObjects];
        }
    }
}

- (void)handleUserTimelineWithRequset:(SinaWeiboRequest *)request Data: (NSDictionary *)aDict
{
    if (aDict.count)
    {
        NSArray *receiveDataArray = [aDict objectForKey:@"statuses"];
        
        if (receiveDataArray.count)
        {
            [self.weiboDataArray removeAllObjects];
            for (NSDictionary *dict in receiveDataArray)
            {
                Status *repostStatusCell = [[[Status alloc] initWithDictionary:dict] autorelease];
                [self.weiboDataArray addObject:repostStatusCell];
            }
        }
        else
        {
            [self.weiboDataArray removeAllObjects];
        }
    }
    else
    {
        NSLog(@"%s::::Data Error", __func__);
    }
}


@end
