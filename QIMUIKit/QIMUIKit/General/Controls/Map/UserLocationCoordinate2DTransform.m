//
//  UserLocationCoordinate2DTransform.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/2/22.
//
//

#import "UserLocationCoordinate2DTransform.h"

@implementation UserLocationCoordinate2DTransform

+ (instancetype)sharedInstanced {
    
    static UserLocationCoordinate2DTransform *__userLocationTrans = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __userLocationTrans = [[UserLocationCoordinate2DTransform alloc] init];
    });
    return __userLocationTrans;
}


/**
 高德地图坐标系转百度地图坐标系

 @param gd_coordinate 高德地图坐标系
 @return 百度地图坐标系
 */
- (CLLocationCoordinate2D)getBaiduFromGaodeForLocationCoordinate:(CLLocationCoordinate2D)gd_coordinate
{
    CLLocationCoordinate2D bd_coordinate;
    double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    double x = gd_coordinate.longitude, y = gd_coordinate.latitude;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    bd_coordinate.longitude = z * cos(theta) + 0.0065;
    bd_coordinate.latitude = z * sin(theta) + 0.006;
    return bd_coordinate;
}

/**
 百度地图坐标系转高德地图坐标系
 @param gd_coordinate 百度地图坐标系
 @return 高德地图坐标系
 */
- (CLLocationCoordinate2D)getGaodeFromBaiduForLocationCoordinate:(CLLocationCoordinate2D)bd_coordinate
{
    CLLocationCoordinate2D gd_coordinate;
    double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    double x = bd_coordinate.longitude - 0.0065, y = bd_coordinate.latitude - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    gd_coordinate.longitude = z * cos(theta);
    gd_coordinate.latitude = z * sin(theta);
    return gd_coordinate;
}

@end
