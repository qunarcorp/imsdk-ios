
#import "QIMContactObject.h"

#pragma mark - QIMContactObject

@interface QIMContactObject ()

/**
 *  存放ABRecordRef属性的对象
 */
@property (nonatomic, strong)NSValue * recordRefValue;

@end


@implementation QIMContactObject


@end








//QTContactNameObject

#pragma mark - QTContactNameObject
@implementation QTContactNameObject

-(NSString *)name
{
    //除nil处理
    self.middleName = (self.middleName) ? self.middleName : @"";
    self.givenName = (self.givenName) ? self.givenName : @"";
    self.familyName = (self.familyName) ? self.familyName : @"";
    
    
    return [[self.familyName stringByAppendingString:self.middleName] stringByAppendingString:self.givenName];
}

@end









#pragma mark - QTContactPhoneObject
@implementation QTContactPhoneObject



@end









#pragma mark -  QTContactJobObject
@implementation QTContactJobObject



@end









#pragma mark - QTContactEmailObject
@implementation QTContactEmailObject



@end








#pragma mark - QTContactAddressObject
@implementation QTContactAddressObject



@end









#pragma mark - QTContactBrithdayObject
@implementation QTContactBrithdayObject



@end








#pragma mark - QTContactInstantMessageObject
@implementation QTContactInstantMessageObject



@end





#pragma mark - QTContactRelatedNamesObject
@implementation QTContactRelatedNamesObject



@end






#pragma mark - QTContactSocialProfileObject
@implementation QTContactSocialProfileObject



@end

