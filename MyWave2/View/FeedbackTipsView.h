//
//  FeedbackTipsView.h
//  MyWave
//
//  Created by youngsing on 13-1-27.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedbackTipsView : UIView
{
    UILabel *tipsLabel;
}

- (void)showTipsViewWithText: (NSString *)tipsText;

@end
