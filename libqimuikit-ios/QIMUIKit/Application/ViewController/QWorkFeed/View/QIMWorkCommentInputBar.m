//
//  QIMWorkCommentInputBar.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/10.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkCommentInputBar.h"
#import "QIMWorkCommentTextView.h"
#import "QIMWorkMomentUserIdentityModel.h"

@interface QIMWorkCommentInputBar () <UITextViewDelegate>

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UIImageView *headerImageView;

@property (nonatomic, strong) QIMWorkCommentTextView *commentTextView;

@property (nonatomic, strong) UIButton *likeBtn;

@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, strong) UILabel *placeholderLabel;

@property (nonatomic, assign) BOOL isLike;

@property (nonatomic, assign) NSInteger likeNum;

@end

@implementation QIMWorkCommentInputBar

- (BOOL)isInputBarFirstResponder {
    return [self.commentTextView isFirstResponder];
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(_headerImageView.right - 5, _headerImageView.bottom - 5, 5, 5)];
        _iconView.backgroundColor = [UIColor whiteColor];
        _iconView.image = [UIImage imageNamed:@"q_work_triangle"];
    }
    return _iconView;
}

- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 36, 36)];
        _headerImageView.layer.cornerRadius = 18.0f;
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.layer.borderColor = [UIColor qim_colorWithHex:0xDFDFDF].CGColor;
        _headerImageView.layer.borderWidth = 1.0f;
        [_headerImageView qim_setImageWithJid:[[QIMKit sharedInstance] getLastJid]];
        _headerImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUserIdentifierVC:)];
        [_headerImageView addGestureRecognizer:tap];
    }
    return _headerImageView;
}

- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - 62, 17, 52, 26);
        [_likeBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e0e7" size:26 color:[UIColor qim_colorWithHex:0x999999]]] forState:UIControlStateNormal];
        [_likeBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e0cd" size:26 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateSelected];
        [_likeBtn setTitle:@"顶" forState:UIControlStateNormal];
        [_likeBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateNormal];
        [_likeBtn setTitleColor:[UIColor qim_colorWithHex:0x999999] forState:UIControlStateSelected];
        [_likeBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_likeBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
        [_likeBtn addTarget:self action:@selector(didLikeComment:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - 46, 10, 36, 36);
        [_sendBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e644" size:36 color:[UIColor qim_colorWithHex:0xBFBFBF]]] forState:UIControlStateDisabled];
        [_sendBtn setImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000e644" size:36 color:[UIColor qim_colorWithHex:0x00CABE]]] forState:UIControlStateNormal];
        _sendBtn.layer.cornerRadius = 18.0f;
        _sendBtn.layer.masksToBounds = YES;
        _sendBtn.hidden = YES;
        _sendBtn.enabled = NO;
        [_sendBtn addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 8, 90, 21)];
        _placeholderLabel.text = @"  快来说几句…";
        _placeholderLabel.numberOfLines = 0;
        _placeholderLabel.font = [UIFont systemFontOfSize:15];
        _placeholderLabel.textColor = [UIColor qim_colorWithHex:0x999999];
    }
    return _placeholderLabel;
}

- (QIMWorkCommentTextView *)commentTextView {
    if (!_commentTextView) {
        _commentTextView = [[QIMWorkCommentTextView alloc] initWithFrame:CGRectMake(self.headerImageView.right + 6, 10, CGRectGetWidth(self.frame) - self.headerImageView.right - 6 - 16 - self.likeBtn.width - 6, 36)];
        _commentTextView.textAlignment = NSTextAlignmentLeft;
        _commentTextView.delegate = self;
        _commentTextView.backgroundColor = [UIColor qim_colorWithHex:0xF0F0F0];
        _commentTextView.font = [UIFont systemFontOfSize:16];
        _commentTextView.contentInset = UIEdgeInsetsMake(0, 10.0f, 0, 10.0f);
        [_commentTextView addSubview:self.placeholderLabel];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.3) {
            [_commentTextView setValue:self.placeholderLabel forKey:@"_placeholderLabel"];
        }
        _commentTextView.layer.cornerRadius = 18.0f;
        _commentTextView.layer.masksToBounds = YES;
        _commentTextView.returnKeyType = UIReturnKeySend;
    }
    return _commentTextView;
}

- (void)resignFirstInputBar:(BOOL)flag {
    if (flag) {
        self.sendBtn.hidden = NO;
        if (self.commentTextView.text.length <= 0) {
            self.sendBtn.enabled = NO;
        } else {
            self.sendBtn.enabled = YES;
        }
        self.likeBtn.hidden = YES;
        self.commentTextView.frame = CGRectMake(self.headerImageView.right + 6, 10, CGRectGetWidth(self.frame) - self.headerImageView.right - 6 - self.likeBtn.width - 6, 36);
        [self bringSubviewToFront:self.sendBtn];
    } else {
        self.sendBtn.hidden = YES;
        self.likeBtn.hidden = NO;
        self.commentTextView.frame = CGRectMake(self.headerImageView.right + 6, 10, CGRectGetWidth(self.frame) - self.headerImageView.right - 6 - 16 - self.likeBtn.width - 15, 36);
        [self sendSubviewToBack:self.sendBtn];
        self.placeholderLabel.text = @"  快来说几句…";
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
        self.layer.shadowOffset = CGSizeMake(0,-2.5);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 7.5;
        
        [self addSubview:self.headerImageView];
        [self addSubview:self.iconView];
        [self addSubview:self.sendBtn];
        [self addSubview:self.likeBtn];
        [self addSubview:self.commentTextView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUserIdentifier) name:@"kReloadUserIdentifier" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setLikeNum:(NSInteger)likeNum withISLike:(BOOL)isLike {
    _likeNum = likeNum;
    _isLike = isLike;
    if (isLike) {
        _likeBtn.selected = YES;
        [_likeBtn setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateSelected];
    } else {
        _likeBtn.selected = NO;
        if (likeNum > 0) {
            [_likeBtn setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateNormal];
        } else {
            [_likeBtn setTitle:@"顶" forState:UIControlStateNormal];
        }
    }
}

- (void)reloadUserIdentifier {
    if ([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] == NO) {
        [self.headerImageView qim_setImageWithJid:[[QIMKit sharedInstance] getLastJid]];
    } else {
        NSString *anonymousName = [[QIMWorkMomentUserIdentityManager sharedInstance] anonymousName];
        NSString *anonymousPhoto = [[QIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto];
        if (![anonymousPhoto qim_hasPrefixHttpHeader]) {
            anonymousPhoto = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], anonymousPhoto];
        } else {
            
        }
        [self.headerImageView qim_setImageWithURL:[NSURL URLWithString:anonymousPhoto]];
    }
}

- (void)beginCommentToUserId:(NSString *)userId {
    self.placeholderLabel.text = [NSString stringWithFormat:@"%@", userId];
    [self.commentTextView becomeFirstResponder];
}

- (void)didLikeComment:(UIButton *)sender {
    BOOL likeFlag = !sender.selected;
    [[QIMKit sharedInstance] likeRemoteMomentWithMomentId:self.momentId withLikeFlag:likeFlag withCallBack:^(NSDictionary *responseDic) {
        if (responseDic.count > 0) {
            NSLog(@"点赞成功");
            BOOL islike = [[responseDic objectForKey:@"isLike"] boolValue];
            NSInteger likeNum = [[responseDic objectForKey:@"likeNum"] integerValue];
            if (islike) {
                [sender setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateSelected];
                sender.selected = YES;
            } else {
                if (likeNum > 0) {
                    [sender setTitle:[NSString stringWithFormat:@"%ld", likeNum] forState:UIControlStateNormal];
                } else {
                    [sender setTitle:@"顶" forState:UIControlStateNormal];
                }
                sender.selected = NO;
            }
        } else {
            NSLog(@"点赞失败");
        }
    }];
}

- (void)openUserIdentifierVC:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didOpenUserIdentifierVC)]) {
        [self.delegate didOpenUserIdentifierVC];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        [self.sendBtn setEnabled:YES];
    } else {
        [self.sendBtn setEnabled:NO];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.commentTextView && [text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        NSLog(@"text : %@", text);
        if (self.delegate && [self.delegate respondsToSelector:@selector(didaddCommentWithStr:)]) {
            [self sendComment];
        }
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}

- (void)sendComment {
    if (self.commentTextView.text.length > 0) {
        [self.delegate didaddCommentWithStr:self.commentTextView.text];
        self.commentTextView.text = nil;
        [self.commentTextView resignFirstResponder];
    }
}

@end
