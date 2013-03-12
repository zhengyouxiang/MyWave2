//
//  EmoticonsScrollView.m
//  MyWave
//
//  Created by youngsing on 13-1-26.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "EmoticonsScrollView.h"

@implementation EmoticonsScrollView

- (id)init
{
    if (self = [super init])
    {
        self.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.2f];
        for (int i = 0; i < 19; ++i)
        {
            for (int j = 0; j < 8; ++j)
            {
                int faceNum = i * 8 + j + 1;
                if (faceNum < 147)
                {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(j*38 + 12, i*38, 30, 30);
                    [button addTarget:self
                               action:@selector(imageButtonTappedAction:)
                     forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:button];
                    
                    NSString *faceStr = nil;
                    if (faceNum < 10)
                        faceStr = [NSString stringWithFormat:@"00%d", faceNum];
                    else if (faceNum > 9 && faceNum < 100)
                        faceStr = [NSString stringWithFormat:@"0%d.png", faceNum];
                    else if (faceNum > 99 && faceNum < 105)
                        faceStr = [NSString stringWithFormat:@"%d.png", faceNum];
                    else
                        faceStr = [NSString stringWithFormat:@"%d.gif", faceNum];
                    [button setTitle:faceStr forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    [button setBackgroundImage:[UIImage imageNamed:faceStr] forState:UIControlStateNormal];
                    
                }
                else
                {
                    break;
                }
            }
        }
        self.contentSize = CGSizeMake(320, 740);
    }
    return self;
}

- (void)setFaceImageTappedBlock:(FaceImageTappedBlock)block
{
    [faceImageTappedBlock release];
    faceImageTappedBlock = [block copy];
}

- (void)imageButtonTappedAction: (UIButton *)sender
{
    int faceInt = [[sender.titleLabel.text substringToIndex:3] intValue] - 1;
    NSArray *faceArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emoticons" ofType:@"plist"]];
    NSString *face = [[faceArray objectAtIndex:faceInt] objectForKey:@"chs"];
    
    if (faceImageTappedBlock)
    {
        faceImageTappedBlock(face);
    }
}

@end
