//
//  QIMDefalutMessageCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/2.
//

#import "QIMMsgBaloonBaseCell.h"
#import "QIMDefalutMessageCell.h"
#import "QIMAttributedLabel.h"
#import "QIMMessageParser.h"

#define kTextLabelTop       10
#define kTextLableLeft      10
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kMyCellHeightCap    14
#define kMyBackViewCap      55
#define kMinTextWidth       30
#define kMinTextHeight      30

@interface QIMDefalutMessageCell () <QIMMenuImageViewDelegate>

@property (nonatomic, strong) QIMAttributedLabel *messageLabel;

@property (nonatomic, strong) QIMTextContainer *textContainer;

@end

@implementation QIMDefalutMessageCell

- (QIMAttributedLabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[QIMAttributedLabel alloc] init];
        _messageLabel.backgroundColor = [UIColor clearColor];
    }
    return _messageLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.backView addSubview:self.messageLabel];
    }
    return self;
}

- (void)refreshUI {
    self.selectedBackgroundView.frame = self.contentView.frame;
    if (!self.textContainer) {
        self.textContainer = [QIMMessageParser textContainerForMessage:self.message];
    }
    [self.messageLabel clearOwnerView];
    self.messageLabel.textContainer = self.textContainer;
    CGFloat backWidth = self.messageLabel.textContainer.textWidth + 2 * kTextLableLeft + 10;
    CGFloat backHeight = self.messageLabel.textContainer.textHeight + 20;
    [self.backView setText:self.message.message];
    self.backView.message = self.message;
    [self setBackViewWithWidth:backWidth WihtHeight:backHeight];
    [super refreshUI];
}

//判断是否有文字
- (BOOL)hasTextWithArray:(NSArray *)textStroages {
    
    BOOL flag = YES;
    for (id textStorage in textStroages) {
        
        if ([textStorage isKindOfClass:[QIMImageStorage class]]) {
            
            flag = NO;
            continue;
            
        } else {
            
            flag = YES;
            return YES;
            break;
        }
    }
    return flag;
}

//判断是否包含非Emotion表情和文字
- (BOOL)hasNoEmotionOrTestWithArray:(NSArray *)textStroages {
    
    BOOL flag = NO;
    NSInteger count = 0;
    for (id textStorage in textStroages) {
        
        if ([textStorage isKindOfClass:[QIMImageStorage class]]) {
            
            QIMImageStorage *imageStorage = textStorage;
            if (imageStorage.storageType == QIMImageStorageTypeEmotion) {
                
                flag = NO;
            } else {
                
                flag = YES;
                count++;
            }
            continue;
            
        }
    }
    if (count==1) {
        return YES;
    } else {
        return NO;
    }
    return flag;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.messageLabel setFrameWithOrign:CGPointMake(kTextLableLeft + (self.message.messageDirection == MessageDirection_Sent ? 0 : 10),10) Width:_textContainer.textWidth];
}

- (NSArray *)showMenuActionTypeList {
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
    switch (self.message.messageDirection) {
        case MessageDirection_Received: {
            if (self.textContainer.textStorages.count > 0 && [self hasTextWithArray:self.textContainer.textStorages]) {
                
                [menuList addObject:@(MA_Copy)];
            }
            if (self.textContainer.textStorages.count > 0 && [self hasNoEmotionOrTestWithArray:self.textContainer.textStorages]) {
                
                [menuList addObject:@(MA_Collection)];
            }
            [menuList addObjectsFromArray:@[@(MA_Refer),@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        case MessageDirection_Sent: {
            if (self.textContainer.textStorages.count > 0 && [self hasTextWithArray:self.textContainer.textStorages]) {
                
                [menuList addObject:@(MA_Copy)];
            }
            if (self.textContainer.textStorages.count > 0 && [self hasNoEmotionOrTestWithArray:self.textContainer.textStorages]) {
                
                [menuList addObject:@(MA_Collection)];
            }
            [menuList addObjectsFromArray:@[@(MA_Refer), @(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete), @(MA_Forward)]];
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

@end
