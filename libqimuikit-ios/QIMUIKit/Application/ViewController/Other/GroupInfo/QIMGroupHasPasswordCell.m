//
//  QIMGroupHasPasswordCell.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/17.
//
//

#import "QIMGroupHasPasswordCell.h"

@interface QIMGroupHasPasswordCell(){
    UIView      *_rootView;
    UILabel     *_titleLabel;
    UISwitch    *_switchBtn;
}
@end
@implementation QIMGroupHasPasswordCell

+ (CGFloat)getCellHeight{
    return 40;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [QIMGroupHasPasswordCell getCellHeight])];
        [_rootView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_rootView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setText:@"🔒密码"];
        [_rootView addSubview:_titleLabel];
        
        _switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
        [_switchBtn addTarget:self
                       action:@selector(onSwitchClicked:)
             forControlEvents:UIControlEventValueChanged];
        [self setAccessoryView:_switchBtn];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, _rootView.height - 0.5, _rootView.width - 10, 0.5)];
        [line setBackgroundColor:[UIColor qim_colorWithHex:0xd1d1d1 alpha:1]];
        [_rootView addSubview:line];
        
    }
    return self;
}

- (void) onSwitchClicked:(id) sender {
    UISwitch *switchBtn = (UISwitch *) sender;
    BOOL on = switchBtn.on;
    if ([self.delegate respondsToSelector:@selector(setGroupHasPassword:)]) {
        if (![self.delegate setGroupHasPassword:on]) {
            [switchBtn setOn:!on animated:YES];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshUI{
    [_switchBtn setOn:self.hasPassword];
}

@end
