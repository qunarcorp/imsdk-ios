//
//  QIMFaceViewCell.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/9.
//
//

#import "QIMFaceViewCell.h"
#import "QIMEmotionTip.h"

@interface QIMFaceViewCell ()

@end

static CGPoint tipPoint;

@implementation QIMFaceViewCell

- (YLImageView *)emojiView {
    
    if (!_emojiView) {
        
        _emojiView = [[YLImageView alloc] initWithFrame:self.bounds];
        _emojiView.width = (self.contentView.width * 2) / 3.0f;
        _emojiView.height = (self.contentView.height * 2) / 3.0f;
        _emojiView.center = self.contentView.center;
        _emojiView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _emojiView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.contentView addSubview:self.emojiView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    switch (self.emotionType) {
        case QTalkEmotionTypeShowAll: {
            self.emojiView.width = (self.contentView.width * 2) / 3.0f;
            self.emojiView.height = (self.contentView.height * 2) / 3.0f;
            self.emojiView.center = self.contentView.center;
        }
            break;
        case QTalkEmotionTypeNormal: {
            self.emojiView.width = self.contentView.width;
            self.emojiView.height = self.contentView.height;
            self.emojiView.center = self.contentView.center;
        }
            break;
        default:
            break;
    }
}

- (CGPoint)tipFloatPoint {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tipPoint = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetMaxY(self.emojiView.frame));
    });
    
    return tipPoint;
}

- (void)didMoveIn {
    QIMVerboseLog(@"%s", __func__);
    switch (self.emotionType) {
        case QTalkEmotionTypeShowAll: {
            if (self.tag != -1 && self.tag != 0) {
                [[QTalkShowAllEmojiTip sharedTip] showTipOnCell:self];
            }
        }
            break;
        case QTalkEmotionTypeNormal: {
            [[QTalkGifEmojiTip sharedTip] showTipOnCell:self];
        }
            break;
        default:
            break;
    }
}

- (void)didMoveOut {
    QIMVerboseLog(@"%s", __func__);
    switch (self.emotionType) {
        case QTalkEmotionTypeShowAll: {
            if (self.tag != -1  && self.tag != 0) {
                [[QTalkShowAllEmojiTip sharedTip] showTipOnCell:nil];
            }
        }
            break;
        case QTalkEmotionTypeNormal: {
            [[QTalkGifEmojiTip sharedTip] showTipOnCell:nil];
        }
            break;
        default:
            break;
    }
}

@end
