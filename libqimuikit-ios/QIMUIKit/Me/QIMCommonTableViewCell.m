//
//  QIMCommonTableViewCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/21.
//

#import "QIMCommonTableViewCell.h"

#define CONTACT_CELL_IMAGE_SIZE 36

@interface QIMCommonTableViewCell ()

@property (nonatomic) QIMCommonTableViewCellStyle style;

@end

@implementation QIMCommonTableViewCell

+ (instancetype)cellWithStyle:(QIMCommonTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    QIMCommonTableViewCell *cell;
    switch (style) {
        case kQIMCommonTableViewCellStyleValue1:
        case kQIMCommonTableViewCellStyleValue2:
        case kQIMCommonTableViewCellStyleSubtitle:
        case kQIMCommonTableViewCellStyleDefault:
            cell = [[QIMCommonTableViewCell alloc] initWithStyle:(UITableViewCellStyle)style reuseIdentifier:reuseIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:TABLE_VIEW_CELL_DEFAULT_FONT_SIZE];
            break;
        case kQIMCommonTableViewCellStyleValueCenter:
        case kQIMCommonTableViewCellStyleContactList:
        case kQIMCommonTableViewCellStyleValueLeft:
            cell = [[QIMCommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.font = [UIFont systemFontOfSize:TABLE_VIEW_CELL_DEFAULT_FONT_SIZE];
            break;
        case kQIMCommonTableViewCellStyleContactSearchList:
            cell = [[QIMCommonTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            
            break;
    }
    
    cell.style = style;
    return cell;
}

- (void)setAccessoryType_LL:(QIMCommonTableViewCellAccessoryType)accessoryType_LL {
    _accessoryType_LL = accessoryType_LL;
    switch (accessoryType_LL) {
        case kQIMCommonTableViewCellAccessoryNone:
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        case kQIMCommonTableViewCellAccessoryDisclosureIndicator:
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case kQIMCommonTableViewCellAccessoryDetailButton:
            self.accessoryType = UITableViewCellAccessoryDetailButton;
            break;
        case kQIMCommonTableViewCellAccessoryDetailDisclosureButton:
            self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            break;
        case kQIMCommonTableViewCellAccessoryCheckmark:
            self.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
            
        case kQIMCommonTableViewCellAccessoryText: {
            self.accessoryType = UITableViewCellAccessoryNone;
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [UIColor blackColor];
            CGFloat fontSize = self.textLabel.font.pointSize;
            label.font = [UIFont systemFontOfSize:fontSize - 1];
            label.textAlignment = NSTextAlignmentCenter;
            self.accessoryView = label;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case kQIMCommonTableViewCellAccessorySwitch:
            self.accessoryType = UITableViewCellAccessoryNone;
            self.accessoryView = [[UISwitch alloc] init];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        default:
            break;
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame;
    
    switch (self.style) {
        case kQIMCommonTableViewCellStyleValueCenter: {
            [self.textLabel sizeToFit];
            frame = self.contentView.bounds;
            self.textLabel.center = CGPointMake(frame.size.width/2, frame.size.height/2);
            break;
        }
        case kQIMCommonTableViewCellStyleContactList: {
            frame = CGRectMake(10, 0, CONTACT_CELL_IMAGE_SIZE, CONTACT_CELL_IMAGE_SIZE);
            frame.origin.y = (CGRectGetHeight(self.contentView.frame) - CONTACT_CELL_IMAGE_SIZE) / 2;
            self.imageView.frame = frame;
            
            [self.textLabel sizeToFit];
            frame = self.textLabel.frame;
            frame.origin.x = CGRectGetMaxX(self.imageView.frame) + 10;
            frame.origin.y = (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(frame)) / 2;
            self.textLabel.frame = frame;
            
            break;
        }
        case kQIMCommonTableViewCellStyleContactSearchList: {
            
            
            break;
        }
        case kQIMCommonTableViewCellStyleValueLeft: {
            [self.textLabel sizeToFit];
            frame = self.textLabel.frame;
            frame.origin.x = TABLE_VIEW_CELL_LEFT_MARGIN;
            frame.origin.y = (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(frame)) / 2;
            self.textLabel.frame = frame;
            break;
        }
        default:
            break;
    }
}

- (BOOL)isSwitchOn {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UISwitch class]]) {
        UISwitch *switcher = (UISwitch *)self.accessoryView;
        return switcher.on;
    }else {
        return NO;
    }
}

- (void)setSwitchOn:(BOOL)on animated:(BOOL)animated {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UISwitch class]]) {
        UISwitch *switcher = (UISwitch *)self.accessoryView;
        [switcher setOn:on animated:animated];
    }
}

- (void)addSwitchTarget:(id)object tag:(NSUInteger)type action:(nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UISwitch class]]) {
        UISwitch *switcher = (UISwitch *)self.accessoryView;
        switcher.tag = type;
        [switcher addTarget:object action:action forControlEvents:controlEvents];
    }
}

- (NSString *)rightTextValue {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)self.accessoryView;
        return label.text;
    }
    
    return nil;
}

- (void)setRightTextValue:(NSString *)value {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)self.accessoryView;
        label.text = value;
        [label sizeToFit];
    }
}

@end
