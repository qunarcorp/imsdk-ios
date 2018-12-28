//
//  QTNoteCell.m
//  qunarChatIphone
//
//  Created by lihuaqi on 2017/9/21.
//
//

#import "QTNoteCell.h"
#import "QIMNoteModel.h"
#import "QIMNoteUICommonFramework.h"

@interface QTNoteCell()
@property (nonatomic,strong) UIImageView *iconImgV;
@property (nonatomic,strong) UILabel *titleLb;
@property (nonatomic,strong) UILabel *desLb;
@end
@implementation QTNoteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"noteCellId";
    QTNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[QTNoteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(void)createUI {
    _iconImgV = [[UIImageView alloc] initWithFrame:CGRectZero];
    _iconImgV.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_iconImgV];
    
    _titleLb = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLb.font = [UIFont fontWithName:FONT_NAME size:16];
    _titleLb.textColor = [UIColor blackColor];
    [self.contentView addSubview:_titleLb];
    
    _desLb = [[UILabel alloc] initWithFrame:CGRectZero];
    _desLb.font = [UIFont fontWithName:FONT_NAME size:14];
    _desLb.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_desLb];
}

-(void)refreshCellWithModel:(QIMNoteModel *)model {
    _iconImgV.image = [UIImage imageNamed:@"evernote_note"];
//    _titleLb.text = [NSString stringWithFormat:@"%ld & %ld---%@",(long)model.q_id,(long)model.qs_id,model.qs_title? model.qs_title:@""];
//    _desLb.text =  [NSString stringWithFormat:@"%ld & %ld---%@",(long)model.c_id,(long)model.cs_id,model.qs_introduce?model.qs_introduce:@""];
    _titleLb.text = [NSString stringWithFormat:@"%@",model.qs_title? model.qs_title:@""];
    _desLb.text =  [NSString stringWithFormat:@"%@",model.qs_introduce?model.qs_introduce:@""];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat iconW = 60;
    _iconImgV.frame = CGRectMake(20, (self.contentView.frame.size.height-iconW)*.5, iconW, iconW);
    
    _titleLb.frame = CGRectMake(CGRectGetMaxX(_iconImgV.frame)+10, CGRectGetMinY(_iconImgV.frame), self.contentView.frame.size.width - iconW-40, 25);
    
    _desLb.frame = CGRectMake(CGRectGetMinX(_titleLb.frame), CGRectGetMaxY(_titleLb.frame)+10, CGRectGetWidth(_titleLb.frame), 25);
    
}

@end
