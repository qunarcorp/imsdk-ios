//
//  QIMWorkCommentModel.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/15.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkCommentModel : NSObject

@property (nonatomic, copy) NSString *anonymousName;    //匿名名称

@property (nonatomic, copy) NSString *anonymousPhoto;   //匿名图标

@property (nonatomic, copy) NSString *commentUUID;      //评论的UUID

@property (nonatomic, copy) NSString *content;          //评论内容

@property (nonatomic, assign) long long createTime;     //评论的创建时间

@property (nonatomic, copy) NSString *fromHost;         //发评论的用户Host

@property (nonatomic, copy) NSString *fromUser;         //发评论的用户UserId

@property (nonatomic, assign) NSInteger rId;            //评论服务器Id

@property (nonatomic, assign) BOOL isAnonymous;         //是否匿名评论

@property (nonatomic, assign) BOOL isDelete;            //是否已删除

@property (nonatomic, assign) BOOL isLike;              //是否自己已点赞

@property (nonatomic, assign) NSInteger likeNum;        //点赞数

@property (nonatomic, copy) NSString *parentCommentUUID;    //父级评论UUID

@property (nonatomic, copy) NSString *postUUID;          //原贴UUID

@property (nonatomic, assign) NSInteger reviewStatus;    //评论审核状态

@property (nonatomic, copy) NSString *toAnonymousName;   //给评论人的匿名名称

@property (nonatomic, copy) NSString *toAnonymousPhoto;  //给评论人的匿名图片

@property (nonatomic, copy) NSString *toHost;            //评论人的Host

@property (nonatomic, copy) NSString *toUser;            //评论人的UserId

@property (nonatomic, assign) BOOL toisAnonymous;        //被评论人是否匿名

@property (nonatomic, assign) long long updateTime;      //评论更新时间

@property (nonatomic, assign) CGFloat rowHeight;        //Moment高度

@end

NS_ASSUME_NONNULL_END
