//
//  CommentView.h
//  MyWave
//
//  Created by youngsing on 13-1-27.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "EmoticonsScrollView.h"

typedef void(^InputViewDidChangedFrameBlock) (CGFloat changedHeight);

@interface CommentView : UIView <UITextViewDelegate>
{
    InputViewDidChangedFrameBlock inputViewDidChangedFrameBlock;
    
    UIView *toolView;
    UIButton *repostButton;
    UIButton *commentButton;
    UIButton *favButton;
    NSString *selectedButtonTitle;
    
//    UILabel *numLabel;
    
    UIView *commentInputView;
    UITextView *inputTextView;
    
    CGFloat keyBoardHeight;
    
    EmoticonsScrollView *emoticonsScrollView;
    BOOL isFaceLoad;
    
    NSMutableArray *favArray;
}

@property (nonatomic, retain) Status *detailStatus;
@property (nonatomic, retain) NSMutableArray *favArray;

- (void)setInputViewDidChangedFrameBlock: (InputViewDidChangedFrameBlock)block;
- (void)upDateFavArray;

@end
