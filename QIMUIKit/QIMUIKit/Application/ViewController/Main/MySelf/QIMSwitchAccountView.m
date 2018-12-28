//
//  QIMSwitchAccountView.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/9/8.
//
//

#define kSwitchAccountViewItemWidth 80
#define kSwitchAccountViewNumPerLine 2
#define kMyCollectionFaceLines 2

#import "QIMSwitchAccountView.h"
static NSString *cellId = @"QIMSwitchAccountViewCellId";
@interface QIMSwitchAccountView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *accountCollectionView;

@property (nonatomic, strong) NSMutableArray *accounts;

@end

@implementation QIMSwitchAccountView

- (UICollectionView *)accountCollectionViewWithFrame:(CGRect)frame WithAccounts:(NSMutableArray *)accounts {
    if (!_accountCollectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(kSwitchAccountViewItemWidth, kSwitchAccountViewItemWidth);
        if (accounts.count == 1) {
            layout.sectionInset = UIEdgeInsetsMake(20, 70, 40, 70);
        } else {
            layout.sectionInset = UIEdgeInsetsMake(20, 20, 40, 20);
            layout.minimumLineSpacing = 40;
            layout.minimumInteritemSpacing = 15;
        }
        UICollectionView *collectFaceView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        collectFaceView.delegate = self;
        collectFaceView.dataSource = self;
        collectFaceView.backgroundColor = [UIColor whiteColor];
        collectFaceView.bounces = NO;
        collectFaceView.showsVerticalScrollIndicator = YES;
        collectFaceView.showsHorizontalScrollIndicator = NO;
        collectFaceView.pagingEnabled = YES;
        [collectFaceView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellId];
        _accountCollectionView = collectFaceView;
    }
    return _accountCollectionView;
}

- (instancetype)initWithFrame:(CGRect)frame WithAccounts:(NSMutableArray *)accounts{
    self = [super initWithFrame:frame];
    if (self) {
        if (accounts) {
            self.accounts = accounts;
        }
        [self addSubview:[self accountCollectionViewWithFrame:frame WithAccounts:accounts]];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    return self.accounts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *accountItem = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSDictionary *accountDict = [self.accounts objectAtIndex:indexPath.row];
    NSString *userFullJid = [accountDict objectForKey:@"userFullJid"];
    NSString *userId = [[userFullJid componentsSeparatedByString:@"@"] firstObject];
    BOOL addBtn = [userId isEqualToString:@"Add"] ? YES : NO;
    accountItem.contentView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    accountItem.contentView.layer.borderWidth = 0.5f;
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 45)];
//    [iconView setImage:addBtn ? [UIImage imageNamed:@"Card_AddIcon"] : [[QIMKit sharedInstance] getUserHeaderImageByUserId:userFullJid]];
    if (!addBtn) {
        [iconView qim_setImageWithJid:userFullJid];
    } else {
        [iconView setImage:[UIImage imageNamed:@"Card_AddIcon"]];
    }
    [accountItem.contentView addSubview:iconView];
    iconView.centerX = accountItem.contentView.centerX;
    if (addBtn) {
        iconView.center = accountItem.contentView.center;
    }
    if (addBtn != YES) {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, iconView.bottom + 5, accountItem.contentView.width, 25)];
        nameLabel.text = userFullJid;
        nameLabel.textColor = [UIColor qtalkTextLightColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [accountItem.contentView addSubview:nameLabel];
    }
    return accountItem;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    NSDictionary *accountDict = [self.accounts objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(swicthAccountWithAccount:)]) {
        [self.delegate swicthAccountWithAccount:accountDict];
    }
}

@end
