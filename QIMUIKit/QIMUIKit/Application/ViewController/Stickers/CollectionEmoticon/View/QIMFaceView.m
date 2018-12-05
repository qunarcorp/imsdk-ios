//
//  QIMFaceView.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/9.
//
//

#import "QIMFaceView.h"
#import "QIMFaceViewDataSource.h"
#import "QIMFaceViewFlowLayout.h"
#import "QIMFaceViewCell.h"
#import "QIMEmotionManager.h"

/*
 ** 两边边缘间隔
 */
#define EdgeDistance 3
/*
 ** 上下边缘间隔
 */
#define EdgeInterVal 5


/*
 ** 两边边缘间隔
 */
#define NormalEdgeDistance 10
/*
 ** 上下边缘间隔
 */
#define NormalEdgeInterVal 10
#define IsWidescreen ([UIScreen mainScreen].bounds.size.width > 320 ? 1 : 0)
#define kMyCollectionFaceNumPerLine (4 + IsWidescreen)
#define kMyCollectionFaceLines 2
#define kImageFacePageViewItemWidth (60)

static NSString *cellID = @"cellID";

@interface QIMFaceView () <UICollectionViewDelegate>

@property (nonatomic, strong) QIMFaceViewDataSource *lluDataSource;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSArray *dataList;

@property (nonatomic, strong) NSMutableArray *devideEmojiList;

@property (nonatomic, assign) BOOL showAll;

@end

@implementation QIMFaceView

- (NSArray *)dataList {
    
    if (!_dataList) {
        
        QIMEmotionManager *manager = [QIMEmotionManager sharedInstance];
        NSString *currentPackageId = manager.currentPackageId;
        _dataList = [[QIMEmotionManager sharedInstance] getEmotionImagePathListForPackageId:currentPackageId];

    }
    return _dataList;
}

- (NSMutableArray *)devideEmojiList {
    
    if (!_devideEmojiList) {
        
        _devideEmojiList = [NSMutableArray array];
        for (NSInteger i = 0; i < self.dataList.count; i++) {
            
            NSMutableArray *arr1 = [NSMutableArray array];
            NSInteger counts = 0;
            while (counts != kEmotionFaceLines * kEmotionFaceNumPerLine - 1 && i < self.dataList.count) {
                
                counts ++;
                [arr1 addObject:self.dataList[i]];
                i++;
            }
            
            [_devideEmojiList addObject:arr1];
            i--;
        }
    }
    return _devideEmojiList;
}

- (QIMFaceViewDataSource *)lluDataSource {
    
    if (!_lluDataSource) {
        
        _lluDataSource = [[QIMFaceViewDataSource alloc] init];
        _lluDataSource.devideEmojiList = self.devideEmojiList;
    }
    return _lluDataSource;
}

+ (instancetype)FaceViewWithFrame:(CGRect)frame WithShowAll:(BOOL)showAll WithPKId:(NSString *)pkId {
    QIMFaceViewFlowLayout *layout = [[QIMFaceViewFlowLayout alloc] init];
    QIMFaceView *faceView = [[QIMFaceView alloc] initWithFrame:frame collectionViewLayout:layout];

    if (showAll || [pkId isEqualToString:@"qq"] || [pkId isEqualToString:@"yahoo"] || [pkId isEqualToString:@"EmojiOne"]) {
        // 水平间隔
        CGFloat horizontalInterval = (CGRectGetWidth(faceView.bounds)-kEmotionFaceNumPerLine*FaceSize -2*EdgeDistance)/(kEmotionFaceNumPerLine-1);
        // 上下垂直间隔
        CGFloat verticalInterval = (CGRectGetHeight(faceView.bounds)-2*EdgeInterVal -kEmotionFaceLines*FaceSize)/(kEmotionFaceLines-1);
        layout.minimumLineSpacing = horizontalInterval;
        layout.minimumInteritemSpacing = verticalInterval;
        //item的大小
        layout.itemSize = CGSizeMake(FaceSize, FaceSize);
        layout.sectionInset = UIEdgeInsetsMake(EdgeInterVal, EdgeDistance, EdgeInterVal, EdgeDistance);
    } else {
        
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        layout.itemSize = CGSizeMake(kImageFacePageViewItemWidth, kImageFacePageViewItemWidth);
        float colunmCap = (CGRectGetWidth(frame) - kImageFacePageViewItemWidth * kMyCollectionFaceNumPerLine - 2 * NormalEdgeInterVal) /
        (kMyCollectionFaceNumPerLine - 1);
        layout.sectionInset = UIEdgeInsetsMake(NormalEdgeInterVal, NormalEdgeDistance, NormalEdgeInterVal, NormalEdgeDistance);
        layout.minimumLineSpacing = colunmCap;
        layout.minimumInteritemSpacing = NormalEdgeInterVal;
    }

    faceView.bounces = NO;
    faceView.showsHorizontalScrollIndicator = NO;
    faceView.pagingEnabled = YES;
    
    return faceView;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        
        self.backgroundColor = [UIColor qtalkChatBgColor];
        self.delegate = self;
        [self registerClass:[QIMFaceViewCell class] forCellWithReuseIdentifier:cellID];
        self.dataSource = self.lluDataSource;
        [self setValue:@(self.devideEmojiList.count) forKey:@"pages"];
    }
    return self;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    NSString *faceName;
    BOOL isDelete;
    if (cell.tag == -1) {
        
        faceName = nil;
        isDelete = YES;
    } else {
        
        /**
         *  获取当前点击表情的路径
         */
        NSString * faceImagePath =  [[[ QIMEmotionManager sharedInstance] getEmotionImagePathListForPackageId:[[QIMEmotionManager sharedInstance] currentPackageId]] objectAtIndex:cell.tag];
        faceName = [[QIMEmotionManager sharedInstance] getEmotionShortCutForImagePath:faceImagePath withPackageId:[[QIMEmotionManager sharedInstance] currentPackageId]];
        isDelete = NO;
    }
    
    /**
     *  触发是否点击了删除表情代理方法
     *
     */
    if (self.faceViewDelegate && [self.faceViewDelegate respondsToSelector:@selector(didSelecteFace:andIsSelecteDelete:)]) {
        
        [self.faceViewDelegate didSelecteFace:faceName andIsSelecteDelete:isDelete];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetX = scrollView.contentOffset.x;
    self.pageIndex = offsetX / self.width;
    
    self.pageControl.currentPage = self.pageIndex;
    if (self.pageIndex) {
        if (self.faceViewDelegate && [self.faceViewDelegate respondsToSelector:@selector(pageControlHandlde:)]) {
            
            [self.faceViewDelegate pageControlHandlde:self.pageIndex];
        }
    } else {
        
    }
}
@end
