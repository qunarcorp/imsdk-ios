//
//  ShareLocationViewController.m
//  qunarChatIphone
//
//  Created by chenjie on 16/1/28.
//
//
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "QIMJSONSerializer.h"
#import "ShareLocationViewController.h"
#import "ShareLocationUserImageView.h"
#import "QIMUUIDTools.h"
#import "FindDirectionsView.h"
#import "MBProgressHUD.h"
#import "NSBundle+QIMLibrary.h"

#define kUserHeaderBGViewTagFrom            1000

@interface MyAnnotation : NSObject <MKAnnotation>
//显示标注的经纬度
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
//标注的标题
@property (nonatomic,copy,readonly) NSString * title;
//标注的子标题
@property (nonatomic,copy,readonly) NSString * subtitle;

@property (nonatomic,copy)NSString  * identifier;

@property (nonatomic,assign) double     headingDirection;

@property (nonatomic,copy) NSString     * userId;

-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle
                subTitle:(NSString *)paramTitle;

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end

@implementation MyAnnotation
-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle
                subTitle:(NSString *)paramSubitle
{
    self = [super init];
    if(self != nil)
    {
        _coordinate = paramCoordinates;
        _title = paramTitle;
        _subtitle = paramSubitle;
    }
    return self;
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    _coordinate = newCoordinate;
}

@end

@interface ShareLocationViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>
{
    MKMapView               * _mapView;
    CLLocationManager       * _lctnManager;
    MKPolyline              * _polyline;
    MKPolylineView          * _polylineView;
    CLHeading               * _currentHeading;
    
    NSMutableDictionary     * _annotationsDic;
    NSMutableDictionary     * _antViewsDic;
    
    UIScrollView            * _userListView;
    UILabel                 * _userCountLabel;
    
    CLLocation              * _bestEffortAtLocation;
    
    MBProgressHUD          * _progressHUD;
    
    BOOL                      _sysIdleTimerDisabled;
    
    UIButton                * _myLctBtn;
    UIButton                * _findDirection;
    
    FindDirectionsView      * _findDirectionsView;
}

@end

@implementation ShareLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShareLocationMsg:) name:kBeginShareLocation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinShareLocationMsg:) name:kJoinShareLocation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateShareLocationMsg:) name:kShareLocationInfo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitShareLocationMsg:) name:kQuitShareLocation object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endShareLocationMsg:) name:kEndShareLocation object:nil];
    
    [self initMapView];
    [self initNavBar];
    [self initMyLocationBtn];
//    [self initFindDirectionBtn];
    [self initLocationManager];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)goBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _sysIdleTimerDisabled = [[UIApplication sharedApplication] isIdleTimerDisabled];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        UIAlertController *locationNotifyAlertVc = [UIAlertController alertControllerWithTitle:nil message:[NSBundle qim_localizedStringForKey:@"QTalk Privacy Location Message"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle qim_localizedStringForKey:@"ok"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [locationNotifyAlertVc addAction:okAction];
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
            locationNotifyAlertVc.message = [NSBundle qim_localizedStringForKey:@"QChat Privacy Location Message"];
        }
        [self presentViewController:locationNotifyAlertVc animated:YES completion:nil];
    } else {
        if (self.shareLocationId) {
            NSArray * userList = [[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:self.shareLocationId];
            
            [[QIMKit sharedInstance] joinShareLocationToUsers:userList WithShareLocationId:self.shareLocationId];
        }else{
            self.shareLocationId = [QIMUUIDTools UUID];
            if ([self.userId rangeOfString:@"@conference."].location != NSNotFound) {
                [[QIMKit sharedInstance] beginShareLocationToGroupId:self.userId WithShareLocationId:self.shareLocationId];
            }else{
                Message * msg = [[QIMKit sharedInstance] beginShareLocationToUserId:self.userId WithShareLocationId:self.shareLocationId];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate
                                                                    object:self.userId
                                                                  userInfo:@{@"message":msg}];
            }
        }
    }
    if ([CLLocationManager locationServicesEnabled]) {
        if (!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
            [_lctnManager requestWhenInUseAuthorization];
        }  else{
//            [_lctnManager startUpdatingLocation];
            [_lctnManager startUpdatingHeading];
            _mapView.showsUserLocation = YES;
            [[self progressHUDWithText:@"正在定位，请稍后..."] show:YES];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:_sysIdleTimerDisabled];
    
    _mapView.showsUserLocation = NO;
    [_lctnManager stopUpdatingHeading];
//    [_lctnManager stopUpdatingLocation];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startUpdateUserLocation) object:nil];
}

#pragma mark - actions

- (MBProgressHUD *)progressHUDWithText:(NSString *)text {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        [_progressHUD setLabelText:@""];
        [self.view addSubview:_progressHUD];
    }
    [_progressHUD setDetailsLabelText:text];
    return _progressHUD;
}

- (void)closeHUD{
    if (_progressHUD) {
        [_progressHUD hide:YES];
    }
}

- (void)startUpdateUserLocation{
//    [_lctnManager startUpdatingLocation];
    _mapView.showsUserLocation = YES;
}

- (void)stopUpdateUserLocation{
//    [_lctnManager stopUpdatingLocation];
    _mapView.showsUserLocation = NO;
}


- (void)closeBtnHandle:(id)sender{
    NSArray * userList = [[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:self.shareLocationId];
    if (userList.count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kEndShareLocation object:self.shareLocationId];
    }
    [[QIMKit sharedInstance] quitShareLocationToUsers:[[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:self.shareLocationId] WithShareLocationId:self.shareLocationId];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)smallBtnHandle:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)myLctBtnHandle:(id)sender{
    [self selectAnnotationForUserId:[[QIMKit sharedInstance] getLastJid]];
}

- (void)findDirectionBtnHandle:(id)sender{
    if (_findDirectionsView == nil) {
        _findDirectionsView = [[FindDirectionsView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_findDirectionsView];
    }else{
        [self.view bringSubviewToFront:_findDirectionsView];
    }
    _findDirectionsView.hidden = NO;
}

- (void)selectAnnotationForUserId:(NSString *)userId{
    MyAnnotation * annotation = [_annotationsDic objectForKey:userId];
    if (annotation) {
        [_mapView setCenterCoordinate:annotation.coordinate animated:YES];
    }
}

- (void)tapGesHandle:(UITapGestureRecognizer *)tap{
    NSInteger index = tap.view.tag - kUserHeaderBGViewTagFrom;
    if (index < _annotationsDic.allKeys.count) {
        NSString * userId = [_annotationsDic.allKeys objectAtIndex:index];
        [self selectAnnotationForUserId:userId];
    }
}

#pragma mark - initUI

- (void)initNavBar{
    self.navigationController.navigationBarHidden = YES;
    UIView * navBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 110)];
    navBgView.backgroundColor = [UIColor qim_colorWithHex:0x000000 alpha:0.5];
    [self.view addSubview:navBgView];
    
    UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"locationSharing_icon_close"] forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"locationSharing_icon_close_HL"] forState:UIControlStateHighlighted];
    closeBtn.frame = CGRectMake(15, 30, 32, 32);
    [closeBtn addTarget:self action:@selector(closeBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [navBgView addSubview:closeBtn];
    
    UIButton * smallBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [smallBtn setImage:[UIImage imageNamed:@"locationSharing_icon_back"] forState:UIControlStateNormal];
    [smallBtn setImage:[UIImage imageNamed:@"locationSharing_icon_back_HL"] forState:UIControlStateHighlighted];
    smallBtn.frame = CGRectMake(navBgView.width - 32 - 15, 30, 32, 32);
    [smallBtn addTarget:self action:@selector(smallBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [navBgView addSubview:smallBtn];
    
    _userListView = [[UIScrollView alloc] initWithFrame:CGRectMake(closeBtn.right + 10, 30, smallBtn.left - closeBtn.right - 20, 50)];
    [navBgView addSubview:_userListView];
    
    _userCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, navBgView.height - 25, navBgView.width, 20)];
    _userCountLabel.textAlignment = NSTextAlignmentCenter;
    _userCountLabel.textColor = [UIColor whiteColor];
    [navBgView addSubview:_userCountLabel];
    
}

- (void)initMyLocationBtn{
    if (_myLctBtn == nil) {
        _myLctBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_myLctBtn setImage:[UIImage imageNamed:@"locationSharing_mylocation"] forState:UIControlStateNormal];
        [_myLctBtn setImage:[UIImage imageNamed:@"locationSharing_mylocation_HL"] forState:UIControlStateHighlighted];
        _myLctBtn.frame = CGRectMake(20, self.view.height - 20 - 40, 40, 40);
        [_myLctBtn addTarget:self action:@selector(myLctBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_myLctBtn];
    }
}

- (void)initFindDirectionBtn{
    if (_findDirection == nil) {
        _findDirection = [UIButton buttonWithType:UIButtonTypeCustom];
        [_findDirection setImage:[UIImage imageNamed:@"locationSharing_mylocation"] forState:UIControlStateNormal];
        [_findDirection setImage:[UIImage imageNamed:@"locationSharing_mylocation_HL"] forState:UIControlStateHighlighted];
        _findDirection.frame = CGRectMake(20, self.view.height - 20 - 40 - 20 - 40, 40, 40);
        [_findDirection addTarget:self action:@selector(findDirectionBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_findDirection];
    }
}

- (void)initMapView{
    if (_mapView == nil) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        _mapView.showsCompass = YES;
        _mapView.showsScale = YES;
        [_mapView setLayoutMargins:UIEdgeInsetsMake(90, 0, 0, 0)];
        [self.view addSubview:_mapView];
    }
}

- (void)initLocationManager{
    if (_lctnManager == nil) {
        _lctnManager = [[CLLocationManager alloc] init];
        _lctnManager.delegate = self;
        _lctnManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
}


- (void)refreshUserList{
    [_userListView removeAllSubviews];
    for (NSString * userId in _annotationsDic.allKeys) {
        NSInteger index = [_annotationsDic.allKeys indexOfObject:userId];
        UIImageView * userBgView = [[UIImageView alloc] initWithFrame:CGRectMake((10 + 50) * index + 10, 0, 50, 50)];
        userBgView.image = [UIImage imageNamed:@"locationSharing_avatar_bg"];
        [_userListView addSubview:userBgView];
        
        userBgView.userInteractionEnabled = YES;
        userBgView.tag = kUserHeaderBGViewTagFrom + index;
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesHandle:)];
        [userBgView addGestureRecognizer:tapGes];
        
        UIImageView * userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 5, 38, 38)];
//        userImageView.image = [[QIMKit sharedInstance] getUserHeaderImageByUserId:userId];
        [userImageView qim_setImageWithJid:userId];
        userImageView.layer.cornerRadius = userImageView.height / 2;
        userImageView.clipsToBounds = YES;
        [userBgView addSubview:userImageView];
    }
    _userListView.frame = CGRectMake(0, 0, MIN((10 + 50) * _annotationsDic.allKeys.count + 10, self.view.width - 104), 50);
    _userListView.center = CGPointMake(self.view.width / 2, 110 / 2);
    _userListView.contentSize = CGSizeMake((10 + 50) * _annotationsDic.allKeys.count + 10, 50);
    _userCountLabel.text = [NSString stringWithFormat:@"%@人在共享位置",@(_annotationsDic.allKeys.count)];
}

#pragma mark - MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *antView = nil;
    if (_antViewsDic == nil) {
        _antViewsDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    antView = [_antViewsDic objectForKey:[(MyAnnotation *)annotation identifier]];
    if (antView == nil) {
        antView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[(MyAnnotation *)annotation identifier]];
        ShareLocationUserImageView * shareImgView = [[ShareLocationUserImageView alloc] initWithUserId:[(MyAnnotation *)annotation userId]];
        shareImgView.tag = 9999;
        [antView addSubview:shareImgView];
        [_antViewsDic setQIMSafeObject:antView forKey:[(MyAnnotation *)annotation identifier]];
    }
    ShareLocationUserImageView * shareView = [antView viewWithTag:9999];
    [shareView updateDirectionTo:[(MyAnnotation *)annotation headingDirection]];
//    pinView.pinColor = MKPinAnnotationColorRed;
//    pinView.canShowCallout = YES;
//    pinView.animatesDrop = YES;
    
    return antView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay
{
    MKOverlayView* overlayView = nil;
    if(overlay == _polyline){
        //if we have not yet created an overlay view for this overlay, create it now.
        if(nil == _polylineView){
            _polylineView = [[MKPolylineView alloc] initWithPolyline:_polyline];
            _polylineView.fillColor = [UIColor qunarBlueColor];
            _polylineView.strokeColor = [UIColor qunarBlueColor];
            _polylineView.lineWidth = 10;
        }
        overlayView = _polylineView;
    }
    return overlayView;
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    [[self progressHUDWithText:@"正在定位，请稍后..."] hide:YES];
    [self stopUpdateUserLocation];
    [self performSelector:@selector(startUpdateUserLocation) withObject:nil afterDelay:5];
    CLLocationCoordinate2D coord = userLocation.location.coordinate;
    BOOL needShowAnts = NO;
    if (![_annotationsDic.allKeys containsObject:[[QIMKit sharedInstance] getLastJid]]) {
        if (_annotationsDic.allKeys.count == 0) {
            //        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((srcLocation.coordinate.latitude + desLocation.coordinate.latitude) / 2, (srcLocation.coordinate.longitude + desLocation.coordinate.longitude) / 2);
            CLLocationDistance distance = 500;//[desLocation distanceFromLocation:srcLocation];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, distance, distance);
            [_mapView setRegion:region animated:YES];
        }else{
            needShowAnts = YES;
            
        }
    }
    if (_annotationsDic == nil) {
        _annotationsDic = [NSMutableDictionary dictionaryWithCapacity:1];
    }
   CLLocationDirection mapAngle = -_mapView.camera.heading;
    MyAnnotation * annotation = [_annotationsDic objectForKey:[[QIMKit sharedInstance] getLastJid]];
    if (annotation == nil) {
        MyAnnotation * annotation = [[MyAnnotation alloc] initWithCoordinates:coord title:@"当前位置" subTitle:@"我的子标题"];
        annotation.identifier = [[QIMKit sharedInstance] getLastJid];
        annotation.userId = [[QIMKit sharedInstance] getLastJid];
        annotation.headingDirection = mapAngle + _mapView.userLocation.heading.trueHeading;
        [_annotationsDic setQIMSafeObject:annotation forKey:[[QIMKit sharedInstance] getLastJid]];
        [self refreshUserList];
        [_mapView addAnnotation:annotation];
    }else{
        [annotation setCoordinate:coord];
        [_annotationsDic setQIMSafeObject:annotation forKey:[[QIMKit sharedInstance] getLastJid]];
        MKAnnotationView *antView = [_antViewsDic objectForKey:[(MyAnnotation *)annotation identifier]];
        if (antView) {
            ShareLocationUserImageView * shareView = [antView viewWithTag:9999];
            [shareView updateDirectionTo:[(MyAnnotation *)annotation headingDirection]];
        }
    }
    
    if (needShowAnts) {
        [_mapView showAnnotations:_annotationsDic.allValues animated:YES];
    }
    coord = [self getBaiduFromGaodeForLocationCoordinate:coord];
    [self sendShareLocationMsgWithLatitude:coord.latitude longitude:coord.longitude headingDirection:_currentHeading.trueHeading];
}

-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    [[self progressHUDWithText:@"定位失败..."] show:YES];
    [self performSelector:@selector(closeHUD) withObject:nil afterDelay:0.5];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    //得到newLocation
    CLLocation * srcLocation = locations.firstObject;
        [self stopUpdateUserLocation];
        [self performSelector:@selector(startUpdateUserLocation) withObject:nil afterDelay:5];
        CLLocationCoordinate2D coord = srcLocation.coordinate;

        if (_annotationsDic.allKeys.count == 0 || ![_annotationsDic.allKeys containsObject:[[QIMKit sharedInstance] getLastJid]]) {
            //        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((srcLocation.coordinate.latitude + desLocation.coordinate.latitude) / 2, (srcLocation.coordinate.longitude + desLocation.coordinate.longitude) / 2);
            CLLocationDistance distance = 1000;//[desLocation distanceFromLocation:srcLocation];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, distance, distance);
            [_mapView setRegion:region animated:YES];
            [_mapView showAnnotations:_annotationsDic.allValues animated:YES];
        }
        if (_annotationsDic == nil) {
            _annotationsDic = [NSMutableDictionary dictionaryWithCapacity:1];
        }
       CLLocationDirection mapAngle = -_mapView.camera.heading;
        MyAnnotation * annotation = [_annotationsDic objectForKey:[[QIMKit sharedInstance] getLastJid]];
        if (annotation == nil) {
            MyAnnotation * annotation = [[MyAnnotation alloc] initWithCoordinates:coord title:@"当前位置" subTitle:@"我的子标题"];
            annotation.identifier = [[QIMKit sharedInstance] getLastJid];
            annotation.userId = [[QIMKit sharedInstance] getLastJid];
            annotation.headingDirection = mapAngle + _mapView.userLocation.heading.trueHeading;
            [_annotationsDic setQIMSafeObject:annotation forKey:[[QIMKit sharedInstance] getLastJid]];
            [self refreshUserList];
            [_mapView addAnnotation:annotation];
        }else{
            [annotation setCoordinate:coord];
            [_annotationsDic setQIMSafeObject:annotation forKey:[[QIMKit sharedInstance] getLastJid]];
            MKAnnotationView *antView = [_antViewsDic objectForKey:[(MyAnnotation *)annotation identifier]];
            if (antView) {
                ShareLocationUserImageView * shareView = [antView viewWithTag:9999];
                [shareView updateDirectionTo:[(MyAnnotation *)annotation headingDirection]];
            }
        }
        coord = [self getBaiduFromGaodeForLocationCoordinate:coord];
        [self sendShareLocationMsgWithLatitude:coord.latitude longitude:coord.longitude headingDirection:_currentHeading.trueHeading];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    _currentHeading = newHeading;
    
    CLLocationDirection mapAngle = -_mapView.camera.heading;
    MKAnnotationView * antView = [_antViewsDic objectForKey:[[QIMKit sharedInstance] getLastJid]];
    if (antView) {
        ShareLocationUserImageView * shareView = [antView viewWithTag:9999];
        [shareView updateDirectionTo: mapAngle +  _currentHeading.trueHeading];
    }
    
    MyAnnotation * ant = [_annotationsDic objectForKey:[[QIMKit sharedInstance] getLastJid]];
    if (ant) {
        ant.headingDirection = mapAngle + _currentHeading.trueHeading;
        [_annotationsDic setQIMSafeObject:ant forKey:[[QIMKit sharedInstance] getLastJid]];
    }
    
}


#pragma mark -  find directions

- (void)findDirectionsFrom:(MyAnnotation *)source
                        to:(MyAnnotation *)destination
             transportType:(MKDirectionsTransportType)transportType
{
    MyAnnotation * annotation2 = [[MyAnnotation alloc] initWithCoordinates:destination.coordinate title:@"目的位置" subTitle:@"目的地子标题"];
    
    [_mapView addAnnotation:annotation2];
    
    MKPlacemark * sourcePlaceMark = [[MKPlacemark alloc] initWithCoordinate:source.coordinate addressDictionary:nil];
    MKPlacemark * desPlaceMark = [[MKPlacemark alloc] initWithCoordinate:destination.coordinate addressDictionary:nil];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [[MKMapItem alloc] initWithPlacemark:sourcePlaceMark];
    request.destination = [[MKMapItem alloc] initWithPlacemark:desPlaceMark];
    request.transportType = transportType;
    MKDirections *dirc = [[MKDirections alloc] initWithRequest:request];
    
    [dirc calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        _polyline = [response routes].firstObject.polyline;
        [_mapView removeOverlays:_mapView.overlays];
        if (_polyline) {
            [_mapView addOverlay:_polyline];
        }
    }];
}


#pragma mark - send Msg

- (void)sendShareLocationMsgWithLatitude:(double)latitude longitude:(double)longitude headingDirection:(double)direction{
    NSDictionary * infoDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",@(latitude)],@"latitude",[NSString stringWithFormat:@"%@",@(longitude)],@"longitude",[NSString stringWithFormat:@"%@",@(direction)],@"direction", nil];
    [[QIMKit sharedInstance] sendMyLocationToUsers:[[QIMKit sharedInstance] getShareLocationUsersByShareLocationId:self.shareLocationId] WithLocationInfo:[[QIMJSONSerializer sharedInstance] serializeObject:infoDic] ByShareLocationId:self.shareLocationId];
}

#pragma mark - notifacation action
- (void)joinShareLocationMsg:(NSNotification *)noti{
    // xxx加入了
}

- (void)quitShareLocationMsg:(NSNotification *)noti{
    if (noti.object) {
        MyAnnotation * annotation = [_annotationsDic objectForKey:noti.object];
        if (annotation) {
            [_mapView removeAnnotation:annotation];
            [_annotationsDic removeObjectForKey:noti.object];
            MKAnnotationView *antView = [_antViewsDic objectForKey:[(MyAnnotation *)annotation identifier]];
            if (antView) {
                [antView removeFromSuperview];
            }
        }
        [self refreshUserList];
        [_mapView showAnnotations:_annotationsDic.allValues animated:YES];
    }
}

- (void)updateShareLocationMsg:(NSNotification *)noti{
    Message * msg = [noti.userInfo objectForKey:@"message"];
    if ([msg.to isEqualToString:[[QIMKit sharedInstance] getLastJid]]) {
        CLLocationDirection mapAngle = -_mapView.camera.heading;
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:msg.message error:nil];
        if (_annotationsDic == nil) {
            _annotationsDic = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        MyAnnotation * annotation = [_annotationsDic objectForKey:msg.from];
        if (annotation == nil) {
            MyAnnotation * annotation = [[MyAnnotation alloc] initWithCoordinates:[self getGaodeFromBaiduForLocationCoordinate:CLLocationCoordinate2DMake([[infoDic objectForKey:@"latitude"] doubleValue], [[infoDic objectForKey:@"longitude"] doubleValue])] title:@"当前位置" subTitle:@"我的子标题"];
            annotation.identifier = msg.from;
            annotation.userId = msg.from;
            annotation.headingDirection = mapAngle + [[infoDic objectForKey:@"direction"] doubleValue];
            [_annotationsDic setQIMSafeObject:annotation forKey:msg.from];
            [self refreshUserList];
            [_mapView addAnnotation:annotation];
            [_mapView showAnnotations:_annotationsDic.allValues animated:YES];
        }else{
            [annotation setCoordinate:[self getGaodeFromBaiduForLocationCoordinate:CLLocationCoordinate2DMake([[infoDic objectForKey:@"latitude"] doubleValue], [[infoDic objectForKey:@"longitude"] doubleValue])]];
            annotation.headingDirection = mapAngle + [[infoDic objectForKey:@"direction"] doubleValue];
            [_mapView addAnnotation:annotation];
            [_annotationsDic setQIMSafeObject:annotation forKey:msg.from];
            
            MKAnnotationView *antView = [_antViewsDic objectForKey:[(MyAnnotation *)annotation identifier]];
            if (antView) {
                ShareLocationUserImageView * shareView = [antView viewWithTag:9999];
                [shareView updateDirectionTo:[(MyAnnotation *)annotation headingDirection]];
            }
        }
    }
}


#pragma mark - 百度 高德坐标系转换
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

-(BOOL)shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationPortrait == toInterfaceOrientation;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
@end
