#import "QIMCommonUIFramework.h"

@import AddressBook;

@class QIMContactObject;

NS_ASSUME_NONNULL_BEGIN

@interface QIMContactObjectManager : NSObject

/**
 *  根据ABRecordRef数据获得YContantObject对象
 *
 *  @param recordRef ABRecordRef对象
 *
 *  @return YContantObject对象
 */
+ (QIMContactObject *)contantObject:(ABRecordRef)recordRef;

@end

NS_ASSUME_NONNULL_END
