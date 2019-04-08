//
//  QIMKit+QIMTPRequest.h
//  QIMCommon
//
//  Created by 李露 on 11/5/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMKit.h"

@interface QIMKit (QIMTPRequest)

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback;

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withRequestBodyData:(NSData *)bodyData withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback;

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withChatId:(NSString *)chatId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType;

- (void)synchronizeDujiaWarningWithJid:(NSString *)dujiaJid;

@end
