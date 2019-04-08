//
//  UserLocationCoordinate2DTransform.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/2/22.
//
//

#import "QIMCommonUIFramework.h"
#import <CoreLocation/CoreLocation.h>

@interface UserLocationCoordinate2DTransform : NSObject

+ (instancetype)sharedInstanced;

- (CLLocationCoordinate2D)getBaiduFromGaodeForLocationCoordinate:(CLLocationCoordinate2D)gd_coordinate;

- (CLLocationCoordinate2D)getGaodeFromBaiduForLocationCoordinate:(CLLocationCoordinate2D)bd_coordinate;

@end
