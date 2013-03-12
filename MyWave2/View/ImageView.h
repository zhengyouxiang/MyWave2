//
//  ImageView.h
//  MyWave
//
//  Created by youngsing on 13-1-23.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageView : UIView <UIScrollViewDelegate>
{
    UIImage *originImage;
    UIScrollView *scrollImageView;
    CGFloat initScale;
    UILabel *loadingLabel;
}

- (void)loadImage;
- (void)singleTapAction: (id)sender;
- (void)doubleTapAction: (id)sender;

@property (nonatomic, retain) UIImageView *originImageView;

@end
