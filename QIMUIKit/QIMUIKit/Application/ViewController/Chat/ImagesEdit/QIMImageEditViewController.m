//
//  QIMImageEditViewController.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/3.
//
//

#define kImageTagFrom 10000
#define kColorViewTagFrom 100
#define kSendBtnTag 1001
#define kTurnLeftBtnTag 1101
#define kTurnRightBtnTag 1102

#define kDisplayImageViewFrame CGRectMake(0, 20, CGRectGetWidth([UIScreen mainScreen].bounds), _toolBar.top - 20)
#define kClipImageViewFrame CGRectMake(20, 20, CGRectGetWidth([UIScreen mainScreen].bounds) - 40, _toolBar.top - 40)

#import "QIMImageEditViewController.h"
#import "QIMImageUtil.h"
#import "QIMImageClipView.h"
#import "QIMImageDoodleView.h"
#import "NSBundle+QIMLibrary.h"

//LOMO
const float colormatrix_lomo[] = {
    1.7f,  0.1f, 0.1f, 0, -73.1f,
    0,  1.7f, 0.1f, 0, -73.1f,
    0,  0.1f, 1.6f, 0, -73.1f,
    0,  0, 0, 1.0f, 0 };

//黑白
const float colormatrix_heibai[] = {
    0.8f,  1.6f, 0.2f, 0, -163.9f,
    0.8f,  1.6f, 0.2f, 0, -163.9f,
    0.8f,  1.6f, 0.2f, 0, -163.9f,
    0,  0, 0, 1.0f, 0 };
//复古
const float colormatrix_huajiu[] = {
    0.2f,0.5f, 0.1f, 0, 40.8f,
    0.2f, 0.5f, 0.1f, 0, 40.8f,
    0.2f,0.5f, 0.1f, 0, 40.8f,
    0, 0, 0, 1, 0 };

//哥特
const float colormatrix_gete[] = {
    1.9f,-0.3f, -0.2f, 0,-87.0f,
    -0.2f, 1.7f, -0.1f, 0, -87.0f,
    -0.1f,-0.6f, 2.0f, 0, -87.0f,
    0, 0, 0, 1.0f, 0 };

//锐化
const float colormatrix_ruise[] = {
    4.8f,-1.0f, -0.1f, 0,-388.4f,
    -0.5f,4.4f, -0.1f, 0,-388.4f,
    -0.5f,-1.0f, 5.2f, 0,-388.4f,
    0, 0, 0, 1.0f, 0 };


//淡雅
const float colormatrix_danya[] = {
    0.6f,0.3f, 0.1f, 0,73.3f,
    0.2f,0.7f, 0.1f, 0,73.3f,
    0.2f,0.3f, 0.4f, 0,73.3f,
    0, 0, 0, 1.0f, 0 };

//酒红
const float colormatrix_jiuhong[] = {
    1.2f,0.0f, 0.0f, 0.0f,0.0f,
    0.0f,0.9f, 0.0f, 0.0f,0.0f,
    0.0f,0.0f, 0.8f, 0.0f,0.0f,
    0, 0, 0, 1.0f, 0 };

//清宁
const float colormatrix_qingning[] = {
    0.9f, 0, 0, 0, 0,
    0, 1.1f,0, 0, 0,
    0, 0, 0.9f, 0, 0,
    0, 0, 0, 1.0f, 0 };

//浪漫
const float colormatrix_langman[] = {
    0.9f, 0, 0, 0, 63.0f,
    0, 0.9f,0, 0, 63.0f,
    0, 0, 0.9f, 0, 63.0f,
    0, 0, 0, 1.0f, 0 };

//光晕
const float colormatrix_guangyun[] = {
    0.9f, 0, 0,  0, 64.9f,
    0, 0.9f,0,  0, 64.9f,
    0, 0, 0.9f,  0, 64.9f,
    0, 0, 0, 1.0f, 0 };

//蓝调
const float colormatrix_landiao[] = {
    2.1f, -1.4f, 0.6f, 0.0f, -31.0f,
    -0.3f, 2.0f, -0.3f, 0.0f, -31.0f,
    -1.1f, -0.2f, 2.6f, 0.0f, -31.0f,
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f
};

//梦幻
const float colormatrix_menghuan[] = {
    0.8f, 0.3f, 0.1f, 0.0f, 46.5f,
    0.1f, 0.9f, 0.0f, 0.0f, 46.5f,
    0.1f, 0.3f, 0.7f, 0.0f, 46.5f,
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f
};

//夜色
const float colormatrix_yese[] = {
    1.0f, 0.0f, 0.0f, 0.0f, -66.6f,
    0.0f, 1.1f, 0.0f, 0.0f, -66.6f,
    0.0f, 0.0f, 1.0f, 0.0f, -66.6f,
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f
};

@interface QIMImageEditViewController ()
{
    UIImage         * _originalImage;//原图
    UIImage         * _tempOriginalImage;//原图
    UIImage         * _productImage;
    
    UIView          * _toolBar;//工具栏
    UIView          * _naviBar;//导航栏
    UIImageView     * _imageDisplayView;//展示图片
    
    UIScrollView    * _duangView;//特效
    UIView          * _orientationView;//旋转工具条
    UIScrollView    * _doodleSelectBar;//涂鸦工具条
    
    NSArray         * _dataSource;
    NSArray         * _titles;
    NSArray         * _colors;
    
    QIMImageClipView   * _imageClipView;//图片裁剪
    
    QIMImageDoodleView * _imageDoodleView;//涂鸦
    
    UIButton        * _duangBtn,//特效按钮
                    * _clipsBtn,//裁剪按钮
                    * _doodleBtn;//涂鸦按钮
    
}


@end

@implementation QIMImageEditViewController

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [self init]) {
        _originalImage = image;
        _productImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    [self initUI];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initUI

- (void)initUI
{
    [self initNaviBar];
    [self initToolsBar];
    [self initImageDisplayView];
}

- (void)initNaviBar
{
    _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - [[QIMDeviceManager sharedInstance] getTAB_BAR_HEIGHT] + 5, CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    _naviBar.backgroundColor = [UIColor qim_colorWithHex:0x414141 alpha:1.0];
    [self.view addSubview:_naviBar];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(0, 12, 50, 20);
//    [NSBundle qim_localizedStringForKey:@"common_cancel"];
    [cancelBtn setTitle:[NSBundle qim_localizedStringForKey:@"common_cancel"] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [cancelBtn addTarget:self action:@selector(cancelBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_naviBar addSubview:cancelBtn];
    
    _duangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _duangBtn.frame = CGRectMake(70, 5, 34, 34);
    [_duangBtn setImage:[UIImage imageNamed:@"aio_photo_filter"] forState:UIControlStateNormal];
    [_duangBtn setImage:[UIImage imageNamed:@"aio_photo_filter_pressed"] forState:UIControlStateHighlighted];
    [_duangBtn setImage:[UIImage imageNamed:@"aio_photo_filter_pressed"] forState:UIControlStateSelected];
    [_duangBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_duangBtn addTarget:self action:@selector(duangBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    _duangBtn.selected = YES;
    [_naviBar addSubview:_duangBtn];
    
    _clipsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _clipsBtn.frame = CGRectMake(140, 5, 34, 34);
    [_clipsBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_clipsBtn setImage:[UIImage imageNamed:@"aio_photo_cut"] forState:UIControlStateNormal];
    [_clipsBtn setImage:[UIImage imageNamed:@"aio_photo_cut_pressed"] forState:UIControlStateHighlighted];
    [_clipsBtn setImage:[UIImage imageNamed:@"aio_photo_cut_pressed"] forState:UIControlStateSelected];
    [_clipsBtn addTarget:self action:@selector(clipsBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_naviBar addSubview:_clipsBtn];
    
    _doodleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _doodleBtn.frame = CGRectMake(210, 5, 34, 34);
    [_doodleBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_doodleBtn setImage:[UIImage imageNamed:@"aio_photo_brush"] forState:UIControlStateNormal];
    [_doodleBtn setImage:[UIImage imageNamed:@"aio_photo_brush_pressed"] forState:UIControlStateHighlighted];
    [_doodleBtn setImage:[UIImage imageNamed:@"aio_photo_brush_pressed"] forState:UIControlStateSelected];
    [_doodleBtn addTarget:self action:@selector(doodleBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_naviBar addSubview:_doodleBtn];
    
    UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    sendBtn.frame = CGRectMake(CGRectGetWidth(_naviBar.bounds) - 70, 12, 50, 20);
    [sendBtn setTitle:[NSBundle qim_localizedStringForKey:@"common_ok"] forState:UIControlStateNormal];
    [sendBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    sendBtn.tag = kSendBtnTag;
    [sendBtn addTarget:self action:@selector(sendBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_naviBar addSubview:sendBtn];
}

- (void)initToolsBar
{
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, _naviBar.top - 80, CGRectGetWidth([UIScreen mainScreen].bounds), 80)];
    _toolBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_toolBar];
    [self addDuangView];
}

- (void)initImageDisplayView
{
    _imageDisplayView = [[UIImageView alloc] initWithImage:_originalImage];
    _imageDisplayView.frame = kDisplayImageViewFrame;
    _imageDisplayView.backgroundColor = [UIColor blackColor];
    _imageDisplayView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageDisplayView];
}

//加特效 Duang
- (void)addDuangView
{
    _dataSource = [[NSArray alloc] initWithObjects:@"imageEdit.png",@"imageEdit.png",@"imageEdit.png",@"imageEdit.png",@"imageEdit.png",@"imageEdit.png",@"imageEdit.png",@"imageEdit.png",@"imageEdit.png",@"imageEdit.png",@"imageEdit.png",@"imageEdit.png",@"imageEdit.png",@"imageEdit.png", nil];
    _titles = [[NSArray alloc] initWithObjects:@"原图",@"LOMO",@"黑白",@"怀旧",@"哥特",@"锐化",@"淡雅",@"酒红",@"清宁",@"浪漫",@"光晕",@"蓝调",@"梦幻",@"夜色", nil];
    _duangView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolBar.bounds), CGRectGetHeight(_toolBar.bounds))];
    _duangView.showsVerticalScrollIndicator = NO;
    _duangView.backgroundColor = [UIColor qim_colorWithHex:0x2e2e2e alpha:1.0];
    [_toolBar addSubview:_duangView];
    
    NSInteger i = 0;
    for (NSString * imageStr in _dataSource) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(80 * i, 0, 80, 80)];
        imageView.image = [self getDuangImageWithIndexTag:i originalImage:[UIImage imageNamed:imageStr]];
        imageView.tag = kImageTagFrom + i;
        imageView.userInteractionEnabled = YES;
        [_duangView addSubview:imageView];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, imageView.height - 20, imageView.width - 4, 20)];
        titleLabel.backgroundColor = [UIColor blackColor];
        titleLabel.alpha = 0.7;
        titleLabel.text = _titles[i];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        titleLabel.textColor = [UIColor yellowColor];
        titleLabel.font = [UIFont systemFontOfSize:12];
        [imageView addSubview:titleLabel];
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewHandle:)];
        [imageView addGestureRecognizer:tapGes];
        i++;
    }
    _duangView.contentSize = CGSizeMake(80 * _dataSource.count, _duangView.height);
}

//图片旋转工具条
- (void)addOrientationView
{
    _orientationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolBar.bounds), CGRectGetHeight(_toolBar.bounds))];
    _orientationView.backgroundColor = [UIColor qim_colorWithHex:0x2e2e2e alpha:1.0];
    [_toolBar addSubview:_orientationView];
    
    UIButton * orientationLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    orientationLeftBtn.frame = CGRectMake(_orientationView.width / 2 - 70, 10, 34, 34);
//    [orientationLeftBtn setTitle:@"left" forState:UIControlStateNormal];
    [orientationLeftBtn setImage:[UIImage imageNamed:@"pe_crop_left_ccw_normal"] forState:UIControlStateNormal];
    [orientationLeftBtn setImage:[UIImage imageNamed:@"pe_crop_left_ccw_pressed"] forState:UIControlStateHighlighted];
    [orientationLeftBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    orientationLeftBtn.tag = kTurnLeftBtnTag;
    [orientationLeftBtn addTarget:self action:@selector(orientationBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_orientationView addSubview:orientationLeftBtn];
    
    UIButton * orientationRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    orientationRightBtn.frame = CGRectMake(_orientationView.width / 2 + 20, 10, 34, 34);
//    [orientationRightBtn setTitle:@"right" forState:UIControlStateNormal];
    [orientationRightBtn setImage:[UIImage imageNamed:@"pe_crop_right_ccw_normal"] forState:UIControlStateNormal];
    [orientationRightBtn setImage:[UIImage imageNamed:@"pe_crop_right_ccw_pressed"] forState:UIControlStateHighlighted];
    [orientationRightBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    orientationRightBtn.tag = kTurnRightBtnTag;
    [orientationRightBtn addTarget:self action:@selector(orientationBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_orientationView addSubview:orientationRightBtn];
    
}

- (void)addDoodleSelectBar
{
    _doodleSelectBar = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_toolBar.bounds), CGRectGetHeight(_toolBar.bounds))];
    _doodleSelectBar.showsVerticalScrollIndicator = NO;
    _doodleSelectBar.backgroundColor = [UIColor qim_colorWithHex:0x2e2e2e alpha:1.0];
    [_toolBar addSubview:_doodleSelectBar];
    
    UIButton * cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cleanBtn.frame = CGRectMake(10, (_toolBar.height - 34) / 2, 34, 34);
    [cleanBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [cleanBtn setImage:[UIImage imageNamed:@"pe_doodle_eraser_normal"] forState:UIControlStateNormal];
    [cleanBtn setImage:[UIImage imageNamed:@"pe_doodle_eraser_pressed"] forState:UIControlStateHighlighted];
    [cleanBtn setImage:[UIImage imageNamed:@"pe_doodle_eraser_pressed"] forState:UIControlStateSelected];
    [cleanBtn addTarget:self action:@selector(cleanBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    [_doodleSelectBar addSubview:cleanBtn];
    
    _colors = [NSArray arrayWithObjects:[UIColor redColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor greenColor],[UIColor blueColor],[UIColor purpleColor], nil];
    
    cleanBtn.tag = kColorViewTagFrom + _colors.count;
    
    NSInteger i = 0;
    for (UIColor * color in _colors) {
        UIView * colorView = [[UIView alloc] initWithFrame:CGRectMake(54 + i * 44, (_toolBar.height - 34) / 2, 34, 34)];
        colorView.backgroundColor = color;
        colorView.layer.cornerRadius = 5;
        if (i == 0) {
            colorView.layer.borderColor = [UIColor blueColor].CGColor;
            colorView.layer.borderWidth = 1;
            _imageDoodleView.selectedColor = [_colors firstObject];
        }
        [_doodleSelectBar addSubview:colorView];
        colorView.tag = kColorViewTagFrom + i;
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorViewTapHandle:)];
        [colorView addGestureRecognizer:tapGes];
        i ++;
    }
}

- (void)setUpQIMImageClipView
{
    if (_imageClipView) {
        [_imageClipView resetClipRectWithImage:_imageDisplayView.image];
        [self.view bringSubviewToFront:_imageClipView];
    }else{
        _imageClipView = [[QIMImageClipView alloc] initWithFrame:kClipImageViewFrame imageView:_imageDisplayView.image];
        [self.view addSubview:_imageClipView];
    }
    _imageDisplayView.frame = kClipImageViewFrame;
    UIButton * sendBtn = (UIButton *)[_naviBar viewWithTag:kSendBtnTag];
    [sendBtn setTitle:@"裁剪" forState:UIControlStateNormal];
    
    if (_orientationView) {
        [_toolBar bringSubviewToFront:_orientationView];
    }else{
        [self addOrientationView];
    }
    
}

- (void)setUpQIMImageDoodleView
{
    _imageDoodleView = [[QIMImageDoodleView alloc] initWithFrame:CGRectZero];
    _imageDoodleView.drawingMode = DrawingModePaint;
    [self.view addSubview:_imageDoodleView];
}

#pragma mark - btnHandle

- (void)cancelBtnHandle:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clipsBtnHandle:(UIButton *)btn
{
    _duangView.hidden = YES;
    _imageDoodleView.hidden = YES;
    [self setUpQIMImageClipView];
    
    _clipsBtn.selected = YES;
    _doodleBtn.selected = NO;
    _duangBtn.selected = NO;
    [self saveDoodleImage];
    
    _tempOriginalImage = _originalImage;
}

- (void)duangBtnHandle:(UIButton *)btn
{
    _duangView.hidden = NO;
    if (_imageDisplayView) {
        _imageDisplayView.image = _productImage;
        [self.view bringSubviewToFront:_imageDisplayView];
    }
    _imageDisplayView.frame = kDisplayImageViewFrame;
    UIButton * sendBtn = (UIButton *)[_naviBar viewWithTag:kSendBtnTag];
    [sendBtn setTitle:[NSBundle qim_localizedStringForKey:@"common_ok"] forState:UIControlStateNormal];
    
    if (_duangView) {
        [_toolBar bringSubviewToFront:_duangView];
    }
    
    _duangBtn.selected = YES;
    _clipsBtn.selected = NO;
    _doodleBtn.selected = NO;
    [self saveDoodleImage];
}

- (void)doodleBtnHandle:(UIButton *)btn
{
    _imageDisplayView.image = _productImage;
    [self.view bringSubviewToFront:_imageDisplayView];

    if (_imageDoodleView) {
        [_imageDoodleView clean];
        [self.view bringSubviewToFront:_imageDoodleView];
    }else{
        [self setUpQIMImageDoodleView];
    }
    
    UIImage * image = _imageDisplayView.image;
    float scale = image.size.width / image.size.height > _imageDisplayView.width / _imageDisplayView.height ? _imageDisplayView.width / image.size.width : _imageDisplayView.height / image.size.height;
    CGRect doodleFrame = CGRectMake(_imageDisplayView.left + (_imageDisplayView.width-image.size.width * scale)/2, _imageDisplayView.top + (_imageDisplayView.height-image.size.height * scale)/2, image.size.width * scale, image.size.height * scale);
    _imageDoodleView.frame = doodleFrame;
    _imageDisplayView.frame = kDisplayImageViewFrame;
    
    _imageDoodleView.hidden = NO;
    if (_doodleSelectBar) {
        [_toolBar bringSubviewToFront:_doodleSelectBar];
    }else{
        [self addDoodleSelectBar];
    }
    
    _doodleBtn.selected = YES;
    _clipsBtn.selected = NO;
    _duangBtn.selected = NO;
    
    UIButton * sendBtn = (UIButton *)[_naviBar viewWithTag:kSendBtnTag];
    [sendBtn setTitle:[NSBundle qim_localizedStringForKey:@"common_ok"] forState:UIControlStateNormal];
}

- (void)sendBtnHandle:(UIButton *)btn
{
    if ([[btn titleForState:UIControlStateNormal] isEqualToString:[NSBundle qim_localizedStringForKey:@"common_ok"]]) {
        [self saveDoodleImage];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"图片尚未保存，是否保存图片？"
                                                       delegate:self
                                              cancelButtonTitle:@"直接发送"
                                              otherButtonTitles:@"保存并发送",nil];
        alert.delegate = self;
        [alert show];
    }else if ([[btn titleForState:UIControlStateNormal] isEqualToString:@"裁剪"]) {
        _productImage = [_imageClipView getClipImage];
        _originalImage = _tempOriginalImage;
        _originalImage = [_imageClipView getClipImageForOriginalImage:_originalImage];
        [self duangBtnHandle:nil];
    }
    
}

- (void)sendImage
{
    //发送图片
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageEditVC:didEditWithProductImage:)]) {
        [self.delegate imageEditVC:self didEditWithProductImage:_productImage];
    }
}

- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    UIAlertView *alert = nil;
    if(error != NULL){
        msg = @"保存图片失败" ;
        alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                   message:msg
                                  delegate:self
                         cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
    }else{
        [self sendImage];
    }
   
    [alert show];
}

- (void)orientationBtnHandle:(UIButton *)btn
{

    if (btn.tag == kTurnLeftBtnTag) {
        _imageDisplayView.image = [QIMImageUtil image:_imageDisplayView.image rotation:UIImageOrientationLeft];
        _tempOriginalImage = [QIMImageUtil image:_tempOriginalImage rotation:UIImageOrientationLeft];
        
    }else if (btn.tag == kTurnRightBtnTag){
        _imageDisplayView.image = [QIMImageUtil image:_imageDisplayView.image rotation:UIImageOrientationRight];
        _tempOriginalImage = [QIMImageUtil image:_tempOriginalImage rotation:UIImageOrientationRight];
    }
    [_imageClipView resetClipRectWithImage:_imageDisplayView.image];
}

- (void)cleanBtnHandle:(UIButton *)btn
{
    [self cleanColorSelection];
    _imageDoodleView.drawingMode = DrawingModeErase;
    btn.selected = YES;
}

- (void)colorViewTapHandle:(UITapGestureRecognizer *)tap
{
    _imageDoodleView.drawingMode = DrawingModePaint;
    
    [self cleanColorSelection];
    
    UIColor * color = [_colors objectAtIndex:tap.view.tag - kColorViewTagFrom];
    _imageDoodleView.selectedColor = color;
    
    tap.view.layer.borderColor = [UIColor blueColor].CGColor;
    tap.view.layer.borderWidth = 1;
}

#pragma mark - action

-(void)imageViewHandle:(UITapGestureRecognizer *)tapGes
{
    _imageDisplayView.image = [self getDuangImageWithIndexTag:tapGes.view.tag - kImageTagFrom originalImage:_originalImage];
    _productImage = _imageDisplayView.image;
    float desOffsetX = tapGes.view.origin.x - (_duangView.width - 80) / 2;
    [_duangView setContentOffset:CGPointMake(MIN(MAX(desOffsetX, 0), _duangView.contentSize.width - _duangView.width), 0) animated:YES];
}


- (UIImage *)getDuangImageWithIndexTag : (NSInteger)indexTag originalImage : (UIImage *)originalImage
{
    UIImage *image;
    switch (indexTag) {
        case 0:
        {
            return originalImage;
        }
            break;
        case 1:
        {
            image = [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_lomo];
        }
            break;
        case 2:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_heibai];
        }
            break;
        case 3:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_huajiu];
        }
            break;
        case 4:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_gete];
        }
            break;
        case 5:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_ruise];
        }
            break;
        case 6:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_danya];
        }
            break;
        case 7:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_jiuhong];
        }
            break;
        case 8:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_qingning];
        }
            break;
        case 9:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_langman];
        }
            break;
        case 10:
        {
            image =  [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_guangyun];
        }
            break;
        case 11:
        {
            image = [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_landiao];
            
        }
            break;
        case 12:
        {
            image = [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_menghuan];
            
        }
            break;
        case 13:
        {
            image = [QIMImageUtil imageWithImage:originalImage withColorMatrix:colormatrix_yese];
            
        }
    }
    return image;
}


- (void)saveDoodleImage
{
    UIImage * doodleImage = [_imageDoodleView getDoodleImage];
    float scale = _productImage.size.width / doodleImage.size.width;
    _productImage = [QIMImageUtil addImage:doodleImage toImage:_productImage subRect:CGRectMake(0, 0, doodleImage.size.width * scale, doodleImage.size.height * scale)];
    _imageDisplayView.image = _productImage;
    _originalImage = [QIMImageUtil addImage:doodleImage toImage:_originalImage subRect:CGRectMake(0, 0, doodleImage.size.width * scale, doodleImage.size.height * scale)];
}

- (void)cleanColorSelection
{
    for (int i = 0; i <= _colors.count; i ++) {
        UIView * colorView = [_doodleSelectBar viewWithTag:kColorViewTagFrom + i];
        if ([colorView isKindOfClass:[UIButton class]]) {
            [(UIButton *)colorView setSelected:NO];
        }else{
            colorView.layer.borderWidth = 0;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self saveImageToPhotos:_productImage];
    }else{
        [self sendImage];
    }
}

@end
