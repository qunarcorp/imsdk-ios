//
//  QIMVideoMsgCell.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/13.
//
//

#import "QIMMsgBaloonBaseCell.h"
#import "QIMVideoMsgCell.h"
#import "QIMMenuImageView.h"
#import "QIMVideoPlayerVC.h"
#import "QIMJSONSerializer.h"
#import <MediaPlayer/MediaPlayer.h>

static NSMutableDictionary *__uploading_progress_dic = nil;
@interface QIMVideoMsgCell()<QIMMenuImageViewDelegate>
@end

@implementation QIMVideoMsgCell{
    UIImageView     * _imageView;
    UIView          * _infoView;
    UILabel         * _sizeLabel;
    UILabel         * _durationLabel;
    UIProgressView  * _progressView;
    UIImageView     * _playIconView;
    
}

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType {
    if (message.extendInformation.length > 0) {
        message.message = message.extendInformation;
    }
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
    CGSize size = CGSizeMake([[infoDic objectForKey:@"Width"] floatValue], [[infoDic objectForKey:@"Height"] floatValue]);
    
    if (size.width > 0) {
        size.height =  150 * size.height / size.width;
        size.width = 150;
    } else {
        size.height = 150;
        size.width = 150;
    }
    return size.height + 25;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _imageView = [[UIImageView alloc] init];
        [_imageView setBackgroundColor:[UIColor redColor]];
        [_imageView.layer setCornerRadius:15];
        [_imageView.layer setMasksToBounds:YES];
        [self.backView addSubview:_imageView];
        
        _playIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"aio_short_video_icon_playable"]];
        [_imageView addSubview:_playIconView];
        
        _infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
        [_infoView setBackgroundColor:[UIColor qim_colorWithHex:0x0 alpha:0.5]];
        [_imageView addSubview:_infoView];
        
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 130, 20)];
        [_sizeLabel setTextAlignment:NSTextAlignmentLeft];
        _sizeLabel.numberOfLines = 0;
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        _sizeLabel.backgroundColor = [UIColor clearColor];
        [_sizeLabel setTextColor:[UIColor whiteColor]];
        [_infoView addSubview:_sizeLabel];
        
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 130, 20)];
        [_durationLabel setTextAlignment:NSTextAlignmentRight];
        _durationLabel.numberOfLines = 0;
        _durationLabel.font = [UIFont systemFontOfSize:12];
        _durationLabel.backgroundColor = [UIColor clearColor];
        [_durationLabel setTextColor:[UIColor whiteColor]];
        [_infoView addSubview:_durationLabel];
        
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, _infoView.height - 2, _infoView.width, 2)];
        [_infoView addSubview:_progressView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [self.backView addGestureRecognizer:tap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:kNotifyFileManagerUpdate object:nil];
        
    }
    return self;
}

- (void)updateProgress:(NSNotification *)notify{
    NSDictionary *infoDic = [notify object];
    Message *message = [infoDic objectForKey:@"message"];
    float progress = [[infoDic objectForKey:@"propress"] floatValue];
    NSString * status = [infoDic objectForKey:@"status"];
    if (__uploading_progress_dic == nil) {
        __uploading_progress_dic = [NSMutableDictionary dictionary];
    }
    if (progress > 1) {
        [__uploading_progress_dic removeObjectForKey:message.messageId];
    } else {
        [__uploading_progress_dic setObject:@(progress) forKey:message.messageId];
    }
    if ([message.messageId isEqualToString:self.message.messageId]) {
        if (progress > 1) {
            [_progressView setHidden:YES];
        } else {
            [_progressView setHidden:NO];
            [_progressView setProgress:progress];
        }
        if ([status isEqualToString:@"failed"]) {
            self.message.messageState = MessageState_Faild;
            [self refreshUI];
        }
    }
}


- (void)tapHandle:(UITapGestureRecognizer *)tap
{
    if (self.owerViewController) {
        if (self.message.extendInformation.length > 0) {
            self.message.message = self.message.extendInformation;
        }
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
        NSString *fileName = [infoDic objectForKey:@"FileName"];
        NSString *fileUrl = [infoDic objectForKey:@"FileUrl"];
        NSInteger videoWidth = [[infoDic objectForKey:@"Width"] integerValue];;
        NSInteger videoHeight = [[infoDic objectForKey:@"Height"] integerValue];;
        
        if (![fileUrl qim_hasPrefixHttpHeader]) {
            fileUrl = [[QIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingFormat:@"/%@", fileUrl];
        }
        NSString *filePath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingPathComponent:fileName?fileName:@""];
        QIMVideoPlayerVC *videoPlayVC = [[QIMVideoPlayerVC alloc] init];
        [videoPlayVC setVideoPath:filePath];
        [videoPlayVC setVideoUrl:fileUrl];
        [videoPlayVC setVideoWidth:videoWidth];
        [videoPlayVC setVideoHeight:videoHeight];
        [self.owerViewController.navigationController pushViewController:videoPlayVC animated:YES];
        /*
        QIMMoviePlayerVC *moviePlayerVc = [[QIMMoviePlayerVC alloc] init];
        moviePlayerVc.videoURL = [NSURL URLWithString:fileUrl];
        [self.owerViewController presentViewController:moviePlayerVc animated:YES completion:nil];
        */
    }
}

#pragma mark - ui

- (void)refreshUI{
    self.selectedBackgroundView.frame = self.contentView.frame;
    self.backView.message = self.message;
    NSNumber *progressNum = [__uploading_progress_dic objectForKey:self.message.messageId];
    if (progressNum) {
        [_progressView setHidden:NO];
        [_progressView setProgress:progressNum.floatValue];
    } else {
        [_progressView setHidden:YES];
    }
    if (self.message.extendInformation.length > 0) {
        self.message.message = self.message.extendInformation;
    }
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
/*    CGSize size;
    size.width = [[infoDic objectForKey:@"Width"] floatValue];
    size.height = [[infoDic objectForKey:@"Height"] floatValue];
    if (size.width > 0) {
        size.height =  180 * size.height / size.width;
        size.width = 150;
    } else {
        size.height = 180;
        size.width = 150;
    }*/
    
    CGSize size = CGSizeMake(150, [QIMVideoMsgCell getCellHeightWihtMessage:self.message chatType:1] - 40);
    
    [_sizeLabel setText:[infoDic objectForKey:@"FileSize"]];
    [_durationLabel setText:[NSString stringWithFormat:@"%@s",[infoDic objectForKey:@"Duration"]]];
    [_imageView setFrame:CGRectMake((self.message.messageDirection==MessageDirection_Received?kBackViewCap+10:5) - 1, 5, size.width, size.height)];
    NSString *fileName = [infoDic objectForKey:@"FileName"];
    NSString *thubmName = [infoDic objectForKey:@"ThumbName"] ? [infoDic objectForKey:@"ThumbName"] : [NSString stringWithFormat:@"%@_thumb.jpg", [[fileName componentsSeparatedByString:@"."] firstObject]];
    NSString *filePath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingPathComponent:thubmName];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (image == nil) {
        NSString *thumbUrl = [infoDic objectForKey:@"ThumbUrl"];
        if (![thumbUrl hasPrefix:[QIMKit sharedInstance].qimNav_InnerFileHttpHost]) {
            thumbUrl = [[QIMKit sharedInstance].qimNav_InnerFileHttpHost stringByAppendingPathComponent:thumbUrl];
        }
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbUrl]];
        [data writeToFile:filePath atomically:YES];
        image = [UIImage imageWithContentsOfFile:filePath];
    }
    [_imageView setImage:image];
    [_infoView setFrame:CGRectMake(0, _imageView.bottom - _infoView.height, _infoView.width, _infoView.height)];
    
    float backWidth = size.width + 6 + kBackViewCap + 8;
    float backHeight = size.height + 6 + 5;
    [self setBackViewWithWidth:backWidth WihtHeight:backHeight];
    CGPoint center = _imageView.center;
    if (self.message.messageDirection==MessageDirection_Received) {
        center.x -= kBackViewCap+2;
    }
    [_playIconView setCenter:center];
    [super refreshUI];
}

- (NSArray *)showMenuActionTypeList {
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
    switch (self.message.messageDirection) {
        case MessageDirection_Received: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        case MessageDirection_Sent: {
            [menuList addObjectsFromArray:@[@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        default:
            break;
    }
    if ([[[QIMKit sharedInstance] qimNav_getDebugers] containsObject:[QIMKit getLastUserName]]) {
        [menuList addObject:@(MA_CopyOriginMsg)];
    }
    if ([[QIMKit sharedInstance] getIsIpad]) {
        [menuList removeAllObjects];
    }
    return menuList;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
