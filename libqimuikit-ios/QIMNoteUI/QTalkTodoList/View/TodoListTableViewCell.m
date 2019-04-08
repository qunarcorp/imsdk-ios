//
//  TodoListTableViewCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/31.
//
//

#import "TodoListTableViewCell.h"
#import "QIMNoteModel.h"
#import "QIMNoteUICommonFramework.h"

@interface TodoListTableViewCell ()

@property (nonatomic, strong) QIMNoteModel *model;
@property (nonatomic, assign) NSTimeInterval completeTime;

@end

@implementation TodoListTableViewCell

- (void)setTodoListModel:(QIMNoteModel *)model {
    if (model) {
        _model = model;
        NSString *content = model.q_content;
        if (content.length) {
            NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [[QIMJSONSerializer sharedInstance] deserializeObject:data error:nil];
            _completeTime = [[dict objectForKey:@"completeTime"] integerValue];
        }
        [self refreshUI];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.unFinished = YES;
        self.hasOutOfDate = NO;
        self.hasCompleted = NO;
        self.textLabel.numberOfLines = 0;
        self.selectedBackgroundView = [UIView new];
    }
    return self;
}

- (void)refreshUI {
    self.textLabel.text = self.model.q_title;
    if (self.hasCompleted) {
        self.textLabel.text = nil;
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:self.model.q_title];
        NSRange titleRange = NSMakeRange(0, title.length);
        NSDictionary *titleAttributes = @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle|NSUnderlinePatternSolid),
                                         NSStrikethroughColorAttributeName:[UIColor lightGrayColor], NSForegroundColorAttributeName:[UIColor lightGrayColor]};
        [title addAttributes:titleAttributes range:titleRange];
        self.textLabel.attributedText = title;
    }
    if (self.completeTime > 0) {
        NSString *timeStr = [[NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:self.completeTime] qim_formattedDateDescription];
        if (self.unFinished) {
            self.detailTextLabel.text = timeStr;
            self.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
        if (self.hasOutOfDate) {
            self.detailTextLabel.text = timeStr;
            self.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
        if (self.hasCompleted) {
            
            NSMutableAttributedString *time = [[NSMutableAttributedString alloc] initWithString:timeStr];
            NSRange timeRange = NSMakeRange(0, time.length);
            NSDictionary *timeAttributes = @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle|NSUnderlinePatternSolid),
                                             NSStrikethroughColorAttributeName:[UIColor lightGrayColor], NSForegroundColorAttributeName:[UIColor lightGrayColor]};
            [time addAttributes:timeAttributes range:timeRange];
            self.detailTextLabel.attributedText = time;
        }
    }
}

@end
