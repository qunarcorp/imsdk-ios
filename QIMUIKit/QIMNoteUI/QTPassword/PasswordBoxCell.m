//
//  PasswordBoxCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/19.
//
//

#import "PasswordBoxCell.h"
#import "QIMNoteModel.h"
#import "QIMNoteUICommonFramework.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define NormalImage [UIImage imageNamed:@"PasswordBox_favorite_normal"]
#define FavoriteImage [UIImage imageNamed:@"PasswordBox_favorite_selected"]

@interface PasswordBoxCell ()
{
    BOOL _selected;
}

@property (nonatomic, strong) UIButton *favoriteView;

@property (nonatomic, strong) QIMNoteModel *model;

@property (nonatomic, strong) UIImageView *selectBtn;


@end

@implementation PasswordBoxCell

- (void)setQIMNoteModel:(QIMNoteModel *)model {
    if (model != nil) {
        _model = model;
        [self refreshUI];
    }
}

- (UIImageView *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 24, 24)];
        [_selectBtn setImage:[UIImage imageNamed:@"common_checkbox_no_44px"]];
        _selectBtn.centerY = self.contentView.centerY;
    }
    return _selectBtn;
}

- (UIButton *)favoriteView {
    if (!_favoriteView) {
        _favoriteView = [UIButton buttonWithType:UIButtonTypeCustom];
        _favoriteView.frame = CGRectMake(SCREEN_WIDTH - 60, 0, 24, 24);
        [_favoriteView addTarget:self action:@selector(favoritePasswordBox:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _favoriteView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _selected = NO;
        self.imageView.image = [UIImage imageNamed:@"explore_tab_passwordBox"];
    }
    return self;
}

- (void)favoritePasswordBox:(id)sender {
    QIMVerboseLog(@"%s", __func__);
    if (self.model.q_state == QIMNoteStateFavorite) {
        self.model.q_state = QIMNoteStateNormal;
        [self.favoriteView setImage:NormalImage forState:UIControlStateNormal];
    } else {
        self.model.q_state = QIMNoteStateFavorite;
        [self.favoriteView setImage:FavoriteImage forState:UIControlStateNormal];
    }
    [[QIMNoteManager sharedInstance] updateQTNoteMainItemStateWithModel:self.model];
}

- (void)refreshUI {
    if (self.isSelect) {
        [self.contentView addSubview:self.selectBtn];
    }
    if (self.model.q_state != QIMNoteStateBasket) {
        [self.contentView addSubview:self.favoriteView];
        self.favoriteView.centerY = self.contentView.centerY;
    }
    self.textLabel.text = self.model.q_title;
    if (self.model.q_state == QIMNoteStateFavorite) {
        [self.favoriteView setImage:FavoriteImage forState:UIControlStateNormal];
    } else {
        [self.favoriteView setImage:NormalImage forState:UIControlStateNormal];
    }
}

- (void)setCellSelected:(BOOL)selected {
    _selected = selected;
    [self.selectBtn setImage:selected ? [UIImage imageNamed:@"common_checkbox_yes_44px"] : [UIImage imageNamed:@"common_checkbox_no_44px"]];
}

- (BOOL)isCellSelected {
    return _selected;
}

@end
