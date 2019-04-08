//
//  QIMMWPhotoSectionBrowserCell.m
//  QIMUIKit
//
//  Created by lilu on 2018/12/12.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMMWPhotoSectionBrowserCell.h"
#import "UIImageView+QIMImageCache.h"
#import "NSBundle+QIMLibrary.h"
#import "UIImage+QIMMWPhotoBrowser.h"

@interface QIMMWPhotoSectionBrowserCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *tagView; //标识这是一个视频

@property (nonatomic, strong) UILabel *videoLabel;  //视频时长

@property (nonatomic, strong) UIButton *photoSelectBtn;

@end

@implementation QIMMWPhotoSectionBrowserCell

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.image = [UIImage imageNamed:@"LaunchImage"];
    }
    return _imageView;
}

- (UIImageView *)tagView {
    if (!_tagView) {
        _tagView = [[UIImageView alloc] initWithFrame:CGRectMake(18, self.contentView.bottom - 22, 16, 16)];
        _tagView.backgroundColor = [UIColor clearColor];
        _tagView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e0e9" size:18 color:[UIColor whiteColor]]];
        _tagView.hidden = YES;
    }
    return _tagView;
}

- (UILabel *)videoLabel {
    if (!_videoLabel) {
        _videoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.tagView.right + 8, self.contentView.bottom - 20, 50, 15)];
        _videoLabel.backgroundColor = [UIColor clearColor];
        [_videoLabel setFont:[UIFont systemFontOfSize:12]];
        [_videoLabel setTextColor:[UIColor whiteColor]];
    }
    return _videoLabel;
}

- (UIButton *)photoSelectBtn {
    if (!_photoSelectBtn) {
        _photoSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoSelectBtn.frame = CGRectMake(self.contentView.right - 25, self.contentView.top + 1, 24, 24);
        _photoSelectBtn.backgroundColor = [UIColor clearColor];
        _photoSelectBtn.contentMode = UIViewContentModeTopRight;
        _photoSelectBtn.adjustsImageWhenHighlighted = NO;
        [_photoSelectBtn setImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
        [_photoSelectBtn setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
        [_photoSelectBtn addTarget:self action:@selector(choosePhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoSelectBtn;
}

- (void)setThumbUrl:(NSURL *)thumbUrl {
    if (thumbUrl.absoluteString.length > 0) {
        _thumbUrl = thumbUrl;
        if (![_thumbUrl.absoluteString containsString:@"w="] && ![_thumbUrl.absoluteString containsString:@"gif"]) {
            _thumbUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@w=%d&h=%d", _thumbUrl.absoluteString, [_thumbUrl.absoluteString containsString:@"?"] ? @"&" : @"?", (int)self.width, (int)self.height]];
        }
        NSString *placeholdImagePath = [[NSBundle mainBundle] pathForResource:@"PhotoDownload" ofType:@"png"];
        UIImage *placeHolderImage = [UIImage imageWithContentsOfFile:placeholdImagePath];
        [self.imageView qim_setImageWithURL:_thumbUrl placeholderImage:placeHolderImage];
    } else {
        self.imageView.image = [UIImage imageNamed:@"LaunchImage"];
    }
}

- (void)setVideoDuration:(NSString *)videoDuration {
    if (videoDuration.length > 0 && self.type == QIMMWTypeVideo) {
        _videoDuration = videoDuration;
        [self.videoLabel setText:videoDuration];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundView = nil;
        self.selectedBackgroundView = nil;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)setType:(QIMMWType)type {
    _type = type;
    if (type == QIMMWTypeVideo) {
        [self addSubview:self.tagView];
        [self addSubview:self.videoLabel];
        self.tagView.hidden = NO;
    } else {
        self.tagView.hidden = YES;
        self.videoLabel.hidden = YES;
    }
}

- (void)setShouldChooseFlag:(BOOL)shouldChooseFlag {
    if (shouldChooseFlag) {
        self.photoSelectBtn.hidden = NO;
        [self.contentView addSubview:self.photoSelectBtn];
    } else {
        self.photoSelectBtn.hidden = YES;
        self.photoSelectBtn.selected = NO;
    }
}

- (void)choosePhoto:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectedQIMMWPhotoSectionBrowserChoose:)]) {
            [self.delegate selectedQIMMWPhotoSectionBrowserChoose:self.photo];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(deSelectedQIMMWPhotoSectionBrowserChoose:)]) {
            [self.delegate deSelectedQIMMWPhotoSectionBrowserChoose:self.photo];
        }
    }
}

@end
