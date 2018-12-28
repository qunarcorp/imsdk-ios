//
//  QIMUserListCategoryView.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/1/17.
//

#import "QIMCommonUIFramework.h"

typedef enum {
    UserListCategoryTypeNotRead,
    UserListCategoryTypeFriend,
    UserListCategoryTypeGroup,
    UserListCategoryTypePublicNumber,
    UserListCategoryTypeOrganizational,
} UserListCategoryType;

@protocol QIMUserListCategoryViewDelegate <NSObject>

- (void)didSelectUserListCategoryRowAtCategoryType:(UserListCategoryType)categoryType;

@end

@interface QIMUserListCategoryView : UIView

@property (nonatomic, weak) id <QIMUserListCategoryViewDelegate> categoryViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame WithCategoryList:(NSArray *)types;

- (void)reloadData;

@end
