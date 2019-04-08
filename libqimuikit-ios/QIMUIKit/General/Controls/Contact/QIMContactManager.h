//
//  QIMContactManager.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/11/10.
//
//

#import "QIMCommonUIFramework.h"
#import <ContactsUI/CNContactViewController.h>
#import <ContactsUI/CNContactPickerViewController.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface QIMContactManager : NSObject
+ (UIAlertController *)showAlertViewControllerWithPhoneNum:(NSString *)phoneNum rootVc:(UIViewController *)rootVc;
+ (instancetype)sharedInstanceWithRootVc:(UIViewController *)rootVc phoneNum:(NSString *)phoneNum;
- (void)saveNewContact;
- (void)saveExistContact;
@end
