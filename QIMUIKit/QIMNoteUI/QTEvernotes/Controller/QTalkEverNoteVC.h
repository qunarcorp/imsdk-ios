//
//  KCHtmlEditorVC.h
//  Noob2017
//
//  Created by lihuaqi on 2017/9/18.
//  Copyright © 2017年 lihuaqi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    ENUM_EverNote_TypeNew = 0,//新建
    ENUM_EverNote_TypeEdit//编辑
} ENUM_EverNote_Type;

@class QIMNoteModel;
@interface QTalkEverNoteVC : UIViewController
@property(nonatomic, assign) ENUM_EverNote_Type everNoteType;
@property(nonatomic, strong) QIMNoteModel *evernoteSModel;
@end
