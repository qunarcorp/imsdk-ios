//
//  QIMCollectionEmotionEditorViewCell.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/14.
//
//

#import "QIMCollectionEmotionEditorViewCell.h"
#import "QIMCollectionFaceManager.h"

@interface QIMEmotionEditorImageView : UIView

@end

@interface QIMEmotionEditorImageView ()
{
    UIImageView        * _imageView;
    UIView             * _maskView;
    UIImageView        * _selectFlagView;
    BOOL                 _isAdd;
}

@end

@implementation QIMEmotionEditorImageView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(-1, -1, frame.size.width + 1, frame.size.height + 1)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.borderColor = [UIColor qim_colorWithHex:0xd6d6d4 alpha:1].CGColor;
        bgView.layer.borderWidth = 1;
        [self addSubview:bgView];
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setImageSize:(CGSize )size{
    _imageView.frame = CGRectMake(0, 0, size.width, size.height);
    _imageView.center = CGPointMake(self.width / 2, self.height / 2);
}

- (void)setIsAdd:(BOOL)isAdd{
    _isAdd = isAdd;
}

- (void)setImage:(UIImage *)image{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    if (_isAdd) {
        [self setImageSize:CGSizeMake(self.width / 3, self.width)];
    }else{
        _imageView.frame = CGRectMake(kImageViewCap, kImageViewCap, self.width - kImageViewCap * 2, self.height - kImageViewCap * 2);
    }
    _imageView.image = image;
}

- (void)setViewSelected:(BOOL)selected{
    [self setUpMaskViews];
    if (selected) {
        _maskView.hidden = NO;
        _selectFlagView.hidden = NO;
        [self insertSubview:_maskView aboveSubview:_imageView];
        [self insertSubview:_selectFlagView aboveSubview:_maskView];
    }else{
        _maskView.hidden = YES;
        _selectFlagView.hidden = YES;
    }
}

- (void)setUpMaskViews{
    if (_maskView == nil) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.backgroundColor = [UIColor lightGrayColor];
        _maskView.alpha = 0.2;
        _maskView.hidden = YES;
        [self addSubview:_maskView];
    }
    
    if (_selectFlagView == nil) {
        _selectFlagView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _selectFlagView.center = _maskView.center;
        _selectFlagView.image = [UIImage imageNamed:@"AlbumCellRedSelected"];
        _selectFlagView.hidden = YES;
        [self addSubview:_selectFlagView];
    }
}

- (BOOL)viewSelected{
    [self setUpMaskViews];
    return _maskView.hidden == NO;
}

@end

@implementation QIMCollectionEmotionEditorViewCell

- (void)setEmotionItem:(id)emotionItem {
    
    _emotionItem = emotionItem;
    [self setUpEmotionViews];
}

- (void)setUpEmotionViews {
    
    float itemWidth = [UIScreen mainScreen].bounds.size.width / 4;
    id item = _emotionItem;
    if ([item isKindOfClass:[NSDictionary class]]) {
        item = _emotionItem[@"httpUrl"];
    }
    QIMEmotionEditorImageView *itemView = [[QIMEmotionEditorImageView alloc] initWithFrame:self.bounds];
    itemView.tag = self.tag;
    UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapHandle:)];
    [itemView addGestureRecognizer:tapGes];
    [self.contentView addSubview:itemView];
    
    __block UIImage *itemImage = nil;
    if ([item isEqualToString:kImageFacePageViewAddFlagName]) {
        
        [itemView setIsAdd:YES];
        [itemView setImageSize:CGSizeMake(itemWidth / 3.0f, itemWidth / 3.0f)];
        
        //添加按钮
        itemImage = [UIImage imageNamed:@"EmotionEditorAdd"];
    } else {
        
        [itemView setIsAdd:NO];
        [[QIMCollectionFaceManager sharedInstance] showSmallImage:^(UIImage *image) {
            
            itemImage = image;
        } withIndex:self.tag];
    }
    
    [itemView setViewSelected:NO];
    [itemView setImage:itemImage];
    
    if ([item isEqualToString:kImageFacePageViewAddFlagName]){
        [itemView setImageSize:CGSizeMake(itemWidth / 3, itemWidth / 3)];
    }else{
        [itemView setImageSize:CGSizeMake(itemWidth - kImageViewCap * 2, itemWidth - kImageViewCap * 2)];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)itemTapHandle:(UITapGestureRecognizer *)tap{
    
    QIMEmotionEditorImageView * view = (QIMEmotionEditorImageView *)tap.view;
    if (self.canSelect) {
        [view setViewSelected:![view viewSelected]];
    }
    
    if (self.editDelegate && [self.editDelegate respondsToSelector:@selector(collectionEmotionEditorCell:didClickedItemAtIndex:selected:)]) {
        [self.editDelegate collectionEmotionEditorCell:self didClickedItemAtIndex:self.tag selected:[view viewSelected]];
    }
}

@end
