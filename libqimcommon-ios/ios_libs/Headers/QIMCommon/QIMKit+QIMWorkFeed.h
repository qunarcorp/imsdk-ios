//
//  QIMKit+QIMWorkFeed.h
//  QIMCommon
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMKit (QIMWorkFeed)

- (void)updateLastWorkFeedMsgTime;

- (void)getRemoteMomentDetailWithMomentUUId:(NSString *)momentId withCallback:(QIMKitgetMomentDetailSuccessedBlock)callback;

- (void)getAnonyMouseDicWithMomentId:(NSString *)momentId WithCallBack:(QIMKitgetAnonymouseSuccessedBlock)callback;

- (void)pushNewMomentWithMomentDic:(NSDictionary *)momentDic;

- (void)getMomentHistoryWithLastMomentId:(NSString *)momentId;

- (void)deleteRemoteMomentWithMomentId:(NSString *)momentId;

- (void)likeRemoteMomentWithMomentId:(NSString *)momentId withLikeFlag:(BOOL)likeFlag withCallBack:(QIMKitLikeMomentSuccessedBlock)callback;

- (void)likeRemoteCommentWithCommentId:(NSString *)commentId withMomentId:(NSString *)momentId withLikeFlag:(BOOL)likeFlag withCallBack:(QIMKitLikeContentSuccessedBlock)callback;

- (void)uploadCommentWithCommentDic:(NSDictionary *)commentDic;

- (void)getRemoteRecentHotCommentsWithMomentId:(NSString *)momentId withHotCommentCallBack:(QIMKitWorkCommentBlock)callback;

- (void)getRemoteRecentNewCommentsWithMomentId:(NSString *)momentId withNewCommentCallBack:(QIMKitWorkCommentBlock)callback;

- (NSDictionary *)getWorkMomentWihtMomentId:(NSString *)momentId;

- (void)getWorkMomentWithLastMomentTime:(long long)lastMomentTime withUserXmppId:(NSString *)xmppId WihtLimit:(int)limit WithOffset:(int)offset withFirstLocalMoment:(BOOL)firstLocal WihtComplete:(void (^)(NSArray *))complete;

- (void)deleteRemoteCommentWithComment:(NSString *)commentId withPostUUId:(NSString *)postUUId withCallback:(QIMKitWorkCommentDeleteSuccessBlock)callback;

#pragma mark - Remote Notice

- (void)updateRemoteWorkNoticeMsgReadStateWithTime:(long long)time;

#pragma mark - Local Comment

- (void)getWorkCommentWithLastCommentRId:(NSInteger)lastCommentRId withMomentId:(NSString *)momentId WihtLimit:(int)limit WithOffset:(int)offset withFirstLocalComment:(BOOL)firstLocal WihtComplete:(void (^)(NSArray *))complete;

#pragma mark - Local NoticeMsg

- (void)getRemoteLastWorkMoment;

- (NSDictionary *)getLastWorkMoment;

- (NSInteger)getWorkNoticeMessagesCount;

- (NSInteger)getWorkNoticePOSTCount;

- (void)updateWorkNoticePOSTMessageReadState;

- (NSArray *)getWorkNoticeMessagesWihtLimit:(int)limit WithOffset:(int)offset;

- (void)updateLocalWorkNoticeMsgReadStateWithTime:(long long)time;

@end

NS_ASSUME_NONNULL_END
