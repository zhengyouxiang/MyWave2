//
//  ImageView.m
//  MyWave
//
//  Created by youngsing on 13-1-23.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "ImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ImageView
@synthesize originImageView = _originImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor blackColor];
        scrollImageView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        scrollImageView.delegate = self;
        self.originImageView = [[[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
        self.originImageView.userInteractionEnabled = YES;
        
        [scrollImageView addSubview:self.originImageView];
        [self addSubview:scrollImageView];
        
        loadingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 200, 320, 30)] autorelease];
        loadingLabel.text = @"......";
        loadingLabel.textColor = [UIColor whiteColor];
        loadingLabel.font = [UIFont systemFontOfSize:40];
        loadingLabel.backgroundColor = [UIColor blackColor];
        [self addSubview:loadingLabel];
        
        UITapGestureRecognizer *singleTapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(singleTapAction:)] autorelease];
        [self.originImageView addGestureRecognizer:singleTapGesture];
        
        
        UITapGestureRecognizer *doubleTapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(doubleTapAction:)] autorelease];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self.originImageView addGestureRecognizer:doubleTapGesture];
        
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        
        [UIView animateWithDuration:2.0 animations:^{
            [loadingLabel sizeToFit];
            
            CGRect labelFrame = loadingLabel.frame;
            labelFrame.origin.x = 320;
            loadingLabel.frame = labelFrame;
            
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            [UIView setAnimationRepeatAutoreverses:NO];
            [UIView setAnimationRepeatCount:99999];
            
            labelFrame.origin.x = -loadingLabel.frame.size.width;
            loadingLabel.frame = labelFrame;
        }];
    }
    return self;
}

- (void)dealloc
{
    [scrollImageView release];
    [_originImageView release];
    [super dealloc];
}

#pragma mark - ScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.originImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.contentSize.width < scrollView.bounds.size.width) ?
    (scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0;
    
    CGFloat offsetY = (scrollView.contentSize.height < scrollView.bounds.size.height) ?
    (scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0;
    
    self.originImageView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX,
                                   scrollView.contentSize.height / 2 + offsetY);
}

#pragma mark - Custom Methods
- (void)loadImage
{
    [loadingLabel removeFromSuperview];
    originImage = self.originImageView.image;
    CGRect imageViewFrame = self.originImageView.frame;
    imageViewFrame.size = CGSizeMake(originImage.size.width, originImage.size.height);
    self.originImageView.frame = imageViewFrame;
    self.originImageView.center = self.center;
    
    CGFloat widthRatio = scrollImageView.frame.size.width / originImage.size.width;
    CGFloat heigthRatio = scrollImageView.frame.size.height / originImage.size.height;
    initScale = (widthRatio < heigthRatio) ? widthRatio : heigthRatio;
    
    [scrollImageView setMinimumZoomScale:initScale];
    [scrollImageView setMaximumZoomScale:4];
    [scrollImageView setZoomScale:initScale];
}

- (void)singleTapAction: (id)sender
{
    [self removeFromSuperview];
}

- (void)doubleTapAction: (id)sender
{
    if (scrollImageView.zoomScale == 1)
        [scrollImageView setZoomScale:initScale animated:YES];
    else
        [scrollImageView setZoomScale:1 animated:YES];
}

@end
