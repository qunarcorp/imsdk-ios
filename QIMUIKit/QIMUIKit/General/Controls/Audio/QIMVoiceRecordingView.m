//
//  QIMVoiceRecordingView.m
//  AudioTempForQT
//
//  Created by danzheng on 15/4/21.
//  Copyright (c) 2015年 fresh. All rights reserved.
//

#import "QIMVoiceRecordingView.h"

#define Image_Name_0 [UIImage imageNamed:@"voiceRecording1"]
#define Image_Name_1 [UIImage imageNamed:@"voiceRecording2"]
#define Image_Name_2 [UIImage imageNamed:@"voiceRecording3"]
#define Image_Name_3 [UIImage imageNamed:@"voiceRecording4"]
#define Image_Name_4 [UIImage imageNamed:@"voiceRecording5"]
#define Image_Name_5 [UIImage imageNamed:@"voiceRecording6"]
#define Image_Name_6 [UIImage imageNamed:@"voiceRecording7"]

@interface QIMVoiceRecordingView() {
    UIImageView *_imageView;
    UIImageView *_staticImageView;
    NSArray *_imageArray;
    UIImageView *_maybeCancelView;
    UILabel *_textLabel;
}

@end

@implementation QIMVoiceRecordingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doDataInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self doDataInit];
    }
    return self;
}

- (void)doDataInit
{
    self.backgroundColor = [UIColor qim_colorWithHex:0x0 alpha:0.65];
    [self.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.layer setCornerRadius:10.0f];
    self.clipsToBounds = YES;
    
    CGRect backRect = CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height-20-35);
    
//    _staticImageView = [[UIImageView alloc] initWithFrame:CGRectMake(backRect.origin.x, backRect.origin.y, backRect.size.width/2, backRect.size.height)];
//    [_staticImageView setImage:[UIImage imageNamed:@"voiceRecording"]];
//    [self addSubview:_staticImageView];
    
    _imageArray = [[NSArray alloc] initWithObjects: Image_Name_0, Image_Name_1, Image_Name_2, Image_Name_3, Image_Name_4, Image_Name_5, Image_Name_6, nil];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 30, 30, 60, 90)];
   [self addSubview:_imageView];
    
    //取消发送的图片
    _maybeCancelView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 17, self.frame.size.height/2 - 22, 34, 34)];
    [_maybeCancelView setImage:[UIImage imageNamed:@"SignUpError"]];
    [self addSubview:_maybeCancelView];
    _maybeCancelView.hidden = YES;
    
    //取消发送的文案
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, backRect.origin.y+backRect.size.height, self.frame.size.width, 35)];
    _textLabel.font = [UIFont systemFontOfSize:12];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.text = @"手指上滑  取消发送";
//    [self addSubview:_textLabel];
    
//    _remainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
//    [_remainLabel setFont:[UIFont systemFontOfSize:10]];
//    _remainLabel.textAlignment = 1;
//    _remainLabel.hidden = YES;
//    [self addSubview:_remainLabel];
}

- (void)beginDoRecord
{
    [_imageView setImage:[_imageArray objectAtIndex:0]];
}

//0表示完全安静，160表示最大输入值
- (void)doImageUpdateWithVoicePower:(float)voicePower
{
    NSInteger level;
    if (voicePower >= 145)
        level = 6;
    else if (voicePower < 145 && voicePower >= 140)
        level = 5;
    else if (voicePower < 140 && voicePower >= 135)
        level = 4;
    else if (voicePower < 135 && voicePower >= 130)
        level = 3;
    else if (voicePower < 130 && voicePower >= 125)
        level = 2;
    else if (voicePower < 125 && voicePower >= 115)
        level = 1;
    else
        level = 0;
        
    [_imageView setImage:[_imageArray objectAtIndex:level]];
}

- (void)voiceMaybeCancelWithState:(BOOL)ifMaybeCancel
{
    if (ifMaybeCancel) {
        //提示松开手指取消发送
        [_textLabel setText:@"松开手指  取消发送"];
        [_maybeCancelView setHidden:NO];
//        [_staticImageView setHidden:YES];
        [_imageView setHidden:YES];
    } else {
        [_textLabel setText:@"手指上滑  取消发送"];
        [_maybeCancelView setHidden:YES];
        [_imageView setHidden:NO];
//        [_staticImageView setHidden:NO];
    }
}

//- (void)doRemindUserWithRemainTime:(float)remainTime
//{
//    _remainLabel.text = [NSString stringWithFormat:@"本次录音还有%f秒结束",remainTime];
//    _remainLabel.hidden = NO;
//    QIMVerboseLog(@"本次录音还有%f秒结束",remainTime);
//}

@end
