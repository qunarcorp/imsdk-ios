#import "QIMContactsManager8.h"
#import "QIMContactObject.h"
#import "QIMContactObjectManager.h"
@import AddressBook;

typedef void(^ContactDidObatinBlock)(NSArray <QIMContactObject *> *);

@interface QIMContactsManager8 ()

@property (nonatomic, assign, nullable)ABAddressBookRef addressBook;//请求通讯录的结构体对象
@property (nonatomic, copy) ContactDidObatinBlock contactsDidObtainBlockHandle;

@end

@implementation QIMContactsManager8

-(instancetype)init {
    if (self = [super init]) {
        self.addressBook = ABAddressBookCreate();
        
//        QIMVerboseLog(@"%@",@([(id)self.addressBook retainCount]));

        /**
         *  注册通讯录变动的回调
         *
         *  @param self.addressBook          注册的addressBook
         *  @param addressBookChangeCallBack 变动之后进行的回调方法
         *  @param void                      传参，这里是将自己作为参数传到方法中
         */
        ABAddressBookRegisterExternalChangeCallback(self.addressBook,  addressBookChangeCallBack, (void *)CFBridgingRetain(self));
    }
    return self;
}


void addressBookChangeCallBack(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    //coding when addressBook did changed
    QIMVerboseLog(@"通讯录发生变化啦");
    
    //初始化对象
    QIMContactsManager8 * contactManager = CFBridgingRelease(context);
    
    //重新获取联系人
    [contactManager obtainContacts:addressBook];
    
}

+(instancetype)sharedInstance {
    static QIMContactsManager8 * addressBookManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        addressBookManager = [[QIMContactsManager8 alloc]init];
    });
    return addressBookManager;
}

-(void)dealloc {
    //移除监听
    ABAddressBookUnregisterExternalChangeCallback(self.addressBook, addressBookChangeCallBack, (__bridge void *)(self));
    
    //释放
    CFRelease(self.addressBook);
}

#pragma mark - 请求通讯录
//请求通讯录
-(void)requestContactsComplete:(void (^)(NSArray<QIMContactObject *> * _Nonnull))completeBlock {
    self.contactsDidObtainBlockHandle = completeBlock;
    [self checkAuthorizationStatus];
}

/**
 *  检测权限并作响应的操作
 */
- (void)checkAuthorizationStatus {
    switch (ABAddressBookGetAuthorizationStatus()) {
            //存在权限
        case kABAuthorizationStatusAuthorized:
            //获取通讯录
            [self obtainContacts:self.addressBook];
            break;
            
            //权限未知
        case kABAuthorizationStatusNotDetermined:
            //请求权限
            [self requestAuthorizationStatus];
            break;
            
            //如果没有权限
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted://需要提示
            //弹窗提醒
            [self showAlertController];
        
            break;
        default:
            break;
    }
}

/**
 *  获取通讯录中的联系人
 */
- (void)obtainContacts:(ABAddressBookRef)addressBook {
    
    //按照添加时间请求所有的联系人
    CFArrayRef contants = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    //按照排序规则请求所有的联系人
//    ABRecordRef recordRef = ABAddressBookCopyDefaultSource(addressBook);
//    CFArrayRef contants = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, recordRef, kABPersonSortByFirstName);

    //存放所有联系人的数组
    NSMutableArray <QIMContactObject *> * contacts = [NSMutableArray arrayWithCapacity:0];
    
    //遍历获取所有的数据
    for (NSInteger i = 0; i < CFArrayGetCount(contants); i++) {
        //获得People对象
        ABRecordRef recordRef = CFArrayGetValueAtIndex(contants, i);
        
        //获得contact对象
        QIMContactObject * contactObject = [QIMContactObjectManager contantObject:recordRef];
        
        //添加对象
        [contacts addObject:contactObject];
    }
    
    //释放资源
    CFRelease(contants);
    
    //进行回调赋值
    ContactDidObatinBlock copyBlock  = self.contactsDidObtainBlockHandle;
    
    //进行数据回调
    copyBlock([NSArray arrayWithArray:contacts]);
}

/**
 *  请求通讯录的权限
 */
- (void)requestAuthorizationStatus {
    //避免强引用
//    typeof(self) copy_self = [self copy];
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
       
        //权限得到允许
        if (granted == true) {
            //主线程获取联系人
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self obtainContacts:self.addressBook];
            });
        }
    });
}

/**
 *  弹出提示AlertController
 */
- (void)showAlertController {
    
}

@end

@implementation QIMContactsManager8 (QTCodingHandle)

/**
 *  添加联系人姓名属性
 */
- (void)codingAddPersonToAddressBook {
    //实例化一个Person数据
    ABRecordRef person = ABPersonCreate();
    ABAddressBookRef addressBook = ABAddressBookCreate();

    //实例化一个CFErrorRef属性
    CFErrorRef error = NULL;

#pragma mark - 添加联系人姓名属性
    /*添加联系人姓名属性*/
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)@"Wen", &error);       //名字
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFStringRef)@"Yue", &error);        //姓氏
    ABRecordSetValue(person, kABPersonMiddleNameProperty,(__bridge CFStringRef)@"YW", &error);        //名字中的信仰名称（比如Jane·K·Frank中的K
    ABRecordSetValue(person, kABPersonPrefixProperty,(__bridge CFStringRef)@"W", &error);             //名字前缀
    ABRecordSetValue(person, kABPersonSuffixProperty,(__bridge CFStringRef)@"Y", &error);             //名字后缀
    ABRecordSetValue(person, kABPersonNicknameProperty,(__bridge CFStringRef)@"", &error);            //名字昵称
    ABRecordSetValue(person, kABPersonFirstNamePhoneticProperty,(__bridge CFStringRef)@"Wen", &error);//名字的拼音音标
    ABRecordSetValue(person, kABPersonLastNamePhoneticProperty,(__bridge CFStringRef)@"Yue", &error); //姓氏的拼音音标
    ABRecordSetValue(person, kABPersonMiddleNamePhoneticProperty,(__bridge CFStringRef)@"Y", &error); //英文信仰缩写字母的拼音音标

#pragma mark - 添加联系人类型属性
    /*添加联系人类型属性*/
    ABRecordSetValue(person, kABPersonKindProperty, kABPersonKindPerson, &error);      //设置为个人类型
    ABRecordSetValue(person, kABPersonKindProperty, kABPersonKindOrganization, &error);//设置为公司类型

#pragma mark - 添加联系人头像属性
    /*添加联系人头像属性*/
    ABPersonSetImageData(person, (__bridge CFDataRef)(UIImagePNGRepresentation([UIImage imageNamed:@""])),&error);//设置联系人头像

#pragma mark - 添加联系人电话信息
    /*添加联系人电话信息*/
    //实例化一个多值属性
    ABMultiValueRef phoneMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);

    //设置相关标志位,也可以不设置，下面的方法写NULL即可
    ABMultiValueIdentifier MobileIdentifier;    //手机
    ABMultiValueIdentifier iPhoneIdentifier;    //iPhone
    ABMultiValueIdentifier MainIdentifier;      //主要
    ABMultiValueIdentifier HomeFAXIdentifier;   //家中传真
    ABMultiValueIdentifier WorkFAXIdentifier;   //工作传真
    ABMultiValueIdentifier OtherFAXIdentifier;  //其他传真
    ABMultiValueIdentifier PagerIdentifier;     //传呼

    //设置相关数值
    ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551211", kABPersonPhoneMobileLabel, &MobileIdentifier);    //手机
    ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551212", kABPersonPhoneIPhoneLabel, &iPhoneIdentifier);    //iPhone
    ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551213", kABPersonPhoneMainLabel, &MainIdentifier);        //主要
    ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551214", kABPersonPhoneHomeFAXLabel, &HomeFAXIdentifier);  //家中传真
    ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551215", kABPersonPhoneWorkFAXLabel, &WorkFAXIdentifier);  //工作传真
    ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551216", kABPersonPhoneOtherFAXLabel, &OtherFAXIdentifier);//其他传真
    ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"5551217", kABPersonPhonePagerLabel, &PagerIdentifier);      //传呼

    //自定义标签
    ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFStringRef)@"55512118", (__bridge CFStringRef)@"自定义", &PagerIdentifier);//自定义标签

    //添加属性
    ABRecordSetValue(person, kABPersonPhoneProperty, phoneMultiValue, &error);

    //释放资源
    CFRelease(phoneMultiValue);


#pragma mark - 添加联系人的工作信息
    /*添加联系人的工作信息*/
    ABRecordSetValue(person, kABPersonOrganizationProperty, (__bridge CFStringRef)@"OYue", &error);//公司(组织)名称
    ABRecordSetValue(person, kABPersonDepartmentProperty, (__bridge CFStringRef)@"DYue", &error);  //部门
    ABRecordSetValue(person, kABPersonJobTitleProperty, (__bridge CFStringRef)@"JYue", &error);    //职位

#pragma mark - 添加联系人的邮件信息
    /*添加联系人的邮件信息*/
    //实例化多值属性
    ABMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);

    //设置相关标志位
    ABMultiValueIdentifier QQIdentifier;//QQ

    //进行赋值
    //设置自定义的标签以及值
    ABMultiValueAddValueAndLabel(emailMultiValue, (__bridge CFStringRef)@"77xxxxx48@qq.com", (__bridge CFStringRef)@"QQ", &QQIdentifier);

    //添加属性
    ABRecordSetValue(person, kABPersonEmailProperty, emailMultiValue, &error);

    //释放资源
    CFRelease(emailMultiValue);

#pragma mark -  添加联系人的地址信息
    /*添加联系人的地址信息*/
    //实例化多值属性
    ABMultiValueRef addressMultiValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);

    //设置相关标志位
    ABMultiValueIdentifier AddressIdentifier;

    //初始化字典属性
    CFMutableDictionaryRef addressDictionaryRef = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, NULL, NULL);

    //进行添加
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressCountryKey, (__bridge CFStringRef)@"China");      //国家
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressCityKey, (__bridge CFStringRef)@"WeiFang");       //城市
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressStateKey, (__bridge CFStringRef)@"ShangDong");    //省(区)
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressStreetKey, (__bridge CFStringRef)@"Street");      //街道
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressZIPKey, (__bridge CFStringRef)@"261500");         //邮编
    CFDictionaryAddValue(addressDictionaryRef, kABPersonAddressCountryCodeKey, (__bridge CFStringRef)@"ISO");    //ISO国家编码

    //添加属性
    ABMultiValueAddValueAndLabel(addressMultiValue, addressDictionaryRef, (__bridge CFStringRef)@"主要", &AddressIdentifier);
    ABRecordSetValue(person, kABPersonAddressProperty, addressMultiValue, &error);

    //释放资源
    CFRelease(addressMultiValue);

#pragma mark - 添加联系人的生日信息
    /*添加联系人的生日信息*/
    //添加公历生日
    ABRecordSetValue(person, kABPersonBirthdayProperty, (__bridge CFTypeRef)([NSDate date]), &error);

    //添加联系人
    if (ABAddressBookAddRecord(addressBook, person, &error) == true) {
        //成功就需要保存一下
        ABAddressBookSave(addressBook, &error);
    }
    //不要忘记了释放资源
    CFRelease(person);
    CFRelease(addressBook);
}


@end
