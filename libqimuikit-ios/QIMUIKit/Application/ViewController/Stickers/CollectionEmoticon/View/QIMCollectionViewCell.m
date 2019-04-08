//
//  QIMCollectionViewCell.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/6/1.
//
//

#import "QIMCollectionViewCell.h"
#import "YLImageView.h"
#import "QIMEmotionTip.h"
#import "QIMCollectionFaceManager.h"

@interface QIMCollectionViewCell ()

@property (nonatomic, strong) YLImageView *emojiView;

@property (nonatomic, assign) BOOL refresh;

@end

@implementation QIMCollectionViewCell

- (YLImageView *)emojiView {
    
    if (!_emojiView) {
        
        _emojiView = [[YLImageView alloc] initWithFrame:self.bounds];
        _emojiView.userInteractionEnabled = YES;
    }
    return _emojiView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        [self.contentView addSubview:self.emojiView];
    }
    return self;
}

- (void)setRefreshCount:(BOOL)refreshed {
    self.refresh = refreshed;
}

- (void)refreshUIWithFlag:(BOOL)flag {
    
    __weak typeof(self) weakSelf = self;
    if (flag) {
        
        if (self.tag == 0) {
        
            self.emojiView.image = [UIImage imageNamed:@"EmoticonAddButton"];

        } else if (self.tag == -1) {
            self.emojiView.image = [UIImage new];
            self.userInteractionEnabled = NO;
        } else {
            
            self.emojiView.image = [UIImage imageNamed:@"aio_ogactivity_default"];
            [[QIMCollectionFaceManager sharedInstance] showSmallImage:^(UIImage *downLoadImage) {

                weakSelf.emojiView.image = downLoadImage;

              } withIndex:self.tag - 1];
        }
    } else {
        self.emojiView.image = [UIImage new];
        self.userInteractionEnabled = NO;
        self.tag = -1;
    }
}

- (void)didMoveIn {
//    QIMVerboseLog(@"%s", __func__);
    if (self.tag != 0 && self.tag != -1) {
        [[QTalkGifEmojiTip sharedTip] showTipOnCell:self];
    }
}

- (void)didMoveOut {
//    QIMVerboseLog(@"%s", __func__);
    if (self.tag != 0 && self.tag != -1) {
        [[QTalkGifEmojiTip sharedTip] showTipOnCell:nil];
    }
}

@end
