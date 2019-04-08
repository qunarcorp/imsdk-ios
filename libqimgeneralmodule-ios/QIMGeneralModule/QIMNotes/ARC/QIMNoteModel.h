//
//  QIMNoteModel.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/18.
//
//

#import <Foundation/Foundation.h>
#import "QIMNoteManager.h"

@protocol QIMPasswordModelUpdateDelegate <NSObject>

- (void)updatePasswordModel;

@end

@protocol TodoListModelUpdateDelegate <NSObject>

- (void)updateTodoListModel;

@end

@protocol QIMEverNoteModelUpdateDelegate <NSObject>

- (void)updateEverNoteModel;

@end

@interface QIMNoteModel : NSObject

@property (nonatomic, weak) id <QIMPasswordModelUpdateDelegate> pwdDelegate;

@property (nonatomic, weak) id <TodoListModelUpdateDelegate> todoDelegate;

@property (nonatomic, weak) id <QIMEverNoteModelUpdateDelegate> noteDelegate;

@property (nonatomic, copy) NSString *privateKey;

@property (nonatomic) NSInteger q_id;

@property (nonatomic) NSInteger qs_id;

@property (nonatomic) NSInteger c_id;

@property (nonatomic) NSInteger cs_id;

@property (nonatomic) QIMNoteType q_type;

@property (nonatomic, copy) NSString *q_title;

@property (nonatomic, copy) NSString *q_introduce;

@property (nonatomic, copy) NSString *q_content;

@property (nonatomic) NSInteger q_time;

@property (nonatomic) QIMNoteState q_state;

@property (nonatomic) QIMNoteExtendedFlagState q_ExtendedFlag;

@property (nonatomic) QIMPasswordType qs_type;

@property (nonatomic, copy) NSString *qs_title;

@property (nonatomic, copy) NSString *qs_introduce;

@property (nonatomic, copy) NSString *qs_content;

@property (nonatomic) NSInteger qs_time;

@property (nonatomic) QIMNoteState qs_state;

@property (nonatomic) QIMNoteExtendedFlagState qs_ExtendedFlag;

@end
