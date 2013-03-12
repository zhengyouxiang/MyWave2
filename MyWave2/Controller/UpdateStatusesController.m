//
//  UpdateStatusesController.m
//  MyWave
//
//  Created by youngsing on 13-1-17.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "UpdateStatusesController.h"
#import "FeedbackTipsView.h"

@interface UpdateStatusesController ()

@end

static BOOL isFaceLoad = NO;

@implementation UpdateStatusesController

- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    
    self.navigationController.navigationBarHidden = YES;
    
    //默认中文键盘 252 英文键盘 216
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 20 - 252;
    loadTextView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height)] autorelease];
    [self.view addSubview:loadTextView];
    
    UIImageView *cancelImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_m.png"]] autorelease];
    cancelImageView.frame = CGRectMake(0, 0, 44, 44);
    [loadTextView addSubview:cancelImageView];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(7, 7, 30, 30);
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"button_icon_close.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self
                     action:@selector(cancelBarButtonAction:)
           forControlEvents:UIControlEventTouchUpInside];
    [loadTextView addSubview:cancelButton];
    
    UIImageView *updateImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button_m.png"]] autorelease];
    updateImageView.frame = CGRectMake(320 - 44, 0, 44, 44);
    [loadTextView addSubview:updateImageView];
    
    UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    updateButton.tag = 2000;
    updateButton.frame = CGRectMake(320 - 44 + 7 , 7, 30, 30);
    [updateButton setBackgroundImage:[UIImage imageNamed:@"button_icon_ok.png"] forState:UIControlStateNormal];
    [updateButton addTarget:self
                     action:@selector(updateBarButtonAction:)
           forControlEvents:UIControlEventTouchUpInside];
    updateButton.enabled = NO;
    [loadTextView addSubview:updateButton];
    
    UIButton *messageToButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageToButton setTitle:@"新微博" forState:UIControlStateNormal];
    [messageToButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    messageToButton.frame = CGRectMake(160 - 120, 0, 240, 44);
    UIImage *stretchableImage = [[UIImage imageNamed:@"button_m.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
    [messageToButton setBackgroundImage:stretchableImage forState:UIControlStateNormal];
    [loadTextView addSubview:messageToButton];
    
    self.inputTextView = [[[UITextView alloc] initWithFrame:CGRectMake(0, 40, 320, height - 40 - 33)] autorelease];
    self.inputTextView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.2f];
    self.inputTextView.font = FontOFHelvetica14;
    self.inputTextView.delegate = self;
    [loadTextView addSubview:self.inputTextView];
    
    numLabel = [[[UILabel alloc] initWithFrame:CGRectMake(290, height - 33 - 20, 30, 20)] autorelease];
    numLabel.text = @"140";
    numLabel.font = FontOFHelvetica14;
    numLabel.textAlignment = UITextAlignmentCenter;
    numLabel.backgroundColor = [UIColor clearColor];
    numLabel.textColor = [UIColor cyanColor];
    [loadTextView addSubview:numLabel];
    
    updateStatusToolView = [[[UIView alloc] initWithFrame:CGRectMake(0, height - 33, 329, 33)] autorelease];
    
    UIButton *toolButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    toolButton1.tag = 3001;
    toolButton1.frame = CGRectMake(12, 0, 40, 33);
    [toolButton1 setBackgroundImage:[UIImage imageNamed:@"compose_toolbar_1.png"] forState:UIControlStateNormal];
    [toolButton1 addTarget:self
                    action:@selector(cameraButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [updateStatusToolView addSubview:toolButton1];
    
    UIButton *toolButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    toolButton2.tag = 3002;
    toolButton2.frame = CGRectMake(76, 0, 40, 33);
    [toolButton2 setBackgroundImage:[UIImage imageNamed:@"compose_toolbar_4.png"] forState:UIControlStateNormal];
    [toolButton2 addTarget:self
                    action:@selector(topicButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [updateStatusToolView addSubview:toolButton2];
    
    UIButton *toolButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    toolButton3.tag = 3003;
    toolButton3.frame = CGRectMake(140, 0, 40, 33);
    [toolButton3 setBackgroundImage:[UIImage imageNamed:@"compose_toolbar_3.png"] forState:UIControlStateNormal];
    [toolButton3 addTarget:self
                    action:@selector(atButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [updateStatusToolView addSubview:toolButton3];
    
    UIButton *toolButton4 = [UIButton buttonWithType:UIButtonTypeCustom];
    toolButton4.tag = 3004;
    toolButton4.frame = CGRectMake(204, 0, 40, 33);
    [toolButton4 setBackgroundImage:[UIImage imageNamed:@"compose_toolbar_6.png"] forState:UIControlStateNormal];
    [toolButton4 addTarget:self
                    action:@selector(faceButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [updateStatusToolView addSubview:toolButton4];
    
    UIButton *toolButton5 = [UIButton buttonWithType:UIButtonTypeCustom];
    toolButton5.tag = 3005;
    toolButton5.frame = CGRectMake(268, 0, 40, 33);
    [toolButton5 setBackgroundImage:[UIImage imageNamed:@"compose_toolbar_5.png"] forState:UIControlStateNormal];
    [toolButton5 addTarget:self
                    action:@selector(locationButtionAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [updateStatusToolView addSubview:toolButton5];
    
    for (int i = 0; i < 4; ++i)
    {
        UIImageView *seperatorLineImageView = [[[UIImageView alloc] initWithFrame:CGRectMake((i+1)*64, 0, 1, 33)] autorelease];
        seperatorLineImageView.image = [UIImage imageNamed:@"compose_toolbar_sp.png"];
        [updateStatusToolView addSubview:seperatorLineImageView];
    }
    
    [loadTextView addSubview:updateStatusToolView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_inputTextView release];
    _inputTextView = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self keyBoardFrameWillChange:note];
                                                  }];
    [self.inputTextView becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat height = [[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString:@"zh-Hans"] ? 252 : 216;
    height = [UIScreen mainScreen].bounds.size.height - 20 - height;
    loadTextView.frame = CGRectMake(0, 0, 320, height);
    numLabel.frame = CGRectMake(290, height - 33 - 20, 30, 20);
    self.inputTextView.frame = CGRectMake(0, 40, 320, height - 33 - 40);
    updateStatusToolView.frame = CGRectMake(0, height - 33, 320, 33);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark text view delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    isFaceLoad = NO;
    [emoticonsScrollView removeFromSuperview];
}

-(void)textViewDidChange:(UITextView *)textView
{
    float sumLength = 0.0;
    for(int i = 0; i<[textView.text length]; ++i)
    {
        NSString *character = [textView.text substringWithRange:NSMakeRange(i, 1)];
        if([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
            ++sumLength;
        else
            sumLength += 0.5;
    }
    
    UIButton *updateButton = (UIButton *)[self.view viewWithTag:2000];
    if (sumLength > 0 && sumLength <= 140)
        updateButton.enabled = YES;
    else
        updateButton.enabled = NO;
    
    numLabel.text = [NSString stringWithFormat:@"%d", 140 - (int)ceil(sumLength)];
}

#pragma mark - Custom Methods
- (void)keyBoardFrameWillChange: (NSNotification *)note
{
    NSDictionary *keyBoardInfo = [note userInfo];
    CGFloat beginkeyBoardHeiht = [[keyBoardInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    CGFloat endkeyBoardHeight = [[keyBoardInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat changedHeight = endkeyBoardHeight - beginkeyBoardHeiht;
    if (abs(changedHeight) == 36)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect loadTextViewFrame = loadTextView.frame;
            loadTextViewFrame.size.height = loadTextViewFrame.size.height - changedHeight;
            loadTextView.frame = loadTextViewFrame;
            
            CGRect numLabelFrame = numLabel.frame;
            numLabelFrame.origin.y = loadTextViewFrame.size.height - 33 - 20;
            numLabel.frame = numLabelFrame;
            
            CGRect inputTextViewFrame = self.inputTextView.frame;
            inputTextViewFrame.size.height = loadTextViewFrame.size.height - 40;
            self.inputTextView.frame = inputTextViewFrame;
            
            CGRect updateStatusToolViewFrame = updateStatusToolView.frame;
            updateStatusToolViewFrame.origin.y = loadTextViewFrame.size.height - 33;
            updateStatusToolView.frame = updateStatusToolViewFrame;
        }];
    }
    else
    {
        NSLog(@"不是在中英文键盘间切换！");
    }
}

- (void)cancelBarButtonAction: (id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateBarButtonAction: (id)sender
{
    WeiboConnectManager *weiboM = [WeiboConnectManager new];
    
    [weiboM setResultCallbackBlock:^(SinaWeiboRequest *request, id obj) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        FeedbackTipsView *feedbackView = [[[FeedbackTipsView alloc] init] autorelease];
        UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
        if (!appWindow)
            appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        [appWindow addSubview:feedbackView];
        [feedbackView showTipsViewWithText:@"微博发送成功"];
        
        [weiboM release];
    }];
    
    [weiboM setFailCallbackBlock:^(SinaWeiboRequest *request, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        FeedbackTipsView *feedbackView = [[[FeedbackTipsView alloc] init] autorelease];
        UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
        if (!appWindow)
            appWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        [appWindow addSubview:feedbackView];
        [feedbackView showTipsViewWithText:@"微博发送失败"];
        NSLog(@"%@", [error description]);
        
        [weiboM release];
    }];
    
    NSDictionary *inputTextDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self.inputTextView.text, @"status", nil];
    
    [weiboM getDataFromWeiboWithURL:@"statuses/update.json"
                             params:inputTextDict
                         httpMethod:@"POST"];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraButtonAction: (id)sender
{
    NSLog(@"cameraButtonAction Coming soon!");
}

- (void)topicButtonAction: (id)sender
{
    NSLog(@"topicButtonAction Coming soon!");
}

- (void)atButtonAction: (id)sender
{
    NSLog(@"atButtonAction Coming soon!");
}

- (void)faceButtonAction: (id)sender
{
    [self.view endEditing:YES];
    if (!isFaceLoad)
    {
        emoticonsScrollView = [[[EmoticonsScrollView alloc] init] autorelease];
        emoticonsScrollView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 320,
                                               [UIScreen mainScreen].bounds.size.height - loadTextView.frame.size.height);
        [self.view addSubview:emoticonsScrollView];;
        
        [emoticonsScrollView setFaceImageTappedBlock:^(NSString *face) {
            self.inputTextView.text = [self.inputTextView.text stringByAppendingString:face];
            [self textViewDidChange:self.inputTextView];
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect emoticonsFrame = emoticonsScrollView.frame;
            emoticonsFrame.origin.y = loadTextView.frame.size.height;
            emoticonsScrollView.frame = emoticonsFrame;
        } completion:^(BOOL finished) {
            isFaceLoad = YES;
        }];
    }
    else
    {
        [self.inputTextView becomeFirstResponder];
        isFaceLoad = NO;
    }
}

- (void)locationButtionAction: (id)sender
{
    NSLog(@"locationButtionAction Coming soon!");
    CLLocationManager *locationManager = [[[CLLocationManager alloc] init] autorelease];
    if (![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"location error");
        return;
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 100;
    [locationManager startUpdatingHeading];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"yes");
    NSLog(@"%@", newLocation);
}
@end
