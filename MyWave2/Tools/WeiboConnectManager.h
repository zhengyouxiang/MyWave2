//
//  WeiboConnectManager.h
//  MyWave2
//
//  Created by youngsing on 13-3-7.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SinaWeiboRequest.h"

@class SinaWeibo;

typedef void(^RequestCallbackBasicBlock) (SinaWeiboRequest* request, id obj);

@interface WeiboConnectManager : NSObject <SinaWeiboRequestDelegate>
{
    RequestCallbackBasicBlock resultCallbackBlock;
    RequestCallbackBasicBlock failCallbackBlock;
}

- (SinaWeibo* ) sinaweibo;
- (void) setResultCallbackBlock: (RequestCallbackBasicBlock)block;
- (void) setFailCallbackBlock: (RequestCallbackBasicBlock)block;

- (void)getDataFromWeiboWithURL: (NSString *)UrlString params: (NSDictionary *)aDic httpMethod: (NSString *)httpMethod;

@end
