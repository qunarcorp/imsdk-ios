//
//  QIMMicroTourGuideCell.m
//  qunarChatIphone
//
//  Created by admin on 16/4/15.
//
//

#import "QIMMicroTourGuideCell.h"
#import "QIMMenuImageView.h"

@interface QIMMicroTourGuideCell()<QIMMenuImageViewDelegate>

@end
@implementation QIMMicroTourGuideCell{
    
    QIMMenuImageView *_backView;
    UILabel *_contentLabel;
    
}

+ (CGFloat)getCellHeigthWithMessage:(Message *)message{
    return 100;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _backView = [[QIMMenuImageView alloc] initWithFrame:CGRectZero];
        [_backView setDelegate:self];
        [_backView setUserInteractionEnabled:YES];
        [self.contentView addSubview:_backView];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_backView addSubview:_contentLabel];
        
    }
    return self;
}

@end
