//
//  QTImagePickerController.m
//  qunarChatIphone
//
//  Created by admin on 15/8/18.
//
//

#import "QTImagePickerController.h"

#import "QTImageAlbumViewController.h"

#define kPopoverContentSize CGSizeMake(320, 480)

@interface QTImagePickerController ()

@end

@implementation QTImagePickerController
@dynamic delegate;
- (instancetype)init{
    
    QTImageAlbumViewController *vc = [[QTImageAlbumViewController alloc] init];
    self = [super initWithRootViewController:vc];
    if (self) { 
        
        [self.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationBar setTintColor:[UIColor whiteColor]];
        [self.navigationBar setBackgroundImage:[UIImage qim_imageFromColor:[UIColor spectralColorBlueColor]] forBarMetrics:UIBarMetricsDefault];
        
        _maximumNumberOfSelection      = 9;
        _minimumNumberOfSelection      = 0;
        _assetsFilter                  = [ALAssetsFilter allAssets];
        _showCancelButton              = YES;
        _showEmptyGroups               = NO;
        _selectionFilter               = [NSPredicate predicateWithValue:YES];
        _isFinishDismissViewController = YES;
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0
        self.preferredContentSize=kPopoverContentSize;
#else
        if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
            [self setContentSizeForViewInPopover:kPopoverContentSize];
#endif
        
    }
    return self;
} 

- (NSPredicate *)selectionFilter{
    if (_selectionFilter == nil) {
        _selectionFilter = [NSPredicate predicateWithValue:YES];
    }
    return _selectionFilter;
}

- (NSMutableArray *)indexPathsForSelectedItems{
    if (_indexPathsForSelectedItems == nil) {
        _indexPathsForSelectedItems = [NSMutableArray array];
    }
    return _indexPathsForSelectedItems;
}

- (NSMutableDictionary *)compressDataLengthDic{
    if (_compressDataLengthDic == nil) {
        _compressDataLengthDic = [NSMutableDictionary dictionary];
    }
    return _compressDataLengthDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation;
    }else{
        return YES;
    }
    
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
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return statusBarOrientation;
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

@end
