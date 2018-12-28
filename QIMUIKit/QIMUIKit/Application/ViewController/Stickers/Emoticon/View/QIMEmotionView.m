//
//  QIMEmotionView.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/6.
//

#import "QIMEmotionView.h"
#import "QIMFaceViewCell.h"
#import "QIMCollectionViewCell.h"
#import "QIMEmotionTipDelegate.h"
#import "QIMCollectionFaceManager.h"
#import "QIMEmotionManager.h"

@interface QIMEmotionView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *originDataSource;
@property (nonatomic, strong) NSMutableArray *devideDataSource;
@property (nonatomic, weak) id <QIMEmotionTipDelegate> touchView;
@property (nonatomic, strong) NSMutableDictionary *collectionCellIdentifiers;

@property (nonatomic, strong) NSString *Pkid;

@end

static NSString *showAllEmotionCellId = @"showAllEmotionCellId";
static NSString *normalEmotionCellId = @"normalEmotionCellId";
static NSString *collectionCellId = @"CollectionCellId";

@implementation QIMEmotionView

#pragma mark - setter and getter

- (NSMutableDictionary *)collectionCellIdentifiers {
    if (!_collectionCellIdentifiers) {
        _collectionCellIdentifiers = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return _collectionCellIdentifiers;
}

- (NSMutableArray *)originDataSource {
    if (!_originDataSource) {
        _originDataSource = [NSMutableArray arrayWithCapacity:5];
        switch (self.emotionType) {
            case QTalkEmotionTypeShowAll:
            case QTalkEmotionTypeNormal: {
                _originDataSource = [NSMutableArray arrayWithArray:[[QIMEmotionManager sharedInstance] getEmotionImagePathListForPackageId:self.Pkid]];
            }
                break;
            case QTalkEmotionTypeCollection: {
                [_originDataSource addObjectsFromArray:[[QIMCollectionFaceManager sharedInstance] getCollectionFaceList]];
            }
                break;
            default:
                break;
        }
    }
    return _originDataSource;
}

- (NSMutableArray *)devideDataSource {
    if (!_devideDataSource) {
        _devideDataSource = [NSMutableArray arrayWithCapacity:5];
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.originDataSource];
        switch (self.emotionType) {
            case QTalkEmotionTypeShowAll: {
                for (NSInteger i = 0; i < tempArray.count; i++) {
                    
                    NSMutableArray *arr1 = [NSMutableArray array];
                    NSInteger counts = 0;
                    while (counts != kShowAllEmotionFaceLines * kShowAllEmotionFaceNumPerLine - 1 && i < tempArray.count) {
                        
                        counts ++;
                        [arr1 addObject:tempArray[i]];
                        i++;
                    }
                    
                    [_devideDataSource addObject:arr1];
                    i--;
                }
            }
                break;
            default:
                break;
        }
    }
    return _devideDataSource;
}

- (void)reloadCollectionFaceView {
    if (self.emotionType == QTalkEmotionTypeCollection) {
        self.originDataSource = [NSMutableArray arrayWithArray:[[QIMCollectionFaceManager sharedInstance] getCollectionFaceList]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
            [self updateTotalPageIndex];
        });
    }
}

+ (instancetype)qtalkEmotionCollectionViewWithFrame:(CGRect)frame WithPkid:(NSString *)packageId {
    BOOL showAll = [[QIMEmotionManager sharedInstance] isEmotionPackageSupportGraphicMixedForPackageId:packageId];
    QTalkEmotionType emotionType = QTalkEmotionTypeNormal;
    if ([packageId isEqualToString:@"EmojiOne"] || [packageId isEqualToString:@"qq"] || [packageId isEqualToString:@"yahoo"] || [packageId isEqualToString:@"mop"]) {
        emotionType = QTalkEmotionTypeShowAll;
    } else if ([packageId isEqualToString:kEmotionCollectionPKId]) {
        emotionType = QTalkEmotionTypeCollection;
    } else {
        emotionType = showAll ? QTalkEmotionTypeShowAll : QTalkEmotionTypeNormal;
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    switch (emotionType) {
        case QTalkEmotionTypeShowAll: {
            // 水平间隔
            CGFloat horizontalInterval = (CGRectGetWidth(frame)-kShowAllEmotionFaceNumPerLine*FaceSize -2*kShowAllEmotionFaceEdgeDistance)/(kShowAllEmotionFaceNumPerLine-1);
            // 上下垂直间隔
            CGFloat verticalInterval = (CGRectGetHeight(frame)-2*kShowAllEmotionFaceEdgeInterVal -kShowAllEmotionFaceLines*FaceSize)/(kShowAllEmotionFaceLines-1);
            layout.minimumLineSpacing = horizontalInterval;
            layout.minimumInteritemSpacing = verticalInterval;
            //item的大小
            layout.itemSize = CGSizeMake(FaceSize, FaceSize);
            layout.sectionInset = UIEdgeInsetsMake(kShowAllEmotionFaceEdgeInterVal, kShowAllEmotionFaceEdgeDistance, kShowAllEmotionFaceEdgeInterVal, kShowAllEmotionFaceEdgeDistance);
        }
            break;
        case QTalkEmotionTypeNormal:
        case QTalkEmotionTypeCollection: {
            
            layout.itemSize = CGSizeMake(kEmotionFaceItemWidth, kEmotionFaceItemWidth);
            float colunmCap = (CGRectGetWidth(frame) - kEmotionFaceItemWidth * kEmotionFaceNumPerLine - 2 * kEmotionFaceEdgeInterVal) /
            (kEmotionFaceNumPerLine - 1);
            layout.sectionInset = UIEdgeInsetsMake(kEmotionFaceEdgeInterVal, kEmotionFaceEdgeDistance, kEmotionFaceEdgeInterVal, kEmotionFaceEdgeDistance);
            layout.minimumLineSpacing = colunmCap;
            layout.minimumInteritemSpacing = kEmotionFaceEdgeDistance;
        }
            break;
        default:
            break;
    }
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    QIMEmotionView *collectionView = [[QIMEmotionView alloc] initWithFrame:frame collectionViewLayout:layout WithPackageId:packageId WithEmotionType:emotionType];
    collectionView.bounces = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.pagingEnabled = YES;
    
    return collectionView;
}

- (void)registerGestureRecognizer {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    longPress.allowableMovement = 10000;
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
}

- (void)updateTotalPageIndex {
    switch (self.emotionType) {
        case QTalkEmotionTypeShowAll: {
            self.totalPageIndex = self.devideDataSource.count;
        }
            break;
        case QTalkEmotionTypeCollection:
        case QTalkEmotionTypeNormal: {
            self.totalPageIndex = ceilf((float)self.originDataSource.count / (float)(kEmotionFaceLines * kEmotionFaceNumPerLine));
        }
            break;
        default:
            break;
    }
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout WithPackageId:(NSString *)Pkid WithEmotionType:(QTalkEmotionType)type {
    QIMVerboseLog(@"QTalkEmotionType : %ld, PKID : %@", type, Pkid);
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor qtalkChatBgColor];
        self.delegate = self;
        self.dataSource = self;
        self.Pkid = Pkid;
        self.emotionType = type;
        [self registerClass:[QIMCollectionViewCell class] forCellWithReuseIdentifier:collectionCellId];
        [self registerClass:[QIMFaceViewCell class] forCellWithReuseIdentifier:showAllEmotionCellId];
        [self registerClass:[QIMFaceViewCell class] forCellWithReuseIdentifier:normalEmotionCellId];
        [self registerGestureRecognizer];
        [self updateTotalPageIndex];
    }
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    switch (self.emotionType) {
        case QTalkEmotionTypeShowAll: {
            self.totalPageIndex = self.devideDataSource.count;
            return self.devideDataSource.count;
        }
            break;
        case QTalkEmotionTypeNormal: {
            float number = ceilf((float)self.originDataSource.count / (float)(kEmotionFaceLines * kEmotionFaceNumPerLine));
            self.totalPageIndex = number;
            return number;
        }
            break;
        case QTalkEmotionTypeCollection: {
            float number = ceilf((float)self.originDataSource.count / (float)(kEmotionFaceLines * kEmotionFaceNumPerLine));
            self.totalPageIndex = number;
            return (number > 0) ? number : 1;
        }
            break;
        default: {
            return 1;
        }
            break;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (self.emotionType) {
        case QTalkEmotionTypeShowAll: {
            return kShowAllEmotionFaceLines * kShowAllEmotionFaceNumPerLine;
        }
            break;
        case QTalkEmotionTypeNormal:
        case QTalkEmotionTypeCollection:{
            return kEmotionFaceLines * kEmotionFaceNumPerLine;
        }
            break;
        default: {
            return 0;
        }
            break;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    switch (self.emotionType) {
        case QTalkEmotionTypeShowAll: {
            QIMFaceViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:showAllEmotionCellId forIndexPath:indexPath];
            cell.emotionType = QTalkEmotionTypeShowAll;
            /**
             *  计算cell排列方式让collectionView横向滚动，一行一行地去排列
             */
            NSInteger column = indexPath.row / kShowAllEmotionFaceLines;
            NSInteger newRow = (indexPath.row - column * kShowAllEmotionFaceLines) * kShowAllEmotionFaceNumPerLine + column;
            
            if (!cell.userInteractionEnabled) {

                cell.userInteractionEnabled = YES;
            }
            //如果不是最后一组并且row == 23时为删除按钮
            if ((indexPath.section!= self.devideDataSource.count - 1) && newRow == (kShowAllEmotionFaceNumPerLine * kShowAllEmotionFaceLines - 1)) {
                cell.emojiView.image = [UIImage imageNamed:@"DeleteEmoticonBtn"];
                cell.tag = -1;
                [cell setAccessibilityIdentifier:@"-1"];
            } else if (indexPath.section == self.devideDataSource.count - 1 && newRow == [self.devideDataSource[indexPath.section] count]) {
                //如果是最后一组并且newRow = 该组最后一张时为删除按钮
                cell.emojiView.image = [UIImage imageNamed:@"DeleteEmoticonBtn"];
                cell.tag = -1;
                [cell setAccessibilityIdentifier:@"-1"];
                cell.userInteractionEnabled = YES;
            } else {
                if ([self.devideDataSource[indexPath.section] count] > newRow) {
                    NSString *imageStr = self.devideDataSource[indexPath.section][newRow];
                    imageStr = [[QIMEmotionManager sharedInstance] getImageAbsolutePathForRelativePath:imageStr];
                    cell.emojiPath = imageStr;
                    cell.emojiView.image = [[QIMEmotionManager sharedInstance] getEmotionThumbIconWithImageStr:imageStr BySize:CGSizeMake(FaceSize, FaceSize)];
                    cell.tag = indexPath.section * (kShowAllEmotionFaceNumPerLine * kShowAllEmotionFaceLines - 1) + newRow ;
                    [cell setAccessibilityIdentifier:[NSString stringWithFormat:@"%d", indexPath.section * (kShowAllEmotionFaceNumPerLine * kShowAllEmotionFaceLines - 1) + newRow]];
                    cell.userInteractionEnabled = YES;
                } else {
                    cell.emojiView.image = [UIImage new];
                    cell.tag = 0;
                    cell.userInteractionEnabled = NO;
                }
            }
            return cell;
        }
            break;
        case QTalkEmotionTypeNormal: {
            /**
             *  计算cell排列方式让collectionView横向滚动，一行一行地去排列
             */
            //行
            NSInteger column = indexPath.row / kEmotionFaceLines;
            NSInteger newRow = (indexPath.row - column * kEmotionFaceLines) * kEmotionFaceNumPerLine + column;
            NSInteger tag = indexPath.section * kEmotionFaceNumPerLine * kEmotionFaceLines + newRow;
            QIMFaceViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:normalEmotionCellId forIndexPath:indexPath];
            cell.emotionType = QTalkEmotionTypeNormal;
            cell.tag = tag;
            [cell setAccessibilityIdentifier:[NSString stringWithFormat:@"%ld", tag]];
            NSString *imageStr = self.originDataSource[tag];
            imageStr = [[QIMEmotionManager sharedInstance] getImageAbsolutePathForRelativePath:imageStr];
            cell.emojiPath = imageStr;
            cell.emojiView.image = [[QIMEmotionManager sharedInstance] getEmotionThumbIconWithImageStr:imageStr BySize:CGSizeMake(kShowAllImageFacePageViewItemWidth, kShowAllImageFacePageViewItemWidth)];
            return cell;
        }
            break;
        case QTalkEmotionTypeCollection: {
            QIMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellId forIndexPath:indexPath];
            /**
             *  计算cell排列方式让collectionView横向滚动，一行一行地去排列
             */
            //行
            NSInteger column = indexPath.row / kEmotionFaceLines;
            NSInteger newRow = (indexPath.row - column * kEmotionFaceLines) * kEmotionFaceNumPerLine + column;
            NSInteger tag = indexPath.section * kEmotionFaceNumPerLine * kEmotionFaceLines + newRow;
            cell.tag = tag;
            [cell setAccessibilityIdentifier:[NSString stringWithFormat:@"%ld", tag]];
            if (![cell isUserInteractionEnabled]) {
                [cell setUserInteractionEnabled:YES];
            }
            if(self.originDataSource.count + 1 > cell.tag) {
                [cell refreshUIWithFlag:YES];
            } else {
                [cell refreshUIWithFlag:NO];
            }
            [cell setRefreshCount:YES];
            return cell;
        }
        default:
            break;
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    switch (self.emotionType) {
        case QTalkEmotionTypeShowAll: {
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
                NSString * faceImagePath = [[[QIMEmotionManager sharedInstance] getEmotionImagePathListForPackageId:[[QIMEmotionManager sharedInstance] currentPackageId]] objectAtIndex:cell.tag];
                faceName = [[QIMEmotionManager sharedInstance] getEmotionShortCutForImagePath:faceImagePath withPackageId:[[QIMEmotionManager sharedInstance] currentPackageId]];
                isDelete = NO;
            }
            
            /**
             *  触发是否点击了删除表情代理方法
             *
             */
            if (self.emotionViewDelegate && [self.emotionViewDelegate respondsToSelector:@selector(didSelectShowAllEmotion:andIsSelectDelete:)]) {
                [self.emotionViewDelegate didSelectShowAllEmotion:faceName andIsSelectDelete:isDelete];
            }
        }
            break;
        case QTalkEmotionTypeNormal: {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            NSString *normalFaceImagePath = [[[QIMEmotionManager sharedInstance] getEmotionImagePathListForPackageId:[[QIMEmotionManager sharedInstance] currentPackageId]] objectAtIndex:cell.tag];
            NSString *faceName = [[QIMEmotionManager sharedInstance] getEmotionShortCutForImagePath:normalFaceImagePath withPackageId:[[QIMEmotionManager sharedInstance] currentPackageId]];
            //直接发送表情
            if (self.emotionViewDelegate && [self.emotionViewDelegate respondsToSelector:@selector(didSelectNormalEmotion:)]) {
                [self.emotionViewDelegate didSelectNormalEmotion:faceName];
            }
        }
            break;
        case QTalkEmotionTypeCollection: {
            QIMCollectionViewCell *cell = (QIMCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            NSString *fileUrl = nil;
            if (cell.tag) {
                fileUrl = [[QIMCollectionFaceManager sharedInstance] getCollectionFaceHttpUrlWithIndex:cell.tag - 1];
            } else {
                
                fileUrl = kImageFacePageViewAddFlagName;
            }
            
            NSMutableDictionary *collInfo = [NSMutableDictionary dictionaryWithDictionary:@{}];
            [collInfo setValue:@(cell.tag - 1) forKey:@"Index"];
            NSString *fileName = [[QIMKit sharedInstance] getFileNameFromUrl:fileUrl];
            
            if (fileName || !cell.tag) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionEmotionHandleNotification
                                                                    object:fileUrl];
            } else {
                if (cell.tag) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionEmotionNotFoundHandleNotification object:nil];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger pageIndex = offsetX / self.width;
    if (self.width * (pageIndex + 1) - offsetX < 20) {
        pageIndex += 1;
    }
    if (self.emotionViewDelegate && [self.emotionViewDelegate respondsToSelector:@selector(changePageControlIndex:)]) {
        [self.emotionViewDelegate changePageControlIndex:pageIndex];
    }
}

- (UIView *)subViewAtPoint:(CGPoint)point {
    if (point.y <= 0)return nil;
    for (UIView *view in self.subviews) {
        CGPoint localPoint = [view convertPoint:point fromView:self];
        if ([view pointInside:localPoint withEvent:nil]) {
            return view;
        }
    }
    return nil;
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)longPress {
    CGPoint point = [longPress locationInView:longPress.view];
    id <QIMEmotionTipDelegate> touchView = (id <QIMEmotionTipDelegate> )[self subViewAtPoint:point];
    if (longPress.state == UIGestureRecognizerStateEnded) {
        [_touchView didMoveOut];
    } else {
        if (touchView == _touchView) return;
        [_touchView didMoveOut];
        _touchView = touchView;
        [_touchView didMoveIn];
    }
}

@end
