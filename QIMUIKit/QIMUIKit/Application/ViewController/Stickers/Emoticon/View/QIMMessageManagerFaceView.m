//
//  QIMMessageManagerFaceView.m
//  QIMEmojiFace
//
//  Created by qitmac000495 on 16/5/10.
//  Copyright © 2016年 Qunar-lu. All rights reserved.
//

#import "QIMMessageManagerFaceView.h"

#define FaceSectionBarHeight  0   // 表情下面控件
#define FacePageControlHeight 30  // 表情pagecontrol

@interface QIMMessageManagerFaceView () {
    QIMFaceView * _faceView;
}

//pagecontrol
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation QIMMessageManagerFaceView

- (instancetype)initWithFrame:(CGRect)frame WithPkId:(NSString *)packageId{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.packageId = packageId;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    self.backgroundColor = [UIColor qtalkChatBgColor];
    _faceView = [QIMFaceView FaceViewWithFrame:CGRectMake(0, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - FaceSectionBarHeight - FacePageControlHeight) WithShowAll:self.showAll WithPKId:self.packageId];
    [_faceView setScrollsToTop:NO];
    _faceView.faceViewDelegate = self;
    NSInteger pages = _faceView.pages;
    [self addSubview:_faceView];
    
    self.pageControl = [[UIPageControl alloc] init];
    CGSize pagesize = CGSizeMake(_faceView.width, 20);
    self.pageControl.size = pagesize;
    self.pageControl.centerY = CGRectGetMaxY(_faceView.frame) + 15;
    self.pageControl.centerX = self.centerX;
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    self.pageControl.numberOfPages = pages;
    self.pageControl.currentPage   = 0;
    [self.pageControl addTarget:self action:@selector(pageControlHandle:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];

}


- (void)didSelecteFace:(NSString *)faceName andIsSelecteDelete:(BOOL)del {
    
    if ([self.delegate respondsToSelector:@selector(SendTheFaceStr:withPackageId:isDelete:)]) {
        
        [self.delegate SendTheFaceStr:faceName withPackageId:self.packageId isDelete:del];
    }
}

- (void)pageControlHandlde:(NSInteger)pageIndex {
    
    self.pageControl.currentPage = pageIndex;
}

- (void)pageControlHandle:(UIPageControl *)sender{
    [_faceView setContentOffset:CGPointMake(sender.currentPage * CGRectGetWidth(_faceView.bounds), _faceView.contentOffset.y) animated:YES];
}
@end
