//
//  MyCellDelegate.h
//  MyWave
//
//  Created by youngsing on 13-1-27.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyCellDelegate <NSObject>

@optional
- (void)imageTappedActionWithStatusCell: (id)cell;
- (void)avatarImageTappedActionWithStatusCell: (id)cell;
- (void)rightSwipToolViewWithCell: (id)cell Position: (CGPoint)position;

@end
