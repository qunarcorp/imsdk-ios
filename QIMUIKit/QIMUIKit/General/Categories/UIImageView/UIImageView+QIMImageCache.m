//
//  UIImageView+QIMImageCache.m
//  QIMUIKit
//
//  Created by 李露 on 2018/8/27.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "UIImageView+QIMImageCache.h"

@implementation UIImageView (QIMImageCache)

- (void)qim_setImageWithJid:(NSString *)jid {
    [self qim_setImageWithJid:jid WithChatType:ChatType_SingleChat];
}

- (void)qim_setImageWithJid:(NSString *)jid WithChatType:(ChatType)chatType {
    [self qim_setImageWithJid:jid WithChatType:chatType placeholderImage:nil];
}

- (void)qim_setImageWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(ChatType)chatType {
    [self qim_setImageWithJid:jid WithRealJid:realJid WithChatType:chatType placeholderImage:nil];
}

- (void)qim_setImageWithJid:(NSString *)jid WithChatType:(ChatType)chatType placeholderImage:(UIImage *)placeholder {
    [self qim_setImageWithJid:jid WithRealJid:nil WithChatType:chatType placeholderImage:placeholder];
}

- (void)qim_setImageWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(ChatType)chatType placeholderImage:(UIImage *)placeholder {
    __block NSString *headerUrl = nil;
    __block UIImage *placeholderImage = placeholder;
    dispatch_async([[QIMKit sharedInstance] getLastQueue], ^{

        switch (chatType) {
            case ChatType_SingleChat: {
                headerUrl = [[QIMKit sharedInstance] getUserBigHeaderImageUrlWithUserId:jid];
                if (!placeholder) {
                    placeholderImage = [UIImage imageWithData:[QIMKit defaultUserHeaderImage]];
                }
            }
                break;
            case ChatType_GroupChat: {
                headerUrl = [[QIMKit sharedInstance] getGroupBigHeaderImageUrlWithGroupId:jid];
                if (!placeholder) {
                    placeholderImage = [QIMKit defaultGroupHeaderImage];
                }
            }
                break;
            case ChatType_System: {
                if ([jid hasPrefix:@"FriendNotify"]) {
                    placeholderImage = [UIImage imageNamed:@"conversation_address-book_avatar"];
                } else {
                    if ([jid hasPrefix:@"rbt-notice"]) {
                        placeholderImage = [UIImage imageNamed:@"rbt_notice"];
                    } else if ([jid hasPrefix:@"rbt-qiangdan"]) {
                        placeholderImage = [UIImage imageNamed:@"rbt-qiangdan"];
                    } else if ([jid hasPrefix:@"rbt-zhongbao"]) {
                        placeholderImage = [UIImage imageNamed:@"rbt-qiangdan"];
                    } else {
                        placeholderImage = [UIImage imageNamed:@"icon_speaker_h39"];
                    }
                }
            }
                break;
            case ChatType_PublicNumber: {
                placeholderImage = [UIImage imageNamed:@"ReadVerified_icon"];
            }
                break;
            case ChatType_Consult: {
                headerUrl = [[QIMKit sharedInstance] getUserHeaderSrcByUserId:jid];
                if (!placeholderImage) {
                    placeholderImage = [UIImage imageWithData:[QIMKit defaultUserHeaderImage]];
                }
            }
                break;
            case ChatType_ConsultServer: {
                headerUrl = [[QIMKit sharedInstance] getUserHeaderSrcByUserId:realJid];
                if (!placeholderImage) {
                    placeholderImage = [UIImage imageWithData:[QIMKit defaultUserHeaderImage]];
                }
            }
                break;
            case ChatType_CollectionChat: {
                placeholderImage = [UIImage imageNamed:@"relation"];
            }
                break;
                
            default:
                break;
        }
        if (![headerUrl qim_hasPrefixHttpHeader] && headerUrl.length > 0) {
            headerUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], headerUrl];
        } else {

            if (!headerUrl.length && (jid || realJid)) {
                if (chatType == ChatType_GroupChat) {
                    [[QIMKit sharedInstance] updateGroupCard:@[jid]];
                } else if (chatType == ChatType_ConsultServer) {
                    [[QIMKit sharedInstance] updateUserCard:@[realJid]];
                } else {
                    [[QIMKit sharedInstance] updateUserCard:@[jid]];
                }
            } else {
                
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sd_setImageWithURL:headerUrl placeholderImage:placeholderImage];
        });
    });
}

- (void)qim_setCollectionImageWithJid:(NSString *)jid WithChatType:(ChatType)chatType {
    __block NSString *headerUrl = nil;
    __block UIImage *placeholderImage = nil;
    dispatch_async([[QIMKit sharedInstance] getLastQueue], ^{
        switch (chatType) {
            case ChatType_SingleChat: {
                headerUrl = [[QIMKit sharedInstance] getCollectionUserHeaderUrlWithXmppId:jid];
                placeholderImage = [UIImage imageWithData:[QIMKit defaultUserHeaderImage]];
            }
                break;
            case ChatType_GroupChat: {
                headerUrl = [[QIMKit sharedInstance] getCollectionGroupHeaderUrlWithCollectionGroupId:jid];
                placeholderImage = [QIMKit defaultGroupHeaderImage];
            }
                break;
            default:
                break;
        }
        if (![headerUrl qim_hasPrefixHttpHeader] && headerUrl.length > 0) {
            headerUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], headerUrl];
        } else {
            dispatch_async([[QIMKit sharedInstance] getLastQueue], ^{
                if (!headerUrl && jid) {
                    if (chatType == ChatType_GroupChat) {
                        [[QIMKit sharedInstance] updateCollectionGroupCardByGroupId:jid];
                    } else {
                        [[QIMKit sharedInstance] updateCollectionUserCardByUserIds:@[jid]];
                    }
                } else {
                    
                }
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sd_setImageWithURL:headerUrl placeholderImage:placeholderImage];
        });
    });
}

- (void)qim_setImageWithURL:(NSURL *)url {
    [self sd_setImageWithURL:url];
}

- (void)qim_setImageWithURL:(NSURL *)url WithChatType:(ChatType)chatType {
    
    UIImage *placeholderImage = nil;
    switch (chatType) {
        case ChatType_SingleChat: {
            placeholderImage = [UIImage imageWithData:[QIMKit defaultUserHeaderImage]];
        }
            break;
        case ChatType_GroupChat: {
            placeholderImage = [QIMKit defaultGroupHeaderImage];
        }
            break;
        default:
            break;
    }
    [self sd_setImageWithURL:url placeholderImage:placeholderImage];
}


- (void)qim_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self sd_setImageWithURL:url placeholderImage:placeholder];
}

- (void)qim_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder completed:completedBlock];
}

@end
