//
//  QIMNotReadMsgTipViews.m
//  qunarChatIphone
//
//  Created by admin on 16/5/6.
//
//

#import "QIMNotReadMsgTipViews.h"

@implementation QIMNotReadMsgTipViews{ 
    UIView *_backView;
    UIView *_leftView;
    UIImageView *_leftArrowImageView;
    UILabel *_titleLabel;
    int _notReadCount;
    NSString *_title;
}

- (CGFloat)getHeight{
    return 40;
}

- (CGFloat)getWidthForNotReadCount:(int)notReadCount{
    _title = [NSString stringWithFormat:@"%d条未读消息",notReadCount];
    CGSize titleSize = [_title sizeWithFont:[UIFont systemFontOfSize:14] forWidth:INT8_MAX lineBreakMode:NSLineBreakByCharWrapping];
    return titleSize.width + [self getHeight] / 2.0 - 5 + 10 + 14;
}

- (instancetype)initWithNotReadCount:(int)notReadCount{
    _notReadCount = notReadCount;
    return [self initWithFrame:CGRectMake(0, 0, [self getWidthForNotReadCount:notReadCount], [self getHeight])];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        _leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self getHeight], [self getHeight])];
        [_leftView setBackgroundColor:[UIColor whiteColor]];
        [_leftView.layer setCornerRadius:_leftView.height / 2.0];
        [self addSubview:_leftView];
        
        _backView = [[UIView alloc] initWithFrame:CGRectMake(_leftView.height/2.0, 0, self.width - _leftView.height/2.0, [self getHeight])];
        [_backView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_backView];
        
        _leftArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_backView.left - 5, ([self getHeight] - 14)/2.0, 14, 14)];
        [_leftArrowImageView setImage:[UIImage imageNamed:@"left_arrow"]];
        [self addSubview:_leftArrowImageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_leftArrowImageView.right, 0, self.width - 10 - (_backView.left - 5), [self getHeight])];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextColor:[UIColor qim_colorWithHex:0x1cb252 alpha:1]];
        [_titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_titleLabel setText:_title];
        [self addSubview:_titleLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)onClick{
    if (self.notReadMsgDelegate && [self.notReadMsgDelegate respondsToSelector:@selector(moveToFirstNotReadMsg)]) {
        [self.notReadMsgDelegate moveToFirstNotReadMsg];
    }
}

@end
