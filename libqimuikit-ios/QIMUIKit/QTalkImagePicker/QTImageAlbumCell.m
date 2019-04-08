//
//  QTImageAlbumCell.m
//  qunarChatIphone
//
//  Created by admin on 15/8/18.
//
//

#import "QTImageAlbumCell.h"
//#import "NSBundle+QIMLibrary.h"

#define kThumbnailLength    78.0f

@interface QTImageAlbumCell (){
    UIButton        * _accessoryBtn;
}
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) UIView        * sepLine;
@end

@implementation QTImageAlbumCell

+ (CGFloat)getCellHeight{
    return kThumbnailLength + 12;
}

- (void)bind:(ALAssetsGroup *)assetsGroup
{
    self.assetsGroup            = assetsGroup;
    
    CGImageRef posterImage      = assetsGroup.posterImage;
    size_t height               = CGImageGetHeight(posterImage);
    float scale                 = height / kThumbnailLength;
    
    self.imageView.image        = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    self.textLabel.text         = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    if ([self.textLabel.text.lowercaseString isEqualToString:@"camera roll"]) {
        self.textLabel.text = @"相机胶卷";
    }
    self.detailTextLabel.text   = [NSString stringWithFormat:@"%ld", (long)[assetsGroup numberOfAssets]];
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _sepLine = [[UIView alloc] initWithFrame:CGRectZero];
    _sepLine.backgroundColor = [UIColor qtalkSplitLineColor];
    [self.contentView addSubview:_sepLine];
}

- (NSString *)accessibilityLabel
{
    NSString *label = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    return [label stringByAppendingFormat:NSLocalizedString(@"%ld 张照片", nil), (long)[self.assetsGroup numberOfAssets]];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.contentView.frame;
    frame.size.width = self.width;
    self.contentView.frame = frame;
    
    frame = self.imageView.frame;
    frame.origin.x = 15;
    self.imageView.frame = frame;
    
    frame = self.textLabel.frame;
    frame.origin.x = self.imageView.right + 10;
    self.textLabel.frame = frame;
    
    frame = self.detailTextLabel.frame;
    frame.origin.x = self.textLabel.left;
    self.detailTextLabel.frame = frame;
    
    if (_accessoryBtn == nil) {
        for (UIView * subView in self.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                _accessoryBtn = (UIButton *)subView;
                break;
            }
        }
    }
    
    frame = _accessoryBtn.frame;
    frame.origin.x = self.contentView.width - frame.size.width - 30;
    _accessoryBtn.frame = frame;
    
    _sepLine.frame = CGRectMake(5, self.contentView.height - 0.5, self.contentView.width - 10, 0.5);
    
}

@end
