//
//  QIMVoiceTimeRemindView.m
//  qunarChatIphone
//
//  Created by danzheng on 15/5/13.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMVoiceTimeRemindView.h"

@interface QIMVoiceTimeRemindView()
{
    UIImageView *_imageView;
    UILabel *_textLabel;
}

@end

@implementation QIMVoiceTimeRemindView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doSubViewInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self doSubViewInit];
    }
    return self;
}


- (void)doSubViewInit
{
    self.backgroundColor = [UIColor lightGrayColor];
    
    CGRect backRect = CGRectMake(self.frame.size.width/2-60/2, (self.frame.size.height-50)/2-60/2, 60, 60);
    _imageView = [[UIImageView alloc] initWithFrame:backRect];
    [_imageView setImage:[UIImage imageNamed:@"registered_icon_quxiao"]];
    [self addSubview:_imageView];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-50, self.frame.size.width, 50)];
    _textLabel.text = @"录音时间短，录音取消";
    _textLabel.font = [UIFont systemFontOfSize:10.0];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLabel];
}

@end
