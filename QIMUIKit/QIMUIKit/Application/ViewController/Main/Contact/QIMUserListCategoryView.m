//
//  QIMUserListCategoryView.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/1/17.
//

#import "QIMUserListCategoryView.h"
#import "QIMCommonFont.h"
#import "QIMIconInfo.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMUserListCategoryView ()

@property (nonatomic, strong) NSArray *categoryList;

@end

@implementation QIMUserListCategoryView

- (instancetype)initWithFrame:(CGRect)frame WithCategoryList:(NSArray *)types{
    self = [super initWithFrame:frame];
    if (self) {
        self.categoryList = types;
        [self setupCateoryListView];
    }
    return self;
}

- (void)reloadData {
    [self removeAllSubviews];
    [self setupCateoryListView];
}

- (void)setupCateoryListView {
    UIView *lastCateoryView = [UIView new];
    for (NSInteger i = 0; i < self.categoryList.count; i++) {
        UserListCategoryType type = [[self.categoryList objectAtIndex:i] integerValue];
        lastCateoryView = [self singleCateoryListViewWithType:type WithLastView:lastCateoryView];
        [self addSubview:lastCateoryView];
        if (i != self.categoryList.count - 1) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(60, lastCateoryView.bottom, lastCateoryView.width - 60 - 10, 0.5f)];
            lineView.backgroundColor = [UIColor qim_colorWithHex:0xEEEEEE alpha:1.0];
            [self addSubview:lineView];
        }
    }
}

- (UIView *)singleCateoryListViewWithType:(UserListCategoryType)type WithLastView:(UIView *)lastView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, lastView.bottom, self.width, 54)];
    view.tag = type;
    
    UIView *iconBgView = [[UIView alloc] initWithFrame:CGRectMake(17, 8, 36, 36)];
    iconBgView.backgroundColor = [self getCategoryIcoBgColor:type];
    iconBgView.layer.cornerRadius = 18.0f;
    iconBgView.layer.masksToBounds = YES;
    [view addSubview:iconBgView];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 20, 20)];
    iconImageView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:[self getCategoryIconImageName:type] size:26 color: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0]]];
    [iconBgView addSubview:iconImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconBgView.right + 10, 15, 150, 24)];
    [titleLabel setText:[self getCategoryTitle:type]];
    [titleLabel setTextColor:[UIColor qtalkTextBlackColor]];
//    _nameLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
    [titleLabel setFont:[UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4]];
    [view addSubview:titleLabel];
    [view setAccessibilityIdentifier:[self getCategoryTitle:type]];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectUserListCategoryView:)];
    [view addGestureRecognizer:gesture];
    return view;
}

- (NSString *)getCategoryTitle:(UserListCategoryType)type {
    switch (type) {
        case UserListCategoryTypeNotRead: {
            return [NSBundle qim_localizedStringForKey:@"contact_tab_not_read"];
        }
            break;
        case UserListCategoryTypeFriend: {
            return [NSBundle qim_localizedStringForKey:@"contact_tab_friend"];
        }
            break;
        case UserListCategoryTypeGroup: {
            return [NSBundle qim_localizedStringForKey:@"contact_tab_group"];
        }
            break;
        case UserListCategoryTypePublicNumber: {
            return [NSBundle qim_localizedStringForKey:@"contact_tab_public_number"];
        }
            break;
        case UserListCategoryTypeOrganizational: {
            return [NSBundle qim_localizedStringForKey:@"contact_tab_organization"];
        }
            break;
        default:
            break;
    }
}

- (NSString *)getCategoryIconImageName:(UserListCategoryType)type {
    switch (type) {
        case UserListCategoryTypeNotRead: {
            return @"\U0000f0f4";
        }
            break;
        case UserListCategoryTypeFriend: {
            return @"\U0000f0eb";
        }
            break;
        case UserListCategoryTypeGroup: {
            return @"\U0000f10f";
        }
            break;
        case UserListCategoryTypePublicNumber: {
            return @"\U0000f130";
        }
            break;
        case UserListCategoryTypeOrganizational: {
            return @"\U0000f11d";
        }
            break;
        default:
            break;
    }
}

- (UIColor *)getCategoryIcoBgColor:(UserListCategoryType)type {
    switch (type) {
        case UserListCategoryTypeNotRead: {
            return [UIColor colorWithRed:250/255.0 green:136/255.0 blue:41/255.0 alpha:1/1.0];
        }
            break;
        case UserListCategoryTypeFriend: {
            return [UIColor colorWithRed:93/255.0 green:115/255.0 blue:229/255.0 alpha:1/1.0];
        }
            break;
        case UserListCategoryTypeGroup: {
            return [UIColor colorWithRed:6/255.0 green:181/255.0 blue:36/255.0 alpha:1/1.0];
        }
            break;
        case UserListCategoryTypePublicNumber: {
            return [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1/1.0];
        }
            break;
        case UserListCategoryTypeOrganizational: {
            return [UIColor colorWithRed:92/255.0 green:197/255.0 blue:127/255.0 alpha:1/1.0];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITapGestureMethod

- (void)didSelectUserListCategoryView:(UITapGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    UserListCategoryType type = view.tag;
    if (self.categoryViewDelegate && [self.categoryViewDelegate respondsToSelector:@selector(didSelectUserListCategoryRowAtCategoryType:)]) {
        [self.categoryViewDelegate didSelectUserListCategoryRowAtCategoryType:type];
    }
}

@end
