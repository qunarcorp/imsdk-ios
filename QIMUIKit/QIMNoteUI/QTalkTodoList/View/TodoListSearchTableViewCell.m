//
//  TodoListSearchTableViewCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/8/1.
//
//

#import "TodoListSearchTableViewCell.h"
#import "QIMNoteModel.h"
#import "QIMNoteUICommonFramework.h"

@interface TodoListSearchTableViewCell ()

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) QIMNoteModel *model;

@end

@implementation TodoListSearchTableViewCell

- (void)setTodoListModel:(QIMNoteModel *)model {
    _model = model;
    [self refreshUI];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)refreshUI {
    self.textLabel.text = self.model.q_title;
    NSString *timeStr = [[NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:self.model.q_time] qim_formattedDateDescription];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", timeStr];
}

@end
