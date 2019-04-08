//
//  QIMSTAlertView.m
//  QIMSTAlertView
//
//  Created by Nestor on 09/28/2014.
//  Copyright (c) 2014 Nestor. All rights reserved.
//

#import "QIMSTAlertView.h"


typedef enum {
    QIMSTAlertViewTypeNormal,
    QIMSTAlertViewTypeTextField
} QIMSTAlertViewType;

@implementation QIMSTAlertView{
    QIMSTAlertViewBlock cancelButtonBlock;
    QIMSTAlertViewBlock otherButtonBlock;
    
    QIMSTAlertViewStringBlock textFieldBlock;
}

@synthesize alertView;


- (void) alertView:(UIAlertView *)theAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && cancelButtonBlock)
        cancelButtonBlock();
    else if (buttonIndex == 1 && theAlertView.tag == QIMSTAlertViewTypeNormal && otherButtonBlock)
        otherButtonBlock();
    else if (buttonIndex == 1 && theAlertView.tag == QIMSTAlertViewTypeTextField && textFieldBlock)
        textFieldBlock([alertView textFieldAtIndex:0].text);
    
}

- (void) alertViewCancel:(UIAlertView *)theAlertView
{
    if (cancelButtonBlock)
        cancelButtonBlock();
}

- (id) initWithTitle:(NSString*)title
             message:(NSString*)message
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSString *)otherButtonTitles
   cancelButtonBlock:(QIMSTAlertViewBlock)theCancelButtonBlock
    otherButtonBlock:(QIMSTAlertViewBlock)theOtherButtonBlock
{

    cancelButtonBlock = [theCancelButtonBlock copy];
    otherButtonBlock = [theOtherButtonBlock copy];
    
    alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    alertView.tag = QIMSTAlertViewTypeNormal;
    
    [alertView show];
    
    return self;
}

- (id) initWithTitle:(NSString*)title
             message:(NSString*)message
       textFieldHint:(NSString*)textFieldMessage
      textFieldValue:(NSString *)texttFieldValue
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSString *)otherButtonTitles
   cancelButtonBlock:(QIMSTAlertViewBlock)theCancelButtonBlock
    otherButtonBlock:(QIMSTAlertViewStringBlock)theOtherButtonBlock
{
    
    cancelButtonBlock = [theCancelButtonBlock copy];
    textFieldBlock = [theOtherButtonBlock copy];
    
    alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    alertView.tag = QIMSTAlertViewTypeTextField;

    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setPlaceholder:textFieldMessage];
    [[alertView textFieldAtIndex:0] setText:texttFieldValue];
    
    [alertView show];
    
    return self;
}



@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
