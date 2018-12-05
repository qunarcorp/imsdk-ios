//
//  QIMMessageManagerFaceView.h
//  QIMEmojiFace
//
//  Created by qitmac000495 on 16/5/10.
//  Copyright © 2016年 Qunar-lu. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMFaceView.h"

@protocol QIMMessageManagerFaceViewDelegate <NSObject>

- (void)SendTheFaceStr:(NSString *)faceStr withPackageId:(NSString *)packageId isDelete:(BOOL)dele;

- (void)SendTheContent;

- (void)segmentBtnDidClickedAtIndex : (NSInteger)index;

@end

@interface QIMMessageManagerFaceView : UIView <QIMFaceViewDelegate>

@property (nonatomic,weak) id<QIMMessageManagerFaceViewDelegate>delegate;
@property (nonatomic,copy) NSString         * packageId;
@property (nonatomic,assign) BOOL showAll;

- (instancetype)initWithFrame:(CGRect)frame WithPkId:(NSString *)packageId;

@end
