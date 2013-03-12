//
//  FeedbackTipsView.m
//  MyWave
//
//  Created by youngsing on 13-1-27.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "FeedbackTipsView.h"

@implementation FeedbackTipsView

- (id)init
{
    if (self = [super init])
    {
        self.frame = CGRectMake(90, -20, 140, 20);
        tipsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 20)] autorelease];
        tipsLabel.backgroundColor = [UIColor cyanColor];
        tipsLabel.font = FontOFHelvetica14;
        tipsLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:tipsLabel];
    }
    return self;
}

- (void)showTipsViewWithText: (NSString *)tipsText
{
    tipsLabel.text = tipsText;
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.frame;
        frame.origin.y = 20;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:1.5f];
    }];
}

- (void)dismiss
{
    [self removeFromSuperview];
}

@end
