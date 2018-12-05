//
//  BaseMapViewController.h
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <MapKit/MapKit.h>
#import "QIMMsgBaseVC.h"

@interface BaseMapViewController : QIMMsgBaseVC <MAMapViewDelegate, MKMapViewDelegate,AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) MKMapView *appleMapView;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) CLLocation *location;

- (void)returnAction;

- (void)reGeocodeAction;

- (NSString *)getApplicationName;
- (NSString *)getApplicationScheme;
@end
