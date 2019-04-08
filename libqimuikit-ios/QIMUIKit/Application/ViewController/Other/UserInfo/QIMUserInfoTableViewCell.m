//
//  QIMUserInfoTableViewCell.m
//  qunarChatIphone
//
//  Created by qitmac000301 on 15/3/24.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMUserInfoTableViewCell.h"

@implementation QIMUserInfoTableViewCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
     
        CGRect myframe = [UIScreen mainScreen].bounds;
        
        self.icon =  [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 75, 75)];
        [self.icon setContentMode:UIViewContentModeScaleAspectFill];
        
        self.nameLabel = [[UITextField alloc]initWithFrame:CGRectMake(self.icon.frame.origin.x + self.icon.frame.size.width + 10,
                                                                      self.icon.frame.origin.y + self.icon.frame.size.height/10,
                                                                      myframe.size.width/2,
                                                                      self.icon.frame.size.height/3 - 2)];

        self.icon.layer.masksToBounds = YES;
        self.icon.layer.cornerRadius = 5;


        self.nameLabel.userInteractionEnabled = NO;
        self.nameLabel.delegate = self;
        
        
        self.IDLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.nameLabel.frame.origin.x,
                                                                self.icon.frame.size.height  * 9 / 10 + self.icon.frame.origin.y - self.nameLabel.frame.size.height,
                                                                myframe.size.width - self.nameLabel.frame.origin.x - 10,
                                                                self.nameLabel.frame.size.height)];
   
        
        self.IDLabelTitle.font = [UIFont systemFontOfSize:14];
        self.IDLabel.textColor = [UIColor grayColor];
        
    
        [self.contentView addSubview:self.icon];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.IDLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserHeaderClick)];
        [self.icon setUserInteractionEnabled:YES];
        [self.icon addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)onUserHeaderClick{
    if ([self.delegate respondsToSelector:@selector(onUserHeaderClick)]) {
        [self.delegate onUserHeaderClick];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;

}



@end
