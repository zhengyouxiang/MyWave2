//
//  WeiboConnectManager.m
//  MyWave2
//
//  Created by youngsing on 13-3-7.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "WeiboConnectManager.h"
#import "YSAppDelegate.h"
#import "WeiboDataManager.h"
#import "SinaWeibo.h"

@implementation WeiboConnectManager

- (void)dealloc
{
    [resultCallbackBlock release];
    resultCallbackBlock = nil;
    
    [failCallbackBlock release];
    failCallbackBlock = nil;
    
    [super dealloc];
}

#pragma mark - Custom Methods
- (SinaWeibo *)sinaweibo
{
    YSAppDelegate *delegate = (YSAppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.sinaweibo;
}

- (void)getDataFromWeiboWithURL: (NSString *)UrlString params: (NSDictionary *)aDic httpMethod: (NSString *)httpMethod
{
    SinaWeibo *sinaweibo = [self sinaweibo];
    NSLog(@"%@", UrlString);
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:aDic];
    [sinaweibo requestWithURL:UrlString
                       params:mutableParams
                   httpMethod:httpMethod
                     delegate:self];
}

#pragma mark - SinaWeiboRequest Delegate
- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if (failCallbackBlock)
        failCallbackBlock(request, error);
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    [[WeiboDataManager share] handleBackRequest:request withData:result];
    if (resultCallbackBlock)
        resultCallbackBlock(request, result);
}

#pragma mark - MyBlock
- (void)setResultCallbackBlock:(RequestCallbackBasicBlock)block
{
    if (resultCallbackBlock != block)
    {
        Block_release(resultCallbackBlock);
        resultCallbackBlock = Block_copy(block);
    }
}

- (void)setFailCallbackBlock:(RequestCallbackBasicBlock)block
{
    if (failCallbackBlock != block)
    {
        Block_release(failCallbackBlock);
        failCallbackBlock = Block_copy(block);
    }
}

@end
