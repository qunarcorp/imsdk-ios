//
//  QIMAnnotation.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/1.
//
//

#import "QIMCommonUIFramework.h"
#import <MapKit/MapKit.h>
@interface QIMAnnotation : NSObject <MKAnnotation>

//显示标注的经纬度
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
//标注的标题
@property (nonatomic,copy,readonly) NSString * title;
//标注的子标题
@property (nonatomic,copy,readonly) NSString * subtitle;
@property (nonatomic, strong, readonly) UIColor *pinColor;

-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle
                subTitle:(NSString *)paramTitle;

@end
