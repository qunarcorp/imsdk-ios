//
//  QIMFYDepartmentTableViewCell.m
//  qunarChatIphone
//
//  Created by qitmac000301 on 15/3/27.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMFYDepartmentTableViewCell.h"

@implementation QIMFYDepartmentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 40, 50)];
        self.departmentLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.TitleLabel.frame.origin.x + self.TitleLabel.frame.size.width + 5, 0, self.frame.size.width - self.TitleLabel.frame.size.width - 10, 50)];
        [self.departmentLabel setNumberOfLines:0];
        [self.contentView addSubview:self.TitleLabel];
        [self.contentView addSubview:self.departmentLabel];
        
    }
    return self;
}

@end
