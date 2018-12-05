//
//  QIMCommonUserInfoCell.h
//  LLWeChat
//
//  Created by GYJZH on 9/8/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMCommonUserInfoCell : UITableViewCell

@property (nonatomic, strong) YLImageView *avatarImage;       //用户头像

@property (nonatomic, strong) UILabel *nickNameLabel;         //昵称

@property (nonatomic, strong) UILabel *signatureLabel;      //个性签名

@property (nonatomic, assign) BOOL showQRCode;

@end
