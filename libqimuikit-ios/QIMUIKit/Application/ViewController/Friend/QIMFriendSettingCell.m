//
//  QIMFriendSettingCell.m
//  qunarChatIphone
//
//  Created by admin on 15/11/23.
//
//

#import "QIMFriendSettingCell.h"
#import "QIMCommonFont.h"

@implementation QIMFriendSettingItem

@end

@implementation QIMFriendSettingCell{ 
    UILabel *_titleLabel;
    UILabel *_descLabel;
    UIImageView *_selectedImageView;
}

+ (CGFloat)getCellHeight{
    return [[QIMCommonFont sharedInstance] currentFontSize] + 32;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, ([QIMFriendSettingCell getCellHeight] - 40)/2.0, self.width - 125 - 20, 40)];
        [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 2]];
        [_titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setNumberOfLines:0];
        [self.contentView addSubview:_titleLabel];
        
        _descLabel =  [[UILabel alloc] initWithFrame:CGRectMake(self.width - 125, ([QIMFriendSettingCell getCellHeight] - 20)/2.0, 100, 20)];
        [_descLabel setBackgroundColor:[UIColor clearColor]];
        [_descLabel setTextAlignment:NSTextAlignmentRight];
        [_descLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_descLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE - 4]];
        [_descLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_descLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.contentView addSubview:_descLabel];
        
        _selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, ([QIMFriendSettingCell getCellHeight] - 20)/2.0, 20, 20)];
        [_selectedImageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_selectedImageView setImage:[UIImage imageNamed:@"chat_group_selected"]];
        [self.contentView addSubview:_selectedImageView];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshUI{
    
    _titleLabel.frame = CGRectMake(10, ([QIMFriendSettingCell getCellHeight] - 40)/2.0, self.width - 125 - 20, 40);
    _descLabel.frame = CGRectMake(self.width - 125, ([QIMFriendSettingCell getCellHeight] - 20)/2.0, 100, 20);
    
    _titleLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 2];
    _descLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
    
    if (self.item.isVerifyMode && self.item.mode == VerifyMode_Question_Answer) {
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [_selectedImageView setLeft:self.width - 50];
        if (self.item.isSelected) { 
            [_descLabel setText:self.item.question];
        } else {
            [_descLabel setText:@""];
        }
    } else {
        [self setAccessoryType:UITableViewCellAccessoryNone];
        [_selectedImageView setLeft:self.width - 30];
    }
    if (self.item.isSelected) {
        [_selectedImageView setHidden:NO];
    } else {
        [_selectedImageView setHidden:YES];
    }
    [_titleLabel setText:self.item.title]; 
}

@end
