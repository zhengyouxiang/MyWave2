//
//  UpdateStatusesController.h
//  MyWave
//
//  Created by youngsing on 13-1-17.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EmoticonsScrollView.h"

@interface UpdateStatusesController : UIViewController <UITextViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>
{
    UIView *loadTextView;
    UILabel *numLabel;
    UIView *updateStatusToolView;
    EmoticonsScrollView *emoticonsScrollView;
}

@property (retain, nonatomic) UITextView *inputTextView;

@end
