//
//  QIMContactManager.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/11/10.
//
//

#import "QIMContactManager.h"
#import "QIMContactsManager8.h"
#import "QIMContactObject.h"

@interface QIMContactManager () <CNContactViewControllerDelegate,CNContactPickerDelegate, ABNewPersonViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate>
@property (nonatomic, strong) UIViewController *rootVc;
@property (nonatomic, strong) NSString *phoneNum;
@end

@implementation QIMContactManager

+ (instancetype)sharedInstanceWithRootVc:(UIViewController *)rootVc phoneNum:(NSString *)phoneNum {
    
    static QIMContactManager *__contactManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __contactManager = [[QIMContactManager alloc] initWithRootVc:rootVc phoneNum:phoneNum];
    });
    return __contactManager;
}

- (instancetype)initWithRootVc:(UIViewController *)rootVc phoneNum:(NSString *)phoneNum {
    
    self = [super init];
    if (self) {
        self.rootVc = rootVc;
        self.phoneNum = phoneNum;
    }
    return self;
}

- (void)saveNewContact {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {

        CNMutableContact *contact = [[CNMutableContact alloc] init];
        [self setValue4Contact:contact existContect:NO];
        //创建新建好友页面
        CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:contact];
        controller.delegate = self;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.rootVc presentViewController:navigation animated:YES completion:nil];
    }
//    //实例化一个person
//    ABRecordRef person = ABPersonCreate();
//    //设置姓名
//    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)@"firstName", NULL);
//    ABNewPersonViewController *newPersonViewController = [[ABNewPersonViewController alloc] init];
//    newPersonViewController.newPersonViewDelegate = self;
//    //释放资源
//    CFRelease(person);
//    UINavigationController *newPersonNavigationVC = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
//    [self.rootVc presentViewController:newPersonNavigationVC animated:YES completion:nil];
}

//保存现有联系人实现
- (void)saveExistContact {

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {

        CNContactPickerViewController *controller = [[CNContactPickerViewController alloc] init];
        controller.delegate = self;
        [self.rootVc presentViewController:controller animated:YES completion:nil];
    }
//    ABPeoplePickerNavigationController *peoplePickerVc = [[ABPeoplePickerNavigationController alloc] init];
//    peoplePickerVc.peoplePickerDelegate = self;
//    [self.rootVc presentViewController:peoplePickerVc animated:YES completion:nil];
}

#warning iOS8-iOS9的保存联系人
#pragma mark - ABNewPersonViewControllerDelegate
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(nullable ABRecordRef)person {
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person {
    [peoplePicker dismissViewControllerAnimated:NO completion:^{
        
        ABPersonViewController *peopleVc = [[ABPersonViewController alloc] init];
        peopleVc.displayedPerson = person;
        peopleVc.allowsEditing = YES;
        peopleVc.personViewDelegate = self;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:peopleVc];
        [self.rootVc presentViewController:navigation animated:YES completion:nil];
    }];
}

#warning iOS9之后的保存联系人
#pragma mark - CNContactViewControllerDelegate
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact{
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CNContactPickerDelegate
//点击联系人的代理方法
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    
    [picker dismissViewControllerAnimated:NO completion:^{
        
        CNMutableContact *existContact = [contact mutableCopy];
        [self setValue4Contact:existContact existContect:YES];
        CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:existContact];
        controller.delegate = self;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
        [self.rootVc presentViewController:navigation animated:YES completion:nil];
    }];
}
- (void)setValue4Contact:(CNMutableContact *)contact existContect:(BOOL)exist{

    CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:self.phoneNum]];
    if (!exist) {
        contact.phoneNumbers = @[phoneNumber];
    }
    //现有联系人情况
    else{
        if ([contact.phoneNumbers count] >0) {
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] initWithArray:contact.phoneNumbers];
            [phoneNumbers addObject:phoneNumber];
            contact.phoneNumbers = phoneNumbers;
        }else{
            contact.phoneNumbers = @[phoneNumber];
        }
    }
}

+ (UIAlertController *)showAlertViewControllerWithPhoneNum:(NSString *)phoneNum rootVc:(UIViewController *)rootVc {
    
    NSString *alertMsg = [NSString stringWithFormat:@"%@可能是一个电话号码，你可以", phoneNum];
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:alertMsg preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *callAction = [UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *telPhoneNum = [NSString stringWithFormat:@"telprompt:%@", phoneNum];
        NSString *deviceType = [UIDevice currentDevice].model;
        if (TARGET_IPHONE_SIMULATOR || [deviceType isEqualToString:@"iPod touch"] || [deviceType  isEqualToString:@"iPad"] || [deviceType  isEqualToString:@"iPhone Simulator"]) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的设备不支持通话功能" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil,nil];
            [alert show];
            return;
            
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telPhoneNum]];
        }
    }];
    UIAlertAction *copyNumAction = [UIAlertAction actionWithTitle:@"复制号码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *board = [UIPasteboard generalPasteboard];
        [board setString:phoneNum];
    }];
    UIAlertAction *addContactAction = [UIAlertAction actionWithTitle:@"添加到手机通讯录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *saveContactAlertVc = [UIAlertController alertControllerWithTitle:nil message:phoneNum preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *saveNewContactAction = [UIAlertAction actionWithTitle:@"创建新联系人" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            QIMContactManager *manager = [QIMContactManager sharedInstanceWithRootVc:rootVc phoneNum:phoneNum];
            [manager saveNewContact];
        }];
        UIAlertAction *saveExistContactAction = [UIAlertAction actionWithTitle:@"添加到现有联系人" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            QIMContactManager *manager = [QIMContactManager sharedInstanceWithRootVc:rootVc phoneNum:phoneNum];
            [manager saveExistContact];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [saveContactAlertVc addAction:saveNewContactAction];
        [saveContactAlertVc addAction:saveExistContactAction];
        [saveContactAlertVc addAction:cancelAction];
        [rootVc presentViewController:saveContactAlertVc animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:callAction];
    [alertVc addAction:copyNumAction];
    [alertVc addAction:addContactAction];
    [alertVc addAction:cancelAction];
    return alertVc;
}

@end
