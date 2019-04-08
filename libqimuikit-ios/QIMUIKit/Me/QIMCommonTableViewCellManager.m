//
//  QIMCommonTableViewCellManager.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/21.
//

#import "QIMCommonTableViewCellManager.h"
#import "QIMCommonTableViewCellData.h"
#import "QIMCommonTableViewCell.h"
#import "QIMCommonUserInfoCell.h"
#import "QIMWebView.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMDataController.h"
#import "QIMFileManagerViewController.h"
#import "QIMFeedBackViewController.h"
#import "QIMAboutVC.h"
#import "QIMMySettingController.h"
#import "QIMDressUpController.h"
#import "QIMGroupChangeNameVC.h"
#import "QIMGroupChangeTopicVC.h"
#import "QIMFriendSettingViewController.h"
#import "QIMUserProfileViewController.h"
#import "QIMCommonFont.h"
#import "QIMUserInfoModel.h"
#import "QCGroupModel.h"
#import "QIMMenuView.h"
#import "QIMFriendListViewController.h"
#import "QIMServiceStatusViewController.h"

@interface QIMCommonTableViewCellManager ()

@property (nonatomic, strong) UIViewController *rootVC;

@end

@implementation QIMCommonTableViewCellManager

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super init]) {
        self.rootVC = rootViewController;
    }
    return self;
}

#pragma mark - Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMCommonTableViewCellData *cellData = self.dataSource[indexPath.section][indexPath.row];
    switch (cellData.cellDataType) {
        case QIMCommonTableViewCellDataTypeBlankLines: {
            return QCBlankLineCellHeight;
        }
            break;
        case QIMCommonTableViewCellDataTypeMine: {
            return QCMineProfileCellHeight;
        }
            break;
        default: {
            return QCMineOtherCellHeight;
        }
            break;
    }
    return QCMineOtherCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.dataSourceTitle.count > 0) {
        NSString *sectionTitle = [self.dataSourceTitle objectAtIndex:section];
        if (sectionTitle.length > 0) {
            return 37;
        } else {
            return 10.0f;
        }
    } else {
        if (section == 0) {
            return 0.00001f;
        }
        return QCMineSectionHeaderHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return QCMineMinSectionHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QIMCommonTableViewCellData *itemData = self.dataSource[indexPath.section][indexPath.row];
    switch (itemData.cellDataType) {
        case QIMCommonTableViewCellDataTypeMine: {
            QIMUserProfileViewController *myProfileVc = [[QIMUserProfileViewController alloc] init];
            myProfileVc.userId = [[QIMKit sharedInstance] getLastJid];
            myProfileVc.myOwnerProfile = YES;
            [self.rootVC.navigationController pushViewController:myProfileVc animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeMyRedEnvelope: {
            NSString *myRedpackageUrl = [[QIMKit sharedInstance] myRedpackageUrl];
            if (myRedpackageUrl.length > 0) {
                [QIMFastEntrance openWebViewForUrl:myRedpackageUrl showNavBar:YES];
            }
        }
            break;
        case QIMCommonTableViewCellDataTypeBalanceInquiry: {
            NSString *balacnceUrl = [[QIMKit sharedInstance] redPackageBalanceUrl];
            if (balacnceUrl.length > 0) {
                [QIMFastEntrance openWebViewForUrl:balacnceUrl showNavBar:YES];
            }
        }
            break;
        case QIMCommonTableViewCellDataTypeAttendance:{
#if defined (QIMRNEnable) && QIMRNEnable == 1
            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"clockOnVC");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                vc = [RunC performSelector:sel withObject:nil];
            }
            [self.rootVC presentViewController:vc animated:YES completion:nil];
#endif
        }
            break;
        case QIMCommonTableViewCellDataTypeTotpToken:{
#if defined (QIMRNEnable) && QIMRNEnable == 1
            [QIMFastEntrance openQIMRNVCWithModuleName:@"TOTP" WithProperties:@{}];
#endif
        }
            break;
        case QIMCommonTableViewCellDataTypeAccountInformation: {
            dispatch_async(dispatch_get_main_queue(), ^{
#if defined (QIMOPSRNEnable) && QIMOPSRNEnable == 1
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotify_QtalkSuggest_handle_opsapp_event" object:nil userInfo:@{@"module":@"user-info", @"initParam":@[]}];
#endif
            });
        }
            break;
        case QIMCommonTableViewCellDataTypeMyFile: {
            
            QIMFileManagerViewController *fileManagerVc = [[QIMFileManagerViewController alloc] init];
            [self.rootVC.navigationController pushViewController:fileManagerVc animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeFeedback: {
            QIMFeedBackViewController *feedBackVc = [[QIMFeedBackViewController alloc] init];
            [self.rootVC.navigationController pushViewController:feedBackVc animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeSetting: {
            QIMMySettingController *settingVc = [[QIMMySettingController alloc] init];
            [self.rootVC.navigationController pushViewController:settingVc animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeMessageNotification: {
            
        }
            break;
        case QIMCommonTableViewCellDataTypeMessageOnlineNotification: {
            
        }
            break;
        case QIMCommonTableViewCellDataTypeShowSignature: {
            
        }
            break;
        case QIMCommonTableViewCellDataTypeServiceMode: {
            QIMServiceStatusViewController *serverVc = [[QIMServiceStatusViewController alloc] init];
            [self.rootVC.navigationController pushViewController:serverVc animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeContactBlack: {
            /*
            QIMContactBlackVC *friendListVC = [[QIMContactBlackVC alloc] init];
            [self.rootVC.navigationController pushViewController:friendListVC animated:YES];
            */
        }
            break;
        case QIMCommonTableViewCellDataTypeDressUp: {
            QIMDressUpController * dressUpVC = [[QIMDressUpController alloc] init];
            [self.rootVC.navigationController pushViewController:dressUpVC animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeSearchHistory: {
            QIMWebView *webView = [[QIMWebView alloc] init];
            [webView setUrl:[NSString stringWithFormat:@"%@/lookback/main_controller.php", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost]]];
            //@"https://qt.qunar.com/lookback/main_controller.php"];
            [self.rootVC.navigationController pushViewController:webView animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeClearSessionList: {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"将要删掉当前用户的所有消息，是否继续？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"cancel"] style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[QIMKit sharedInstance] clearAllNoRead];
                [[QIMKit sharedInstance] deleteSessionList];
            }];
            [alertVc addAction:okAction];
            [alertVc addAction:cancelAction];
            [self.rootVC.navigationController presentViewController:alertVc animated:YES completion:nil];
        }
            break;
        case QIMCommonTableViewCellDataTypeGroupName: {
            QIMGroupChangeNameVC *changeNameVC = [[QIMGroupChangeNameVC alloc] init];
            [changeNameVC setGroupId:self.groupModel.groupId];
            [changeNameVC setGroupName:self.groupModel.groupName];
            [self.rootVC.navigationController pushViewController:changeNameVC animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeGroupTopic: {
            QIMGroupChangeTopicVC *changeTopicVC = [[QIMGroupChangeTopicVC alloc] init];
            [changeTopicVC setGroupId:self.groupModel.groupId];
            [changeTopicVC setGroupTopic:self.groupModel.groupAnnouncement];
            [self.rootVC.navigationController pushViewController:changeTopicVC animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeGroupQRcode: {
            [QIMFastEntrance showQRCodeWithQRId:self.groupModel.groupId withType:QRCodeType_GroupQR];
//            [QIMFastEntrance showQRCodeWithUserId:self.groupModel.groupId withName:self.groupModel.groupName withType:QRCodeType_GroupQR];
        }
            break;
        case QIMCommonTableViewCellDataTypeGroupLeave: {
            
        }
            break;
        case QIMCommonTableViewCellDataTypePrivacy: {
            QIMFriendSettingViewController *settingVC = [[QIMFriendSettingViewController alloc] init];
            [settingVC setOldNavHidden:self.rootVC.navigationController.navigationBarHidden];
            [self.rootVC.navigationController pushViewController:settingVC animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeGeneral: {
            
        }
            break;
        case QIMCommonTableViewCellDataTypeUpdateConfig: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [[QIMKit sharedInstance] checkClientConfig];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"配置更新完成，建议重启客户端进行查看！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                });
            });
        }
            break;
        case QIMCommonTableViewCellDataTypeClearCache: {
            [[QIMDataController getInstance] removeAllImage];
        }
            break;
        case QIMCommonTableViewCellDataTypeMconfig: {
            NSString *linkUrl = [NSString stringWithFormat:@"%@?u=%@&d=%@&navBarBg=208EF2", [[QIMKit sharedInstance] qimNav_Mconfig], [QIMKit getLastUserName], [[QIMKit sharedInstance] getDomain]];
            QIMWebView *webView = [[QIMWebView alloc] init];
            [webView setUrl:linkUrl];
            [self.rootVC.navigationController pushViewController:webView animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeAbout: {
            QIMAboutVC *aboutVc = [[QIMAboutVC alloc] init];
            [self.rootVC.navigationController pushViewController:aboutVc animated:YES];
        }
            break;
        case QIMCommonTableViewCellDataTypeLogout: {
            [QIMFastEntrance signOut];
        }
            break;
        default:
            break;
    }
}

#pragma mark - DataSource

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self.dataSourceTitle objectAtIndex:section];
    if (sectionTitle == nil) {
        return nil;
    }
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(16, 10, [UIScreen mainScreen].bounds.size.width - 10, 17);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont systemFontOfSize:12];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.dataSourceTitle objectAtIndex:section];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMCommonTableViewCellData *cellData = self.dataSource[indexPath.section][indexPath.row];
    switch (cellData.cellDataType) {
        case QIMCommonTableViewCellDataTypeBlankLines: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellData.title];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
            cell.contentView.backgroundColor = [UIColor qim_colorWithHex:0xf5f5f5 alpha:1.0];
            return cell;
        }
            break;
        case QIMCommonTableViewCellDataTypeMine: {
            QIMCommonUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [[QIMCommonUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellData.title];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.avatarImage.image = [[QIMKit sharedInstance] getUserHeaderImageByUserId:self.model.ID];
            [cell.avatarImage qim_setImageWithJid:self.model.ID];
            [cell setAccessibilityIdentifier:@"QIMCommonTableViewCellDataTypeMine"];
            cell.nickNameLabel.text = self.model.name;
            cell.signatureLabel.text = self.model.personalSignature;
            cell.showQRCode = YES;
            return cell;
        }
            break;
        case QIMCommonTableViewCellDataTypeMessageNotification:
        case QIMCommonTableViewCellDataTypeMessageOnlineNotification:
        case QIMCommonTableViewCellDataTypeShowSignature:
        case QIMCommonTableViewCellDataTypeGroupPush:
        case QIMCommonTableViewCellDataTypeMessageAlertSound:
        case QIMCommonTableViewCellDataTypeMessageVibrate:
        case QIMCommonTableViewCellDataTypeMessageShowPreviewText: {
            QIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [QIMCommonTableViewCell cellWithStyle:kQIMCommonTableViewCellStyleValueLeft reuseIdentifier:cellData.title];
            }
            cell.textLabel.text = cellData.title;
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.accessoryType_LL = kQIMCommonTableViewCellAccessorySwitch;
            BOOL switchOn = [self getSwitchOnWithType:cellData.cellDataType];
            [cell setSwitchOn:switchOn animated:NO];
            cell.tag = cellData.cellDataType;
            [cell addSwitchTarget:self tag:cellData.cellDataType action:@selector(switchActions:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
            break;
        case QIMCommonTableViewCellDataTypeSearchHistory: {
            QIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [QIMCommonTableViewCell cellWithStyle:kQIMCommonTableViewCellStyleValueLeft reuseIdentifier:cellData.title];
            }
            [cell setAccessibilityIdentifier:cellData.title];
            cell.textLabel.text = cellData.title;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor qim_colorWithHex:0x03A9F4 alpha:1.0];
            return cell;
        }
            break;
        case QIMCommonTableViewCellDataTypeClearSessionList: {
            QIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [QIMCommonTableViewCell cellWithStyle:kQIMCommonTableViewCellStyleValueLeft reuseIdentifier:cellData.title];
            }
            [cell setAccessibilityIdentifier:cellData.title];
            cell.textLabel.text = cellData.title;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor colorWithRed:251/255.0 green:70/255.0 blue:86/255.0 alpha:1/1.0];
            return cell;
        }
            break;
        case QIMCommonTableViewCellDataTypeClearCache: {
            QIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [QIMCommonTableViewCell cellWithStyle:kQIMCommonTableViewCellStyleValue1 reuseIdentifier:cellData.title];
            }
            [cell setAccessibilityIdentifier:cellData.title];
            cell.accessoryType_LL = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = cellData.title;
            long long totalSize = [[QIMDataController getInstance] sizeofImagePath];
            NSString *str = nil;
            if (totalSize < 1048576) {
                // 1024 * 1024
                double total = (double)totalSize;
                float result = total / 1024.0;
                str = [NSString stringWithFormat:@"%.2fKB", result];
            } else if (totalSize < 1073741824) {
                // 1024 * 1024 * 1024
                double total = (double)totalSize;
                float result = total / 1048576.0;
                str = [NSString stringWithFormat:@"%.2fMB", result];
            } else if (totalSize < 1099511627776) {
                // 1024 * 1024 * 1024
                double total = (double)totalSize;
                float result = total / 1073741824.0;
                str = [NSString stringWithFormat:@"%.2fGB", result];
            }
            cell.detailTextLabel.text = str;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            return cell;
        }
            break;
        case QIMCommonTableViewCellDataTypeLogout: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellData.title];
            }
            [cell removeAllSubviews];
            [cell setAccessibilityIdentifier:cellData.title];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, cell.height)];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            label.textColor = [UIColor colorWithRed:251/255.0 green:70/255.0 blue:86/255.0 alpha:1/1.0];
            [label setText:[NSBundle qim_localizedStringForKey:@"Setting_tab_Logout"]];
            [cell addSubview:label];
            return cell;
        }
            break;
        case QIMCommonTableViewCellDataTypeGroupName: {
            static NSString *cellIdentifier = @"GroupName cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:@"群名称"];
                
                QIMMenuView * menuView = [[QIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.tag = 1000;
                [cell.contentView addSubview:menuView];
            }
            [cell setAccessibilityIdentifier:@"GroupName"];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSString * groupName = self.groupModel.groupName;
            cell.detailTextLabel.text = groupName?groupName:@"设置群名称";
            
            [(QIMMenuView * )[cell.contentView viewWithTag:1000] setCoprText:groupName];
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            
            return cell;
        }
            break;
        case QIMCommonTableViewCellDataTypeGroupTopic: {
            static NSString *cellIdentifier = @"groupAnnouncement cell";
            QIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[QIMCommonTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:@"群公告"];
                
                QIMMenuView * menuView = [[QIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.tag = 1000;
                [cell.contentView addSubview:menuView];
            }
            [cell setAccessibilityIdentifier:@"groupAnnouncement"];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.accessoryType_LL = UITableViewCellAccessoryDisclosureIndicator;
            NSString * groupAnnouncement = self.groupModel.groupAnnouncement;
            cell.detailTextLabel.text = groupAnnouncement?groupAnnouncement:@"未设置";
            
            [(QIMMenuView * )[cell.contentView viewWithTag:1000] setCoprText:groupAnnouncement];
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            
            return cell;
        }
            break;
        case QIMCommonTableViewCellDataTypeGroupQRcode: {
            static NSString *cellIdentifier = @"MyQrcode cell";
            QIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [QIMCommonTableViewCell cellWithStyle:kQIMCommonTableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
            [cell setAccessibilityIdentifier:@"MyQrcode"];
            cell.accessoryType_LL = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"群二维码";
            cell.detailTextLabel.font = [UIFont fontWithName:@"Qtalk" size:24];
            cell.detailTextLabel.text = @"\U0000f10d";
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            return cell;
        }
            break;
        case QIMCommonTableViewCellDataTypeGroupLeave: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellData.title];
            }
            [cell removeAllSubviews];
            [cell setAccessibilityIdentifier:cellData.title];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, cell.height)];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            label.textColor = [UIColor colorWithRed:251/255.0 green:70/255.0 blue:86/255.0 alpha:1/1.0];
            [label setText:@"删除并退出"];
            [cell addSubview:label];
            return cell;
        }
            break;
        default: {
            QIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                if (cellData.icon) {
                    cell = [QIMCommonTableViewCell cellWithStyle:kQIMCommonTableViewCellStyleDefault reuseIdentifier:cellData.title];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                    cell.imageView.image = cellData.icon;
                } else {
                    cell = [QIMCommonTableViewCell cellWithStyle:kQIMCommonTableViewCellStyleValueLeft reuseIdentifier:cellData.title];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
            [cell setAccessibilityIdentifier:cellData.title];
            cell.textLabel.text = cellData.title;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[QIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            return cell;
        }
            break;
    }
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"];
}

- (BOOL)getSwitchOnWithType:(QIMCommonTableViewCellDataType)type {
    BOOL switchOn = NO;
    switch (type) {
        case QIMCommonTableViewCellDataTypeMessageNotification: {
            switchOn = [[QIMKit sharedInstance] isNewMsgNotify];
        }
            break;
        case QIMCommonTableViewCellDataTypeMessageOnlineNotification: {
            BOOL state = [[QIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:QIMMSGSETTINGPUSH_ONLINE];

            switchOn = state;
        }
            break;
        case QIMCommonTableViewCellDataTypeShowSignature: {
            switchOn = [[QIMKit sharedInstance] moodshow];
        }
            break;
        case QIMCommonTableViewCellDataTypeGroupPush: {
            switchOn = [[QIMKit sharedInstance] groupPushState:self.groupModel.groupId];
        }
            break;
        default: {
            switchOn = NO;
        }
            break;
    }
    return switchOn;
}

- (void)switchActions:(UISwitch *)sender {
    switch (sender.tag) {
        case QIMCommonTableViewCellDataTypeMessageNotification: {
            [[QIMKit sharedInstance] setNewMsgNotify:sender.on];
        }
            break;
        case QIMCommonTableViewCellDataTypeMessageOnlineNotification: {
            BOOL success = [[QIMKit sharedInstance] setMsgNotifySettingWithIndex:QIMMSGSETTINGPUSH_ONLINE WithSwitchOn:sender.on];
            if (!success) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"切换状态失败"
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"确定", nil];
                
                [alertView show];
                [sender setOn:!sender.on animated:YES];
            }
        }
            break;
        case QIMCommonTableViewCellDataTypeShowSignature: {
            [[QIMKit sharedInstance] setMoodshow:sender.on];
        }
            break;
        case QIMCommonTableViewCellDataTypeGroupPush: {
            [[QIMKit sharedInstance] updatePushState:self.groupModel.groupId withOn:sender.on];
        }
            break;
        default:
            break;
    }
}

@end
