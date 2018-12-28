//
//  QIMEmotionManagerView.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/7.
//

#import "QIMEmotionManagerView.h"
#import "QIMEmotionView.h"
#import "QIMEmotionManager.h"

@interface QIMEmotionManagerView () <QIMEmotionViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) QIMEmotionView *emotionView;

@property (nonatomic, assign) QTalkEmotionType emotionType;

@end

@implementation QIMEmotionManagerView

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.centerX = self.centerX;
        _pageControl.centerY = CGRectGetMaxY(self.frame) - 10;
        _pageControl.currentPage  = 0;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        [_pageControl addTarget:self action:@selector(pageControlHandle:) forControlEvents:UIControlEventValueChanged];
    }
    _pageControl.numberOfPages = self.emotionView.totalPageIndex;
    return _pageControl;
}

- (QIMEmotionView *)emotionView {
    if (!_emotionView) {
        CGRect rect = self.bounds;
        rect.size.height -= 20;
        _emotionView = [QIMEmotionView qtalkEmotionCollectionViewWithFrame:rect WithPkid:self.packageId];
        _emotionView.emotionViewDelegate = self;
    }
    return _emotionView;
}

- (instancetype)initWithFrame:(CGRect)frame WithPkId:(NSString *)packageId {
    self = [super initWithFrame:frame];
    if (self) {
        [self registerNSNotification];
        self.packageId = packageId;
        [self addSubview:self.emotionView];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerNSNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCollectionList:) name:kCollectionEmotionUpdateHandleNotification object:nil];
}

//收藏表情数组改变时，pagecontrol位置改变
- (void)updateCollectionList:(NSNotification *)notify{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.emotionView reloadCollectionFaceView];
        self.pageControl.numberOfPages = self.emotionView.totalPageIndex;
    });
}

- (void)didSelectShowAllEmotion:(NSString *)faceName andIsSelectDelete:(BOOL)del {
    if (self.delegate && [self.delegate respondsToSelector:@selector(SendTheFaceStr:withPackageId:isDelete:)]) {
        [self.delegate SendTheFaceStr:faceName withPackageId:self.packageId isDelete:del];
    }
}

- (void)didSelectNormalEmotion:(NSString *)faceName {
    if (self.delegate && [self.delegate respondsToSelector:@selector(SendTheFaceStr:withPackageId:)]) {
        [self.delegate SendTheFaceStr:faceName withPackageId:self.packageId];
    }
}

- (void)changePageControlIndex:(NSInteger)pageIndex {
    self.pageControl.currentPage = pageIndex;
}

- (void)pageControlHandle:(UIPageControl *)sender {
    [self.emotionView setContentOffset:CGPointMake(sender.currentPage * CGRectGetWidth(self.emotionView.bounds), self.emotionView.contentOffset.y)  animated:YES];
}

@end
