//
//  QIMLocalLogTableViewCell.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/10.
//
//

#import "QIMLocalLogTableViewCell.h"
#import "QIMFileIconTools.h"
#import "QIMStringTransformTools.h"

@interface QIMLocalLogTableViewCell ()
{
    BOOL _selected;
}
@property (nonatomic, strong) NSDictionary *logFileDict;
@property (nonatomic, strong) UIImageView *fileIcon;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UIImageView *selectBtn;

@end

@implementation QIMLocalLogTableViewCell

#pragma mark - setter and getter

- (void)setLogFileDict:(NSDictionary *)logFileDict {
    if (logFileDict.count > 0) {
        _logFileDict = logFileDict;
        NSString *logFilePath = [logFileDict objectForKey:@"LogFilePath"];
        NSDictionary *logFileAttribute = [logFileDict objectForKey:@"logFileAttribute"];
        //文件字节数
        NSNumber *theFileSize = [logFileAttribute objectForKey:NSFileSize];
        //文件大小 MB
        NSString *fileSizeStr = [QIMStringTransformTools CapacityTransformStrWithSize:theFileSize.longLongValue];
        //文件名
        NSString *fileName = [logFilePath lastPathComponent];        
        [self.nameLabel setText:fileName];
        [self.sizeLabel setText:fileSizeStr];
        [self.fileIcon setImage:[QIMFileIconTools getFileIconWihtExtension:fileName.pathExtension]];
    }
}

- (UIImageView *)selectBtn {
    if (!_selectBtn) {
        _selectBtn = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_selectBtn setImage:[UIImage imageNamed:@"common_checkbox_no_44px"]];
    }
    return _selectBtn;
}

- (UIImageView *)fileIcon {
    if (!_fileIcon) {
        _fileIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _fileIcon;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.numberOfLines = 0;
    }
    return _nameLabel;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        _sizeLabel.backgroundColor = [UIColor clearColor];
        _sizeLabel.textColor = [UIColor lightGrayColor];
    }
    return _sizeLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _selected = NO;
        [self.contentView addSubview:self.selectBtn];
        [self.contentView addSubview:self.fileIcon];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.sizeLabel];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isSelect) {
        self.selectBtn.frame = CGRectMake(10, (self.contentView.height - 30) / 2, 24, 24);
    }else{
        self.selectBtn.frame = CGRectZero;
    }
    
    self.fileIcon.frame = CGRectMake(self.selectBtn.right + 10, 10, 60, 60);
    
    self.nameLabel.frame = CGRectMake(self.fileIcon.right + 10, self.fileIcon.top, self.contentView.width - self.fileIcon.right - 10 - 10, 20);
    
    self.sizeLabel.frame = CGRectMake(self.nameLabel.left, self.nameLabel.bottom + 15, self.nameLabel.width, 15);
}

- (void)setCellSelected:(BOOL)selected {
    _selected = selected;
    [self.selectBtn setImage:selected ? [UIImage imageNamed:@"common_checkbox_yes_44px"] : [UIImage imageNamed:@"common_checkbox_no_44px"]];
}

- (BOOL)isCellSelected {
    return _selected;
}

@end
