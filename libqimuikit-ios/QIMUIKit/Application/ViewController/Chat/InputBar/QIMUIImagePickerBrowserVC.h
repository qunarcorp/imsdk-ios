//
//  QIMUIImagePickerBrowserVC.h
//  DangDiRen
//
//  Created by 平 薛 on 14-4-14.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@protocol QIMUIImagePickerBrowserVCDelegate;

@interface QIMUIImagePickerBrowserVC : QTalkViewController

@property (nonatomic, retain) UIImage *sourceImage;
@property (nonatomic, assign) id<QIMUIImagePickerBrowserVCDelegate> delegate;

@end

@protocol QIMUIImagePickerBrowserVCDelegate <NSObject>
@required
- (void)imagePickerBrowserDidCancel:(QIMUIImagePickerBrowserVC *)pickerBrowser;
- (void)imagePickerBrowserDidFinish:(QIMUIImagePickerBrowserVC *)pickerBrowser;
@end
