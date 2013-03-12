//
//  EmoticonsScrollView.h
//  MyWave
//
//  Created by youngsing on 13-1-26.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FaceImageTappedBlock)(NSString *face);
@interface EmoticonsScrollView : UIScrollView
{
    FaceImageTappedBlock faceImageTappedBlock;
}

- (void)setFaceImageTappedBlock: (FaceImageTappedBlock)block;

@end
