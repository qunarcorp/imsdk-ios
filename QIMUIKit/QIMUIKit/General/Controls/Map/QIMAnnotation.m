//
//  QIMAnnotation.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/1.
//
//

#import "QIMAnnotation.h"

@implementation QIMAnnotation

-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle
                subTitle:(NSString *)paramSubitle
{
    self = [super init];
    if(self != nil)
    {
        _coordinate = paramCoordinates;
        _title = paramTitle;
        _subtitle = paramSubitle;
        _pinColor = [UIColor redColor];
//        _pinColor = MKPinAnnotationColorGreen;
    }
    return self;
}


@end
