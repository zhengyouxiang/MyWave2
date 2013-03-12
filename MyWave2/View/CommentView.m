//
//  CommentView.m
//  MyWave
//
//  Created by youngsing on 13-1-27.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "CommentView.h"
#import "WeiboConnectManager.h"
#import "FeedbackTipsView.h"
#import "EmoticonsScrollView.h"

@implementation CommentView
@synthesize detailStatus, favArray;

- (id)init
{
    if (self = [super init])
    {
        toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        toolView.backgroundColor = [UIColor whiteColor];
        [self addSubview:toolView];
        
        UIView *view1 = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 106, 44)] autorelease];
        view1.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
        [toolView addSubview:view1];
        
        repostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        repostButton.frame = CGRectMake(33.5, 2, 40, 40);
        [repostButton setTitle:@"status" forState:UIControlStateNormal];
        [repostButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [repostButton setBackgroundImage:[UIImage imageNamed:@"detail_button_forward.png"] forState:UIControlStateNormal];
        [repostButton addTarget:self
                         action:@selector(commentButtonAction:)
               forControlEvents:UIControlEventTouchUpInside];
        [view1 addSubview:repostButton];
        
        UIView *view2 = [[[UIView alloc] initWithFrame:CGRectMake(107, 0, 106, 44)] autorelease];
        view2.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
        [toolView addSubview:view2];
        
        commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commentButton.frame = CGRectMake(33.5, 2, 40, 40);
        [commentButton setTitle:@"comment" forState:UIControlStateNormal];
        [commentButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [commentButton setBackgroundImage:[UIImage imageNamed:@"detail_button_comment.png"] forState:UIControlStateNormal];
        [commentButton addTarget:self
                          action:@selector(commentButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
        [view2 addSubview:commentButton];
        
        UIView *view3 = [[[UIView alloc] initWithFrame:CGRectMake(214, 0, 106, 44)] autorelease];
        view3.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
        [toolView addSubview:view3];
        
        favButton = [UIButton buttonWithType:UIButtonTypeCustom];
        favButton.frame = CGRectMake(33.5, 2, 40, 40);
        [favButton setTitle:@"fav" forState:UIControlStateNormal];
        [favButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [favButton setBackgroundImage:[UIImage imageNamed:@"detail_button_fav.png"] forState:UIControlStateNormal];
        [favButton addTarget:self
                      action:@selector(favButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
        [view3 addSubview:favButton];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [self keyboardHeightDidChanged:note];
                                                      }];
        
        favArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)dealloc
{
    [favArray release];
    [super dealloc];
}

#pragma mark - TextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    isFaceLoad = NO;
    [emoticonsScrollView removeFromSuperview];
}

-(void)textViewDidChange:(UITextView *)textView
{
    float sumLength = 0.0;
    for(int i = 0; i<[textView.text length]; ++i)
    {
        NSString *character = [textView.text substringWithRange:NSMakeRange(i, 1)];
        if([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
            ++sumLength;
        else
            sumLength += 0.5;
    }
    
    UIButton *updateButton = (UIButton *)[self viewWithTag:20000];
    if ([selectedButtonTitle isEqualToString:@"comment"])
    {
        if (sumLength > 0 && sumLength <= 140)
            updateButton.enabled = YES;
        else
            updateButton.enabled = NO;
    }
    else if ([selectedButtonTitle isEqualToString:@"status"])
    {
        if (sumLength >= 0 && sumLength <= 140)
            updateButton.enabled = YES;
        else
            updateButton.enabled = NO;
    }
    
//    numLabel.text = [NSString stringWithFormat:@"%d", 140 - (int)ceil(sumLength)];
}

#pragma mark - Custom Methods
- (void)setInputViewDidChangedFrameBlock:(InputViewDidChangedFrameBlock)block
{
    [inputViewDidChangedFrameBlock release];
    inputViewDidChangedFrameBlock = [block copy];
}

- (void)upDateFavArray
{
    WeiboConnectManager *weiboM = [WeiboConnectManager new];
    
    [weiboM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *resultDict = (NSDictionary *)obj;
            [favArray removeAllObjects];
            [favArray addObjectsFromArray:[[resultDict objectForKey:@"favorites"] valueForKey:@"status"]];

            if ([favArray containsObject:detailStatus.statusStr])
            {
                [favButton setBackgroundImage:[UIImage imageNamed:@"detail_button_fav_1.png"] forState:UIControlStateNormal];
            }
        }
        
        [weiboM release];
    }];
    
    [weiboM setFailCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        NSError *error = (NSError *)obj;
        NSLog(@"%@", [error description]);
        
        [weiboM release];
    }];
    
    [weiboM getDataFromWeiboWithURL:@"favorites/ids.json" params:nil httpMethod:@"GET"];
}

- (void)keyboardHeightDidChanged: (NSNotification *)note
{
    NSDictionary *dict = [note userInfo];
    keyBoardHeight = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;

    CGRect originFrame = self.frame;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect changeToFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 20 - keyBoardHeight - 44,
                                          320, 44);
        self.frame = changeToFrame;
    }];
    
    if (inputViewDidChangedFrameBlock)
        inputViewDidChangedFrameBlock(originFrame.origin.y - self.frame.origin.y);
}

- (void)commentButtonAction: (UIButton *)sender
{
    selectedButtonTitle = sender.titleLabel.text;
    
    commentInputView = [[[UIView alloc] initWithFrame:CGRectMake(320, 0, 320, 44)] autorelease];
    commentInputView.backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
    [self addSubview:commentInputView];
    
    UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    faceButton.frame = CGRectMake(2, 5.5, 40, 33);
    [faceButton setBackgroundImage:[UIImage imageNamed:@"compose_toolbar_6.png"] forState:UIControlStateNormal];
    [faceButton addTarget:self
                    action:@selector(faceButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [commentInputView addSubview:faceButton];
    
    UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    updateButton.tag = 20000;
    updateButton.enabled = NO;
    updateButton.frame = CGRectMake(320 - 44 + 7, 7, 30, 30);
    [updateButton setBackgroundImage:[UIImage imageNamed:@"button_icon_ok_1.png"] forState:UIControlStateNormal];
    [updateButton addTarget:self
                     action:@selector(updateCommentButtonAction:)
           forControlEvents:UIControlEventTouchUpInside];
    updateButton.enabled = NO;
    [commentInputView addSubview:updateButton];

    inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(44, 0, 232, 44)];
    inputTextView.delegate = self;
    inputTextView.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
    inputTextView.layer.cornerRadius = 8.0f;
    [commentInputView addSubview:inputTextView];
    
    [UIView animateWithDuration:0.3f animations:^{
        CGRect toolViewFrame = toolView.frame;
        toolViewFrame.origin.x = -320;
        toolView.frame = toolViewFrame;
        
        commentInputView.frame = CGRectMake(0, 0, 320, 44);
    }];
    
    if ([selectedButtonTitle isEqualToString:@"status"])
        updateButton.enabled = YES;
}

- (void)faceButtonAction: (UIButton *)sender
{
    [self endEditing:YES];
    if (!isFaceLoad)
    {
        emoticonsScrollView = [[[EmoticonsScrollView alloc] init] autorelease];
        emoticonsScrollView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320,
                                               [UIScreen mainScreen].bounds.size.height - self.frame.origin.y);
        emoticonsScrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:emoticonsScrollView];
        
        [emoticonsScrollView setFaceImageTappedBlock:^(NSString *face) {
            inputTextView.text = [inputTextView.text stringByAppendingString:face];
            [self textViewDidChange:inputTextView];
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect emoticonsFrame = emoticonsScrollView.frame;
            emoticonsFrame.origin.y = 44;
            emoticonsScrollView.frame = emoticonsFrame;
            
            CGRect selfFrame = self.frame;
            selfFrame.size.height = 44 + emoticonsScrollView.frame.size.height;
            self.frame = selfFrame;
        } completion:^(BOOL finished) {
            isFaceLoad = YES;
        }];
    }
    else
    {
        [inputTextView becomeFirstResponder];
        isFaceLoad = NO;
    }
}

- (void)updateCommentButtonAction: (UIButton *)sender
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          inputTextView.text, selectedButtonTitle,
                          detailStatus.statusStr, @"id",
                          nil];
    
    NSString *urlStr = nil;
    NSString *title = nil;
    if ([selectedButtonTitle isEqualToString:@"comment"])
    {
        urlStr = @"comments/create.json";
        title = @"评论";
    }
    else
    {
        urlStr = @"statuses/repost.json";
        title = @"转发";
    }
    
    WeiboConnectManager *weiboM = [WeiboConnectManager new];
    [weiboM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        [self removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentViewRemoved" object:self];
        
        FeedbackTipsView *feedbackView = [[[FeedbackTipsView alloc] init] autorelease];
        UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
        if (!appWindow)
            appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        [appWindow addSubview:feedbackView];
        [feedbackView showTipsViewWithText:[title stringByAppendingString:@"成功"]];
        
        [weiboM release];
    }];
    
    [weiboM setFailCallbackBlock:^(SinaWeiboRequest *request, NSError *error) {
        [self removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentViewRemoved" object:self];
        
        FeedbackTipsView *feedbackView = [[[FeedbackTipsView alloc] init] autorelease];
        UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
        if (!appWindow)
            appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        [appWindow addSubview:feedbackView];
        [feedbackView showTipsViewWithText:[title stringByAppendingString:@"失败"]];
        NSLog(@"转发评论错误 %@", [error description]);
        
        [weiboM release];
    }];
    
    [weiboM getDataFromWeiboWithURL:urlStr params:dict httpMethod:@"POST"];
}

- (void)favButtonAction: (UIButton *)sender
{
    if (![favArray containsObject:detailStatus.statusStr])
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              detailStatus.statusStr, @"id",
                              nil];
        
        WeiboConnectManager *weiboM = [WeiboConnectManager new];
        [weiboM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
            [self upDateFavArray];
            [self removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentViewRemoved" object:self];
            
            FeedbackTipsView *feedbackView = [[[FeedbackTipsView alloc] init] autorelease];
            UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
            if (!appWindow)
                appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
            [appWindow addSubview:feedbackView];
            [feedbackView showTipsViewWithText:@"收藏成功"];
            
            [weiboM release];
        }];
        
        [weiboM setFailCallbackBlock:^(SinaWeiboRequest *request, NSError *error) {
            [self removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentViewRemoved" object:self];
            
            FeedbackTipsView *feedbackView = [[[FeedbackTipsView alloc] init] autorelease];
            UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
            if (!appWindow)
                appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
            [appWindow addSubview:feedbackView];
            [feedbackView showTipsViewWithText:@"收藏失败"];
            NSLog(@"收藏错误 %@", [error description]);
            
            [weiboM release];
        }];
        
        [weiboM getDataFromWeiboWithURL:@"favorites/create.json" params:dict httpMethod:@"POST"];
    }
    else
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              detailStatus.statusStr, @"id",
                              nil];
        WeiboConnectManager *weiboM = [WeiboConnectManager new];
        [weiboM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
            [favButton setBackgroundImage:[UIImage imageNamed:@"detail_button_fav.png"]
                                 forState:UIControlStateNormal];
            [self removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentViewRemoved" object:self];
            
            FeedbackTipsView *feedbackView = [[[FeedbackTipsView alloc] init] autorelease];
            UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
            if (!appWindow)
                appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
            [appWindow addSubview:feedbackView];
            [feedbackView showTipsViewWithText:@"移除成功"];

            [weiboM release];
        }];
        
        [weiboM setFailCallbackBlock:^(SinaWeiboRequest *request, NSError *error) {
            [self removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentViewRemoved" object:self];
            
            FeedbackTipsView *feedbackView = [[[FeedbackTipsView alloc] init] autorelease];
            UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
            if (!appWindow)
                appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
            [appWindow addSubview:feedbackView];
            [feedbackView showTipsViewWithText:@"移除失败"];
            NSLog(@"收藏移除错误 %@", [error description]);
            
            [weiboM release];
        }];
        
        [weiboM getDataFromWeiboWithURL:@"favorites/destroy.json" params:dict httpMethod:@"POST"];
    }
}

@end
