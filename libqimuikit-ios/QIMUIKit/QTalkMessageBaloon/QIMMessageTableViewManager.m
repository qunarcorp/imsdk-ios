//
//  QIMMessageTableViewManager.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/5.
//

#import "QIMMessageTableViewManager.h"
#import "QIMJSONSerializer.h"
//Message parser
#import "QIMTextContainer.h"
#import "QIMMessageParser.h"
#import "QIMEmotionSpirits.h"
//Cell
#import "QIMMsgBaloonBaseCell.h"
#import "QIMExtensibleProductCell.h"
#import "QIMPNRichTextCell.h"
#import "QIMPNActionRichTextCell.h"
#import "QIMPublicNumberNoticeCell.h"
#import "QIMChatNotifyInfoCell.h"
#import "QIMProductInfoCell.h"
#import "QIMC2BGrabSingleCell.h"
#import "QIMSingleChatCell.h"
#import "QIMCommonTrdInfoCell.h"
#import "QIMForecastCell.h"
#import "QIMSingleChatVoiceCell.h"
#import "QIMNewMessageTagCell.h"
#import "QIMPublicNumberOrderMsgCell.h"
#import "QIMRobotQuestionCell.h"
#import "QIMRobotAnswerCell.h"
#import "QIMMeetingRemindCell.h"

//#import "TransferInfoCell.h"
#import "QIMGroupChatCell.h"
#import "QIMPublicNumberNoticeCell.h"
#import "QIMVoiceNoReadStateManager.h"

//UI
#import "QIMRedPackageView.h"
#import "QIMWebView.h"
#import "QIMOriginMessageParser.h"

#if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
#import "QIMWebRTCClient.h"
#import "QIMWebRTCMeetingClient.h"
#endif

#if defined (QIMNoteEnable) && QIMNoteEnable == 1
#import "QIMEncryptChat.h"
#endif

#import "QIMGroupNickNameHelper.h"

@interface QIMMessageTableViewManager () 

@property (nonatomic, copy) NSString *chatId;
@property (nonatomic, assign) ChatType chatType;
@property (nonatomic, assign) BOOL editing;

@property (nonatomic, weak) QTalkViewController *ownerVc;

@property(nonatomic, strong) NSMutableArray *canForwardMsgTypeArray;

@end

@implementation QIMMessageTableViewManager


#pragma mark - setter and getter

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:20];
    }
    return _dataSource;
}

//用户已经选择的将要转发消息
- (NSMutableSet *)forwardSelectedMsgs {
    if (!_forwardSelectedMsgs) {
        _forwardSelectedMsgs = [NSMutableSet setWithCapacity:5];
    }
    return _forwardSelectedMsgs;
}

//支持转发的消息类型
- (NSMutableArray *)canForwardMsgTypeArray {
    if (!_canForwardMsgTypeArray) {
        _canForwardMsgTypeArray = [NSMutableArray arrayWithCapacity:5];
        [_canForwardMsgTypeArray addObjectsFromArray:@[@(QIMMessageType_Text), @(QIMMessageType_Image), @(QIMMessageType_NewAt), @(QIMMessageType_ImageNew), @(QIMMessageType_Voice), @(QIMMessageType_File), @(QIMMessageType_LocalShare), @(QIMMessageType_SmallVideo), @(QIMMessageType_CommonTrdInfo), @(QIMMessageType_CommonTrdInfoPer)]];
    }
    return _canForwardMsgTypeArray;
}

- (instancetype)initWithChatId:(NSString *)chatId ChatType:(ChatType)chatType OwnerVc:(QTalkViewController *)ownerVc {
    self = [super init];
    if (self) {
        self.chatId = chatId;
        self.chatType = chatType;
        self.ownerVc = ownerVc;
        self.width = self.ownerVc.view.width;
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) {
        return 0;
    }
    id temp = [self.dataSource objectAtIndex:indexPath.row];
    if ([temp isKindOfClass:[NSString class]]) {
        
    } else if (![temp isKindOfClass:[Message class]]) {
        
    } else {
        Message *message = temp;
        NSString *msgContent = message.message;
        NSString *extendInfo = message.extendInformation;
        switch (message.messageType) {
            case QIMMessageType_PNote:
            case QIMMessageType_CNote: {
                NSDictionary *productDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
                NSDictionary *infoDic = [productDic objectForKey:@"data"];
                NSString *url = [productDic objectForKey:@"url"];
                if (infoDic.count > 0) {
                    if (MessageDirection_Received == message.messageType || QIMMessageType_CNote == message.messageType) {
                        return [QIMProductInfoCell getCellHeight];
                    } else {
                        message.message = [NSString stringWithFormat:@"[obj type=\"url\" value=\"%@\"]", url];
                        message.messageType = QIMMessageType_Text;
                        QIMTextContainer *textContaner = [QIMMessageParser textContainerForMessage:message];
                        return [textContaner getHeightWithFramesetter:nil width:textContaner.textWidth] + 45;
                    }
                } else {
                    message.message = [NSString stringWithFormat:@"[obj type=\"url\" value=\"%@\"]", url];
                    message.messageType = QIMMessageType_Text;
                    QIMTextContainer *textContaner = [QIMMessageParser textContainerForMessage:message];
                    return [textContaner getHeightWithFramesetter:nil width:textContaner.textWidth] + 45;
                }
            }
                break;
            case QIMMessageType_ExProduct: {
                return [QIMExtensibleProductCell getCellHeightForProductInfo:message.extendInformation.length ? message.extendInformation : message.message];
            }
                break;
            case QIMMessageType_product: {
                
                NSDictionary *productDic = nil;
                if (message.extendInformation) {
                    productDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.extendInformation error:nil];
                } else {
                    productDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
                }
                NSDictionary *infoDic = [productDic objectForKey:@"data"];
                if (infoDic == nil) {
                    message.messageType = QIMMessageType_Text;
                    QIMTextContainer *textContaner = [QIMMessageParser textContainerForMessage:message];
                    return [textContaner getHeightWithFramesetter:nil width:textContaner.textWidth] + 45;
                }
                if (infoDic.count > 0) {
                    return [QIMProductInfoCell getCellHeight];
                }
                return 0;
            }
                break;
            case QIMMessageType_CommonTrdInfoPer:
            case QIMMessageType_CommonTrdInfo: {
                
                CGFloat height = [QIMCommonTrdInfoCell getCellHeightWihtMessage:message chatType:self.chatType] + 20;
                return height;
            }
                break;
            case QIMMessageType_Forecast: {
                return [QIMForecastCell getCellHeightWihtMessage:message chatType:self.chatType] + 20;
            }
            case QIMMessageType_GroupNotify: {
                return [QIMChatNotifyInfoCell getCellHeightWihtMessage:message chatType:self.chatType] + 20;
            }
                break;
            case QIMMessageType_Text:
            case QIMMessageType_Image:
            case QIMMessageType_ImageNew:{
                
                QIMTextContainer *textContaner = [QIMMessageParser textContainerForMessage:message];
                return MAX([textContaner getHeightWithFramesetter:nil width:textContaner.textWidth], 20) + (message.messageDirection == MessageDirection_Received ? 36 : 25) + 10;
            }
                break;
            case QIMMessageType_NewAt: {
                QIMTextContainer *textContaner = [QIMMessageParser textContainerForMessage:message];
                return MAX([textContaner getHeightWithFramesetter:nil width:textContaner.textWidth], 20) + (message.messageDirection == MessageDirection_Received ? 36 : 25) + 10;
            }
                break;
            case QIMMessageType_NewMsgTag: {
                
                return [QIMNewMessageTagCell getCellHeight];
            }
                break;
            case QIMMessageType_TransChatToCustomerService:{
                // 不显示
                return 0;
            }
                break;
            case QIMMessageType_TransChatToCustomer:{
                if (self.chatType == ChatType_Consult) {
                    return 0;
                } else {
                    return [TransferInfoCell getCellHeightWihtMessage:message chatType:self.chatType];
                }
            }
                break;
            case QIMMessageType_TransChatToCustomer_Feedback:
            case QIMMessageType_TransChatToCustomerService_Feedback:{
                return [TransferInfoCell getCellHeightWihtMessage:message chatType:self.chatType];
            }
                break;
            case PublicNumberMsgType_Notice: {
                
                return [QIMPublicNumberNoticeCell getCellHeightByContent:message.message];
            }
                break;
            case PublicNumberMsgType_OrderNotify: {
                
                return [QIMPublicNumberOrderMsgCell getCellHeightByContent:message.message];
            }
                break;
            case MessageType_C2BGrabSingle: {
                return [QIMC2BGrabSingleCell getCellHeight];
            }
                break;
            case MessageType_C2BGrabSingleFeedBack: {
                return 0.01;
            }
                break;
            case QIMMessageTypeMeetingRemind: {
                return [QIMMeetingRemindCell getCellHeightWihtMessage:temp chatType:self.chatType] + 35;
            }
                break;
            default: {
                
                Class someClass = [[QIMKit sharedInstance] getRegisterMsgCellClassForMessageType:message.messageType];
                if (someClass) {
                    CGFloat height = [someClass getCellHeightWihtMessage:temp chatType:self.chatType] + 5;
                    return height;
                } else {
                    QIMTextContainer *textContaner = [QIMMessageParser textContainerForMessage:message];
                    return [textContaner getHeightWithFramesetter:nil width:textContaner.textWidth] + 50;
                }
            }
                break;
        }
    }
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing == YES) {
        if (!self.forwardSelectedMsgs) {
            self.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
        }
        Message *msg = [self.dataSource objectAtIndex:indexPath.row];
        if ([self.canForwardMsgTypeArray containsObject:@(msg.messageType)]) {
            [self.forwardSelectedMsgs addObject:msg];
        }
        [self updateForwardBtnState];
        return;
    }
    Message *msg = [self.dataSource objectAtIndex:indexPath.row];
    
    switch (msg.messageType) {
        case QIMMessageType_RedPack:
        case QIMMessageType_RedPackInfo:
        case QIMMessageType_AA:
        case QIMMessageType_AAInfo: {
            NSString *infoStr = msg.extendInformation.length <= 0 ? msg.message : msg.extendInformation;
            if (infoStr.length > 0) {
                
                NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
                if ([[[QIMKit getLastUserName] lowercaseString] isEqualToString:@"appstore"] || [[[QIMKit getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                        message:@"该消息已过期。"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"确定"
                                                              otherButtonTitles:nil];
                    [alertView show];
                } else {
                    if (self.chatType == ChatType_GroupChat) {
#pragma mark 00d8c4642c688fd6bfa9a41b523bdb6b PHP那边加的key
                        if (msg.messageType == QIMMessageType_RedPack || msg.messageType == QIMMessageType_AA) {
                            [QIMRedPackageView showRedPackagerViewByUrl:[NSString stringWithFormat:@"%@&username=%@&sign=%@&company=qunar&group_"@"id=%@&rk=%@&q_d=%@", infoDic[@"url"], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey], [[QIMKit sharedInstance] getDomain]]];
                        } else if (msg.messageType == QIMMessageType_RedPackInfo || msg.messageType == QIMMessageType_AAInfo) {
                            [QIMRedPackageView showRedPackagerViewByUrl:[NSString stringWithFormat:@"%@&username=%@&sign=%@&company=qunar&group_"@"id=%@&rk=%@&q_d=%@", infoDic[@"Url"], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b",                                                                                                                    [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey], [[QIMKit sharedInstance] getDomain]]];
                        }
                    } else {
                        if (msg.messageType == QIMMessageType_RedPack || msg.messageType == QIMMessageType_AA) {
                            [QIMRedPackageView showRedPackagerViewByUrl:[NSString stringWithFormat:@"%@&username=%@&sign=%@&company=qunar&user_id=%@&rk=%@&q_d=%@", infoDic[@"url"], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey], [[QIMKit sharedInstance] getDomain]]];
                        } else {
                            [QIMRedPackageView showRedPackagerViewByUrl:[NSString stringWithFormat:@"%@&username=%@&sign=%@&company=qunar&user_id=%@&rk=%@&q_d=%@", infoDic[@"Url"], [QIMKit getLastUserName], [[NSString stringWithFormat:@"%@00d8c4642c688fd6bfa9a41b523bdb6b", [QIMKit getLastUserName]] qim_getMD5], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey],  [[QIMKit sharedInstance] getDomain]]];
                        }
                    }
                }
            }
        }
            break;
        case QIMMessageType_CNote:
        case QIMMessageType_PNote: {
            NSDictionary *proDic = [[QIMJSONSerializer sharedInstance] deserializeObject:msg.message error:nil];
            proDic = [proDic objectForKey:@"data"];
            NSString *touchUrl = [proDic objectForKey:@"touchDtlUrl"];
            if (touchUrl.length > 0) {
                [QIMFastEntrance openWebViewForUrl:touchUrl showNavBar:YES];
            }
        }
            break;
        case QIMMessageType_shareLocation: {
             /*
             QIMMsgBaloonBaseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
             if (cell.message.extendInformation) {
             
             cell.message.message = cell.message.extendInformation;
             }
             NSDictionary *dic = [[CJSONDeserializer deserializer] deserializeAsDictionary:[cell.message.message dataUsingEncoding:NSUTF8StringEncoding]
             error:nil];
             NSString *shareId = [dic objectForKey:@"shareId"];
             
             if ([[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:shareId].count) {
             
             if (_shareLctVC == nil || ![_shareLctId isEqualToString:shareId]) {
                 _shareLctVC = [[ShareLocationViewController alloc] init];
                 _shareLctVC.userId = self.groupID;
                 _shareLctVC.shareLocationId = shareId;
             }
             [[self navigationController] presentViewController:_shareLctVC animated:YES completion:nil];
             } else {
             
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"哎呀呀~~"
                 message:@"这个位置共享已经关闭啦~"
                 delegate:nil
                 cancelButtonTitle:@"俺 Know!"
                 otherButtonTitles:nil, nil];
                 [alertView show];
             }
             */
        }
            break;
        case QIMMessageType_CardShare: {
            if (self.ownerVc) {
                NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:msg.message error:nil];
                NSString *userId = [infoDic objectForKey:@"userId"];
                NSString * suff = [NSString stringWithFormat:@"@%@",[[QIMKit sharedInstance] getDomain]];
                if ([userId rangeOfString:@"@"].location == NSNotFound) {
                    userId = [userId stringByAppendingString:suff];
                }
                [QIMFastEntrance openUserCardVCByUserId:userId];
            }
        }
            break;
        case QIMMessageType_activity: {
            NSString *infoStr = msg.extendInformation.length <= 0 ? msg.message : msg.extendInformation;
            if (infoStr.length > 0) {
                NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
                QIMWebView *webView = [[QIMWebView alloc] init];
                webView.url = infoDic[@"url"];
                webView.navBarHidden = YES;
                [webView setFromRegPackage:YES];
                [self.ownerVc.navigationController pushViewController:webView animated:YES];
            }
        }
            break;
            case QIMMessageType_CommonTrdInfo:
            case QIMMessageType_CommonTrdInfoPer:
            case QIMMessageType_Forecast: {

                NSString *infoStr = msg.extendInformation.length <= 0 ? msg.message : msg.extendInformation;
                if (infoStr.length > 0) {
                    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
                    if ([QIMFastEntrance handleOpsasppSchema:infoDic] == NO) {
                        QIMWebView *webView = [[QIMWebView alloc] init];
                        if ([infoDic objectForKey:@"showbar"]) {
                            webView.navBarHidden = [[infoDic objectForKey:@"showbar"] boolValue] == NO;
                        }
                        if ([infoDic objectForKey:@"auth"]) {
                            webView.needAuth = [[infoDic objectForKey:@"auth"] boolValue];
                        }
                        NSString *url = infoDic[@"linkurl"];
                        if (webView.needAuth == YES) {
                            
                            if ([url rangeOfString:@"qunar.com"].location != NSNotFound) {
                                if (self.chatType == ChatType_GroupChat) {
                                    url = [url stringByAppendingFormat:@"%@username=%@&company=qunar&group_id=%@&rk=%@", ([url rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?"), [[QIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey]];
                                } else {
                                    url = [url stringByAppendingFormat:@"%@username=%@&company=qunar&user_id=%@&rk=%@", ([url rangeOfString:@"?"].location != NSNotFound ? @"&" : @"?"), [[QIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self.chatId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMKit sharedInstance] myRemotelogginKey]];
                                }
                            }
                        }
                        webView.url = url;
                        [self.ownerVc.navigationController pushViewController:webView animated:YES];
                    }
                }
            }
            break;
        case QIMWebRTC_MsgType_Audio: {
            
        }
            break;
        case QIMMessageTypeWebRtcMsgTypeVideoMeeting: {
#if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
            
            NSString *infoStr = msg.extendInformation.length <= 0 ? msg.message : msg.extendInformation;
            if (infoStr.length > 0) {
                NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
                if (infoDic.count) {
                    [[QIMWebRTCMeetingClient sharedInstance] joinRoomByMessage:infoDic];
                }
            }
#endif
        }
            break;
        case QIMWebRTC_MsgType_Video: {
#if defined (QIMWebRTCEnable) && QIMWebRTCEnable == 1
            [[QIMWebRTCClient sharedInstance] setRemoteJID:self.chatId];
//            [[QIMWebRTCClient sharedInstance] setHeaderImage:[[QIMKit sharedInstance] getUserHeaderImageByUserId:self.chatId]];
            [[QIMWebRTCClient sharedInstance] showRTCViewByXmppId:self.chatId isVideo:YES isCaller:YES];
#endif
        }
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        Message *msg = [self.dataSource objectAtIndex:indexPath.row];
        if (!self.forwardSelectedMsgs) {
            self.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
        }
        [self.forwardSelectedMsgs removeObject:msg];
#warning 回调转发消息按钮状态
        [self updateForwardBtnState];
//        QIMVerboseLog(@"cellIndexPath : %@", indexPath);
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        QIMVerboseLog(@"cell.indexPath : %@", cell);
//        QIMVerboseLog(@"cell.editing : %d", cell.editing);
//        QIMVerboseLog(@"cell.selecting : %d", cell.selected);
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    Message *msg = [self.dataSource objectAtIndex:indexPath.row];
    if (tableView.editing) {
        if (!self.forwardSelectedMsgs) {
            self.forwardSelectedMsgs = [[NSMutableSet alloc] initWithCapacity:5];
        }
        if ([self.forwardSelectedMsgs containsObject:msg]) {
            [cell setSelected:YES animated:NO];
        } else {
            [cell setSelected:NO animated:NO];
        }
    }
    
    if (row < self.dataSource.count) {
        
        Message *message = [self.dataSource objectAtIndex:indexPath.row];
        if (message.messageType == QIMMessageType_Text) {
            if (message.readTag != 1) {
                [[QIMEmotionSpirits sharedInstance] playQIMEmotionSpiritsWithMessage:message.message];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                   [[QIMKit sharedInstance] updateMessageReadStateWithMsgId:message.messageId];
                });
                [message setReadTag:1];
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if (row >= self.dataSource.count || self.dataSource.count < 1 || self.dataSource == nil) {
        return [[UITableViewCell alloc] init];
    }
    BOOL isvisable = [[tableView indexPathsForVisibleRows] containsObject:indexPath];
    id temp = [self.dataSource objectAtIndex:row];
    Message *message = temp;
//    QIMVerboseLog(@"解密会话状态 : %lu,   %d", (unsigned long)[[QIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId], message.messageType);
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
    if (([[QIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.chatId] > QIMEncryptChatStateNone) && message.messageType == QIMMessageType_Encrypt) {
        
        NSInteger msgType = [[QIMEncryptChat sharedInstance] getMessageTypeWithEncryptMsg:message WithUserId:self.chatId];
        NSString *originBody = [[QIMEncryptChat sharedInstance] getMessageBodyWithEncryptMsg:message WithUserId:self.chatId];
        NSString *originExtendInfo = [[QIMEncryptChat sharedInstance] getMessageExtendInfoWithEncryptMsg:message WithUserId:self.chatId];
        if (originBody.length > 0) {
            message.message = originBody;
        }
        NSArray *msgTypeList = [[QIMKit sharedInstance] getSupportMsgTypeList];
        if ([msgTypeList containsObject:@(msgType)] && originExtendInfo.length > 0) {
            message.message = originExtendInfo;
        }
        if (originBody.length <= 0 && originExtendInfo.length <= 0) {
            message.extendInformation = @"[解密失败]";
        } else {
            message.messageType = (QIMMessageType)msgType;
        }
    }
#endif
    switch ((int) message.messageType) {
        case QIMMessageType_ExProduct: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_ExProduct Cell %@", message.messageId];
            QIMExtensibleProductCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[QIMExtensibleProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            cell.chatType = self.chatType;
            NSDictionary *proDic = nil;
            if (message.extendInformation) {
                proDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.extendInformation error:nil];
            } else {
                proDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
            }
            if (proDic == nil) {
                message.messageType = QIMMessageType_Text;
                NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_ExProduct->QIMMessageType_Text Cell %@", message.messageId];
                QIMGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[QIMGroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [cell setFrameWidth:self.ownerVc.view.width];
                    [cell setDelegate:self.ownerVc];
                }
                [cell setMessage:message];
                [cell refreshUI];
                return cell;
            }
            [cell setProDcutInfoDic:proDic];
            cell.owner = self.ownerVc;
            [cell refreshUI];
            
            return cell;
        }
            break;
        case QIMMessageType_PNote:
        case QIMMessageType_CNote: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_CNote Cell %@", message.messageId];
            QIMProductInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[QIMProductInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell setMessage:message];
            }
            [cell setMessage:message];
            [cell setChatType:self.chatType];
            if (isvisable) {
                NSDictionary *proDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
                proDic = [proDic objectForKey:@"data"];
                NSString *tag = [proDic objectForKey:@"tag"];
                NSString *type = [proDic objectForKey:@"type"];
                [cell setHeaderUrl:[proDic objectForKey:@"imageUrl"]];
                [cell setTitle:[proDic objectForKey:@"title"]];
                [cell setSubTitle:tag];
                [cell setTypeStr:type];
                [cell setPriceStr:[proDic objectForKey:@"price"]];
                [cell setTouchUrl:[proDic objectForKey:@"touchDtlUrl"]];
                [cell setOwner:self.ownerVc];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case MessageType_C2BGrabSingle: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"MessageType_C2BGrabSingle Cell %@", message.messageId];
            QIMC2BGrabSingleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[QIMC2BGrabSingleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            [cell setChatType:self.chatType];
            if (isvisable) {
                [cell setMessage:message];
                [cell setOwner:self.ownerVc];
            }
            return cell;
        }
            break;
        case QIMMessageType_product: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_product Cell %@", message.messageId];
            QIMProductInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                
                cell = [[QIMProductInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            cell.message = message;
            cell.chatType = self.chatType;
            NSDictionary *proDic = nil;
            if (message.extendInformation) {
                proDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.extendInformation error:nil];
            } else {
                proDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
            }
            proDic = [proDic objectForKey:@"data"];
            if (proDic == nil) {
                message.messageType = QIMMessageType_Text;
                NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_product->QIMMessageType_Text Cell %@", message.messageId];
                QIMGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    
                    cell = [[QIMGroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:cellIdentifier];
                    [cell setFrameWidth:self.ownerVc.view.width];
                    [cell setDelegate:self.ownerVc];
                }
                [cell setMessage:message];
                [cell refreshUI];
                return cell;
            }
            NSString *tag = [[proDic objectForKey:@"tag"] isKindOfClass:[NSNull class]] ? @"" : [proDic objectForKey:@"tag"];
            NSString *type = [proDic objectForKey:@"type"];
            [cell setHeaderUrl:[proDic objectForKey:@"imageUrl"]];
            [cell setTitle:[proDic objectForKey:@"title"]];
            [cell setSubTitle:tag];
            [cell setTypeStr:type];
            [cell setPriceStr:[proDic objectForKey:@"price"]];
            [cell setTouchUrl:[proDic objectForKey:@"touchDtlUrl"]];
            [cell setOwner:self.ownerVc];
            [cell refreshUI];
            return cell;
        }
            break;
        case QIMMessageType_CommonTrdInfoPer:
        case QIMMessageType_CommonTrdInfo: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_CommonTrdInfo Cell %@", message.messageId];
            QIMCommonTrdInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                
                cell = [[QIMCommonTrdInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
                cell.chatType = self.chatType;
//                if (message.extendInformation.length > 0) {
//                    
//                    message.message = message.extendInformation;
//                }
                [cell setMessage:message];
                [cell setChatType:self.chatType];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case QIMMessageType_Forecast: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_Forecast Cell %@", message.messageId];
            QIMForecastCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[QIMForecastCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
            }
            cell.chatType = self.chatType;
            if (isvisable) {
                if (message.extendInformation.length > 0) {
                    message.message = message.extendInformation;
                }
                [cell setMessage:message];
                [cell setChatType:self.chatType];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case QIMMessageType_Text:
        case QIMMessageType_Image:
        case QIMMessageType_ImageNew:{
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_Text Cell %@", message.messageId];
            QIMGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                
                cell = [[QIMGroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:cellIdentifier];
                cell.chatType = self.chatType;
                [cell setFrameWidth:self.ownerVc.view.width];
                [cell setDelegate:self.ownerVc];
                [cell setMessage:message];
            }
            [cell refreshUI];
            return cell;
        }
            break;
            case QIMMessageType_NewAt: {
                NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_NewAt Cell %@", message.messageId];
                QIMGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[QIMGroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:cellIdentifier];
                    cell.chatType = self.chatType;
                    [cell setFrameWidth:self.ownerVc.view.width];
                    [cell setDelegate:self.ownerVc];
                    NSString *backupInfo = [[QIMOriginMessageParser shareParserOriginMessage]
                                            getOriginMsgBackupInfoWithMsgRaw:message.msgRaw WithMsgId:message.messageId];
                    NSString *msg = message.message;
                    NSArray *array = [[QIMJSONSerializer sharedInstance] deserializeObject:backupInfo error:nil];
                    if ([array isKindOfClass:[NSArray class]]) {
                        NSDictionary *groupAtDic = [array firstObject];
                        for (NSDictionary *someOneAtDic in [groupAtDic objectForKey:@"data"]) {
                            NSString *someOneJid = [someOneAtDic objectForKey:@"jid"];
                            if (someOneJid.length) {
                                NSString *someOneText = [someOneAtDic objectForKey:@"text"];
                                NSString *replaceText = [NSString stringWithFormat:@"@%@", someOneText];
                                NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:someOneJid];
                                NSString *newReplaceName = [NSString stringWithFormat:@"@%@", remarkName];
                                if(remarkName.length) {
                                    msg = [msg stringByReplacingOccurrencesOfString:replaceText withString:newReplaceName];
                                } else {
                                }
                            } else {
                                continue;
                            }
                        }
                    } else {
                        
                    }
                    message.message = msg;
                    [cell setMessage:message];
                    [cell refreshUI];
                }
                return cell;
            }
            break;
        case QIMMessageType_Voice: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_Voice Cell %@", message.messageId];
            QIMSingleChatVoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                
                cell = [[QIMSingleChatVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:cellIdentifier];
                cell.chatType = self.chatType;
                [cell setFrameWidth:self.ownerVc.view.width];
                [cell setDelegate:self.ownerVc];
                [cell setMessage:message];
                BOOL isRead = [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] isReadWithMsgId:message.messageId ChatId:self.chatId];
                if (message.messageDirection == MessageDirection_Received) {
                    [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] setVoiceNoReadStateWithMsgId:message.messageId ChatId:self.chatId withState:isRead];
                }
                cell.isGroupVoice = YES;
                cell.chatId = self.chatId;
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case QIMMessageType_GroupNotify: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_GroupNotify Cell %@", message.messageId];
            QIMChatNotifyInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[QIMChatNotifyInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:cellIdentifier];
                cell.chatType = self.chatType;
                [cell setFrameWidth:self.ownerVc.view.width];
                [cell setDelegate:self.ownerVc];
                [cell setMessage:message];
                [cell refreshUI];
            }
            
            return cell;
        }
            break;
        case QIMMessageType_NewMsgTag: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_NewMsgTag Cell %@", message.messageId];
            QIMNewMessageTagCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[QIMNewMessageTagCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:cellIdentifier];
            }
            if (isvisable) {
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case QIMMessageType_TransChatToCustomerService:{
            // 不显示
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_TransChatToCustomerService Cell %@", message.messageId];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            return cell;
        }
            break;
        case QIMMessageType_TransChatToCustomer:{
            if (self.chatType == ChatType_Consult) {
                // 不显示
                NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_TransChatToCustomer Empty Cell %@", message.messageId];
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                return cell;
            } else {
                NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_TransChatToCustomer Cell %@", message.messageId];
                TransferInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[TransferInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [cell setFrameWidth:self.ownerVc.view.width];
                    [cell setDelegate:self.ownerVc];
                }
                [cell setChatType:ChatType_SingleChat];
                [cell setMessage:message];
                [cell refreshUI];
                return cell;
            }
        }
            break;
        case QIMMessageType_TransChatToCustomerService_Feedback:{
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_TransChatToCustomerService_Feedback Cell %@", message.messageId];
            TransferInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[TransferInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setFrameWidth:self.ownerVc.view.width];
                [cell setDelegate:self.ownerVc];
            }
            [cell setChatType:self.chatType];
            [cell setMessage:message];
            [cell refreshUI];
            return cell;
        }
            break;
        case QIMMessageType_TransChatToCustomer_Feedback:{
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"QIMMessageType_TransChatToCustomer_Feedback Cell %@", message.messageId];
            TransferInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[TransferInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setFrameWidth:self.ownerVc.view.width];
                [cell setDelegate:self.ownerVc];
            }
            [cell setChatType:self.chatType];
            [cell setMessage:message];
            [cell refreshUI];
            return cell;
        }
            break;
        case PublicNumberMsgType_RichText: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"PublicNumberMsgType_RichText Cell %@", message.messageId];
            QIMPNRichTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                
                cell = [[QIMPNRichTextCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
            }
            if (isvisable) {
                
                [cell setContent:message.message];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case PublicNumberMsgType_ActionRichText: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"PublicNumberMsgType_ActionRichText Cell %@", message.messageId];
            QIMPNActionRichTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                
                cell = [[QIMPNActionRichTextCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
            }
            if (isvisable) {
                
                [cell setContent:message.message];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case PublicNumberMsgType_Notice: {
            
            NSString *cellIdentifier = [NSString stringWithFormat:@"PublicNumberMsgType_Notice Cell %@", message.messageId];
            QIMPublicNumberNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[QIMPublicNumberNoticeCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
            }
            if (isvisable) {
                [cell setContent:message.message];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case PublicNumberMsgType_OrderNotify:{
            static NSString *cellIdentifier = @"Cell Order Notify ";
            QIMPublicNumberOrderMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[QIMPublicNumberOrderMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setDelegate:self.ownerVc];
            }
            if (isvisable) {
                [cell setMessage:message];
                [cell refreshUI];
            }
            return cell;
        }
            break;
        case MessageType_C2BGrabSingleFeedBack: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"C2B GrabSingle FeedBack Cell %@", @(message.messageDirection)];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.backgroundColor = [UIColor qtalkChatBgColor];
            }
            return cell;
        }
            break;
        case QIMMessageTypeRobotQuestionList: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"%d Cell %@", message.messageType, message.messageId];
            QIMMsgBaloonBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[QIMRobotQuestionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdentifier];
                [cell setFrameWidth:self.ownerVc.view.width];
                cell.chatType = self.chatType;
                cell.delegate = self.ownerVc;
            }
            [cell setOwerViewController:self.ownerVc];
            [cell setMessage:message];
            [cell setChatType:self.chatType];
            [cell refreshUI];
            return cell;
        }
            break;
        case QIMMessageType_RobotAnswer: {
            NSString *cellIdentifier = [NSString stringWithFormat:@"%d Cell %@", message.messageType, message.messageId];
            QIMRobotAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[QIMRobotAnswerCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:cellIdentifier];
                [cell setFrameWidth:self.ownerVc.view.width];
                cell.chatType = self.chatType;
                cell.delegate = self.ownerVc;
            }
            [cell setOwerViewController:self.ownerVc];
            [cell setMessage:message];
            [cell setChatType:self.chatType];
            [cell refreshUI];
            return cell;
        }
            break;
        default: {
            Class someClass = [[QIMKit sharedInstance] getRegisterMsgCellClassForMessageType:message.messageType];
            if (someClass) {
                
                NSString *cellIdentifier = [NSString stringWithFormat:@"%d Cell %@", message.messageType, message.messageId];
                QIMMsgBaloonBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[someClass alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier];
                    [cell setFrameWidth:self.ownerVc.view.width];
                    cell.chatType = self.chatType;
                    cell.delegate = self.ownerVc;
                    [cell setOwerViewController:self.ownerVc];
                    [cell setMessage:message];
                    [cell refreshUI];
                }
                return cell;
            } else {
                NSString *cellIdentifier = [NSString stringWithFormat:@"No Found MessageType(%d) Cell %@", message.messageType, message.messageId];
                QIMGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[QIMGroupChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    [cell setFrameWidth:self.ownerVc.view.width];
                    [cell setDelegate:self.ownerVc];
                    cell.chatType = self.chatType;
                    [cell setMessage:message];
                    [cell refreshUI];
                }
                return cell;
            }
        }
            break;
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) {
        return NO;
    }
    if (tableView.editing) {
        id temp = [self.dataSource objectAtIndex:indexPath.row];
        Message *message = temp;
        if ([self.canForwardMsgTypeArray containsObject:@(message.messageType)]) {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    id temp = [self.dataSource objectAtIndex:indexPath.row];
    Message *message = temp;
    QIMVerboseLog(@"commit msg : %@", message);
}

#pragma mark - ScrollViewDelegate

- (void)updateForwardBtnState {
    if (self.delegate && [self.delegate respondsToSelector:@selector(QTalkMessageUpdateForwardBtnState:)]) {
        [self.delegate QTalkMessageUpdateForwardBtnState:(self.forwardSelectedMsgs.count >= 1)];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(QTalkMessageScrollViewDidScroll:)]) {
        [self.delegate QTalkMessageScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(QTalkMessageScrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate QTalkMessageScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.delegate && [self.delegate respondsToSelector:@selector(QTalkMessageScrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.delegate QTalkMessageScrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
}

@end
