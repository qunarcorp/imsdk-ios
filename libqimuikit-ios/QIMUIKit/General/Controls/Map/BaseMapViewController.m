
//
//  BaseMapViewController.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "BaseMapViewController.h"
#define DefaultLocationTimeout  10
#define DefaultReGeocodeTimeout 10
@interface BaseMapViewController() <AMapLocationManagerDelegate>

@property (nonatomic, assign) BOOL isFirstAppear;

@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;

@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

@implementation BaseMapViewController
@synthesize mapView = _mapView;
@synthesize search  = _search;

#pragma mark - Utility

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置期望定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置定位超时时间
//    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    
    //设置逆地理超时时间
//    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
}

- (void)reGeocodeAction
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //进行单次带逆地理定位请求
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

- (void)initCompleteBlock
{
    __weak BaseMapViewController *weakSelf = self;
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error)
        {
            QIMVerboseLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            //如果为定位失败的error，则不进行annotation的添加
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        //得到定位信息，添加annotation
        if (location)
        {
            weakSelf.location = location;
        }
    };
}


- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
}

- (void)clearSearch
{
    self.search.delegate = nil;
}

/**
 *  hook,子类覆盖它,实现想要在viewDidAppear中执行一次的方法,搜索中有用到
 */
- (void)hookAction
{
}

#pragma mark - Handle Action

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self clearMapView];
    
    [self clearSearch];
}

#pragma mark - AMapSearchDelegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    QIMVerboseLog(@"%s: searchRequest = %@, errInfo= %@", __func__, [request class], error);
}

#pragma mark - Initialization

- (void)initMapView
{
    if (self.mapView == nil) {
        self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        self.mapView.delegate = self;
        [self.view addSubview:self.mapView];
    }
}

- (void)initAppleMapView {
    
    if (self.appleMapView == nil) {
        self.appleMapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        self.appleMapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.appleMapView.delegate = self;
        [self.view addSubview:self.appleMapView];
        [self.appleMapView setHidden:YES];
    }
}

- (void)initSearch
{
    
    [AMapServices sharedServices].apiKey = [[QIMKit sharedInstance] getGAODE_APIKEY];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}

- (void)initBaseNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
}

- (void)initTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.text             = title;
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - Handle URL Scheme

- (NSString *)getApplicationName
{
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return [bundleInfo valueForKey:@"CFBundleDisplayName"] ?: [bundleInfo valueForKey:@"CFBundleName"];
}

- (NSString *)getApplicationScheme
{
    NSDictionary *bundleInfo    = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier  = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *URLTypes           = [bundleInfo valueForKey:@"CFBundleURLTypes"];
    
    NSString *scheme;
    for (NSDictionary *dic in URLTypes)
    {
        NSString *URLName = [dic valueForKey:@"CFBundleURLName"];
        if ([URLName isEqualToString:bundleIdentifier])
        {
            scheme = [[dic valueForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
            break;
        }
    }
    
    return scheme;
}

#pragma mark - Life Cycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isFirstAppear)
    {
        self.mapView.visibleMapRect = MAMapRectMake(220880104, 101476980, 27249, 46665);
        _isFirstAppear = NO;
        
        [self hookAction];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isFirstAppear = YES;
    
    [self initTitle:self.title];
    
    [self initBaseNavigationBar];
    
    [self initMapView];
    [self initAppleMapView]; 
    [self initSearch];
    
    [self initCompleteBlock];
    
    [self configLocationManager];
}

@end
