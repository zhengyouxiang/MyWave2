//
//  WeiboDataManager.h
//  MyWave
//
//  Created by youngsing on 13-1-12.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SinaWeiboRequest;

@interface WeiboDataManager : NSObject
{
    NSMutableArray *requestMatchingArray;
    NSMutableArray *cacheWeiboDataArray;
}

@property (retain, nonatomic) NSMutableArray *weiboDataArray;

+ (id)share;
- (void)loadCacheWeiboDataFromFile;
- (void)handleBackRequest: (SinaWeiboRequest *)request withData: (id)data;

@end
