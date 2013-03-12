//
//  DetailStatusViewController.h
//  MyWave
//
//  Created by youngsing on 13-1-25.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "Status.h"
#import "EmoticonsScrollView.h"
#import "HMSegmentedControl.h"

@interface DetailStatusViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, OHAttributedLabelDelegate, UITextViewDelegate>
{
    NSMutableArray *commentDataArray;
    NSMutableArray *repostDataArray;
    
    HMSegmentedControl *repostAndCommentSegCtrl;
    
    UIView *commentInputView;
    UIView *inputBackgroundView;
    UITextView *inputTextView;
    UILabel *placeHolderInTextViewLabel;
    UIButton *atButton;
    UIButton *faceButton;
    UIButton *updateButton;
    
    UILabel *numLabel;
    
    CGFloat priorHeight;
    
    BOOL isFaceLoad;
    EmoticonsScrollView *emoticonsScrollView;
    CGFloat keyBoardHeight;
    
    CGFloat sectionHeight;
}

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) Status *detailStatus;

@end
