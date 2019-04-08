//
//  QIMCommonUserProfileCellManager.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/25.
//

#import "QIMCommonUserProfileCellManager.h"
#import "QIMMWPhotoBrowser.h"
#import "QIMCommonUserInfoCell.h"
#import "QIMCommonTableViewCell.h"
#import "QIMCommonUserInfoHeaderCell.h"
#import "QIMMenuView.h"
#import "QIMWebView.h"
#import "QIMUserInfoModel.h"
#import "QIMModifyRemarkViewController.h"
#import "QIMMySignatureViewController.h"
#import "QIMCommonFont.h"
#import "NSBundle+QIMLibrary.h"

#define QCMineProfileCellHeight     79.0f
#define QCMineOtherCellHeight       [[QIMCommonFont sharedInstance] currentFontSize] + 24
#define QCMineSectionHeaderHeight   10.0f
#define QCMineMinSectionHeight      0.00001f

@interface QIMCommonUserProfileCellManager () <QIMMWPhotoBrowserDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIViewController *rootVC;
@property (nonatomic, copy) NSString *userId;

@end

@implementation QIMCommonUserProfileCellManager

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController WithUserId:(NSString *)userId {
    if (self = [super init]) {
        self.rootVC = rootViewController;
        self.userId = userId;
    }
    return self;
}

#pragma mark - Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *userProfileRowType = self.dataSource[indexPath.section][indexPath.row];
    CGFloat cellRowHeight = 44;
    switch (userProfileRowType.integerValue) {
        case QCUserProfileHeader:
        case QCUserProfileUserInfo: {
            cellRowHeight = QCMineProfileCellHeight;
        }
            break;
        case QCUserProfileRNView: {
            
#if defined (QIMOPSRNEnable) && QIMOPSRNEnable == 1
            Class RunC = NSClassFromString(@"QTalkCardRNView");
            SEL sel = NSSelectorFromString(@"getQtalkCardRNViewHeight");
            if ([RunC respondsToSelector:sel]) {
                cellRowHeight = [[RunC performSelector:sel] floatValue];
            }
#endif
        }
            break;
        case QCUserProfileDepartment: {
            CGSize size = [self.model.department qim_sizeWithFontCompatible:[UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 4] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 70, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            cellRowHeight = MAX([[QIMCommonFont sharedInstance] currentFontSize] + 32, size.height + 10);
        }
            break;
        default: {
            cellRowHeight = QCMineOtherCellHeight;
        }
            break;
    }
    return cellRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.00001f;
    }
    return QCMineSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return QCMineMinSectionHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSNumber *userProfileRowType = self.dataSource[indexPath.section][indexPath.row];
    switch ([userProfileRowType integerValue]) {
//            QCUserProfileUserInfo,      //用户
//            QCUserProfileHeader,        //头像
//            QCUserProfileUserSignature,      //个性签名
//            QCUserProfileMyQrcode,      //二维码
//            QCUserProfileRemark,        //备注
//            QCUserProfileUserName,      //用户名称
//            QCUserProfileUserId,        //用户Id
//            QCUserProfileLeader,        //直属上级
//            QCUserProfileWorderId,      //工号
//            QCUserProfilePhoneNumber,   //手机号
//            QCUserProfileDepartment,    //部门
//            QCUserProfileComment,       //评论
//            QCUserProfileSendMail,      //发送邮件
//            QCUserProfileRNView,        //RN展示
//            QCUserProfileCustom,        //自定义
        case QCUserProfileUserInfo: {
            [self onUserHeaderClick];
        }
            break;
        case QCUserProfileHeader: {
//            QIMVerboseLog(@"查看大图");
            __weak typeof(self) weakSelf = self;
            UIAlertController *sheetVc = [UIAlertController alertControllerWithTitle:@"选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *showHeaderAction = [UIAlertAction actionWithTitle:@"查看头像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf onUserHeaderClick];
            }];
            UIAlertAction *pickerPhotoAction = [UIAlertAction actionWithTitle:@"相册中获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIImagePickerController *picker = [[UIImagePickerController alloc]init];
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
                }
                picker.delegate = self;
                picker.allowsEditing = YES;
                [weakSelf.rootVC presentViewController:picker animated:YES completion:nil];
            }];
            UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    
                    UIImagePickerControllerSourceType souceType = UIImagePickerControllerSourceTypeCamera;
                    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
                    picker.delegate = self;
                    picker.allowsEditing = YES;
                    picker.sourceType = souceType;
                    [weakSelf.rootVC presentViewController:picker animated:YES completion:nil];
                } else {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设备不支持拍照" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
            [sheetVc addAction:showHeaderAction];
            [sheetVc addAction:pickerPhotoAction];
            [sheetVc addAction:takePhoto];
            [sheetVc addAction:cancelAction];
            [self.rootVC presentViewController:sheetVc animated:YES completion:nil];
        }
            break;
        case QCUserProfileUserSignature: {
            QIMMySignatureViewController * mySignVC = [[QIMMySignatureViewController alloc] init];
            mySignVC.userId = [[QIMKit sharedInstance] getLastJid];
            mySignVC.playholder = self.model.personalSignature;
            [self.rootVC.navigationController pushViewController:mySignVC animated:YES];
        }
            break;
        case QCUserProfileMyQrcode: {
            [QIMFastEntrance showQRCodeWithQRId:self.userId withType:QRCodeType_UserQR];
//            [QIMFastEntrance showQRCodeWithUserId:self.userId withName:self.model.name withType:QRCodeType_UserQR];
        }
            break;
        case QCUserProfileRemark: {
            QIMModifyRemarkViewController * modifyRemarkVC = [[QIMModifyRemarkViewController alloc] init];
            modifyRemarkVC.jid = self.userId;
            modifyRemarkVC.nickName = [_userInfo objectForKey:@"Name"];
            [self.rootVC.navigationController pushViewController:modifyRemarkVC animated:YES];
        }
            break;
        case QCUserProfileComment: {
            NSData *userInfoData = [self.userInfo objectForKey:@"UserInfo"];
            NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:userInfoData];
            NSString *commentUrl = [dic objectForKey:@"commenturl"];
            NSURL *url = [NSURL URLWithString:commentUrl];
            NSString *query = [url query];
            NSString *baseUrl = nil;
            if (query.length > 0) {
                baseUrl =[commentUrl substringToIndex:commentUrl.length - query.length - 1];
                query = [query stringByAppendingString:@"&"];
            } else {
                baseUrl = commentUrl;
                query = @"";
            }
            commentUrl = [NSString stringWithFormat:@"%@?%@u=%@&k=%@&t=%@",
                          baseUrl,
                          query,
                          [[QIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                          [[QIMKit sharedInstance] myRemotelogginKey],
                          [self.userInfo objectForKey:@"UserId"]];
            
            QIMWebView *webView = [[QIMWebView alloc] init];
            [webView setUrl:commentUrl];
            [self.rootVC.navigationController pushViewController:webView animated:YES];
        }
            break;
        case QCUserProfileSendMail: {
            NSString *userId = [self.userInfo objectForKey:@"UserId"];
            [[QIMFastEntrance sharedInstance] sendMailWithRootVc:self.rootVC ByUserId:userId.length?userId:@"lilulucas.li"];
        }
            break;
        default:
            break;
    }
}

#pragma mark - DataSource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *userProfileRowType = self.dataSource[indexPath.section][indexPath.row];
    switch ([userProfileRowType integerValue]) {
        case QCUserProfileUserInfo: {
            NSString *cellId = [NSString stringWithFormat:@"QCUserProfileUserInfo_%lu", (unsigned long)QCUserProfileUserInfo];
            QIMCommonUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (!cell) {
                cell = [[QIMCommonUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
             }
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.avatarImage qim_setImageWithJid:self.userId];
//            cell.avatarImage.image = [[QIMKit sharedInstance] getUserHeaderImageByUserId:self.userId];
            cell.nickNameLabel.text = self.model.name;
            cell.signatureLabel.text = self.model.personalSignature;
            [cell setAccessibilityIdentifier:@"user_header"];
            return cell;
        }
            break;
        case QCUserProfileHeader: {
            NSString *cellId = [NSString stringWithFormat:@"QCUserProfileHeader_%lu;", (unsigned long)QCUserProfileHeader];
            QIMCommonUserInfoHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (!cell) {
                cell = [[QIMCommonUserInfoHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.avatarImage.image = [[QIMKit sharedInstance] getUserHeaderImageByUserId:self.userId];
            [cell.avatarImage qim_setImageWithJid:self.userId];
            cell.textLabel.text = @"头像";
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            return cell;
        }
            break;
        case QCUserProfileUserSignature: {
            static NSString *cellIdentifier = @"Signature cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle qim_localizedStringForKey:@"user_introduce"]];
                QIMMenuView * menuView = [[QIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.tag = 1000;
                [cell.contentView addSubview:menuView];
            }
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = self.model.personalSignature;
            [cell setAccessibilityIdentifier:cellIdentifier];
            [(QIMMenuView * )[cell.contentView viewWithTag:1000] setCoprText:self.model.personalSignature];
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];

            return cell;
        }
            break;
        case QCUserProfileMyQrcode: {
            static NSString *cellIdentifier = @"MyQrcode cell";
            QIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [QIMCommonTableViewCell cellWithStyle:kQIMCommonTableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
            [cell setAccessibilityIdentifier:@"MyQrcode"];
            cell.accessoryType_LL = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSBundle qim_localizedStringForKey:@"myself_tab_qrcode"];
            cell.detailTextLabel.font = [UIFont fontWithName:@"QTalk-QChat" size:24];
            cell.detailTextLabel.text = @"\U0000f10d";
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            return cell;
        }
            break;
        case QCUserProfileRemark: {
            static NSString *cellIdentifier = @"Remark cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle qim_localizedStringForKey:@"user_remark"]];
                
                QIMMenuView * menuView = [[QIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.tag = 1000;
                [cell.contentView addSubview:menuView];
            }
            [cell setAccessibilityIdentifier:@"user_remark"];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSString * remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:self.userId];
            cell.detailTextLabel.text = remarkName?remarkName:@"设置备注";
            [cell setAccessibilityValue:remarkName?remarkName:@"设置备注"];
            [(QIMMenuView * )[cell.contentView viewWithTag:1000] setCoprText:remarkName];
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];

            return cell;
        }
            break;
        case QCUserProfileUserName: {
            static NSString *cellIdentifier = @"UserName cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle qim_localizedStringForKey:@"user_name"]];
                
                QIMMenuView * menuView = [[QIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.tag = 1000;
                [cell.contentView addSubview:menuView];
            }
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.detailTextLabel.text = self.model.name;
            
            [(QIMMenuView * )[cell.contentView viewWithTag:1000] setCoprText:self.model.name];
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];

            return cell;
        }
            break;
        case QCUserProfileUserId: {
            static NSString *cellIdentifier = @"UserId cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle qim_localizedStringForKey:@"user_id"]];
                cell.detailTextLabel.text = self.model.ID;
                
                QIMMenuView * menuView = [[QIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.coprText = self.model.ID;
                [cell.contentView addSubview:menuView];
            }
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];

            return cell;
        }
            break;
        case QCUserProfileDepartment: {
            static NSString *cellIdentifier = @"DescInfo cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[QIMKit getQIMProjectType] == QIMProjectTypeQChat ? [NSBundle qim_localizedStringForKey:@"user_introduce"] : [NSBundle qim_localizedStringForKey:@"user_department"]];
                cell.detailTextLabel.text = self.model.department;
                
                CGSize size = [self.model.department qim_sizeWithFontCompatible:[UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 4] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 70, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
                QIMMenuView * menuView = [[QIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, MAX([[QIMCommonFont sharedInstance] currentFontSize] + 32, size.height + 10))];
                menuView.coprText = self.model.department;
                [cell.contentView addSubview:menuView];
            }
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.textLabel.textAlignment = NSTextAlignmentRight;
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.detailTextLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            return cell;
        }
            break;
        case QCUserProfileRNView: {
            
            static NSString *cellIdentifier = @"ReactViewCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            #if defined (QIMOPSRNEnable) && QIMOPSRNEnable == 1
                Class RunC = NSClassFromString(@"QTalkCardRNView");
                SEL sel = NSSelectorFromString(@"getQTalkCardRNViewWithFrameStr:withParam:");
                SEL selH = NSSelectorFromString(@"getQtalkCardRNViewHeight");
                CGFloat height = 0;
                if ([RunC respondsToSelector:selH]) {
                    height = [[RunC performSelector:selH] floatValue];
                }
                UIView *rnCardView = nil;
                if ([RunC respondsToSelector:sel]) {
                    CGRect rect = CGRectMake(0, 0, tableView.width, height);
                    NSString *frameStr = NSStringFromCGRect(rect);
                    rnCardView = [RunC performSelector:sel withObject:frameStr withObject:@{}];
                }

                [cell.contentView addSubview:rnCardView];
            #endif
            }
            return cell;
        }
            break;
        case QCUserProfileComment: {
            static NSString *cellIdentifier = @"comment cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle qim_localizedStringForKey:@"user_comment"]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            return cell;

        }
            break;
        case QCUserProfileSendMail: {
            static NSString *cellIdentifier = @"SendMail cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle qim_localizedStringForKey:@"user_send_mail"]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            return cell;
        }
            break;
        case QCUserProfilePhoneNumber: {
            static NSString *cellIdentifier = @"MobileNo cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle qim_localizedStringForKey:@"user_mobile_no"]];
                // 手机号
                cell.detailTextLabel.text = @"点击查看";
                
                CGSize size = [self.model.department qim_sizeWithFontCompatible:[UIFont systemFontOfSize:[[QIMCommonFont sharedInstance] currentFontSize] - 4] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 70, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
                QIMMenuView * menuView = [[QIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, MAX([[QIMCommonFont sharedInstance] currentFontSize] + 32, size.height + 10))];
                menuView.coprText = self.model.department;
                [cell.contentView addSubview:menuView];
            }
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.textColor = [UIColor qim_colorWithHex:0x999999 alpha:1];
            cell.detailTextLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            return cell;
        }
            break;
        default: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                [cell setBackgroundColor:[UIColor clearColor]];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            return cell;
        }
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
}

#pragma mark - QIMUserInfoTableViewCell Delegate
- (void)onUserHeaderClick{
    QIMMWPhotoBrowser *browser = [[QIMMWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.zoomPhotosToFill = YES;
    browser.enableSwipeToDismiss = NO;
    [browser setCurrentPhotoIndex:0];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    
    //初始化navigation
    QIMNavController *nc = [[QIMNavController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.rootVC presentViewController:nc animated:YES completion:nil];
}

#pragma mark - QIMMWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(QIMMWPhotoBrowser *)photoBrowser {
    return 1;
}

- (id <QIMMWPhoto>)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
#pragma mark - 查看大图
    //1. 根据userId读取本地大图路径
    //2. 本地路径存在 -> fileURLWithPath转URL
    //3. 本地路径不存在 -> 直接加载URL
    NSString *headerUrl = [[QIMKit sharedInstance] getUserHeaderSrcByUserId:self.userId];
    if (![headerUrl qim_hasPrefixHttpHeader]) {
        headerUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], headerUrl];
    }
    QIMMWPhoto *photo = [[QIMMWPhoto alloc] initWithURL:[NSURL URLWithString:headerUrl]];
    return photo;
}

- (void)photoBrowserDidFinishModalPresentation:(QIMMWPhotoBrowser *)photoBrowser {
    //界面消失
    [photoBrowser dismissViewControllerAnimated:YES completion:^{
        //tableView 回滚到上次浏览的位置
    }];
}

#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self saveImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image {
    image = [image qim_scaleToSize:CGSizeMake(120, 120)];
    NSData *currentImageData = UIImageJPEGRepresentation(image, 0.5);
    if (currentImageData) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[QIMKit sharedInstance] updateMyPhoto:currentImageData];
        });
    }
}

@end
