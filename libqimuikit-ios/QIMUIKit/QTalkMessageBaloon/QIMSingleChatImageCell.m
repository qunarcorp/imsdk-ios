//
//  QIMSingleChatImageCell.m
//  DangDiRen
//
//  Created by ping.xue on 14-3-27.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "QIMSingleChatImageCell.h"
#import "QIMMsgBaloonBaseCell.h"
#import "QIMMenuImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "LvtuAutoImageView.h"
#import "QIMSingleChatImageTools.h"

#define kMsgImageViewTop        3
#define kMsgImageViewLeft       3
#define kMsgImageHeight         100
#define kCellHeightCap      5
#define kBackViewCap        5

@interface QIMSingleChatImageCell()<QIMMenuImageViewDelegate,UIGestureRecognizerDelegate>

@end

@implementation QIMSingleChatImageCell{
    
    QIMMenuImageView *_backView;
    LvtuAutoImageView *_msgImageView;
    UIButton *_errorButton;
    UIActivityIndicatorView *_waittingView;
}

@synthesize delegate = _delegate;

+ (CGFloat)getCellHeight{
    return kMsgImageHeight + kMsgImageViewTop *2 + 5;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setBackgroundColor:[UIColor clearColor]];
        
        _backView = [[QIMMenuImageView alloc] initWithFrame:CGRectZero];
        [_backView setDelegate:self];
        [_backView setUserInteractionEnabled:YES];
        [self.contentView addSubview:_backView];
        
        _msgImageView = [[LvtuAutoImageView alloc] initWithFrame:CGRectZero]; 
        [_msgImageView.layer setCornerRadius:15];
        [_msgImageView setClipsToBounds:YES];
        [_backView addSubview:_msgImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayPhoto:)];
        [_backView addGestureRecognizer:tap];
        
        _errorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
        [_errorButton setHidden:YES];
        [_errorButton setImage:[UIImage imageNamed:@"SignUpError"] forState:UIControlStateNormal];
        [_errorButton addTarget:self action:@selector(resendMessage) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_errorButton];
        
        _waittingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
        [_waittingView setHidden:YES];
        [self.contentView addSubview:_waittingView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)displayPhoto:(UITapGestureRecognizer *)tap {
    
    NSDictionary *infoDic = [self.message getMsgInfoDic];
    if (infoDic) {
        NSString *filePath = [infoDic objectForKey:@"filePath"];
        NSString *httpUrl = [infoDic objectForKey:@"httpUrl"];
        if (filePath) {
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            [self.delegate openBigPhoto:image FromRect:CGRectMake(self.frame.origin.x+_msgImageView.frame.origin.x + _backView.frame.origin.x, self.frame.origin.y+_msgImageView.frame.origin.y + _backView.frame.origin.y, _msgImageView.frame.size.width, _msgImageView.frame.size.height)];
        } else {
            [self.delegate openBigPhotoUrl:httpUrl FromRect:CGRectMake(self.frame.origin.x+_msgImageView.frame.origin.x + _backView.frame.origin.x, self.frame.origin.y+_msgImageView.frame.origin.y + _backView.frame.origin.y, _msgImageView.frame.size.width, _msgImageView.frame.size.height)];
        }
    }
}

- (void)resendMessage{

}

- (void)refreshUI{
    
    _backView.message = self.message;
    
    if (self.message.messageType == QIMMessageType_Image) {
        
        UIImage *image = nil;
        CGSize size;
        NSDictionary *infoDic = [self.message getMsgInfoDic];
        if (infoDic) {
            NSString *filePath = [infoDic objectForKey:@"thumbFilePath"];           //???????????why,在哪里设置的
            NSString *httpUrl = [infoDic objectForKey:@"thumbUrl"];
            size = CGSizeFromString([infoDic objectForKey:@"size"]);
            if (filePath.length > 0) {
                image = [UIImage imageWithContentsOfFile:filePath];
            }
            if (image == nil && httpUrl.length > 0){
                [_msgImageView setImageURL:httpUrl];;
                if (_msgImageView.image == nil) {
                    image = [[QIMSingleChatImageTools sharedInstance] getImageDownloadFaildWithDirect:self.message.messageDirection];
                } else {
                    image = _msgImageView.image;
                }
            }
        } else {
            if ([self.message.message hasPrefix:@"http://"]) {
                [_msgImageView setImageURL:self.message.message];;
                if (_msgImageView.image == nil) {
                    image = [[QIMSingleChatImageTools sharedInstance] getImageDownloading];
                } else {
                    image = _msgImageView.image;
                }
            } else {
                image = [UIImage imageWithContentsOfFile:self.message.message];
            }
        }
        if (image == nil) {
            image = [[QIMSingleChatImageTools sharedInstance] getImageDownloadFaildWithDirect:self.message.messageDirection];
            size = image.size;
        }
        
        if ((int)size.width <= 1 || size.width == NAN) {
            size = image.size;
        }
        CGFloat height = size.height < 100 ? size.height : kMsgImageHeight;
        CGFloat width = size.width * height / size.height;
        
        [_msgImageView setImage:image];
        
        CGFloat backWidth = width + kMsgImageViewLeft * 2 + 5, backHeight = height + kMsgImageViewTop * 2;
        
        switch (self.message.messageState) {
            case MessageState_Waiting:
            {
                [_errorButton setHidden:YES];
                [_waittingView setHidden:NO];
                [_waittingView startAnimating];
            }
                break;
            case MessageState_Faild:
            {
                [_errorButton setHidden:NO];
                [_waittingView setHidden:YES];
                [_waittingView stopAnimating];
            }
                break;
            default:
            {
                [_errorButton setHidden:YES];
                [_waittingView setHidden:YES];
                [_waittingView stopAnimating];
            }
                break;
        } 
        
        if (self.message.messageDirection == MessageDirection_Received) {
            
            [_msgImageView setFrame:CGRectMake(kMsgImageViewLeft + 5, kMsgImageViewTop, width, height)];
            
            CGRect frame = {{kBackViewCap,kCellHeightCap / 2.0},{backWidth,backHeight}};
            [_backView setFrame:frame];
            
            [_backView setImage:[[QIMSingleChatImageTools sharedInstance] getReceivedBg]];
            
            [_errorButton setHidden:YES];
            CGRect waitingFrame = _waittingView.frame;
            waitingFrame.origin.x = _backView.frame.origin.x + _backView.frame.size.width + kBackViewCap;
            waitingFrame.origin.y = _backView.frame.origin.y + (_backView.frame.size.height - waitingFrame.size.height) / 2.0;
            [_waittingView setFrame:waitingFrame];
            
        } else {
            [_msgImageView setFrame:CGRectMake(kMsgImageViewLeft, kMsgImageViewTop, width, height)];
            CGRect frame = {{self.frameWidth - kBackViewCap - backWidth,kBackViewCap},{backWidth,backHeight}};
            [_backView setFrame:frame];
            [_backView setImage:[[QIMSingleChatImageTools sharedInstance] getSentBg]];
            
            [_errorButton setHidden:self.message.messageState != MessageState_Faild];
            CGRect errorFrame = _errorButton.frame;
            errorFrame.origin.x = _backView.frame.origin.x - kBackViewCap - errorFrame.size.width;
            errorFrame.origin.y = _backView.frame.origin.y;
            errorFrame.size.width = backWidth + 17 + kBackViewCap;
            errorFrame.size.height = backHeight;
            [_errorButton setFrame:errorFrame];
            CGRect waitingFrame = _waittingView.frame;
            waitingFrame.origin.x = _backView.frame.origin.x + _backView.frame.size.width + kBackViewCap;
            waitingFrame.origin.y = _backView.frame.origin.y + (_backView.frame.size.height - waitingFrame.size.height) / 2.0;
            [_waittingView setFrame:waitingFrame];
        }
    }
}

@end
