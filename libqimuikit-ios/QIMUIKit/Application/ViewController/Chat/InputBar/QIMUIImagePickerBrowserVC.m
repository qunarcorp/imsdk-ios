//
//  QIMUIImagePickerBrowserVC.m
//  DangDiRen
//
//  Created by 平 薛 on 14-4-14.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "QIMUIImagePickerBrowserVC.h"
#import "QIMImageEditViewController.h"
#import "QIMStringTransformTools.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMUIImagePickerBrowserVC ()<UIActionSheetDelegate,UIScrollViewDelegate,QIMImageEditViewControllerDelegate>{
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    UIButton *_sdButton;
    BOOL _isSD;
}

@end

@implementation QIMUIImagePickerBrowserVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY-32);
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle qim_localizedStringForKey:@"common_save"] style:UIBarButtonItemStylePlain target:self action:@selector(saveBtnHandle:)];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [[QIMDeviceManager sharedInstance] getSTATUS_BAR_HEIGHT] - 20, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.height - 40 - 20 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT])];
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
    [_scrollView setShowsHorizontalScrollIndicator:YES];
    [_scrollView setShowsVerticalScrollIndicator:YES];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.maximumZoomScale=2.0;
    _scrollView.minimumZoomScale=0.5;
//    [_scrollView setBackgroundColor:[UIColor redColor]];
    [_scrollView setDelegate:self];
    [self.view addSubview:_scrollView];
    CGFloat scale = MIN(_scrollView.width / self.sourceImage.size.width, _scrollView.height / self.sourceImage.size.height);
    CGSize imageSize = CGSizeMake(scale*self.sourceImage.size.width, scale*self.sourceImage.size.height);
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, imageSize.width,imageSize.height)];
    [_imageView setCenter:CGPointMake(_scrollView.centerX, _scrollView.centerY-32)];
    [_imageView setImage:self.sourceImage];
    [_scrollView addSubview:_imageView];
    
    [_scrollView setContentSize:CGSizeMake(_imageView.size.width, _imageView.size.height)];

    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.height - 40 - 20 - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], [UIScreen mainScreen].bounds.size.width, 46)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    
    
    _sdButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_sdButton setFrame:CGRectMake(80, 10, 60, 20)];
    [_sdButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_sdButton setTitle:@"标清" forState:UIControlStateNormal];
    [_sdButton setImage:[UIImage imageNamed:@"photo_browser_button_arrow_normal"] forState:UIControlStateNormal];
    [_sdButton setImage:[UIImage imageNamed:@"photo_browser_button_arrow_pressed"] forState:UIControlStateHighlighted];
    [_sdButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [_sdButton addTarget:self action:@selector(onPictureQualityClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_sdButton];
    
    UIButton * imageEditButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [imageEditButton setFrame:CGRectMake(10, 10, 60, 20)];
    [imageEditButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [imageEditButton setTitle:@"编辑" forState:UIControlStateNormal];
    [imageEditButton addTarget:self action:@selector(onImageEditClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:imageEditButton];
    
    _isSD = YES;
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 110, 6, 100, 28)];
    [doneButton.layer setCornerRadius:5];
    [doneButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [doneButton setTitle:@"确定" forState:UIControlStateNormal];
    [doneButton setBackgroundColor:[UIColor spectralColorBlueColor]];
    [doneButton addTarget:self action:@selector(onDoneClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:doneButton];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    //照相机返回 导航条会自动消失 重设一下
    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        _isSD = YES;
        [_sdButton setTitle:@"标清" forState:UIControlStateNormal];
    } else if(buttonIndex == 1){
        _isSD = NO;
        [_sdButton setTitle:@"原图" forState:UIControlStateNormal];
    }
}


- (void)onImageEditClick:(UIButton *)btn
{
    QIMImageEditViewController * imageEditVC = [[QIMImageEditViewController alloc] initWithImage:_sourceImage];
    imageEditVC.delegate = self;
    [self.navigationController pushViewController:imageEditVC animated:YES];
}

- (void)onPictureQualityClick:(UIButton *)sender{
    NSString *bqStr = @"";
    NSString *sourceStr = @"";
    @autoreleasepool {
        NSData *data = UIImageJPEGRepresentation(_sourceImage, 1);
        sourceStr = [QIMStringTransformTools CapacityTransformStrWithSize:data.length];
        UIImage *image = [_sourceImage qim_sdImage];
        data = UIImageJPEGRepresentation(image, 1);
        bqStr = [QIMStringTransformTools CapacityTransformStrWithSize:data.length];
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择图片尺寸" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"标清 (%@)",bqStr],
                            [NSString stringWithFormat:@"原图 (%@)",sourceStr],nil];
    [sheet showInView:self.view];
}

- (void)onCancelClick:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(imagePickerBrowserDidCancel:)]) {
        [self.delegate imagePickerBrowserDidCancel:self];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onDoneClick:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(imagePickerBrowserDidFinish:)]) {
        if (_isSD) {
            [self setSourceImage:[_sourceImage qim_sdImage]];
        }
        [self.delegate imagePickerBrowserDidFinish:self];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)saveBtnHandle:(UIButton *)btn
{
    UIImageWriteToSavedPhotosAlbum(self.sourceImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    UIAlertView *alert = nil;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    
    alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                       message:msg
                                      delegate:self
                             cancelButtonTitle:@"确定"
                             otherButtonTitles:nil];
    
    [alert show];
}

#pragma mark - QIMImageEditViewControllerDelegate

- (void)imageEditVC:(QIMImageEditViewController *)imageEditVC didEditWithProductImage:(UIImage *)productImage
{
    _sourceImage = productImage;
    [self onDoneClick:nil];
}

@end
