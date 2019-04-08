//
//  QIMCollectionEmotionEditorVC.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/13.
//
//

#import "QIMCollectionEmotionEditorVC.h"
#import "QIMCollectionFaceManager.h"
#import "MBProgressHUD.h"

typedef NS_ENUM(NSUInteger, QIMDragCellCollectionViewScrollDirection) {
    QIMDragCellCollectionViewScrollDirectionNone = 0,
    QIMDragCellCollectionViewScrollDirectionLeft,
    QIMDragCellCollectionViewScrollDirectionRight,
    QIMDragCellCollectionViewScrollDirectionUp,
    QIMDragCellCollectionViewScrollDirectionDown
};
#define kEmotionItemColumnNum   4

#import "QIMCollectionEmotionEditorViewFlowLayout.h"
#import "QTImagePickerController.h"
#import "QIMImageUtil.h"
#import "UIBarButtonItem+Utility.h"
#import "QIMCollectionEmotionEditorViewCell.h"
#import "QIMCollectionEmotionPanView.h"

static NSString *collectEmojiCellID = @"collectEmojiCellID";

@interface QIMCollectionEmotionEditorVC () <UICollectionViewDelegate, UICollectionViewDataSource, UINavigationBarDelegate, QIMCollectionEmotionEditorViewDelegate, QTImagePickerControllerDelegate, QIMDragCellCollectionViewDelegate, QIMDragCellCollectionViewDataSource, UIAlertViewDelegate>
{
    NSMutableArray *_emotionSelectedList;
}

@property (nonatomic, strong) QIMCollectionEmotionPanView *mainCollectionView;

@property (nonatomic, strong) UIView *emotionDelBar;

@property (nonatomic, strong) UIButton *emotionDelBtn;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) UIButton *sortBtn;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, assign) BOOL willRefresh;

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end

@implementation QIMCollectionEmotionEditorVC

#pragma mark - setter and getter

- (NSMutableArray *)dataList {
    
    if (!_dataList) {
        
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (QIMCollectionEmotionPanView *)mainCollectionView {
    
    if (!_mainCollectionView) {
        
        QIMCollectionEmotionEditorViewFlowLayout *layout = [[QIMCollectionEmotionEditorViewFlowLayout alloc] init];
        _mainCollectionView = [[QIMCollectionEmotionPanView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_mainCollectionView registerClass:[QIMCollectionEmotionEditorViewCell class] forCellWithReuseIdentifier:collectEmojiCellID];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.shakeLevel = 3.0f;
        _mainCollectionView.showsVerticalScrollIndicator = NO;
        _mainCollectionView.backgroundColor = [UIColor whiteColor];
        
        UIView * headerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight(_mainCollectionView.frame), CGRectGetWidth(_mainCollectionView.frame), CGRectGetHeight(_mainCollectionView.frame))];
        headerBgView.backgroundColor = [UIColor qim_colorWithHex:0xececec alpha:1];
        [_mainCollectionView addSubview:headerBgView];
    }
    return _mainCollectionView;
}

#pragma mark - HUD
- (MBProgressHUD *)progressHUDWithText:(NSString *)text {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        [_progressHUD setLabelText:@""];
        [self.mainCollectionView addSubview:_progressHUD];
    }
    [_progressHUD setDetailsLabelText:text];
    return _progressHUD;
}
- (UIButton *)sortBtn {
    
    if (!_sortBtn) {
        
        _sortBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sortBtn.frame =  CGRectMake(0, 0, 44, 44);
        [_sortBtn setTitle:@"整理" forState:UIControlStateNormal];
        [_sortBtn setTitle:@"完成" forState:UIControlStateSelected];
        [_sortBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [_sortBtn addTarget:self action:@selector(arrangeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sortBtn;
}

- (UIButton *)cancelBtn {
    
    if (!_cancelBtn) {
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(0, 0, 44, 44);
        [_cancelBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateSelected];
        [_cancelBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateSelected];
        [_cancelBtn addTarget:self action:@selector(CancelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

#pragma mark - 初始化

- (void)initUI {
    
    self.title = @"收藏的表情";
    
    self.view.backgroundColor = [UIColor qim_colorWithHex:0xececec alpha:1.0];
    [self.view addSubview:self.mainCollectionView];
}

/**
 *  设置导航条
 */
- (void)setNavBar {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sortBtn];
}

- (void)updateDelBar{
    if (_emotionDelBar == nil) {
        _emotionDelBar = [[UIView alloc] initWithFrame:CGRectMake(0, _mainCollectionView.bottom - 50, _mainCollectionView.width, 50)];
        _emotionDelBar.backgroundColor = [UIColor qtalkChatBgColor];
        UILabel * dispalyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _emotionDelBar.width / 2 - 10, 50)];
        dispalyLabel.text = [NSString stringWithFormat:@"共%@个表情",@(_dataList.count)];
        dispalyLabel.textColor = [UIColor grayColor];
        [_emotionDelBar addSubview:dispalyLabel];
        
        [self.view addSubview:_emotionDelBar];
        _mainCollectionView.frame = CGRectMake(0 , 0, self.view.width, self.view.height - _emotionDelBar.height);
        
    }
    if (_emotionDelBtn == nil) {
        
        _emotionDelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _emotionDelBtn.frame = CGRectMake(_emotionDelBar.width - 120, 0, 100, 50);
        _emotionDelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_emotionDelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_emotionDelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_emotionDelBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_emotionDelBtn addTarget:self action:@selector(emotionDelBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    [_emotionDelBar addSubview:_emotionDelBtn];
    
    
    if (_emotionSelectedList.count) {
        [_emotionDelBtn setTitle:[NSString stringWithFormat:@"删除(%@)",@(_emotionSelectedList.count)] forState:UIControlStateNormal];
        [_emotionDelBtn setEnabled:YES];
    }else{
        [_emotionDelBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_emotionDelBtn setEnabled:NO];
        
    }
}

- (void)emotionDelBtnHandle:(id)sender{
    if (_emotionSelectedList.count > 0) {
        [_dataList removeObjectsInArray:_emotionSelectedList];
        [[QIMCollectionFaceManager sharedInstance] delCollectionFaceArr:_emotionSelectedList];
        [_mainCollectionView reloadData];
        [self arrange];
        
        [_emotionDelBar removeFromSuperview];
    }
    _emotionSelectedList = nil;
    [_emotionDelBar removeFromSuperview];
    
    [self updateDelBar];
}


#pragma mark - actionMethod
//关闭
- (void)CancelAction:(id)sender {
    
    if (!self.cancelBtn.selected) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        
        
        self.sortBtn.selected = NO;
        self.cancelBtn.selected = NO;
        self.mainCollectionView.isOpenMove = NO;
        [_emotionDelBar removeFromSuperview];
        
        if (![self isChangeDataList]) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定取消改动？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 0;
            [alertView show];
        }
        [_dataList addObject:kImageFacePageViewAddFlagName];
        [_mainCollectionView reloadData];
    }
}

//判断数据源是否改变
- (BOOL)isChangeDataList {
    
    NSArray *array = [[QIMCollectionFaceManager sharedInstance] getCollectionFaceList];
    BOOL isEqual = [_dataList isEqualToArray:array];
    return isEqual;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 0) {
        
        if (buttonIndex == 1) {
            
            [self refresh];
            [self.mainCollectionView reloadData];
        }
    }
}

//整理
- (void)arrangeAction {
    
    self.sortBtn.selected = !self.sortBtn.selected;
    self.cancelBtn.selected = self.sortBtn.selected;
    self.mainCollectionView.isOpenMove = self.sortBtn.selected;
    // 暂时不支持长按排序
    [self arrange];
     
}

- (void)arrange {
    
    NSString * item = _dataList.lastObject;
    if ([item isKindOfClass:[NSDictionary class]]) {
        item = _dataList.lastObject[@"imageName"];
    }
    
    if ([item isEqualToString:kImageFacePageViewAddFlagName]) {
        [_dataList removeLastObject];
        [self updateDelBar];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"长按表情解锁新姿势" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
    }else{
        
        [_emotionDelBar removeFromSuperview];
        _emotionDelBar = nil;
        _mainCollectionView.frame = self.view.bounds;
        if (![self isChangeDataList]) {
            
            [[QIMCollectionFaceManager sharedInstance] resetCollectionItems:self.dataList WithUpdate:YES];
            [[self progressHUDWithText:@"系统君正在重新排版您的收藏表情..."] show:YES];
            [self performSelector:@selector(closeHUD) withObject:nil afterDelay:1.0f];
        }
        [self refresh];
    }
    [_mainCollectionView reloadData];
}

- (void)refresh {
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:_dataList];
    if (self.sortBtn.selected) {
        
        [tempArray removeAllObjects];
        [tempArray addObjectsFromArray:[[QIMCollectionFaceManager sharedInstance] getCollectionFaceList]];
        _dataList = [NSMutableArray arrayWithArray:tempArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainCollectionView reloadData];
        });
    } else {
        
        [tempArray removeAllObjects];
        [tempArray addObjectsFromArray:[[QIMCollectionFaceManager sharedInstance] getCollectionFaceList]];
        [tempArray addObject:kImageFacePageViewAddFlagName];
        _dataList = [NSMutableArray arrayWithArray:tempArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainCollectionView reloadData];
        });
    }
    _emotionSelectedList = nil;
}

#pragma mark - life ctyle

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (_willRefresh) {
        
        [self refresh];
        _willRefresh = NO;
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self setNavBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:@"kCollectionEmotionUpdateHandleNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:@"refreshTableView"
                                               object:nil];
    _willRefresh = YES;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QIMCollectionEmotionEditorViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectEmojiCellID forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.editDelegate = self;
    
    NSString * item = _dataList.lastObject;
    if ([item isKindOfClass:[NSDictionary class]]) {
        item = _dataList.lastObject[@"httpUrl"];
    }
    cell.canSelect = ![item isEqualToString:kImageFacePageViewAddFlagName];
    [cell setEmotionItem:_dataList[cell.tag]];
    return cell;
}

- (void)collectionEmotionEditorCell:(QIMCollectionEmotionEditorViewCell *)cell didClickedItemAtIndex:(NSInteger)index selected:(BOOL)selected {
    
    if (self.sortBtn.selected) {
        [self.view addSubview:_emotionDelBar];
    }
    NSString *item = _dataList.lastObject;
    if ([item isKindOfClass:[NSDictionary class]]) {
        
        item = _dataList.lastObject[@"httpUrl"];
    }
    if (![item isEqualToString:kImageFacePageViewAddFlagName]) {
        
        if (_emotionSelectedList == nil) {
            
            _emotionSelectedList = [NSMutableArray arrayWithCapacity:1];
        }
        if (selected) {
            
            [_emotionSelectedList addObject:_dataList[index]];
        } else {
            
            [_emotionSelectedList removeObject:_dataList[index]];
        }
        
        [self updateDelBar];
    } else if (index == _dataList.count - 1) {
        
        QTImagePickerController *imagePickerController = [[QTImagePickerController alloc] init];
        imagePickerController.imageDelegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - QTImagePickerControllerDelegate
- (void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingVideo:(NSDictionary *)videoDic{
    
    [picker dismissViewControllerAnimated:NO completion:nil];
}

-(void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets ToOriginal:(BOOL)flag
{
    for (ALAsset * asset in assets) {
        NSData * imageData = nil;
        if (flag) {
            uint8_t *buffer = (uint8_t *)malloc(asset.defaultRepresentation.size);
            NSInteger length = [asset.defaultRepresentation getBytes:buffer fromOffset:0 length:asset.defaultRepresentation.size error:nil];
            imageData = [NSData dataWithBytes:buffer length:length];
            free(buffer);
            UIImage * image = [QIMImageUtil fixOrientation:[UIImage imageWithData:imageData]];
            imageData = UIImageJPEGRepresentation(image, 1.0);
        }else{
            UIImage * image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage                                         scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
            image = [QIMImageUtil fixOrientation:image];
            imageData = UIImageJPEGRepresentation(image, 0.5);
        }
        
        [[QIMKit sharedInstance] uploadFileForData:imageData forCacheType:QIMFileCacheTypeColoction isFile:NO completionBlock:^(UIImage *image, NSError *error, QIMFileCacheType cacheType, NSString *imageURL) {
            
            
            [[QIMKit sharedInstance] getPermUrlWithTempUrl:imageURL PermHttpUrl:^(NSString *httpPermUrl) {
                
                [[QIMCollectionFaceManager sharedInstance] insertCollectionEmojiWithEmojiUrl:httpPermUrl];

                [[QIMCollectionFaceManager sharedInstance] checkForUploadLocalCollectionFace];

            }];
            
            [self refresh];
            [picker dismissViewControllerAnimated:NO completion:nil];
            
        }];
    }
}

-(void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingImage:(UIImage *)image
{
    NSData * imageData = UIImageJPEGRepresentation(image, 0.9);
    __block NSString *httpUrl = [NSString stringWithFormat:@""];
    [[QIMKit sharedInstance] uploadFileForData:imageData forCacheType:QIMFileCacheTypeColoction isFile:NO completionBlock:^(UIImage *image, NSError *error, QIMFileCacheType cacheType, NSString *imageURL) {
        
        httpUrl = imageURL;
        
        [[QIMKit sharedInstance] getPermUrlWithTempUrl:httpUrl PermHttpUrl:^(NSString *httpPermUrl) {
            [[QIMCollectionFaceManager sharedInstance] insertCollectionEmojiWithEmojiUrl:httpPermUrl];
            [[QIMCollectionFaceManager sharedInstance] checkForUploadLocalCollectionFace];

        }];
        [self refresh];
        [picker dismissViewControllerAnimated:NO completion:nil];
        
    }];
    
}

#pragma mark - <QIMDragCellCollectionViewDelegate> <QIMDragCellCollectionViewDataSource>

- (NSArray *)dataSourceArrayOfCollectionView:(QIMCollectionEmotionPanView *)collectionView{
    
    return _dataList;
}

- (void)dragCellCollectionView:(QIMCollectionEmotionPanView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    
    [_dataList removeAllObjects];
    [_dataList addObjectsFromArray:newDataArray];
}

- (void)dragCellCollectionView:(QIMCollectionEmotionPanView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath{
    //拖动时候最后禁用掉编辑按钮的点击
    
    [_emotionDelBar removeFromSuperview];
}

- (void)dragCellCollectionViewCellEndMoving:(QIMCollectionEmotionPanView *)collectionView{
    
}

- (void)closeHUD{
    if (_progressHUD) {
        [_progressHUD hide:YES];
    }
}

- (void)dealloc {
    
    _dataList = nil;
    _emotionSelectedList = nil;
    _mainCollectionView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
