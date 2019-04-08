//
//  QIMSTAlertView.h
//  QIMSTAlertView
//
//  Created by Nestor on 09/28/2014.
//  Copyright (c) 2014 Nestor. All rights reserved.
//

#import "QIMCommonUIFramework.h"

typedef void (^QIMSTAlertViewBlock)();

typedef void (^QIMSTAlertViewStringBlock)(NSString*);

@interface QIMSTAlertView : NSObject <UIAlertViewDelegate>

/**
 The native UIAlertView reference. You can make any modification to the native alert view, after the init.
 */
@property (nonatomic, strong) UIAlertView* alertView;

/**
Show a native UIAlertView with two buttons. The text and the title is custom, and is also custom the text of the buttons.
 @param title Title of the UIAlertView
 @param message Message of the UIAlertView
 @param cancelButtonTitle Text of the second button
 @param otherButtonTitles Text of the first button
 @param cancelButtonBlock Code to run if the user tap at the second button
 @param otherButtonBlock Code to run if the user tap at the first button
 @return The reference to the QIMSTAlertView
 */

- (id) initWithTitle:(NSString *)title
             message:(NSString *)message
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSString *)otherButtonTitles
   cancelButtonBlock:(QIMSTAlertViewBlock)cancelButtonBlock
    otherButtonBlock:(QIMSTAlertViewBlock)otherButtonBlock;


/**
 Show a native UIAlertView with two buttons and a UITextField. The text and the title is custom, and is also custom the text of the buttons and the UITextField value and placeholder.
 @param title Title of the UIAlertView
 @param message Message of the UIAlertView
 @param textFieldHint Text of the placeholder
 @param textFieldValue Initial text of the UITextField
 @param cancelButtonTitle Text of the second button
 @param otherButtonTitles Text of the first button
 @param cancelButtonBlock Code to run if the user tap at the second button
 @param otherButtonBlock Code to run if the user tap at the first button
 @return The reference to the QIMSTAlertView
 */
- (id) initWithTitle:(NSString *)title
             message:(NSString*)message
       textFieldHint:(NSString *)textFieldMessage
      textFieldValue:(NSString *)texttFieldValue
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSString *)otherButtonTitles
   cancelButtonBlock:(QIMSTAlertViewBlock)cancelButtonBlock
    otherButtonBlock:(QIMSTAlertViewStringBlock)otherButtonBlock;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
