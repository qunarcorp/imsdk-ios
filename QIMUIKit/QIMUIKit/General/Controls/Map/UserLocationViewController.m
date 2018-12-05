//
//  UserLocationViewController.m
//  Category_demo
//
//  Created by songjian on 13-3-21.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

typedef enum {
    MapLocationStatusLocationing,
    MapLocationStatusDraging,
    MapLocationStatusDone,
    MapLocationStatusFailed,
} MapLocationStatus;

#import "UserLocationViewController.h"
#import "QIMLocationCell.h"
#import <MapKit/MapKit.h>
#import "QIMAnnotation.h"
#import "NSBundle+QIMLibrary.h"
#import "UserLocationCoordinate2DTransform.h"
@interface MapAdressInfo : NSObject

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString         * adress;
@property (nonatomic,strong)UIImage         * icon;
//MAPointAnnotation *pointAnnotation
@end

@implementation MapAdressInfo

@end

@interface UserLocationViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView         * _mainTableView;
    MapLocationStatus     _status;
    BOOL                  _hasLocation;
    NSMutableArray      * _dataSource;
    BOOL                  _isNotSend;
    BOOL                  _isFirstRegion;
    NSString            * _address;
    CLLocationCoordinate2D _coordinate;
    MapAdressInfo       * _currentAdressInfo;
    UIImageView         * _locationFlag;
    AMapAddressComponent    * _addressSearchResult;
    NSInteger                 _selectIndex;
    UIButton            * _myAddressBtn;
    UIButton            * _otherMapBtn;
    BOOL                  _isMapSmall;
    UILabel             * _tipsLabel;
    BOOL                  _isSelected;
    AMapPOI             *_userPOI;
    //国外坐标
    BOOL                _isAbroadLocation;
}

@property (nonatomic, retain)UISegmentedControl *showSegment;
@property (nonatomic, retain)UISegmentedControl *modeSegment;
@property (nonatomic, strong) MAPointAnnotation *pointAnnotation;
@property (nonatomic, assign) BOOL isSwitching;

@end

@implementation UserLocationViewController
@synthesize showSegment, modeSegment;

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation;
    }else{
        return YES;
    }
    
}

- (MAPointAnnotation *)pointAnnotation {
    
    if (!_pointAnnotation) {
        
        _pointAnnotation = [[MAPointAnnotation alloc] init];
    }
    return _pointAnnotation;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationMaskLandscape;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft;
    }else{
        UIInterfaceOrientation orientation;
        switch ([[UIDevice currentDevice] orientation]) {
            case UIDeviceOrientationPortrait:
            {
                orientation = UIInterfaceOrientationPortrait;
            }
                break;
            case UIDeviceOrientationPortraitUpsideDown:
            {
                orientation = UIInterfaceOrientationPortraitUpsideDown;
            }
                break;
            case UIDeviceOrientationLandscapeLeft:
            {
                orientation = UIInterfaceOrientationLandscapeLeft;
            }
                break;
            case UIDeviceOrientationLandscapeRight:
            {
                orientation = UIInterfaceOrientationLandscapeRight;
            }
                break;
            default:
            {
                orientation = UIInterfaceOrientationPortrait;
            }
                break;
        }
        return orientation;
        
    }
}


#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (_hasLocation == NO) {
        
        _tipsLabel.text = @"正在获取周边信息...";
        if (mapView.isHidden) {
            return;
        }
        
        if (self.isSwitching) {
            self.isSwitching = NO;
            return;
        }
        
        if (!self.location || self.location.coordinate.latitude == 0 || self.location.coordinate.longitude == 0) {
            self.location = userLocation.location;
        }
        if ([mapView isKindOfClass:[MAMapView class]]) {
            if (!AMapDataAvailableForCoordinate(self.location.coordinate)) {
                _isAbroadLocation = YES;
                [self updateAppleMapViewWithUserLocation:userLocation];
            } else {
                _isAbroadLocation = NO;
                [self updateGaodeMapView];
            }
        } else {
            if (AMapDataAvailableForCoordinate(self.location.coordinate)) {
                [self updateAppleMapViewWithUserLocation:userLocation];
            }
        }
    }
}

- (void)updateGaodeMapView {
    
    self.isSwitching = YES;
    [self.mapView setHidden:NO];
    [self.appleMapView setHidden:YES];
    
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(self.location.coordinate.latitude,self.location.coordinate.longitude);
    float zoomLevel = 0.02;
    
    [self.mapView setCenterCoordinate:self.location.coordinate];
    
    if (_currentAdressInfo == nil) {
        _currentAdressInfo = [[MapAdressInfo alloc] init];
    }
    _currentAdressInfo.coordinate = self.location.coordinate;
    
    MACoordinateRegion region = MACoordinateRegionMake(coords,MACoordinateSpanMake(zoomLevel, zoomLevel));
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location                    = [AMapGeoPoint locationWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];
    regeo.requireExtension            = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
    
    _hasLocation = YES;
}

- (void)updateAppleMapViewWithUserLocation:(MAUserLocation *)userLocation {
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    
    [self.mapView setHidden:YES];
    [self.appleMapView setHidden:NO];
    [_mainTableView removeFromSuperview];
    _mainTableView = nil;
    [self.appleMapView setCenterCoordinate:userLocation.location.coordinate];
    if (_currentAdressInfo == nil) {
        _currentAdressInfo = [[MapAdressInfo alloc] init];
    }
    _currentAdressInfo.coordinate = userLocation.coordinate;
    
    //设置地图显示的范围
    MKCoordinateSpan span;
    //地图显示范围越小，细节越清楚；
    span.latitudeDelta = 0.08;
    span.longitudeDelta = 0.08;
    //创建MKCoordinateRegion对象，该对象代表地图的显示中心和显示范围
    MKCoordinateRegion region = {coords,span};
    //设置当前地图的显示中心和显示范围
    [self.appleMapView setRegion:region animated:YES];
    _hasLocation = YES;
    // 创建标注
    QIMAnnotation *annotation = [[QIMAnnotation alloc] initWithCoordinates:coords title:@"I am Here" subTitle:@""];
    [self.appleMapView addAnnotation:annotation];
    //自动显示标注的layout
    [self.appleMapView selectAnnotation:annotation animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    
}
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    QIMVerboseLog(@"%@",error.description);
}

-(void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (_isNotSend) {
        return;
    }
    if (_isSelected == NO) {
        if (_hasLocation && _isFirstRegion == NO) {
            _status = MapLocationStatusLocationing;
            [_dataSource removeAllObjects];
            [_mainTableView reloadData];
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(mapView.region.center.latitude, mapView.region.center.longitude);
            
            [self searchReGeocodeWithCoordinate:coordinate];
            
        }
        
        if (_hasLocation && _isFirstRegion) {
            _isFirstRegion = NO;
        }
    }else{
        _isSelected = NO;
    }
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (_isNotSend) {
        return;
    }
    if (_hasLocation && _isFirstRegion == NO) {
        _myAddressBtn.selected = NO;
    }
}

#pragma mark - Action Handle

- (void)showsSegmentAction:(UISegmentedControl *)sender
{
    self.mapView.showsUserLocation = !sender.selectedSegmentIndex;
}

- (void)modeAction:(UISegmentedControl *)sender
{
    self.mapView.userTrackingMode = sender.selectedSegmentIndex;
}

#pragma mark - NSKeyValueObservering

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"showsUserLocation"])
    {
        NSNumber *showsNum = [change objectForKey:NSKeyValueChangeNewKey];
        
        self.showSegment.selectedSegmentIndex = ![showsNum boolValue];
    }
}

#pragma mark - Initialization
- (void)setUpNavbar
{
    UIView * bottomBarBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mapView.width, 64)];
    if ([[QIMKit sharedInstance] getIsIpad]) {
        bottomBarBack.frame = CGRectMake(0, 0, [[UIScreen mainScreen] width], 64);
    }
    bottomBarBack.backgroundColor = [UIColor spectralColorBlueColor];
    [self.view addSubview:bottomBarBack];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(-22, 20, self.view.width / 3, 43);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [UIColor spectralColorBlueColor];
    [cancelBtn addTarget:self action:@selector(cancelBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarBack addSubview:cancelBtn];
    
    UIButton * sendBtn = nil;
    if (!_isNotSend) {
        sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendBtn.frame = CGRectMake(self.view.width - self.view.width / 3 + 22, 20, self.view.width / 3, 43);
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sendBtn.backgroundColor = [UIColor spectralColorBlueColor];
        [sendBtn addTarget:self action:@selector(sendBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [bottomBarBack addSubview:sendBtn];
        
        UIView * sepLine = [[UIView alloc] initWithFrame:CGRectMake(cancelBtn.right - 0.5, 0, 1, bottomBarBack.height)];
        sepLine.backgroundColor = [UIColor qtalkSplitLineColor];
        //        [bottomBarBack addSubview:sepLine];
        
    }
    if (_tipsLabel == nil) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(cancelBtn.right, cancelBtn.top, (sendBtn?sendBtn.left:(bottomBarBack.width - cancelBtn.right)) - cancelBtn.right, cancelBtn.height)];
        _tipsLabel.font = [UIFont boldSystemFontOfSize:17];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.textColor = [UIColor whiteColor];
        _tipsLabel.text = @"位置";
        [bottomBarBack addSubview:_tipsLabel];
    }
}


- (void)setUpTableView
{
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.mapView.bottom, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - self.mapView.bottom) style:UITableViewStylePlain];
    if ([[QIMKit sharedInstance] getIsIpad]) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.mapView.right, 64, [[UIScreen mainScreen] width] - self.mapView.right, [[UIScreen mainScreen] height]) style:UITableViewStylePlain];
    }
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    _mainTableView.backgroundColor = [UIColor qim_colorWithHex:0xf9f9f9 alpha:1.0];
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _mainTableView.separatorColor = [UIColor qtalkSplitLineColor];
    [self.view addSubview:_mainTableView];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    label.text = @"   没有更多数据了";
    [view addSubview:label];
    [_mainTableView setTableFooterView:view];
}



- (void)initToolBar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    self.showSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Start", @"Stop", nil]];
    self.showSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.showSegment addTarget:self action:@selector(showsSegmentAction:) forControlEvents:UIControlEventValueChanged];
    self.showSegment.selectedSegmentIndex = 0;
    UIBarButtonItem *showItem = [[UIBarButtonItem alloc] initWithCustomView:self.showSegment];
    
    self.modeSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"None", @"Follow", @"Head", nil]];
    self.modeSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.modeSegment addTarget:self action:@selector(modeAction:) forControlEvents:UIControlEventValueChanged];
    self.modeSegment.selectedSegmentIndex = 0;
    UIBarButtonItem *modeItem = [[UIBarButtonItem alloc] initWithCustomView:self.modeSegment];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexble, showItem, flexble, modeItem, flexble, nil];
}


- (void)returnAction
{
    [super returnAction];
    
    self.mapView.userTrackingMode  = MAUserTrackingModeNone;
    
}

#pragma mark - Life Cycle

-(instancetype)initWithAddress:(NSString *)address
{
    if (self = [self init]) {
        _isNotSend = YES;
        _address = address;
    }
    return self;
}

-(instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self = [self init]) {
        _isNotSend = YES;
        _coordinate = coordinate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    CLLocationManager
    //    MKMapItem
    //    MKMapView
    
    _dataSource = [NSMutableArray arrayWithCapacity:1];
    
    _isFirstRegion = YES;
    
    self.mapView.frame = CGRectMake(0, 64, CGRectGetWidth([UIScreen mainScreen].bounds), self.view.width * 3 / 4);
    if ([[QIMKit sharedInstance] getIsIpad]) {
        self.mapView.frame = CGRectMake(0, 64, [[UIScreen mainScreen] height] - 64, [[UIScreen mainScreen] height] - 64);
    }
    if (_isNotSend) {
        self.mapView.frame = CGRectMake(0, 64, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 64);
        if ([[QIMKit sharedInstance] getIsIpad]) {
            self.mapView.frame = CGRectMake(0, 64, [[UIScreen mainScreen] width], [[UIScreen mainScreen] height] - 64);
        }
    }
    
    if (_isNotSend) {
        
    }else{
        [self setUpTableView];
    }
    
    [self setUpNavbar];
    
    if (!_isNotSend) {
        
        _myAddressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_myAddressBtn setImage:[UIImage imageNamed:@"location_my"] forState:UIControlStateNormal];
        [_myAddressBtn setImage:[UIImage imageNamed:@"location_my_HL"] forState:UIControlStateHighlighted];
        [_myAddressBtn setImage:[UIImage imageNamed:@"location_my_current"] forState:UIControlStateSelected];
        [_myAddressBtn addTarget:self action:@selector(currentBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        _myAddressBtn.frame = CGRectMake(self.mapView.width - 70 , self.mapView.height - 70, 50, 50);
        if ([[QIMKit sharedInstance] getIsIpad]) {
            _myAddressBtn.frame = CGRectMake(self.mapView.left + 20, self.mapView.height - 70, 50, 50);
        }
        [self.mapView addSubview:_myAddressBtn];
        [self currentBtnHandle:nil];
    } else {
        
        _otherMapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherMapBtn setImage:[UIImage imageNamed:@"locationSharing_navigate_icon_new"] forState:UIControlStateNormal];
        [_otherMapBtn setImage:[UIImage imageNamed:@"locationSharing_navigate_icon_HL_new"] forState:UIControlStateHighlighted];
        [_otherMapBtn setImage:[UIImage imageNamed:@"locationSharing_navigate_icon_HL_new"] forState:UIControlStateSelected];
        [_otherMapBtn addTarget:self action:@selector(openWithOtherApplication:) forControlEvents:UIControlEventTouchUpInside];
        _otherMapBtn.frame = CGRectMake(self.mapView.width - 70 , self.mapView.height - 70, 50, 50);
        if ([[QIMKit sharedInstance] getIsIpad]) {
            _otherMapBtn.frame = CGRectMake(self.mapView.left + 20, self.mapView.height - 70, 50, 50);
        }
        [self.mapView addSubview:_otherMapBtn];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isNotSend) {
        self.mapView.showsUserLocation = NO;
        float zoomLevel = 0.01;
        MACoordinateRegion region = MACoordinateRegionMake([[UserLocationCoordinate2DTransform sharedInstanced] getGaodeFromBaiduForLocationCoordinate:_coordinate],MACoordinateSpanMake(zoomLevel, zoomLevel));
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        
        AMapPOI * poi = [[AMapPOI alloc] init];
        AMapGeoPoint * location = [[AMapGeoPoint alloc] init];
        location.latitude = [[UserLocationCoordinate2DTransform sharedInstanced] getGaodeFromBaiduForLocationCoordinate:_coordinate].latitude;
        location.longitude = [[UserLocationCoordinate2DTransform sharedInstanced] getGaodeFromBaiduForLocationCoordinate:_coordinate].longitude;
        poi.location = location;
        if (self.dispalyName) {
            poi.name = self.dispalyName;
            poi.address = self.dispalyAdr;
        }else{
            poi.name = self.dispalyAdr;
        }
        _userPOI = poi;
        if (AMapDataAvailableForCoordinate(_coordinate)) {
            [self reSelectAnnotationForPOI:poi];
            
            self.mapView.userTrackingMode = MAUserTrackingModeNone;
        } else {
            MAUserLocation *userLocation = [[MAUserLocation alloc] init];
            userLocation.coordinate = _coordinate;
            [self updateAppleMapViewWithUserLocation:userLocation];
        }

        //        [self searchReGeocodeWithCoordinate:[self getGaodeFromBaiduForLocationCoordinate:_coordinate]];
    }else{
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusDenied  || status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusNotDetermined) {
            
            CLAuthorizationStatus newStatus = [CLLocationManager authorizationStatus];
            if (newStatus == kCLAuthorizationStatusDenied  || newStatus == kCLAuthorizationStatusRestricted) {
                UIAlertController *locationNotifyAlertVc = [UIAlertController alertControllerWithTitle:nil message:[NSBundle qim_localizedStringForKey:@"QTalk Privacy Location Message"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                [locationNotifyAlertVc addAction:okAction];
                if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
                    locationNotifyAlertVc.message = [NSBundle qim_localizedStringForKey:@"QChat Privacy Location Message"];
                }
                [self presentViewController:locationNotifyAlertVc animated:YES completion:nil];
            }
        }
        _tipsLabel.text = @"正在定位，请稍等...";
        self.mapView.showsUserLocation = YES;
        
        self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    }
    
    //    [_mapView setZoomLevel:16.1 animated:YES];
    //    [self.mapView setUserTrackingMode:MAUserTrackingModeFollowWithHeading animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapView.showsUserLocation = NO;
    _hasLocation = NO;
    _isFirstRegion = YES;
    self.delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = @"cell";
    QIMLocationCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[QIMLocationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.numberOfLines = 0;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setCellSelect:indexPath.row == _selectIndex];
    AMapPOI * poi = _dataSource[indexPath.row];
    cell.textLabel.text = poi.name;
    if (poi.address) {
        if (!_isNotSend) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%@%@",_addressSearchResult.province,_addressSearchResult.city?_addressSearchResult.city:@"",_addressSearchResult.district,poi.address];
        }else{
            cell.detailTextLabel.text = poi.address;
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != _selectIndex) {
        _isSelected = YES;
        _selectIndex = indexPath.row;
        AMapPOI * poi = _dataSource[_selectIndex];
        if (poi.location.latitude == _currentAdressInfo.coordinate.latitude && poi.location.longitude == _currentAdressInfo.coordinate.longitude) {
            _myAddressBtn.selected = YES;
            
            _tipsLabel.text = @"我的位置";
        }else{
            _tipsLabel.text = @"位置";
            _myAddressBtn.selected = NO;
        }
        _userPOI = poi;
        [self reSelectAnnotationForPOI:poi];
        [_mainTableView reloadData];
    }
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (scrollView.contentOffset.y < -5 && _isMapSmall == YES) {
//        _isMapSmall = NO;
//        [UIView animateWithDuration:0.5 animations:^{
//            self.mapView.frame = CGRectMake(0, 20, CGRectGetWidth([UIScreen mainScreen].bounds), 500);
//            _mainTableView.frame = CGRectMake(0, self.mapView.bottom, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - self.mapView.bottom);
//        }];
//    }else if (scrollView.contentOffset.y > 5 && _isMapSmall == NO){
//        _isMapSmall = YES;
//        [UIView animateWithDuration:0.5 animations:^{
//            self.mapView.frame = CGRectMake(0, 20, CGRectGetWidth([UIScreen mainScreen].bounds), 300);
//            _mainTableView.frame = CGRectMake(0, self.mapView.bottom, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - self.mapView.bottom);
//        }];
//    }
//}

#pragma mark - action

-(void)currentBtnHandle:(id)sender{
    _selectIndex = 0;
    if (_dataSource.count) {
        [self.mapView setCenterCoordinate:_currentAdressInfo.coordinate animated:YES];
        //        _isSelected = YES;
        //        [self searchReGeocodeWithCoordinate:_currentAdressInfo.coordinate];
    }
    //    [_mainTableView reloadData];
    [self reGeocodeAction];
}

- (void)cancelBtnHandle:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)openWithOtherApplication:(UIButton *)sender {
//    "baiduMap" = "Navigate by Baidu Maps";
//    "tencentMap" = "Navigate by Tencent Maps";
//    "iosamap" = "Navigate by AutoNavi Maps";
//    "appleMap" = "Navigate by Apple Maps";
    UIAlertController *otherMapSheetVc = [UIAlertController alertControllerWithTitle:nil message:@"尝试使用其他Map应用打开" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *tencentMap = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"tencentMap"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
            NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=终点&coord_type=1&policy=0",_coordinate.latitude, _coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if ([[[UIDevice currentDevice] systemName] floatValue] > 10.0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                    QIMVerboseLog(@"scheme调用结束");
                }];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            }
        }
    }];
    UIAlertAction *badiuMap = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"baiduMap"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
            CLLocationCoordinate2D baiduCoordinate = [[UserLocationCoordinate2DTransform sharedInstanced] getBaiduFromGaodeForLocationCoordinate:_coordinate];
            NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",baiduCoordinate.latitude, baiduCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if ([[[UIDevice currentDevice] systemName] floatValue] > 10.0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                    QIMVerboseLog(@"scheme调用结束");
                }];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            }
        }
    }];
    UIAlertAction *gaodeMap = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"iosamap"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
            NSString *urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dev=0&t=0", @"QTalk", _coordinate.latitude, _coordinate.longitude];
            if ([[[UIDevice currentDevice] systemName] floatValue] > 10.0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                    QIMVerboseLog(@"scheme调用结束");
                }];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            }
        }
    }];
    UIAlertAction *AppleMap = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"appleMap"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(_coordinate.latitude, _coordinate.longitude);
        //当前位置
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        //目的地位置
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:loc addressDictionary:nil]];
        toLocation.name = _userPOI.name;
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                       MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard],
                                       MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        QIMVerboseLog(@"Cancel");
    }];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        [otherMapSheetVc addAction:tencentMap];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        [otherMapSheetVc addAction:badiuMap];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        [otherMapSheetVc addAction:gaodeMap];
    }
    [otherMapSheetVc addAction:AppleMap];
    [otherMapSheetVc addAction:cancelAction];
    [self presentViewController:otherMapSheetVc animated:YES completion:nil];
}

- (void)sendBtnHandle:(UIButton *)sender
{
    
    if (_status == MapLocationStatusLocationing) {
        [self showAlertViewWithTitle:@"定位中..." message:@"正在定位中，是否要放弃并返回？"];
    }else if (_status == MapLocationStatusFailed) {
        [self showAlertViewWithTitle:@"定位失败！" message:@"定位失败，是否确定返回？"];
    }else if (_status == MapLocationStatusDone) {
        AMapPOI * poi = [_dataSource objectAtIndex:_selectIndex];
        if (self.delegate && [self.delegate respondsToSelector:@selector(UserLocationViewController:shouldSendAdressInfo:)]) {
            MapAdressInfo * mapAdrInfo = [[MapAdressInfo alloc] init];
            mapAdrInfo.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
            NSString * address = nil;
            if (poi.address) {
                address = [NSString stringWithFormat:@"%@%@%@%@",_addressSearchResult.province,_addressSearchResult.city?_addressSearchResult.city:@"",_addressSearchResult.district,poi.address];
            }else{
                address = poi.name;
            }
            mapAdrInfo.adress = address;
            [self.delegate UserLocationViewController:self shouldSendAdressInfo:mapAdrInfo];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendMessage:WithInfo:ForMsgType:)]) {
            _tipsLabel.text = @"正在获取位置图片...";
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                CGRect inRect = self.mapView.bounds;
            UIImage *screenshotImage = nil;
            if (!_isAbroadLocation) {
                screenshotImage = [self.mapView takeSnapshotInRect:inRect];
                [[QIMKit sharedInstance] setUserObject:UIImagePNGRepresentation(screenshotImage) forKey:@"userLocationScreenshotImage"];
            } else {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.appleMapView.width, self.appleMapView.height / 2.0f)];
                view.center = self.appleMapView.center;
                UIImage *image = [UserLocationViewController imageWithUIView:self.appleMapView];
//                screenshotImage = [image getSubImage:view.frame];
                screenshotImage = image;
                [[QIMKit sharedInstance] setUserObject:UIImagePNGRepresentation(screenshotImage) forKey:@"userLocationScreenshotImage"];
            }
                dispatch_async(dispatch_get_main_queue(), ^{
                    _tipsLabel.text = @"已发送";
                    NSString * address = nil;
                    if (poi.address) {
                        address = [NSString stringWithFormat:@"%@%@%@%@",_addressSearchResult.province,_addressSearchResult.city?_addressSearchResult.city:@"",_addressSearchResult.district,poi.address];
                    }else{
                        address = poi.name;
                    }
                    
                    CLLocationCoordinate2D bdCoordinate = [[UserLocationCoordinate2DTransform sharedInstanced] getBaiduFromGaodeForLocationCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude)];
                    NSString *message = [NSString stringWithFormat:@"我在这里，点击查看: [obj type=\"url\" value=\"%@\"] (%@)", [NSString stringWithFormat:@"http://api.map.baidu.com/marker?location=%lf,%lf&title=我的位置&content=%@&output=html",bdCoordinate.latitude,bdCoordinate.longitude,address],address];
                    NSString *info = [NSString stringWithFormat:@"{\"name\":\"%@\",\"adress\":\"%@\",\"latitude\":\"%lf\",\"longitude\":\"%lf\"}",poi.name,address,bdCoordinate.latitude,bdCoordinate.longitude];
                    
                    [self.delegate sendMessage:message WithInfo:info ForMsgType:QIMMessageType_LocalShare];
//                    [self.delegate sendMessage:[NSString stringWithFormat:@"我在这里，点击查看：[obj type=\"url\" value=\"%@\"] (%@)",[NSString stringWithFormat:@"http://api.map.baidu.com/marker?location=%lf,%lf&title=我的位置&content=%@&output=html",bdCoordinate.latitude,bdCoordinate.longitude,address],address] WithInfo:[NSString stringWithFormat:@"{\"name\":\"%@\",\"adress\":\"%@\",\"latitude\":\"%lf\",\"longitude\":\"%lf\"}",poi.name,address,bdCoordinate.latitude,bdCoordinate.longitude] ForMsgType:QIMMessageType_LocalShare];
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
//            });
            
        }
    }
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"cancel"] style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:cancelAction];
    [alertVc addAction:okAction];
    [self presentViewController:alertVc animated:YES completion:nil];
}

#pragma mark - AMapSearchDelegate

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
}


#pragma mark - AMapSearchDelegate

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    _tipsLabel.text = @"位置";
    
    _addressSearchResult = response.regeocode.addressComponent;
    
    _status = MapLocationStatusDone;
    [_dataSource removeAllObjects];
    [_dataSource addObjectsFromArray:response.regeocode.pois];
    
    AMapPOI * poi = [[AMapPOI alloc] init];
    poi.location = request.location;
    if (_isNotSend) {
        if (self.dispalyName) {
            poi.name = self.dispalyName;
            poi.address = self.dispalyAdr;
        }else{
            poi.name = self.dispalyAdr;
        }
    }else{
        poi.name = response.regeocode.formattedAddress;
    }
    [_dataSource insertObject:poi atIndex:0];
    
    [self reSelectAnnotationForPOI:_dataSource.firstObject];
    _selectIndex = 0;
    AMapPOI * poiC = _dataSource[_selectIndex];
    if (poiC.location.latitude == _currentAdressInfo.coordinate.latitude && poiC.location.longitude == _currentAdressInfo.coordinate.longitude) {
        _myAddressBtn.selected = YES;
        
        _tipsLabel.text = @"我的位置";
    }else{
        _tipsLabel.text = @"位置";
        _myAddressBtn.selected = NO;
    }
    
    
    [_mainTableView reloadData];
}


- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location                    = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.radius = 2500;
    regeo.requireExtension            = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (!annotationView)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.highlighted = YES;
        //        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorRed;
        annotationView.animatesDrop = YES;
        return annotationView;
    }
    return nil;
}


- (void)reSelectAnnotationForPOI:(AMapPOI *)poi{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
    
    self.pointAnnotation.coordinate = coordinate;
    self.pointAnnotation.title = [poi name];
    if (poi.address) {
        if (_isNotSend) {
            self.pointAnnotation.subtitle = poi.address;
        }else{
            self.pointAnnotation.subtitle = [NSString stringWithFormat:@"%@%@%@%@",_addressSearchResult.province,_addressSearchResult.city?_addressSearchResult.city:@"",_addressSearchResult.district,[poi address]];// response.regeocode.formattedAddress;
        }
    }
    [self.mapView addAnnotation:self.pointAnnotation];
    [self.mapView selectAnnotation:self.pointAnnotation animated:YES];
}

/**
 高德地图转苹果地图
 */
- (MKCoordinateRegion)MKRegionForMARegion:(MACoordinateRegion)maRegion {
    MKCoordinateRegion mkRegion = MKCoordinateRegionMake(maRegion.center, MKCoordinateSpanMake(maRegion.span.latitudeDelta, maRegion.span.longitudeDelta));
    
    return mkRegion;
}

/**
 苹果地图转高德地图
 */
- (MACoordinateRegion)MARegionForMKRegion:(MKCoordinateRegion)mkRegion {
    MACoordinateRegion maRegion = MACoordinateRegionMake(mkRegion.center, MACoordinateSpanMake(mkRegion.span.latitudeDelta, mkRegion.span.longitudeDelta));
    
    if(maRegion.center.latitude + maRegion.span.latitudeDelta / 2 > 90) {
        maRegion.span.latitudeDelta = (90.0 - maRegion.center.latitude) / 2;
    }
    if(maRegion.center.longitude + maRegion.span.longitudeDelta / 2 > 180) {
        maRegion.span.longitudeDelta = (180.0 - maRegion.center.longitude) / 2;
    }
    
    return maRegion;
}

+ (UIImage *)imageWithUIView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
